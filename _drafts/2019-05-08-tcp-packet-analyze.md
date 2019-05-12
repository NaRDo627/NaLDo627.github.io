---
layout: post
title:  "TCP 패킷 분석 실습"
subtitle:  "데이터 통신"
date : 2019-05-08 16:24:07 +0900
author:     "날도"
header-img: "img/post-bg-2015.jpg"
mathjax: true
catalog: true
tags: 
    - 데이터 통신
    - 와이어샤크
    - 과제
---

## 개요

데이터 통신 수업에서 TCP 패킷 분석에 관한 과제를 받았다. 과제 내용은 웹 브라우저에서 HTTP POST 요청 후 Wireshark로 캡쳐, 그 후 질문에 답해야 하는 것이다. <br>  풀어야할 문제는 다음과 같다.

****

1. What is the IP address and TCP port number used by your client computer
(source) to transfer the file to gaia.cs.umass.edu? 
4. What is the sequence number of the TCP SYN segment that is used to initiate the
TCP connection between the client computer and gaia.cs.umass.edu? What is it
in the segment that identifies the segment as a SYN segment?
5. What is the sequence number of the SYNACK segment sent by gaia.cs.umass.edu
to the client computer in reply to the SYN? What is the value of the
Acknowledgement field in the SYNACK segment? How did gaia.cs.umass.edu
determine that value? What is it in the segment that identifies the segment as a
SYNACK segment?
6. What is the sequence number of the TCP segment containing the HTTP POST
command? Note that in order to find the POST command, you’ll need to dig into
the packet content field at the bottom of the Wireshark window, looking for a
segment with a “POST” within its DATA field.
7. Consider the TCP segment containing the HTTP POST as the first segment in the
TCP connection. What are the sequence numbers of the first six segments in the 
TCP connection (including the segment containing the HTTP POST)? At what
time was each segment sent? When was the ACK for each segment received?
Given the difference between when each TCP segment was sent, and when its
acknowledgement was received, what is the RTT value for each of the six
segments? What is the EstimatedRTT value (see Section 3.5.3, page 242 in
text) after the receipt of each ACK? Assume that the value of the
EstimatedRTT is equal to the measured RTT for the first segment, and then is
computed using the EstimatedRTT equation on page 242 for all subsequent
segments.
8. What is the length of each of the first six TCP segments?
9. What is the minimum amount of available buffer space advertised at the received
for the entire trace? Does the lack of receiver buffer space ever throttle the
sender?
10. Are there any retransmitted segments in the trace file? What did you check for (in
the trace) in order to answer this question?
11. How much data does the receiver typically acknowledge in an ACK? Can you
identify cases where the receiver is ACKing every other received segment (see
Table 3.2 on page 250 in the text).
12. What is the throughput (bytes transferred per unit time) for the TCP connection?
Explain how you calculated this value.
13. Use the Time-Sequence-Graph(Stevens) plotting tool to view the sequence
number versus time plot of segments being sent from the client to the
gaia.cs.umass.edu server. Can you identify where TCP’s slowstart phase begins
and ends, and where congestion avoidance takes over? Comment on ways in
which the measured data differs from the idealized behavior of TCP that we’ve
studied in the text.
14. Answer each of two questions above for the trace that you have gathered when
you transferred a file from your computer to gaia.cs.umass.edu

****

## 실습 과정



## 문제 풀이
#### 1\. What is the IP address and TCP port number used by your client computer (source) to transfer the file to gaia.cs.umass.edu?<br> (gaia.cs.umass.edu(이하 서버)에 파일을 전송한 클라이언트 컴퓨터의 IP 주소와 TCP 포트번호는 무엇인가?)

#### 2\. What is the sequence number of the TCP SYN segment that is used to initiate the TCP connection between the client computer and gaia.cs.umass.edu? What is it in the segment that identifies the segment as a SYN segment?<br> (클라이언트와 서버 사이의 TCP 연결을 초기화할 때 사용된 TCP SYN 세크먼트의 시퀀스 넘버는 무엇인가? SYN 세그먼트임을 식별하게 해주는 것은 무엇인가?)

#### 3\. What is the sequence number of the SYNACK segment sent by gaia.cs.umass.edu to the client computer in reply to the SYN? What is the value of the Acknowledgement field in the SYNACK segment? How did gaia.cs.umass.edu determine that value? What is it in the segment that identifies the segment as a SYNACK segment?<br>(서버에서 클라이언트로 SYN의 응답으로서 전송된 SYNACK 세그먼트의 시퀀스 넘버는 무엇인가? SYNACK 세그먼트의 Acknowledgement 필드의 값은 무엇인가? 서버가 어떻게 그 값을 판단하는가? 그 세그먼트가 SYNACK 임을 식별하는 것은 무엇인가?)

#### 4\. What is the sequence number of the TCP segment containing the HTTP POST command? Note that in order to find the POST command, you’ll need to dig into the packet content field at the bottom of the Wireshark window, looking for a segment with a “POST” within its DATA field.<br>(HTTP POST 명령에 포함되어있는 TCP 세그먼트의 시퀀스 넘버는 무엇인가?)

#### 5\. Consider the TCP segment containing the HTTP POST as the first segment in the TCP connection. What are the sequence numbers of the first six segments in the TCP connection (including the segment containing the HTTP POST)? At what time was each segment sent? When was the ACK for each segment received? Given the difference between when each TCP segment was sent, and when its acknowledgement was received, what is the RTT value for each of the six segments? What is the EstimatedRTT value (see Section 3.5.3, page 242 in text) after the receipt of each ACK? Assume that the value of the EstimatedRTT is equal to the measured RTT for the first segment, and then is computed using the EstimatedRTT equation on page 242 for all subsequent segments.<br>()

#### 6\. What is the length of each of the first six TCP segments?<br>

#### 7\. What is the minimum amount of available buffer space advertised at the received for the entire trace? Does the lack of receiver buffer space ever throttle the sender?<br>

#### 8\. Are there any retransmitted segments in the trace file? What did you check for (in the trace) in order to answer this question?<br>

#### 9\. How much data does the receiver typically acknowledge in an ACK? Can you identify cases where the receiver is ACKing every other received segment (see Table 3.2 on page 250 in the text)?<br>

#### 10\. What is the throughput (bytes transferred per unit time) for the TCP connection? Explain how you calculated this value.<br>

#### 11\. Use the Time-Sequence-Graph(Stevens) plotting tool to view the sequence number versus time plot of segments being sent from the client to the gaia.cs.umass.edu server. Can you identify where TCP’s slowstart phase begins and ends, and where congestion avoidance takes over? Comment on ways in which the measured data differs from the idealized behavior of TCP that we’ve studied in the text.<br>

#### 12. Answer each of two questions above for the trace that you have gathered when you transferred a file from your computer to gaia.cs.umass.edu<br>

 _주관적인 생각이 많이 들어간 포스트입니다. 지적은 언제나 환영입니다!_

> 출처 : http://www-net.cs.umass.edu/wireshark-labs/Wireshark_TCP_v7.0.pdf