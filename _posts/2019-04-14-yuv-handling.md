---
layout: post
title:  "YUV 영상 처리 실습"
subtitle:  "영상처리"
date:   2019-04-14 22:56:00 +0900 # release.sh 사용시 자동 입력 될것임
author:     "날도"
header-img: "img/post-bg-2015.jpg"
mathjax: true
catalog: true
tags: 
    - 영상처리
    - 과제
    - C/C++
---

## 개요

영상처리 과제로 YUV 영상처리 실습을 하게 되었다.<br>
YUV 파일을 처리하여 첨부 파일 중 PeopleOnStreet_Original YUV 파일에 대하여 PeopleOnStreet_Recons YUV 파일에 대한 Y 값만의 Root mean square error (제곱평균제곱근 차이)를 구하는 것이 목표이다.<br>

## YUV 파일이란?

기존에는 RGB 방식으로 영상을 처리하였다. RGB를 이용한 색 표현은 색 그대로를 전부 묘사가 가능하다. 그러나 이는 용량이 매우 커진다는 단점이 있다. 이 용량이 커지는 단점을 영상으로 가져오기에는 큰 무리가 있다. 그래서 생긴 포맷이 YUV 포맷이다.<br>
빛의 삼원색을 표현하는 RGB와 달리 빛의 밝기를 나타내는 휘도(Y)와 색상신호 2개(U, V)(각각 파란색, 빨간색 성분)로 표현하는 방식이다.<br>
사람의 눈은 색깔 그 자체보다 휘도, 즉 밝게에 더 민감하기 때문에 샘플링 단계에서 적용하여 압축한다.

![(YUV 파일 형태)](/img/in-post/post-yuv-handling/1.png)

실습에 사용하는 파일은 420 YUV 파일로, 형태는 위와 같다. <br>
즉, Y의 길이는 해상도(resolution)의 길이이며, U와 V는 각각 (resolution / 4) 길이이다<br>
해상도(resolution)를 1280 x 720 으로, YUV파일의 첫 번째 프레임의 offset값은 아래와 같다.<br>
```
Y = 0 ~ resolution - 1
U = resolution ~ (resolution + resolution / 4) - 1
V = (resolution + resolution / 4) ~ (resolution + resolution / 4 + resolution / 4) - 1
```

써놓고 보니 뭔가 어려워 보이지만, 결국 YUV파일의 한 프레임의 크기는 resoultion + resolution / 2 이며, 다음 프레임의 위치는 (resolution + resolution / 2) ~ (3 * resolution) - 1 이다.

## MSE, PSNR 이란?

$$

\text{PSNR} = 10\log(\frac{255^2}{\text{MSE}})

$$

$$

\text{MSE} = \frac{1}{MN}\sum_{i=1}^M\sum_{j=1}^N[I(i,j)=I^{'}(i,j)]^2

$$

**MSE(Mean Square Error)** 라는 것은 평균제곱오차를 말하는 것으로, 통계적 추정에서 실제값과 추정값의 차로 정확성에 대한 질적인 척도로 사용된다고 한다. 여기서는 원본영상과 압축해제 후 영상의 손실율을 측정하기 위한 용도로 사용된다. <br>
위의 그림에서 M, N은 영상의 가로, 세로 크기, I(i,j)는 해당 지점의 픽셀 값을 나타낸다.<br>

**PSNR(Peak Signal to Noise Ratio)** 이라는 것은 두 영상을 비교한 값을 숫자로 나타낸 것으로, 오차값(MSE)값이 적을 수록 PSNR 값은 높아진다. 즉, 압축했다가 복원한 영상에 대한 PSNR값이 높아지면 높아질수록 원본 영상에 가깝다는 말이 된다.<br>

우리가 구해야 하는 것은 **RMSE(Root Mean Square Error)** , 즉 제곱평균제곱근 차이의 평균 값으로, 각 프레임마다 MSE를 구한 후, 제곱근을 한 다음, 평균을 내면 된다.<br>

우리가 실습할 파일은 PeopleOnStreet_Original.yuv 파일과 PeopleOnStreet_Recons.yuv 파일 두 가지이다.<br>
이 두 파일에 대해, Y값만의 RMSE값을 구한 후, 평균을 내면 된다.<br>

## 실습과정

먼저, 실습에 사용한 YUV 파일을 YUV 플레이어(<http://www.yuvplayer.com/>)를 사용하여 재생해 보았다.

![(Original YUV 파일 재생)](/img/in-post/post-yuv-handling/2.PNG)

![(Recons YUV 파일 재생)](/img/in-post/post-yuv-handling/3.PNG)

각각 30프레임씩 구성되어 있음을 확인할 수 있었다. 우리는 이 파일을 c++로 열어 Y값만을 추출한 다음, RMSE값을 구할 것이다.<br>
우선, Y값만 잘 뽑아낼 수 있는지를 테스트 하기위해 아래와 같이 소스코드를 작성하였다.

```cpp
#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main()
{
    FILE *pFile = NULL;
    FILE *pWriteFile = NULL;

    // 읽기 파일과 쓰기 파일을 각각 binary 모드로 연다.
    pFile = fopen("./PeopleOnStreet_1280x720_30_Original.yuv", "rb");
    pWriteFile = fopen("./oneframe_y.yuv", "wb");

    // 파일이 제대로 열렸는지 체크
    if(pFile == NULL || pWriteFile == NULL)
    {
    	fputs("File error", stderr);
    	exit(1);
    }

    // 해상도 크기 만큼 동적할당 받는다.
    int resoulution_size = 1280 * 720;
    unsigned char* read_data = new unsigned char[resoulution_size];
    size_t n_size = 0;

    // 버퍼크기만큼 초기화 후 한 프레임 읽은 후 그대로 쓴다.
    memset(read_data, 0, resoulution_size);
    n_size = fread(read_data, sizeof(unsigned char), resoulution_size, pFile);
    n_size = fwrite(read_data, sizeof(unsigned char), resoulution_size, pWriteFile);
    
    // 버퍼를 0으로 초기화 한 후 해상도 / 2 크기만큼 0으로 채운다.
    memset(read_data, 0, resoulution_size);
    n_size = fwrite(read_data, sizeof(unsigned char), resoulution_size / 2, pWriteFile);

    delete read_data;

    fclose(pWriteFile);
    fclose(pFile);

    getchar();

    return 0;
}
```

위 소스코드를 실행한 후, 생성된 oneframe_y.yuv를 YUV 플레이어로 재생해 보았다.

![(oneframe_y YUV 파일 재생)](/img/in-post/post-yuv-handling/4.PNG)

한 프레임의 Y값(휘도값)만 보여지는 것을 확인할 수 있었다.<br>
(그림이 파랗게 보이는 이유는 YUV 플레이어가 0으로 채워진 U, V값을 합하여 보여주려고 시도하기 때문이다)

이제 두 파일을 프레임 단위로 Y값을 추출한 후, RMSE값을 구한 후 평균을 구해보겠다.

```cpp
#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int main()
{
	FILE *pOriginalFile = NULL;
	FILE *pReconFile = NULL;

	// 비교할 두 파일을 binary 모드로 연다.
	pOriginalFile = fopen("./PeopleOnStreet_1280x720_30_Original.yuv", "rb");
	pReconFile = fopen("./PeopleOnStreet_1280x720_30_Recons.yuv", "rb");

	if(pOriginalFile == NULL || pReconFile == NULL)
	{
		fputs("File error", stderr);
		exit(1);
	}

	// 두 파일에 대해 각각 resolution 크기만큼 할당 받는다.
	int resoulution_size = 1280 * 720;
	unsigned char* read_data_origin = new unsigned char[resoulution_size];
	unsigned char* read_data_recon = new unsigned char[resoulution_size];
	size_t n_size = 0;

	printf("현재 Originfile 포인터 위치 : %d\n", ftell(pOriginalFile));
	printf("현재 reconfile 포인터 위치 : %d\n\n", ftell(pReconFile));
	
	// 프레임 수(30)만큼 반복
	double dRmseSum = 0;
	for(int nFrame = 1; nFrame <= 30; nFrame++)
	{
		// 버퍼를 초기화 한 후 Y값만 추출한다.
		memset(read_data_origin, 0, resoulution_size);
		memset(read_data_recon, 0, resoulution_size);
		n_size = fread(read_data_origin, sizeof(unsigned char), resoulution_size, pOriginalFile);
		n_size = fread(read_data_recon, sizeof(unsigned char), resoulution_size, pReconFile);

		// RMSE값을 구한다.
		int nTmp = 0;
		double dRmse = 0;
		for(int i = 0; i < resoulution_size; i++)
			nTmp += (read_data_origin[i] - read_data_recon[i]) * (read_data_origin[i] - read_data_recon[i]);

		dRmse = sqrt((double)nTmp / resoulution_size);
		printf("%d프레임의 Y값의 RMSE 값 : %f\n", nFrame, dRmse);
		dRmseSum += dRmse;

		// PSNR값을 확인하고 싶다면 아래 주석 해제
		/*
		double psnr = 10 * log10(255 * 255 / ((double)nTmp / resoulution_size));
		printf("%d프레임의 Y값의 PSNR 값 : %f\n\n", nFrame, psnr);
		*/
		
		// U, V값은 읽지 않을 것이므로, 다음 프레임을 가르키도록 파일 포인터 전진
		// (현재 위치에서 해상도 / 2 크기만큼 파일 포인터를 전진시킨다)
		fseek(pOriginalFile, (long)resoulution_size / 2, SEEK_CUR);
		fseek(pReconFile, (long)resoulution_size / 2, SEEK_CUR);
	}

	printf("\n현재 Originfile 포인터 위치 : %d\n", ftell(pOriginalFile));
	printf("현재 reconfile 포인터 위치 : %d\n", ftell(pReconFile));

	printf("\nY값만의 RMSE 평균 값 : %f\n", dRmseSum / 30);

	delete read_data_recon;
	delete read_data_origin;

	fclose(pReconFile);
	fclose(pOriginalFile);

	getchar();

	return 0;
}
```

실행 결과는 다음과 같다.

![(실행결과)](/img/in-post/post-yuv-handling/5.PNG)
<br>(처음 실행과 끝에 파일의 포인터 위치를 삽입한 이유는 두 파일을 확실히 제대로 읽었는지 확인하기 위해서이다)

실행 결과로 보았을 때, 두 영상의 Y값에 대한 RMSE의 평균은 약 7.13인 것을 알 수 있었다.

만약 프레임당 PSNR값을 확인하고 싶다면, RMSE를 구하는 소스코드 바로 밑에 있는 PSNR 구하는 과정의 주석을 해제하면 된다.<br>
(본인이 따로 실험해 본 결과, 평균 PSNR값이 30db을 넘어간다는 것을 알 수 있었다. 이는 두 영상의 화질차이는 있으나, 사람의 눈으로는 식별하기 어렵다는 것을 의미한다고 한다)

## 실습후기

영상처리 수업을 듣기 전에는, 색의 표기는 빛의 삼원색인 RGB외에는 없는 줄 알았다. 수업중에 YUV에 대한 내용을 들었을 때도, 사실 크게 와닫지는 않았던 것 같다. 하지만 이렇게 직접 YUV파일 처리에 대한 실습을 하고나니, 나는 영상처리 부분에선 우물 안 개구리였다는 생각을 하게 되었다. 또한 파일 입출력을 통해 Y, U, V 픽셀 값 각각을 접근할 수 있다는 것도 신기했다. 물론 실제 영상에서는 압축 기술이 들어가기 때문에 이같이 Y값만 뽑아내기는 어려울 지도 모르지만, 우선은 영상처리의 기초를 배웠다는 생각에 자신감이 붙은 느낌이다. (물론 갈길을 아직 멀지만..)

 _주관적인 생각이 많이 들어간 포스트입니다. 지적은 언제나 환영입니다!_
