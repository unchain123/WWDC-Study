
# WWDC22 Eliminate data races using Swift Concurrency

> Swift Concurrency 를 이용하여 data races 를 제거해봅시다 !

> 요약 : @Sendable 을 사용해서 


## 1 . Task isolation

격리에 대해 이야기 합니다.
Task란 무엇일까요? Task는 순차적, 비동기적, 독립적으로 동작합니다. 여기선 하나의 Task 를 하나의 보트로 비유해서 설명합니다.  보트들이 완전히 독립적 이라면, 데이터레이스를 걱정할 필요가 없지만, 보트끼리 소통할 방법이 없다면, 그다지 유용하지 않을 겁니다. 

![](https://hackmd.io/_uploads/SkgOfVvw3.png)


- 한 보트에서 다른 보트로 파인애플을 옮긴다고 가정해봅시다. 
```swift
enum Ripeness {
    case hard
    case perfect
    case mushy(daysPast: Int)
}

struct Pineapple {
    var weight: Double
    var ripeness: Ripeness // 숙성도
    mutating func rippen() async {...}
    mutating func slice() -> Int {...}
}
```
- 값타입을 사용하게 되면, 객체를 공유하지 않기 때문에 data race 문제가 일어나지 않습니다. 
- 이런 특성은 값타입이 isolation을 유지하도록 합니다. (rippen이나slice 메서드를 실행시켜도 원본값에 영향을 미치지 않으니까!)
- 반면에 이런 치킨 Class 가 있다면 어떨까요? 
```swift
class Chicken {
    let name: String
    var currentHunger: HungerLevel

    func feed()
    func play()
    func produce() -> Egg {...}
}
```
![](https://hackmd.io/_uploads/BkCiM4wwh.png)


- 위와 같이 참조타입을 이용할 경우 한 보트에서 다른보트로 이동시킨 후, 각각의 보트에서 다른 메서드를 동시성으로 실행한다면 독립적이지 않게 됩니다. 
- 치킨 = shared mutable data (가변 공유 데이터) 입니다. 가변공유 데이터는 데이터레이스를 발생시킬 위험이 있습니다. 그래서 보트에서 다른보트로 치킨이 공유되지 않는지 확인하는 방법이 필요합니다. 

### Sendable

> Sendable 프로토콜은 데이터레이스를 발생시키지 않고 서로 다른 격리 도메인 간에 안전하게 공유할 수 있습니다.


![](https://hackmd.io/_uploads/BkkafEvwh.png)


- 위처럼 채택을 해보면 알 수 있습니다. Sendable 프로토콜이 채택 가능해야 데이터레이스를 발생시키지 않는다는 것을 보장할 수 있습니다. 
- 클래스는 참조타입 이기에, final class 에 불변 상수만 가지는 상태가 아닌 이상 sendable 할 수 없습니다. 
- 아래의 경우 Sendable 채택이 가능하지만

```swift
final class Chicken: Sendable {
    let name: String
}
```

```swift 
final class Chicken: Sendable {
    let name: String
    var birthDay: String // 가변상태 감지로 인한 오류발생
}
```

- @unchecked Sendable 를 이용하여 컴파일 타임에 진행되는 Sendable 검사를 건너뛸 수 있습니다. 다만, 안전보장이 되지 않으므로 주의해서 사용해야 합니다.
- 아래와 같이 함수의 타입에서도 Sendable 속성을 사용해줄 수 있습니다.  
![](https://hackmd.io/_uploads/ryOAGEvwh.png)

- 일반적으로 함수 유형은 프로토콜을 준수할 수 없습니다.

## 2. Actor
> Actor 를 이용해 가변상태를 격리시킬 수 있습니다. 


```swift
actor Island {
    var flock: [Chicken]
    var food: [Pineapple]

    func advanceTime()
}
```

- 위 코드로 구현된 섬은 동시성의 바다 위에서 각각 독립적인 상태를 가집니다. 
- 보트로 하나의 섬으로 가서 위 advanceTime() 메서드를 실행시킬 수 있습니다.
- actor 에는 한번에 하나의 보트만 접근 가능합니다.
```swift
func nextRound(islands: [Island]) async {
    for island in islands {
        await island.advanceTime()
    }
}
```

- 보트(Task) 와 섬(actor) 는 마찬가지로 가변데이터를 공유할 수 없고, Sendable 한 데이터만 공유 가능합니다. 
- Actor 는 참조타입 이지만, 모든 속성과 코드를 격리하여 동시 엑세스를 방지합니다. 
- 모든 Actor 타입은 암묵적으로  Sendable 합니다.

```swift

await myIsland.addToFlock(myChicken) // 불가능
myChicken = await myIsland.adoptPet() // 불가능

```


- 어떤 코드가 Actor에 의해 격리되어 있고 어떤 코드가 그렇지 않은지 어떻게 알 수 있을까요?

```swift

actor Island {
    var flock: [Chicken]
    var food: [Pineapple]
    func advenceTime() {
        let totalSlices = food.indices.reduce(0) { (total, nextIndex) in
            total + food[nextIndex].slice()
        }
    
        Task {
            flock.map(Chicken.produce)
        } // actor 격리를 상속한다. 
    
        Task.detached {
            let ripePineapples = await food.filter { $0.ripeness == .perfect }
            // 격리된 food를 참조하려고 await 을 사용하고 있다. 
            print("There are \(ripePineapples.count) ripe pineapples")
        } // 맥락에서 actor 격리를 상속하지 않는다. 독립적이기 때문, actor 외부에 있는 것으로 간주
        // 위 클로저를 non-isolated code 라 부른다. 
    }
}
```

- actor의 격리는 맥락에 따라 결정됩니다.  (이 부분 이해 불가)

#### non-isolated

```swift
extension Island {
    func meetTheFlock() {
        let flockNames = flock.map { $0.name }
        print("Meet our fabulous flock: \(flockNames)")
    }
}
```

- 어떤 actor 에게도 실행되지 않는 메서드를 말합니다. 
- 이 키워드를 사용하여 actor 외부에 배치하면, actor 내부의 기능을 명시적으로 `nonisolated` 키워드를 이용하여 비격리로 만들 수 있습니다. 
```swift
extension Island {
    nonisolated func meetTheFlock() {
        let flockNames = await flock.map { $0.name }
        print("Meet our fabulous flock: \(flockNames)")
    }
}
```

- 비격리 코드 예시를 하나 더 보겠습니다. 

```swift
func greet(_ friend: Chicken) { }

// 비격리, 동기 
extension Island {
    func greetOne() {
        if let friend = flock.randomElement() {
            greet(friend)
        }
    }
}


----

// 비격리, 비동기
func greetAny(flock: [Chicken]) async {
    if let friend = flock.randomElement() {
        greet(friend)
    }
}
```


### @MainActor

- 사용예시
```swift
@MainActor func updateView() {}

Task { @MainActor in
    // ..
    view.selectedChicken = lily
}

nonisolated func computeAndUpdate() async {
    computeNewValues()
    await updateView() // 이처럼 MainActor와 격리되지 않은 맥락에서 updateView를 호출하는
     //경우 MainActor로의 전환을 설명하기 위한 await 키워드를 사용해야 합니다. 
}


@MainActor
class ChickenValley {
    var flock: [Chicken]
    var food: [Pineapple]
    
    func advanceTime() {
        for chicken in flock {
            chicken.eat(from: &food)
        }
    }
}
```

## 3. Atomicity
>  원자성 

Swift Concurrency의 목적은 데이터레이스를 제거하는 것입니다. 
actor 는 한 번에 하나의 작업만 수행합니다. 하지만 actor에 대한 실행을 중지하면 해당 actor는 다른 작업을 실행할 수 있습니다. 이렇게 하면 프로그램이 `진행` 되므로 교착 상태의 가능성이 제거됩니다. 

그러나 await 구문에 대한 actor의 불변을 고려해야 합니다. 

```swift
func deposit(pineapples: [Pineapple], onto island: Island) async {
    var food = await island.food
    food += pineapples
    await island.food = food // 같은 actor 에 대놓고 접근하는 상황 -> 컴파일러가 오류 방출
}

// 위 코드는 오류를 발생

extension Island {
    func deposit(pineapples: [Pineapple]) {
        var food = self.food
        food += pineapples
        self.food = food
    }
}

// 이렇게 하면 동기 코드 이므로, 중단 없이 actor 에서 실행된다. 

// 비동기 actor의 경우 간단하게 유지하자. 주로 동기식 트랜잭션 작업으로 구성하고 각 await 작업시 actor 상태가 양호하도록 주의해야 한다. 

```


- 같은 actor의 상태에 접근하려는 2개의 await 사이에서 변하지 않는다고 가정했지만, await 은 다른 우선 순위가 높은 일을 하는 동안 우리 작업이 여기서 보류될 수도 있습니다. 


## 4. Ordering
> 동시성 프로그램에서는 여러가지 일들이 동시에 발생하므로, 이러한 일들이 일어나는 순서는 실행마다 다를 수 있습니다. 

- actor는 작업 순서를 지정하기 위한 도구가 아닙니다.
- actor 는 우선순위가 높은 작업 먼저 실행합니다. 우선순위가 낮은 작업이 동일한 actor 에서 우선순위가 높은 작업보다 먼저 발생하는 우선 순위 역전이 제거된다.  (직렬큐 FIFO 와는 상당한 차이가 있다. )
- Swift Concurrency 에는 작업 순서를 정하기 위한 몇몇 도구가 있습니다.
    - Task
    - AsyncStreams - 순서를 유지하면서도 스트림에 요소를 추가할 수 있는 이벤트와 생성자와 공유 가능하다.
     ```swift
        for await event in eventStream {
            await process(event)
        } 
    ```

- Swift 5.7 부터 Swift 컴파일러가 얼마나 엄격하게 Sendable을 검사해야 하는지 지정하는 빌드 설정을 도입했습니다. 

![](https://hackmd.io/_uploads/HJalmEwwn.png)

- 원래는 Sendable 을 채택해봄으로써 이 객체가 Sendable 한지 확인할 수 있었다면, 저 검사를 강력하게 하도록 설정하면 Sendable을 채택해보지 않고도 알아서 경고를 띄워주는 방식입니다. 
- 기존에 만들어놨던 모듈에 이러한 새로운 검사가 적용되어 불편한 경우도 있을텐데, 그럴 땐
```swift

@preconcurrency import FarmAnimals // @preconcurrency 키워드를 붙여주면 경고를 비활성화 해준다. 

func visit(coop: Coop) async {
    guard let favorite = coop.flock.randomElement() else {
        return
    }
    Task {
        favorite.play()    
    }
}

```

- Complete checking 을 이용해 모든 data race 를 제거할 수 있습니다.
- 이전 방식에서는 모든 항목을 검사하지만, 여기서는 모든 코드에 대해 검사를 수행합니다. 
- 점진적으로 엄격한 검사를 이어나가며 코드에서 오류 클래스를 제거합시다 !

## Reference
-   [Eliminate data races using Swift Concurrency](https://developer.apple.com/videos/play/wwdc2022/110351/)
