# [What's New in Notifications](https://developer.apple.com/videos/play/wwdc2015/720/)

## Notification
- iOS Notification
- Apple Push Notification Service (APNS)

<br>

## iOS Notification

### silent notification 
- 무음이라 전화를 울리지 않습니다.
- 사용자에게 알리는데 사용하지 않고, 자신의 앱에 알리는데 사용합니다.
- 백그라운드에서 앱을 리프레시 하기 위한 도구로 UI를 보여주지 않습니다.
- 원격 알림이라 인터넷에서 왔습니다.
- 기본적으로 활성화 되어 있어 사용자에게 권한을 요청하지 않고 바로 사용을 시작할 수 있습니다. (자동알림)
    - 자동알림은 언제든지 사용자가 설정에서 비활성화 할 수 있으므로 항상 사용할 수 있는 것은 아닙니다.
    - 사용자가 알림을 끈지 알 수 없습니다. 
- 시스템 상황에 따라서(배터리 상태, 현재 시간 등) 전달되는 시간이 다를 수 있습니다 
    - Best Effort

### user notification
- 알림 시 진동이 울릴 수 있습니다.
- 사용자에게 무언가를 알리고 싶을때, 서버에서 또는 앱의 다른 사용자로부터 발생한 무언가를 알리고 싶을 때 사용합니다.
- 사용자 페이지, 배너, 잠금 화면, 알림 센터에 표시됩니다.
- 사용자 허가가 필요합니다.
    - 언제든지 비활성화도 가능하며, 사용자가 설정을 변경할 수 있습니다.
- 시간이나, 지역(Geofences)로 알림을 예약할 수 있습니다.

## User notification 더 알아보기

### 종류
1. remote notification
- 인터넷 서버에서 보낸 것입니다.
- 사용자가 알림을 누를 때만 앱이 실행됩니다.

2. local notification
- 로컬 알림은 사용자의 기기에서 직접 앱에 의해 예약됩니다.
- 서버(인터넷)이 없습니다.
- 원격과 마찬가지로 앱에서 알림을 예약합니다.

### User notification Actions

<img src="https://i.imgur.com/yosJd6c.png" width="200" height="250"/>

- iOS 8부터 도입되었습니다.
- 알림을 대화형으로 만들 수 있습니다.
    - 앱을 시작하지 않아도 앱과 상호작용 할 수있습니다.
- 진동 알림이 가능합니다.
- 사용자가 시계를 착용하고 있고 장치와 페어링 되어 있으면 별도의 작업없이 시계에서도 작동합니다.

### User notification Text Input

<img src="https://i.imgur.com/cAOD3sJ.jpg" width="400" height="250"/>

- iOS 9에서는 사용자 알림 텍스트 입력을 도입하여 자신의 앱에서 동일한 UI와 동일한 대화형 알림을 사용할 수 있습니다.

### Text input Action
1. 만드는 법 (10:34 ~)

<img src="https://i.imgur.com/NjftYZT.png" width="400" height="150"/>

<br>
<br>

<img src="https://i.imgur.com/6E1QRBy.jpg" width="400" height="150"/>

<br>
<br>

2. 기존 방식과 다른점
- 동작을 텍스트 입력 동작으로 설정하여 디바이스가 알림을 수신하고 텍스트 입력 동작이 포함된 새 동작이 있을 때 텍스트 필드를 표시할 수 있다는 것

## Apple Push Notification Service (APNS)

### APNS 흐름

<img src="https://i.imgur.com/4Q0NMfy.jpg" width="400" height="250"/>

1. 클라이언트 앱 -> 운영체제
- 클라이언트 앱에서 운영 체제로 알림을 수신하도록 등록합니다.

2. 운영체제 <-> APNS
- 운영 체제는 APNS에서 클라이언트 앱에 고유한 장치 토큰을 가져 옵니다. 

3. 운영체제 -> 클라이언트 앱
- 클라이언트 앱으로 다시 돌아옵니다.

4. 클라이언트 앱 -> 공급자
- 전송을 담당하는 서버인 공급자에 원격 알림을 등록합니다.

5. 공급자 -> APNS
- 인증서가 있으면 APNS에 대한 클라이언트 SSL 연결을 설정하고 APNS 공급자 API를 사용하여 원격 알림을 보낼 수 있습니다.
- 인증서는 Apple 개발자 포털에서 받을 수 있습니다.

### APNS에 대해 더 알아보기
- APNS에서 제공하는 API는 오버헤드가 매우 적은 매우 빠르고 매우 고성능인 서버 API라고 합니다. 
- 단일 연결을 사용하여 많은 수의 푸시 알림을 보낼 수 있습니다.
- 더 높은 처리량을 위해 원하는 경우 APNS에 대한 많은 연결을 만들 수 있습니다.
- 알림 전송을 완료한 후에는 연결을 그대로 두고 다시 사용할 수 있습니다.
- APNS는 연결을 즉시 끊지 않기 때문에 나중에 새롭게 연결을 설정하는데 비용을 내지 않아도 됩니다.
- 연결에 오류가 있는 경우 APNS는 오류 코드를 반환하고 연결을 닫습니다.

### 피드백 서비스 (Feedback Service)

<img src="https://i.imgur.com/N8fOPNB.png" width="400" height="250"/>

- 피드백 서비스는 리소스를 낭비하지 않게 해주는 방법입니다.
- 장치 토큰에 알림을 보내고 APNS가 장치 토큰이 더 이상 활성화되지 않음을 발견하면 이를 APNS 피드백 서비스에 저장합니다.
- 그러면 공급자는 주기적으로 APNS 피드백 서비스를 가져오고 유효하지 않은 장치 토큰을 검색하고 데이터베이스를 정리할 수 있습니다.

### 장치 토큰(Device Tokens)
- 2015년 장치 토큰은 최대 32바이트까지 입니다.
- 2016년에는 최대 100바이트까지 성장할 예정입니다.

<br>

## 새로운 공급자 API (New Provider API)

### 주요 기능
1. HTTP/2
- 새로운 공급자 API는 새로운 HTTP/2 산업 표준 위에 구축되었습니다.
- HTTP/2 사용했을 때 이점
    - 재응답
    - 다중 프로토콜
    - 바이너리 

2. 즉각적인 피드백
- 즉각적인 피드백을 사용하면 애플리케이션에 대해 더 이상 활성화되지 않은 장치 토큰을 얻기 위해 별도의 피드백 서비스에 문의할 필요가 없다고 합니다.
- 기존에는 공급자의 APNS 피드백에서 주기적으로 폴링해야 했지만, 이제는 응답에서 피드백을 받을 수 있습니다.
- 응답이 400번대라면 장치 토큰이 더 이상 애플리케이션에 대해 활설 상태가 아님을 의미하므로, 더 이상 알림을 보내지 않도록 정리할 수 있습니다.

3. 간소화된 인증서 처리
- 기존에는 애플리케이션 주제에 대해 각각 인증서가 있었습니다.
    - Application 용
    - VOIP 용
    - Watch Complicatin 용 등.. 
- 이제는 애플리케이션의 모든 푸시에 단일 인증서를 사용할 수 있습니다.

### 이전 버전보다 좋아진 점
- 푸시 페이로드 크기가 4KB가 되었습니다.
- 새로운 공급자 API를 사용하여 모든 버전의 iOS 및 OS X에 알림을 보낼 수 있습니다.
- 버전 호환성을 위해 특별한 논리를 만들 필요가 없습니다.

### 새로운 공급자 API 흐름

<img src="https://i.imgur.com/xaLk41U.png" width="400" height="250"/>

### Provider API 더 알아보기

<img src="https://i.imgur.com/GTvRdif.png" width="500" height="250"/>

1. 연결
- 공급자에서 APNS로 연결을 설정합니다.
- 그러면 현재 공급자 API와 동일한 클라이언트 인증서를 사용합니다.
- 해당 인증서를 사용하여 APNS에 대한 클라이언트 인증 SSL 연결을 설정할 수 있으며 연결이 설정되는 즉시 설정 프레임을 교환하여 HTTP/2가 시작됩니다.
- 설정 프레임에는 해당 연결을 통해 발행할 수 있는 동시 요청 수 또는 헤더 테이블 매개변수 크기 등과 같은 세부 정보가 포함됩니다.
- 설정 프레임이 교환되는 즉시 제공자로부터 설정 프레임을 전송하는 즉시 알림 데이터, 알림 요청 전송을 시작할 수 있습니다.

<img src="https://i.imgur.com/PM0ghYY.png" width="500" height="250"/>

<br>
<br>

<img src="https://i.imgur.com/6yKHBag.png" width="400" height="250"/>

<br>
<br>

<img src="https://i.imgur.com/4e04SGh.png" width="400" height="250"/>

2. 요청
- 여기서 HTTP/2 다중화를 활용합니다.
- 요청이 여러 개 있고 보내려는 알림이 여러 개인 경우 동일한 연결에서 모두 보낼 수 있습니다.
- 요청이 실패한 경우, 이유와 함께 "잘못된 장치 토큰"이라고 표시되지만 연결은 유지됩니다.

<br>

## 마무리

<img src="https://i.imgur.com/t5Jyrho.png" width="400" height="300"/>

<br>
<br>

<img src="https://i.imgur.com/Fmssohn.png" width="500" height="300"/>
