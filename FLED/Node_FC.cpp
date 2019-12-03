#include "Node_FC.h"

Node_FC::Node_FC()
{
	edgeID = 1;
	nextAddress = NULL;
	lastAddress = NULL;
}

Node_FC::Node_FC(int x, int y, int scale)
{
	Location.x = x; Location.y = y;
	edgeID = 1;
	nextAddress = NULL;
	lastAddress = NULL;

	nodeMat[0] = pow(double(x), 4) / pow(scale, 4);
	nodeMat[1] = 2 * pow(double(x), 3)*y / pow(scale, 4);
	nodeMat[2] = double(x)*x*y*y / pow(scale, 4);
	nodeMat[3] = 2 * pow(double(x), 3) / pow(scale, 3);
	nodeMat[4] = 2 * double(x)*x*y / pow(scale, 3);
	nodeMat[5] = double(x)*x / (scale*scale);
	nodeMat[6] = 2 * double(x)*y*y*y / pow(scale, 4);
	nodeMat[7] = 4 * double(x)*y*y / pow(scale, 3);
	nodeMat[8] = 2 * double(x)*y / (scale*scale);
	nodeMat[9] = pow(double(y), 4) / pow(scale, 4);
	nodeMat[10] = 2 * pow(double(y), 3) / pow(scale, 3);
	nodeMat[11] = double(y)*y / (scale*scale);
	nodeMat[12] = 2 * double(x) / scale;
	nodeMat[13] = 2 * double(y) / scale;
	nodeMat[14] = 1;

}
