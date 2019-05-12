---
layout: post
title:  "DCT 변환 실습"
subtitle:  "영상처리"
date:   2019-05-12 21:13:00 +0900
author:     "날도"
header-img: "img/post-bg-2015.jpg"
mathjax: true
catalog: true
tags: 
    - 영상처리
    - 과제
    - C/C++
---
저번 [YUV파일 실습](https://naldo627.github.io/2019/04/14/yuv-handling/) 에서 YUV파일을 다루어 보았는데, 이번에는 YUV파일 한 프레임에 대해서 DCT 변환을 하는 과제를 하게 되었다.

## DCT 변환이란?
DCT 변환은 이산 코사인 변환이라고도 하며, 영상 압축을 위한 방식중의 하나이다. 자연 영상을 NxN 블럭으로 공식을 사용해 변환하면, 분포되어 있던 화소값이 변환 후 이웃 화소 간 별 차이 없는 저주파 영역에 집중되는 것을 이용하여 압축을 시도하는 방식이다. DCT 방식을 사용하면 중복성 제거를 이용하며, 인간의 시각에는 둔감한 고주파 성분을 제거함으로서 압축이 가능해진다.<br><br>
입력 화소값을 $INPUT$, 변환값을 $OUTPUT$라고 했을 때, 변환 식은 다음과 같다.<br>
($INPUT$, $OUTPUT$의 입력값의 픽셀 좌표를 각각 ($i$, $j$), ($x$, $y$) 라 한다)
![(변환식)](/img/in-post/post-dct-transform/1.png)

또한, 역 DCT 변환식은 다음과 같이 쓴다.
$$
INPUT_{ij} = \sum^{N-1}_{x=0}\sum^{N-1}_{y=0}C_{x} \times C_{y} \times OUTPUT_{xy} \times \cos{\frac{(2j+1)y\pi}{2N} } \times  \cos{\frac{(2i+1)x\pi}{2N} }
$$

이 공식을 토대로 YUV파일을 사용, DCT 변환 실습을 진행해 보았다.

## 실습 과정
실험 목표는 아래와 같다.
1. Original yuv에서 첫 1 프레임 배열에 대해 8x8 단위로 DCT 변환을 적용

2. DCT 변환을 마친 결과 배열에 대해 양자화(parameter = 30)를 적용

3. 복원을 위해 다시 양자화한 만큼 값을 곱해주며 DCT 역변환을 시행

4. Original yuv와 역변환까지 시행된 yuv의 MSE를 구함

즉 저번 실습때 사용한 original yuv 파일을 1프레임만 뽑아 DCT 변환을 시행, 양자화까지 적용 후, 다시 DCT 역변환을 시행하면 된다.

소스코드는 아래와 같다.
```cpp
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define N				8
#define M_PIl			3.141592653589793238462643383279502884L /* pi */
#define PARAMETER		30

double getCval(int x, int y) {
	if (x == 0 && y == 0)
		return double(1) / double(N);
	else if (x != 0 && y != 0)
		return double(2) / double(N);
	else
		return sqrt(double(2)) / double(N);
}

int main()
{
	double dTestArray[N][N] = { 0, };
	double dDctArray[N][N] = { 0, };
	double dRdctArray[N][N] = { 0, };

	FILE* pOriginalFile = NULL;

	// 비교할 두 파일을 binary 모드로 연다.
	 fopen_s(&pOriginalFile, "./PeopleOnStreet_1280x720_30_Original.yuv", "rb");

	if (pOriginalFile == NULL)
	{
		fputs("File error", stderr);
		exit(1);
	}

	// 두 파일에 대해 각각 resolution 크기만큼 할당 받는다.
	int resoulution_size = 1280 * 720;
	int nFrameSize = resoulution_size + resoulution_size / 2;
	unsigned char* read_data_origin = new unsigned char[nFrameSize];
	int* transformed_data = new int[nFrameSize];
	unsigned char* restored_data = new unsigned char[nFrameSize];
	memset(read_data_origin, 0, nFrameSize);
	memset(transformed_data, 0, nFrameSize * sizeof(int));
	memset(restored_data, 0, nFrameSize);
	size_t n_size = 0;

	// 한 프레임만 추출
	n_size = fread(read_data_origin, sizeof(unsigned char), nFrameSize, pOriginalFile);
	fclose(pOriginalFile);

	// 프레임 픽셀에 8x8 블럭 적용, dct 변환하여 저장
	int nIndex = 0;
	while (nIndex < nFrameSize) {
		int nX = (nIndex / N) % N;
		int nY = nIndex % N;
		dTestArray[nX][nY] = double(read_data_origin[nIndex]);
		nIndex++;

		if (nIndex % (N * N) != 0)
			continue;

		for (int x = 0; x < N; x++) {
			for (int y = 0; y < N; y++) {
				double dInputSum = 0;
				for (int i = 0; i < N; i++) {
					for (int j = 0; j < N; j++) {
						dInputSum += dTestArray[i][j] *
							cos(((2 * double(j) + 1) * double(y) * M_PIl) / (double(2) * double(N))) *
							cos(((2 * double(i) + 1) * double(x) * M_PIl) / (double(2) * double(N)));
					}
				}
				dDctArray[x][y] = (getCval(x, y) * dInputSum); 
			}
		}

		for (int i = nIndex - (N * N); i < nIndex; i++) {
			nX = (i / N) % N;
			nY = i % N;
			transformed_data[i] = (int)((dDctArray[nX][nY]) / double(PARAMETER)); // 양자화
		}
	}

	// 역 dct
	nIndex = 0;
	while (nIndex < nFrameSize) {
		int nX = (nIndex / N) % N;
		int nY = nIndex % N;
		dDctArray[nX][nY] = double(transformed_data[nIndex]) * double(PARAMETER); // 양자화한 만큼 다시 곱함
		nIndex++;

		if (nIndex % (N * N) != 0)
			continue;

		for (int i = 0; i < N; i++) {
			for (int j = 0; j < N; j++) {
				double dInputSum = 0;
				for (int x = 0; x < N; x++) {
					for (int y = 0; y < N; y++) {
						dInputSum += getCval(x, y) * dDctArray[x][y] *
							cos(((2 * double(j) + 1) * double(y) * M_PIl) / (double(2) * double(N))) *
							cos(((2 * double(i) + 1) * double(x) * M_PIl) / (double(2) * double(N)));
					}
				}
				dRdctArray[i][j] = dInputSum;
			}
		}

		for (int i = nIndex - (N * N); i < nIndex; i++) {
			nX = (i / N) % N;
			nY = i % N;
			restored_data[i] = (unsigned char)(dRdctArray[nX][nY]);
		}
	}

    // 검증용 yuv 파일
	FILE* pWriteFile = NULL;
	fopen_s(&pWriteFile, "./PeopleOnStreet_Reverse_DCT.yuv", "wb");
	n_size = fwrite(restored_data, sizeof(unsigned char), nFrameSize, pOriginalFile);

	if(pWriteFile != NULL)
		fclose(pWriteFile);

	// RMSE값을 구한다.
	long long nTmp = 0;
	double dmse = 0;
	for (int i = 0; i < nFrameSize; i++)
		nTmp += (read_data_origin[i] - restored_data[i]) * (read_data_origin[i] - restored_data[i]);

	dmse = (double)nTmp / nFrameSize;
	printf("MSE 값 : %f\n", dmse);

	delete[] read_data_origin;
	delete[] transformed_data;
	delete[] restored_data;

	getchar();

	return 0;
}
```

우선 Original YUV파일은 아래와 같다.

![(Original YUV)](/img/in-post/post-dct-transform/2.png)

이 파일에서 1프레임만을 추출, DCT변환 적용 후 다시 역변환을 시켜 보았다.<br>
![(reverse YUV)](/img/in-post/post-dct-transform/3.png)

![(실행화면)](/img/in-post/post-dct-transform/4.png)

잘 복원되었지만, 손실 압축이기에 화질이 저하되었음이 눈에 띈다.

## 실습 후기
갈수록 영상처리에 대한 흥미가 올라가는 것 같다. 특히 이 DCT 변환은 우리가 흔히 사용하는 이미지, 동영상 포맷 압축에 많이 쓰인다고 한다. 추가로 알게 된 사실인데, 실제 압축에서는 zig-zag 스캐닝 등의 기법도 함께 사용된다고 한다. 후에 이런 기법들을 잘 익혀두면, 나중에 영상처리 작업 시 훨씬 작업이 수월해 질 것 같다. 