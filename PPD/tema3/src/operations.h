#ifndef OPERATIONS_H
#define OPERATIONS_H

#include "BigNumber.h"

BigNumber addSequential(const BigNumber& a, const BigNumber& b);

BigNumber addMPI1(const BigNumber& a, const BigNumber& b);
BigNumber addMPI1_Optimized(const BigNumber& a, const BigNumber& b);
BigNumber addMPI2_ScatterGather(const BigNumber& a, const BigNumber& b);
// BigNumber addMPI_Async(const BigNumber& a, const BigNumber& b);

#endif
