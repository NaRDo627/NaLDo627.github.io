---
layout: post
title:  "알고리즘 정리"
subtitle:  "알고리즘"
date:   2019-06-02 15:37:00 +0900
author:     "날도"
header-img: "img/post-bg-2015.jpg"
mathjax: true
catalog: true
tags: 
    - 기술면접
    - 면접
    - 알고리즘
    - C/C++
---

저번 포스팅에 이어서, 정렬 등의 알고리즘에 대해서 정리하려고 한다.
특히 공간, 시간복잡도를 생각하면서 정리하도록 하자.

## 정렬 알고리즘 (Sorting)
우선 알고리즘의 기본이라고도 할 수 있는 정렬 알고리즘이다. 크게 Comparisons방식과 non-Comparisions방식으로 나뉘어져 있다.
Comparisons방식에는 `Bubble Sort`, `Selection Sort`, `Insertion Sort`, `Merge Sort`, `Heap Sort`, `Quick Sort`등이 있다.

#### 버블 정렬 (Bubble Sort)
버블 정렬은 n개의 원소를 가진 배열을 정렬할 때, 인접한 두 원소를 비교해 가며 정렬하는 방식이다. 그러므로 정렬은 끝에서부터 완성된다.

```cpp
void bubbleSort(int* a_pAry, int a_nSize) {
	int temp = 0;
	bool sorted = false; // 중간에 정렬이 한 번도 이루어지지 않았다면 정렬이 된 것이므로 정렬 중단
	for (int n = a_nSize-1; n >= 0; n--) {
		if (sorted)
			break;

		sorted = true;
		for (int i = 0; i < n; i++) {
			if (a_pAry[i + 1] >= a_pAry[i])
				continue;

			temp = a_pAry[i];
			a_pAry[i] = a_pAry[i + 1];
			a_pAry[i + 1] = temp;
			sorted = false;
		}
	}
}
```

공간 복잡도 | 시간 복잡도 
---------|----------
 $O(1)$ | $O(n^2)$

 

#### 선택 정렬 (Selection Sort)
n개의 원소를 가진 배열에서 가장 큰 값의 인덱스를 저장한 뒤에, 최종적으로 한 번만 정렬한다. 하지만 여러 번 비교를 하는 것은 마찬가지기에, 시간 복잡도에서는 별 이득을 취하지 못한다.

```cpp
void selectionSort(int* a_pAry, int a_nSize) {
	int temp = 0;
	bool sorted = false; // 중간에 정렬이 한 번도 이루어지지 않았다면 정렬이 된 것이므로 정렬 중단

	for (int n = a_nSize-1; n >= 0; n--) {
		sorted = true;
		int nMaxIndex = -1;

		for (int i = 0; i <= n; i++) {
			if (a_pAry[nMaxIndex] >= a_pAry[i])
				continue;
			
			nMaxIndex = i;
			sorted = false;
		}

		if (sorted)
			break;

		temp = a_pAry[nMaxIndex];
		a_pAry[nMaxIndex] = a_pAry[n];
		a_pAry[n] = temp;
	}
}
```

공간 복잡도 | 시간 복잡도 
---------|----------
 $O(1)$ | $O(n^2)$



#### 삽입 정렬 (Insertion Sort)
n개의 원소를 가진 배열에서, 0부터 n까지의 인덱스 i가 진행될 때, i-1에서 0까지 탐색하며 삽입할 곳을 찾는 정렬이다. 이때 0부터 i-1까지의 인덱스는 이미 정렬이 되어있다(i가 0부터 시작하며 정렬해 나가기 때문).

```cpp
void insertionSort(int* a_pAry, int a_nSize) {
	int temp = 0;
	int nInsertionIndex = 0;

	for (int nIndex = 1; nIndex < a_nSize; nIndex++) {
		temp = a_pAry[nIndex];

		for (nInsertionIndex = nIndex - 1; nInsertionIndex >= 0; nInsertionIndex--) {
			if (temp >= a_pAry[nInsertionIndex])
				break;
				
			a_pAry[nInsertionIndex + 1] = a_pAry[nInsertionIndex];
		}
		a_pAry[nInsertionIndex + 1] = temp;
	}
}
```

공간 복잡도 | 시간 복잡도 
---------|----------
 $O(1)$ | $O(n^2)$


#### 병합 정렬 (Merge Sort)
n개의 원소를 가지고 있는 배열을 2로 나누어지지 않을 때까지 분할 후, 임시 배열에
나누어진 원소를 비교하여 담은 후, 정렬된 임시배열을 원래 배열에 다시 대입함으로서 정렬하는 방법이다. 이를 분할하여 정복한다는 의미의 `Divide and conquer` 방법이라 하며, 복잡한 문제를 분할하여 정복한다는 방법이다. 분할하여 정복한 후에는 다시 결합해야 한다.

```cpp
void merge(int* a_pAry, int a_nFIndex, int a_nMIndex, int a_nLIndex) {
	int nSize = a_nLIndex - a_nFIndex + 1;
	int* pTempAry = new int[1024];
	int i = a_nFIndex;
	int j = a_nMIndex+1;
	int nIndex = a_nFIndex;

	while (true) {
		if (a_pAry[i] < a_pAry[j])
			pTempAry[nIndex] = a_pAry[i++];
		else
			pTempAry[nIndex] = a_pAry[j++];
		nIndex++;

		if (i == a_nMIndex + 1 || j == a_nLIndex + 1)
			break;
	}

	while (i <= a_nMIndex) {
		pTempAry[nIndex] = a_pAry[i++];
		nIndex++;
	}
	while (j <= a_nLIndex) {
		pTempAry[nIndex] = a_pAry[j++];
		nIndex++;
	}
		 
	for (nIndex = a_nFIndex; nIndex <= a_nLIndex; nIndex++)
		a_pAry[nIndex] = pTempAry[nIndex];

	delete[] pTempAry;
}

void mergeSort(int* a_pAry, int a_nFIndex, int a_nLIndex) {
	if (a_nFIndex >= a_nLIndex)
		return;

	int nMIndex = (a_nFIndex + a_nLIndex) / 2;
	mergeSort(a_pAry, a_nFIndex, nMIndex);
	mergeSort(a_pAry, nMIndex+1, a_nLIndex);
	merge(a_pAry, a_nFIndex, nMIndex, a_nLIndex);
}
```

공간 복잡도 | 시간 복잡도 
---------|----------
 $O(n)$ | $O(n\log{n})$


 #### 힙 정렬 (Heap Sort)
 저번 포스팅에서 다룬 `Binary Heap` 자료구조를 활용한 Sorting이다. n개의 원소로 구성된 배열을 `heapify`하여 정렬을 하게 된다. Heap 자료구조에 저장하는 시간 복잡도는 $O(log{n})$이며, n개에 대해서 정렬을 하면 $O(log{n})$의 시간 복잡도를 갖게 된다.

 ```cpp
 // 소스코드 : 추후 업뎃
 ```
 
공간 복잡도 | 시간 복잡도 
---------|----------
 $O(1)$ | $O(n\log{n})$

#### 퀵 정렬 (Quick Sort)
추후 업데이트 예정!!

주) 정리하다가 머리에 쥐날거 같아서, 힙 정렬부터 다른 알고리즘까지 추후 업데이트 하게따!! 수~목 중으로.. 탐색 알고리즘과 프림 알고리즘까지 목표로 하자. 가능한가?
