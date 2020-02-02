#include "FLED.h"


int main()
{
	string imgPath = "002_0038.jpg";
	
	Mat imgC, imgG;
	AAMED aamed(540, 960);
	aamed.SetParameters(CV_PI / 3, 3.4, 0.77);

	imgC = cv::imread(imgPath);
	cv::cvtColor(imgC, imgG, CV_RGB2GRAY);

	aamed.run_FLED(imgG);

	cv::Vec<double, 10> detailTime;
	aamed.showDetailBreakdown(detailTime);
	aamed.drawFLED(imgG, "");


	cv::waitKey();

	
	return 0;
}
