# What's new in UIKit WWDC2021 (23.04.26)

## Productivity

## iPad Multitasking
```swift
  let newSceneAction = UIWindowScene.ActivationAction({ _ in
            let userActivity = NSUserActivity(activityType: "com.myapp.detailscene")

return UIWindowScene.ActivationConfiguration(userActivity: userActivity)
        })
```
- 위의 코드 처럼 NSUserActivity를 반환하는 클로저를 사용하여 쉽게 iPad의 멀티태스킹을 지원해 줄 수 있습니다.

작업상황에 맞는 Activity만 만들어주면 됩니다.

### Pointer band selection
- iPadOS 15에서 밴드선택이 추가됨 (드래그로 여러개 선택하는 기능)
- UICollectionViews에는 기본적으로 밴드선택을 활성화 했습니다.


### pointer accessories

![](https://i.imgur.com/fSLGOLf.png)
여러 악세서리를 한번에 보여줄 수 있습니다.

###  Keyboard shortcuts
- 키보드 단축키 메뉴를 완전히 재설계 했습니다.
- ![](https://i.imgur.com/LpTYsZP.png)


![](https://i.imgur.com/kX8kvCk.png)
- 이것을 보여주려면 앱델리게이트에서 keyCommands를 설정합니다.
 여기 까지를 자세히 알아보려면 'Take your iPad apps to the next level'을 참고하세요

### UIFocusSystem
![](https://i.imgur.com/LWdHik1.png)

iPadOS 15에서는 포커스된 상태에서 화살표를 내리면 포커스가 이동합니다. 이게 이때부터 가능해졌다고 함 키보드 탐색이 기본적으로 활성화 됩니다.

Keyboard navigation에 대해 알고 싶으면 'Focus on keyboard navigation'을 참조


## UI refinements
![](https://i.imgur.com/cX9GpU1.png)

이 업데이트된 모양은 맨 아래로 스크롤할때 배경 자료를 제거하여 콘텐츠를 더 시각적으로 볼 수 있게 합니다.

UITabBar에서 SF심볼을 같이 쓰면 선택했을때 포커싱 되는 기능을 지원합니다.

![](https://i.imgur.com/IPgFTpG.png)

> tapBar의 상단부분을 커스텀 할 수 있습니다.
네비게이션바에서만 됐지만 이제 툴바랑 탭바에서도 가능

![](https://i.imgur.com/0u7ycg6.png)

> 특별히 스크롤 되야 하는 부분을 설정할 수 있습니다.

## 리스트헤더

- .plane
    - 섹션 머리글이 콘텐츠와 함께 표시되며, 디자인으로 섹션을 시각적으로 구분하기 위해 각 섹션 헤더 위에 새로운 패딩이 삽입되었습니다.
 ![](https://i.imgur.com/Pt0lRKF.png)

- .grouped
    - 사용자 정의 또는 시각적으로 풍부한 콘텐츠를 많이 포함하지 않는  UI에서 사용하기 위한 것입니다.

![](https://i.imgur.com/AtbLH8x.png)

예시 설정앱
-------여기까진 원래 있던거 ------
- .prominentInsetGrouped
    - 아이패드의 사이드바 목록에 사용되는 기존 사이드바 헤더 스타일과 유사합니다. 목록을 소형 크기 클래스의 insetGrouped목록에 적용시킬때 사용합니다.

- extraProminetInsetGrouped
    - 헤더가 계층구조를 유지하고 손실되지 않도록 시각적으로 풍부한 콘텐츠와 함께 사용할 수 있는 새로운 스ㅡ타일입니다.

워치앱 페이스갤러리

##  UIListSeparatorConfiguration

- Visibility
- Color
- Insets

전체목록에 대한 구성을 지정하거나 행별로 시스템 생성 모양을 재정의하여 구분 기호를 완전히 제어할 수 있습니다.

##  Sheet presentations
- 시트의 중간높이
    - 화면의 절반만 덮을 수 있습니다.
- 시트내부와 뒤에서 모두 상호작용할 수 있는 비모달 경험을 만들 수 있습니다.

## UIDatePicker
![](https://i.imgur.com/LAiagOA.png)

- 휠타입을 다시 도입하고 키보드를 올라오게 할 수도 있다.
- 아이패드의 매직키보드를 사용하면 인라인에서 바로 시간을 편집할 수도 있습니다.


## 버튼에 새로 추가된  API
![](https://i.imgur.com/gt0Uuy9.png)

텍스트 크기 설정에 대한 조정도 더 잘 지원하고 여러줄 텍스트를 공식적으로 지원합니다.(버튼 텍스트도 멀티라인 가능해짐)

> UIButton.Configuration

![](https://i.imgur.com/XTHq24U.png)
UIMenu추가 기능과 함께 pulldown을 구현할 수 있음

![](https://i.imgur.com/fvMwPPg.png)
Meet the UIKit Button System에서 확인

## Submenus
- UIMenu submenus
    - 접을 수 있는 하위 메뉴를 지원합니다

## SFsymbol 개선
추가 기호가 있을 뿐만 아니라 계층적, 팔레트 및 다중 색상의 세가지 새로운 방식으로 사용할 수 있는 기능을 추가했습니다.

![](https://i.imgur.com/TstSB1K.png)

![](https://i.imgur.com/g2QRVuz.png)

## Content size category limits

![](https://i.imgur.com/v9zLIcg.png)


## UIC?olor 개선
모든 플랫폼에서 시스템색상을 통일했다
![](https://i.imgur.com/MYoabLR.png)

UIColor.tintColor가 추가됨
    - 앱 또는 특성 계층 구조의 현재 색조 색상을 기반으로 런타임에 결정되는 색상입니다.
    
## Color picker개선
![](https://i.imgur.com/G92wmoC.png)
iOS 14.5에는 새로운 콜백인 colorpickerViewcontroller(didselect:continuously)가 있어 색상이 혼합되고 변경될 때와 선택이 완료될때 앱 UI를 업데이트할 수 있습니다.

## TextKit2
- 차세대 텍스트 레이아웃 시스템
'meet texkit'참고


## UIScene state restoration
> NsUserActivity represents interface state
> State restoration enhanceme nts9

iOS 15의 UIKit에는 앱이 각 장면에서 상호작용하는 현재 공유 가능한 콘텐츠를 나타낼 수 있는 새로운  API가 있습니다.

## scene level sharing

## Cell configuration closers
1. 컬랙션뷰와 테이크아웃 뷰

![](https://i.imgur.com/8q6I7Ny.png)
 
 UIButton Configuration API에서도 유사한 클로저 기반 메서드를 사용할 수 있습니다.
 
 ## Diffable data source improvements
 
 Apply snapshots without animation
 
 New API to reconfigure items
 
 ![](https://i.imgur.com/DkC7kc1.png)


## Performence
### Cell prefetching improvements
스크롤을 부드럽게 유지하면서 셀을 준비하는 데 최대 두배의 시간을 앱에 제공할 수 있습니다.

![](https://i.imgur.com/p5RKBbl.png)


## Swift async/await
출시했음

## Security and privacy
앱에 영향을 끼칠 수 있는 3가지

1.  LocationButton
![](https://i.imgur.com/FQbDxVa.png)
일회성 권한을 부여하는 버튼을 만들 수 있습니다 탭할때만 위치 권한을 받아오는 것임


앱이 다른앱의 페이스트보드에 복사된 데이터에 엑세스할때 표시됩니다.

2. standarad paste items
 몇가지 새로운 표준 붙여넣기 메뉴 항목을 제공하기 위해  API추가
- Paste
- Paste and Go
- Paste and Search
- Paste and Match style
등

때때로 앱은 클립보드의 새로운 정보를 원하지만 전체 엑세스 권한은 필요하지 않다.

계산기와 사파리에서 직접사용


Private Click Measurement
- 우리의 마지막 개인정보 보호 기능 향상은 iOS14.5의 새로운 기능이며 위치 및 붙여넣기 인터페이스를 지원하는 기술의 초기버전을 기반으로 합니다.
- UIEventAttributionViews
    - 웹킷팀과 할께 작업
- UIEventAttributionViews로 광고를 덮고 광고 탭에 대한 응답으로 여는 모든 URL과 함께 UIEventAttribution객체를 전달하기만 하면 됩니다.

![](https://i.imgur.com/lwVARo9.png)

