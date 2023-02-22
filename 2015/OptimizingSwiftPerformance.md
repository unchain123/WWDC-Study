# [Optimizing Swift Performance](https://developer.apple.com/videos/play/wwdc2015/409/)

```
2014년에 추가한 새로운 컴파일러 최적화에 대해서 알아보자!
```

## 2014년에 추가한 컴파일러 최적화

<img src="https://i.imgur.com/oPdJ8sf.jpg" width="500" height="300"/>

- Swift는 고도로 최적화된 네이티브 코드로 컴파일되는 매우 빠른 프로그래밍 언어이다.
- Swift를 빠르게 만드는 것이 바로 위 사진 속 컴파일러 최적화다.
- 위와 같은 컴파일러 최적화를 통해 상위 수준 기능의 오버헤드가 최소화 된다.


### 최적화된 프로그램 예시: bounds checks elimination (경계 검사 제거)

ex) 배열의 모든 요소를 숫자 13으로 암호화 하는 예제
```swift
for i in 0..<n {
	A[i] ^= 13
}
```
> 🤔 ^=는 뭘까?
> - 논리적 배타적 OR 결과를 왼쪽에 할당하는 연산자이다.
> - ex) 10 ^= 13 // 결과: 7


- 위 예제는 좋은 암호화가 아니다.
- 배열 범위 밖에서 읽고 쓰는 것은 심각한 버그이며, 보안에 영향을 미칠 수 있다.
- 이를 해결하기 위해 `precondition` 메서드를 통해 배열 범위 밖에서 읽거나 쓰지 않는지 확인하는 과정을 추가할 수 있다.

```swift
for i in 0..<n {
	precondition(i<length)
	A[i] ^= 13
}
```
- 그러나 여기에는 2가지 문제점이 존재한다.
- 첫번째로 이 검사로 인해 코드 속도가 느려진다.
- 두번째로 최적화를 차단한다.
> 🤔 'For example, we cannot vectorize this code with this check in place.' 가 무슨 의미일까?

```swift
precondition(n<=length)
for i in 0..<n {
	A[i] ^= 13
}
```
- 이 검사를 루프 외부로 끌어올리는 컴파일러 최적화를 구현하여 검사 비용을 무시할 수 있게 만들 수 있다.

> 🤔 그냥 처음부터 n대신 A.count를 쓰면 되지 않았을까?
> - count는 iOS 8버전이상 부터 쓸 수 있다.
> - iOS 8은 2014년 9월 17일에 나왔다.
> - 2014이전에는 count를 쓸 수 없었기 때문에 `precondition`을 쓰지 않았을까라고 추정한다.


### 최적화되지 않은 프로그램은 어떻게 성능을 가속화 할 수 있는가?

1. Swift 런타임 구성 요소를 개선
- 런타임은 메모리할당, 메타데이터 액세스등을 담당하는데 이걸 최적화 했다.

2. Swift 표준 라이브러리 최적화
- 표준 라이브러리는 배열, 사전 및 집합을 구현한 구성 요소이다.
- 따라서 표준 라이브러리를 더 잘 최적화함으로써 최적화되지 않은 프로그램의 성능을 가속화 할 수 있다.

<br>

## 결론
- 2014년 동안 최적화된 프로그램과 최적화되지 않은 프로그램 모두의 성능이 훨씬 더 좋아졌다.
- 그래서 Swift가 Objective-C보다 훨씬 빨라졌다. (아래 사진은 벤치마크 결과)
- Objective-C에서는 컴파일러가 Ob-C 메시지 전송을 통한 동적 디스패치를 제거할 수 없기 때문이다.
> 🤔 벤치마크(Benchmark)는 뭘까?
> - 비교평가
> - 컴퓨터의 부품 등의 성능을 프로그램을 이용하여 비교, 평가하여 점수를 내는 결과이다. (출처: 위키백과)

<img src="https://i.imgur.com/OopcJub.png" width="500" height="300"/>

<br>
<br>
<br>

---

<br>

```
Whole Module Optimization과 
Xcode가 파일을 컴파일하는 방식에 대해서 알아보자!
```

## Whole Module Optimization (WMO)
- WMO는 새로운 컴파일러 최적화 모드이다.
- 프로그램을 훨씬 빠르게 실행할 수 있다.

### xcode가 파일을 컴파일하는 방식

#### WMO 이전 방식

<img src="https://i.imgur.com/qADcnWA.png" width="500" height="300"/>

- Xcode는 파일을 개별적으로 컴파일 한다.
- 개별적으로 컴파일을 하면 컴퓨터의 여러 코어에서 많은 파일을 병렬로 컴파일 할 수 있다.
- 또한 업데이트가 필요한 파일만 다시 컴파일 할 수도 있다.
- 그러나 optimizer가 하나의 파일 범위로 제한된다.

#### WMO 방식

<img src="https://i.imgur.com/fCCQUSu.png" width="500" height="300"/>

- 전체 모듈을 한번에 최적화 할 수 있다.
- 모든 것을 분석하고 적극적인 최적화를 수행할 수 있다.
- 그러나 기존보다 빌드가 더 오래 걸린다.
- 생성된 binaries는 일반적으로 더 빠르게 실행된다.

### Swift2에서 달라진 점
1. WMO 모드에 의존하는 새로운 최적화를 추가했다.
- 이로 인해 프로그램이 더 빠르게 실행될 수 있다.
2. 컴파일 파이프라인의 일부를 병렬화 할 수 있다.
- WMO 모드에서 프로젝트를 컴파일하는 데 시간이 덜 걸린다.

<br>

---

<br>

```
앱의 성능을 개선하는 데 사용할 수 있는 특정 기술에 대해서 알아보자!
```

## 1. Reference counting (참조 카운팅)
- 일반적으로 컴파일러는 도움 없이 대부분의 참조 계산 오버헤드를 제거할 수 있다.
- 그러나 참조 카운트 오버헤드로 인해 코드에서 여전히 속도 저하가 발생할 수 있다.

### 오버헤드를 줄이는 방법, 제거하는데 사용할 수 있는 두가지 기술

### 클래스에서 참조 카운팅 작동 방식
- 할당할 때마다 클래스 인스턴스의 참조 카운트를 유지하기 위해 참조 카운트 작업을 수행해야 한다.
- 메모리 안전을 유지해야하기 때문이다.

<img src="https://i.imgur.com/FY95M2k.png" width="500" height="300"/>

1. 변수 x 생성으로 참조카운팅 1이 증가한다. (총 참조카운팅: 1)
2. x를 할당받은 변수 y 생성으로 참조카운팅 1이 증가한다. (총 참조카운팅: 2)
3. y를 foo 메서드에 전달로 인해 참조카운팅 1이 증가한다. (총 참조카운팅: 3)
- 이 과정에서 임시 C타입인 c를 만든 다음, c에 y를 할당한다.
4. foo 메서드 종료 시, 임시 C타입도 소멸되어 참조카운팅 1이 감소한다. (총 참조카운팅: 2)
5. y에 nil을 할당하여 참조카운팅 1이 감소한다. (총 참조카운팅: 1)
6. x에 nil을 할당하여 참조카운팅 1이 감소한다. (총 참조카운팅: 0)

### 참조를 포함하지 않는 클래스

<img src="https://i.imgur.com/U67emAl.png" width="500" height="300"/>

- `Point`는 클래스 이므로 배열에 저장될 때 참조로 저장이 된다.
- 따라서 배열을 반복하며 루프 변수 p를 초기화할 때 실제로 클래스 인스턴스에 대한 새 참조를 생성한다.
- 그 다음 루프 반복이 끝날 때 p가 소멸되면 참조 횟수를 줄여야한다.
- Object-C에서는 NSRA와 같은 Foundation의 데이터 구조를 사용할 수 있도록 Point와 같은 간단한 데이터 구조를 클래스로 만들어야 하는 경우가 많다.
- 간단한 데이터 구조를 조작할 때마다 클래스를 갖는 오버헤드가 발생한다.
- 반면 Swift에서는 구조체를 사용할 수 있어 오버헤드 문제를 해결할 수 있다.
- 구조체가 본질적으로 참조 카운팅을 필요로 하지 않고, 구조체 안에 있는 속성이 클래스 타입이 아니면 속성도 참조 카운팅을 필요로 하지 않기 때문에 루프에서 모든 참조 카운트 오버헤드를 즉시 제거할 수 있기 때문이다.

### 참조를 포함하는 구조체

<img src="https://i.imgur.com/ATVjLKe.png" width="500" height="300"/>

- 사진 속 `User` 타입의 속성은 모두 값 타입이지만, 내부적으로는 내부 데이터의 수명을 관리하는 데 사용되는 클래스를 포함한다.
- 때문에 구조체 중 하나를 할당할 때마다, 함수에 전달할 때마다 실제로 5번의 참조 카운팅 수정을 수행해야 한다.
- 이 문제는 Wrapper Class를 사용하여 해결할 수 있다.
- Wrapper Class를 사용하여 참조 카운팅 횟수를 줄일 수 있지만, value semantic에서 reference semantic으로 바뀐다.
- 그래서 예기치 않은 데이터 공유 발생으로 예상치 못한 일이 발생할 수 있다.

<br>

## 2. Generic (제너릭)

### 동작 원리

ex) 두 개의 매개변수를 비교해 더 작은 것을 반환하는 min 메서드 예제
```swift
func min<T: Comparable>(x: T, y: T) -> T {
	return y < x ? y : x
}
```
- 로직은 간단하지만, 이면에서 훨씬 더 많은 일이 일어나고 있다.

```swift
func min<T: Comparable>(x: T, y: T, FTable: FunctionTable) -> T {
	let xCopy = FTable.copy(x)
	let yCopy = FTable.copy(y)
	let m = FTable.lessThan(yCopy, xCopy) ? y : x
	FTable.release(x)
	FTable.release(y)
	return m
}
```
- 실제 코드를 pseudo-Swift로 나타낸 형태이다.
- 컴파일러가 x와 y를 비교하기 위해 간접 참조를 사용하고 있다.
- 또한 컴파일러는 T에 참조 카운트 수정이 필요한지 여부를 알 수 없기 때문에 min T 함수가 참조 카운팅이 필요한 유형 T와 그렇지 않은 유형 T를 모두 처리할 수 있도록 추가 간접 참조를 삽입해야 한다.
- 여기서 발행한 오버헤드는 generic specialization이라는 최적화 기법을 사용하여 없앨 수 있다.
> 🤔 'these are just no-up calls into the Swift runtime'이 무슨 의미일까?

### Generic Specialization

ex) Generic Specialization 동작 예제
```swift
func foo() {
    let x: Int = ...
    let y: Iny = ...
    let r: min<Int>(x,y)
    ...
}
```

1. 컴파일러가 Generic Specialization를 수행할 때 먼저 min 및 foo에 대한 호출을 본다.
2. 일반 min-T 함수에 전달되는 두 개의 정수가 있음을 확인한다.
3. 컴파일러는 일반 min-T 함수의 정의를 볼 수 있으므로 min-T를 복제한다.
4. 일반 유형 T를 특수 유형 Int로 대체하여 이 복제 함수를 특수화한다.
5. 특수 함수가 Int에 대해 최적화되고 이 함수와 관련된 모든 오버헤드가 제거된다.
    - 불필요한 참조 카운팅 호출이 제거되고 두 정수를 직접 비교할 수 있다.
6. 컴파일러는 일반 min-T 함수에 대한 호출을 특수 min Int 함수에 대한 호출로 대체하여 추가 최적화를 가능하게 한다.

### Generic Specialization의 제한 사항 (visibility of the generic definition)

ex) visibility of the generic definition 예제
```swift
// File1.swift
func compute(...) {
    ...
    return min(x,y)
}

// File2.swift
func min<T: Comparable>(x: T, y: T) -> T {
	return y < x ? y : x
}
```

- 위와 같이 함수 정의와 호출이 다른 파일에서 이뤄지는 경우는 최적화가 되지 않는다. 
    - 파일이 각각 컴파일되기 때문에 File1에서는 File2가 아닌 일반 T함수를 호출하기 때문이다.
- WMO를 키면 전체 파일이 컴바일 되기 때문에 최적화가 가능하다.

<br>

## 3. Dynamic dispatch (동적 디스패치)

### API의 클래스 계층 구조를 제한하는 데 사용할 수 있는 Swift 언어 기능
1. 상속에 대한 제약 (final 키워드 사용)
- final 키워드를 사용하면 컴파일러가 하위클래스에 의해 재정의되지 않음을 알게 된다.
- 그래서 dynamic dispatch, indirection이 제거될 수 있다.

2. 엑세스에 대한 제약 (private 키워드 사용)
- private을 붙여도 더이상 override 할 수 없기 때문에 dynamic dispatch, indirection이 제거될 수 있다.

3. WMO 사용
- WMO를 키는 경우, 코드 변경 없이 컴파일러에게 더 많은 정보만 제공함으로써 컴파일러가 클래스 계층 구조를 이해할 수 있게 한다.
- 즉 internal 클래스에서도 모듈 내에 서브클래스가 없는 경우에 한해 direct로 고칠 수 있다.

<br>

## 결론

<img src="https://i.imgur.com/lbCvuTD.png" width="500" height="300"/>

- final 키워드를 사용하여 API의 의도를 전달하자.
- 릴리스 빌드에서 전체 모듈 최적화를 시도하자.
- 이 두가지르 수행하면 컴파일러가 API의 클래스 계층 구조를 더 잘 이해할 수 있으므로 사용자가 작업하지 않고도 동적 디스패치를 더 많이 제거할 수 있다.

<br>

---

<br>

```
Instruments를 사용해보자!
```

## Instruments 사용하여 애플리케이션의 성능을 개선해보기

<img src="https://i.imgur.com/1C27MMH.png" width="600" height="200"/>

- release모드로 놓고 빌드하고, time profiler를 켜보자.
- CPU 사용량 확인 가능하다.
- CPU 사용량이 폭증하는 부분을 찾아서 어디서 시간을 많이 먹는지 체크하라.
- 하위 작업을 포함하여 해당 함수 내에서 얼마나 많은 시간이 걸렸는지 확인 가능하다.
 
