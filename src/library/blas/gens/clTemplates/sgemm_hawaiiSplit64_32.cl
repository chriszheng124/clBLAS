//below kernels work with an assumption: after the main matrix being computed by kernels with 64x64 micro tile size, the boundary are of size 32.
//Thus, M and N are of mod32 and not necessarily of mod64.
//use sgemm_NT_64_64_16_16x16_4x4__ALPHABETA() from sgemm_gcn.cl as the main solver

static const char * sgemm_NT_64_32_SPLIT__ALPHABETA = "

#define  M4x4 \
            rA[0][0] = lA[offA + 0];				  \
            rA[0][1] = lA[offA + 16];				  \
            rA[0][2] = lA[offA + 32];				  \
            rA[0][3] = lA[offA + 48];				  \
            rB[0][0] = lB[offB + 0];				  \
            rB[0][1] = lB[offB + 16];				  \
            rB[0][2] = lB[offB + 32];				  \
            rB[0][3] = lB[offB + 48];				  \
            offA += 65;								  \
            offB += 65;								  \
            rC[0][0]=mad(rA[0][0],rB[0][0],rC[0][0]); \
            rC[1][0]=mad(rA[0][1],rB[0][0],rC[1][0]); \
            rC[2][0]=mad(rA[0][2],rB[0][0],rC[2][0]); \
            rC[3][0]=mad(rA[0][3],rB[0][0],rC[3][0]); \
            rC[0][1]=mad(rA[0][0],rB[0][1],rC[0][1]); \
            rC[1][1]=mad(rA[0][1],rB[0][1],rC[1][1]); \
            rC[2][1]=mad(rA[0][2],rB[0][1],rC[2][1]); \
            rC[3][1]=mad(rA[0][3],rB[0][1],rC[3][1]); \
            rC[0][2]=mad(rA[0][0],rB[0][2],rC[0][2]); \
            rC[1][2]=mad(rA[0][1],rB[0][2],rC[1][2]); \
            rC[2][2]=mad(rA[0][2],rB[0][2],rC[2][2]); \
            rC[3][2]=mad(rA[0][3],rB[0][2],rC[3][2]); \
            rC[0][3]=mad(rA[0][0],rB[0][3],rC[0][3]); \
            rC[1][3]=mad(rA[0][1],rB[0][3],rC[1][3]); \
            rC[2][3]=mad(rA[0][2],rB[0][3],rC[2][3]); \
            rC[3][3]=mad(rA[0][3],rB[0][3],rC[3][3]); \	
			mem_fence(CLK_LOCAL_MEM_FENCE);

#define  M2x4 \
            rA[0][0] = lA[offA + 0];				  \
            rA[0][1] = lA[offA + 16];				  \
            rB[0][0] = lB[offB + 0];				  \
            rB[0][1] = lB[offB + 16];				  \
            rB[0][2] = lB[offB + 32];				  \
            rB[0][3] = lB[offB + 48];				  \
            offA += 33;								  \
            offB += 65;								  \
            rC[0][0]=mad(rA[0][0],rB[0][0],rC[0][0]); \
            rC[1][0]=mad(rA[0][1],rB[0][0],rC[1][0]); \
            rC[0][1]=mad(rA[0][0],rB[0][1],rC[0][1]); \
            rC[1][1]=mad(rA[0][1],rB[0][1],rC[1][1]); \
            rC[0][2]=mad(rA[0][0],rB[0][2],rC[0][2]); \
            rC[1][2]=mad(rA[0][1],rB[0][2],rC[1][2]); \
            rC[0][3]=mad(rA[0][0],rB[0][3],rC[0][3]); \
            rC[1][3]=mad(rA[0][1],rB[0][3],rC[1][3]); \
            mem_fence(CLK_LOCAL_MEM_FENCE);
			
#define  M4x2 \
            rA[0][0] = lA[offA + 0];				  \
            rA[0][1] = lA[offA + 16];				  \
            rA[0][2] = lA[offA + 32];				  \
            rA[0][3] = lA[offA + 48];				  \
            rB[0][0] = lB[offB + 0];				  \
            rB[0][1] = lB[offB + 16];				  \
            offA += 65;								  \
            offB += 33;								  \
            rC[0][0]=mad(rA[0][0],rB[0][0],rC[0][0]); \
            rC[1][0]=mad(rA[0][1],rB[0][0],rC[1][0]); \
            rC[2][0]=mad(rA[0][2],rB[0][0],rC[2][0]); \
            rC[3][0]=mad(rA[0][3],rB[0][0],rC[3][0]); \
            rC[0][1]=mad(rA[0][0],rB[0][1],rC[0][1]); \
            rC[1][1]=mad(rA[0][1],rB[0][1],rC[1][1]); \
            rC[2][1]=mad(rA[0][2],rB[0][1],rC[2][1]); \
            rC[3][1]=mad(rA[0][3],rB[0][1],rC[3][1]); \
            mem_fence(CLK_LOCAL_MEM_FENCE);

#define  M2x2 \
            rA[0][0] = lA[offA + 0];				  \
            rA[0][1] = lA[offA + 16];				  \
            rB[0][0] = lB[offB + 0];				  \
            rB[0][1] = lB[offB + 16];				  \
            offA += 33;								  \
            offB += 33;								  \
            rC[0][0]=mad(rA[0][0],rB[0][0],rC[0][0]); \
            rC[1][0]=mad(rA[0][1],rB[0][0],rC[1][0]); \
            rC[0][1]=mad(rA[0][0],rB[0][1],rC[0][1]); \
            rC[1][1]=mad(rA[0][1],rB[0][1],rC[1][1]); \
            rC[2][1]=mad(rA[0][2],rB[0][1],rC[2][1]); \
            mem_fence(CLK_LOCAL_MEM_FENCE);

__attribute__((reqd_work_group_size(16,16,1)))
__kernel void sgemm_NT_64_64_16_16x16_4x4__ALPHABETA_SPLIT_MAIN( __global float const * restrict A,
  __global float const * restrict B,
  __global float * C,
  uint const M,
  uint const N,
  uint const K,
  float const alpha,
  float const beta,
  uint lda,
  uint ldb,
  uint ldc,
  uint offsetA,
  uint offsetB,
  uint offsetC)
{
    float rC[4][4]  = {(float)0};
    float rA[1][4];
    float rB[1][4];
    

    
    A += offsetA;
    B += offsetB;
    C+=offsetC;
    
    __local float lA[1040];
    __local float lB[1040];
    
    uint gidx = get_group_id(0);
    uint gidy = get_group_id(1);
    uint idx = get_local_id(0);
    uint idy = get_local_id(1);

    A +=  gidx*64+ idx + idy*lda;
    B +=  gidy*64+ idx + idy*ldb;
    
   
    uint block_k = K >> 4;
    do 
	{
   // for(unsigned int block_k=0 ; block_k< K ; block_k+=16)
	//{
        __local float* plA = lA + idy*65+idx;
        __local float* plB = lB + idy*65+idx;
        barrier(CLK_LOCAL_MEM_FENCE);
        plB[0] = B[0+0*ldb];
        plB[16] = B[16+0*ldb];
        plB[32] = B[32+0*ldb];
        plB[48] = B[48+0*ldb];
	   
	    plA[0] = A[0+0*lda];
        plA[16] = A[16+0*lda];
        plA[32] = A[32+0*lda];
        plA[48] = A[48+0*lda];

        
        barrier(CLK_LOCAL_MEM_FENCE);
        uint offA = idx;
        uint offB = idy;

//        #pragma unroll 1
//        for(unsigned int k = 0 ; k < 16; k+=1){
//        }

        M4x4
		M4x4
		M4x4
		M4x4
		M4x4
		M4x4
		M4x4
		M4x4
		M4x4
		M4x4
		M4x4
		M4x4
		M4x4
		M4x4
		M4x4
		M4x4

        A += lda<<4;
        B += ldb<<4;
    //}
	} while (--block_k > 0);

    C+= gidx*64+idx;
    C+= gidy*64*ldc;
    C+= idy*ldc;
    
	C[0*ldc] = alpha*rC[0][0] + beta*C[0*ldc];
    C[16*ldc] = alpha*rC[0][1] + beta*C[16*ldc];
    C[32*ldc] = alpha*rC[0][2] + beta*C[32*ldc];
    C[48*ldc] = alpha*rC[0][3] + beta*C[48*ldc];
    C+=16;
    C[0*ldc] = alpha*rC[1][0] + beta*C[0*ldc];
    C[16*ldc] = alpha*rC[1][1] + beta*C[16*ldc];
    C[32*ldc] = alpha*rC[1][2] + beta*C[32*ldc];
    C[48*ldc] = alpha*rC[1][3] + beta*C[48*ldc];
    C+=16;
    C[0*ldc] = alpha*rC[2][0] + beta*C[0*ldc];
    C[16*ldc] = alpha*rC[2][1] + beta*C[16*ldc];
    C[32*ldc] = alpha*rC[2][2] + beta*C[32*ldc];
    C[48*ldc] = alpha*rC[2][3] + beta*C[48*ldc];
    C+=16;
    C[0*ldc] = alpha*rC[3][0] + beta*C[0*ldc];
    C[16*ldc] = alpha*rC[3][1] + beta*C[16*ldc];
    C[32*ldc] = alpha*rC[3][2] + beta*C[32*ldc];
    C[48*ldc] = alpha*rC[3][3] + beta*C[48*ldc];
   
}
			
__attribute__((reqd_work_group_size(16,16,1)))
__kernel void sgemm_NT_32_64_16_16x16_2x4__ALPHABETA_SPLIT_ROW( __global float const * restrict A,
  __global float const * restrict B,
  __global float * C,
  uint const M,
  uint const N,
  uint const K,
  float const alpha,
  float const beta,
  uint lda,
  uint ldb,
  uint ldc,
  uint offsetA,
  uint offsetB,
  uint offsetC)
{
    float rC[2][4]  = {(float)0};
    float rA[1][2];
    float rB[1][4];
    
    
    A += offsetA;
    B += offsetB;
    C+=offsetC;
    
    __local float lA[528];//16*32+16
    __local float lB[1040];//16*64+16
    
    uint gidx = M/64;//get_group_id(0);
    uint gidy = get_group_id(1);
    uint idx = get_local_id(0);
    uint idy = get_local_id(1);
    

	int CurrentOffSetA = gidx*64+ idx;
    
    A +=  gidx*64+ idx + idy*lda;
    B +=  gidy*64+ idx + idy*ldb;
    
   
    uint block_k = K >> 4;
    do 
	{
        __local float* plA = lA + idy*33+idx;
        __local float* plB = lB + idy*65+idx;
        barrier(CLK_LOCAL_MEM_FENCE);

        plB[0] = B[0+0*ldb];
        plB[16] = B[16+0*ldb];
        plB[32] = B[32+0*ldb];
        plB[48] = B[48+0*ldb];
	   
	    //plA[0]  = CurrentOffSetA>=M?0.0:A[0];
        //plA[16] = CurrentOffSetA+16>=M?0.0:A[16];
        //plA[32] = CurrentOffSetA+32>=M?0.0:A[32];
        //plA[48] = CurrentOffSetA+48>=M?0.0:A[48];
		plA[0] = A[0];
		plA[16] = A[16];

        
        barrier(CLK_LOCAL_MEM_FENCE);
        uint offA = idx;
        uint offB = idy;


        M2x4
		M2x4
		M2x4
		M2x4
		M2x4
		M2x4
		M2x4
		M2x4
		M2x4
		M2x4
		M2x4
		M2x4
		M2x4
		M2x4
		M2x4
		M2x4

        A += lda<<4;
        B += ldb<<4;
	} while (--block_k > 0);


	int offset_x = gidx*64+idx;
    int offset_y = gidy*64+ idy;

	//if(offset_x>=M )
    //  return;

    C+=offset_x+offset_y*ldc;
    
	int i = 0;
    do 
	{
	  C[0     ] = mad(alpha, rC[i][0], beta*C[0]);
      C[16*ldc] = mad(alpha, rC[i][1], beta*C[16*ldc]);
      C[32*ldc] = mad(alpha, rC[i][2], beta*C[32*ldc]);
      C[48*ldc] = mad(alpha, rC[i][3], beta*C[48*ldc]);
      C+=16;
	  offset_x+=16;
	  //if(offset_x>=M )
      //  return;
	}
    while (++i < 2);
}

__attribute__((reqd_work_group_size(16,16,1)))
__kernel void sgemm_NT_64_32_16_16x16_4x2__ALPHABETA_SPLIT_COLUMN( __global float const * restrict A,
  __global float const * restrict B,
  __global float * C,
  uint const M,
  uint const N,
  uint const K,
  float const alpha,
  float const beta,
  uint lda,
  uint ldb,
  uint ldc,
  uint offsetA,
  uint offsetB,
  uint offsetC)
{
    float rC[4][2]  = {(float)0};
    float rA[1][4];
    float rB[1][2];
    
    
    A += offsetA;
    B += offsetB;
    C+=offsetC;
    
    __local float lA[1040];//16*64+16
    __local float lB[528];//16*32+16
    
    uint gidx = get_group_id(0);
    uint gidy = N/64;//get_group_id(1);
    uint idx = get_local_id(0);
    uint idy = get_local_id(1);
    
	int CurrentOffSetB = gidy*64+ idx;
    
    A +=  gidx*64+ idx + idy*lda;
    B +=  gidy*64+ idx + idy*ldb;
    
   
    uint block_k = K >> 4;
    do 
	{
        __local float* plA = lA + idy*65+idx;
        __local float* plB = lB + idy*33+idx;
        barrier(CLK_LOCAL_MEM_FENCE);

        //plB[0]  = CurrentOffSetB>=N?0.0:B[0];
        //plB[16] = CurrentOffSetB+16>=N?0.0:B[16];
        //plB[32] = CurrentOffSetB+32>=N?0.0:B[32];
        //plB[48] = CurrentOffSetB+48>=N?0.0:B[48];
		plB[0]  = B[0];
        plB[16] = B[16];
	   
	    plA[0]  = A[0];
        plA[16] = A[16];
        plA[32] = A[32];
        plA[48] = A[48];

        
        barrier(CLK_LOCAL_MEM_FENCE);
        uint offA = idx;
        uint offB = idy;


        M4x2
        M4x2
        M4x2
        M4x2
        M4x2
        M4x2
        M4x2
        M4x2
        M4x2
        M4x2
        M4x2
        M4x2
        M4x2
        M4x2
        M4x2
        M4x2

        A += lda<<4;
        B += ldb<<4;
	} while (--block_k > 0);


	int offset_x = gidx*64+idx;
    int offset_y = gidy*64+ idy;

	//if(offset_y>=N )
    // return;

  C+=offset_x+offset_y*ldc;
    
	int i = 0;
  do 
	{
	  C[0     ] = mad(alpha, rC[i][0], beta*C[0]);
      C[16*ldc] = mad(alpha, rC[i][1], beta*C[16*ldc]);
      
	  C+=16;
	    
	}
    while (++i < 4);
}

__attribute__((reqd_work_group_size(16,16,1)))
__kernel void sgemm_NT_32_32_16_16x16_2x2__ALPHABETA_SPLIT_SINGLE( __global float const * restrict A,
  __global float const * restrict B,
  __global float * C,
  uint const M,
  uint const N,
  uint const K,
  float const alpha,
  float const beta,
  uint lda,
  uint ldb,
  uint ldc,
  uint offsetA,
  uint offsetB,
  uint offsetC)
{
    float rC[2][2]  = {(float)0};
    float rA[1][2];
    float rB[1][2];
    
    
    A += offsetA;
    B += offsetB;
    C+=offsetC;
    
    __local float lA[528];
    __local float lB[528];
    
    uint gidx = M/64;//get_group_id(0);
    uint gidy = N/64;//get_group_id(1);
    uint idx = get_local_id(0);
    uint idy = get_local_id(1);
    
	int CurrentOffSetA = gidx*64+ idx;
	int CurrentOffSetB = gidy*64+ idx;
    
    A +=  gidx*64+ idx + idy*lda;
    B +=  gidy*64+ idx + idy*ldb;
    
   
    uint block_k = K >> 4;
    do 
	{
        __local float* plA = lA + idy*33+idx;
        __local float* plB = lB + idy*33+idx;
        barrier(CLK_LOCAL_MEM_FENCE);

        //plB[0]  = CurrentOffSetB>=N?0.0:B[0];
        //plB[16] = CurrentOffSetB+16>=N?0.0:B[16];
        //plB[32] = CurrentOffSetB+32>=N?0.0:B[32];
        //plB[48] = CurrentOffSetB+48>=N?0.0:B[48];
		plB[0]  = B[0];
        plB[16] = B[16];
	   
	    //plA[0]  = CurrentOffSetA>=M?0.0:A[0];
        //plA[16] = CurrentOffSetA+16>=M?0.0:A[16];
        //plA[32] = CurrentOffSetA+32>=M?0.0:A[32];
        //plA[48] = CurrentOffSetA+48>=M?0.0:A[48];
	    plA[0]  = A[0];
        plA[16] = A[16];
        
        barrier(CLK_LOCAL_MEM_FENCE);
        uint offA = idx;
        uint offB = idy;


        M2x2
		M2x2
		M2x2
		M2x2
		M2x2
		M2x2
		M2x2
		M2x2
		M2x2
		M2x2
		M2x2
		M2x2
		M2x2
		M2x2
		M2x2
		M2x2

        A += lda<<4;
        B += ldb<<4;
	} while (--block_k > 0);


	int offset_x = gidx*64+idx;
    int offset_y = gidy*64+ idy;

    //if(offset_x>=M || offset_y>=N )
    //  return;

    C+=offset_x+offset_y*ldc;
    
	int i = 0;
    do 
	{
	  C[0     ] = mad(alpha, rC[i][0], beta*C[0]);
      C[16*ldc] = mad(alpha, rC[i][1], beta*C[16*ldc]);

      
	  C+=16;
	  offset_x+=16;
	  //if(offset_x>=M )
      //  return;

	    
	}
    while (++i < 2);
}

";