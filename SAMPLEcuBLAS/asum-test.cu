#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include "cublas_v2.h"

#define N 99

int main(int argc, char **argv){

  cudaError_t cudaStat;
  cublasStatus_t stat;
  int print_limit_width = 20;
  int i;
  int n = N;
  float *device_x;
  float sum_result;
  float host_original[N];
  int incx = 1;

  cublasHandle_t handle = 0;

  for (i = 0; i < n; i++){
    host_original[i] = 1*3;
  }

  // Create the cuBLAS handle
  stat = cublasCreate(&handle);
  if (stat != CUBLAS_STATUS_SUCCESS) {
    printf ("CUBLAS initialization failed\n");
    return EXIT_FAILURE;
  }

  // Allocate device memory
  cudaStat = cudaMalloc((void **)&device_x, sizeof(float) * n);
  if (cudaStat != cudaSuccess) {
    printf ("device memory allocation failed");
    return EXIT_FAILURE;
  }

  // Transfer inputs to the device
  cublasSetVector(n, sizeof(float), host_original, 1, device_x, 1);
  if (stat != CUBLAS_STATUS_SUCCESS) {
    printf ("data set failed");
    cudaFree (device_x);
    cublasDestroy(handle);
    return EXIT_FAILURE;
  }

  //cublasStatus_t cublasSasum(cublasHandle_t handle, int n, const float *x, int incx, float *result)
  //Read more at: http://docs.nvidia.com/cuda/cublas/index.html#ixzz4wUVIQfLc

  stat = cublasSasum(handle, n, device_x, incx, &sum_result);
  if (stat != CUBLAS_STATUS_SUCCESS) {
    printf ("cublas function failed");
    cudaFree (device_x);
    cublasDestroy(handle);
    return EXIT_FAILURE;
  }

  printf("host original:\n");
  for (i = 0; i < n; i++){

    printf("%.0f ", host_original[i]);
    if(i%print_limit_width==(print_limit_width-1))printf("\n");
  }
  printf("\n");

  printf("result:\n%f\n",sum_result);

  printf("...\n");

  cudaFree(device_x);
  cublasDestroy(handle);

  return EXIT_SUCCESS;
}
