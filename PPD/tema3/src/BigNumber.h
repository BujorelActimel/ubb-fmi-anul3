#ifndef BIGNUMBER_H
#define BIGNUMBER_H

#define byte unsigned char

struct BigNumber {
    int length;
    byte* digits;

    BigNumber(const char* str);
    BigNumber(int len, int initValue);
    BigNumber(const BigNumber& other);
    BigNumber& operator=(const BigNumber& other);
    ~BigNumber();
    void print() const;
};

#endif
