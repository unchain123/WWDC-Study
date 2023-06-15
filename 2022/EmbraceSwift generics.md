
# WWDC22 Embrace Swift generics

- Model with concrete types
- Identify common capabilities
- Build an interface
- Write generic code

위 네가지 단계로 분리하여 농장 시뮬레이션을 위한 Generic 코드를 작성 해보겠습니다. 

### 1. Model with concrete types

```swift

struct Cow {
    func eat(_ food: Hay) {...}
}

struct Hay { // 건초
    static func grow() -> Alfafa {...}
}

struct Alfafa {
    func harvest() -> Hay {...}
}

struct Farm {
    func feed(_ animal: Cow) {
        let alfafa = Hay.grow()
        let hay = alfafa.harvest()
        animal.eat(hay)
    }
}
```

소에게 먹이를 줄 수 있게 되었습니다. 

⚠️ 하지만 말, 닭 같은 동물 유형을 더 추가하고 싶은 경우 어떻게 해야할까요? 

각각의 동물 타입을 만들어 농장에서 각각의 동물에게 feed 해주는 메서드를 overload를 통해 완성할 수 있습니다.

<img src="https://hackmd.io/_uploads/ByWq74vD3.png" width=400>

하지만 이 방법은 boilerplate 코드를 생성시키고 가독성이 좋지 않게 변합니다. 
이때 필요한 것이 일반화(Generalize) 입니다.

### 2. Identify common capabilities
> 동물간 공통적인 기능을 식별합니다. 

- 추상화 코드를 작성하고, 추상을 받는 구체타입에서 각각 다르게 동작하도록 구현하려고 합니다. 
- 이를 다형성이라고 부릅니다. 
- 여러가지 다형성
    - 1. 오버로드 = 함수가 받는 인수에 따라 함수의 기능이 달라집니다. (Ad-hoc 다형성이라고 부름)
    - 2. 서브타입 = 클래스 상속을 통해 부모타입의 특성을 물려받아 각기 다르게 기능할 수 있습니다. 
    - 3. 제네릭 
![](https://hackmd.io/_uploads/SkzTQVDw3.png)

- 위처럼 클래스를 이용해 다형성을 만들 수 있습니다. 그러나 as? 구문을 이용해 런타임에서야 구체타입을 확인할 수 있고. 이는 좋지 않은 흐름인 것 같습니다. 
```swift

class Animal<Food> {
    func eat(_ food: Food) {...}
}

class Cow: Animal<Hay> {}

class Horse: Animal<Carrot> {}

class Chicken: Animal<Grain> {}

```
- 이런식으로 Animal에 제네릭타입을 받도록 설정할 수 있지만, 꺽새 안에 각 동물이 소비하는 음식 타입을 하나하나 다 입력해주어야 하죠. 또 동물마다의 다른 타입의 어떤 것이 들어와야 한다면 꺽새 안에 들어갈 타입은 더 많아질 것입니다. 

### 3. Build an interface

- Animal 의 공통 능력을 추려봅시다. 
    - 특정타입의 음식
    - 음식을 소비하는 작업
- 우리는 위 같은 기능을 나타내는 인터페이스를 구축할 수 있습니다. 바로 프로토콜을 사용하는 것입니다. 
```swift
protocol Animal {
    associatedtype Feed: AnimalFeed
    func eat(_ food: Feed)
}

struct Cow: Animal {
    func eat(_ food: Hay) {...}
}

struct Horse: Animal {
    func eat(_ food: Carrot) {...}
}

struct Chicken: Animal {
    func eat(_ food: Grain) {...}
}
```

- 이제 제네릭 코드를 작성할 수 있습니다. 

### 4. Write generic code

```swift
protocol Animal {
    associatedtype Feed: AnimalFeed
    func eat(_ food: Feed)
}

struct Farm {
    func feed<A: Animal>(_ animal: A) {...}
}

// or

struct Farm {
    func feed<A>(_ animal: A) where A: Animal {...} // 복잡해 보인다. 
}

// 간단하게 표현하는 방법이 있다!

struct Farm {
    func feed(_ animal: some Animal) // 짠.
}

```

#### `some` 구문에 대하여
- `some Animal ` 에 들어올 타입은 Animal을 채택하고 있는 특정 타입입니다. 
- SwiftUI 에서 사용중인 `var body: some View` 에서의 some 과 같은 것입니다. 
- `some View` 에는 View 를 채택하는 어떤 타입이 들어올 것이지만, 구체적으로 어떤 타입인지는 알 필요 없습니다. 

#### 추상화 개념
- 특정 구체타입의 플레이스 홀더를 나타내는 추상 타입을 `Opaque Type` 이라고 합니다. 
- 대체되는  특정 구체타입을 `Underlying Type` (기본타입) 이라고 합니다. 
- Opaque 타입의 값이 사용되는 범위에서는 하나의 기본타입으로 고정이 됩니다. 
- 이렇게 되면 값을 엑세스 할 때마다 동일한 기본타입을 얻을 수 있습니다. (예시코드가 이따 나옴)

```swift
let animal: some Animal = Horse() // 1.이때는 animal의 타입이 Horse라고 타입추론이 됩니다.
animal = Chicken() // 기본타입이 고정 되어있기 때문에 이 경우 에러가 난다.

func feed(_ animal: some Animal) // 2. 파라미터로 Opaque타입이 이용될 때.
feed(Horse()) // feed 안에서 사용되는 animal 파라미터의 타입은 여기서 타입추론이 됩니다. 
feed(Chicken()) // 각 함수 scope 에서만 고정되면 되므로 이 경우 에러가 나지 않습니다. 
// 매개변수에서 사용하는 some 타입은 Swift 5.7의 신기능 입니다.

func makeView(for farm: Farm) -> some View { // 3.결과값으로 Opaque타입이 이용될 때.
    FarmView(farm) // 반환값에서 some View의 타입추론이 됩니다. 
}
// 프로그램의 모든 위치에서 호출할 수 있으므로 결과타입의 범위는 전역적입니다. 
// 그러므로 기본타입 고정이 되어야 합니다. 

func makeView(for farm: Farm) -> some View {
    if condition {
        return FarmView(farm)
    } else {
        return EmptyView()
    }
}
// 위 코드는 에러가 납니다. 위 경우는 함수에 @ViewBuilder 어트리뷰트를 붙여주어 (ViewBuilderDSL)
// 문제를 해결할 수 있습니다.

@ViewBuilder
func makeView(for farm: Farm) -> some View {
    if condition {
        FarmView(farm)
    } else {
        EmptyView()
    }
}

```

다시 농장으로 돌아와 Opaque 타입을 이용해 코드를 작성해보겠습니다.

```swift
protocol Animal {
    associatedtype Feed: AnimalFeed
    func eat(_ food: Feed)
}

struct Farm {
    func feed(_ animal: some Animal) {
        let crop = type(of: animal).Feed.grow()
        let produce = crop.harvest()
        animal.eat(produce)
    } 
    // 위 함수 범위 내에서 animal의 타입은 기본타입 고정되어있기 때문에 
    // 컴파일타임에 타입간 관계를 알고 있습니다. 

    func feedAll(_ animals: [???]) {}
}
```
- feedAll() 메서드를 구현하기 위해 들어가야 될 파라미터 타입은 뭘까요?
![](https://hackmd.io/_uploads/rJ8kV4DDh.png)
- 배열에서 some 키워드를 이용하면 이런식으로 동작 할 것입니다. 
- 이 때 사용할 수 있는 키워드가 `any` 입니다. any 키워드를 이용하면 런타임에 기본타입이 달라질 수 있음을 나타냅니다. 
- any 키워드를 사용하게 되면 정적 타입은 같지만 동적 타입이 달라집니다. 동적 타입은 런타임에만 알 수 있습니다. 

```swift
struct Farm {
    func feed(_ animal: some Animal) {
        let crop = type(of: animal).Feed.grow()
        let produce = crop.harvest()
        animal.eat(produce)
    } 
    
    func feedAll(_ animals: [any Animal]) { // any 키워드를 사용합니다.
        for animal in animals {
            //animal.eat() // 컴파일 에러가 납니다. 
            feed(animal) // animal 이 some Animal 로써 주입되기 때문에 안전하게 동작합니다.
        }
    }
}
```

- some 키워드를 이용하면 기본타입이 고정됩니다. 
- any 키워드를 이용하면 type erase(타입 소거) 를 제공합니다. 
    - type erase가 궁금하면 WWDC: Design protocol interfaces in Swift 를 참고해보세요.
- 변환이 필요하다는 걸 알 때까지 기본값으로 let-constant를 작성하는 것과 유사합니다. 
