# What's New in iOS Design [WWDC 2019]


## ✅ Dark Mode

>Support both light and dark mode

작년에 macOS 에 다크모드가 출시 되었고, 꽤 유명했다. 수년동안 사진과 비디오 앱은 다크 인터페이스를 사용했다. 왜냐하면 사진과 비디오를 명료하게 볼 수 있기 때문이다. 개인적인 취향으로 다크모드를 선호하는 사람들도 있다.
일반적으로, 모든 앱은 다크모드를 지원해야 한다. 왜냐하면 사람들이 다크모드를 설정하고 당신의 앱을 사용했을 때 앱도 마찬가지로 다크모드가 되어야 하기 때문이다.

### ☑️ iOS design system

#### Design Goals (ios 디자인 팀에서 고려한 것들)
- Maintain familiarity 
    - iOS 디자인 팀은 친숙하고 직관적인 ios 특성을 남겨두길 원한다. 디자인 시스템을 탈바꿈 했지만, 여전히 iOS 라고 인지할 수 있다.
- Platform consistency
    - 플랫폼 지속성. 
- Clear information hierarchy 
- Accessible
- Keep it simple

### Color

![](https://i.imgur.com/NrdyHqY.png)

>However, when you add support for separate appearance, you now have two parallel sets of colors to keep in sync with each other and manage.
>At this point, it becomes helpful to think about color in a more abstract way.

위와 같이 다크모드일 때와 라이트모드일 때 color value 를 다르게 가져야 한다. 이를 위해 Semantic color가 등장했다. 

Semantic color는 value 값 보다는 그 목적을 묘사한다.
iOS 13은 당신을 위해 semantic colors 를 포함한다.

### Semantic colors

![](https://i.imgur.com/mGLuy29.png)

위와 같이 title의 color를 label 로 지정하면 라이트모드 다크모드에 둘다 대응이 가능하다. 

정보 계층을 표현하기 위해 많은 색상이 `primary`, `secondary`, `tertiary`, `quaternary` 값을 가진다.
![](https://i.imgur.com/VU0wcg2.png)
![](https://i.imgur.com/Ahk8Mq8.png)

![](https://i.imgur.com/XtInoOb.png)

![](https://i.imgur.com/DY9CssN.png)

사용자에게 비슷한 색상대비를 제공하기 위해 라이트모드일 때와 다크모드일 때 테이블뷰 행은 배경보다 더 밝은 색상으로 설정했다.

![](https://i.imgur.com/ydCzG9U.png)

새로운 system pallete에 fill colors와 separator colors 가 있다. 
모든 fill color와 separator color중 하나는 semi-transparent 이다. 이는 다양한 배경색에 대조하는데 도움을 준다.

![](https://i.imgur.com/qj4CKFU.png)
![](https://i.imgur.com/siW6fA1.png)


새로운 pallete 는 완벽히 불투명한 6개의 회색을 가진다. 예를들어 겹치는 그림의 경우 투명도가 있으면 이상하게 그려지는데, 이를 막을 수 있다.
![](https://i.imgur.com/6RYZ6cU.png)

#### Tint Color

라이트모드와 다크모드에 대응할 수 있다. 

이제 Tint Color는 dynamic하기 때문에 각 모드에서 해당 색상을 고를 때 대비를 4.5 이상 가지도록 해야한다. 강력한 색상대비는 접근성과 사용성을 향상시킨다. 

#### Base and Elevated

> layer interface 

시각적 분리를 위해 사용한다. 

![](https://i.imgur.com/9lWsM6q.png)


### Materials (투명도 조절)

4 level 이 있다. 
`Thick`, `Regular(Default)`, `Thin`, `Ultrathin`
![](https://i.imgur.com/zbnqp24.jpg)



### Controls and bars

![](https://i.imgur.com/26lYvXt.png)

업데이트 내용에 Controls와 bars 가 포함되어 있다. 
Controls는 이제 sementic color로 그려져서 라이트모드와 다크모드에 잘 적용된다. UIKit을 이용하면 이렇게 자유롭게 사용할 수 있으니 시간들여서 커스텀 하려고 시도하지 말어라. 

### Custom controls
![](https://i.imgur.com/ReTLQQY.png)
>But of course, custom controls are often necessary. UIKit does not provide everything that you need. For example, UIKit doesn't provide a rating indicator. So, when you're making custom controls, you should use the system palette so that you don't have to do two different color treatments for Light and Dark Mode.

그렇지만 당연하게도 Custom control이 필요할 때가 있다. 예를들면 rating indicator를 만들 때인데, 이때 system palette를 이용하면 라이트모드와 다크모드일때 두가지 색상을 생각하지 않아도 된다. 

![](https://i.imgur.com/A4J0pdB.jpg)

네비게이션 바도 변경이 있다. 스크롤 시 네비게이션 타이틀이 위로 올라가는 점이 바뀌었다.


### SF Symbol

small, medium, large 스케일을 가질 수 있다. dynamic type 적용이 가능하다. 
bold 가능 
![](https://i.imgur.com/Z7XYuk0.png)

## ✅ Modal Presentation



![](https://i.imgur.com/IrQ8IVm.jpg)

카드형태로 올라오는 형식으로 바뀌었다. 뒤에 어떤 뷰가 깔려있는지 작은 틈으로 확인할 수 있다
맨 위를 잡고 내리면 modalView를 dismiss 할 수 있다. 하지만 cancel 버튼을 삽입해주는 것이 친숙하다.

#### Modals are for switching modes!
![](https://i.imgur.com/tgw4tYH.png)

모달은 모드를 바꾸는 것이다. 화면전환 효과나 애니메이션을 위해 Modal을 사용하는 것이 아니다. 
예를 들어 캘린더 앱에서. 해당 스케쥴을 탭하면 네비게이션으로 다음 화면이 전환되는 반면, 일정을 생성하거나 수정하는 화면은 Modal 로 띄워진다. Modal은 구분되는 새로운 workFlow로 바꿀때 사용한다.


## ✅ Contextual menus

3D터치시 사용할 수 있는 메뉴 [Peek and Pop]
![](https://i.imgur.com/7mCkWNP.jpg)

> Words on all devices

## 요약

전체적으로 새롭게 만들어진 기능에 대한 설명이 많고, 대부분 적용되어 있으니 소개만 간단하게 보아도 좋은 것 같다. 특히 textColor label 은 자주 사용하는 프로퍼티이고 다른 value 들도 존재하니 사용 해봐야 겠다는 생각이 든다. 
