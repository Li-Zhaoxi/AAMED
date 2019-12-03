#include "FLED.h"

void FLED::findContours(uchar *_edge)
{
	const int clockWise[8][2] = { { 0,1 },{ 1,0 },{ 0,-1 },{ -1,0 },{ -1,1 },{ 1,1 },{ 1,-1 },{ -1,-1 } };
	const int anticlockWise[8][2] = { { 0,-1 },{ 1,0 },{ 0,1 },{ -1,0 },{ -1,-1 },{ 1,-1 },{ 1,1 },{ -1,1 } };
	int idx_first = (iROWS - 1)*iCOLS;

	for (int i = 0; i < iCOLS; i++)
	{
		_edge[i] = 0;
		_edge[idx_first + i] = 0;
	}
	for (int i = 1; i < iROWS - 1; i++)
	{
		_edge[i*iCOLS] = 0;
		_edge[i*iCOLS + iCOLS - 1] = 0;
	}
	for (int i = 1; i < iROWS; i++)
	{
		idx_first = i*iCOLS;
		for (int j = 1; j < iCOLS; j++)
		{
			if (_edge[idx_first + j])
			{
				_edge[idx_first + j] = 0;
				if (_edge[idx_first + iCOLS + j - 1] && _edge[idx_first + iCOLS + j] && _edge[idx_first + iCOLS + j + 1])
					continue;
				else
				{
					findContour(clockWise, anticlockWise, _edge, i, j);
				}
			}
		}
	}
}


void FLED::BoldEdge(uchar *_edge, const vector< vector<Point> > &edge_Contours)
{
	const uchar matBold[9] = { 1,2,3,11,12,13,21,22,23 };
	//const uchar matBold[9] = { 12,12,12,12,12,12,12,12,12 };
	int numContours = int(edge_Contours.size());
	int x, y, idx, idx_i;
	for (int i = 0; i < numContours; i++)
	{
		idx_i = int(edge_Contours[i].size());
		for (int j = 0; j < idx_i; j++)
		{
			idx = edge_Contours[i][j].x*iCOLS + edge_Contours[i][j].y;
			for (int k = 0; k < 9; k++)
			{
				x = matBold[k] / 10; y = matBold[k] - 10 * x;
				x -= 1, y -= 2;
				_edge[idx + x*iCOLS + y] = matBold[k];
			}
		}
	}
}



void FLED::findContour(const int Wise[8][2], const int antiWise[8][2], uchar *Edge, int x, int y)
{
	bool isEnd;
	int find_x, find_y;
	int move_x = x, move_y = y;
	oneContour.clear(); oneContourOpp.clear();
	oneContour.push_back(Point(x, y));
	int idxdMove = dIDX(x, y), idxiMove = iIDX(x, y), idxdFind, idxiFind;
	data[idxdMove].setFirst();
	while (1)
	{
		isEnd = true;
		idxiMove = iIDX(move_x, move_y);
		for (int i = 0; i < 8; i++)
		{
			find_x = move_x + Wise[i][0];
			find_y = move_y + Wise[i][1];
			idxiFind = iIDX(find_x, find_y);
			if (Edge[idxiFind])
			{
				Edge[idxiFind] = 0;
				isEnd = false;
				idxdMove = dIDX(move_x, move_y);
				idxdFind = dIDX(find_x, find_y);
				(data + idxdMove)->nextIs(data + idxdFind);
				move_x = find_x; move_y = find_y;
				oneContour.push_back(Point(move_x, move_y));
				break;
			}
		}
		if (isEnd)
		{
			idxdMove = dIDX(move_x, move_y);
			(data + idxdMove)->nextIs(NULL);
			break;
		}
	}
	move_x = oneContour[0].x; move_y = oneContour[0].y;
	while (1)
	{
		isEnd = true;
		idxiMove = iIDX(move_x, move_y);
		for (int i = 0; i < 8; i++)
		{
			find_x = move_x + antiWise[i][0];
			find_y = move_y + antiWise[i][1];
			idxiFind = iIDX(find_x, find_y);
			if (Edge[idxiFind])
			{
				Edge[idxiFind] = 0;
				isEnd = false;
				idxdMove = dIDX(move_x, move_y);
				idxdFind = dIDX(find_x, find_y);
				(data + idxdMove)->lastIs(data + idxdFind);
				move_x = find_x; move_y = find_y;
				oneContourOpp.push_back(Point(move_x, move_y));
				break;
			}
		}
		if (isEnd)
		{
			idxdMove = dIDX(move_x, move_y);
			(data + idxdMove)->lastIs(NULL);
			break;
		}
	}
	if (oneContour.size() + oneContourOpp.size() > _T_edge_num)
	{
		if (oneContourOpp.size() > 0)
		{
			Point temp;
			for (int i = 0; i < (oneContourOpp.size() + 1) / 2; i++)
			{
				temp = oneContourOpp[i];
				oneContourOpp[i] = oneContourOpp[oneContourOpp.size() - 1 - i];
				oneContourOpp[oneContourOpp.size() - 1 - i] = temp;
			}
			oneContourOpp.insert(oneContourOpp.end(), oneContour.begin(), oneContour.end());
			edgeContours.push_back(oneContourOpp);
		}
		else
			edgeContours.push_back(oneContour);
	}
}