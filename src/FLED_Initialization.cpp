#include "FLED.h"

static double get_T_edge_num(double T_dp, double theta_fsa, double &_T_min_minor)
{
	_T_min_minor = T_dp / (1 - cos(theta_fsa / 2));

	double min_edge = _T_min_minor*theta_fsa;

	return min_edge;
}

static double get_T_edge_num(double theta_fsa, double &_T_min_minor)
{
	_T_min_minor = 1 / (1 - cos(theta_fsa / 2));
	
	return _T_min_minor * 2 * theta_fsa;
}


void FLED::SetParameters(double theta_fsa, double length_fsa, double T_val)
{
	assert(theta_fsa >= 0 || theta_fsa <= CV_PI / 2);
	assert(length_fsa > 1);
	assert(T_val > 0);

	_theta_fsa = theta_fsa;
	_length_fsa = length_fsa;
	_T_val = T_val;

	_T_edge_num = get_T_edge_num(theta_fsa, _T_min_minor);


}

void FLED::SetParameters(double T_dp, double theta_fsa, double length_fsa, double T_val, int grad_num)
{
	assert(T_dp >= std::sqrt(2.0) / 2);
	assert(theta_fsa >= 0 || theta_fsa <= CV_PI / 2);
	assert(length_fsa > 1);

	_T_dp = T_dp;
	_theta_fsa = theta_fsa;
	_length_fsa = length_fsa;
	_T_val = T_val;
	_T_gradnum = grad_num;

	_T_edge_num = get_T_edge_num(T_dp, theta_fsa, _T_min_minor);
}





