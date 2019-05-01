---
layout: post
title:  "Mininet - Routing 실습"
subtitle:  "데이터 통신"
date:   2019-05-01 15:40:00 +0900
author:     "날도"
header-img: "img/post-bg-2015.jpg"
mathjax: true
catalog: true
tags: 
    - 데이터 통신
    - Mininet
    - 네트워크
---

데이터 통신 과제로 Mininet의 routing table 에 대한 실습을 하게 되었다.

## 실습 네트워크 구성

실습에 사용되는 네트워크 망 그림은 다음과 같다.

![(네트워크망)](/img/in-post/post-mininet-routing/0.png)

h1과 h2 사이에는 10.0.1.0/24 서브넷, h2와 h3 사에이는 10.0.2.0/24 서브넷이 형성될 것이다. <br>
먼저 Mininet 소스코드는 다음과 같다.
```python
#!/usr/bin/python

from mininet.net import Mininet
from mininet.node import Controller, RemoteController
from mininet.link import TCLink
from mininet.cli import CLI
from mininet.log import setLogLevel, info
from subprocess import call
import time, os

net = Mininet(controller=None, link=TCLink, autoSetMacs=True)
print "***Creating nodes..."
h1 = net.addHost('h1')
h2 = net.addHost('h2')
h3 = net.addHost('h3')
print "***Creating links..."
net.addLink(h1, h2)
net.addLink(h2, h3)
net.start()
CLI(net)
net.stop()
```

위 파이썬 스크립트를 실행 후, 각각의 노드에 대한 인터페이스 설정하였다.

![(h1 인터페이스)](/img/in-post/post-mininet-routing/1.png)

![(h2 인터페이스)](/img/in-post/post-mininet-routing/2.png)

![(h3 인터페이스)](/img/in-post/post-mininet-routing/3.png)

각각의 서브넷에 대해 Ping 요청을 해보았다.

![(h1-h2 ping)](/img/in-post/post-mininet-routing/4.png)

![(h2-h3 ping)](/img/in-post/post-mininet-routing/5.png)

각각의 서브넷에 대해서는 ping 요청에 정상적으로 응답이 돌아오는 것을 확인할 수 있었다.

![(h1-h3)](/img/in-post/post-mininet-routing/6.png)

하지만 서로 다른 서브넷인 h1, h3 사이에서는 ping 요청이 실패하였다. 각각의 라우팅 테이블이 작성되지 않았기 때문이다. 우리는 이 노드들 사이의 라우팅테이블을 조작하여 서로 통신이 되도록 할 것이다.

## 라우팅 테이블 작성

우선 라우터 역할을 할 노드 h2에서 라우팅 설정을 확인한 뒤 켜준다.

![(h2 - routing)](/img/in-post/post-mininet-routing/7.png)

(0은 disable, 1은 enable 이다)

그 후 h1, h3에서 각각 라우팅 테이블을 작성한다.<br>
라우팅 테이블을 작성할 때, h2 쪽 인터페이스의 주소를 기본 게이트웨이로 설정한다.

![(h1 routing table)](/img/in-post/post-mininet-routing/8.png)

![(h3 routing table)](/img/in-post/post-mininet-routing/9.png)

## 결과

아래와 같이, h1과 h3간의 ping에 성공하였다.

![(성공)](/img/in-post/post-mininet-routing/10.png)

 _주관적인 생각이 많이 들어간 포스트입니다. 지적은 언제나 환영입니다!_
