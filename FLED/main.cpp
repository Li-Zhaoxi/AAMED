#include "FLED.h"


int main()
{
	double t1, t2;
//	string imgPath = "E:\\Ellipse and Line Dataset\\Low Resolution\\6.png";
	string imgPath = "4.png";
	Mat imgC = cv::imread(imgPath);
	cv::imshow("Ori", imgC);
	FLED fled(1080, 1920);
	Mat imgG;
	cv::cvtColor(imgC, imgG, CV_RGB2GRAY);
	t1 = (double)cv::getTickCount();
	fled.run_FLED(imgG);
	t2 = (double)cv::getTickCount();
	cout << "Using Time is : " << (t2 - t1) * 1000 / cv::getTickFrequency() << " ms" << endl;
	fled.drawEdgeContours();
	fled.writeEdgeContours();
	fled.drawFSA_ArcContours();
	fled.writeFSA_ArcContours();
	fled.drawFSA_Lines();
	fled.writeFSA__Lines();
	fled.writeLinkMatrix();

	cv::waitKey();

	//Point2f p1(2, 3), p2(5, 4), p3(9, 6), p4(4, 7), p5(8, 1), p6(7, 2), p7(1, 1.5);

	//Mat source(7, 2, CV_32FC1);
	//source.at<float>(0, 0) = p1.x; source.at<float>(0, 1) = p1.y;
	//source.at<float>(1, 0) = p2.x; source.at<float>(1, 1) = p2.y;
	//source.at<float>(2, 0) = p3.x; source.at<float>(2, 1) = p3.y;
	//source.at<float>(3, 0) = p4.x; source.at<float>(3, 1) = p4.y;
	//source.at<float>(4, 0) = p5.x; source.at<float>(4, 1) = p5.y;
	//source.at<float>(5, 0) = p6.x; source.at<float>(5, 1) = p6.y;
	//source.at<float>(6, 0) = p7.x; source.at<float>(6, 1) = p7.y;

	//cv::flann::KDTreeIndexParams indexParams;
	//cv::flann::Index kdtree(source, indexParams, cvflann::FLANN_DIST_L1);
	////  2） 查找 :

	//Mat query = Mat::zeros(1, 2, CV_32FC1);
	//query.at<float>(0, 0) = 0.1; query.at<float>(0, 1) = 1;
	////query.at<float>(1, 0) = 10; query.at<float>(1, 1) = 10;
	////query.at<float>(2, 0) = 3; query.at<float>(2, 1) = 4;
	////vector<float> query;
	////Point2f pt(0.1, 1);
	////query.push_back(pt.x);
	////query.push_back(pt.y);


	////cv::Mat indices(source.rows, 1, CV_32F); 
	////cv::Mat dists(source.rows, 1, CV_32F);         //搜索到的最近邻的距离
	//Mat indices; Mat dists;
	//cv::flann::SearchParams params(32);

	//int idx = kdtree.radiusSearch(query, indices, dists, 1, source.rows, params);
	//
	//cout << indices.type() << endl;
	//cout << indices << endl;

	//cout << dists.type() << endl;
	//cout << dists << endl;
	//cout << "idx: " << idx << endl;
	system("pause");
	return 0;
}
