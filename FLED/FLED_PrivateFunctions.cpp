#include "FLED.h"




void FLED::clockwiseContour(vector<Point> &antiContour)
{
	Point dot_ed;
	dot_ed = antiContour[antiContour.size() - 1];
	int idxdHead = dIDX(antiContour[0].x, antiContour[0].y);
	int idxdTail = dIDX(dot_ed.x, dot_ed.y);
	if (data[idxdHead].lastAddress != NULL)//如果非空，则选择起点为下一点
	{
		antiContour[0] = data[idxdHead].nextAddress->Location;//选择起点为下一点
		data[idxdHead].nextAddress->lastAddress = NULL;
		data[idxdHead].nextAddress = NULL;
		idxdHead = dIDX(antiContour[0].x, antiContour[0].y);
	}
	if (data[idxdTail].nextAddress != NULL)//如果不为空，则选择起点为前一点
	{
		dot_ed = data[idxdTail].lastAddress->Location;
		antiContour[antiContour.size() - 1] = dot_ed;
		data[idxdTail].lastAddress->nextAddress = NULL;
		data[idxdTail].lastAddress = NULL;
		idxdTail = dIDX(dot_ed.x, dot_ed.y);
	}
	//至此，起点和终点均已预处理完毕，只需要对整个弧段进行交换处理即可
	Node_FC * SigPot_Temp = NULL;
	Point* Idx_Dot = NULL;
	for (int step_idx = idxdTail; step_idx != idxdHead;)
	{
		SigPot_Temp = data[step_idx].nextAddress;
		data[step_idx].nextAddress = data[step_idx].lastAddress;
		data[step_idx].lastAddress = SigPot_Temp;
		Idx_Dot = &(data[step_idx].nextAddress->Location);
		step_idx = Idx_Dot->x*dCOLS + Idx_Dot->y;
	}//最后一个点没有交换		
	data[idxdHead].lastAddress = data[idxdHead].nextAddress;
	data[idxdHead].nextAddress = NULL;
	//后面参与计算均与起点终点有关，基本不会再涉及到内部矩阵元素，因此交换首尾重要信息
	int ID_temp = data[idxdTail].edgeID;
	double fit_sig_temp;
	data[idxdTail].edgeID = data[idxdHead].edgeID;
	data[idxdHead].edgeID = ID_temp;
	for (uint mm = 0; mm < MAT_NUMBER; mm++)
	{
		fit_sig_temp = data[idxdTail].nodesMat[mm];
		data[idxdTail].nodesMat[mm] = data[idxdHead].nodesMat[mm];
		data[idxdHead].nodesMat[mm] = fit_sig_temp;
	}
	for (uint mm = 0; mm < antiContour.size() / 2; mm++)
	{
		dot_ed = antiContour[mm];
		antiContour[mm] = antiContour[antiContour.size() - 1 - mm];
		antiContour[antiContour.size() - 1 - mm] = dot_ed;
	}
}

void FLED::GetArcMat(vector< cv::Vec<double, MAT_NUMBER> > &arcfitmat, vector< vector<Point> > &fsa_arc)
{
	const int arcs_num = fsa_arc.size();
	cv::Vec<double, MAT_NUMBER> *_arcs_data = NULL, *arc_temp = NULL;
	Point *st, *ed;
	int idx_st, idx_ed;
	Node_FC *st_node = NULL, *ed_node = NULL;

	arcfitmat.resize(arcs_num);
	_arcs_data = arcfitmat.data();

	for (int i = 0; i < arcs_num; i++)
	{
		arc_temp = _arcs_data + i;
		st = &fsa_arc[i][0]; ed = &fsa_arc[i].back();
		idx_st = dIDX(st->x, st->y); idx_ed = dIDX(ed->x, ed->y);
		st_node = data + idx_st; ed_node = data + idx_ed;
		for (int j = 0; j < MAT_NUMBER; j++)
			arc_temp->val[j] = ed_node->nodesMat[j] - st_node->nodesMat[j];
	}
}

void FLED::init_fitmat(double *basic_fitmat, double *init_fitmat, int num)
{
	for (int i = 0; i < num; i++)
		basic_fitmat[i] = init_fitmat[i];
}

void FLED::push_fitmat(double *basic_fitmat, double *add_fitmat, int num)
{
	for (int i = 0; i < num; i++)
		basic_fitmat[i] += add_fitmat[i];
}

void FLED::pop_fitmat(double *basic_fitmat, double *minus_fitmat, int num)
{
	for (int i = 0; i < num; i++)
		basic_fitmat[i] -= minus_fitmat[i];
}



void FLED::sortCombine(GPSD &fitComb, vector < cv::Vec<double, MAT_NUMBER> > arcMats[2], vector< vector<int> > s_group[2])
{
	double t1, t2;

	int temp_pos = 0;//统计负数个数


	int linking_num = arcMats[0].size(), linked_num = arcMats[1].size(), idx_i, idx;
	double val_l, val_r;
	fitComb.Update(linking_num*linked_num + linking_num + linked_num);
	for (int i = 0; i < linking_num; i++) //r
	{
		val_r = arcMats[0][i][MAT_NUMBER - 1];
		idx_i = i*linked_num;
		for (int j = 0; j < linked_num; j++)
		{
			if (s_group[1][j].size() >= 2)
			{
				val_l = arcMats[1][j][MAT_NUMBER - 1];
				fitComb[idx_i + j]->idx_r = i;
				fitComb[idx_i + j]->idx_l = j;
				fitComb[idx_i + j]->val = val_l + val_r;
			}
			else
			{
				fitComb[idx_i + j]->val = -1;
				temp_pos++;
			}
		}
	}
	idx_i = linking_num*linked_num;
	int arc_dp_idx;
	for (int i = 0; i < linking_num; i++)
	{
		idx = idx_i + i;
		//if (s_group[0][i].size() == 1) //说明这个只有1个fsa段
		//{
		//	if (FSA_ArcContours[s_group[0][i][0]].size() < MIN_DP_CONTOUR_NUM)
		//	{
		//		fitComb[idx]->val = -1;
		//		fitComb[idx]->idx_r = i;
		//		fitComb[idx]->idx_l = -1;
		//		continue;
		//	}
		//}
		
		fitComb[idx]->val = arcMats[0][i][MAT_NUMBER - 1];
		fitComb[idx]->idx_r = i;
		fitComb[idx]->idx_l = -1;
	}
	idx_i = linking_num*linked_num + linking_num;
	for (int i = 0; i < linked_num; i++)
	{
		idx = idx_i + i;
		if (s_group[1][i].size() > 2)
		{
			fitComb[idx]->val = arcMats[1][i][MAT_NUMBER - 1];
			fitComb[idx]->idx_l = i;
			fitComb[idx]->idx_r = -1;
		}
		//else if (s_group[1][i].size() == 2)
		//{
		//	if (FSA_ArcContours[s_group[1][i][1]].size() < MIN_DP_CONTOUR_NUM)
		//	{
		//		fitComb[idx]->val = -1;
		//		fitComb[idx]->idx_r = i;
		//		fitComb[idx]->idx_l = -1;
		//		continue;
		//	}
		//}
		else
		{
			fitComb[idx]->val = -1;
			temp_pos++;
		}
	}
	//t2 = (double)cv::getTickCount();
	//sum_time += (t2 - t1) * 1000 / cv::getTickFrequency();
	//t1 = cv::getTickCount();
	//cout << linking_num*linked_num + linking_num + linked_num << ". 复数个数：" << temp_pos << endl;
//	t1 = cv::getTickCount();
	std::sort(fitComb[0], fitComb[linking_num*linked_num + linking_num + linked_num - 1], cmp);
//	t2 = (double)cv::getTickCount();
//	sum_time += (t2 - t1) * 1000 / cv::getTickFrequency();
}



