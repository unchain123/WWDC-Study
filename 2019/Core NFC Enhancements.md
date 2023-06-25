# WWDC 스터디 7주차 (2023.04.19)

# Core NFC Enhancements.(WWDC 2019)

## API Changes

### Core NFC Review

#### Session based interface
- Core NFC프레임 워크의 일반적인 구조는 현재와 동일하게 유지됩니다.

#### Tag Reading UI
- 리더 세션이 활성화 될때마다 화면에 나타납니다

#### Tag writing and native access are available in-app
- 새로운 태그 쓰기(수정) 및 기본 태그 엑세스 기능을 앱에서 사용할 수 있습니다.
    - 그러나 백그라운드 태그 검색 기능에는 여전히 NDEF형식의 태그가 필요하며 읽기 전용입니다.

60초 스캔 시간은 그대로 유지 중 입니다.

### **Reader Sessions**

#### New NFCTagReaderSession
- Poll for ISO14443, ISO15693, and/or ISO18092 tags
- Discovery callback provides protocol specific tag objects
- Restart polling
    - 폴링 주기를 중지했다가 다시 시작하여 새 태그를 검색하거나 필요한 경우 다시 연결할 수 있습니다.

#### NFCNDEFReaderSession
- New discovery callback provides NDEF tag objects
- Read and write operations with NDEF tag objects
    - 읽기와 쓰기를 모두 지원하는 세션

### Tag Protocols

#### Basic attributes for all tag objects
- NFCTag
#### Protocols for different tag types
- NFCNDEFTag
- NFCISO07816Tag
- NFCMiFareTag
- NFCISO015693Tag
- NFCFelicaTag
    - 다양한 NFC기술에 익숙하지 않다면 먼저 NDEF에 집중하는 것이 좋습니다.

### General API Usage
- Enable the NFC entitlement in Xcode

<img src = "https://i.imgur.com/VUbftel.png" width= 400>

- 하나는 NDEF용이고 하나는 기본태그 액세스용입니다.

- NFCTagReaderSession, NFCNDEFReaderSession 둘 중 필요한 항목을 결정하고 적절한 세션을 사용해야 합니다.

- 새 태그 객체를 수신하려면 새 프로토콜 delegate 콜백을 구현해야 합니다.
- 태그 개체가 있으면 세션을 사용하여 계속해서 태그에 연결합니다.
- 이때 태그 개체를 사용하여 모든 상호작용을 수행할 수 있습니다.
- 마지막으로 작업이 끝나면 세션을 무효화하고 태그를 해제합니다.

### NFCNDEFReaderSession

```swift
optional func readerSession(_ session: NFCNDEFReadersession,
                            didDetect tags: [NFCNDEFTag ])
````
-> NDEF태그 개체를 수신하려면 위 메서드를 구현해야 합니다.

#### NDEF tag protocol
```swift
var isAvailable: Bool { get }
func queryNDEFStatus (completionHandler: @escaping (NFCNDEFStatus, Int, Error?) -> Void) 
func readNDEF (completionHandler: @escaping (NFCNDEFMessage?, Error?) -> Void) 
func writeNDEF‹_ ndefMessage: NFCNDEFMessage, completionHandler: @escaping (Error?) -> Void) 
func writeLock(completionHandler: @escaping (Error?) -> Void)
```

<img src = "https://i.imgur.com/IKtGJtY.png" width = 500>

```swift
optional func readerSession(_ session: NFCNDEFReadersession,
                            didDetect tags: [NFCNDEFTag ]) {
    let tag = tags.first!
    session.connect(to: tag) { ( error: Error?) in
    // 여기서 세션을 태그에 연결하고 다른 태그에 연결하거나 세션을 무효활 할때까지 연결된 상태로 유지 시키는 것입니다.   
    tag.queryNDEFStatus() { (ndefStatus: NFCNDEFStatus,
                            capacity: Int,
                            error: Error?) in
        let myMessage = NFCNDEFMessage(data: Data())
                   /* 태그에 연결한 후 계속 진행하여 NDEF정보를 쿼리합니다.
             태그가 읽기-쓰기 상태를 반환하면 태그에 새 메시지를 쓸 수 있습니다.
            */             
        tag.writeNDEF(myMessage) { (error: Error?) in
         // 여기서 태그를 업데이트 함
            session.invalidate()       
        // session을 invalidate시키고 NFC작업이 종료되고 세션이 종료됨
            }       
        }
    }
}
````
- 여기까지가 NDEF를 앱에서 읽어오는데 필요한 전부입니다.

> 하지만 NDEF형식이 아닌 태그와 상호 작용해야 하는 몇가지 사례가 있을 수 있습니다. 이를 위해서는 기본 태그 액세스를 사용해야 합니다.

### Native Tag Reading
##### ISO 7816
> 여권과 같은 전자 ID, 엑세스, 스마트 카드와의 접촉, 결제 및 교통 시스템을 포함하여 다양한 사례에 사용됩니다.

APDU명력을 보내고 받을 수 있습니다.

##### Requirements(요구사항)

- 먼저 앱에서 사용하려는 특정 앱의 식별자 또는 AID를 선언하는 항목을 info.plist파일에 추가해야 합니다.
- Core NFC가 태그를 발견하면 해당 태그가 애플리케이션의 info.plist파일에 나열된 AID를 지원하는지 확인하고 일치할때까지 차례로 시도합니다.
- 단, 당분간 결제카드 읽기는 지원하지 않습니다. ??

![](https://i.imgur.com/AX0HmiN.png)

![](https://i.imgur.com/Dzu83MQ.png)

NFCTagReaderSessionDelegate

```swift
@IBAction func beginScanning(_ sender: Any)
    session = NFCTagReaderSession (pollingOption: •iso14443, delegate: self)
// 폴링 옵션을 ISO14443으로 설정
// Type A 및 TypeB태그의 기본 NFC기술입니다.
    session?.alertMessage = "Hold your iPhone near the IS07816 tag to begin
transaction."
session?.begin()
}

func tageReaderSession(_ session: NFCTagReaderSession,
                      didDetect tags: [NFCTag]) {
    if case let NFCTag.iso7816(tag) = tags.first {
        session.connect(to: tag) { error: Error? in
        let myAPDU = NFCISO7816APDU(instructionClass: 0 instructionCode: 0xB0 p1Parameter: 0 p2Parameter:0 data: Data() expectedResponseLength16)
        tag.sendCommand(apdu: myAPDU) { (response: Data,
                                        sw1: UInt8,
                                        sw2: UInt8,
                                        error: Error?) in
            // 연결된 후 헬퍼 클래스를 사용하여 APDU를 생성하고 태그의 동일한 명령 방법을 사용하여 APDU를 전송하고 응답을 받습니다.
            guard error != nil && !(sw1 == 0x90 && sw2 == 0) else { 
        session.invalidate(errorMessage: "Application failure")
                //트랜잭션 중에 애플리케이션 관련 오류가 발생한 것을 발견할 수 있으며 여기서 끊어줄 수 있습니다. 여권을 읽는 중에 적절한 자격 증명이 없거나 하면 이런 시나리오를 표시할 수 있습니다.
                return
        }
            }
        }
    }
}
```
![](https://i.imgur.com/IP5CSrO.png)
![](https://i.imgur.com/FVQFmBI.png)

### MIFARE tag reading(NXP Semiconductors에서 개발한 RFID기술)
> 발권 및 배지 시스템에 많이 사용됨

```swift
@IBAction func beginScanning(_ sender: Any)
    session = NFCTagReaderSession (pollingOption: •iso14443, delegate: self)
    session?.alertMessage = "Hold your iPhone near the IS07816 tag to begin
transaction."
session?.begin()


func tageReaderSession(_ session: NFCTagReaderSession,
                      didDetect tags: [NFCTag]) {
    if case let NFCTag.miFare(tag) = tag.first {
        session.connect(to: tag) { (error: Error?) in
        
        tag.sendMiFareCommand(comandPacket: command) { (response: Data, error: Error?) in                                 
          }
        }
    }
```

### ISO15693
> 소매, 산업 및 의료 응요분야에서 사용됩니다.
#### properties
- identifier(UID)
- icManufacturerCode 제조코드
- icSerialNumber 일련번호

ISO15693은 편의 메서드가 아래와 같이 많습니다. 자세한건 사양을 참조하세요
![](https://i.imgur.com/0VMb4hq.png)

```swift
@IBAction func beginScanning(_ sender: Any)
    session = NFCTagReaderSession (pollingOption: •iso15693,
                                   delegate: self)
    session?.alertMessage = "Hold your iPhone near the IS015693 tag to begin
transaction."
session?.begin()


func tageReaderSession(_ session: NFCTagReaderSession,
                      didDetect tags: [NFCTag]) {
    if case let NFCTag. iso15693(tag) = tags. first {
        session.connect (to: tag) { (error: Error?) in
        tag. readSingleBlock(requestFlags: [.highDataRate, •address],
                             blockNumber:0) { (response:
        Data, error: Error?) in
```

#### FeliCa 
> Sony에서 정의한 형식이며 일본전역에서 많이 사용됨

다똑같고 NFCTag.feliCa(tag)만 바껴서 스킵합니다.

```
1. NDEF는 일종의 데이터 포멧이다, 다양한 종류의 데이터를 NFC를 통해 교환할 수 있도록 구성된 형식. URL, 텍스트, 사진, 동영상 등의 데이터를 NDEF형식으로 구성하여 교환할 수 있다.

데이터를 레코드 형태로 구성한다.

Well-Known Record (잘 알려진 레코드): 미리 정의된 형식으로, 대부분의 NFC 애플리케이션에서 사용됩니다. 예를 들어, URL 또는 텍스트 메시지를 전송할 때 사용됩니다.

MIME Media Record: MIME (Multipurpose Internet Mail Extensions) 형식으로 된 데이터를 저장합니다. 이 형식은 이메일 등에서도 사용되는 표준 데이터 교환 형식입니다.

External Record: 임의의 레코드 유형을 정의할 수 있습니다. 이러한 레코드는 특정 NFC 애플리케이션에서만 사용됩니다.

2. ISO 7816는 칩카드 표준 규격으로, 카드와 카드 리더 간에 통신할 때 사용되는 프로토콜과 인터페이스를 정의한다. 칩카드에서 사용되는 명령어 및 응답 형식, 전기 및 물리적 특성, 보안 기능등을 규정하고 있음
카드와 카드 리더 간의 통신을 관리하기 위한 목적으로 사용됨

3. Type A 태그는 Philips (NXP)사의 MIFARE Classic, MIFARE Ultralight, MIFARE DESFire 등의 제품군에서 사용되는 태그입니다. Type A 태그는 ISO/IEC 14443 Type A 표준을 따릅니다.

4. Type B 태그는 Infineon사의 제품군에서 사용되는 태그입니다. Type B 태그는 ISO/IEC 14443 Type B 표준을 따릅니다.

두 태그 유형은 모두 ISO/IEC 14443 표준을 기반으로 하며, NFC 통신에서 사용되는 두 가지 주요한 프로토콜인 NFC-A와 NFC-B 프로토콜을 따릅니다.

그러나 Type A와 Type B 태그는 서로 다른 무선 통신 프로토콜을 사용하므로, NFC 디바이스는 두 태그 유형을 동시에 지원하기 위해선 두 개의 안테나를 가지고 있어야 합니다. 이러한 이유로, 일부 NFC 디바이스에서는 Type A와 Type B 중 하나만 지원하는 경우도 있습니다.

```


