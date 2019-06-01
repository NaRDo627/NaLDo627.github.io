---
layout: post
title:  "자료구조 정리"
subtitle:  "기술면접대비"
date:   2019-06-01 16:00:00 +0900
author:     "날도"
header-img: "img/post-bg-2015.jpg"
mathjax: true
catalog: true
tags: 
    - 기술면접
    - 면접
    - 자료구조
    - 공부
---
Naver Campus Hackday 2019 우수 참가자로 선정되어, 네이버 계열사인 **(주)웍스모바일** 에 기술면접을 보게 되었다(무려 1시간이나.. ㄷㄷ). 웍스모바일 면접 후기 등을 찾아보면서 공부해야겠지만 그 전에, 자료구조 등 기본적인 것들은 공부를 확실히 해야겠다는 생각이 들어, 여기다 정리하면서 공부하기로 했다.

## Array & LinkedList
우선 자료구조의 기본이라고 할 수 있는 **Array** 에 대해서 보자. Array는 논리적 순서와 물리적 순서가 일치한다. 따라서 index값을 통한 원소 접근이 용이하며, 구현이 쉽다. 단점으로는 삽입, 삭제 등에 대한 연산에 필요한 Cost가 높다는 것이다. 삭제의 경우 순서를 맞추기 위해, 뒤의 원소들을 모두 앞으로 Shift연산을 해줘야 하며, 삽입의 경우도 삽입한 인덱스 포함, 그 뒤의 인덱스들에 Shift 연산을 해줘야 한다.

![(배열 그림)](/img/in-post/post-data-structure/1.PNG)

배열의 삽입/삭제 연산에 대한 비효율성을 극복하고자 등장한 것이 **LinkedList** 이다. Array와 LinkedList의 차이점은, Array는 논리적, 물리적 저장이 순서대로 되어있으나, LinkedList는 논리적으론 순서대로 되어있으나 물리적으론 순서대로 되어있지 않다. 대신 LinkedList는 각 원소가 다음 index 위치에 해당하는 물리적 주소를 가지고 있다. 그렇기에 삽입/삭제시에는 데이터를 Shift할 필요 없이, 해당되는 원소의 물리적 주소만 변경해주면 된다. 하지만 이 같은 특징 때문에 원하는 index를 참조하려면, 1번 index부터 차례대로 접근해야 한다는 비효율성이 있다.

![(리스트 그림)](/img/in-post/post-data-structure/2.PNG)

## Stack & Queue
**Stack** 은 선형 자료구조의 일종으로, FILO(First In Last Out)의 대표적인 예시로 들 수 있으며, 말 그대로 먼저 들어갔다가 나중에 나오는 구조이다. 즉 가장 나중에 들어간 원소가 가장 먼저 나오게 된다. 미로찾기, 괄호 유효성 체크 등에 활용된다.

![(스택 그림)](/img/in-post/post-data-structure/3.PNG)

**Queue** 역시 선형 자료구조이며, Stack과는 반대로 FIFO(First In First Out) 구조이다. 줄을 선다는 뜻과 같게, 먼저 들어간 원소가 가장 먼저 나온다. 작업 우선순위, Heap 구현 등에 사용된다.

![(큐 그림)](/img/in-post/post-data-structure/4.PNG)

## Tree
**Tree** 는 Stack, Queue와는 다르게 비선형 자료구조로, 계층적 구조를 표현하는 자료구조이다. 실제 데이터를 삽입하고 삭제한다는 생각 이전에, 표현에 집중하자. 트리의 구성 요소는 다음과 같다.

* Node (노드) : 트리를 구성하고 있는 원소 그 자체를 말한다.
* Edge (간선) : 노드와 노드사이를 연결하고 있는 선을 말한다.
* Root(Node) : 트리에서 최상위 노드를 말한다.
* Terminal(Node) : 트리에서 최하위 노드를 말한다. Leaf Node라고도 한다.
* Internal(Node) : 트리에서 최하위 노드를 제외한 모든 노드를 말한다. 

![(트리 그림)](/img/in-post/post-data-structure/5.jpg)

(이미지 출처 : <http://blog.daum.net/_blog/BlogTypeView.do?blogid=0JHcJ&articleno=8382646&categoryId=791705&regdt=20100728174800>)

#### Binary Tree (이진트리)
**Binary Tree**는 Root 노드를 포함, Leaf 노드를 제외한 모든 노드의 자식이 두 개인 것을 말한다. 공집합 역시 노드로 인정한다. 노드로 이루어진 각 층을 `Level`이라 하며, Level의 수를 이 트리의 `height`라 한다.

이진트리에는 모든 Level이 가득 찬 이진 트리인 **Full Binary Tree(포화 이진 트리)** 와 위에서 아래로, 왼쪽에서 오른쪽으로 순서대로 채워진 트리인 **Complete Binary Tree(완전 이진 트리)** 가 있다(**두 트리의 차이점을 알아두면 좋을 것 같다**). 배열로 포화 이진트리와 완전 이진트리를 구현했을 때, 노드의 개수 n에 대해서 i번째 노드에 대해서 `parent(i) = i/2 , left_child = 2i, right_child = 2i + 1` 의 인덱스 값을 갖는다.

![(이진트리 그림)](/img/in-post/post-data-structure/6.png)

#### BST, Binary Search Tree (이진 탐색 트리)
자료구조에서 효율적인 탐색 방법만을 고민할 것이 아니라, 효율적인 저장방법도 고민해야 한다. Binary Search Tree (이진 탐색 트리)는 이진 트리이며, 데이터를 저장하는 특별한 규칙이 있다. 그 규칙으로 찾고자 하는 데이터를 찾을 수 있다.

1. 이진 탐색 노드에 저장된 값은 유일한 값이다.
2. 루트 노드의 값은 왼쪽에 있는 모든 노드의 값보다 크다.
3. 루트 노드의 값은 오른쪽에 있는 모든 노드의 값보다 작다.
4. 각 서브 트리별로 2, 3번 규칙을 만족한다.

저장할 때 위의 규칙대로 잘 저장하기만 하면, 루트 노드로부터 원하는 값을 찾아나가는 것은 어렵지 않을 것이다. 하지만 값이 추가되고 삭제됨에 따라, 한 쪽에만 치우친 Skewed Tree(편향 트리)가 될 가능성이 있다. 이를 해결하기 위해 `Rebalancing`이라는 기법을 사용하여 트리를 재조정하게 된다.

![(이진탐색트리 그림)](/img/in-post/post-data-structure/7.png)

(이미지 출처 : <https://songeunjung92.tistory.com/31>)

#### Red Black Tree
RBT(Red-Black Tree)는 위에서 설명한 `Rebalancing`기법의 하나로, 기존 이진탐색트리의 삽입, 삭제, 탐색의 비효율성을 개선한 방법이다. RBT는 다음과 같은 규칙을 따른다.

1. 각 노드는 `Red` 혹은 `Black`이라는 색깔을 갖는다.
2. 루트 노드는 `Black`이다.
3. 각 말단 노드(NIL)는 `Black`이다.
4. 어떤 노드의 색이 `Red`라면, 두 자식 노드의 색은 모두 `Black`이다.
5. 어느 한 노드로부터 리프노드(NIL)까지의 `Black`의 수는 리프노드를 제외하면 모두 같다(이를 `Black-Height`라 한다).

RBT 특징으로는 다음과 같다.

1. Binary Search Tree이므로, BST의 특징을 모두 갖고있다.
2. 루트로부터 말단 노드까지의 최소 경로는 최대 경로의 두 배보다 크지 않다. 이를 `Balanced`한 상태라 한다.
3. 노드의 Child가 없을 경우, Child를 가리키는 포인터에 NIL(혹은 NULL)값을 저장한다. 이러한 NIL 노드들을 말단 노드로 간주한다. 말단 노드이기 때문에, 이 노드들의 색은 `Black`이다.

RBT에서의 **삽입** 과정은 다음과 같다. 우선 새로 삽입한 노드를 BST 특성을 유지하며 삽입한 후, 색을 `Red`로 칠한다. 이는 `Black-Height`의 수를 최대한 유지하기 위해서이다. 삽입 결과 RBT 특성이 위배된다면, 노드의 색을 다시 칠한다. 만일 `Black-Height`특성, 즉 위의 5번 규칙이 위배되었다면, `Rotation`을 통해 조정한다.

**삭제** 과정 역시 마찬가지로 우선 BST 특성을 유지하며 노드를 삭제한다. 삭제될 노드의 Child와 색깔로 `Rotation` 방법이 정해진다(후에 삭제 과정을 자세히 조사하겠다).

![(RBT 그림)](/img/in-post/post-data-structure/8.png)

#### Binary Heap
Binary Heap은 배열에 기반한 완전 이진탐색트리이며, Max-Heap과 Min-Heap이 있다. Max-Heap은 상위 노드의 값이 하위 각 노드의 값보다 크며, Min-Heap은 반대로 상위 노드의 값이 하위 각 노드의 값보다 작다(형제 노드끼리는 상관없다). 이 성질을 이용하면 최대, 최솟값을 찾아내는 것이 훨씬 용이하다.

![(이진힙 그림)](/img/in-post/post-data-structure/9.png)

(이미지 출처 : <https://ieatt.tistory.com/40>)

## HashTable
추후 업데이트 예정!!

## Graph
추후 업데이트 예정!!

주) HashTable, Graph는 설명할 게 많아서 추후 포스트 하게따!
