# WWDC스터디 3주차 23.03.08
## Networking with NSURLSession

## Background
1. NSURLSession
- 주로 웹에서 콘텐츠, HTTP 콘텐츠를 다운로드 하는데 사용된 네트워킹 API입니다.
- 가장 큰 특징 중 하나는 백그라운드 다운로드 API를 통해 앱이 실행 되지 않는 동안에도 네트워킹을 할 수 있다는 것입니다.

<img src="https://i.imgur.com/dv08awf.png" width=300>
#### HTTP
기본적인 핵심은 서버에 요청을 하고 응답으로 데이터를 가져오는 것입니다.

#### HTTPS
- 앱에서 나가는 데이터를 가져가기 위한 잠재적인 위험이 많기 때문에 우리는 해결책을 찾았습니다..
- HTTPS는 전송계층 보안으로 알려진 계층화된 HTTP입니다.
- 전송계층 보안은 공개 키 암호화(키페어: 공개키를 통해 비밀키를 암호화 하고 복호화 한다.) 를 사용하여 다중 레그 핸드셰이크를 수행하고 완료되면 보안 연결을 생성합니다.


🙂 HTTPS가 안전한 이유?
1. **Encryption**: 첫번째는 앱에서 나가는 데이터가 암호화된 네트워크를 통해 이동한다는 것입니다.
2. **Integrity**: 두번째는 메시지 무결성을 제공하므로 메시지가 감지되지 않고는 변경될 수 없습니다.
3. **Authentication**: 마지막으로 세번째는 인증을 제공하여 통신중인 사람의 신원을 실제로 증명할 수 있습니다.

- 데이터는 민감하게 간주해야 하며 앱에서 네트워크로 나가는 데이터가 민감하지 않다고 생각하더라도 고객은 실제로 민감하다고 생각할 수 있기 때문입니다.

## App Transport Security(ATS)
- iOS 9 및 OS X, El Capitan에서 추가된 새로운 기능
    - 고객의 데이터가 실수로 공개되는 것을 방지하는데 도움이 됩니다.
<img src="
https://i.imgur.com/VpsCj4W.png" width=300>
```
! 여기서 가장 중요한 측면은 NSURLSession이 
기본적으로 일반 텍스트 HTTP로드를 허용하지 않는다는 것입니다.
```
- ATS는 앱 Info.plist를 통해 간단하게 구성된다.
![](https://i.imgur.com/t42NYps.png)
영상에선 이렇게 되어있는데 지금은 바뀐거 같다.
![](https://i.imgur.com/AkHR5OL.png)
디폴트 값은 NO이다. 보안되지 않은 URL은 막는다는 뜻이고 사진처럼 YES로 설정하게 되면 모든 HTTP주소를 허용하겠다는 뜻이다.
하지만 모든 보안되지 않은 주소가 허용되는것은 위험하기 때문에
![](https://i.imgur.com/AUa8VgK.png)
이처럼 특정 URL만 허용하는 방법을 사용하는 것이 좋습니다.
반대로 모두 오픈하고 특정도매인만 허용하지 않는 방법으로 할 수도 있습니다.
```
ATS는 사용자가 네트워크로 무엇을 하려는지 실제로 설명하기를 원하며, 우리는 사용자가 앱의 보안에 대해 덜 걱정하고 올바른 작업을 수행하기 위해 시스템에 더많이 의존하기를 원합니다.
```

- URLSession은 http를 https로 자동으로 바꿔서 로드합니다.

## CF Network Diagnostics(Debuggin Tool)
- ![](https://i.imgur.com/LvREjCY.png)
    - CF네트워크 진단을 수준 1로 설정하면 실패한 모든 URL이 로드 되므로 실패한 모든 로드는 URL과 기본 TLS오류를 기록합니다.

## Protecting Customer Data
- Use HTTPS for new project
- Transition existing apps from HTTP to HTTPS
- Use exceptions where needed


## HTTP/2 in NSURL Session
- HTTP/2프로토콜을 지원한다.
- 앱 코드의 변경없이 그대로 사용이 가능하다.

### Why a new protocol
#### Common issues
1. One outstanding request
HTTP/1.1 문제 중 가장 유명한 문제는 TCP연결당 하나의 미해결 요청 문제입니다. 

2. HTTP pipelining
- 1번에 대한 해결책이 파이프라이닝이었지만 사용안되는 웹사이트가 훨씬 많습니다.

3. Multiple connections
- 호스트에 다중 연결을 여는것입니다.

4. Textual protocol overhead
- 이렇게 하면 여러 리소스를 빠르게 가져오는데 도움이 되지만 텍스트 프로토콜 오버헤드, 헤더 압축 부족과 같은 다른요소와 함께 시스템 요구사항이 높아지고 클라이언트와 서버 모두에서 성능이 저하됩니다.
 
5. Header Compression

작년에 NSURL Session에 SPDY지원을 도입했었다 (웹을 더 빠르게 하기 위함)
- 그래서 올해 HTTP/2를 지원하게 되었다.
    - HTTP/2는 호스트에 대해 하나의 TCP연결만 엽니다.
    - 클라이언트와 서버 모두 리소스가 적게 필요
![](https://i.imgur.com/kBcecSA.png)

- HTTP/2는 완전 다중화가 되고 새 요청이 이전 요청의 응답을 기다릴 필요가 없습니다.
- 요청 우선순위를 줄 수 있습니다.

## HTTP/2 멀티플렉싱 
```
HOL(Head-of-Line) 차단 문제를 해결하는
방법을 살펴보겠습니다.
```
<img src="https://i.imgur.com/Qs72iFM.png" width=300>

- 기존에는 동기적으로 진행 됐었다.

<img src="https://i.imgur.com/Mx3Tiu7.png" width=300>

- 파이프라이닝을 사용하면 요청은 응답을 기다리지 않고 보낼 수 있지만 응답을 받는 순서는 여전히 똑같다.

![](https://i.imgur.com/Tc5zpkw.png)
- HTTP/2는 바이너리 데이터 이기 때문에 데이터 처리 및 구문 분석이 더 빨라집니다.
 
![](https://i.imgur.com/x7aP6GP.png)
- 헤더 압축위해 보다 안전한 메커니즘인 HPACK을 사용

## HTTP/2 Header Compression(HPACK)
![](https://i.imgur.com/DDZpgSI.png)

## HTTP/2 (Adoption on the client)
![](https://i.imgur.com/pxRn54z.png)
- 이전에 사용하던 코드를 그대로 사용하더라도 HTTP/2를 서비스 할 수 있다고 설명함

- NSURL Session은 암호화된 연결을 통해서만 HTTP/2프로토콜을 지원합니다

- HTTP/2 서버는 ALPN or NPN을 지원해야 합니다.

- HomeKit원격 액세스는 HomeKit액세서리와 ICloud간의 통신에 HTTP/2 프로토콜을 사용하고 있습니다.

----------------------------------------
# NSURLSession on watch OS
- watchOs에서 HTTPS가 완벽하게 로드되게 지원됩니다.
- 사용자의 시계가 페어링된 iPhone 근처에 있을 경우 전화에서 HTTP load를 수행하고 결과를 BLUEtooth를 통해 시계로 다시 전달함을 의미합니다.


## Best practices

1. 최소크기의 에셋만 다운로드하려고 시도해야합니다
- 워치는 화면이 작다
- 밴드의 넓이에도 제한이 있다.
    - 그래서 이미지를 아이폰이나 맥에 표시하려는 전체 해상도의 이미지를 다운로드할 필요가 없다

2. 시계의 앱은 일반적으로 아이폰앱이나 맥앱보다 훨씬 짧은 시간동안 실행된다는 것입니다.
- 따라서 기본 Session구성 또는 임시 Session구성을 사용하는 경우 이러한 네트워킹 전송은 앱이 실제로 실행되는 동안에만 발생한다는 점에 유의하세요
- 소량의 데이터 전송은 괜찮지만 비디오 같은 더 큰 콘텐츠의 경우 백그라운드 업로드 또는 다운로드를 사용하는게 좋다.

## API Changes

### NSURLConnection
- Deprecated 됐다 (어쩐지 이게 뭔가 싶었지..)
- 계속 작동은 하지만 새 기능은 다르게 NSURLSession에서만 된다.
- 워치OS에서 안된다
**기존 코드**
![](https://i.imgur.com/ZPNC84E.png)

**변경 코드**
![](https://i.imgur.com/jchgc1i.png)

- 여기서 다른점은 NSURLConnection로 비동기요청을 보내는 대신 dataTaskWithRequest를 사용한다는 것입니다.

## New NSURLSesssion API

### Sharing Cookies
![](https://i.imgur.com/6az5w7i.png)
- 새로운 쿠키 저장소를 identifier를 통해 공유하는 방법입니다.
- 애플리케이션 그룹의 이름을 전달하여 쿠키 저장소를 생성하기만 하면 엑스코드에서 프로젝트의 빌드 설정을 편집하고 Capabilities탭으로 이동하는 동안 애플리케이션 그룹을 구성할 수 있습니다.

- 쿠키 저장소를 만든 후 NSURLSession구성 개체에서 HTTP쿠키 저장소 속성으로 설정하고 NSURLSession에 넣어서 만든 다음 쿠키를 사용하기만 하면됩니다

- 채팅응용프로그램이나 화상통화 응용프로그램과 유사한 것을 구현하는 경우 HTTP가 아닌 프로토콜이 필요할 수 있습니다.


## NSURLSessionStreamTask(NSStream이었나봄)
TCP/IP networking

1. 매우 간단하고 편리한 비동기식 읽기 및 쓰기 인터페이스를 제공합니다

2. NSURLSessionStreamTask 자동으로 HTTP프록시를 통과하는 훌륭한 기본 제공 지원 기능을 갖추고 있다.
    - 서버 사이에 HTTP프록시가 있는경우에도 원격서버에 연결할 수 있다. 이전엔 안됐다

3. NSURLSessionStreamTask는 기존 NSURLSession구성 옵션 및 델리게이트 메서드를 사용하여 이벤트를 사용자에게 전달합니다.

![](https://i.imgur.com/b2prLZk.png)

스트림작업을 만들려면 호스트 이름 및 포트가 있는 스트림 작업 메서드를 사용하면 됩니다. 그리고 연결할 호스트 이름과 포트를 전달하기만 하면됩니다.
그런 다음 task.resume()을 한 뒤 최소길이 최대길이 시간초과등의 데이터를 읽어오는 방법을 사용할 수 있습니다.

![](https://i.imgur.com/43cRfiG.png)

- NSStream과 달리 NSData로 직접 작업할 수 있습니다. 
- 쓰기를 원하는 NSData객체와 해당 작업에 대한 시간제한을 전달하면 됩니다.


## Enabling TLS

![](https://i.imgur.com/WzArvq8.png)

TLS를 활성화하는 것은 start Secure Connection 메서드를 호출 하는 것 만큼 간단하다
(번역 그대로 한건데 이걸 추가하면 TLS를 활성화 시킨다는 뜻인것 같아요)


## NSURLSessionStreamTask

```swift
let streamTask: NSURLSessionStreamTask = ..

streamTask.captureStreams()
```
NSStreams를 NSURLSessionStreamTask에서 captureStreams 메서드를 호출하면 아주 쉽게 변환할 수 있다고 설명함
호출만 하면 delegate메시지와 함께 전달됩니다.
![](https://i.imgur.com/uo9yEqV.png)

- 셀룰러 데이터가 연결되어있는 상황에서 와이파이 네트워크를 수신할 경우에 더 좋은 네트워크가 있다고 알림을 보냅니다
- 이상황에서 원하는 경우 기존 스트림 태스크를 해체하고 해당 호스트 및 포트에 새 스트림 태스크를 생성한 다음 더 나은 연결을 통해 연결을 시도할 수 있습니다.
![](https://i.imgur.com/ThpTpVK.png)

![](https://i.imgur.com/giYBbxR.png)
TCP연결을 읽거나 쓸때 닫혔는지 알려주는 Delegate메서드도 있습니다.

![](https://i.imgur.com/YwG8QGB.png)
- DataTask를 Stream작업으로 변환하려면 위와 같이 CompletionHandler(.BecomeStream)메서드를 사용하기만 하면됩니다

## Summary
![](https://i.imgur.com/tvJKEym.png)


