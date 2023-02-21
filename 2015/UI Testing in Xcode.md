# UI Testing in Xcode(WWDC 2015)
📅 2023.02.22

WWDC 2015 |
🔗 [UI Testing in Xcode - WWDC 2015 - Videos - Apple Developer](https://developer.apple.com/videos/play/wwdc2015/406/)

## Overview

#### UI testing
- UI요소를 찾고 UI간의 상호작용과 상태에서 UI속성의 유효성 검사를 할 수 있다.

#### UI recording
- UItest를 빠르게 하기위함

### XCTest
- Xcode의 테스트 프레임워크
- 테스트를 만들고 메서드를 구현하고, 어설션으로 확인한다.

<img src = "https://i.imgur.com/Cu99Dt1.png" width=300 height=300>


### Accessibility
<img src ="https://i.imgur.com/lRBFIsf.png" width=150 >

- 접근성은 다른 사용자가 받는 경험을 장애인에게도 동일한 경험을 제공하게 할 수 있다.

![](https://i.imgur.com/RjdmJIA.png)
- UI테스트가 사용자가 하는 것처럼 애플리케이션과 상호작용한다는 것이다.

## UI Test Requirements
- OS의 기능에 따라 달라진다
- 개인정보를 보호한다.

Adding a UI testing target
Using recording
- 앱과 상호작용하여 요소를 사용하고 이벤트를 합성하는 코드를 생성

## UI Testing Xcode Targets
- 테스트중인 어플리케이션과 별도의 프로세스에서 실행된다.
- 개인정보보호에서 접근성을 사용하기 위한 권한도 처리한다.


## UI Testing API
### XCUIApplication - 내 앱의 프록시앱

<img src = "https://i.imgur.com/kZaxu7f.png" width=300 height=300>

- 앱의 생명주기와는 무관하다.(앱의 시작과 종료지점을 명시적으로 제어)
#### Lunch
- 시작할때 항상 새로운 프로세스를 시작한다.
    - 이미 실행 중인 경우 시작을 하면 기존의 인스턴스가 종료된다.

### XCUIElemnet
- XCUIApplication과 마찬가지로 프록시 객체이지만 UI요소에 대한 것이다.
- Types
    - Button, Cell, Window, etc.
- Identifiers
    - Accessibility identifier, label, title, etc
<img src = "https://i.imgur.com/OZxjYM2.png" width=400 height=300>
- 각각의 테스트에서 참조할 수 있는 요소
- 

### XCUIElementQuery
- Query는 단일 인스턴스로 확인되어야 한다. 그렇지 않으면 탭하라는 이벤트를 합성하려고 할때 이에 일치하는 버튼이 여러개 있을 수 있고 매치되지 않는다.


``` 
☞ 예외사항
- exists propert
    - element를 안전하게 테스트 할 수 있다.
    - 이것을 사용해서 element가 UI에서 제거되었는지 확인하거나 조건부 UI가 있는 경우도 처리 할 수 있다
- 예를 들어 다른 파일이 이미 있는 위치에 파일을 저장하는 경우 존재하는지 확인 가능하다. 
```
- XCUIElementQuery는 element를 지정하기 위한 API다.
- 쿼리는 접근가능한 요소의 컬렉션으로 구선된다.
    - count를 사용해서 요소의 개수를 알 수 있다.
    - 서브스크립트 사용가능
    - index도 접근가능

### Event Synthesis(이벤트 합성)

#### Simulate user interation on elements ( Realationships)
- 이벤트 합성은 사용자 상호작용을 시뮬레이션 하는 방법이고 시스템의 가장 낮은 수준에서 수행한다.
- 이벤트 합성을 위한 API는 플렛폼 별로 다름
<img src = "https://i.imgur.com/yxfylTU.png" width=300 height=300>
- Descendants: 하위의 모든 요소
- Children: 바로 하위의 요소만 해당
- Containment: 셀과 같은 요소가 서로 고유한 데이터가 많지 않지만 고유한 요소를 포함하는 경우에 매우 유용하다.

#### Filtering
- 필터링은 한 Set을 취하고 특정기준에 따라 Set을 줄이는 것이다
- 필터링을 사용하면 요소 또는 type 또는 해당 식별자와 같은 항목을 사용하여 이전 쿼리를 필터링하는 쿼리를 만들 수 있다.
<img src = "https://i.imgur.com/CYFGrRa.png" width=300 height=300>


### Combining Relationships and Filtering
## ```descendantsMatchiongType```
- 가장 일반적인 쿼리
<img src = "https://i.imgur.com/PnbdUHz.png" width=300 height=300>

descendantsMatchiongType을 이용해서 특정 요소가 있는 table의 셀을 제공하거나 찾을 수 있다.
<img src = "https://i.imgur.com/PeJH6Hf.png" width=300 height=300>
이 API가 이렇게 바뀌어서 사용되고 표현력이 뛰어나면서 간결하게 만드는데 도움을 준다.

## ```ChildrenMatchingType```
- 차별화에 매우 유용한 경우가 있다.
<img src="https://i.imgur.com/ccNDdiF.png" width=500 height=50>
- 특정 객체의 자식인 버튼 만 찾으려면 이렇게 사용할 수 있다.

## ```ContainingType```
- 이것을 통해 자손을 설명하고 요소를 찾을 수 있다
    - label의 값은 StaticText라고 한다.
<img src="https://i.imgur.com/s39RMln.png" width=400 height=300>

## Combining Queries
<img src="https://i.imgur.com/HBwV9ee.png" width=300 height=300>
- 쿼리의 강력한 점은 이것들을 합칠 수 있다는 것이다.
- Unix명령줄에서 명령을 함께 하는 것처럼 한쿼리의 출력을 가져와서 다음 쿼리의 입력으로 만들 수 있다.

### Getting Elements from Queries
- 모든 element는 쿼리로 지원된다.

```
Subscripting  ==> table.staticTests["Groceries"]
// 쿼리를 받은 다음 식별자를 사용하여 subscripting한다

Index   ==> table.staticTexts.elementAtIndex(0)

Unique ==> app.navigationBars.element
// 고유한 쿼리가 있는 경우 응용 프로그램에 탐색 모음이 하나만 있는 경우에는 element type을 사용하여 해당 쿼리가 지원하는 새 요소를 만들 수 있다.
```

### Evaluating Queries
쿼리는 평가가 필요하다.
#### XCUElement
- element를 사용하면 이벤트를 합성하거나 속성 값을 읽을 때 쿼리가 평가된다.(사용할 때 까지 평가되지않음)

#### XCUIElementQuery
- 쿼리를 직접 생성하는 경우에는 일치 항목 수를 얻거나 모든 일치 항목을 반환하는 API중 하나를 호출하면 쿼리가 평가된다.
- 해당시점에서만 평가하고 UI가 변경되면 재평가

## Queries and Elements
```Similar to URLs```
- URL을 만들 순 있지만 리소스를 직접 가져오지는 않는다. 실제 URL요청 또는 세션을 생성하기전까지는 아니다.
    - 즉 URL이 유효하지 않더라도 그 시점에는 오류가 발생하지 않는다.

- 쿼리와 요소는 테스트된 애플리케이션에서 엑세스 가능한 요소에 대한 사양일 뿐이다.

## API Recap
<img src="https://i.imgur.com/z0sDupv.png" width=500, height=300>

## Accessibility and UI Testing
- 접근성 데이터는 UI테스트가 가능하게 한다.
<img src ="https://i.imgur.com/mZQ9eGa.png" width=300 height= 300>
- 접근성 데이터가 좋을 수록 테스트작성이 더 쉬워지고 시간이 지남에 따라 테스트의 안정성이 높아진다.

### Not accessible
- Custom view subclasses
- 레이어와 같은 하위수준의 그래픽 하위 시스템에 있는 그래픽 개체

### Poor accessibility data
### Tools
- UI recording
    - UI레코딩은 테스트 시스템이 요소를 보는 방법에 대한 가장 가까운 view를 제공한다

## 
- Accessibility insperctors

접근성 데이터를 개선해야 하는 경우 인터페이스 빌더를 가장 먼저 중단해야 한다.
인터페이스 빌더에는 UI테스트에서 type으로 표현되는 방식에 직접적인 영향을 미치는 특성을 구성할 수 있는 뛰어난 accessibility insperctors가 있다.??

<img src="https://i.imgur.com/SE5jnkb.png" width=300 heigth=300>

여기서 이걸 확장하면 테스트중에 발생하는 모든 활동을 볼 수 있다.

<img src="https://i.imgur.com/DW3Sgux.png" width=500 heigth=700>

cell을 삭제하고 셀 속성이 있는지 확인하는 테스트이다.
여기서 elementAtIndex(1)은 디프리케이트 되고 현재는 element(boundBy: Int)를 사용한다.

![](https://i.imgur.com/B2zS5Wz.png)

- while루프를 이용하여 모든 셀을 삭제하는 테스트를 만듬

![](https://i.imgur.com/g8tEBUw.png)
- 인스펙터에서 접근성을 Enabled하게 만들어준다. (스토리보드 사용시)
- 그리고 이것들이 버튼은 아니지만 버튼 처럼 작동하기 때문에 button에 체크를 하고 UITest를 진행하면 각각의 레이블에 대해서 버튼을 탭하는 테스트를 만들 수 있다.

## Test Reports
### Show result for all tests(테스트에 관한 모든것을 보여줌)
- Pass/fail
- Failure reason
- Performance metrics(성능테스트에 대한 메트릭)
- 엑스코드서버와 엑스코드에서 동일한 UI를 얻는다.
- 엑스코드 서버에서는 여러 장치를 통합할 수 있기 때문에 장치별 결과도 얻을 수 있다.


UI testing addions
- New data
    - screen shot (영상에서는 쿼리가 실패햇을 때의 스크린샷을 가져와서 디버깅했음 스크린샷을 못찾겠음..)
- Nested activities

![](https://i.imgur.com/U5iOt8C.jpg)

## When to Use UI Testing
- Complements unit testing
    - Unit테스트를 대체하는게 아니라 보완 하는 것 
- Unit testing more precisely pinpoints failures
    - 로직에 대해 테스트를 계속해야한다. 단위 테스트가 더 정확하게 오류를 찾아내기 때문
- UI testing covers broader aspects of functionality
    - UI테스트를 통해서 더 광범위하게 기능을 다룰 순 있지만 오류를 추적하는 것이 더 여려울 수 있다.
- 유닛테스트와 UI테스트의 균형을 찾는것이 하나의 과제이다

## Candidates for UI Testing 

1. Demo sequence
- 고객에게 앱으로 사용하는 방법은 다음과 같습니다 라고 안내하는 데모 시퀀스는 UITest를 위한 훌륭한 후보이다.

2. Common workflows
- 앱의용도, 편집앱의 경우 문서 편집 방법 등

3. Custom Views

4. Document creation, saving, and opening
- 문서기반 워크플로우, 혹은 저장등은 자동화 하기에 좋다.
- 유닛테스트로는 힘들고 이게 잘못되면 사용자에게 큰영향을 미친다.

## Summary

- UI Testing
    - UI요소간의 상호작용을 찾고 사용자의 방식으로 구동되는 이벤트를 합성한다.
    - UI속성 및 상태의 유효성을 검사할 수 있다.
- UI recrding
    - 이것을 통해 테스트를 아주 빠르고 쉽게 만들 수 있다.
- Test reposts
    - 테스트작동 방식을 더 잘 이해하고 관련 추가 데이터를 수집할 수 있도록 테스트 보고서를 개편했다.

## More Information
![](https://i.imgur.com/v1zuL4S.png)

