<h1><center> Build a workout app for Apple Watch [2주차] </center></h1>

###### tags: `💻 WWDC 스터디`
> [color=#724cd1][name=데릭]
> [Build a workout app for Apple Watch - wwdc21](https://developer.apple.com/videos/play/wwdc2021/10009/)

> [Download Project] (https://developer.apple.com/documentation/healthkit/workouts_and_activity_rings/build_a_workout_app_for_apple_watch)


> WWDC 2021 Session 중 하나인 `Build a workout app for Apple Watch`에 대해 알아보자

# 개요

운동 중에도 추적할 수 있는 앱을 만들어 보자

## Code-Along

- 먼저 Watch App 프로젝트를 만들자. 

### StartView

- HKWorkoutActivityTypes에는 사이클링, 달리기, 걷기 등이 있다.
- HKWorkoutActivityTypes 열겨형을 확장하여 식별 가능한 프로토콜을 준수하고 이름 변수를 추가하여 목록에서 HKWorkoutActivityTypes에 접근할 수 있도록 해야 한다.

```swift
extension HKWorkoutActivityType: Identifiable {
    public var id: UInt {
        rawValue
    }

    var name: String {
        switch self {
        case .running:
            return "Run"
        case .cycling:
            return "Bike"
        case .walking:
            return "Walk"
        default:
            return ""
        }
    }
}

```

이제 운동 List를 표시하기 위해 StartView의 본문에 ListView를 추가한다.

```swift 
struct StartView: View {
    var workoutTypes: [HKWorkoutActivityType] = [.cycling, .running, .walking]

    var body: some View {
        List(workoutTypes) { workoutType in
            NavigationLink(workoutType.name, 
                           destination: Text(workoutType.name))
                .padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
        }
        .listStyle(.carousel)
        .navigationBarTitle("Workouts")
    }
}
``` 

`List`는 workoutTypes 변수를 Model로 사용한다. 그리고 각 운동 타입 별로 `NavigationList가` 표시됩니다. 

- NavigationList는 탐색 기반 인터페이스의 대상을 정의한다.
    - 지금은 텍스트 뷰가 대상이 된다.
    - 패딩은 Navigation Link를 더 크게 만들어 쉽게 운동을 시작할 수 있도록 더 큰 탭 영역을 제공한다.
- `List`는 listStyle을 사용하여 스크롤할 때 깊이 효과를 제공한다. 
- `navigationBarTitle`은 Workouts이다.


Workout Session은 모달 Experience로 제공된다. 사람들에게 운동하는 동안에는 일반적으로 세션별로 기능만 
필요하다. 운동 목록을 검토하거나 앱의 다른 부분에 접근할 필요가 없다. 

- 모달 경험에서 가장 중요한 항목을 제공하면(End 버튼, Pause 버튼) 사람들에게 방해하는 것을 최소하하면서 세션을 관리하는 데 도움이 될 수 있다.

![](https://hackmd.io/_uploads/HJ7agKkrn.png)

- 종료, 일시 중지, 다시 시작과 같은 진행 중인 세션을 제어하는 버튼


![](https://hackmd.io/_uploads/rJLfWFkS3.png)

- 사람들이 한눈에 읽을 수 있는 지표

![](https://hackmd.io/_uploads/Sk5M-tkSn.png)

- 미디어 재생 컨트롤을 통해 운동 중에 미디어를 제어

watchOS의 TabView는 사용자가 왼쪽에서 오른쪽으로 스와이프하면 여러 하위 뷰 사이를 전환한다. 또한, TabView는 뷰 하단에 페이지 표시를 제공한다. 세션 내 뷰를 표시하는 데 효과적인 뷰이다.

## SessionPagingView - TabView

- TabView에서 선택할 수 있는 각 뷰를 모델링하는 Tab enum을 만든다.

```swift 
    enum Tab {
        case controls, metrics, nowPlaying
    }
```

- TabView의 선택에 대한 바인딩을 제공하기 위해 selection이라는 @State 변수도 추가한다.

```swift 
    @State private var selection: Tab = .metrics
```

**TabView**

```swift 
    var body: some View {
        TabView(selection: $selection) {
            Text("Controls").tag(Tab.controls)
            Text("Metrics").tag(Tab.metrics)
            Text("Now Playing").tag(Tab.nowPlaying)
        }
    }
``` 

**NOTE**

> 달리기와 같이 세션에 움직임이 필요한 앱은 가장 중요한 정보를 쉽게 읽을 수 잇도록 큰 글꼴 크기를 사용하고 텍스트를 정렬해야 한다.

## MetricsView

![](https://hackmd.io/_uploads/rJLfWFkS3.png)

- 경과시간, 활성 에너지, 현재 심박수 및 거리를 표시한다.
- HealthKit에는 HKQuantityTypes를 통해 더 많은 정보를 얻을 수 있다.

```swift 
    var body: some View {
            VStack(alignment: .leading) {
                Text("03:15.23")
                    .foregroundColor(Color.yellow)
                    .fontWeight(.semibold)
                
                Text(
                    Measurement(
                        value: workoutManager.activeEnergy, 
                        unit: UnitEnergy.kilocalories)
                        .formatted(
                            .measurement(
                                width: .abbreviated,
                                usage: .workout, 
                                numberFormatStyle: .number.precision(.fractionLength(0))
                            )
                        )
                    )
                
                Text(153.formatted(
                    .number.precision(.fractionLength(0))) + " bpm")
                
                Text(
                    Measurement(
                        value: 515, 
                        unit: UnitLength.meters
                    ).formatted(
                        .measurement(
                            width: .abbreviated,
                            usage: .road
                        )
                    )
                )
            }
            .font(
                .system(
                    .title, 
                    design: .rounded).monospacedDigit().lowercaseSmallCaps())
            .frame(
                maxWidth: .infinity, 
                alignment: .leading)
            .ignoresSafeArea(edges: .bottom)
            .scenePadding()
        }
    }

``` 

- Model에 연결할 때까지 기본값으로 설정
- Measurement는 kilocalories 에너지 단위를 사용하여 생성한다.
    - width : abbreviates 단위 축약을 포맷하는 메서드 형식
    - usage : workout으로 소모된다는 것을 의미
    - numberFormat : 분수를 자르기 위해 fractionLength를 0으로 설정

- Heart rate 텍스트 뷰는 fractionLength 0 형식의 기본값을 사용
    - bpm : 분당 비트 수

- 거리 텍스트 뷰는 `UnitLength.meters`를 기본값으로 사용한다. 
    - unit : 약식 단위로 지정한다.
    - usage : imperial or metric 반위로 표시하는 방법


- maxWidth: .infinity 
    - MetricsView가 leading edge에 정렬되게 설정하기 위해 

- .ignoresSafeArea(edges: .bottom) 
    - VStack의 콘텐츠가 하면 하단까지 확장되도록 허용

- scenePadding
    - navigation bar title 정렬 


## ElapsedTimeView

시간 텍스트 뷰에서 시간의 형식을 적절하게 지정하고 Always On 상태에 맞춰 초 미만을 숨기거나 표시하게 하기 위해 만든다.

```swift 
import SwiftUI

struct ElapsedTimeView: View {
    var elapsedTime: TimeInterval = 0
    var showSubseconds: Bool = true
    @State private var timeFormatter = ElapsedTimeFormatter()

    var body: some View {
        Text(NSNumber(value: elapsedTime), formatter: timeFormatter)
            .fontWeight(.semibold)
            .onChange(of: showSubseconds) {
                timeFormatter.showSubseconds = $0
            }
    }
}

class ElapsedTimeFormatter: Formatter {
    let componentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    var showSubseconds = true

    override func string(for value: Any?) -> String? {
        guard let time = value as? TimeInterval else {
            return nil
        }

        guard let formattedString = componentsFormatter.string(from: time) else {
            return nil
        }

        if showSubseconds {
            let hundredths = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
            let decimalSeparator = Locale.current.decimalSeparator ?? "."
            return String(format: "%@%@%0.2d", formattedString, decimalSeparator, hundredths)
        }

        return formattedString
    }
}

```

이제 MetricsView의 시간 텍스트 뷰를 ElapsedTimeView로 교체한다.

```swift 
  ElapsedTimeView(
      elapsedTime:3 * 60 + 15.24, 
      showSubseconds: true
  ).foregroundStyle(.yellow)
```

## ControlsView

![](https://hackmd.io/_uploads/HJ7agKkrn.png)


```swift=
struct ControlsView: View {
    var body: some View {
        HStack {
            VStack {
                Button {
                } label: {
                    Image(systemName: "xmark")
                }
                .tint(.red)
                .font(.title2)
                Text("End")
            }
            VStack {
                Button {
                } label: {
                    Image(systemName:"pause")
                }
                .tint(.yellow)
                .font(.title2)
                Text("Pause")
            }
        }
    }
```

## NowPlayingView

- TabView에 만든 뷰들을 추가하자.

```swift 
      TabView(selection: $selection) {
            ControlsView().tag(Tab.controls)
            MetricsView().tag(Tab.metrics)
            NowPlayingView().tag(Tab.nowPlaying)
        }
```

- StartView로 돌아가서 NavigationLink의 대상을 SessionPagingView로 변경한다.

 ```swift 
struct StartView: View {
    var workoutTypes: [HKWorkoutActivityType] = [.cycling, .running, .walking]

    var body: some View {
        List(workoutTypes) { workoutType in
            NavigationLink(
                workoutType.name,
                destination: SessionPagingView())
                .padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
        }
        .listStyle(.carousel)
        .navigationBarTitle("Workouts")
    }
}
``` 

## Summary View

- 운동이 완료되었음을 **확인**하고 기록된 정보를 표시한다.

```swift 
    @State private var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
```

- durationFormatter는 시, 분, 초를 클론으로 구분하고 0을 채우는 DateComponentsFormatter이다.

```swift 
struct SummaryView: View {
    @State private var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    var body: some View {
            ScrollView {
                VStack(alignment: .leading) {
                    SummaryMetricView(
                        title: "Total Time",
                        value: durationFormatter.string(
                            from: 30 * 60 + 15) ?? "")
                        .accentColor(Color.yellow)
                    
                    SummaryMetricView(
                        title: "Total Distance",
                        value: Measurement(
                            value: 1625,
                            unit: UnitLength.meters
                        ).formatted(
                            .measurement(
                                width: .abbreviated,
                                usage: .road
                            )
                        )
                    ).accentColor(Color.green)
                    
                    SummaryMetricView(title: "Total Energy",
                                      value: Measurement(
                                          value: 96,
                                          unit: UnitEnergy.kilocalories
                                      ).formatted(
                                          .measurement(
                                              width: .abbreviated,
                                              usage: .workout,
                                              numberFormat: .numberic(precision: .fractionLength(0))
                                          )
                                      ).accentColor(Color.pink)
                                      
                    SummaryMetricView(title: "Avg. Heart Rate",
                                      value: 143.formatted(
                                          .number.precision(
                                              .fractionLength(0))
                                      ) + " bpm"
                                     ).accentColor(Color.red)
             
                    Button("Done") {
                        dismiss()
                    }
                }
                .scenePadding()
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
    }
}

```

## ActivityRingsView

```swift 
import Foundation
import HealthKit
import SwiftUI

struct ActivityRingsView: WKInterfaceObjectRepresentable {
    let healthStore: HKHealthStore

    func makeWKInterfaceObject(context: Context) -> some WKInterfaceObject {
        let activityRingsObject = WKInterfaceActivityRing() // 해당 메서드 내부에서 선언한다.

        let calendar = Calendar.current
        var components = calendar.dateComponents([.era, .year, .month, .day], from: Date())
        components.calendar = calendar

        let predicate = HKQuery.predicateForActivitySummary(with: components)
        let query = HKActivitySummaryQuery(predicate: predicate) { query, summaries, error in
            DispatchQueue.main.async {
                activityRingsObject.setActivitySummary(summaries?.first, animated: true)
            }
        }

        healthStore.execute(query)

        return activityRingsObject
    }

    func updateWKInterfaceObject(_ wkInterfaceObject: WKInterfaceObjectType, context: Context) {

    }
}

```

- `WKInterfaceObjectRepresentable` 프로토콜을 준수하기 위해서 `makeWKInterfaceObject`,`updateWKInterfaceObject` 두 메서드의 기능이 필요하다.


SummaryView에 추가한다.
- Done 버튼 위에 위치한다.

```swift 
Text("Activity Rings")
ActivityRingsView(
    healthStore: HKHealthStore())
    .frame(width: 50, height: 50)

```

## HealthKit 

- 운동 중 피트니스 활동을 추적하고 해당 운동을 HealthKit에 저장하는 기능을 제공한다.

**HKWorkoutSession**

- 칼로리 및 심박수와 같은 운동과 관련된 데이터를 정확하게 수집할 수 있도록 디바이스의 센서를 준비한다.
- 또한, workout을 활성화하면 앱이 백그라운드에서 실행될 수 있다.

**HKLiveWorkoutBuilder**

- HKWorkout 객체를 생성하고 저장한다.
- 샘플과 이벤트를 자동으로 수집한다.

아래의 링크로 조금 더 자세히 알 수 있다.
[New ways to work with workouts - WWDC18](https://developer.apple.com/videos/play/wwdc2018/707/)


### Data Flow

> WorkoutManager는 HealthKit과의 인터페이스를 담당한다.

 ![](https://hackmd.io/_uploads/Sy3QJ9kHn.png)

- HKWorkoutSession과 인터페이스하여 운동을 시작, 일시 중지 및 종료한다.
- HKLiveWorkoutBuilder와 인터페이스하여 운동 샘플을 수신하고 해당 데이터를 뷰에 제공한다.
- **WorkoutManager**는 `EnvironmentObject`가 된다.
    - 해당 객체는 관찰 가능한 객체가 변경될때마다 현재 보이는 뷰를 무효화한다.

![](https://hackmd.io/_uploads/ryf9y9kS3.png)

- MyWorkoutsApp의 NavigationView에 WorkoutManager를 NavigationView의 뷰 계층 구조에 있는 뷰로 전달하는 WorkoutManger 객체를 할당한다.

![](https://hackmd.io/_uploads/ryAp151S2.png)

- 그런 다음 하위 뷰는 @EnvironmentObject를 선언하여 WorkoutManger에 대한 접근 권한을 얻는다.

## WorkoutManger

```swift 
import Foundation
import HealthKit

class WorkoutManger: NSObject, ObservableObject {
    var selectedWorkout: HKWorkoutActivityType?
    
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    // Start the workout.
    func startWorkout(workoutType: HKWorkoutActivityType) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        configuration.locationType = .outdoor

        // Create the session and obtain the workout builder.
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            // Handle any exceptions.
            return
        }

        // Setup session and builder.
        session?.delegate = self
        builder?.delegate = self

        // Set the workout builder's data source.
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                     workoutConfiguration: configuration)

        // Start the workout session and begin data collection.
        let startDate = Date()
        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { (success, error) in
            // The workout has started.
        }
    }

}

```

- `HKLiveWorkoutDataSource`는 활성화된 운동의 실시간 데이터를 자동으로 제공한다.
- `selectedWorkout`이 변경될 때마다 `startWorkout`을 호출하자.

``` swift 
    var selectedWorkout: HKWorkoutActivityType? {
        didSet {
            guard let selectedWorkout = selectedWorkout else { return }
            startWorkout(workoutType: selectedWorkout)
        }
    }
```

앱에서 운동 세션을 생성하려면, 먼저 HealthKit을 설정하고 앱에서 사용할 건강 데이터를 읽고 공유할 권한을 요청해야 한다.


**인증 요청하는 기능**

```swift 
    // Request authorization to access HealthKit.
    func requestAuthorization() {
        
        // 운동 세션의 경우, 운동 타입을 공유하려면 권한을 요청해야 한다.
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]

        // 또한 세션의 일부로 Apple Watch가 자동으로 기록한 모든 데이터 타입을 읽어야 한다.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
            
            HKObjectType.activitySummaryType() // Activity Rings Summary를 읽는 권한도 필요하다.
        ]

        // Request authorization for those quantity types.
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            // Handle error.
        }
    }
```


- StartView가 나타나면 바로 권한을 요청하도록 하자
    - onAppear 메서드를 사용

```swift 

struct StartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    var workoutTypes: [HKWorkoutActivityType] = [.cycling, .running, .walking]

    var body: some View {
        List(workoutTypes) { workoutType in
            NavigationLink(workoutType.name, destination: SessionPagingView(),
                           tag: workoutType, selection: $workoutManager.selectedWorkout)
            .padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
        }
        .listStyle(.carousel)
        .navigationBarTitle("Workouts")
        .onAppear {
            workoutManager.requestAuthorization()
        }
    }
}
```

![](https://hackmd.io/_uploads/Hyv3M5yB2.png)

- HealthKit에 대해 Extension에서 추가 해야한다.

![](https://hackmd.io/_uploads/rk-WQ9kS2.png)

- 활성화하는 운동 세션이 있는 앱은 백그라운드에서 실행될 수 있도록 WatchKit Extension에서 백그라운드 모드 기능을 추가해야 한다.
- **Workout processing** 선택

![](https://hackmd.io/_uploads/r1_OX9ySn.png)

- WatchKit Extension의 info.plist에서 `NSHealthShareUsageDescription` 키를 사용해야 한다.
    - 앱에서 요청된 데이터를 읽어야 하는 이유를 설명.
- NSHealthUpdateUsageDescription
    - 앱에서 쓰려는 데이터를 설명.


이제 운동 세션을 시작할 수 있으므로 `HKWorkoutSession`을 제어해야한다.

## HKWorkoutSession

`running`은 해당 세션이 실행 중인지 추적한다.


**WorkoutManager**

```swift 
    // MARK: - Session State Control

    // The app's workout state.
    @Published var running = false

    // 세션이 실행 중인지 여부에 따라 세션을 일시 중지하거나 다시 시작한다.
    func togglePause() {
        if running == true {
            self.pause()
        } else {
            resume()
        }
    }

    func pause() {
        session?.pause()
    }

    func resume() {
        session?.resume()
    }

    // 세션 종료
    func endWorkout() {
        session?.end()
        showingSummaryView = true
    }
```

**`HKWorkoutSessionDelegate`를 채택하여 세션의 상태 변경 사항을 수신하도록하자**

```swift 
// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    
    // 세션 상태가 변경될 때마다 호출된다.
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        
        // 실행 중인지 여부에 따라 UI업데이트를 위해 메인 스레드로 보낸다.
        DispatchQueue.main.async {
            self.running = toState == .running
        }

        // 세션이 종료됨으로 전환되면 종료 날짜와 함께 빌더에서 endCollection을 호출하여 운동 샘플 수집을 중지한다.
        // 그 후, finishWorkout을 호출하여 HKWorkout을 Health 데이터베이스에 저장한다.
        if toState == .ended {
            builder?.endCollection(withEnd: date) { (success, error) in
                self.builder?.finishWorkout { (workout, error) in
                }
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {

    }
}
```

이제 ControlsView에서 Pause를 제어하자.

```swift 
struct ControlsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager

    var body: some View {
        HStack {
            VStack {
                Button {
                    workoutManager.endWorkout()
                } label: {
                    Image(systemName: "xmark")
                }
                .tint(.red)
                .font(.title2)
                Text("End")
            }
            VStack {
                Button {
                    workoutManager.togglePause()
                } label: {
                    Image(systemName: workoutManager.running ? "pause" : "play")
                }
                .tint(.yellow)
                .font(.title2)
                Text(workoutManager.running ? "Pause" : "Resume")
            }
        }
    }
}
```

이제 Navigation bar에서 이름을 표시하도록 SessionPagingView를 업데이트 하겠다.

```swift 
import SwiftUI
import WatchKit

struct SessionPagingView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @State private var selection: Tab = .metrics

    enum Tab {
        case controls, metrics, nowPlaying
    }

    var body: some View {
        TabView(selection: $selection) {
            ControlsView().tag(Tab.controls)
            MetricsView().tag(Tab.metrics)
            NowPlayingView().tag(Tab.nowPlaying)
        }
        .navigationTitle(workoutManager.selectedWorkout?.name ?? "")
        .navigationBarBackButtonHidden(true) // 운동을 하는 동안 StartView로 돌아가는 것을 원하지 않기 때문에 숨긴다.
        .navigationBarHidden(selection == .nowPlaying)
        .onChange(of: workoutManager.running) { _ in
            displayMetricsView()
        } // 운동을 일시 중지하거나 다시 시작할 때 MetricsView로 스와이프 할 필요가 없다.
        
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: isLuminanceReduced ? .never : .automatic))
        .onChange(of: isLuminanceReduced) { _ in
            displayMetricsView()
        }
    }

    private func displayMetricsView() {
        withAnimation {
            selection = .metrics
        }
    }
}

```

이제 운동이 끝나고 SummaryView가 보일 수 있도록 설정하자.


**WorkoutManger**

```swift 
    @Published var showingSummaryView: Bool = false {
        didSet {
            if showingSummaryView == false {
                selectedWorkout = nil
            }
        }
    }
```

- endWorkout() 메서드에서 true로 설정한다.

이제 MyWorkoutsApp의 NavigationView에 SummaryView를 추가해보자.

```swift 
import SwiftUI

@main
struct MyWorkoutsApp: App {
    @StateObject private var workoutManager = WorkoutManager()

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                StartView()
            }
            .sheet(isPresented: $workoutManager.showingSummaryView) {
                SummaryView()
            }
            .environmentObject(workoutManager)
        }
    }
}
```

이제 SummaryView에서 dismiss기능을 추가한다.

```swift 
    @Environment(\.dismiss) var dismiss
```

- 해당 변수를 추가하고 Done 버튼의 Action으로 dismiss()를 추가하자.

```swift 
    Button("Done") {
        dismiss()
    }
```

이제 WorkoutManger에서 HealthKit 데이터를 가지는 변수들을 만들어서 MetricsView, SummaryView가 관찰할 수 있도록 하자.


**WorkoutManger**

```swift 
    // MARK: - Workout Metrics
    @Published var averageHeartRate: Double = 0
    @Published var heartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var distance: Double = 0
``` 

`WorkoutManager`는 HKLiveWorkoutBuilderDelegate를 추가하여 빌더에 추가된 샘플 데이터를 관찰하도록 해야 한다.

```swift 
// MARK: - HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    
    // Builder가 이벤트를 수집할 때마다 호출된다.
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {

    }

    // 새로운 샘플 데이터를 수집할 때마다 호출된다.
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return // Nothing to do.
            }

            let statistics = workoutBuilder.statistics(for: quantityType)

            // Update the published values.
            updateForStatistics(statistics)
        }
    }
    
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }

        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning), HKQuantityType.quantityType(forIdentifier: .distanceCycling):
                let meterUnit = HKUnit.meter()
                self.distance = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
            default:
                return
            }
        }
    }
}
```

- `updateForStatistics` 메서드는 비동기적으로 메인 스레드에서 처리한다. 


이제 MetricsView에서 해당 데이터들을 관찰해보자.

```swift 

import SwiftUI
import HealthKit

struct MetricsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
            VStack(alignment: .leading) {
                ElapsedTimeView(
                    elapsedTime: workoutManager.builder?.elapsedTime ?? 0,
                    showSubseconds: true)
                    .foregroundStyle(.yellow)
                
                Text(
                    Measurement(
                        value: workoutManager.activeEnergy, 
                        unit: UnitEnergy.kilocalories
                    ).formatted(
                        .measurement(
                            width: .abbreviated,
                            usage: .workout,
                            numberFormatStyle: .number.precision(
                                .fractionLength(0))
                        )
                    )
                )
                
                Text(
                    workoutManager.heartRate.formatted(
                        .number.precision(
                            .fractionLength(0))
                    ) + " bpm"
                )
                
                Text(
                    Measurement(
                        value: workoutManager.distance,
                        unit: UnitLength.meters)
                    .formatted(
                        .measurement(
                            width: .abbreviated,
                            usage: .road))
                )
            }
            .font(
                .system(
                    .title,
                    design: .rounded
                ).monospacedDigit().lowercaseSmallCaps())
            .frame(
                maxWidth: .infinity,
                alignment: .leading)
            .ignoresSafeArea(
                edges: .bottom)
            .scenePadding()
        }
    
}

```

- 위의 코드는 빌더의 경과 시간 변수가 게시되지 않아 빌더의 elapsedTime이 업데이트 될 때 뷰가 업데이트 되고 있지 않다.
    - TimelineView에서 VStack을 랩핑하면 된다.
    - 2021년부터 새로워짐 ([TimelineView](https://developer.apple.com/videos/play/wwdc2021/10018/))
    - 일정에 따라 시간이 지나면 업데이트 된다.
        - watchOS앱은 Always On 상태를 지원한다.
            - [What's new in SwiftUI](https://developer.apple.com/videos/play/wwdc2021/10002/)

**활성화된 운동 세션이 있는 앱은 Always On 상태에서 최대 1초에 한 번 업데이트할 수 있다.**

![](https://hackmd.io/_uploads/HypkR5kSh.png)

    - 이는 MetricsView가 Always on 상태에서 1초 미만을 숨길 필요가 있다는 것을 의미한다.(?)
    - 뷰를 단순화하기 위해 페이지를 표시하는 컨트롤을 숨기는 것과 같이 Always on 상태에 대한 다른 디자인을 만들어야 한다.
    

TimelineView에는 Always On 컨텍스트에서 지정한 TimelineScheduleMode에 따라 간격을 변경하는 커스텀 TimelineSchedule이 필요하다.

```swift 
private struct MetricsTimelineSchedule: TimelineSchedule {
    var startDate: Date
    var isPaused: Bool

    init(from startDate: Date, isPaused: Bool) {
         
        self.startDate = startDate
        self.isPaused = isPaused
    }

    // lowFrequency인 경우 TimelineSchedule은 1초 간격으로 작동한다.
    // lowFrequency는 잠금 상태일 경우를 말한다.
    // nomal인 경우 초당 30회이다.
    func entries(from startDate: Date, mode: TimelineScheduleMode) -> AnyIterator<Date> {
        var baseSchedule = PeriodicTimelineSchedule(from: self.startDate,
                                                    by: (mode == .lowFrequency ? 1.0 : 1.0 / 30.0))
            .entries(from: startDate, mode: mode)
        
        return AnyIterator<Date> {
            guard !isPaused else { return nil }
            return baseSchedule.next()
        }
    }
}
```

**MetricsView**

```swift 

    TimelineView(
        MetricsTimelineSchedule(
            from: workoutManager.builder?.startDate ?? Date(),
            isPaused: workoutManager.session?.state == .paused)
    ) { context in
        VStack(alignment: .leading) {
             ElapsedTimeView(
                 elapsedTime: workoutManager.builder?.elapsedTime(
                     at: context.date) ?? 0,
                 showSubseconds: context.cadence == .live)
            ...
```

- ElapsedTimeView의 showSubseconds는 TimelineView의 context.cadence에 의해 결정된다. cadence가 활성화되면 초 미만이 표시된다. 그렇지 않으면 초 미만이 Always On 상태에서 숨겨지게 된다.




SummaryView에서 필요한 실제 HKWorkout 데이터를 가져오자.

**WorkoutManager**

```swift 
    @Published var workout: HKWorkout?
```

빌더가 운동 저장을 완료후, 빌더의 finishWorkout 기능을 호출하면 workout을 WorkoutManager에 할당한다.

```swift 
// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            self.running = toState == .running
        }

        // Wait for the session to transition states before ending the builder.
        if toState == .ended {
            builder?.endCollection(withEnd: date) { (success, error) in
                self.builder?.finishWorkout { (workout, error) in
                                             
                    // UI 업데이트를 위해 메인 스레드에서 이 할당을 수행.
                    DispatchQueue.main.async {
                        self.workout = workout // **이 부분**
                    }
                }
            }
        }
    }

```

이제 SummaryView가 사라지면 데이터를 reset 해줘야 한다. reset기능을 만들어 보자

**WorkoutManager**

```swift 
    @Published var showingSummaryView: Bool = false {
        didSet {
            if showingSummaryView == false {
                resetWorkout()
            }
        }
    }

    func resetWorkout() {
        selectedWorkout = nil
        builder = nil
        workout = nil
        session = nil
        activeEnergy = 0
        averageHeartRate = 0
        heartRate = 0
        distance = 0
    }
```

이제 SummaryView가 나타나기 전에 전에 전에 운동이 종료될 때의 진행률에 대한 뷰를 실행해 보자. 

먼저 workoutManager를 추가한다.

```swift 
    @EnvironmentObject var workoutManager: WorkoutManager
```

빌더가 운동 저장을 완료되고, workoutManager에 HKWorkout이 할당 될 때까지 ProgressView를 표시하려고 한다.

```swift 
struct SummaryView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) var dismiss
    @State private var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    var body: some View {
        if workoutManager.workout == nil {
            ProgressView("Saving Workout")
                .navigationBarHidden(true)
        } else {
            ScrollView {
                VStack(alignment: .leading) {
                ...
    }
```

- workoutManager의 운동이 nil이면 운동 저장 중이라는 텍스트와 함께 ProgressView를 표시하고 Navigation Bar를 숨긴다.