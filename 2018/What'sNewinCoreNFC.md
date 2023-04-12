## What's New in Core NFC 
 Core NFC Update (WWDC 2018 talk Session)

### Background Tag Reading
- 필요한 앱을 켜거나 가져올 수 있음 백그라운드 상태에서 

1. NFC요구사항
![](https://i.imgur.com/NPY6Y6v.png)
- 백그라운드 태그 읽기는 NDEF메시지에 URL레코드가 포함된 모든 NDEF형식 태그에서 작동한다.

URL레코드에 유효한 Apple Universal Link URL이 포함되어야 한다.
[Apple UniversalLink](https://developer.apple.com/ios/universal-links/)에 등록된된 앱으로 라우팅한다.

2. 어떻게 작동하냐
- 화면이 켜져있는 동안 백그라운드 태그 읽기는 근처의 NFC태그를 스캔한다.
- 태그에 성공하면 푸시알림을 띄우고 탭하면 UniversalLink메커니즘을 사용하여 NSUserActivity객체가 관련 어플리케이션으로 전달된다.
- 사파리는 기본적으로 등록되지않은 모든 어플리케이션 링크를 처리하고 이것은  URL payload프로세스이다.

백그라운드 태그 읽기는 아이폰 XS부터 지원했다
- 단말기의 첫번째 잠금해제 후에 사용이 가능하고 그 이후에는 디스플레이가 켜져있을때마다 백그라운드에서 NFC태그를 스캔한다.
    - 예외사항: Wallet또는 애플페이가 사용중이거나 카메라가 켜져 있는 경우는 예외이다. 비행기모드도 포함

### Handling NFC tag delivery in your app(NFC tag 내 앱에서 다루기)
Step1 - 범용 링크 요구사항에 따라 애플리케이션에 연결된 도메인을 등록해야 한다.

Step2 - UIApplicationDelegate프로토콜인 application(_: continue: restorationHandler:)메서드를 채택해야 한다.

Step3 - NSUserActivity 개체의 NDEFMessagePayload속성에서 NDEF메시지를 추출해야합니다.

![](https://i.imgur.com/LX9E5TB.png)
- 앱에 도메인을 등록하려면 Associated Domains섹션에 서버 호스트 도메인을 입력합니다. (이걸 찾을수가 없네요..) Deep link같은데 아시는분?

```swift
import CoreNFC

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    /// - Tag: universalLinkHandling
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    // - Handle only valid activity type
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else {
return false
    }
        let ndefMessage = userActivity.ndefMessagePayload
        
        guard ndefMessage.records.count > 0,
            ndefMessage.records[0].typNameFormat != .empty else { return flase }
```
![](https://i.imgur.com/LJa6O81.png)
URL 레코드에 범용링크가 포함되어 있지 않는 경우 iOS는 홈킷, sms, GPS등과 같은 QR코드 스캐너와 동일한 많은 URI체계를 처리할 수 있다.



https://developer.apple.com/videos/play/tech-talks/702/
