#include "AAMBasedCombinations.h"

void AAMBasedCombinations::PosteriorArcsSearch(int rootidx)
{
	const int arcs_num = _AAM_rows, group_num = TempArcsComb.size();
	const char *_link_data = _AAM;
	const int *_TempArcs = TempArcsComb.data();
	int idx_use = rootidx*arcs_num;
	bool isValid = true;
	char check_val;
	//检查当前点与其他组合点是否可相连 Linking Search the 2th search constraint
	for (int i = 0; i < group_num; i++)
	{
		char check_val = _link_data[idx_use + _TempArcs[i]];
		if (check_val == -1)
		{
			isValid = false;
			break;
		}
	}



	if (isValid == false)
	{

	}



}