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

__global__ void kernel(int size,int* d_vec){
  int thid = threadIdx.x;
  int blid = blockIdx.x;

  /* if(thid < size && blid < 1){
    printf("blid:%d,thid:%d,vec[%d]:%d\n",blid,thid,thid,d_vec[thid]);
    }*/
  if(blid<2&&thid<2)
  printf("blid:%d,thid:%d\n",blid,thid,thid);
}

int main(){

  int* vec;
  //int vec[10];
  int size = 10;
  int* d_vec;
  int i;

  dim3 grid(32);
  dim3 block(32);
 
  //----set up device START-----
  cudaDeviceProp deviceProp;
  int dev_num =0;
  cudaGetDeviceProperties(&deviceProp,dev_num);
  printf("Using Device %d:%s\n",dev_num,deviceProp.name);
  cudaSetDevice(dev_num);
  //----set up device START-----

  vec = (int*)malloc(sizeof(int)*size);
 
  //----initialize vec----
  for(i=0;i<size;i++){
    vec[i]=i;
    printf("[%d]:%d\n",i,vec[i]);
  }
  
  cudaMalloc((int**)&d_vec,sizeof(int)*size);
  cudaMemcpy(d_vec,vec,sizeof(int)*size,cudaMemcpyHostToDevice);
  for(i=0;i<size;i++){
    vec[i]=0;
    printf("[%d]:%d\n",i,vec[i]);
  }
 
  kernel<<<grid,block>>>(size,d_vec);
  printf("hoge\n\n");
  kernel<<<grid,block>>>(size,d_vec);

  cudaDeviceSynchronize();

  cudaMemcpy(vec,d_vec,sizeof(int)*size,cudaMemcpyDeviceToHost);
  for(i=0;i<size;i++){
    printf("[%d]:%d\n",i,vec[i]);
  }
  cudaFree(d_vec);
  cudaDeviceReset();

  free(vec);
  
  return 0;
}

