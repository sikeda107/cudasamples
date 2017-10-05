# Makefile
TEST: test.cu
	nvcc -o TEST -arch=sm_52 test.cu

CPYSYMBOL-TEST: cpysymbol-test.cu
	nvcc -o CPYSYMBOL-TEST -arch=sm_52 cpysymbol-test.cu

#remove .o files and execute file
.PHONY:clean
clean:
	rm -f TEST
	rm -f CPYSYMBOL-TEST
	rm -f ./*.o
