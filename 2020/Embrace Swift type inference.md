# WWDC스터디 05.31
# Embrace Swift type inference (WWDC2020)
- 스위프트에서 타입추론 수용

> 스위프트는 코드의 안정성을 유지하면서 간결한 구문을 달성하기 위해 유형 추론을 광범위하게 사용한다.

## What is typ inference?
> 타입추론을 사용하면 컴파일러가 주변 컨텍스트에서 이러한 세부 정보를 파악할 수 있을 때 소스코드에서 명시적 유형 주석 및 기타 장황한 세부 정보를 생략할 수 있다.

![](https://hackmd.io/_uploads/BJNK_yWUh.png)

![](https://hackmd.io/_uploads/HkeOrfNU3.png)
- filterBy는 필터링 하려는 keyPath이고 두번째는 해당 속성을 기반으로 목록에 스무디를 포함해야 하는지 계산하는 메서드입니다.(isIncluded)

- 스무디는 제목으로 필터링 되고 제목에 searchParase가 하위 문자열인 경우 스무디가 포함된다.

> 이 코드는 타입추론에 의존하는 코드이다. 그 원인을 알아보고 더 깨끗한 코드를 위해 타입추론을 활용하는 방법에 대해 얘기해 보자.

```swift
public struct FilterdList<Element, FilterKey, RowContent>: View {
    public init(_ data: [Element],
               filterBy key: KeyPath<Element, FilterKey,,
               isIncluded: @secaping (FilterKey) -> Bool,
               @ViewBulider rowContent: @escaping (Element) -> RowContent) //FilterdList가 타입에 이 클로저를 저장해야 하므로 escaping{}
// 마지막 매개변수는 데이터 요소를 ㅔ 매핑하기 위한 클로저이다.
    public var body: some View {}
}

```


```swift
// FilteredList.swift
public struct FilteredList<Element, FilterKey, RowContent>
public init (_ data: [Element],
filterBy key: KeyPath<Element, FilterKey>, isIncluded: @escaping (FilterKey) -> Bool, @ViewBuilder rowContent: @escaping (Element) -> RowContent)
}


FilteredList<Element, FilterKey, RowContent>(
smoothies as [Element], filterBy: \Element.title, as KeyPath<Element, FilterKey>,
isIncluded: { title (FliterKey) -> Bool in title.hasSubstring(searchPhrase) } ) { smoothie: Element -> RowContent in
SmoothieRowView(smoothie: smoothie)

```

1. FilterdList의 세 가지 유형 매개변수는 FliteredList뒤의 꺽쇠 괄호 안에 있는 호출 사이트에서 명시적으로 지정될 수 있습니다.
2. 위처럼 모든 타입을 다 알고 있을 필요가 없다. 타입추론 알고리즘은 소스 코드의 단서를 사용하여 누락된 부분을 채워 퍼즐을 해결합니다.


컴파일러의 소스 코드 오류가 있는 경우 퍼즐을 풀기 위해 타입추론 전략을 수정하는 방법에대해 얘기해보자

## Integrated error traking
(에러 추적)

1) 컴파일러는 모든 에러에 관련된 정보를 기록합니다.

2) 컴파일러는 타입유추를 계속하기 위해 휴리스틱을 사용하여 오류를 수정합니다.
(**휴리스틱이란 의미를 사전에서 찾아보면 '시간이나 정보가 불충분하여 합리적인 판단을 할 수 없거나, 굳이 체계적이고 합리적인 판단을 할 필요가 없는 상황에서 신속하게 사용하는 어림짐작의 기술'로 표현된다.Jul 22, 2022
**)

3) 타입추론이 완료되면 컴파일러는 수집한 모든 오류를 보고한다. 
4) 엑스코드 12, 스위프트 5.3의 많은 오류 메시지에 대해 통합오류추적이 도입되었다.

## 오류 수정
- edit -> behaviors ->
![](https://hackmd.io/_uploads/Sko6I7NIh.png)

이렇게 설정하면 빌드실패마다 프로젝트 전체의 모든 오류를 볼 수 있습니다

![](https://hackmd.io/_uploads/SyjYMiVIh.png)
