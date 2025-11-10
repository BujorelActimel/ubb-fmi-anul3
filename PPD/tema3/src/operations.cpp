#include "operations.h"
#include "utils.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mpi.h>

BigNumber addSequential(const BigNumber& a, const BigNumber& b) {
    int smallLength = min(a.length, b.length);
    int largeLength = max(a.length, b.length);

    BigNumber result(largeLength + 1, 0);
    int carry = 0;

    for (int i = 0; i < smallLength; i++) {
        int sum = a.digits[i] + b.digits[i] + carry;
        result.digits[i] = sum % 10;
        carry = sum / 10;
    }

    const byte* remainingDigits = (a.length > b.length ? a.digits : b.digits);

    for (int i = smallLength; i < largeLength; i++) {
        int sum = remainingDigits[i] + carry;
        result.digits[i] = sum % 10;
        carry = sum / 10;
    }

    if (carry) {
        result.digits[largeLength] = carry;
    } else {
        result.length = largeLength;
    }

    return result;
}

BigNumber addMPI1(const BigNumber& a, const BigNumber& b) {
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (size < 2) {
        fprintf(stderr, "Error: MPI Variant 1 requires at least 2 processes\n");
        exit(1);
    }

    int maxLength = max(a.length, b.length);
    int numWorkers = size - 1;
    int chunkSize = maxLength / numWorkers;
    int remainder = maxLength % numWorkers;

    if (rank == 0) {
        int lengths[2] = {a.length, b.length};
        for (int workerID = 1; workerID < size; workerID++) {
            MPI_Send(lengths, 2, MPI_INT, workerID, 0, MPI_COMM_WORLD);
        }

        int startPos = 0;
        for (int workerID = 1; workerID < size; workerID++) {
            int currentChunkSize = chunkSize + (workerID <= remainder ? 1 : 0);

            int chunkInfo[2] = {currentChunkSize, startPos};
            MPI_Send(chunkInfo, 2, MPI_INT, workerID, 1, MPI_COMM_WORLD);

            int aChunkSize = min(currentChunkSize, max(0, a.length - startPos));
            if (aChunkSize > 0) {
                MPI_Send(&a.digits[startPos], aChunkSize, MPI_BYTE, workerID, 2, MPI_COMM_WORLD);
            }

            int bChunkSize = min(currentChunkSize, max(0, b.length - startPos));
            if (bChunkSize > 0) {
                MPI_Send(&b.digits[startPos], bChunkSize, MPI_BYTE, workerID, 3, MPI_COMM_WORLD);
            }

            startPos += currentChunkSize;
        }

        BigNumber result(maxLength + 1, 0);
        startPos = 0;

        for (int workerID = 1; workerID < size; workerID++) {
            int currentChunkSize = chunkSize + (workerID <= remainder ? 1 : 0);

            MPI_Recv(&result.digits[startPos], currentChunkSize, MPI_BYTE, workerID, 4, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

            startPos += currentChunkSize;
        }

        byte finalCarry = 0;
        MPI_Recv(&finalCarry, 1, MPI_BYTE, size - 1, 5, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        if (finalCarry) {
            result.digits[maxLength] = finalCarry;
            result.length = maxLength + 1;
        } 
        else {
            result.length = maxLength;
        }

        return result;

    } else {
        int lengths[2];
        MPI_Recv(lengths, 2, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        int aLength = lengths[0];
        int bLength = lengths[1];

        int chunkInfo[2];
        MPI_Recv(chunkInfo, 2, MPI_INT, 0, 1, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        int myChunkSize = chunkInfo[0];
        int myStartPos = chunkInfo[1];

        byte* myDigitsA = (byte*)malloc(myChunkSize * sizeof(byte));
        byte* myDigitsB = (byte*)malloc(myChunkSize * sizeof(byte));
        byte* myResult = (byte*)malloc(myChunkSize * sizeof(byte));

        memset(myDigitsA, 0, myChunkSize);
        memset(myDigitsB, 0, myChunkSize);

        int aChunkSize = min(myChunkSize, max(0, aLength - myStartPos));
        if (aChunkSize > 0) {
            MPI_Recv(myDigitsA, aChunkSize, MPI_BYTE, 0, 2, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        }

        int bChunkSize = min(myChunkSize, max(0, bLength - myStartPos));
        if (bChunkSize > 0) {
            MPI_Recv(myDigitsB, bChunkSize, MPI_BYTE, 0, 3, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        }

        int carry = 0;
        for (int i = 0; i < myChunkSize; i++) {
            int sum = myDigitsA[i] + myDigitsB[i] + carry;
            myResult[i] = sum % 10;
            carry = sum / 10;
        }

        if (rank > 1) {
            byte carryFromPrev;
            MPI_Recv(&carryFromPrev, 1, MPI_BYTE, rank - 1, 6, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

            int i = 0;
            int incomingCarry = carryFromPrev;
            while (incomingCarry > 0 && i < myChunkSize) {
                int sum = myResult[i] + incomingCarry;
                myResult[i] = sum % 10;
                incomingCarry = sum / 10;
                i++;
            }
            carry += incomingCarry;
        }

        if (rank < size - 1) {
            MPI_Send(&carry, 1, MPI_BYTE, rank + 1, 6, MPI_COMM_WORLD);
        } else {
            MPI_Send(&carry, 1, MPI_BYTE, 0, 5, MPI_COMM_WORLD);
        }

        MPI_Send(myResult, myChunkSize, MPI_BYTE, 0, 4, MPI_COMM_WORLD);

        free(myDigitsA);
        free(myDigitsB);
        free(myResult);

        return BigNumber(1, 0);
    }
}

BigNumber addMPI1_Optimized(const BigNumber& a, const BigNumber& b) {
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (size < 2) {
        fprintf(stderr, "Error: MPI Variant 1.1 requires at least 2 processes\n");
        exit(1);
    }

    int maxLength = max(a.length, b.length);
    int numWorkers = size - 1;
    int chunkSize = maxLength / numWorkers;
    int remainder = maxLength % numWorkers;

    if (rank == 0) {
        int lengths[2] = {a.length, b.length};
        for (int workerID = 1; workerID < size; workerID++) {
            MPI_Send(lengths, 2, MPI_INT, workerID, 0, MPI_COMM_WORLD);
        }

        int startPos = 0;
        for (int workerID = 1; workerID < size; workerID++) {
            int currentChunkSize = chunkSize + (workerID <= remainder ? 1 : 0);

            int chunkInfo[2] = {currentChunkSize, startPos};
            MPI_Send(chunkInfo, 2, MPI_INT, workerID, 1, MPI_COMM_WORLD);

            int aChunkSize = min(currentChunkSize, max(0, a.length - startPos));
            if (aChunkSize > 0) {
                MPI_Send(&a.digits[startPos], aChunkSize, MPI_BYTE, workerID, 2, MPI_COMM_WORLD);
            }

            int bChunkSize = min(currentChunkSize, max(0, b.length - startPos));
            if (bChunkSize > 0) {
                MPI_Send(&b.digits[startPos], bChunkSize, MPI_BYTE, workerID, 3, MPI_COMM_WORLD);
            }

            startPos += currentChunkSize;
        }

        BigNumber result(maxLength + 1, 0);
        startPos = 0;

        for (int workerID = 1; workerID < size; workerID++) {
            int currentChunkSize = chunkSize + (workerID <= remainder ? 1 : 0);
            MPI_Recv(&result.digits[startPos], currentChunkSize, MPI_BYTE, workerID, 4, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            startPos += currentChunkSize;
        }

        byte finalCarry = 0;
        MPI_Recv(&finalCarry, 1, MPI_BYTE, size - 1, 5, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        if (finalCarry) {
            result.digits[maxLength] = finalCarry;
            result.length = maxLength + 1;
        } else {
            result.length = maxLength;
        }

        return result;

    } else {
        int lengths[2];
        MPI_Recv(lengths, 2, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        int aLength = lengths[0];
        int bLength = lengths[1];

        int chunkInfo[2];
        MPI_Recv(chunkInfo, 2, MPI_INT, 0, 1, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        int myChunkSize = chunkInfo[0];
        int myStartPos = chunkInfo[1];

        byte* myDigitsA = (byte*)malloc(myChunkSize * sizeof(byte));
        byte* myDigitsB = (byte*)malloc(myChunkSize * sizeof(byte));
        byte* myResult = (byte*)malloc(myChunkSize * sizeof(byte));

        memset(myDigitsA, 0, myChunkSize);
        memset(myDigitsB, 0, myChunkSize);

        int aChunkSize = min(myChunkSize, max(0, aLength - myStartPos));
        if (aChunkSize > 0) {
            MPI_Recv(myDigitsA, aChunkSize, MPI_BYTE, 0, 2, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        }

        int bChunkSize = min(myChunkSize, max(0, bLength - myStartPos));
        if (bChunkSize > 0) {
            MPI_Recv(myDigitsB, bChunkSize, MPI_BYTE, 0, 3, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        }

        MPI_Request carryRequest;
        byte carryFromPrev = 0;
        int needsCarry = (rank > 1);

        if (needsCarry) {
            MPI_Irecv(&carryFromPrev, 1, MPI_BYTE, rank - 1, 6, MPI_COMM_WORLD, &carryRequest);
        }

        int carry = 0;
        for (int i = 0; i < myChunkSize; i++) {
            int sum = myDigitsA[i] + myDigitsB[i] + carry;
            myResult[i] = sum % 10;
            carry = sum / 10;
        }

        if (needsCarry) {
            MPI_Wait(&carryRequest, MPI_STATUS_IGNORE);

            if (carryFromPrev != 0) {
                int i = 0;
                int incomingCarry = carryFromPrev;
                while (incomingCarry > 0 && i < myChunkSize) {
                    int sum = myResult[i] + incomingCarry;
                    myResult[i] = sum % 10;
                    incomingCarry = sum / 10;
                    i++;
                }
                carry += incomingCarry;
            }
        }

        if (rank < size - 1) {
            MPI_Send(&carry, 1, MPI_BYTE, rank + 1, 6, MPI_COMM_WORLD);
        } else {
            MPI_Send(&carry, 1, MPI_BYTE, 0, 5, MPI_COMM_WORLD);
        }

        MPI_Request resultRequest;
        MPI_Isend(myResult, myChunkSize, MPI_BYTE, 0, 4, MPI_COMM_WORLD, &resultRequest);

        MPI_Wait(&resultRequest, MPI_STATUS_IGNORE);

        free(myDigitsA);
        free(myDigitsB);
        free(myResult);

        return BigNumber(1, 0);
    }
}

BigNumber addMPI2_ScatterGather(const BigNumber& a, const BigNumber& b) {
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (size < 2) {
        fprintf(stderr, "Error: MPI Variant 2 requires at least 2 processes\n");
        exit(1);
    }

    int maxLength = max(a.length, b.length);

    int paddedLength = ((maxLength + size - 1) / size) * size;
    int chunkSize = paddedLength / size;

    byte* paddedA = nullptr;
    byte* paddedB = nullptr;
    byte* globalResult = nullptr;

    if (rank == 0) {
        paddedA = (byte*)malloc(paddedLength * sizeof(byte));
        paddedB = (byte*)malloc(paddedLength * sizeof(byte));
        globalResult = (byte*)malloc((paddedLength + 1) * sizeof(byte));

        memset(paddedA, 0, paddedLength);
        memset(paddedB, 0, paddedLength);
        memset(globalResult, 0, paddedLength + 1);

        memcpy(paddedA, a.digits, a.length);
        memcpy(paddedB, b.digits, b.length);
    }

    byte* localA = (byte*)malloc(chunkSize * sizeof(byte));
    byte* localB = (byte*)malloc(chunkSize * sizeof(byte));
    byte* localResult = (byte*)malloc(chunkSize * sizeof(byte));

    MPI_Scatter(paddedA, chunkSize, MPI_BYTE, localA, chunkSize, MPI_BYTE, 0, MPI_COMM_WORLD);
    MPI_Scatter(paddedB, chunkSize, MPI_BYTE, localB, chunkSize, MPI_BYTE, 0, MPI_COMM_WORLD);

    int carry = 0;
    for (int i = 0; i < chunkSize; i++) {
        int sum = localA[i] + localB[i] + carry;
        localResult[i] = sum % 10;
        carry = sum / 10;
    }

    if (rank > 0) {
        byte carryFromPrev;
        MPI_Recv(&carryFromPrev, 1, MPI_BYTE, rank - 1, 6, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        int i = 0;
        int incomingCarry = carryFromPrev;
        while (incomingCarry > 0 && i < chunkSize) {
            int sum = localResult[i] + incomingCarry;
            localResult[i] = sum % 10;
            incomingCarry = sum / 10;
            i++;
        }
        carry += incomingCarry;
    }

    if (rank < size - 1) {
        MPI_Send(&carry, 1, MPI_BYTE, rank + 1, 6, MPI_COMM_WORLD);
    }

    MPI_Gather(localResult, chunkSize, MPI_BYTE, globalResult, chunkSize, MPI_BYTE, 0, MPI_COMM_WORLD);

    BigNumber result(1, 0);
    if (rank == 0) {
        byte finalCarry = 0;
        MPI_Recv(&finalCarry, 1, MPI_BYTE, size - 1, 7, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        if (finalCarry) {
            globalResult[paddedLength] = finalCarry;
            result = BigNumber(paddedLength + 1, 0);
            memcpy(result.digits, globalResult, paddedLength + 1);
        } else {
            int actualLength = paddedLength;
            while (actualLength > 1 && globalResult[actualLength - 1] == 0) {
                actualLength--;
            }
            result = BigNumber(actualLength, 0);
            memcpy(result.digits, globalResult, actualLength);
        }

        free(paddedA);
        free(paddedB);
        free(globalResult);
    } else if (rank == size - 1) {
        MPI_Send(&carry, 1, MPI_BYTE, 0, 7, MPI_COMM_WORLD);
    }

    free(localA);
    free(localB);
    free(localResult);

    return result;
}
