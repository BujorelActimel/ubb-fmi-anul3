#ifndef UTILS_H
#define UTILS_H

#include "BigNumber.h"

BigNumber readFromFile(const char* filename);
void writeToFile(const char* filename, const BigNumber& num);
int min(int first, int second);
int max(int first, int second);

#endif
