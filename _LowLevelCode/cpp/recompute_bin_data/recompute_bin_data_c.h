#pragma once

#include "CommonCode.h"

#include <memory>
#include <sstream>

void validate_inputs(const int &nlhs, mxArray *plhs[], const int &nrhs,
                     const mxArray *prhs[]);
