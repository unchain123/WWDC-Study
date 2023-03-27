WWDC 2021 Protect mutable state with Swift Actors

https://developer.apple.com/wwdc21/10133

Swift의 Actor에 대해 알아보고, 이 친구들이 어떻게 동시성을 활용한 프로그래밍에서 변화 가능한 상태를 보호해줄 수 있는지.

# Data Race

Race Condition에 대한 설명. 요약하면, 2개 이상의 다른 스레드가 동시성을 통해 같은 데이터에 접근하고 그 중 하나 이상이 값을 수정하는 경우. 
디버깅하기 개빡세다. 어디서 일어날지도 모르는데다가, 오류 재현도 쉽지 않기 때문.
Race Codition 혹은 Data Race는 공유 가변 상태에서 발생할 수 있다.

value semantic을 이용해 공유 상태를 없앨 수 있다.
값 타입에서의 변화는 지역적일 뿐만 아니라, Let은 바뀌지도 않으니 여러 동시성 태스크에서 접근하기 좋다.
Swift의 표준 라이브러리는 밸류 시맨틱을 준수한다.
```swift
var arr1 = [1,2]
var arr2 = arr1

arr1.append(3)
arr2.append(4)

print(arr1) // [1,2,3]
print(arr2) // [1,2,4]
```

이제 값 타입 관련 연산을 struct로 바꿔 보면 (물론 let으로 카운터 인스턴스를 만든 경우 값이 바뀌지 않는다)
``` swift
struct Counter {
    var value = 0

    mutating func increment() -> Int {
        value += 1
        return value
    }
}

var counter = Counter()

Task.detached {
    print(counter.increment())
}

Task.detached {
    print(counter.increment())
}

// 그냥 이런 식으로 쓰면 Race Condition이 발생할 우려가 있다
// 컴파일러가 오류를 내서 컴파일이 안 되고, 알려준다
// Mutation of captured var 'counter' in concurrently executing code

Task.detached {
    var counter = counter
    print(counter.increment()) // 1
    // 근데 이건 우리가 원하던 게 아니다
    // 결국은 공유 가변 자원이 필요한 때가 있는 경우가 분명 있다.
}
```

공유 가변 자원을 쓰기 위해, 일종의 동기화 로직이 필요하다.
이미 있는 걸로는
- 아토믹
- 락킹
- 동기 디스패치 큐
이것들은 쓸 때마다 항상 "정답"을 찾아 써야 한다. 그렇지 않으면 어차피 레이스 컨디션에 빠질 우려가 있다..

# Actor
짜잔~ 액터 등장.
Actor는 공유 가변 자원을 위한 동기화를 제공한다.
Actor는 자신들의 상태를 가지고 있고, 이것은 프로그램의 다른 부분들과 분리되어 있다. 이 상태(state)에 접근하려면 액터를 통해야만 한다. 액터에 진입하면, 액터의 동기화 메커니즘이 액터의 상태에 다른 코드가 동시적으로 접근하는 것을 원천차단하는 것을 보장한다. Swift 언어 단위에서!

Actor는 일종의 새로운 타입이다. 프로퍼티, 메서드, 이니셜라이저, 등등이 있을 수 있다.

``` swift
actor Counter {
    var value = 0

    func increment() -> Int {
        value += 1
        return value
    }
}

let counter = Counter()

Task.detached {
    print(counter.increment()) // 1 혹은 2
}

Task.detached {
    print(counter.increment()) // 2 혹은 1
}

// 다만, 비동기 태스크의 순서를 보장하지 않는 점은 여전하기 때문에..
```

actor 타입은 일단 타입에 접근하는 다른 코드가 실행이 완료될 때까지 다른 코드가 액터에 접근하지 않는 것을 보장한다.
어케 분리했누?

actor는 안에 있는 메서드를 await를 통해 비동기적으로 실행한다. 
``` swift
extension Counter {
    func resetSlowly(to newValue: Int) {
        value = 0
        for _ in 0..<newValue {
            increment()
        }

        assert(value == newValue)
    }
}

// 이 메서드도 actor 안에 있는 것이므로, 실제 실행될 때는 await로 실행된다.
```

Actor는 프로그램 안의 다른 비동기적 코드와 상호작용할 수 있기도 하다 당연히.

``` swift
actor ImageDownloader {
    private var cache: [URL: Image] = [:]

    func image(from url: URL) async throws -> Image? {
        if let cached = cache[url] {
            return cached
        }

        let image = try await downloadImage(from: url)

        // Potential bug: `cache` may have changed.
        cache[url] = image
        return image
    }
}

// actor기 때문에, 로우 레벨에서 data race를 방지할 수 있다.
```

메서드에 await 키워드가 있다는 건, 이 코드를 실행하는 시점에 함수의 실행이 미뤄질 수도 있다는 것을 뜻한다. 이 "미루는" 동작은 CPU 사용 권한을 포기하기 때문에, 프로그램 내의 다른 코드를 실행할 수 있게 되고, 이는 프로그램 전체 상태의 변화를 불러올 수도 있다. 
그럼 미뤄뒀던 함수를 실행할 때 의도치 않았던 상황 하에서 실행될 수도 있다는 것.
위의 이미지 다운로더에서.. 이미지를 다운로드받는 도중 서버에서 해당 URL의 이미지가 바뀌었다면? 각각의 태스크에서 캐시를 건드릴 것이고, 의도치 않은 현상이 발생할 수도 있다.

``` swift 
actor ImageDownloader {
    private var cache: [URL: Image] = [:]

    func image(from url: URL) async throws -> Image? {
        if let cached = cache[url] {
            return cached
        }

        let image = try await downloadImage(from: url)

        // Replace the image only if it is still missing from the cache.
        cache[url] = cache[url, default: image]
        return cache[url]
    }
}
```

# Actor Reentrancy

Actor 재진입은 데드락을 방지하고 작업을 진행하게 한다.
재진입을 이용해 코드를 잘 디자인하려면?
- 동기적 코드로 변경을 시전해라
- 코드 실행이 미뤄져 있을 때 액터 상태가 바뀔 수 있음을 인지하자

``` swift
// 아예 이런 식으로
actor ImageDownloader {

    private enum CacheEntry {
        case inProgress(Task<Image, Error>)
        case ready(Image)
    }

    private var cache: [URL: CacheEntry] = [:]

    func image(from url: URL) async throws -> Image? {
        if let cached = cache[url] {
            switch cached {
            case .ready(let image):
                return image
            case .inProgress(let task):
                return try await task.value
            }
        }

        let task = Task {
            try await downloadImage(from: url)
        }

        cache[url] = .inProgress(task)

        do {
            let image = try await task.value
            cache[url] = .ready(image)
            return image
        } catch {
            cache[url] = nil
            throw error
        }
    }
}
```

# Actor Isolation
Actor가 작동하는 근본.

액터도 프로토콜을 채택할 수 있다.

``` swift
actor LibraryAccount {
    let idNumber: Int
    var booksOnLoan: [Book] = []
}

extension LibraryAccount: Equatable {
    static func ==(lhs: LibraryAccount, rhs: LibraryAccount) -> Bool {
        lhs.idNumber == rhs.idNumber
    }
}
// 문제없다. static이고, 독립된 두 actor를 파라미터로 받으므로.

actor LibraryAccount {
    let idNumber: Int
    var booksOnLoan: [Book] = []
}

extension LibraryAccount: Hashable {
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(idNumber)
    }
    // nonisolated가 붙은 이유는 이 함수가 actor 밖에서 불려올 수 있지만 비동기적이지 않기 때문
    // 비동기적이야 "미룰" 수 있고, actor의 분리를 충족할 수 있다.
    // nonisolated를 붙임으로써 actor 밖에 있는 것으로 메서드를 취급할 수 있다.
    // 다만, 아무리 그래도 actor 밖에서 mutable한 actor의 프로퍼티에 접근할 순 없다.
}
```

``` swift
// 클로저의 경우
// isolated일 수도, nonisolated일 수도 있다.
extension LibraryAccount {
    func readSome(_ book: Book) -> Int { ... }
    
    func read() -> Int {
        booksOnLoan.reduce(0) { book in
            readSome(book)
        }
    }
}
// 이 경우는 isolated된 경우다.

// detached task는 actor가 다른 일을 하는 동안 코드를 동시적으로 처리한다. 그러면 안 되지.
extension LibraryAccount {
    func readSome(_ book: Book) -> Int { ... }
    func read() -> Int { ... }
    
    func readLater() {
        Task.detached {
            await read()
            // await을 써 줌으로써 비동기적으로 수행한다는 것을 명시해야 쓸 수 있다.
        }
    }
}

```

이 안에서 쓰이는 Book 타입이 값 타입이라면, 얘를 가지고 동작을 수행할 때 값이 복사되고, 복사된 값으로 뭘 하는 건 괜찮다.
근데 참조 타입이면, actor의 변수인 Book에 대한 참조가 생기는데, 이 참조의 원본은 Actor의 밖에서 공유되고 있으므로 데이터 레이스가 생길 수 있다.

# Sendable
이런 상황을 해결하기 위한 Sendable 타입. 각기 다른 액터 간에 값이 공유될 수 있게 하는 타입이다.
값 타입, 액터 타입이 Sendable하다.
클래스가 Sendable해질 수 있는 조건이 좀 있다.
- 자기 자신과 자식 클래스 모드 불변 데이터만 들고 있을 때
- 클래스 내부적으로 동기화를 진행할 때 (예를 들면 Lock을 활용해서)
이런 케이스 아니면, Sendable할 수 없다 클래스는.
함수는 @Sendable 접두어가 붙어야 Sendable하다.
    (여담 - 클로저가 참조 타입이고, 함수는 이름이 있는 클로저임을 생각해보자)\
Swift는 Sendable하지 않은 타입이 고유되는 것을 컴파일러 단에서 막는다.
Sendable도 프로토콜이니까, 적용시키면 된다 일단. Codable 적용시켰듯이.

함수(클로저)가 Sendable하려면, 로컬 변수를 캡처하면 안 된다. 클로저가 캡처하는 모든 것은 센더블해야 한다.
센더블 클로저는 동기적이면서 actor-isolated할 수 없다. 액터 밖에서 코드를 돌릴 수 있기 때문.
이런 것들을 컴파일러가 다 체크해 준다.

Sendable 표시가 된 함수는 그 자체로 비동기적 액션이 일어남을 말하기도 한다.

# Main Actor
특별한 액터.
메인 스레드에서 해야 할 일이라고 상식적으로 알고 있는 여러 가지가 있다. 하지만 너무 많은 것을 메인에 시키면 앱이 느려진다.
그래서 스레드를 분배하고, 메인 스레드에서 해야 했던 작업은 디스패치큐 메인을 활용하곤 헀지.

메인 스레드와 상호작용하는 거는 사실 액터와 상호작용하는 것과 비슷하다!
메인 스레드에서는 안전하게 UI를 업데이트할 수 있고, 메인이 아닌 곳에서 작업할 때는 메인과 비동기적으로 소통해야 한다는 거.

메인 스레드를 대신하는 액터가 메인 액터다.
메인 액터는 동기화를 메인 큐에서 수행한다. 디스패치큐 메인 대신 써도 된다.
Swift Concurrency에 기반한 액터를 통해 여러 곳에 퍼져 있는 코드 중 필요한 것을 메인 큐에서 실행하게 할 수 있다.
메인 액터 밖에서 부른다면, await하게 함으로써 실행될 때까지 기다려야 한다.
``` swift
// 1
func checkedOut(_ booksOnLoan: [Book]) {
    booksView.checkedOutBooks = booksOnLoan
}

// Dispatching to the main queue is your responsibility.
DispatchQueue.main.async {
    checkedOut(booksOnLoan)
}

// 2
@MainActor func checkedOut(_ booksOnLoan: [Book]) {
    booksView.checkedOutBooks = booksOnLoan
}

// Swift ensures that this code is always run on the main thread.
await checkedOut(booksOnLoan)

// 1과 2는 같은 거다. 적어도 작동은 그렇다.

```

타입도 MainActor일 수 있다. UI와 상호작용해야 하는 타입에 매우 유용하다.
``` swift
@MainActor class MyViewController: UIViewController {
    func onPress(...) { ... } // implicitly @MainActor

    nonisolated func fetchLatestAndDisplay() async { ... } 
}
```

# 참조
https://academy.realm.io/kr/posts/letswift-swift-performance/ (Value Semantics)
