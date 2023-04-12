
# WWDC스터디 6주차 (2023.04.12)

## Introducing Core NFC

## Near Field Communication(근거리 무선 통신)
> 가까운 거리에 있는 장치간에 정보를 교환할 수 있는 무선 기술
    - 몇 센티미터로 제한됨
- NFC텍스트는 다양한 모양, 크기 및 용량으로 제공된다.
- ![](https://i.imgur.com/WnUp4o1.png)
- NFC포럼은 NFC Data Exchange Format을 서로 다른 텍스트 유형 간에 표준화된 방식으로 데이터를 교환하기 위한 공통 메시징 형식으로 정의했다.

1. Core NFC 프레임워크
- NFC Tag Reading
    - 사용자 위치 또는 상황별 콘텐츠에 연결하고 실제 하드웨어를 프로그램과 연결하고 매장 내 제품의 정보 또는 재고 추적을 위해서도 연결할 수 있다.
    - 애플리케이션에서 NDEF형식의 태그를 읽을 수 있다.
    - 아이폰 7부터 지원
    - Core NFC는 쓰기나 포맷은 지원하지 않음

2. 요구사항
i) 자격을 요구하는 기능임
- ![](https://i.imgur.com/3E4Eium.png)

ii) info-plist파일에서 스캔에 대한 권한을 받아야 한다.
- ![](https://i.imgur.com/VOzJSRO.png)

3. 세부정보
i) 태그 읽기는 주문형 프로세스이다.앱이 세션을 사용하여 태그 읽기 활동을 시작해야 한다.

ii) 태그 읽기를 시작하려면 Foreground상태여야 한다.
- 앱이 백그라운드에 있으면 종료되거나 실행안된다.(근데 애플페이는 백그라운드에서도 불려진다. 다른부분일까?)

iii) 태그 읽기 활동은 한번에 60초로 제한된다. 
- 정책을 바꿀순 없는지? 궁금하네요

iv) 단일 태그 혹은 멀티 태그를 읽을수 있도록 세션을 구성할 수도 있다.
- 단일 태그는 태그 이후 바로 종료, 멀티태그는 사용자가 취소하거나 60초 제한 까지 활성화 상태로 유지

V) info.Plist에 정의되s NFC사용 문자열이 사용자에게 표시됨
![](https://i.imgur.com/LXfzgYu.jpg)
(애플페이는 리더기 가까이 들고 있으십시오 인듯합니다.)


4. 샘플 코드
Step1 - NFCNDEFReaderSessionDelegate프로토콜을 채택


Step2 - Create a NFCNDEFReaderSession instance를 생성하고 대리인에게 제공

Step3 - 세션을 시작하고 delegate에서 오는 콜백을 조절함

```swift
import CoreNFC

class MessagesTableViewController: UITableViewController, NFCNDEFReaderSessionDelegate {
    //MARK: NFCNDEReaderSessionDelegate
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        //  태그 읽기 활동이 중지되었을 때 앱에 알립니다
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Process read NFCNDEFMessage objects
        
    }
    
    @IBAction func beginScanning(_ sender: Any) {
        let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidatedAfterFirstRead: true)
        session.begin()
    }
}

```
첫번째 메서드의 session은 함수가 종료된 후 무효화됩니다. 추가로 읽기 위해서는 NFC인스턴스가 추가로 필요하다.

NDEFDetect는 NFC태그에서 NDEF를 읽을때마다 호출된다.
그러면 앱이 NDEF메시지에서 페이로드를 가져와서 디코딩하고 적절하게 메시지를 처리할 수 있다.

NFCNDEFReaderSession인스턴스를 만들ㄱh begin메서드를 사용하여 호출한다.
멀티 세션으로 생성하려면 invalidatedAfterFirstRead매개변수fmf false로설정한다.


### 요약
NFC태그 기능을 활성화하고
info.plist에서 스캔권한을 추가한다 
Core NFC를 앱에 추가한다. 
그리고 태그 읽기를 시작함
