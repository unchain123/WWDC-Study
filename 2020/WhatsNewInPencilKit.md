# WWDC 2020 What's new in PencilKit
https://developer.apple.com/videos/play/wwdc2020/10107/

생각보다 짧네요

iOS13에서 추가된 펜슬킷~ 적은 레이턴시로 펜슬 사용하기
올해는 뭐가 바뀌었을까?
    - New features
    - Global setting: pencil or finger
    - New APIs

# New features
무엇보다도, 이 모든 기능은 코드 상에서 따로 더 구현할 필요 없이 사용가능
신기능 1: 손글씨 선택 기능!
    이미 쓰인 글자를 두번 탭하거나, 지익 끌거나 하는 식으로 손글씨 노트의 글자를 인식
    공백 공간을 탭하고 Insert Space를 선택하면 위 아래의 글자를 자동으로 인식하고, 사이를 벌려서 공간을 만들어 준다.

![[Pasted image 20230419165436.png]] 
(2분 8초)

신기능 2: 새로운 컬러 픽커!
    UIKit에서 쓰는 스탠다드 시스템 컬러 픽커를 제공. PKToolPicker에 기본적으로 달려 있나봐요?
    Build with iOS Pickers, Menus and Actions 세션을 참고합시다.

신기능..? 레이턴시 개선. 
    작년에는 레이턴시 때문에 블러나 시각 효과 같은 거를 집어넣지 말라고 했었는데, 이제는 그런 비주얼 이펙트를 집어 넣어도 레이턴시에 큰 지장이 없이 잘 작동된다.

맥 카탈리스트도 이제 지원한다구요~ 단, 툴 픽커는 제공하지 않습니다. PKCanvasView API로 직접 구현해줘야 함

# Global setting: pencil or finger
모두가 펜슬이 있는 건 아니잖아요.
13에서는 allowsFingerDrawing 프로퍼티를 통해 손가락으로 그릴 수 있냐 없냐를 판가름하게 했다.
14에서는 OS 전체 차원에서 설정이 일단 생겼다. 설정 - Apple Pencil에 들어가면 Prefer Only Pencil Drawing(한글로는 Apple Pencil로만 그리기) 토글 메뉴가 있다. 이 설정 자체는 펜슬킷을 쓰든 안 쓰든 적용할 수 있다. (애플의 뉘앙스로 보면 적용해야 한다에 가까울지도)

이 설정 자체는 아래 프로퍼티에서 액세스 가능하다.
``` swift
UIPencilInteraction.prefersPencilOnlyDrawing
// true일 때는 펜으로만 그릴 수 있음
// false일 때는 손가락 모드 펜 모드를 선택할 수 있게 됨
// iPhone에서는 기본적으로 false 고정
```

한편 펜슬킷을 사용한다면, 툴 픽커 오른쪽의 설정 탭에서 Draw with Finger(손가락으로 그리기) 토글을 조정하면 된다. 이 토글 설정값은 OS-Wide하게 적용돼서, 이 값을 바꾸면 설정에 있는 값도 바뀌고 모든 툴 픽커에서 값이 바뀌고.. 한다.

# New APIs
그래서 손가락, 펜슬 사용 정책에 액세스할 때는 이제...
``` swift
var allowsFingerDrawing: Bool // 이제 이 친구는 deprecated됐습니다!
// allowedTouchTypes 제스처 인식기도 넣지 않아도 됩니다.
var drawingPolicy: PKCanvasViewDrawingPolicy // 앞으로는 이 프로퍼티를 써 주세요

enum PKCanvasViewDrawingPolicy {
    case anyInput
    case pencilOnly
    case `default`
    // 디폴트 정책의 경우
    // 툴 픽커가 있을 경우 UIPencilInteraction.prefersPencilOnlyDrawing 값을 따르고
    // 툴 픽커가 없을 경우 pencilOnly와 같은 역할을 수행
}
```

톡톡 두 번 탭하면 스마트 셀렉션이 작동한다. 펜슬을 쓰고 있을 경우, 이를 통해 올가미 툴 없이도 선택과 필기 사이를 빠르게 오갈 수 있다.
만약 당신의 앱에서 펜슬만 쓰게 하고 싶다면?
``` swift
// 기본값은 true
let toolPicker = PKToolPicker() // 이것의 비밀은 바로 다음 섹션에
toolPicker.showPolicyControls = false
```
이렇게 해 줌으로써 선택지 자체를 없애버릴 수 있다.

이제 PKToolPicker를 싱글턴으로 만들지 않게 됐다!
``` swift
public func shared(for: UIWindow) -> PKToolPicker? // deprecated
public func init() // iOS 14 or newer
```
이를 통해 각각 독립적인 상태를 가진 툴 픽커들을 가질 수 있다. 대신! 이 툴 픽커 인스턴스에 대한 소유권을 항상 뷰가 가지고 있어야 한다.
두 가지 다른 캔버스 뷰를 지원하고, 각각이 추구하는 정책이 다를 때 유용하다.
``` swift
notesCanvas.drawingPolicy = .default
notesToolPicker.showsDrawingPolicyControls = true
notesToolPicker.selectedTool = PKInkingTool(.pen, color: .black, width: 2)

drawingCanvas.drawingPolicy = .anyInput
drawingToolPicker.showsDrawingPolicyControls = false
drawingToolPicker.selectedTool = PKInkingTool(.marker, color: .purple, width: 20)
```

또 iOS 14부터는 펜슬의 Stroke(획) 하나하나에 접근할 수 있게 됐다! 잉크, 경로, 포인트 등등..
    자세한 사항은 Inspect, Modify and Construct PencilKit Drawings 세션을 참조
    획에 접근함으로써 표시, 애니메이션, 인식, 머신 러닝까지도?! 넘볼 수 있다.

# 참조
https://developer.apple.com/documentation/pencilkit/pkcanvasviewdrawingpolicy
