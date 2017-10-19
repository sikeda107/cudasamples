#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include "cublas_v2.h"

int main(int argc, char **argv)
{
    int i;
    float *A, *dA;
    float *X, *dX;
    float *Y, *dY;
    float beta;
    float alpha;
    cublasHandle_t handle = 0;

    // Create the cuBLAS handle
    cublasCreate(&handle));

    // Allocate device memory
    cudaMalloc((void **)&dA, sizeof(float) * M * N);
    cudaMalloc((void **)&dX, sizeof(float) * N);
    cudaMalloc((void **)&dY, sizeof(float) * M);

    // Transfer inputs to the device
    cublasSetVector(N, sizeof(float), X, 1, dX, 1);
    cublasSetVector(M, sizeof(float), Y, 1, dY, 1);
    cublasSetMatrix(M, N, sizeof(float), A, M, dA, M);

    // Execute the matrix-vector multiplication
    cublasSasum(handle, CUBLAS_OP_N, M, N, &alpha, dA, M, dX, 1,
                             &beta, dY, 1));

    // Retrieve the output vector from the device
    cublasGetVector(M, sizeof(float), dY, 1, Y, 1));

    for (i = 0; i < 10; i++)
    {
        printf("%2.2f\n", Y[i]);
    }

    printf("...\n");

    free(A);
    free(X);
    free(Y);

    cudaFree(dA));
    cudaFree(dY));
    cublasDestroy(handle);

    return 0;
}
