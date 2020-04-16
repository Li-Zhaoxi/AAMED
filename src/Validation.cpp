#include "FLED.h"


// When compiling AAMED with GCC under Linux, 
// some functions (cos, sin, tan, etc.) will generate some bugs, 
// which will result in the inability to detect ellipses.
#if defined(__GNUC__)
using namespace std;
#endif

void FLED::ClusterEllipses(std::vector<cv::RotatedRect> &detElps, vector<double> &detEllipseScore)
{
	const int ellipse_num = (int)detElps.size();
	if (ellipse_num == 0) return;

	// The first ellipse is assigned to a cluster
	std::vector<cv::RotatedRect> clusters;
	std::vector<double> scores;
	clusters.push_back(detElps[0]);
	scores.push_back(detEllipseScore[0]);

	bool bFoundCluster = false;


	float th_Da = 0.12f;
	float th_Db = 0.12f;
	float th_Dc_ratio = 0.12f;

	//float th_Dr = 0.13f;
	float th_Dr = 30.0 / 180 * CV_PI;

	float th_Dr_circle = 0.8f;


	float loop_width = 10;


	for (int i = 1; i < ellipse_num; i++)
	{
		cv::RotatedRect& e1 = detElps[i];
		int sz_clusters = int(clusters.size());

		float ba_e1 = e1.size.height / e1.size.width;
		float Decc1 = e1.size.height / e1.size.width;
		float score_i = detEllipseScore[i];

		bool bFoundCluster = false;
		for (int j = 0; j < sz_clusters; ++j)
		{
			cv::RotatedRect& e2 = clusters[j];

			float ba_e2 = e2.size.height / e2.size.width;
			float th_Dc = std::min(e1.size.height, e2.size.height) * th_Dc_ratio;
			if (th_Dc < 30 * th_Dc_ratio) th_Dc = 30 * th_Dc_ratio;
			th_Dc *= th_Dc;

			// Centers
			float Dc = ((e1.center.x - e2.center.x)*(e1.center.x - e2.center.x) + (e1.center.y - e2.center.y)*(e1.center.y - e2.center.y));
			if (Dc > th_Dc) continue;

			// a
			float Da = abs(e1.size.width - e2.size.width) / std::max(e1.size.width, e2.size.width);
			if (Da > th_Da && abs(e1.size.width - e2.size.width) > loop_width) continue;

			// b
			float Db = abs(e1.size.height - e2.size.height) / std::min(e1.size.height, e2.size.height);
			if (Db > th_Db && abs(e1.size.height - e2.size.height) > loop_width) continue;

			// angle
			float diff = std::abs(e1.angle - e2.angle) / 180 * CV_PI;
			float Dr = diff < CV_PI / 2 ? diff : CV_PI - diff;
			if ((Dr > th_Dr) && (ba_e1 < th_Dr_circle) && (ba_e2 < th_Dr_circle))
			{
				//not same cluster
				continue;
			}

			

			//Score
			float score_j = scores[j];

			if (score_i > score_j) 
			{
				clusters[j] = e1;
				scores[j] = score_i;
			}
			// Same cluster as e2
			bFoundCluster = true;//
								 // Discard, no need to create a new cluster
			break;
		}

		if (!bFoundCluster)
		{
			// Create a new cluster			
			clusters.push_back(e1);
			scores.push_back(score_i);
		}
	}

	clusters.swap(detElps);
	scores.swap(detEllipseScore);
}



bool FLED::Validation(cv::RotatedRect &res, double *detScore)
{

	//	return true;
	float _ROT_GRAD[4], _ROT_TRANS[4];
	float angleRot, xyCenter[2], R, r;
	float m, E_score(0), w, sum_w(0), step, norm_li_gi;
	int count1, count2;
	Node_FC *node_temp, *node_next = NULL, *node_last = NULL;
	Point l_i;
	Point2f g_i;
	int length_l_i_2, length_g_i_2;
	angleRot = res.angle / 180 * CV_PI; // The ellipse rotation angle.
	xyCenter[0] = res.center.x, xyCenter[1] = res.center.y; // The ellipse center xy.
	R = res.size.width / 2, r = res.size.height / 2; // The major-axis and minor-axis.
	m = r / R;
	// I_0(R,r).  Note: sqrt(2) -1 ~= 0.414213562373095
	if (4 * R*r < _T_min_minor*_T_min_minor)
		return false;

	//if (R*r < _T_min_minor*_T_min_minor*0.25)
	//	return false;

	if (R*r < _T_dp / (0.414213562373095)*sqrt(R*R + r*r))
		return false;


	//if (R/r > 30)
	//	cout << "ERROR" << endl;
	m = r / R;




	_ROT_TRANS[0] = R * cos(angleRot), _ROT_TRANS[1] = -r * sin(angleRot);
	_ROT_TRANS[2] = R  * sin(angleRot), _ROT_TRANS[3] = r  * cos(angleRot);

	_ROT_GRAD[0] = -r*sin(angleRot), _ROT_GRAD[1] = -R*cos(angleRot);
	_ROT_GRAD[2] = r*cos(angleRot), _ROT_GRAD[3] = -R*sin(angleRot);

	uchar* _boldData = (uchar*)imgCanny.data;
	const int vld_num = _T_gradnum;

	// Estimate the sampling points number N. Note: N = RoundEllipseCircum;
	int RoundEllipseCircum = int((R + r)*CV_PI);
	if (RoundEllipseCircum > 360) RoundEllipseCircum = 360;
	step = 360.0 / RoundEllipseCircum;

	int x, y, idxdxy, idxixy, angle_idx;
	int xOffset, yOffset, xReal, yReal, idxdxyReal;
	float vldBaseData_x, vldBaseData_y;

	//if (R / r > RoundEllipseCircum / 8)
	//	return false;
#if DEFINITE_ERROR_BOUNDED
	const int Prasad_R = 10;
	Point n;
	double dist, min_dist;
	Node_FC* node_center = NULL;
#endif 

	for (int i = 0; i < RoundEllipseCircum; i++)
	{
		angle_idx = round(i*step);
		if (angle_idx >= VALIDATION_NUMBER)
		{
			RoundEllipseCircum = i;
			break;
		}
		vldBaseData_x = vldBaseData[angle_idx][0], vldBaseData_y = vldBaseData[angle_idx][1];
		w = m / (m*m*vldBaseData_x * vldBaseData_x + vldBaseData_y * vldBaseData_y);
		//w = 1;
		sum_w += w;
		//Get a sample point
		x = _ROT_TRANS[0] * vldBaseData_x + _ROT_TRANS[1] * vldBaseData_y + xyCenter[0];
		y = _ROT_TRANS[2] * vldBaseData_x + _ROT_TRANS[3] * vldBaseData_y + xyCenter[1];
		if (OutOfRange(x, y))
			continue;
		idxdxy = dIDX(x, y);
		idxixy = iIDX(x, y);
		//I_1(V_i)
		if (_boldData[idxixy] != 0)
		{
			//get the real point on the edge map.
			xOffset = _boldData[idxixy] / 10; yOffset = _boldData[idxixy] - 10 * xOffset;
			xOffset = xOffset - 1; yOffset = yOffset - 2;
			xReal = x - xOffset; yReal = y - yOffset;
			idxdxyReal = dIDX(xReal, yReal);

			// estimate the grad of this point.
#if DEFINITE_ERROR_BOUNDED
			node_center = data + idxdxyReal;

			node_next = node_temp = node_center;
			node_temp = node_temp->nextAddress;
			for (count1 = 0, min_dist = 100; node_temp != NULL && count1 < Prasad_R; count1++)
			{
				n.x = node_temp->Location.x - node_center->Location.x;
				n.y = node_temp->Location.y - node_center->Location.y;
				dist = fabs(sqrt(double(n.x*n.x + n.y*n.y)) - Prasad_R);
				//dist = abs(abs(n.x) + abs(n.y) - Prasad_R);
				if (dist <= min_dist)
					min_dist = dist, node_next = node_temp;
				node_temp = node_temp->nextAddress;
			}
			node_last = node_temp = node_center;
			node_temp = node_temp->lastAddress;
			for (count2 = 0, min_dist = 100; node_temp != NULL && count2 < Prasad_R; count2++)
			{
				n.x = node_temp->Location.x - node_center->Location.x;
				n.y = node_temp->Location.y - node_center->Location.y;
				dist = fabs(sqrt(double(n.x*n.x + n.y*n.y)) - Prasad_R);
				//dist = abs(abs(n.x) + abs(n.y) - Prasad_R);
				if (dist <= min_dist)
					min_dist = dist, node_last = node_temp;
				node_temp = node_temp->lastAddress;
			}
			// Grad l_i Estimation
			l_i = node_next->Location - node_last->Location;
#else
			node_temp = data + idxdxyReal;
			node_last = node_next = NULL;
			for (count1 = 0; count1 < vld_num; count1++)
			{
				if (node_temp == NULL)
					break;
				node_next = node_temp;
				node_temp = node_temp->nextAddress;
				//				node_next = node_next->nextAddress;
			}
			node_temp = data + idxdxyReal;
			for (count2 = 0; count2 < vld_num; count2++)
			{
				if (node_temp == NULL)
					break;
				node_last = node_temp;
				node_temp = node_temp->lastAddress;
			}
			if (count1 + count2 < vld_num)
				continue;
			// Grad l_i Estimation
			l_i = node_next->Location - node_last->Location;
#endif
			length_l_i_2 = l_i.x*l_i.x + l_i.y*l_i.y;
			// Grad g_i Estimation
			g_i.x = _ROT_GRAD[0] * vldBaseData_x + _ROT_GRAD[1] * vldBaseData_y;
			g_i.y = _ROT_GRAD[2] * vldBaseData_x + _ROT_GRAD[3] * vldBaseData_y;
			length_g_i_2 = g_i.x*g_i.x + g_i.y*g_i.y;
			// |g_i * l_i| / (|g_i|*|l_i|)
			norm_li_gi = abs(l_i.x*g_i.x + l_i.y*g_i.y) / sqrt(length_l_i_2*length_g_i_2);
			//norm_li_gi = 1;
			if (norm_li_gi <= 0.707106781186548) // sqrt(2)/2 ~= 0.707106781186548
				continue;
			E_score += w*(norm_li_gi - 0.707106781186548) / (1 - 0.707106781186548);
			//E_score += w;



			//float grad[2], nl = lineGrad.x*lineGrad.x + lineGrad.y*lineGrad.y;
			//grad[0] = _ROT_GRAD[0] * vldBaseData_x + _ROT_GRAD[1] * vldBaseData_y;
			//grad[1] = _ROT_GRAD[2] * vldBaseData_x + _ROT_GRAD[3] * vldBaseData_y;
			//float nl2 = grad[0] * grad[0] + grad[1] * grad[1];
			//float csita = abs(lineGrad.x*grad[0] + lineGrad.y*grad[1]) / sqrt(nl*nl2);

			//float alpha = acos(csita);
			//// I_2(V_i)
			//if (csita <= cos(CV_PI / 4))
			//	continue;
			//float I_2;
			//if(csita > cos(CV_PI/8))
			//	I_2 = (csita - cos(CV_PI / 4)) / (1 - cos(CV_PI / 4));
			//else
			//{
			//	float I_2_t = (cos(CV_PI / 8) - cos(CV_PI / 4)) / (1 - cos(CV_PI / 4));
			//	I_2 = (csita - cos(CV_PI / 4)) / (1 - cos(CV_PI / 4));
			//}
			//float I_2 = 10 * (csita - cos(CV_PI/8)) / (1 - cos(CV_PI / 8));
			//I_2 = 1 / (1 + exp(-I_2));
			//E_score += I_2*w;


			//if (csita <= cos(CV_PI / 4))
			//	continue;
			//E_score += w*(csita - std::sqrt(2.0) / 2) / (1 - std::sqrt(2.0) / 2);
		}
	}

	E_score = E_score / sum_w*RoundEllipseCircum;
	if (E_score > RoundEllipseCircum * _T_val)
	{
		*detScore = E_score / RoundEllipseCircum;
		return true;
	}
	else
		return false;
}


/*
bool FLED::fastValidation(cv::RotatedRect &res, double *detScore)
{
	const float angleRot(res.angle / 180 * CV_PI),
		xyCenter[2] = { res.center.x, res.center.y },
		R(res.size.width / 2), r(res.size.height / 2);// The major-axis and minor-axis.
	
	// Shape constraint I_0(R,r).  Note: sqrt(2) - 1 ~= 0.414213562373095

	// Shape Index
	if (R*r * 4 < _T_min_minor * _T_min_minor)
		return false;
	if (R*r < 2 * _T_dp / (0.414213562373095)*sqrt(R*R + r*r))
		return false;

	const float _ROT_TRANS[4] = { R * cos(angleRot), -r * sin(angleRot), R  * sin(angleRot), r  * cos(angleRot) },
		_ROT_GRAD[4] = {-r*sin(angleRot), -R*cos(angleRot), r*cos(angleRot), -R*sin(angleRot)};

	float m = r / R;

	if (m < 0.2) { detScore = 0; return false; } 
	if (m < 0.4) m = 0.4;
	

	// Use SSE to faster the step of ellipse validation.
	__m256 _rot_trans_0 = _mm256_set1_ps(_ROT_TRANS[0]),
		_rot_trans_1 = _mm256_set1_ps(_ROT_TRANS[1]),
		_rot_trans_2 = _mm256_set1_ps(_ROT_TRANS[2]),
		_rot_trans_3 = _mm256_set1_ps(_ROT_TRANS[3]);

	__m256 _rot_grad_0 = _mm256_set1_ps(_ROT_GRAD[0]),
		_rot_grad_1 = _mm256_set1_ps(_ROT_GRAD[1]),
		_rot_grad_2 = _mm256_set1_ps(_ROT_GRAD[2]),
		_rot_grad_3 = _mm256_set1_ps(_ROT_GRAD[3]);

	__m256	x_center = _mm256_set1_ps(xyCenter[0]),
		y_center = _mm256_set1_ps(xyCenter[1]);

	__m256 mm = _mm256_set1_ps(m*m);
	__m256 tmp_x, tmp_y, tmp_gx, tmp_gy, tmp_wx, tmp_wy, tmp_w;
	
	for (int i = 0; i < VALIDATION_NUMBER; i += sizeof(__m256)/sizeof(float))
	{
		__m256 base_x = _mm256_load_ps(vldBaseDataX + i);
		__m256 base_y = _mm256_load_ps(vldBaseDataY + i);
		// calculate location x
		tmp_x = _mm256_add_ps(
			_mm256_mul_ps(_rot_trans_0, base_x),
			_mm256_mul_ps(_rot_trans_1, base_y));
		tmp_x = _mm256_add_ps(tmp_x, x_center);
		// calculate location y
		tmp_y = _mm256_add_ps(
			_mm256_mul_ps(_rot_trans_2, base_x),
			_mm256_mul_ps(_rot_trans_3, base_y));
		tmp_y = _mm256_add_ps(tmp_y, y_center);
		// calculate grad x
		tmp_gx = _mm256_add_ps(
			_mm256_mul_ps(_rot_grad_0, base_x),
			_mm256_mul_ps(_rot_grad_1, base_y));
		// calculate grad y
		tmp_gy = _mm256_add_ps(
			_mm256_mul_ps(_rot_grad_2, base_x),
			_mm256_mul_ps(_rot_grad_3, base_y));
		// calculate weight
		tmp_wx = _mm256_mul_ps(mm, _mm256_mul_ps(base_x, base_x));
		tmp_wy = _mm256_mul_ps(base_y, base_y);
		tmp_w = _mm256_div_ps(
			_mm256_set1_ps(m),
			_mm256_add_ps(tmp_wx, tmp_wy));
		// Save location x, y, gx, gy
		_mm256_storeu_ps(sample_x + i, tmp_x);
		_mm256_storeu_ps(sample_y + i, tmp_y);
		_mm256_storeu_ps(grad_x + i, tmp_gx);
		_mm256_storeu_ps(grad_y + i, tmp_gy);
		_mm256_storeu_ps(sample_weight + i, tmp_w);

	}

	// Estimate the sampling points number N. Note: N = RoundEllipseCircum;
	float step;
	int RoundEllipseCircum = int((R + r)*CV_PI);
	if (RoundEllipseCircum > 360) RoundEllipseCircum = 360;
	step = 360.0 / RoundEllipseCircum;


#if DEFINITE_ERROR_BOUNDED
	const int Prasad_R = 10;
	Point n;
	double dist, min_dist;
	Node_FC* node_center = NULL;
#else 
	const int vld_num = _T_gradnum;
#endif 

	int x, y, idxdxy, idxixy, angle_idx;
	int xOffset, yOffset, xReal, yReal, idxdxyReal, count1, count2, length_l_i_2, length_g_i_2;
	float w, sum_w(0), norm_li_gi, E_score(0);
	unsigned char* _boldData = (unsigned char*)imgCanny.data;
	Node_FC *node_temp(NULL), *node_next = NULL, *node_last = NULL;
	Point l_i;
	cv::Point2f g_i;
	float inSw = 0, outSw = 0, inNum = 0, onNum = 0;
	for (int i = 0; i < RoundEllipseCircum; i++)
	{
		angle_idx = round(i*step);
		if (angle_idx >= VALIDATION_NUMBER)
		{
			RoundEllipseCircum = i;
			break;
		}
		w = sample_weight[angle_idx];
		//w = 1;
		sum_w += w;

		x = sample_x[angle_idx], y = sample_y[angle_idx];
		if (OutOfRange(x, y))
		{
			outSw += w;
			continue;
		}
		inSw += w;
		inNum += 1;
		
		idxdxy = dIDX(x, y), idxixy = iIDX(x, y);

		if (_boldData[idxixy] == 0)
		{
			E_score += w * 0.5;
			continue;
		}
		onNum += 1;
		//get the real point on the edge map.
		xOffset = _boldData[idxixy] / 10; yOffset = _boldData[idxixy] - 10 * xOffset;
		xOffset = xOffset - 1; yOffset = yOffset - 2;
		xReal = x - xOffset; yReal = y - yOffset;
		idxdxyReal = dIDX(xReal, yReal);
		// estimate the grad of this point.
#if DEFINITE_ERROR_BOUNDED
		node_center = data + idxdxyReal;

		node_next = node_temp = node_center;
		node_temp = node_temp->nextAddress;
		for (count1 = 0, min_dist = 100; node_temp != NULL && count1 < Prasad_R; count1++)
		{
			n.x = node_temp->Location.x - node_center->Location.x;
			n.y = node_temp->Location.y - node_center->Location.y;
			dist = fabs(sqrt(double(n.x*n.x + n.y*n.y)) - Prasad_R);
			//dist = abs(abs(n.x) + abs(n.y) - Prasad_R);
			if (dist <= min_dist)
				min_dist = dist, node_next = node_temp;
			node_temp = node_temp->nextAddress;
		}
		node_last = node_temp = node_center;
		node_temp = node_temp->lastAddress;
		for (count2 = 0, min_dist = 100; node_temp != NULL && count2 < Prasad_R; count2++)
		{
			n.x = node_temp->Location.x - node_center->Location.x;
			n.y = node_temp->Location.y - node_center->Location.y;
			dist = fabs(sqrt(double(n.x*n.x + n.y*n.y)) - Prasad_R);
			//dist = abs(abs(n.x) + abs(n.y) - Prasad_R);
			if (dist <= min_dist)
				min_dist = dist, node_last = node_temp;
			node_temp = node_temp->lastAddress;
		}
		// Grad l_i Estimation
		if (count1 + count2 + 2 < Prasad_R / 2)
			continue;
		l_i = node_next->Location - node_last->Location;
#else
		node_temp = data + idxdxyReal;
		node_last = node_next = NULL;
		for (count1 = 0; count1 < vld_num; count1++)
		{
			if (node_temp == NULL)
				break;
			node_next = node_temp;
			node_temp = node_temp->nextAddress;
			//				node_next = node_next->nextAddress;
		}
		node_temp = data + idxdxyReal;
		for (count2 = 0; count2 < vld_num; count2++)
		{
			if (node_temp == NULL)
				break;
			node_last = node_temp;
			node_temp = node_temp->lastAddress;
		}
		if (count1 + count2 < vld_num)
			continue;
		// Grad l_i Estimation
		l_i = node_next->Location - node_last->Location;
#endif
		length_l_i_2 = l_i.x*l_i.x + l_i.y*l_i.y;
		// Grad g_i Estimation
		g_i.x = grad_x[angle_idx], g_i.y = grad_y[angle_idx];
		length_g_i_2 = g_i.x*g_i.x + g_i.y*g_i.y;

		// |g_i * l_i| / (|g_i|*|l_i|)
		norm_li_gi = abs(l_i.x*g_i.x + l_i.y*g_i.y) / sqrt(length_l_i_2*length_g_i_2);
		//if (norm_li_gi <= 0.707106781186548) // sqrt(2)/2 ~= 0.707106781186548
		//	continue;
		//E_score += w*(norm_li_gi - 0.707106781186548) / (1 - 0.707106781186548);
		if (norm_li_gi > 1) norm_li_gi = 1;
		E_score += w*abs(1 - 2 / CV_PI * acos(norm_li_gi));

		//E_score += w;

	}

	if (outSw > inSw)
		E_score = 0;
	else
	{
		E_score = E_score / inSw *inNum;
	}
	//E_score = E_score / sum_w*RoundEllipseCircum;


	if (E_score > inNum * _T_val)
	{
		*detScore = E_score / inNum;
		return true;
	}
	else
		return false;

	
	
}
*/



bool FLED::fastValidation(cv::RotatedRect &res, double *detScore)
{
	const float angleRot(res.angle / 180 * CV_PI),
		xyCenter[2] = { res.center.x, res.center.y },
		R(res.size.width / 2), r(res.size.height / 2);// The major-axis and minor-axis.

	// Shape constraint I_0(R,r).  Note: sqrt(2) - 1 ~= 0.414213562373095

	// Shape Index
	if (R*r * 4 < _T_min_minor * _T_min_minor)
		return false;
	if (R*r < 2 * _T_dp / (0.414213562373095)*sqrt(R*R + r * r))
		return false;
	
	const float _ROT_TRANS[4] = { R * cos(angleRot), -r * sin(angleRot), R  * sin(angleRot), r  * cos(angleRot) },
		_ROT_GRAD[4] = { -r * sin(angleRot), -R * cos(angleRot), r*cos(angleRot), -R * sin(angleRot) };

	float m = r / R;

	if (m < 0.2) { detScore = 0; return false; } // \B3\F6\CF\D6\D4\E0\CA\FD\BEݣ\ACʹ\D3\C3\D5ⷽ\B7\A8\BD\E2\BE\F6
	if (m < 0.4) m = 0.4;

#if !FASTER_ELLIPSE_VALIDATION
	float tmpw, vldBaseData_x, vldBaseData_y, tmpx, tmpy, tmpgx, tmpgy;
	for (int i = 0; i < VALIDATION_NUMBER; i++)
	{
		vldBaseData_x = vldBaseData[i][0];
		vldBaseData_y = vldBaseData[i][1];
		tmpw = m / (m*m*vldBaseData_x * vldBaseData_x + vldBaseData_y * vldBaseData_y);
		tmpx = _ROT_TRANS[0] * vldBaseData_x + _ROT_TRANS[1] * vldBaseData_y + xyCenter[0];
		tmpy = _ROT_TRANS[2] * vldBaseData_x + _ROT_TRANS[3] * vldBaseData_y + xyCenter[1];
		tmpgx = _ROT_GRAD[0] * vldBaseData_x + _ROT_GRAD[1] * vldBaseData_y;
		tmpgy = _ROT_GRAD[2] * vldBaseData_x + _ROT_GRAD[3] * vldBaseData_y;


		sample_x[i] = tmpx;
		sample_y[i] = tmpy;
		grad_x[i] = tmpgx;
		grad_y[i] = tmpgy;
		sample_weight[i] = tmpw;
	}
#else
	// Estimate the sampling points number N. Note: N = RoundEllipseCircum;
	// Use SSE to faster the step of ellipse validation.
	__m256 _rot_trans_0 = _mm256_set1_ps(_ROT_TRANS[0]),
		_rot_trans_1 = _mm256_set1_ps(_ROT_TRANS[1]),
		_rot_trans_2 = _mm256_set1_ps(_ROT_TRANS[2]),
		_rot_trans_3 = _mm256_set1_ps(_ROT_TRANS[3]);

	__m256 _rot_grad_0 = _mm256_set1_ps(_ROT_GRAD[0]),
		_rot_grad_1 = _mm256_set1_ps(_ROT_GRAD[1]),
		_rot_grad_2 = _mm256_set1_ps(_ROT_GRAD[2]),
		_rot_grad_3 = _mm256_set1_ps(_ROT_GRAD[3]);

	__m256	x_center = _mm256_set1_ps(xyCenter[0]),
		y_center = _mm256_set1_ps(xyCenter[1]);

	__m256 mm = _mm256_set1_ps(m*m);
	__m256 tmp_x, tmp_y, tmp_gx, tmp_gy, tmp_wx, tmp_wy, tmp_w;

	for (int i = 0; i < VALIDATION_NUMBER; i += sizeof(__m256) / sizeof(float))
	{
		__m256 base_x = _mm256_load_ps(vldBaseDataX + i);
		__m256 base_y = _mm256_load_ps(vldBaseDataY + i);
		// calculate location x
		tmp_x = _mm256_add_ps(
			_mm256_mul_ps(_rot_trans_0, base_x),
			_mm256_mul_ps(_rot_trans_1, base_y));
		tmp_x = _mm256_add_ps(tmp_x, x_center);
		// calculate location y
		tmp_y = _mm256_add_ps(
			_mm256_mul_ps(_rot_trans_2, base_x),
			_mm256_mul_ps(_rot_trans_3, base_y));
		tmp_y = _mm256_add_ps(tmp_y, y_center);
		// calculate grad x
		tmp_gx = _mm256_add_ps(
			_mm256_mul_ps(_rot_grad_0, base_x),
			_mm256_mul_ps(_rot_grad_1, base_y));
		// calculate grad y
		tmp_gy = _mm256_add_ps(
			_mm256_mul_ps(_rot_grad_2, base_x),
			_mm256_mul_ps(_rot_grad_3, base_y));
		// calculate weight
		tmp_wx = _mm256_mul_ps(mm, _mm256_mul_ps(base_x, base_x));
		tmp_wy = _mm256_mul_ps(base_y, base_y);
		tmp_w = _mm256_div_ps(
			_mm256_set1_ps(m),
			_mm256_add_ps(tmp_wx, tmp_wy));
		// Save location x, y, gx, gy
		_mm256_storeu_ps(sample_x + i, tmp_x);
		_mm256_storeu_ps(sample_y + i, tmp_y);
		_mm256_storeu_ps(grad_x + i, tmp_gx);
		_mm256_storeu_ps(grad_y + i, tmp_gy);
		_mm256_storeu_ps(sample_weight + i, tmp_w);

	}
#endif




	float step;
	int RoundEllipseCircum = int((R + r)*CV_PI);
	if (RoundEllipseCircum > 360) RoundEllipseCircum = 360;
	step = 360.0 / RoundEllipseCircum;


#if DEFINITE_ERROR_BOUNDED
	const int Prasad_R = 10;
	Point n;
	double dist, min_dist;
	Node_FC* node_center = NULL;
#else 
	const int vld_num = _T_gradnum;
#endif 

	int x, y, idxdxy, idxixy, angle_idx;
	int xOffset, yOffset, xReal, yReal, idxdxyReal, count1, count2, length_l_i_2, length_g_i_2;
	float w, sum_w(0), norm_li_gi, E_score(0);
	unsigned char* _boldData = (unsigned char*)imgCanny.data;
	Node_FC *node_temp(NULL), *node_next = NULL, *node_last = NULL;
	Point l_i;
	cv::Point2f g_i;
	float inSw = 0, outSw = 0, inNum = 0, onNum = 0;
	for (int i = 0; i < RoundEllipseCircum; i++)
	{
		angle_idx = round(i*step);
		if (angle_idx >= VALIDATION_NUMBER)
		{
			RoundEllipseCircum = i;
			break;
		}
		w = sample_weight[angle_idx];
		//w = 1;
		sum_w += w;

		x = sample_x[angle_idx], y = sample_y[angle_idx];
		if (OutOfRange(x, y))
		{
			outSw += w;
			continue;
		}
		inSw += w;
		inNum += 1;

		idxdxy = dIDX(x, y), idxixy = iIDX(x, y);

		if (_boldData[idxixy] == 0)
		{
			E_score += w * 0.5;
			continue;
		}
		onNum += 1;
		//\BB\F1ȡ\D5\E6ʵ\B1\DFԵ\B5\E3
		xOffset = _boldData[idxixy] / 10; yOffset = _boldData[idxixy] - 10 * xOffset;
		xOffset = xOffset - 1; yOffset = yOffset - 2;
		xReal = x - xOffset; yReal = y - yOffset;
		idxdxyReal = dIDX(xReal, yReal);
		// \B9\C0\BCƵ\B1ǰ\B5\E3\B5\C4\CCݶ\C8ֵ
#if DEFINITE_ERROR_BOUNDED
		node_center = data + idxdxyReal;

		node_next = node_temp = node_center;
		node_temp = node_temp->nextAddress;
		for (count1 = 0, min_dist = 100; node_temp != NULL && count1 < Prasad_R; count1++)
		{
			n.x = node_temp->Location.x - node_center->Location.x;
			n.y = node_temp->Location.y - node_center->Location.y;
			dist = fabs(sqrt(double(n.x*n.x + n.y*n.y)) - Prasad_R);
			//dist = abs(abs(n.x) + abs(n.y) - Prasad_R);
			if (dist <= min_dist)
				min_dist = dist, node_next = node_temp;
			node_temp = node_temp->nextAddress;
		}
		node_last = node_temp = node_center;
		node_temp = node_temp->lastAddress;
		for (count2 = 0, min_dist = 100; node_temp != NULL && count2 < Prasad_R; count2++)
		{
			n.x = node_temp->Location.x - node_center->Location.x;
			n.y = node_temp->Location.y - node_center->Location.y;
			dist = fabs(sqrt(double(n.x*n.x + n.y*n.y)) - Prasad_R);
			//dist = abs(abs(n.x) + abs(n.y) - Prasad_R);
			if (dist <= min_dist)
				min_dist = dist, node_last = node_temp;
			node_temp = node_temp->lastAddress;
		}
		// Grad l_i Estimation
		if (count1 + count2 + 2 < Prasad_R / 2)
			continue;
		l_i = node_next->Location - node_last->Location;
#else
		node_temp = data + idxdxyReal;
		node_last = node_next = NULL;
		for (count1 = 0; count1 < vld_num; count1++)
		{
			if (node_temp == NULL)
				break;
			node_next = node_temp;
			node_temp = node_temp->nextAddress;
			//				node_next = node_next->nextAddress;
		}
		node_temp = data + idxdxyReal;
		for (count2 = 0; count2 < vld_num; count2++)
		{
			if (node_temp == NULL)
				break;
			node_last = node_temp;
			node_temp = node_temp->lastAddress;
		}
		if (count1 + count2 < vld_num)
			continue;
		// Grad l_i Estimation
		l_i = node_next->Location - node_last->Location;
#endif
		length_l_i_2 = l_i.x*l_i.x + l_i.y*l_i.y;
		// Grad g_i Estimation
		g_i.x = grad_x[angle_idx], g_i.y = grad_y[angle_idx];
		length_g_i_2 = g_i.x*g_i.x + g_i.y*g_i.y;

		// |g_i * l_i| / (|g_i|*|l_i|)
		norm_li_gi = abs(l_i.x*g_i.x + l_i.y*g_i.y) / sqrt(length_l_i_2*length_g_i_2);
		//if (norm_li_gi <= 0.707106781186548) // sqrt(2)/2 ~= 0.707106781186548
		//	continue;
		//E_score += w*(norm_li_gi - 0.707106781186548) / (1 - 0.707106781186548);
		if (norm_li_gi > 1) norm_li_gi = 1;
		E_score += w * abs(1 - 2 / CV_PI * acos(norm_li_gi));

		//E_score += w;

	}

	if (outSw > inSw)
		E_score = 0;
	else
	{
		E_score = E_score / inSw * inNum;
	}
	//E_score = E_score / sum_w*RoundEllipseCircum;


	if (E_score > inNum * _T_val)
	{
		*detScore = E_score / inNum;
		return true;
	}
	else
		return false;



}
