# WWDC 스터디 2주차 (23.02.28) - What's new in testing
## Time To Load
<img src = "https://i.imgur.com/NTvY9wC.png" width=400>


- 테스트 시간이 줄었다고 자랑함


<img src = "https://i.imgur.com/ep67tNJ.png" width=400>

- 테스트 파일 사이즈가 줄었다고 자랑

## Code coverage
- 커버리지 파일이 더 작아지고 읽기 및 쓰기의 속도가 더 빨라졌을 뿐 아니라 이전보다 더 정확해 졌다고 합니다!
    - 헤더파일을 근거로 들었는데.
    - 헤더가 C++내용이라 이해를 못해서 생략했어요
    - C++ 기반 코드에서 헤더가 커버리지에 안됐었나 봅니다.

### Code Coverage 기능
<img src = "https://i.imgur.com/BIwJqpU.png" width=500>

#### 1. Target Selection
- 코드 커버리지 활성화 비활성화 여부 제어할 수 있습니다.
- 활성화 된 경우 실제로 포함되는 대상을 제어하는 새로운 옵션이다
- 이건 써드파티를 사용하거나 다른팀에서 이미 테스트한 프레임워크를 제공하는 회사에서 일을 할 경우 중요할 수 있습니다.(메서드의 테스트 진행 여부를 파악하기 쉽기 때문에)

     ![](https://i.imgur.com/PeMiIqN.png)
(Xcode -> product -> scheme눌러서 들어갈 수 있음)
- 코드 커버리지를 모든 영역에 할 수도 있고 특정 타겟에만 할 수도 있습니다.

2. xccov(이게 무슨말인지 아시는분?)
- 커버리지 데이터를 자세하게 나타냄
- 사람이 읽을 수도 있고 기계가 파싱할 수도 있다.

### coverage Data
![](https://i.imgur.com/9Bywa0A.png)

- 코드 커버리지가 활성화된 상태에서 테스트가 실행되면 Xcode에서 두개의 파일을 생성한다.
- 이 커버리지 파일은 프로젝트의 파생 데이터 디렉토리에 있으며 추가로 결과 번들 경로 플레그를 엑스코드 빌드에 전달하면 파일도 결과 번들에 배치된다.
    - 첫번째는 xccoreport파일 확장자를 갖는 각 타겟 및 소스파일 및 기능에 대한 커버리지 백분율 라인을 포함합니다.
    - 두번째는 xccovarchive이며, 각 파일에 대한 실행 횟수를 포함합니다..

![](https://i.imgur.com/wDOJLYZ.jpg)
터미널에서 명령어를 통해 커버리지 데이터를 확인하는 방법인 것 같은데 이걸 GUI로 잘 만들어 놓은게 엑스코드에 있기 때문에 그러려니 하고 넘어가기로 할게요 자세히 아시는분 있으면 바로 말해주세요
(영상에서도 코드 커버리지를 보는게 가장 편리한 방법은 소스코드 옆에서 보는 것이라고 하고 있다.)

#### SourceEditor
```
DEMO
````
(Xcode -> product -> scheme눌러서 들어간 다음 Code Coverage의 다겟을 지정해서 원하는 것만 확인)
![](https://i.imgur.com/gDwOdMT.png)
- 위의 사진처럼 전체 커버리지가 84%인 이유를 찾아서 커버리지가 낮은 파일로 바로 들어갈 수 있다.

- 이렇게 커버리지가 부족한 부분을 파악할 수 있게 하는게 이번에 향상된 것이다

## Test selection and ordering

### Test selection

🤨 스위프트의 모든 테스트가 동일한 목적을 수행하는 것은 아니다. 특정 테스트 만 실행 하고 싶을 수도 있기 때문
- 특정 테스트를 비활성화 할 수 있다.
![](https://i.imgur.com/FoDLdsR.png)
- Automatically include new tests를 활성화하면 새롭게 작성되는 테스트가 자동으로 추가되고 그렇지 않다면 직접 선택한 테스트 목록만 실행할 수 있다.

### TestOrdering
🤨 테스트의 종류뿐만 아니라 테스트의 순서도 중요할 수 있다. 
<img src = "https://i.imgur.com/dcUkF3u.png" width= 400 height=150>
테스트는 기본적으로 알파벳 순이다
 이름을 바꾸지 않는 이상 순서대로 실행되는데 이렇게 되면 테스트 중 하나가 이전에 실행중이 다른테트에 암시적으로 의존하는 경우의 버그를 놓치기 쉽다.

#### Implicit Dependencies Between Test

![](https://i.imgur.com/rP2XDXX.png)
testA가 데이터 베이스를 만들고
testB가 데이터를 저장하고
testC가 이 데이터를 삭제하는 테스트라고 할때 순서대로 있으면 아무 문제가 없겠죠?
하지만 순서가 바껴서 testB가 먼저 시작되면 테스트는 실패합니다
![](https://i.imgur.com/PtOe909.png)

* 테스트간에 의도하지 않은 종속성이 업도록 하기 위해 새로운 테스트 무작위화 모드를 도입했다
    * 이 기능을 키면 테스트가 실행될 때마다 테스트가 무작위로 섞인다
    * 이 모드를 켠상태에서 테스트가 모두 통과 된다면 테스트가 실제로 독립적이라는 확신을 가질 수 있다.

## Paralle testing

![](https://i.imgur.com/qrufNHc.png)
```
개발할때 기본적으로 위와 같은 사이클로 진행되는데 이렇게 되면 테스트를 하는데 너무 많은 시간이 소요될 수 있다.
```
<img src = "https://i.imgur.com/qQolKEx.png" width=300>
- 동시에 테스트를 진행하여 걸리는 시간을 줄인다.

#### 한계점!!

1. 여러 대상에서 테스트 하는 경우에만 유용하다
2. Xcodebulid에서만 사용가능하므로 Xcode Server또는 Jenkins와 같은 지속적인 통합 환경의 맥락에서 주로 유용하다.

### Parallel Distributed Testing


| 직렬(기존) | 병렬 | 
| :--------: | :--------: | 
| <img src = "https://i.imgur.com/TpQYztf.png" width=400>   | <img src = "https://i.imgur.com/AWCOccT.png" width=400>| 

### Testing Architecture

#### Unit tests
- 테스트 번들을 로드하고 모든 테스트를 실행해서 Unit테스트가 실행되는 방식이다.

UI Test Runner
- 테스트는 여전히 번들로 컴파일 되지만 엑스코드가 생성하는 맞춤형 앱에 의해 로드 된다.(XCApplication말하는거 같음)

<img src = "https://i.imgur.com/mpuzyRh.png" width=200>
병렬 테스트에서는 러너를 이용하는건 같지만 여러 러너에게 테스트를 동적으로 배포한다. 

러너에 배포할때의 기준은 클래스입니다. 클래스를 기준으로 실행 됩니다.

### 러너에 배포하는 기준이 클래스 기준인 이유?
1. 앞서 얘기한 테스트 간에 숨겨진 종속성이 있을 수 있다
2. 둘째, 각 테스트 클래스에는 값비싼 계산을 수행할 수 있는 setUp 광 tearDoun Computation이 있다.(클래스를 하나의 실행기로 제한함으로써 이 메서드를 한번만 호출하면 되기 때문에 시간의 절약이 가능하다.)

### Parallel Testing on Simulator

<img src = "https://i.imgur.com/XEcwVKV.png" width=400>

- 시뮬레이터의 복사본을 생성해서 시작한다.

#### 😎 여기서 알아야 할 점!
1. 테스트 중에는 원본 시뮬레이터를 사용하지 않는다.
2. 복제본당 하나씩 앱의 여러 복사본이 있으며 각 복사본에는 고유한 데이터 컨테이너가 있다.(별도의 데이터 컨테이너에 엑세스 하기 때문에 해당 파일 수정 사항이 다른 테스트 클래스에 표시 되지 않는다.)
    - 실제로 다른 복제본에서 실행 된다는 사실이 테스트에서 보이지 않을 가능성이 높지만 알고 있어야 한다.


<img src="https://i.imgur.com/Ch5O5Ef.png" width= 400>

### Tips and Tricsk
- 장기 실행 테스트 클래스를 두개의 클래스로 분할하는 것을 고려해라
- 성능 테스트를 병렬화가 비활성화된 자체 번들에 넣어라
    - 성능 테스트는 시스템 활동에 매우 민감하므로 서로 병렬로 실행하면 기준선을 충족하지 못할 가능성이 높기 때문
- 어떤 테스트가 병렬화에 안전하지 않은지 확인해라
    - 대부분의 테스트는 병렬로 실행할 때 문제가 없지만 테스트가 파일이나 데이터베이스와 같은 공유 시스템 리소스에 엑세스하는 경우 동시에 실행할 수 있도록 명시적인 동기화를 도입해야 할 수 있다.
