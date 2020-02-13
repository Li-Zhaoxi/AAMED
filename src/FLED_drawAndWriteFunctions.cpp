#include "FLED.h"


void FLED::writeDetailData()
{
	std::ofstream outfile("DetailAAMED.aamed", std::ios::binary);

	// basic information
	outfile << "basic";
	outfile.write((char*)&iROWS, sizeof(int));
	outfile.write((char*)&iCOLS, sizeof(int));
	outfile << "endbasic.";

	//write edgecontours;
	outfile << "edgecontours";
	int edgeNum = (int)edgeContours.size();
	outfile.write((char*)&edgeNum, sizeof(int));
	int edgeiNum;
	Point dotTemp;
	for (int i = 0; i < edgeNum; i++)
	{
		edgeiNum = (int)edgeContours[i].size();
		outfile.write((char*)&edgeiNum, sizeof(int));
		for (int j = 0; j < edgeiNum; j++)
		{
			dotTemp = edgeContours[i][j];
			outfile.write((char*)&(dotTemp.x), sizeof(int));
			outfile.write((char*)&(dotTemp.y), sizeof(int));
		}
	}
	outfile << "endedgecontours.";

	//write DP contours;
	outfile << "dpcontours";
	int dpNum = (int)dpContours.size();
	outfile.write((char*)&dpNum, sizeof(int));
	int dpiNum;
	for (int i = 0; i < dpNum; i++)
	{
		dpiNum = (int)dpContours[i].size();
		outfile.write((char*)&dpiNum, sizeof(int));
		for (int j = 0; j < dpiNum; j++)
		{
			dotTemp = dpContours[i][j];
			outfile.write((char*)&(dotTemp.x), sizeof(int));
			outfile.write((char*)&(dotTemp.y), sizeof(int));
		}
	}
	outfile << "enddpcontours.";

	//write arccontours
	outfile << "arccontours";
	int fsaNum = (int)FSA_ArcContours.size();
	outfile.write((char*)&fsaNum, sizeof(int));
	int fsaiNum;
	for (int i = 0; i < fsaNum; i++)
	{
		fsaiNum = (int)FSA_ArcContours[i].size();
		outfile.write((char*)&fsaiNum, sizeof(int));
		for (int j = 0; j < fsaiNum; j++)
		{
			dotTemp = FSA_ArcContours[i][j];
			outfile.write((char*)&(dotTemp.x), sizeof(int));
			outfile.write((char*)&(dotTemp.y), sizeof(int));
		}
	}
	outfile << "endarccontours.";


	// write linkmatrix.
	outfile << "arcadjacencymatrix";
	outfile.write((char*)&fsaNum, sizeof(int));
	char* _LinkMatrix = LinkMatrix.GetDataPoint();
	outfile.write(_LinkMatrix, sizeof(char)*fsaNum*fsaNum);
	outfile << "endarcadjacencymatrix.";

	// write final results;
	outfile << "detectedellipses";
	int elpNUm = detEllipses.size();
	outfile.write((char*)&elpNUm, sizeof(int));
	for (int i = 0; i < detEllipses.size(); i++)
	{
		outfile.write((char*)&detEllipses[i].center.x, sizeof(float));
		outfile.write((char*)&detEllipses[i].center.y, sizeof(float));
		outfile.write((char*)&detEllipses[i].size.height, sizeof(float));
		outfile.write((char*)&detEllipses[i].size.width, sizeof(float));
		outfile.write((char*)&detEllipses[i].angle, sizeof(float));
	}
	outfile << "enddetectedellipses.";

	outfile.close();
}


void FLED::drawEdgeContours()
{
	Mat Img_T = Mat::zeros(iROWS, iCOLS, CV_8UC1) + 255;
	uchar *_Img_T = (uchar*)Img_T.data;
	cout << "Size: edgeContours " << edgeContours.size() << endl;
	for (int i = 0; i < edgeContours.size(); i++)
	{
		for (int j = 0; j < edgeContours[i].size(); j++)
		{
			_Img_T[edgeContours[i][j].x*iCOLS + edgeContours[i][j].y] = 0;
		}
	}
	cv::imshow("EdgeContours", Img_T);
	cv::imwrite("Output Data/EdgeContours.png", Img_T);
}

void FLED::drawDPContours()
{
	char arcnum[10];
	Mat Img_T = Mat::zeros(iROWS, iCOLS, CV_8UC3) + cv::Scalar(255, 255, 255);
	for (int i = 0; i < dpContours.size(); i++)
	{
		for (int j = 0; j < dpContours[i].size() - 1; j++)
		{
			cv::line(Img_T, Point(dpContours[i][j].y, dpContours[i][j].x), Point(dpContours[i][j + 1].y, dpContours[i][j + 1].x), cv::Scalar(255, 0, 0), 2);
		}
		cv::circle(Img_T, Point(dpContours[i][0].y, dpContours[i][0].x), 2, cv::Scalar(0, 0, 255));
		Point arc_mid = dpContours[i][dpContours[i].size() / 2];
		sprintf_s(arcnum, "%d", i);
		cv::putText(Img_T, string(arcnum), Point(arc_mid.y, arc_mid.x + 2), cv::FONT_HERSHEY_SIMPLEX, 0.5, cv::Scalar(0, 0, 255), 1);
	}

	cv::imshow("dpContours", Img_T);
	cv::waitKey(1);
	cv::imwrite("Output Data/DPContours.png", Img_T);
}

void FLED::drawFSA_ArcContours()
{
	char arcnum[10];
	Mat Img_T = Mat::zeros(iROWS, iCOLS, CV_8UC3) + cv::Scalar(255,255,255);

	cout << "Size: FSA_ArcContours " << FSA_ArcContours.size() << endl;

	for (int i = 0; i < FSA_ArcContours.size(); i++)
	{
		for (int j = 0; j < FSA_ArcContours[i].size()-1; j++)
		{
			cv::line(Img_T, Point(FSA_ArcContours[i][j].y, FSA_ArcContours[i][j].x), Point(FSA_ArcContours[i][j + 1].y, FSA_ArcContours[i][j + 1].x), cv::Scalar(255, 0, 0), 2);
		}
		cv::circle(Img_T, Point(FSA_ArcContours[i][0].y, FSA_ArcContours[i][0].x), 2, cv::Scalar(0, 0, 255));

		Point arc_mid = FSA_ArcContours[i][FSA_ArcContours[i].size() / 2];
		sprintf_s(arcnum, "%d", i);
		cv::putText(Img_T, string(arcnum), Point(arc_mid.y, arc_mid.x + 2), cv::FONT_HERSHEY_SIMPLEX, 0.5, cv::Scalar(0, 0, 255), 1);

	}

	cv::imshow("FSA_ArcContours", Img_T);
	cv::imwrite("Output Data/FSA_ArcContours.png", Img_T);
}


void FLED::drawEllipses()
{
	cv::RotatedRect temp;
	Mat Img_T = Mat::zeros(iROWS, iCOLS, CV_8UC3);

	for (int i = 0; i < detEllipses.size(); i++)
	{
		temp.center.x = detEllipses[i].center.y;
		temp.center.y = detEllipses[i].center.x;
		temp.size.height = detEllipses[i].size.width;
		temp.size.width = detEllipses[i].size.height;
		temp.angle = -detEllipses[i].angle;
		ellipse(Img_T, temp, cv::Scalar(0, 0, 255), 2);
	}
	cv::imshow("Ellipses", Img_T);
	cout << "The number of ellipses£º" << detEllipses.size() << endl;
}
void FLED::drawFLED(Mat ImgC, double ust_time)
{
	Mat Img_T = ImgC;
	cv::RotatedRect temp;
	for (int i = 0; i < detEllipses.size(); i++)
	{
		temp.center.x = detEllipses[i].center.y;
		temp.center.y = detEllipses[i].center.x;
		temp.size.height = detEllipses[i].size.width;
		temp.size.width = detEllipses[i].size.height;
		temp.angle = -detEllipses[i].angle;
		
		ellipse(Img_T, temp, cv::Scalar(0, 0, 255), 2);
	}
	imshow("AMED", Img_T);

	char TimeUsing[128];
	if (ust_time > 0)
	{
		cout << ust_time << endl;
		sprintf_s(TimeUsing, "%.2fms", ust_time);
		cv::putText(Img_T, string(TimeUsing), Point(50,50), cv::FONT_HERSHEY_SIMPLEX, 1, cv::Scalar(0, 255, 255), 2);
	}
	


}
void FLED::drawFLED(Mat ImgG,string savepath)
{
	char arcnum[10];
	Mat Img_T = ImgG.clone();
	cvtColor(Img_T, Img_T, CV_GRAY2BGR);
//	Mat Img_T = ImgG;
	cv::RotatedRect temp;
	//for (int i = 0; i < FSA_Lines.size(); i++)
	//{
	//	cv::line(Img_T, Point(FSA_Lines[i].st.y, FSA_Lines[i].st.x), Point(FSA_Lines[i].ed.y, FSA_Lines[i].ed.x), cv::Scalar(255, 0, 0), 2);
	//}
	for (int i = 0; i < detEllipses.size(); i++)
	{
		//if (detEllipseScore[i] < 0.7)
		//	continue;
		temp.center.x = detEllipses[i].center.y;
		temp.center.y = detEllipses[i].center.x;
		temp.size.height = detEllipses[i].size.width;
		temp.size.width = detEllipses[i].size.height;
		temp.angle = -detEllipses[i].angle;
		ellipse(Img_T, temp, cv::Scalar(0, 0, 255), 2);
		sprintf_s(arcnum, "%.2f", detEllipseScore[i]);
		cv::putText(Img_T, string(arcnum), temp.center, cv::FONT_HERSHEY_SIMPLEX, 0.5, cv::Scalar(0, 0, 255), 1);
		cout << "The " << i << "th ellipse's score is :" << detEllipseScore[i] << endl;
	}
	cv::imshow("Ellipses", Img_T);
	if(savepath.length() > 0)
		imwrite(savepath, Img_T);
}

void FLED::writeFLED(string filepath, string filename, double useTime)
{
	std::ofstream outfile(filepath + filename, std::ios::out);
	outfile << useTime << endl;
	for (int i = 0; i < detEllipses.size(); i++)
	{
		outfile << "1" << " ";
		outfile << detEllipses[i].center.x << " " << detEllipses[i].center.y << " ";
		outfile << detEllipses[i].size.height << " " << detEllipses[i].size.width << " " << detEllipses[i].angle << endl;
	}
	outfile.close();
}


void FLED::showDetailBreakdown(cv::Vec<double, 10> &detDetailTime, int needDisplay)
{
#ifdef DETAIL_BREAKDOWN
	detDetailTime[0] = t_preprocess;
	detDetailTime[1] = t_arcsegment;
	detDetailTime[2] = t_allgrouping - t_allfitting - t_allvalidation;
	
	detDetailTime[3] = t_allfitting;
	detDetailTime[4] = fitting_time;
	detDetailTime[5] = fitting_time > 0 ? t_allfitting / fitting_time : 0;

	detDetailTime[6] = t_allvalidation;
	detDetailTime[7] = valitation_time;
	detDetailTime[8] = valitation_time > 0 ? t_allvalidation / valitation_time : 0;

	detDetailTime[9] = t_cluster;

	double sum_time = detDetailTime[0] + detDetailTime[1] + detDetailTime[2] + detDetailTime[3] + detDetailTime[6] + detDetailTime[9];
	dt_time += sum_time;

	if (needDisplay)
	{
		printf("Pre-Processing: %.4f ms.\n", detDetailTime[0]);
		printf("Arc Segmentation: %.4f ms.\n", detDetailTime[1]);
		printf("Arc Grouping: %.4f ms.\n", detDetailTime[2]);
		printf("Ellipse Fitting: %.4f ms, %.2f times, %.4f ms/time\n", detDetailTime[3], detDetailTime[4], detDetailTime[5]);
		printf("Ellipse Validation: %.4f ms, %.2f times, %.4f ms/time\n", detDetailTime[6], detDetailTime[7], detDetailTime[8]);
		printf("Ellipse Cluster: %.4f ms.\n", detDetailTime[9]);

		
		printf("Total: %.4f ms.\n", sum_time);
	}

	ds_t_preprocess += detDetailTime[0];
	ds_t_arcsegment += detDetailTime[1];
	ds_t_allgrouping += detDetailTime[2];

	ds_t_allfitting += detDetailTime[3];
	ds_fitting_time += detDetailTime[4];

	ds_t_allvalidation += detDetailTime[6];
	ds_valitation_time += detDetailTime[7];

	ds_t_cluster += detDetailTime[9];

	ds_num++;

#endif 
}

void FLED::showDatasetBreakdown()
{
#ifdef DETAIL_BREAKDOWN
	printf("Average Pre-Processing: %.4f ms.\n", ds_t_preprocess / ds_num);
	printf("Average Arc Segmentation: %.4f ms.\n", ds_t_arcsegment / ds_num);
	printf("Average Arc Grouping: %.4f ms.\n", ds_t_allgrouping / ds_num);

	double tmp;

	tmp = ds_fitting_time > 0 ? ds_t_allfitting / ds_fitting_time : 0;
	printf("Average Ellipse Fitting: %.4f ms, %.2f times, %.4f ms/time\n", ds_t_allfitting / ds_num, double(ds_fitting_time) / ds_num, tmp);

	tmp = ds_valitation_time > 0 ? ds_t_allvalidation / ds_valitation_time : 0;
	printf("Average Ellipse Validation: %.4f ms, %.2f times, %.4f ms/time\n", ds_t_allvalidation / ds_num, double(ds_valitation_time)/ ds_num, tmp);


	printf("Average Ellipse Cluster: %.4f ms.\n", ds_t_cluster / ds_num);

	double sum_time = dt_time / ds_num;
	printf("Average Time: %.4f ms.\n", sum_time);
#endif
}