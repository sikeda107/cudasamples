#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include "cublas_v2.h"

#define N 10000


__global__ void Kernel2(float* device_x,int element_size){
  int i;
  if(threadIdx.x == 1 && blockIdx.x < 1){
    for(i=0;i<element_size;i++){
      device_x[i]++;
      printf("%.0f ",device_x[i]);
    }
  }//#end-if
  else if(threadIdx.x < 1 && blockIdx.x < 1){
    for(i=0;i<element_size;i++);
  }
}
__global__ void Kernel(float* device_x,int element_size){
  int i;
  if(threadIdx.x < 1 && blockIdx.x < 1){
    for(i=0;i<element_size;i++){
      device_x[i]++;
      printf("%.0f ",device_x[i]);
    }
  }//#end-if
  else if(threadIdx.x == 1 && blockIdx.x < 1){
      for(i=0;i<element_size;i++);
  }
}

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
  int device_number = 0;
  cudaDeviceProp deviceProp;
  cublasHandle_t handle = 0;

  //----set up device START-----
  cudaGetDeviceProperties(&deviceProp,device_number);
  //  printf("Using Device %d:%s\n",dev_num,deviceProp.name);
  cudaSetDevice(device_number);
  //----set up device END-----


  for (i = 0; i < n; i++){
    host_original[i] = 1;
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
  dim3 block(2);
  dim3 grid(1);
  Kernel<<<grid,block>>>(device_x,n);
  Kernel2<<<grid,block>>>(device_x,n);
  //cublasStatus_t cublasSasum(cublasHandle_t handle, int n, const float *x, int incx, float *result)
  //Read more at: http://docs.nvidia.com/cuda/cublas/index.html#ixzz4wUVIQfLc

  stat = cublasSasum(handle, n, device_x, incx, &sum_result);
  if (stat != CUBLAS_STATUS_SUCCESS) {
    printf ("cublas function failed");
    cudaFree (device_x);
    cublasDestroy(handle);
    return EXIT_FAILURE;
  }
  Kernel<<<grid,block>>>(device_x,n);
  Kernel2<<<grid,block>>>(device_x,n);

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
