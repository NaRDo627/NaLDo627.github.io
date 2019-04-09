---
layout: post
title:  "HTTP 분석 실습"
subtitle:  "데이터 통신"
date:   2019-04-08 17:00:00 +0900
author:     "날도"
header-img: "img/post-bg-2015.jpg"
catalog: true
tags: 
    - 데이터 통신
    - HTTP
    - Websocket
    - 과제
---

## 개요
데이터 통신 과제로 wireshark를 사용한 HTTP 분석 과제 레포트를 작성하게 되었다.

## WebSocket Client 제작
PPT의 내용을 참고, Javascript로 온라인 에코서버 (ws://echo.websocket.org)로 요청하는 테스트 WebSocket Client를 제작하였다.

```html

<!DOCTYPE html>
<meta charset="utf-8" />
<title>WebSocket Test</title>
<script language="javascript" type="text/javascript">
    var wsUri = "ws://echo.websocket.org/";
    var output;
    var loopCount = 0;

    function init() {
        output = document.getElementById("output");
        testWebSocket();
    }

    function testWebSocket() {
        websocket = new WebSocket(wsUri);
        websocket.onopen = function (evt) { onOpen(evt) };
        websocket.onclose = function (evt) { onClose(evt) };
        websocket.onmessage = function (evt) { onMessage(evt) };
        websocket.onerror = function (evt) { onError(evt) };
    }

    function onOpen(evt) {
        writeToScreen("CONNECTED");
        doSend("Hello " + loopCount.toString());
    }
function onClose(evt) {
        writeToScreen("DISCONNECTED");
    }

    function onMessage(evt) {
        writeToScreen('<span style="color: blue;">RESPONSE: ' +
            evt.data + '</span>');

        if (loopCount < 10) {
            doSend("Hello " + loopCount.toString());
            loopCount = loopCount + 1;
        }

        else {
            websocket.close();
        }
    }

    function onError(evt) {
        writeToScreen('<span style="color: red;">ERROR:</span> ' + evt.data);
    }

    function doSend(message) {
        writeToScreen("SENT: " + message);
        websocket.send(message);
    }

    function writeToScreen(message) {
        var pre = document.createElement("p");
        pre.style.wordWrap = "break-word";
        pre.innerHTML = message;
        output.appendChild(pre);
    }
    window.addEventListener("load", init, false);
</script>

<h2>WebSocket Test</h2>
<div id="output"></div>


```

## Wireshark Filter 설정 및 캡쳐

Wireshark 상에서 Filter를 적용 후, Sniffing 상태로 둔다. 그 상태에서, 1번에서 작성한 WebSocket Client 를 사용해 요청한다.<br>
(적용된 Wireshark Filter : tcp.port == 80 && ip.addr == 174.129.224.73)<br>
(TCP Port 80포트와 ip 주소 중 174.129.224.73, 즉 websocket.org 주소만 포함)<br>
WebSocket.html 실행 : 

![(실행화면1)](/img/in-post/post-http-analyze/1.png)

Wireshark 캡쳐 : 

![(실행화면2)](/img/in-post/post-http-analyze/2.png)

위와 같이 에코서버와 주고받은 패킷이 캡쳐 되었다.

## 패킷 통신 분석

WireShark PPT 상의 문제는 아래와 같다.<br>
Q1. Do you find ‘hello’?<br>
Q2. Can you find Web-socket handshake?<br>
Q3. Explain handshake procedure and Web-socket header and its fields.<br>
WebSocket Protocol: (이미지 출처: Wireshark PPT)<br>
아래의 그림을 3단계로 나누어 볼 수 있다.

![(3단계)](/img/in-post/post-http-analyze/3.PNG)

1번 영역은 세션 연결, 2번 영역은 세션 내에서 데이터 교환, 3번 영역은 세션 종료로 볼 수 있다.<br>
다음은 Wireshark에서 캡쳐 된 패킷의 일부이다.

![(캡쳐패킷)](/img/in-post/post-http-analyze/4.PNG)

위 그림의 A영역에서, 클라이언트(192.9.116.228)가 에코서버(174.129.224.73)로 [SYN] 패킷, 서버에서 클라이언트로 [SYN, ACK] 패킷, 클라이언트가 서버에게 다시 [ACK]을 전송한 것으로 보아 3-way handshake, 즉 TCP 세션 연결이 이루어졌음을 알 수 있다. (Q2의 Answer)<br>
 B영역에서는, 먼저 클라이언트가 서버로 HTTP 요청을 보낸 후, 서버 쪽에서 TCP [ACK] 응답과 함께 Web Socket Handshake를 통해 연결이 성공했음을 HTTP 헤더를 통해 알려준다는 것을 알 수 있다<br>
HTTP 요청 헤더를 좀 더 자세히 살펴보았다:

![(캡쳐패킷)](/img/in-post/post-http-analyze/5.PNG)

HTTP 헤더의 request line은 동일하나, 헤더 중 “Upgrade: websocket” 헤더를 찾을 수 있었다. 이 헤더를 통해 이 요청이 단순한 GET 요청이 아닌 WebSocket session을 열기위한 요청임을 알 수 있다.
이번엔 응답 헤더이다:

![(응답헤더)](/img/in-post/post-http-analyze/6.PNG)

Status line이 HTTP/1.1 101 Web Socket Protocol Handshake으로 왔다. RFC 7231 문서(<https://tools.ietf.org/html/rfc7231#section-6.2.2>)에서 101응답은 Switching Protocols로 서버가 클라이언트의 요청의 upgrade 헤더를 통해 어떤 프로토콜을 사용할 것인지 알아듣고 그 프로토콜을 사용할 준비가 되어있다는 것을 의미한다고 한다. 즉 서버는 이 응답을 보냄으로써 WebSocket Session이 열렸음을 알려준다. (Q3 중 Explain handshake procedure의 Answer)

![(데이터주고받기)](/img/in-post/post-http-analyze/7.PNG)

위 그림에서는 WebSocket 데이터를 주고받았음을 알 수 있다. <br>
그 중 요청 패킷 하나를 열어 보았다.

![(패킷 자세히)](/img/in-post/post-http-analyze/8.PNG)

위 패킷 중 WireShark에 의해 파싱된 데이터를 통해 바이너리 데이터 중 빨간색으로 표시된 부분이 TCP, 파란색으로 표시된 부분이 WebSocket임을 알 수 있다. <br>
WebSocket Header (이미지 출처 : WireShark PPT)<br>

![(패킷 도표)](/img/in-post/post-http-analyze/9.png)

FIN 은 플래그 비트로, 전송이 성공적으로 완료되었는지 여부를 나타내는 비트이고, RSV 비트는 미리 예약된 비트로 보인다. Opcode는 명령코드, MASK는 플래그비트로 MASK의 사용 여부를 나타낸 비트이다. Payload len 비트는 Payload, 화물, 즉 적재된 데이터의 길이이다. Extended payload length 비트는 만약 payload가 7비트로 나타낼 수 있는 크기를 넘어갈 때를 대비해 예약된 비트로, Payload len이 126/127일 경우에만 사용된다. Masking-key는 MASK 비트가 1일 때만 사용되며, Payload Data를 마스킹 할 때 사용된다(RFC 문서에 따르면, 클라이언트는 서버로 요청 시 Payload Data를 마스킹 처리해야 한다고 나와있다. 일부 프록시에 의해 데이터가 변조되는 것을 방지하기 위함이라고 한다). Payload는 요청되는 데이터이다. 여기서는 Hello 메시지가 마스킹되어 제대로 보이지 않는다.<br>
 다음은 응답 패킷을 열어 보았다.

 ![(패킷 자세히2)](/img/in-post/post-http-analyze/10.PNG)

 대부분 요청 패킷과 일치하였지만 MASK 플래그는 FALSE로, PAYLOAD가 마스킹 처리 되지 않고 그대로 오는 것을 알 수 있다(Q1, Q3의 Answer).
Echo 서버이기 때문에 요청한 데이터와 동일한 데이터가 되돌아온다.
 
 ![(패킷 주고받기2](/img/in-post/post-http-analyze/11.PNG)

위 그림에서는 클라이언트가 서버에게 Connection Close 패킷을 보내서 연결을 종료하겠다고 알리고 있다. 서버는 Connection Close 패킷을 클라이언트에게 보냄으로써 세션이 종료되었음을 알린다. 이렇게 WebSocket 세션이 종료된 후, 서버는 클라이언트에게 [FIN, ACK] TCP 패킷을 전송하여 세션이 종료됨을 알린다. 계속하여 클라이언트는 서버에게 [ACK], [FIN, ACK]를 전송하고 이를 받은 서버는 [ACK] 패킷으로 응답하여 TCP 연결이 종료되었음을 알린다. (4-way handshake)

## 느낀 점
우리가 흔히 사용하는 웹을 WireShark를 이용해 TCP, HTTP 패킷이 오가는 모습을 관찰할 수 있어서 흥미로웠다. 또한 하나의 패킷을 열어 안의 binary 데이터는 물론, 파싱된 데이터를 한 눈에 보여줄 수 있다는 점이 WireShark의 큰 강점이 아닌가 생각된다. 이러한 강력한 네트워크 분석 툴을 통해 통신 간 모니터링 및 트러블슈팅이 가능할 것으로 본다.