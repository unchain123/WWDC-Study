# Migrate to SwiftData(WWDC 2023)

## Generate model classes
> Managed Object Model Editor도우미를 사용하여 스위프트 데이터 모델 클래스를 생성하는 방법을 살펴 봄

1. 첫번째 방법: CoreData managedObject를 사용하여 스위프트 데이터 모델을 생성하는 것
- 스위프트 데이터를 생성할 때 CoreData managedObject가 원래 필요하지 않지만 기존의 코어데이터 모델이 있는 경우 이것을 기반으로 만들 수 있다.
- 모델파일 선택 -> Editor -> Create SwiftData Code 
<img src="https://hackmd.io/_uploads/HJ9Srqr_h.png" width=200 height=200>


## Complete adoption
> 완전한 스위프트 데이터 채택흐름을 시연함



| 코어데이터 스택 | 스위프트데이터 스택|
| :--------: | :--------: |
| <img src="https://hackmd.io/_uploads/BJlcHqBun.png" width=100 height=200> | <img src="https://hackmd.io/_uploads/SkRMUcSu2.png" width=100 height=200> | 

> 스위프트 데이터로 완전히 마이그레이션 할 때 스위프트의 네이티브 언어 기능을 활용하기 위해 코어데이터 스택을 스위프트 데이터 스택으로 대체한다.

### **고려사항**
- 전환을 하기 전에 기존의 코어데이터 모델 디자인의 구성을 고려해야 한다. 코어데이터 모델 디자인이 스위프트 데이터에서도 지원되는지 확인해야 한다.

- 코어데이터에 정의된 각 엔티티에 대해 스위프트 데이터의 엔티티 이름 및 속성과 정확히 일치하는 해당 모델 유형이 있어야 함을 의미 한다.

#### Set up persistent stack
- 모델 클래스를 만든다.(앞서 작업한 스위프트데이터 코드를 말함)
- 이때 만든 파일을 사용할 준비가 되면 이전에 사용했던 코어데이터 관리 개체 모델 파일을 삭제하고 이 파일을 통해 모델을 관리할 수 있다.
- Persistence파일을 삭제할 수 있다.

#### Set up ModelContainer
- 스위프트데이터 스택에 대한 모델 컨테이너를 설정
<img src= "https://hackmd.io/_uploads/rkj8t9S_2.png" width=500 height=200>
- 그룹의 모든 window가 동일한 영구 컨테이너에 액세스하도록 하는 수정자이다. 여기서 이 컨테이너를 추가하면 모델 컨테이너에서도 기본 모델 컨텍스트를 만들고 설정한다.

<img src= "https://hackmd.io/_uploads/B1AA59Suh.png" width=500 height=100>

- 새로운 컨텍스트를 추가하려면 이렇게 하면 된다.


> 스위프트 데이터에는 컨텍스트가 변경된 후 UI수명 주기 이벤트 및 타이머에 대한 저장을 트리거하는 암시적 저장 기능이 있기 때문에 코어데이터의 컨텍스트에서 호출되는 명시적 저장을 제거하고, 코어데이터의 암시적 저장에 의존 할 수 있다.

<img src = "https://hackmd.io/_uploads/BJ8Ti5Sun.png" width=300 height=100>

#### 스위프트데이터에서 값을 가져오는 방법
@Query를 통해서 가져올 수 있고 출발 시간에 따라 정렬을 할 수도 있다.

## Coexists with Core Data
> 스위프트 데이터로의 완전한 전환이 사용사례에 적합한 솔루션이 아닐 경우 Core Data와 스위프트 데이터간의 공존을 소개

<img src = "https://hackmd.io/_uploads/BkLIncrd2.png" width=300 height=200><br>
<br> 
> 이 옵션은 코어데이터에 이미 일부 데이터가 있거나 단순히 스위프트데이터로 완전히 전환할 수 없는 다른 제약에 직면한 경우에 스위프트 데이터를 채택할 때 더 많은 유연성을 제공한다

<br> 

<img src="https://hackmd.io/_uploads/Hy7Aa9S_n.png" width=500 height=100>

<br><br>

- PersistentStoreDescription를 로드하기 전에 컨테이너 description에 URL을 설정하여 두 스택이 동일한 URL에 작성되도록 해야한다.
- 기록추적을 키는 옵션을 실행한다.(스위프트데이터는 자동) 이것을 키지 않고 코어데이터와 스위프트 데이터가 공존하는 경우 persistenceStore를 열려고 하면 저장소가 읽기 전용 모드로 전환된다.


### 공존이 적합한 옵션 몇가지 시나리오
1. 기존 클라이언트와의 하위 호환성을 허용하는 것이다.
- 스위프트 데이터는 iOS17 및 Sonoma에서만 사용가능하므로 현재 코어데이터 어플리케이션은 스위프트 데이터로 전환이 어렵다.

2. 스위프트 데이터로 전체 변환을 어렵게 하는 리소스 제약에 직면할 수 있다. 
- 일부만 변환하여 부분적으로 통합하는게 좋다.

### **고려사항**

1. NSManagedObject기반 엔티티 하위 클래스 또는 스위프트 데이터 클래스의 네임스페이스를 지정해야 한다. 충돌방지.( 클래스 이름을 변경하더라도 엔티티 이름은 동일하게 유지된다.)

2. 코어데이터 및 스위프트 데이터 스키마를 동기화 상태로 유지해야 한다. ??
- 이것은 프로퍼티와 관계가 완전히 동일한 방식으로 모델에 추가되어야 함을 의미한다. 이렇게 하면 잠재적으로 마이그레이션을 트리거하고 제거하고 싶지않은 정보를 삭제할 수 있으므로 엔티티 버전 해시가 모든 단계에서 일치하게 된다.??
( 뭔소린지 모르겠음)

3. 공존을 통합할 때 스키마 버전을 추적해야한다
- 여러 버전의 스위프트 모델로 작업할 때 스위프트 데이터가 차이점을 평가할 수 있도록 변경 사항이 올바르게 표시되는지 확인해야 한다.(Model your schema with SwiftData봐라)

## 추가 고려사항
UIKit & AppKit

1. Bind to Core Data / 공존 솔루션
- UIKit코드를 코어데이터에 바인딩할 수 있으며 스위프트데이터와 병렬로 작동할 수 있다.

2. 스위프트데이터 클래스로 취급
- 스위프트데이터 클래스를 스위프트 클래스로 취급하고 스위프트 코드를 UIKit코드로 래핑할 수 있다.

뭔말이야

