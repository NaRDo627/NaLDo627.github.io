---
layout: post
title:  "유전자 알고리즘 실습"
subtitle:  "인공지능"
date:   2019-05-05 18:03:00 +0900
author:     "날도"
header-img: "img/post-bg-2015.jpg"
mathjax: true
catalog: true
tags: 
    - 인공지능
    - 파이썬
    - 과제
---

인공지능 수업에서 유전자 알고리즘에 대한 과제를 하게 되었다.

## 유전자 알고리즘(GA)이란?
 다윈의 진화론에 의하면, 지구가 처음 생성되고 지금까지 환경에 적응한 생물만이 살아남고, 또한 진화했다. 유전 알고리즘은 생물체가 환경에 적응하며 진화하는 모습을 모방하여, 최적해를 찾아내는 검색 방법이다. GA는 수학적으로 명확하게 이해 혹은 풀기 힘든 문제에도 적용이 가능하기 때문에, 이 경우 매우 유용하게 사용된다. <br>
 **염색체(Chromosome)** 는 생물학적으로 유전자들이 뭉쳐져 포장된 것이다. GA에서의 염색체는 하나의 개체 값을 의미한다.<br>
 **유전자(gene)** 는 생물학적으로나 GA적으로나 염색체의 요소로, 유전 정보를 나타낸다. 
 **자손(offspring, child)** 는 부모(Parent) 유전자로부터 생성된 자식 유전자이며, 이전 세대와 비슷한 (완전히 동일하지는 않은) 유전 정보를 갖게 된다.
 **적합도(fitness)** 어떤 염색체가 최적해에 얼마나 가까운지 나타내는 고유 값으로, 적합도의 값으로 염색체의 개체선별을 하게 된다.<br><br>
 어떤 문제에 유전 알고리즘을 적용하기 위해서는 그 문제에 대해 아래와 같이 5개의 연산을 정의해야 한다.
 1. 초기 염색체를 생성하는 연산
 2. 적합도를 계산하는 연산
 3. 적합도를 기준으로 염색체를 선택하는 연산
 4. 선택된 염색체들로부터 자손을 생성하는 연산
 5. 돌연변이 연산

보통 1번 연산 후, 2~5번 연산을 반복하는 식으로 진행된다. 각 연산에 대한 설명은 실습과 함께 진행하겠다.

## 실습 개요
 저번 [다층 퍼셉트론 실습](https://naldo627.github.io/2019/04/22/multipayer-perceptron/)에서, C/C++ 로 제로코드부터 시작하여 코딩하였었는데, 그 당시의 고통이 너무 커서... 이번엔 비교적 간단한 예제를 파이썬으로 실습을 진행할 계획이다.<br>
 해결할 문제는 숫자야구 게임이다. 숫자야구 게임 규칙은 다음과 같다.
 1. 임의의 N자리 숫자를 선택한다. <br>(예 : N은 4, 숫자는 1234)
 2. 플레이어는 숫자를 임의로 추측한다.  <br>(예 : 현국은 숫자를 2354로 추측하였다.)
 3. 숫자와 자릿수가 모두 일치하는 숫자의 수는 스트라이크, 자릿수는 일치하지 않지만 숫자만 일치하는 숫자의 수는 볼로 계산한다. 만약 스트라이크, 볼 모두 0이라면 아웃이다. (어떤 숫자가 스트라이크인지, 볼인지는 알려주지 않는다.) <br>(예 : 현국은 2354를 추측하였지만 답은 1234로, 1스트라이크 2볼이다.)
 4. 플레이어는 이 정보를 가지고 숫자를 다시 추측한다.<br>
 (예 : 현국은 2354로 1스트라이크 2볼을 얻었음으로, 4235를 시도한다.)

 실습에서는 N은 6, 즉 임의의 6자리 숫자를 가지고 실험하였으며, 염색체를 10개를 두고 실험하였다.<br>
 fitness 함수는 스트라이크를 5점, 볼을 1점으로 환산하여 적합도를 계산하였다. 선택 방식은 룰렛방식으로, 각 염색체 중 적합도가 가장 높은 염색체를 선택하여 유전자를 교환하였다.

## 실습 과정
 1. 초기 염색체를 생성하는 연산
```python
def _generate_parent(length, geneSet, get_fitness):
    chromosome_list = []
    for i in range(0, 10):
        genes = []
        while len(genes) < length:
            sampleSize = min(length - len(genes), len(geneSet))
            genes.extend(random.sample(geneSet, sampleSize))
        fitness = get_fitness(genes)
        chromosome_list.append(Chromosome(genes, fitness))
    return chromosome_list
```
정답과 같은 길이의 염색체를 10개정도 생성하여, 리스트에 저장한다. 이때 유전자의 배열은 0부터 9까지 사이 숫자의 랜덤 값이다.

 2. 적합도를 계산하는 연산
 ```python
 def get_fitness(guess, target):
    fitness = 0
    for expected, actual in zip(target, guess):
        if expected == actual:
            fitness += 5
        elif actual in target:
            fitness += 1

    return fitness
 ```
 숫자와 그 위치까지 동일하다면 스트라이크이므로 5점, 만약 위치는 같지 않고 숫자만 같다면 볼이므로 1점으로 환산하여 계산한다.
 
 3. 적합도를 기준으로 염색체를 선택하는 연산
 ```python
 def _generate_child(parent_list, geneSet, get_fitness):
    child_list = []
    fitness_percent_list = []
    fitness_accum_list = []
    fitness_sum = 0
    for parent in parent_list:
        fitness_sum += parent.Fitness

    for parent in parent_list:
        fitness_percent_list.append(parent.Fitness / fitness_sum)

    fitness_sum = 0
    for fitness_percent in fitness_percent_list:
        fitness_sum += fitness_percent
        fitness_accum_list.append(fitness_sum)

    # Selection
    for i in range(0, 10):
        rand = random.random()
        before = 0
        for j in range(0, len(fitness_accum_list)):
            if rand > before and rand <= fitness_accum_list[j]:
                child_list.append(copy.deepcopy(parent_list[j]))
                break
            before = fitness_accum_list[j]

    # --- 생략 ---
 ```
 부모들로부터 계산된 적합도 값을 모두 더한 후, 백분율로 환산하여 축적하여 저장한다. 이후 난수를 돌려서 걸린 염색체를 자식 염색체로 지정한다. 이게 바로 룰렛 휠 방식이다.

 4. 선택된 염색체들로부터 자손을 생성하는 연산
 ```python
 def _generate_child(parent_list, geneSet, get_fitness):
    # --- 생략 ---

    # Crossover
    crossover_rate = 0.20
    selected = None
    for i in range(0, len(child_list)):
        rand = random.random()
        if rand < crossover_rate:
            if selected is None:
                selected = i
            else:
                child_list[selected].Genes[2:], child_list[i].Genes[2:] = \
                    child_list[i].Genes[2:], child_list[selected].Genes[2:]
                selected = None

        # update
        child_list[i].Fitness = get_fitness(child_list[i].Genes)

    # --- 생략 ---
 ```
 선택한 염색체 중 랜덤으로 선택하여 유전자를 교배 시킨다. Single Point Crossover 방식으로, 유전자, 즉 숫자의 일부를 두 유전자끼리 교환시킨다. Crossover Point는 임의로 지정하였다.

 5. 돌연변이 연산
 ```python
 def _generate_child(parent_list, geneSet, get_fitness):
    # --- 생략 ---

    # mutate
    mutate_rate = 0.2
    for i in range(0, len(child_list)):
        rand = random.random()
        if rand < mutate_rate:
            child = _mutate(child_list[i], geneSet, get_fitness)
            del child_list[i]
            child_list.append(child)
    return child_list
 ```
 기존의 염색체들로만 교배를 한다면 지역 최적점, 즉 원하는 값에 도달할 수가 없기 때문에, 광역 최적점에 도달하기 위해서는 돌연변이 연산을 섞어줘야 한다. 일정 확률로 돌연변이를 발생 시킨 후, 유전자의 일부를 치환하였다.

 결과는 다음과 같다.
 ```
 target : 841532
820653	1/3	8	0:00:00.000997
491670	1/1	6	0:00:00.000997
763810	0/3	3	0:00:00.000997
642183	1/4	9	0:00:00.000997
702563	1/2	7	0:00:00.000997
721048	1/3	8	0:00:00.000997
978064	0/2	2	0:00:00.000997
543081	1/4	9	0:00:00.000997
841530	5/0	25	0:00:00.000997
493157	0/4	4	0:00:00.000997
average fitness : 8.1
new maximum fitness : 9.1
new maximum fitness : 13.6
new maximum fitness : 17.2
...중략...
new maximum fitness : 29.2
new maximum fitness : 29.6
new maximum fitness : 30.0
841532	6/0	30	0:00:00.038933
841532	6/0	30	0:00:00.038933
841532	6/0	30	0:00:00.038933
841532	6/0	30	0:00:00.038933
841532	6/0	30	0:00:00.038933
841532	6/0	30	0:00:00.038933
841532	6/0	30	0:00:00.038933
841532	6/0	30	0:00:00.038933
841532	6/0	30	0:00:00.038933
841532	6/0	30	0:00:00.038933
average fitness : 30.0
 ```

 ```
 target : 495367
450791	1/3	8	0:00:00
315478	1/3	8	0:00:00
068147	1/2	7	0:00:00
598437	2/3	13	0:00:00
385704	1/3	8	0:00:00
623759	0/5	5	0:00:00
253147	1/3	8	0:00:00
548967	2/3	13	0:00:00
067142	0/3	3	0:00:00
431768	2/2	12	0:00:00
average fitness : 8.5
new maximum fitness : 9.5
new maximum fitness : 11.0
...중략...
new maximum fitness : 29.1
new maximum fitness : 30.0
495367	6/0	30	0:00:00.025973
495367	6/0	30	0:00:00.025973
495367	6/0	30	0:00:00.025973
495367	6/0	30	0:00:00.025973
495367	6/0	30	0:00:00.025973
495367	6/0	30	0:00:00.025973
495367	6/0	30	0:00:00.025973
495367	6/0	30	0:00:00.025973
495367	6/0	30	0:00:00.025973
495367	6/0	30	0:00:00.025973
average fitness : 30.0
 ```
 위와 같이 원하는 결과가 잘 나오는 것을 확인할 수 있었다.

## 실습 후기
 저번 다층 퍼셉트론 구현할 때 사실 엄청난 좌절감을 느꼈었다. 이번에도 혹시나 실패하여 좌절감이 더해지지는 않을 까 걱정 했었는데, 다행히도 난이도가 그렇게 어렵지 않은 실습이었고, [오픈소스](https://github.com/handcraftsman/GeneticAlgorithmsWithPython)를 참고할 수가 있어 오히려 자신감이 붙은 느낌이다. 이 교육용 오픈소스가 보기 쉽게 되어있어서, 유전자 알고리즘을 이해하는 데 많은 도움이 되었다. 하지만 Crossover 없이 Mutate로만 구현되어 있었고, 염색체도 하나밖에 쓰지 않아서, 해당 부분은 내가 직접 구현했다. 덕분에 유전자 알고리즘을 한층 더 이해하기 수월했던 것 같다.

## 소스코드
```python
import datetime
import random
import unittest
import copy

def _generate_parent(length, geneSet, get_fitness):
    chromosome_list = []
    for i in range(0, 10):
        genes = []
        while len(genes) < length:
            sampleSize = min(length - len(genes), len(geneSet))
            genes.extend(random.sample(geneSet, sampleSize))
        fitness = get_fitness(genes)
        chromosome_list.append(Chromosome(genes, fitness))
    return chromosome_list

def _mutate(parent, geneSet, get_fitness):
    childGenes = parent.Genes[:]
    index = random.randrange(0, len(parent.Genes))
    newGene, alternate = random.sample(geneSet, 2)
    childGenes[index] = alternate if newGene == childGenes[index] else newGene
    fitness = get_fitness(childGenes)
    return Chromosome(childGenes, fitness)

def _generate_child(parent_list, geneSet, get_fitness):
    child_list = []
    fitness_percent_list = []
    fitness_accum_list = []
    fitness_sum = 0
    for parent in parent_list:
        fitness_sum += parent.Fitness

    for parent in parent_list:
        fitness_percent_list.append(parent.Fitness / fitness_sum)

    fitness_sum = 0
    for fitness_percent in fitness_percent_list:
        fitness_sum += fitness_percent
        fitness_accum_list.append(fitness_sum)

    # Selection
    for i in range(0, 10):
        rand = random.random()
        before = 0
        for j in range(0, len(fitness_accum_list)):
            if rand > before and rand <= fitness_accum_list[j]:
                child_list.append(copy.deepcopy(parent_list[j]))
                break
            before = fitness_accum_list[j]

    # Crossover
    crossover_rate = 0.20
    selected = None
    for i in range(0, len(child_list)):
        rand = random.random()
        if rand < crossover_rate:
            if selected is None:
                selected = i
            else:
                child_list[selected].Genes[2:], child_list[i].Genes[2:] = \
                    child_list[i].Genes[2:], child_list[selected].Genes[2:]
                selected = None

        # update
        child_list[i].Fitness = get_fitness(child_list[i].Genes)

    # mutate
    mutate_rate = 0.2
    for i in range(0, len(child_list)):
        rand = random.random()
        if rand < mutate_rate:
            child = _mutate(child_list[i], geneSet, get_fitness)
            del child_list[i]
            child_list.append(child)
    return child_list


def get_best(get_fitness, targetLen, optimalFitness, geneSet, display):
    random.seed()

    # 1. Generate Parent
    bestParentList = _generate_parent(targetLen, geneSet, get_fitness)
    display(bestParentList)

    gen_count = 0
    maximum_average = 0
    while True:
        gen_count += 1
        #print("generation : {}".format(gen_count))
        child_list = _generate_child(bestParentList, geneSet, get_fitness)

        fitness_sum = 0
        for child in child_list:
            fitness_sum += child.Fitness

        average = fitness_sum / 10
        if average > maximum_average:
            print("new maximum fitness : {}".format(average))
            bestParentList = child_list
            maximum_average = average

        if average >= optimalFitness:
            return child_list

class Chromosome:
    def __init__(self, genes, fitness):
        self.Genes = genes
        self.Fitness = fitness

def get_fitness(guess, target):
    fitness = 0
    for expected, actual in zip(target, guess):
        if expected == actual:
            fitness += 5
        elif actual in target:
            fitness += 1

    return fitness

def display(candidate, target, startTime):
    timeDiff = datetime.datetime.now() - startTime
    strike = 0
    ball = 0
    for expected, actual in zip(target, candidate.Genes):
        if expected == actual:
            strike += 1
        elif actual in target:
            ball += 1

    if strike == 0 and ball == 0:
        result = "out"
    else:
        result = "{}/{}".format(strike, ball)

    print("{}\t{}\t{}\t{}".format(
        ''.join(candidate.Genes),
        result,
        candidate.Fitness,
        timeDiff))

def display_list(candidate_list, target, startTime):
    fitness_sum = 0
    for candidate in candidate_list:
        display(candidate, target, startTime)
        fitness_sum += candidate.Fitness
    print("average fitness : {}".format(fitness_sum / len(candidate_list)))

def pick_baseball_num(length, is_duplicate_allowed):
    if is_duplicate_allowed is True or length > 10:
        return ''.join(random.choice("0123456789")
                       for _ in range(length))

    baseball_list = []
    num = random.randrange(0, 10)

    for i in range(length):
        while str(num) in baseball_list:
            num = random.randrange(0, 10)
        baseball_list.append(str(num))

    return ''.join(baseball_list)


class BaseballGames(unittest.TestCase):
    geneset = "0123456789"

    def test_Baseball(self):
        length = 6

        target = pick_baseball_num(length, False)
        print("target : {}".format(target))
        self.guess_baseball(target)

    def guess_baseball(self, target):
        startTime = datetime.datetime.now()

        def fnGetFitness(genes):
            return get_fitness(genes, target)

        def fnDisplay(candidate_list):
            display_list(candidate_list, target, startTime)

        optimalFitness = len(target) * 5
        child_list = get_best(fnGetFitness, len(target), optimalFitness,
                                self.geneset, fnDisplay)

        fnDisplay(child_list)


if __name__ == '__main__':
    unittest.main()

 ```


 _주관적인 생각이 많이 들어간 포스트입니다. 지적은 언제나 환영입니다!_

> 출처 : <https://github.com/handcraftsman/GeneticAlgorithmsWithPython>