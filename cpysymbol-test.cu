#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<time.h>
#include<memory.h>
#include<math.h>
#include"timer.h"
//CUDA library
#include<cuda_runtime.h>
#include <cuda.h>
#include <curand_kernel.h>

__device__ int d_vec[3][3][3];
//int *d_vec;

__global__ void kernel( ){
		       //int *d_vec){
  int thid = threadIdx.x;
  int blid = blockIdx.x;
  int i,j,k;

  if(blid<1&&thid<1){
    printf("blid:%d,thid:%d\n",blid,thid,thid);
    for(i=0;i<3;i++){
      for(j=0;j<3;j++){
	for(k=0;k<3;k++){
	  d_vec[i][j][k] = (int)fabs((-2)* pow(2.0,2.0));
	  //d_vec[i*3*3+j*3+k] += 3;
	}//#for
      }//#for
    }//#for
  }//#if
}
int main(){

  int vec[3][3][3];
  int i,j,k;
  int size = 27;
  dim3 grid(32);
  dim3 block(32);
 
  //----set up device START-----
  cudaDeviceProp deviceProp;
  int dev_num =0;
  cudaGetDeviceProperties(&deviceProp,dev_num);
  printf("Using Device %d:%s\n",dev_num,deviceProp.name);
  cudaSetDevice(dev_num);
  //----set up device START-----

 
  //----initialize vec----
  for(i=0;i<3;i++){
    for(j=0;j<3;j++){
      for(k=0;k<3;k++){
	vec[i][j][k] = 6;
	printf("vec[%d][%d][%d]:%d\n",i,j,k,vec[i][j][k]);
      }}}
  //cudaMalloc((int**)&d_vec,sizeof(int)*size);  
  
  //cudaMemcpy(d_vec,vec,sizeof(int)*(size),cudaMemcpyHostToDevice); 
    cudaMemcpyToSymbol(d_vec,vec,sizeof(int)*size);//HOST TO DEVICE
  
    //kernel<<<grid,block>>>(d_vec);
  kernel<<<grid,block>>>();
  
  cudaDeviceSynchronize();
 
  //cudaMemcpy(vec,d_vec,sizeof(int)*(size),cudaMemcpyDeviceToHost); 
 
  cudaMemcpyFromSymbol(vec,d_vec,sizeof(int)*size);  //DEVICE TO HOST
  
  cudaFree(d_vec);
  
  for(i=0;i<3;i++){
    for(j=0;j<3;j++){
      for(k=0;k<3;k++){
	printf("vec[%d][%d][%d]:%d\n",i,j,k,vec[i][j][k]);
      }}}
  

  //cudaFree(d_vec);
  cudaDeviceReset();

  return 0;
}

