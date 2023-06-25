# WWDC스터디 
## Meet SwiftData WWDC2023

## 스위프트 데이터는 원할한 API경험을 위해 매크로가 제공하는 표현력에 의존한다.(매크로?)

### Using the model macro
> @Model

- 스위프트 코드에서 모델의 스키마를 정의하는데 도움이 되는 스위프트 매크로이다.

- 스위프트 데이터는 기본적으로 타입으로 즉시 사용할 수 있도록 값 타입으로 조정한다? (기본 타입들이 지원됨)
- 구조체, 열거형, 코더블 등을 포함할 수 있다

@Model -> 은 모든 저장 프로퍼티를 수정한다.

@Attribute(고유성 제약조건을 추가할 수 있다.)
@Relationship(반전 선택을 제어 전파규칙 삭제: 모델 간의 링크 동작을 변경)
등을 사용하여 프로퍼티를 컨트롤할 수 있다.
- cascade: 특정 프로퍼티가 삭제될때마다 연관프로퍼티를 삭제하도록 할 수 있음

@Transient : 특정 프로퍼티를 포함하지 않도록 할 수 있음
![](https://hackmd.io/_uploads/HJQF8l0Dh.png)


### Working with your data
#### Model Container(모델 유형에 대한 영구 백엔드를 제공?)
- 스키마를 지정하기만 하면 기본설정 혹은 구성 및 마이그레이션 옵션으로 사용자 정의를 할 수 있다.

#### ModelContext
> 모델에 대한 모든 변경사항을 관찰하고 이에 대해 작동할 많은 작업을 제공한다.

- 업데이트 추적
- 데이터 패칭
- 변경 사항 저장
- 변경사항 실행 취소

![](https://hackmd.io/_uploads/BkdGZWCw2.png)

컨텍스트가 있으면 데이터를 가져올 준비가 된 것이다.

#### Fetching your data
> 새 기본타입 2가지
1. Predicate(술어)
- NSPredicate를 완전히 대체한 타입
- #Predicate로 사용
- 자동완성도 쉽다?
- 타입을 설명?하는 느낌임
- 
![](https://hackmd.io/_uploads/HJMVzZCP2.png)
여행이 미래에 계획된 여행에만 관심있음을 나타낼 수 있음

2. FetchDesriptor
- FetchDesriptor타입을 사용하여 특정 predicate를 적용하여 내가 원하는 모델을 가져오도록 지시 할 수 있다.

    - SortDescriptor를 사용하여 특정 타이을 기준으로 정렬할 수 있다.
 ![](https://hackmd.io/_uploads/HJ2hGWAvn.png)

- Relationships to prefetch(프리패치할 관련객체 지정)
- Result limits(결과 수 제한)
- Exclude unsaved changes(저장되지 않은 변경사항 제외하는 옵션)

#### Modifying your data
> Basic Operations
- Inserting
- Deleting
- Sacing
- Changing
![](https://hackmd.io/_uploads/Hk3U7bRvh.png)
delete()
save()

> 모델 객체의 속성 값을 변경하는 것은 간단하다.
> 모델 매크로는 저장된 속성을 수정하여 모델 컨텍스트가 변경사항을 자동으로 추적하고 다음 저장 작업에 포함하도록 돕는다.

'Dive deeper SwiftData'보셈
### Use SwiftData with SwiftUI

- 스위프트UI를 쓰면 더 쉽다

#### View modifiers
- Leverage scene and view modifiers
    - SwiftUI를 사용하여 데이터 저장소를 구성하고 옵션을 변경하고 실행취소를 활성화하고 자동 저장을 전환할 수 있다.
![](https://hackmd.io/_uploads/S1qiEWRvh.png)

> @Query 프로퍼티레퍼 사용

#### Observing Changes
- @published가 필요 없다?
- SwiftUI는 자동으로 리프레시한다
