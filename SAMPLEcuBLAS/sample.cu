#include<stdio.h>
#include<stdlib.h>
#include<cublas.h>
#define N 100
#define M 150
#define K 50
#define IDX2C(i,j,ld) (((j)*(ld)+(i)))
int main(int argc,char **argv){
  double alpha = 3.0, beta = 1.0;
  double *A,*B,*C;
  double *dA,*dB,*dC;
  int LDA = M, LDB = K, LDC = M;
  int i,j;
  cudaSetDevice(0);
  cublasInit();
  cudaMallocHost((void **)&A,sizeof(double) * M * K);
  cudaMallocHost((void **)&B,sizeof(double) * K * N);
  cudaMallocHost((void **)&C,sizeof(double) * M * N);
  for(i=0;i<M;++i)
    for(j=0;j<K;++j) A[IDX2C(i,j,M)] = i*K+j + 1;
  for(i=0;i<K;++i)
    for(j=0;j<N;++j) B[IDX2C(i,j,K)] = i*N+j + 1;
  for(i=0;i<M;++i)
    for(j=0;j<N;++j) C[IDX2C(i,j,M)] = 0.0;
  cublasAlloc(M*K,sizeof(double),(void **)&dA);
  cublasAlloc(K*N,sizeof(double),(void **)&dB);
  cublasAlloc(M*N,sizeof(double),(void **)&dC);
  cublasSetMatrix(M,K,sizeof(double),A,LDA,dA,M);
  cublasSetMatrix(K,N,sizeof(double),B,LDB,dB,K);
  cublasSetMatrix(M,N,sizeof(double),C,LDC,dC,M);

  cublasDgemm('N','N',M,N,K,alpha,dA,LDA,dB,LDB,beta,dC,LDC);
  cublasGetMatrix(M,N,sizeof(double),dC,M,C,LDC);
  cublasFree(dA);
  cublasFree(dB);
  cublasFree(dC);
  cublasShutdown();
  return 0;
}
