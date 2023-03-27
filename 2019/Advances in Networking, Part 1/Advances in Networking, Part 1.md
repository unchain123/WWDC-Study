# WWDC스터디 4주차 23.03.15
# Advances in Networking, Part 1 (WWDC 2019)

## 1. Low Data Mode(저데이터모드)
- iOS13에서 도입
- 와이파이나 셀룰러 데이터를 사용할 때 데이터를 사용하는 방법에 매우 주의를 기울이고 싶다는 신호를 보내는 것입니다
### 시스템 정책이 바뀜
- 저데이터 모드 네트워크에 있는동안에는 백그라운드 임의 작업을 연기합니다.
- 앱 새로고침이 비활성화됩니다.

### Application Adoption(저데이터 모드를 선택하는 것은 어쩌면 사용자에게 좋지 못한 경험을 제공할 수도 있다. 그래서 어플리케이션에서 채택할 수 있는 기술을 알아봅시다.)
- 이미지가 핵심이 아닌 애플리케이션에서는 이미지 품질을낮춰서 데이터를 절약할 수 있습니다.
- Reduce pre-fetching 
    - 성능을 향상시키는 훌륭한 기술이지만 결국 사용자에게 필요하지 않은 리소스를 가져오게 될 수 있다는 단점이 있습니다. 그래서 이를 줄여서 데이터를 절약할 수 있고 대신 유저는 스크롤을 할 때 조금 더 기다려야 할 수 있습니다.
- Synchronize less often
    - 장기간에 걸쳐 동기화 속도를 줄임으로써 상당한 비용절감 효과를 얻을 수 있습니다.
- Mark tasks discretionary
    - 백그라운드 작업을 임의로 표시합니다. 
- Disable auto-play(자동재생 비활성화)
- 유저가 시작한 일을 막지 마십시오!

### Low Data Mode APIs

#### URLSession
- 저데이터 모드에 있을 때 제한된 프로퍼티로 설정됩니다
- `allowsConstrainedNetworkAccess`라는 프로퍼티가 추가됐습니다. (URLSessionRequest, URLSessionConfiguration에서 설정가능)
- 저데이터 모드에서는 크기가 큰 리소스나 prefetch를 허용하지 않게 합니다.
- 큰 리소스는 더 작은 리소스로 가져오고 Prefetch는 실제로 콘텐츠를 필요로 할 때 까지 기다립니다.
    - 이렇게 되면 이미 캐시에 있을 수 있는 모든 것을 활요할 수 있다는 추가적인 이점이 있습니다.

#### Network.framework
- prohibitConstrainedPaths프로퍼티가 URLSession의 allowsConstrainedNetworkAccess와 비슷한 역할을 하며 true로 설정하여 같은 효과를 낼 수 있습니다.
<img src = "https://i.imgur.com/1SGErnb.png" width=400>

- 결론은 저데이터 모드에서는 네트워크 이용에 제한을 둘 수 있고 값이 비싼 데이터는 최선의 결과를 보여줄 순 있습니다.
- 어떤 네트워크가 가장 비싼지 체크 할 수도 있으며 그것은 지금은 셀루러 데이터이지만 그 후에는 달라 질 수도 있습니다.

## 2. Combine in URLSession
### 검색필드에서 컴바인
<img src = "https://i.imgur.com/dOGEJNN.png" width=200>

- debounce: 일정시간 데이터가 들어오지 않았을 때만 넘어가게 설정
- removeDuplicates: 수신된 마지막 값을 기억하고 값이 변경될 때만 새 값을 전달하게 함
- fliter: 조건 설정가능
- map: searchURL을 맵핑
- sink: 연결

### What is Combine
- 시간이 지남에 따라 프로세스 값을 결합합니다.
<img src = "https://i.imgur.com/eLoWtTX.png" width=400>

- 네트워킹에 컴바인을 채택하는게 완벽하다고 함(perfect라고 단어씀)

### DataTaskPublisher
- 단일 값 퍼블리셔
- URLSession.dataTask(with:completionHandler:) 과 비슷하게 사용됩니다
```swift
public struct DataTaskPublisher: Publisher {
    public typealias Output = (data: Data, response: URLResponse)
    public typealias Failure = URLError
}
```
### Demo(URL캐시를 비활성화하고 진행했음)
<img src = "https://i.imgur.com/jdWHiIf.png" width=400>

<img src = "https://i.imgur.com/fuxgf0t.jpg" width=400>

- 셀을 캡처하고 이미즈를 셀에 비동기적으로 넣는 실수가 생겼다는 사실을 알게 됐습니다.
<img src = "https://i.imgur.com/PlCfSns.png" width=200>
----------------------------------------
### 컴바인을 사용해서 재구성한 코드
- prepareForeReuse에서 subscriber.cancel()

<img src = "https://i.imgur.com/E1uGoZl.png" width=400>


```swift
// Generalized Publisher for Adaptive URL Loading
func adaptiveLoader(regularURL: URL, lowDataURL: URL) -> AnyPublisher<Data, Error> {
     var request = URLRequest(url: regularURL)
     request.allowsConstrainedNetworkAccess = false
     return URLSession.shared.dataTaskPublisher(for: request)
    
     .tryCatch { error -> URLSession.DataTaskPublisher in
         guard error.networkUnavailableReason == .constrained else {
             throw error
        }
         return URLSession.shared.dataTaskPublisher(for: lowDataURL)
                // 여기서 오류를 포착해서 저데이터모드로 작업이 실패하면 저해상도 이미지를 가져옴
     }
    //여기서 의 두 상황을 모두 처리하여 중복코드가 제거된다.
         .tryMap { data, response -> Data in
             guard let httpResponse = response as? HTTPURLResponse,
                 httpResponse.statusCode == 200 else {
                     throw MyNetworkingError.invalidServerResponse
                 }
                 return data
             }
             .eraseToAnyPublisher
}
```
### 데모 정리
#### 컴바인으로 네트워킹 코드를 간결하고 선형적이고 오류를 줄이도록 할 수 있었습니다.
- retry를 지원하지만 낮은 횟수를 사용하고 멱등성 요청만 재시도 하도록 주의

## 3. WebSocket
- 단일 HTTP연결을 통한 양방향 통신을 허용합니다.
- 기존 웹 인프라를 사용하고 이를 애플 플랫폼의 기본앱으로 가져올 수 있습니다.
- 방화벽과 CDNs와 프록시에 연결 가능?

### HTTP/ 1.1 Long-Polling
<img src = "https://i.imgur.com/TzejxPD.png" width=300 >
- 메시지를 보내려는 두 끝점에 모두 HTTP request 나 HTTP response를 보내야 하는데 이것은 많은 오버헤드 입니다.

### WebSocket (Messaging using WebSocket)
- 웹 소캣 핸드셰이크 첫단계는 서버에 이 연결을 웹소켓으로 업그레이드 한다는 요청을 보내는 것입니다.
- 101스위칭 프로토콜로 서버가 응답하고 두끝점 사이에 양방향 스트림이 있습니다.
 
#### URLSessionWebSocketTask
```swift
// Create with URL
let task = URLSession.shared.webSocketTask(with: URL(string: "wss://websocket.example")!)
task.resume()
// Send a message
task.send(.string("Hello")) { error in /* Handle error */ }
// Receive a message
task.receive { result in /* Handle result */ }
```
- 웹소켓용 URLSession API는 completionHandler와 콜백을 기반으로 하는 자바스크립트 API에 더 가깝습니다.

#### NWConnection, NWListener
- 클라이언트 및 서버를 모두 지원
- P2P통신을 위해 확장할 수 있는 메시지 지향 전송 프로토콜을 가질 수 있습니다.
`NWParameters : 연결에 사용할 프로토콜, 데이터 전송 옵션 및 네트워크 경로 제약 조건을 저장하는 개체입니다.`

`NWProtocolWebSocket: WebSocket을 사용하는 연결을 위한 네트워크 프로토콜입니다.`

`NWConnection : 로컬 끝점과 원격 끝점 간의 양방향 데이터 연결입니다.`

`NWConnection : 들어오는 네트워크 연결을 수신하는 데 사용하는 개체입니다.`
```swift
// Create parameters for WebSocket over TLS
let parameters = NWParameters.tls
let websocketOptions = NWProtocolWebSocket.Options()
parameters.defaultProtocolStack.applicationProtocols.insert(websocketOptions, at: 0)

// Create a connection with those parameters
let websocketConnection = NWConnection(to: endpoint, using: parameters)

// Create a listener with those parameters
let websocketListener = try NWListener(using: parameters

```
### Demo
<img src = "https://i.imgur.com/WAvtsIY.png" width=500>

- 웹소켓의 옵션을 생성하고 매개변수의 프로토콜 스택에 설정하도록 변경

| 기존 | 변경|
| :--------: | :--------: | 
| <img src = "https://i.imgur.com/l8mcdqs.png" width=500>     | <img src = "https://i.imgur.com/Z2SMEdN.png" height=100>  | 

- 서버에서 항목 가격이 변경될 때마다 연결된 모든 클라이언트에 WEBSOCKET메시지를 보내는 것을 의미합니다.
- send메서드에 전달하는 데이터는 이 TCB연결에서 바이트 백으로 전송되며 메시지 프레이밍이 없습니다.(???)

- 여기서 컨텍스트를 변경하고 연결된 일부 WEBSocket메타데이터로 새컨텍스트를 생성합니다. 
    - 이것은 데이터를 웹소켓 메시지 프레임으로 보내도록 내연결에 지시합니다.

- connect (웹소켓 연결)
<img src = "https://i.imgur.com/Zw6ZLc4.png" width=300>

- readMessage()
<img src = "https://i.imgur.com/LArvSrl.png" width=300>
- receive메서드를 호출하고 호출에 성공하면 UI를 업데이트 하고 다시 readMessage를 호출합니다

37:22초 (웹소켓으로 실시간 변화를 보여줌)

WebSocket RTT: 클라이언트와 서버간의 왕복시간을 측정

![](https://i.imgur.com/BeP4oRs.png)
- 서버의 경우 프로토콜 스택에 설정된 WebSocket과 함께 NWListener를 사용
- 클라이언트의 경우 URLSessionWebSocketTask를 이용해 서버와 연결
- 전송을 위해 Bidirectional WebSocket Messages를 사용
- 오버헤드가 거의 없는 양방향 메시징
![](https://i.imgur.com/EICDKkQ.png)


## 4. Mobility Improvements
- 집에서 나갈 때나 와이파이 엑세스 포인트에서 멀리 떨어져 있을 때 등등 애플리케이션이 느려지는 경우가 많습니다.
    - 그래서 집에서 나갈 때 와이파이를 끄는데 익숙해졌습니다.(소름돋았다)
    - ~~이걸 없애야 한다고 하시는데 아직 그러는거 보면 앱들이 이걸 지원안하는걸까?~~

![](https://i.imgur.com/CVxqZOK.png)

i) iOS7 : 시리를 사용하고 집에서 나갈 때마다 Multipath TCP는 트래픽이 셀을 통해 와이파이로 이동하도록 하여 시리 사용자의 대기 시간을 줄이고 오류율을 줄입니다. 둘다 킴

ii) iOS9: 와이파이 어시스트는 모든 서버와 통신하면서 모든 흐름에 대해 모든 애플리케이션의 이동성을 처리합니다. 그 방법은 와이파이에서 시작하고 신호가 나쁘고 연결이 되지않으면 빠르게 재설정되고 셀룰러 링크를 통해 다른연결을 올립니다.
- 하지만 이것도 결국 multipath가 필요합니다.
iii) 이 때부터 API를 공개 했습니다. 그래서 handover모드나 interactive모드를 사용할 수 있습니다.
여기까지는 TCP, 시리, 와이파이지원 에만 집중했습니다.

iV) 여기부터는 이동성이 모든 분야에 적용됩니다. 

1. Wi-Fi Assist in iOS 13
<img src = "https://i.imgur.com/hC1Cd4W.png" width=300>
- 시스템의 모든 구성요소가 와이파이 어시스트에 정보를 제공하여 전체 계층간 이동성을 감지하도록 했습니다.

- URLSession이나 NEtwork.framework같은 API를 통해 Wi-Fi Assist를 지원합니다.
- SCNetworkReachability같은 API를 통해 활성 인터페이스 관리를 하고있습니다.
- 데이터 전송이 너무 크거나 트래픽이 사용자 경험에 특별히 중요하지 않아 흐름을 셀에서 멀어지게 조정해야 하는 경우 allowsExpensiveNetworkAccess를 false로 설정할 수 있습니다.
    - 그렇게 하면 셀룰러로 요청하지 않습니다.

2. Multipath Transports
- 길을 찾을 때 집에서 나와 검색을 사용합니다. Apple Maps를 개선하였다고 자랑
- Apple Music용 다중경로 TCP도 활성화했습니다.

### Mulipath Transports for your App
- multipathServiceType URLSessionConfiguration and Network.framework
    - multipathServiceType을 핸드오버나 interactive로 선택할 수 있습니다.

#### Server-side configuration
- Linux Kernel at https://multipath-tcp.org
    - 서버가 올바르게 구성되었는지 확인하십시오.


    ![](https://i.imgur.com/a1VOIGo.png)

