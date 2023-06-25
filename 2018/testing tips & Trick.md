# WWDC스터디 23.05.14
# testing tips & Trick WWDC2018

## Testing network requests

### WWDC2017 recap
![](https://hackmd.io/_uploads/Hy0G2zAN2.png)

- 피라미드 모델을 통해 테스트 도구모음을 철저하고, 이해가능하게 실행 속도의 균형을 맞추는 방법에 대한 지침으로 논의를 했었다.

- 이 모델을 따르는 테스트 도구모음은 앱 코드의 기반이 작동하는 방식에 대한 포괄적인 그림을 제공할 수 있다.

![](https://hackmd.io/_uploads/ByetaGA43.png)

>여기서 우리는 앱에서 네트워크 요청을 만들고 UI에 데이터를 공급하는 것과 관련된 높은 수준의 데이터 흐름을 볼 수 있습니다.

#### 데모앱의 네트워킹 코드
```swift
func loadData (near coord: CLLocationCoordinate2D) {
    let url = URL(string: "/locations?lat=\ (coord. latitude)&long=\ (coord. longitude)")!
    URLSession. shared.dataTask(with: url) { data, response, error in
        guard let data = data else { self.handleError (error); return }
        do {
            let values = try JSONDecoder () .decode ([PointOfInterest].self, from: data)
            
            DispatchQueue.main.async {
                self.tableValues = values
                self.tableView.reloadData ()
            }
        } catch {
            self.handleError(error)
        }
    }. resume ()
}
```
> 위의 코드를 통해 네트워크에 연결하고 받아온 데이터를 디코딩해서 UI에 업데이트 시켜 줄 수 있다.

### prepare URLRequest를 먼저 살펴보자
```swift
struct PointsOfInterestRequest {
func makeRequest (from coordinate: CLLocationCoordinate2D) throws -> URLRequest {
guard CLLocationCoordinate2DIsValid(coordinate) else {
throw RequestError.invalidCoordinate
?
var components = ULComponents (string: "https:/ /example.com/locations")!
components. querItems = [
URLQueryItem (name: "lat", value: "\ (coordinate.latitude)"),
URLQueryItem(name: "long", value: "\ (coordinate.longitude) ")
]
return URLRequest (url: components.url!)
}
func parseResponse (data: Data) throws -> [Point0fInterest] {
return try JSONDecoder () . decode ([PointOfInterest].self, from: data)
}
}
```

> 이 코드를 더 테스트하기 쉽게 만들기 위해 우리는 뷰컨트롤러에서 코드를 가져와서 PointsOfInterestRequest타입에 두가지 메서드를 만들어 제공했다.(우리 == 애플)

```swift
class Point0fInterestRequestTests: XCTestCase {
let request = PointsOfInterestRequest ( )
func testMakingURLRequest() throws {
let coordinate = CLLocationCoordinate2D(latitude: 37.3293, longitude: -121.8893)
let urlRequest = try request.makeRequest (from: coordinate)
XCTAssertEqual(urlRequest.url?.scheme,
"https")
XCTAssertEqual(uriRequest.url?.host, "example.com")
XCTAssertEqua1 (urlRequest.url?.query, "lat=37.329381ong=-121.8893" )
}
```

> 이렇게 하면 코드에 대한 단위테스트를 작성하는 것이 매우 간단해진다. 위의 코드처럼 몇가지 샘플을 만들고 위치를 입력해서 메서드에 전달하여 테스트 하고 있다.

![](https://hackmd.io/_uploads/HyHpxXRNh.png)
> 마찬가지로 파싱 테스트도 이렇게 해줄 수 있음

### Create URLSession Task
     - 이제 URLSession과 상호 작용하는 코드를 살펴보자
     
![](https://hackmd.io/_uploads/HJcrWX042.png)

- 앞에서 만든 request타입의 메서드와 일치하는 프로토콜을 만들었다.
- 그리고 이건 APIRequestLoader클래스에서 사용된다.
- 요청 타입과 urlSession을 초기화 한다.

![](https://hackmd.io/_uploads/Sk2lMQREh.png)

- 이 방법에 대한 단위 테스트를 계속 작성할 수 있지만 그 전에 데이터 흐름의 여러부분을 다루는 중간 수준의 테스트를 살펴보려고 한다.
![](https://hackmd.io/_uploads/S1zHM704h.png)

### How to Use URLProtocol
![](https://hackmd.io/_uploads/BkITzX0Nh.png)

- URLProtocol은 URLProtocolClient프로토콜을 통해 진행상황을 시스템에 다시 전달한다.
```swift
class MockURLProtocol: URLProtocol {
    static var requestHandler: ( (URLRequest) throws -> (HTTPURLResponse, Data))?

override class func canInit(with request: URLRequest) -> Bool {
return true
}
    
override class func canonicalRequest(for request: URLRequest) -> URLRequest {
return request
}

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail( "Received unexpected request with no handler set" )
            return
        }
        do {
        let (response, data) = try handler (request)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: •notAllowed) 
        client?.urlProtocol(self, didLoad: data)     
        client?.urlProtocolDidFinishLoading(self)
    } catch {
        client?.urlProtocol (self, didFailWithError: error)
        }
    }
override func stopLoading () {
}
```

> URLSession작업이 시작되면 시스템은 URLProtocol하위 클래스를 인스턴스화하여 URLRequest값과 URLProtocol클라이언트 인스턴스를 제공한다.
    - 그런다음 startLoading메서드를 호출함. 여기에서 requestHandler를 테스트 하위 집합으로 가져와 URLRequest를 매개변수로 사용하여 호출한다.
    - 
![](https://hackmd.io/_uploads/HJoPr7A42.png)

- 반환값을 받아서 URL응답과 데이터 또는 오류로 시스템에 다시 전달 한다.

```swift
class APILoaderTests: XCTestCase {
    var loader: APIRequestLoader<Points0fInterestRequest>!
    
    override func setUp () {
        let request = Points0fInterestRequest ( )
        let configuration = URLSessionConfiguration. ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession (configuration: configuration)
        
        loader = APIRequestLoader (apiRequest: request, urlSession: urlSession)
    }
}
```
- APIRequestLoader인스턴스를 만들어서 설정하고 request 유형과 URLProtocol을 사용하도록 구성된 URLSession으로 구성한다.

![](https://hackmd.io/_uploads/SkN2fSCV2.png)

- 이 계층에서 테스트가 잘 작동하면 시스템과 제대로 통합되고 있다는 확신을 가질 수 있다.
- 방금 테스트는 resume을 호출하는 것을 잊었다면 실패했을 것이다.

* 일부시스템 수준 종단 간 테스트를 포함하는 것도 유용할 수 있다. UITest도 하나의 방법이 될 수 있다

### End-to-End Test(종단간 테스트)
> 종단간 테스트를 작성하기 시작할 때 직면하는 가장 큰 문제는 테스트 실패시 문제의 원인을 찾기 시작할 위치를 알기 어렵다는 것이다.
이것을 완화 하기 위해 최근 테스트에서 수행한 한가지는 모의 서버의 로컬 인스턴스를 설정하여 UI테스트를 중단하여 실제 서버 대신 해당 인스턴스에 대한 요청을 만드는 것이었다.

* mock테스트도 좋지만 실제 서버와 통신하는 테스트도 같이 만드는 것이 좋다.
    * 이를 수행하기 위한 한가지는 실제 서버에 대한 요청을 보내는 단위테스트 번들에 몇가지 테스트를 포함하는 것이다(같은말 아닌가요..?ㅎ)

##### 여기까지 단위테스트를 용이하게 하기 위해 코드를 더 작고 독립적인 조각으로 나누는 예를 봤다.


## Working with notifications
> 여기서 노티피케이션은 NSNotification과 옵젝씨로 알려진 기본수준 알림을 말함
> 알림은 일대다 통신 메커니즘이므로 단일 알림이 게시되면 앱 전체 또는 앱 프로세스에서 실행되는 프레임워크 코드에서도 여러 수신자에게 알림이 전송될 수 있다. 이런 점 때문에 노티의 테스트는 항상 고립된 방식으로 테스트하는 것이 중요하다.

1. Test that subjet properly observes or posts a Notification
2. Important to test notifications in isolation
3. isolation avoids unreliable or "flaky" tests

```swift
class PointsOfInterestTableViewController {
    
    var observer: AnyObject?
    
    init() {
        let name = CurrentLocationProvider.AuthChangedNotification
        // authChanged라는 알림을 관찰한다.
        observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main, using: { [weak self] _ in
            self?.handleAtuchChanged()
        })
    }
    
    var didHandleNotification = false
    func handleAuthChanged() {
        didHandleNotification = true
        //이것으로 테스트 코드에서 알림이 실제로 수신되었는지 확인하기 위해 플래그를 확인할 수 있습니다.
    }
}

class PointsOfInterestTableViewController: XVTestCase {
    
    func testNotification() {
        let observer = PointsOfInterestTableViewController()
        XCTAssertFalse(observer.didHandleNotification)
        
        let name = CurrentLocationProvider.authChangedNotification
        NotificationCenter.default.post(name: name, object: nil)
        // 똑같이 포스트함
        
        XCTAssertTrue(observer.didHandleNotification)
    }
}
```

>appDidFinishLaunching알림과 같은 일부 시스템 알림이 많은 계층에서관찰되고 알 수 없는 부작용이 있거나 단순히 테스트 속도가 느려질 수 있는 것은 일반적이다.
그래서 이것을 테스트할때 더 잘 분리 하고 싶다

## Testing Notification Observers
> 노티피케이션을 테스트하는 노하우

### How to use
- 노티피케이션 센터가 여러 인스턴스를 가질 수 있음을 인식해야한다.
    - 이것이 테스트를 격리할때 핵심이 될 것이다.
    - .default대신에 NotificationCenter를 생성해서 사용해야한다.(DI?)


```swift
class PointsOfInterestTableViewController {
    let notificationVenter: NotificationCenter
    var observer: AnyObject?
    
    init(notificationCenter: NotificationCenter = .default) { // 이렇게 하면 기존 클라이언트가 새 매개변수를 전달할 필요가 없고 단위테스트만 전달하기 때문에 기존 코드가 깨지는것을 방지 할 수 있다.
        let name = CurrentLocationProvider.AuthChangedNotification
        observer = notificationCenter.default.addObserver(forName: name, object: nil, queue: .main, using: { [weak self] _ in
            self?.handleAtuchChanged()
        })
    }
    
    var didHandleNotification = false
    func handleAuthChanged() {
        didHandleNotification = true
        //이것으로 테스트 코드에서 알림이 실제로 수신되었는지 확인하기 위해 플래그를 확인할 수 있습니다.
    }
}

  func testNotification() {
        let notificationCenter = NotificationCenter()
        let observer = PointsOfInterestTableViewController(notificationCenter: notificationCenter)
        XCTAssertFalse(observer.didHandleNotification)
        
        let name = CurrentLocationProvider.authChangedNotification
        notificationCenter.default.post(name: name, object: nil)
        // 똑같이 포스트함
        
        XCTAssertTrue(observer.didHandleNotification)
    }
```

- 이렇게 하면 대상이 알림을 옵저빙하는지 테스트할 수 있지만 우리의 주제를 POST하는지 테스트 할 수 있을까?? 내장 API를 사용하여 알림 관찰자를 추가하는 방법이 있다.

```swift
class CurrentLocationProvider {
    
    static let tauthChangedNotification = Notification.Name("AuthChanged")
    
    func notifyAuthChanged() {
        let name CurrentLocationProvider.authChangedNotification
        NotificationCenter.default.post(name: name, objet: self)
    }
    // notification을 게시하여 앱의 위치 인증이 변경되었음을 내 앱의 다른 클래스에 알리는 메서드
}

class CurrentLocationProviderTests: XCTestCase {
    func testNotifyAuthChanged () {
        let poster = CurrentLocationProvider ()
        var observer: AnyObject?
        let expectation = self.expectation (description: "auth changed notification")
        
        // Uses default NotificationCenter, not properly isolating test
        let name = CurrentLocationProvider.authChangedNotification
        observer = NotificationCenter. default. addObserver (forName: name
                                                             object: poster,
                                                             queue: main) { _ in
            NotificationCenter.default.removeObserver(observer!)
            expectation.fulfill ()
}
        
        poster.notifyAuthChanged ()
        wait (for: [expectation], timeout: 0)
    }
    
    개선코드
    class CurrentLocationProvider {
    
    static let tauthChangedNotification = Notification.Name("AuthChanged")
    
    let notificationCenter: NotificationCenter
        init(notificationCenter: NotificationCenter = .default) {
            self.notificationCenter = notificationCenter
        }
        
    func notifyAuthChanged() {
        let name CurrentLocationProvider.authChangedNotification
        notificationCenter.default.post(name: name, objet: self)
    }
    // notification을 게시하여 앱의 위치 인증이 변경되었음을 내 앱의 다른 클래스에 알리는 메서드
}
    
       func testNotifyAuthChanged () {
        let notificationCenter = NotificationCenter()
        let poster = CurrentLocationProvider(notificationCenter: notificationCenter)
        
        let name = CurrentLocationProvider.authChangedNotification
        let expectation = XCTNSNotificationExpectation(name: name,
                                                       object: poster,
                                                      notificationCenter: notificationCenter)
           //테스트에서 특정 센터에 대한 알림을 받을 것으로 예상되면 매개변수를 XCTNSNotificationExpectation에 전달할 수 있습니다.
        
           
        poster.notifyAuthChanged()
        wait (for: [expectation], timeout: 0) --> timeout이 0인 이유는 이 메서드가 반환될 때 알림이 이미 게시되었어야 하기 때문이다.
    }
    
```


## Mocking with protocols

>  다음으로 단위테스트를 작성하고 외부 클래스와 상호작용할 때 자주 발생하는 문제에 대해 이야기 하고 싶다.

1. 클래스가 앱의 다른 위치 또는 SDK에서 제공하는 다른 클래스와 통신하는 상황(아마 라이브러리 같은거 사용할때 테스트를 얘기하는 거 같음 그 중에서도 직접 클래스를 만들어서 사용하지 않는 것들)

프로토콜을 사용하여 상호작용을 모방하면서 해결해야 한다.
```swift
import CoreLocation

class CurrentLocationProvider: NSObject {

         let locationManager = CLLocationManager()
         override init() {
             super.init()
             self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
             //정확도 속성 설정
             self.locationManager.delegate = self
             
 }

    class CurrentLocationProvider: NSObject {
        
         var currentLocationCheckCallback: ((CLLocation) -> Void)?
         func checkCurrentLocation(completion: @escaping (Bool) -> Void) {
         self.currentLocationCheckCallback = { [unowned self] location in
             completion(self.isPointOfInterest(location))
         }
             locationManager.requestLocation()
             이 메서드를 호출하면 현재 위치를 얻으려고 시도하고 클래스에서 delegate메서드를 호출한다.
     }
         func isPointOfInterest(_ location: CLLocation) -> Bool {
         // Perform check...
         }
    }
    // 현재 위치를 요청하고 해당위치가 관심 지점인지 여부를 반환하는 complectionHandler를 사용한다
    
    extension CurrentLocationProvider: CLLocationManagerDelegate {
         func locationManager(_ manager: CLLocationManager, didUpdateLocations locs: [CLLocation]){
             guard let location = locs.first else { return }
             self.currentLocationCheckCallback?(location)
             self.currentLocationCheckCallback = nil
         }
    }
    ----------------테스트 코드--------------
    class CurrentLocationProviderTests: XCTestCase {
         func testCheckCurrentLocation() {
         let provider = CurrentLocationProvider()
             XCTAssertNotEqual(provider.locationManager.desiredAccuracy, 0)
             XCTAssertNotNil(provider.locationManager.delegate)
         let completionExpectation = expectation(description: "completion")
             provider.checkCurrentLocation { isPointOfInterest in
                 XCTAssertTrue(isPointOfInterest)
                 completionExpectation.fulfill()
     }
             
             
              여기서 발생할 수 잇는 문제 1 : provider.checkCurrentLocation메서드의 실행시점을 우리는 모른다.
              2. CoreLocation에 사용자 인증이 필요하고 이전에 부여되지 않은 경우 장치에 권한 대화 상자가 표시된다는 것이다.
             * 그래서 테스트가 장치상태에 의존하게되고 유지관리가 어렵고 실패할 가능성이 높다
             
             // No way to mock the current location or confirm requestLocation() was called
             wait(for: [completionExpectation], timeout: 1)
    
```

### Mocking Using a Subclass( 권장하지 않음)

서브 클래싱에 의존하게 되면 컴파일러는 내가 다른 메서드를 호출하기 시작했음을 알리지 ㅇ낳으며 내 테스트를 잊고 중단하기 쉽다.
작동할 순 있지만 위험성이 있다.

## 그래서 프로토콜을 통해 정의한다.
```swift
class CurrentLocationProvider: NSObject {
    let locationFetcher = LocationFetcher()
    override init(locationFetcher: LocationFetecher = CLLocationManager()) {
        self.locationFetcher = locationFetcher
        super.init()
        self.locationFetcher.desiredAccuracy = kCLLocationAccuracyHunderedMeters
        self.locationFetcher.locationFetcherlocationFetcherDelegate = self
    }
}

Protocol LocationFetcher {
    var delegate: LocationFetcherDelegate? { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }
    func requestLocation()
}

extension CLLocationManger: LoceationFetcher {}

CLLocationManger에서 사용하는 정확한 메서드 및 프로퍼티 집합이 포함되어 있다


 class CurrentLocationProvider: NSObject {
        
         var currentLocationCheckCallback: ((CLLocation) -> Void)?
         func checkCurrentLocation(completion: @escaping (Bool) -> Void) {
         self.currentLocationCheckCallback = { [unowned self] location in
             completion(self.isPointOfInterest(location))
         }
             locationFetcher.requestLocation() //locationFetcher로 바뀜
             이 메서드를 호출하면 현재 위치를 얻으려고 시도하고 클래스에서 delegate메서드를 호출한다.
     }
         func isPointOfInterest(_ location: CLLocation) -> Bool {
         // Perform check...
         }
    }

Protocol LocationFetcherDelegate: class {
    func locationFetcher(_ fetcher: LocationFetcher,
                         didUpdateLocations locs: [CLLocation]
}

extension CLLocationManger: LocationFetcher {
    var locationFetcherDelegate: LocationFetcherDelegate? {
        get { return delegate as! LocationFetcherDelegat? }
        set { delegate = newValue as! CLLocationMangerDelegate? }
    }
}

 extension CurrentLocationProvider: locationFetcherDelegate {
         func locationFetcher(_ fetcher: locationFetcher,
                              didUpdateLocations locs: [CLLocation]){
             guard let location = locs.first else { return }
             self.currentLocationCheckCallback?(location)
             self.currentLocationCheckCallback = nil
         }
    }
    
    찐 CLLocationDelegate메서드를 호출해서 알려줌
     extension CurrentLocationProvider: CLLOcationManagerDelegate {
         func locationManager(_ manager: CLLocationManager,
                              didUpdateLocations locs: [CLLocation]) {
             self.locationFetcher(mager, didUpdateLocations: locs)
         }
     }
--------------------테스트코드 -----------------
    class CurrentLocationProviderTests: XCTestCase {
         struct MockLocationFetcher: LocationFetcher {
                weak var locationFetcherDelegate: LocationFetcherDelegate?
             var desiredAccuracy: CLLocationAccuracy = 0
             var handleRequestLocation: (() -> CLLocation)?
             func requestLocation() {
             guard let location = handleRequestLocation?() else { return }
                 locationFetcherDelegate?.locationFetcher(self, 
                                                          didUpdateLocations: [location])
         }
     }    
        
        wait(for: [requestLocationExpectation, complectionExpectation], timeout: 1)
        
    테스트를 위해 구조체를 중첩해서 정의한다.
    MockLocationFetcher를 locationFetcher프로토콜을 준수하게 한다.
        handleRequestLocation을 테스트에서 사용자 지정으로 가짜위치를 가져오기 위해 호출한 다음 delegate메서드를 호출하여 가짜위치를 전달한다.
        
        
        func testCheckCurrentLocation() {
             var locationFetcher = MockLocationFetcher()
             let requestLocationExpectation = expectation(description: "request location")
                 locationFetcher.handleRequestLocation = {
                 requestLocationExpectation.fulfill()
                 return CLLocation(latitude: 37.3293, longitude: -121.8893)
             } // 가짜 좌표를 보내도록 함
             let provider = CurrentLocationProvider(locationFetcher: locationFetcher) // MockLocationFetcher에 전달한다.
             let completionExpectation = expectation(description: "completion")
                 provider.checkCurrentLocation { isPointOfInterest in
                여기서 체크를 하고 이게 참값인지 확인함
                 XCTAssertTrue(isPointOfInterest)
                 completionExpectation.fulfill()
             }
             // Can mock the current location
             wait(for: [requestLocationExpectation, completionExpectation], timeout: 1)
        }
        
```


## Recap
1. 외부 클래스의 인터페이스를 나타내는 새프로토콜을 정의했다
2. 프로토콜 준수를 선언하는 원래 외부 클래스에 대한 확장을 만들었다
3. 외부 클래스의 모든 사용을 새프로토콜로 교체하고 테스트에서 이유형을 설정할 수 있도록 이니셜라이저를 추가했다.
4. SDK의 일반적인 패턴인 delegate프로토콜토 mock으로 사용하는 방법도 알아봤다
    - 우리가 사용하는 프로토콜과 유사한 메서드 시그니처를 사용하여 모의 delegateProtocol을 정의 했다. 실제 프로토콜을 대체했음
    - 그런 다음 원래 모의 프로토콜에서 delegate속성의 이름을 바꾸고 확장에서 이름이 바뀐 속성을 구현했다.


### 이 방식은 서브클래싱 같은 대안보다 코드가 더 길어질 수 있지만 더 확장에 열려있고 안정적이고 중단될 가능성이 적다





## Test실행속도

> 테스트시간이 오래걸리면 개발중에 테스트를 실행할 가능성이 줄거나 오래 실행되는 테스트를 skip하고 싶을 수 있다.

![](https://hackmd.io/_uploads/Bkt-xMWSh.png)

타이머로 10초에 한번씩 장소를 보여주는 코드

![](https://hackmd.io/_uploads/HJzmefbHn.png)

FeaturedPlaceManager를 생성하고 scheduleNextPlace메서드 호출전에 현재 위치를 저장
11초동안 런루프를 주고 이러면 너무 오랜 시간이 걸린다.



![](https://hackmd.io/_uploads/BkF5-GZH3.png)
* 이렇게 하면 1초로 줄일수 있지만 근본해결책이 아니며 지연이 있고 단지 지연의 시간이 짧을 뿐이다.
타이밍 의존적이다

### 더 나은 접근방식

## Testing Delayed Actions
Without the delay

어떻게 사용하냐
- DispatchQueue.asyncAfter를 사용할 수도 있다.( 지연된 작업을 즉시 호출하고 지연을 우회할 수 있도록 테스트에서 이 메커니즘을 사용하려 한다.)

// 이렇게 분리하면 앞에서 했던 프로토콜을 사용한 방법을 적용할 수 있다.

```swift
class FeaturePlaceManager {
    let runLoop = RunLoop.current
    
    func scheduleNextplace() {
        let timer = Timer.scheduledTimer(withTimInterval: 10,
                            repeats: fasle) { [weak self] _ in
            self?.showNextPlace()                                    
        }
        
        runLoop.add(timer, forMode: .default)
    }
    func showNextPlace() {}
}

protocol TimerScheduler {
    fun add(_ timer: Timer, forMode mode: RunLoop.Mode)
}

extension RunLoop: TimerScheduler {}

```
이 프로토콜로 교체

![](https://hackmd.io/_uploads/HkHxHGbrn.png)

실제 runLoop를 TimerSchduler로 사용하고 싶지 않다

```swift=
class FeaturedPlaceManagerTests: XCTestCase {
    
    struct MockTimerScheduler: TimerScheduler {
        var handleAddTimer: ((_ timer: Timer) -> Void)?
        
        func add(_ timer: Timer, forMode mode: RunLoop.Mode) {
            handleAddTimer?(timer)
        }
        타이머를 추가하라는 지시를 받을 때마다 호출되는 블록을 저장합니다.

    }
    
    func testScheduleNextPlace() {
        var timerScheduler = MockTimerScheduler()
        var timerDelay = TimeInterval(0)
        timerScheduler.handleAddTimer = { timer in
            timerDelay = timer.fiereDate.timeIntervalSinceNow
            timer.fier()
        }
        여기서 스케줄러에 추가되면 타이머의 지연시간을 기록한 다음 타이머를 실행하고 지연을 우회하여 블럭을 호출한다.
    }
    
    let manager = FeaturedPlaceManager(timerScheduler: timerScheduler)
    let beforePlace = manager.currentPlace
    manager.scheduleNextPlace()
    
    XCTAssertEqual(timerDelay, 10, accuracy: 1)
    지연의 시간을 확인하는 테스트도 진행할 수 있음
    XCTAssertNotEqual(manager.currentPlace, beforePlace)
}
```
> 이렇게 하면 빠르게 실행되고 타이머에 의존하지 않게 되어 안정적이다

지연된 작업을 모의할 필요가 없도록 하는 것이 바람직하다


##  NSPredicateExpectations, NSNotification, KVOExpectation은 UI테스트에서 주로 사용 유닛테스트에서는 이것보다 직접적인 메커니즘을 권장한다.

### 다른 팁(속도향상)
> 최대한 빠르게 실행되도록 하는 것

- 유닛테스트는 앱이 런치되는 것을 기다리고 이때 앱시작에 오랜시간이 걸린다는 것을 알고있다면 앱이 테스트 러너로 시작되는 시점을 감지하고 피하는 것이다.
    - 사용자 지정  Enviroment Variables또는 시작인수를 지정하는 것이다.

![](https://hackmd.io/_uploads/B1bVSE-r2.png)

![](https://hackmd.io/_uploads/H1Iq4EZS3.png)

그런 다음 이 조건을 확인하게 앱델리게이트의 디드 피니싱 코드를 수정한다


