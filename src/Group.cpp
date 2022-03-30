#include "FLED.h"
//搜索准则，输入point_idx 时，说明是以这个根节点为基准，查找下一个满足条件的弧段
void FLED::PosteriorArcsSearch2(int point_idx)
{
	const int arcs_num = FSA_ArcContours.size(), group_num = temp.size();
	char *_link_data = LinkMatrix.GetDataPoint();
	int idx_use;
	bool isValid = true, noArcs = false;
	ArcSearchRegion *_asrs_data = asrs.data();

	char check_val, temp_val;
	int find_now_idx = -1, find_arc_idx;
	vector<Point> *single_arc = NULL;


	//创建当前组合弧段的搜索区间
	Point *_st_data(NULL), *_ed_data(NULL);
	int grouped_st_idx, grouped_ed_idx, grouped_ed_arc_num;
	ArcSearchRegion grouped_arcs;

	grouped_st_idx = temp[0], grouped_ed_idx = temp.back();
	_st_data = FSA_ArcContours[grouped_st_idx].data();
	grouped_ed_arc_num = FSA_ArcContours[grouped_ed_idx].size();
	_ed_data = FSA_ArcContours[grouped_ed_idx].data();
	grouped_arcs.create(_st_data, _st_data + 1, _ed_data + grouped_ed_arc_num - 2, _ed_data + grouped_ed_arc_num - 1);

	while (1)
	{
		find_now_idx = lA[point_idx].findNextLinking(find_now_idx);
		if (find_now_idx == -1) //再也找不到可以组合的弧段
		{
			break;
		}
		find_arc_idx = lA[point_idx].idx_linking[find_now_idx]; //获取弧段角标
		if (*visited[find_arc_idx] != 0) //访问过
			continue;
		if (_arc_grouped_label[find_arc_idx] != 0) //被组合过
			continue;

		*visited[find_arc_idx] = 1;
		*searched[find_arc_idx] = 1;
		//验证候选组合点的中心点是否在搜索区间内(考虑到首尾均可能与当前区域相连，只有中点不会造成区域约束的实效).
		int single_num = FSA_ArcContours[find_arc_idx].size() / 2;
		bool inSearch = grouped_arcs.isInSearchRegion(&(FSA_ArcContours[find_arc_idx][single_num]));
		if (!inSearch)
			continue;

		// 验证是否满足第二个约束式
		idx_use = find_arc_idx*arcs_num;
		isValid = true;
		for (int i = 0; i < group_num; i++)
		{
			int tmpData_i = temp[i];
			check_val = _link_data[idx_use + tmpData_i];
			if (check_val == 0) // L_{i,k} ==0 ,there needs to use CASE_1 to varify whether L_{i,k} = -1.
			{
				temp_val = CASE_1(_asrs_data + point_idx, _asrs_data + tmpData_i);
				if (temp_val == -1)
				{
					_link_data[idx_use + tmpData_i] = _link_data[tmpData_i * arcs_num + point_idx] = -1;
					isValid = false;
					break;
				}
			}
			else if (check_val == -1)
			{
				isValid = false;
				break;
			}
		}
		if (isValid == false)
			continue;


		// 这个点是有效的
		temp.push_back(find_arc_idx);
		push_fitmat(fitArcTemp.val, ArcFitMat[find_arc_idx].val, MAT_NUMBER);
		PosteriorArcsSearch2(find_arc_idx);
	}

	//到这说明没有弧段可以组合了，获得当前组合，然后退掉一个点
	search_group[0].push_back(temp); //得到一个组合
	search_arcMats[0].push_back(fitArcTemp); //存储对应组合的拟合矩阵

	pop_fitmat(fitArcTemp.val, ArcFitMat[temp.back()].val, MAT_NUMBER); //删掉最后一个点的拟合矩阵
	temp.pop_back();
	*visited[point_idx] = 0;

}
void FLED::PosteriorArcsSearch(int point_idx)
{
	const int arcs_num = FSA_ArcContours.size(), group_num = temp.size();
	char *_link_data = LinkMatrix.GetDataPoint();
	int idx_use = point_idx*arcs_num;
	bool isValid = true;
	ArcSearchRegion *_asrs_data = asrs.data();

	int *_temp_data = temp.data();
	char check_val, temp_val;
	//检查当前点与其他组合点是否可相连 Linking Search the 2th search constraint
	for (int i = 0; i < group_num - 1; i++)
	{
		check_val = _link_data[idx_use + _temp_data[i]];
		if (check_val == 0) // L_{i,k} ==0 ,there needs to use CASE_1 to varify whether L_{i,k} = -1.
		{
			temp_val = CASE_1(_asrs_data + point_idx, _asrs_data + _temp_data[i]);
			if (temp_val == -1)
			{
				_link_data[idx_use + _temp_data[i]] = _link_data[_temp_data[i] * arcs_num + point_idx] = -1;
				isValid = false;
				break;
			}
		}
		else if (check_val == -1)
		{
			isValid = false;
			break;
		}
	}


	if (isValid == false)
	{
		search_group[0].push_back(temp); //得到一个组合
		search_arcMats[0].push_back(fitArcTemp); //存储对应组合的拟合矩阵

		pop_fitmat(fitArcTemp.val, ArcFitMat[temp.back()].val, MAT_NUMBER); //删掉最后一个点的拟合矩阵
		temp.pop_back();
		*visited[point_idx] = 0;

		return;
	}

	int find_now_idx = -1;
	while (1)
	{
		find_now_idx = lA[point_idx].findNextLinking(find_now_idx);
		if (find_now_idx < 0)//没有可以相连的弧段
		{
			search_group[0].push_back(temp); //得到一个组合
			search_arcMats[0].push_back(fitArcTemp); //存储对应组合的拟合矩阵
			pop_fitmat(fitArcTemp.val, ArcFitMat[temp.back()].val, MAT_NUMBER); //删掉最后一个点的拟合矩阵
			temp.pop_back();
			*visited[point_idx] = 0;
			break;
		}

		int find_arc_idx = lA[point_idx].idx_linking[find_now_idx];
		if (*visited[find_arc_idx] != 0)
			continue;
		if (_arc_grouped_label[find_arc_idx] != 0)
			continue;
		*visited[find_arc_idx] = 1;
		*searched[find_arc_idx] = 1;
		temp.push_back(find_arc_idx);
		push_fitmat(fitArcTemp.val, ArcFitMat[find_arc_idx].val, MAT_NUMBER);
		PosteriorArcsSearch(find_arc_idx);
	}



}

void FLED::AnteriorArcsSearch2(int point_idx)
{
	const int arcs_num = FSA_ArcContours.size(), group_num = temp.size();
	char *_link_data = LinkMatrix.GetDataPoint();
	int idx_use;
	bool isValid = true, noArcs = false;
	ArcSearchRegion *_asrs_data = asrs.data();

	int *_temp_data = temp.data();
	char check_val, temp_val;
	int find_now_idx = -1, find_arc_idx;
	vector<Point> *single_arc = NULL;


	//创建当前组合弧段的搜索区间
	Point *_st_data(NULL), *_ed_data(NULL);
	int grouped_st_idx, grouped_ed_idx, grouped_ed_arc_num;
	ArcSearchRegion grouped_arcs;

	//与前面不同的是，搜索点的顺序需要调换
	grouped_st_idx = _temp_data[group_num - 1], grouped_ed_idx = _temp_data[0];
	_st_data = FSA_ArcContours[grouped_st_idx].data();
	grouped_ed_arc_num = FSA_ArcContours[grouped_ed_idx].size();
	_ed_data = FSA_ArcContours[grouped_ed_idx].data();
	grouped_arcs.create(_st_data, _st_data + 1, _ed_data + grouped_ed_arc_num - 2, _ed_data + grouped_ed_arc_num - 1);

	while (1)
	{
		find_now_idx = lA[point_idx].findNextLinked(find_now_idx);
		if (find_now_idx == -1) //再也找不到可以组合的弧段
		{
			break;
		}
		find_arc_idx = lA[point_idx].idx_linked[find_now_idx]; //获取弧段角标
		if (*visited[find_arc_idx] != 0) //访问过
			continue;
		if (_arc_grouped_label[find_arc_idx] != 0) //被组合过
			continue;
		if (*searched[find_arc_idx] != 0) //被之前算法搜索过
			continue;

		*visited[find_arc_idx] = 1;

		//验证候选组合点的中心点是否在搜索区间内(考虑到首尾均可能与当前区域相连，只有中点不会造成区域约束的实效).
		int single_num = FSA_ArcContours[find_arc_idx].size() / 2;
		bool inSearch = grouped_arcs.isInSearchRegion(&(FSA_ArcContours[find_arc_idx][single_num]));
		if (!inSearch)
			continue;

		// 验证是否满足第二个约束式
		idx_use = find_arc_idx*arcs_num;
		isValid = true;
		for (int i = 0; i < group_num; i++)
		{
			check_val = _link_data[_temp_data[i] * arcs_num + find_arc_idx];
			//			check_val = _link_data[idx_use + _temp_data[i]];
			if (check_val == 0) // L_{i,k} ==0 ,there needs to use CASE_1 to varify whether L_{i,k} = -1.
			{
				temp_val = CASE_1(_asrs_data + _temp_data[i], _asrs_data + point_idx);
				if (temp_val == -1)
				{
					_link_data[idx_use + _temp_data[i]] = _link_data[_temp_data[i] * arcs_num + point_idx] = -1;
					isValid = false;
					break;
				}
			}
			else if (check_val == -1)
			{
				isValid = false;
				break;
			}
		}
		if (isValid == false)
			continue;


		// 这个点是有效的
		temp.push_back(find_arc_idx);
		push_fitmat(fitArcTemp.val, ArcFitMat[find_arc_idx].val, MAT_NUMBER);
		AnteriorArcsSearch2(find_arc_idx);
	}

	//到这说明没有弧段可以组合了，获得当前组合，然后退掉一个点
	search_group[1].push_back(temp); //得到一个组合
	search_arcMats[1].push_back(fitArcTemp); //存储对应组合的拟合矩阵

	pop_fitmat(fitArcTemp.val, ArcFitMat[temp.back()].val, MAT_NUMBER); //删掉最后一个点的拟合矩阵
	temp.pop_back();
	*visited[point_idx] = 0;
}
void FLED::AnteriorArcsSearch(int point_idx)
{
	const int arcs_num = FSA_ArcContours.size(), group_num = temp.size();
	char *_link_data = LinkMatrix.GetDataPoint();
	int idx_use = point_idx*arcs_num;
	bool isValid = true;

	ArcSearchRegion *_asrs_data = asrs.data();
	int *_temp_data = temp.data();
	char check_val, temp_val;





	//检查当前点与其他组合点是否可相连 Linking Search the 2th search constraint
	for (int i = 0; i < group_num - 1; i++)
	{
		check_val = _link_data[idx_use + _temp_data[i]];
		if (check_val == 0)
		{
			temp_val = CASE_1(_asrs_data + point_idx, _asrs_data + _temp_data[i]);
			if (temp_val == -1)
			{
				_link_data[idx_use + _temp_data[i]] = _link_data[_temp_data[i] * arcs_num + point_idx] = -1;
				isValid = false;
				break;
			}
		}
		else if (check_val == -1)
		{
			isValid = false;
			break;
		}
	}
	if (/*temp.size() > MAX_COMBINATION_ARCS ||*/ isValid == false)
	{
		search_group[1].push_back(temp); //得到一个组合
		search_arcMats[1].push_back(fitArcTemp); //存储对应组合的拟合矩阵

		pop_fitmat(fitArcTemp.val, ArcFitMat[temp.back()].val, MAT_NUMBER); //删掉最后一个点的拟合矩阵
		temp.pop_back();

		*visited[point_idx] = 0;
		return;
	}

	int find_now_idx = -1;
	while (1)
	{
		find_now_idx = lA[point_idx].findNextLinked(find_now_idx);
		if (find_now_idx < 0) //搜不到新点
		{
			search_group[1].push_back(temp);
			search_arcMats[1].push_back(fitArcTemp);

			pop_fitmat(fitArcTemp.val, ArcFitMat[temp.back()].val, MAT_NUMBER); //删掉最后一个点的拟合矩阵
			temp.pop_back();
			*visited[point_idx] = 0;
			break;
		}
		int find_arc_idx = lA[point_idx].idx_linked[find_now_idx];


		if (*visited[find_arc_idx] != 0)
			continue;
		if (_arc_grouped_label[find_arc_idx] != 0)
			continue;
		if (*searched[find_arc_idx] != 0)
			continue;
		*visited[find_arc_idx] = 1;
		push_fitmat(fitArcTemp.val, ArcFitMat[find_arc_idx].val, MAT_NUMBER);
		temp.push_back(find_arc_idx);
		AnteriorArcsSearch(find_arc_idx);
	}
}



void FLED::BiDirectionVerification(GPSD &fitComb, vector < cv::Vec<double, MAT_NUMBER> > fitMats[2], vector< vector<int> > link_group[2], vector<unsigned char> &arc_grouped)
{

#ifdef DETAIL_BREAKDOWN
	double tmp_st = 0;
#endif
	int fit_num = fitComb.usesize(), idx_l, idx_r, num_idx_l, num_idx_r;
	cv::RotatedRect fitelpres;

	bool isCombValid = true;
	int linked_num, linking_num, *_linked_data(NULL), *_linking_data(NULL), idx_link;
	char *_link_data = LinkMatrix.GetDataPoint();
	int arcs_num = FSA_ArcContours.size();

	//isBIDIR = 0;

	int max_idx(-1), max_idx_l, max_idx_r;
	double max_score(-1);
	cv::RotatedRect max_ellipse;

	for (int i = 0; i < fit_num; i++)
	{
		if (fitComb[i]->val < 0) //判断是否有效
			break;
		bool fitres;
		//t1 = cv::getTickCount();
		idx_l = fitComb[i]->idx_l; idx_r = fitComb[i]->idx_r;
		if (idx_l >= 0 && idx_r >= 0)
		{
			linked_num = link_group[1][idx_l].size(), linking_num = link_group[0][idx_r].size();
			_linked_data = link_group[1][idx_l].data();
			_linking_data = link_group[0][idx_r].data();
			for (int k = 0; k < linked_num; k++)
			{
				idx_link = _linked_data[k] * arcs_num;
				for (int p = 0; p < linking_num; p++)
				{
					if (_link_data[idx_link + _linking_data[p]] == -1)
					{
						isCombValid = false;
						break;
					}
				}
				if (isCombValid == false)
					break;
			}
			if (isCombValid == false)//两个弧段不能组合
				continue;
			fitres = FittingConstraint(fitMats[0][idx_r].val, fitMats[1][idx_l].val, fitelpres);

			//isBIDIR = 10; //说明开始组合

		}
		else if (idx_l >= 0)
			fitres = FittingConstraint(NULL, fitMats[1][idx_l].val, fitelpres);
		else if (idx_r >= 0)
			fitres = FittingConstraint(fitMats[0][idx_r].val, NULL, fitelpres);
		//t2 = (double)cv::getTickCount();
		//cout << "ElliFit Time: " << (t2 - t1) * 1000 / cv::getTickFrequency() << endl;
		//sum_time += 1;/// (t2 - t1) * 1000 / cv::getTickFrequency();


		if (fitres == false)
			continue;

		//t1 = cv::getTickCount();
		//利用validate进行比较
		double detScore;

#ifdef DETAIL_BREAKDOWN
		tmp_st = cv::getTickCount();
#endif

		fitres = fastValidation(fitelpres, &detScore);

#ifdef DETAIL_BREAKDOWN
		t_allvalidation += (cv::getTickCount() - tmp_st) * 1000 / cv::getTickFrequency();
		valitation_time++;
#endif
		if (fitres == false)
			continue;

		//if (detScore > max_score)
		//	max_idx = i, max_score = detScore, max_idx_l = idx_l, max_idx_r = idx_r, max_ellipse = fitelpres;


		num_idx_l = idx_l >= 0 ? search_group[1][idx_l].size() : -1;
		num_idx_r = idx_r >= 0 ? search_group[0][idx_r].size() : -1;
		for (int k = 0; k < num_idx_l; k++)
			arc_grouped[search_group[1][idx_l][k]] = 1;
		for (int k = 0; k < num_idx_r; k++)
			arc_grouped[search_group[0][idx_r][k]] = 1;
		detEllipses.push_back(fitelpres);
		detEllipseScore.push_back(detScore);

		//if (isBIDIR == 10)
		//	cout << "这张图有两种方向拟合的结果" << endl;
		break;


	}
	//if (max_idx < 0)
	//	return;
	//num_idx_l = max_idx_l >= 0 ? search_group[1][max_idx_l].size() : -1;
	//num_idx_r = max_idx_r >= 0 ? search_group[0][max_idx_r].size() : -1;
	//for (int k = 0; k < num_idx_l; k++)
	//	arc_grouped[search_group[1][max_idx_l][k]] = 1;
	//for (int k = 0; k < num_idx_r; k++)
	//	arc_grouped[search_group[0][max_idx_r][k]] = 1;
	//detEllipses.push_back(max_ellipse);
	//detEllipseScore.push_back(max_score);


}

