#include "BigNumber.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

BigNumber::BigNumber(const char* str) {
    length = strlen(str);
    digits = (byte*)malloc(length * sizeof(byte));

    for (int i = 0; i < length; i++) {
        digits[i] = str[length - 1 - i] - '0';
    }
}

BigNumber::BigNumber(int len, int initValue) {
    length = len;
    digits = (byte*)malloc(length * sizeof(byte));

    for (int i = 0; i < length; i++) {
        digits[i] = initValue;
    }
}

BigNumber::BigNumber(const BigNumber& other) {
    length = other.length;
    digits = (byte*)malloc(length * sizeof(byte));
    memcpy(digits, other.digits, length * sizeof(byte));
}

BigNumber& BigNumber::operator=(const BigNumber& other) {
    if (this != &other) {
        free(digits);
        length = other.length;
        digits = (byte*)malloc(length * sizeof(byte));
        memcpy(digits, other.digits, length * sizeof(byte));
    }
    return *this;
}

BigNumber::~BigNumber() {
    free(digits);
}

void BigNumber::print() const {
    for (int i = length-1; i >= 0; i--) {
        printf("%d", digits[i]);
    }
    printf("\n");
}
