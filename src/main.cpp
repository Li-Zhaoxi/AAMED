#include "FLED.h"


int main()
{
	string imgPath = "002_0038.jpg";

	
	Mat imgC, imgG;
	AAMED aamed(540, 960);
	aamed.SetParameters(CV_PI / 3, 3.4, 0.77); // config parameters of AAMED

	imgC = cv::imread(imgPath);
	cv::cvtColor(imgC, imgG, CV_RGB2GRAY);

	aamed.run_FLED(imgG); // run AAMED

	cv::Vec<double, 10> detailTime;
	aamed.showDetailBreakdown(detailTime); // show detail execution time of each step
	aamed.drawFLED(imgG, "");
	aamed.writeDetailData();
	

	cv::waitKey();

	
	return 0;
}
