# [WWDC22] Explore navigation for iOS

> 사용자에게 친숙한 네비게이션 경험을 제공하는 것은 매우 중요합니다. 

## 1. Tab bars 
> 앱의 콘텐츠를 여러 섹션으로 분류해줍니다. 

- Use tabs to reflect your information hierarchy
- Balance features throughout tabs
- Avoid duplicating functionality into a single tab
- Keep tabs persistent throughout your app
- Use clear and concise labels

- 탭들 전반에 기능을 분배해서 인터페이스의 균형을 만들어 보세요.

    <img src="https://i.imgur.com/FpblQO6.png" width="200">
    <img src="https://i.imgur.com/OtzTvnN.png" width="200">

- 일부 기능들이 발견되지 못하고 사용자에 의해 사용되지 않을 수 있다는 염려에서 홈탭에 모든 기능을 꾸겨넣는 것은 좋지 않습니다. 
- symbol을 통해 탭의 의도를 한 눈에 알아볼 수 있도록 만들어 보세요.

## 2. Hierarchical navigation
> 높은 수준에서 더욱 세부적인 사항으로 파고들며 콘텐츠를 통과하며 이동하는 걸 문자 그대로 표현한 것입니다. 

- To traverse your app's hierarchy
- Keep the tab bar anchored to the bottom of the screen!!
- Use the navigation bar to orient people 
- Use with a disclosure indicator
- When navigating frequently between content

- 탭바가 있는 경우, 네비게이션 이동을 할 때 사라지지 않게 만들어야 합니다. 
- 네비게이션 이동을 한다고 표현할 수 있는 방법으로 disclosure indicator 가 있습니다. 
    <img src="https://i.imgur.com/G9o4twT.png" width="400">
- 아랍권 같은 곳은 반대로 구현합니다.
    <img src="https://i.imgur.com/cfSbPC9.png" width="400">
- 자주 화면전환이 일어난다고 생각되는 곳에서 Navigation을 이용하세요.
    - 카톡 채팅창 목록 -> 채팅창 화면전환 처럼 빈번히 일어나는 곳에 모달로 구현되어 있다면 왔다갔다 하는 작업이 힘들 것입니다. 

## 3. Modal presentations
> 앱의 계층을 횡단하고 뷰 사이를 전환하는 방법 중 침해가 없고 친숙한 방법입니다. 

- Present from the bottom of the screen
- Use for a simple task, multi-step, or full screen
- Dissmiss a modal with `cancel` and preferred actions
- Use close for minimal interaction
- Limit modals over modals

- 자립적인 작업이란? 
    - simple task (집중력↑, 실수로 다른 탭 눌러 흐름에서 벗어날 걱정 x)
    <img src="https://i.imgur.com/UW1hjCy.gif" width="300">
    
    - multi step (복잡한 작업에 모달 쓴다고 안좋다? x 목적은 집중력 강화)
    <img src="https://i.imgur.com/cHjJtDl.gif" width="300">
    
    - full screen
    <img src="https://i.imgur.com/HjqX24g.gif" width="300">
 
- 네비게이션 바에서 백버튼이 중요하듯이 모달에서도 cancel 버튼이 중요합니다. 
- 우측의 Add 버튼처럼 선호하는 동작을 의도한 경우 중요성 강조를 위해 굵은 폰트로 나타냅니다. 
    - 위 Add 버튼의 경우 모달에 여전히 입력이 없거나 상호작용이 없다면 비활성화를 시켜두어 입력이 필요하다는 것을 분명하게 알려줄 수 있습니다. 
    <img src="https://i.imgur.com/BhiEfR6.png" width="300">
    - cancel 탭시, 만약 입력이 있었다면 작업내역을 잃을 수 있다는 경고를 ActionSheet를 통해 알려줄 수 있습니다. 만약 작업내역이 없다면 cancel 시 바로 화면이 dismiss 될 것입니다. 
    <img src="https://i.imgur.com/cD3w1sM.png" width="300">
- X 버튼 (사용자의 입력이 필요하지 않을 때만 사용합니다.)
    <img src="https://i.imgur.com/Szv0d3l.png" width="300">
- X 버튼 사용의 잘못된 예시. ( x를 누르면 저장되는 것인가? 헷갈린다)
    <img src="https://i.imgur.com/ENm2HH0.png" width="300">

- 모달 위의 모달을 띄우는 것을 제한합니다.(다만, 모달 뷰 위의 사진추가를 위한 photo picker를 띄우는 것은 예외)

## References
- [WWDC22 Explore navigation for iOS](https://developer.apple.com/wwdc22/10001 )
