# WWDC 2019 Introducing PencilKit

https://developer.apple.com/videos/play/wwdc2019/221/

애플 펜슬! 와!
아이패드에서의 사용자 경험을 뒤바꿀 수 있는 존재. 가장 특색있는 아이패드 경험.

iOS 13에서 레이턴시를 줄이고, 새로운 툴 팔레트를 제공하며, 펜슬킷을 런칭했고, Markup을 모든 곳에서 가능하게 했다.

# Great pencil experiences
무엇이 좋은 펜슬 경험을 만들까? 펜슬이 제공하는 모든 기능을 쓰는 것이 아닐지.
    필압, 각도, 기울기 등의 기능을 모두 활용하기.
1세대, 2세대, 크레용의 세 가지 펜슬이 있다.
    크레용은 정밀함과 각도(Azimuth), 기울기(Altitude)를 지원하고, 1세대는 거기에 더해 필압, 2세대는 거기에 더해 터치 제스처 인식을 지원한다.
    여담) 짭플펜슬은 크레용 기반이 대부분입니다

## 좋은 펜슬 경험 만들기
UIKit으로부터 터치 데이터 받기
Metal을 통해 렌더링하기
GCD를 통해 비동기적으로 이벤트 처리하기

### 펜슬은 어떻게 작동하나요
펜슬은 초당 240회 인식
펜슬이 수직이면 각도는 잘 인식 못 할 수 있음
필압 데이터는 약간 늦게 들어옴
원래는 이런 것들을 세세하게 컨트롤해줘야 한다.
    펜을 기울여서 마카처럼 그릴 때는 각도와 기울기를 인식한 것을 어떻게 처리해줘야 할까?
    펜을 뗀 후에, 마지막 필압 데이터를 받아올 때까지 연결이 살아 있어야 하는데, 이 경우는 어떻게 해야 할까?
    이 모든 것을 수행하면서, 화면과 펜슬 사이의 간격을 최대한 적게 유지하려면 어떻게 해야 할까?
        레이턴시를 줄이는 통상적인 방법: 메탈로 렌더링하거나 터치 지점 예상하기.
        하면 안 되는 것: 투명한 메탈 레이어, 효과를 덮어쓰지 않기.
거기다가 펜슬 탭 제스처를 통해 지우개와 펜을 바꾸려면? 이런 코드를 추가해줘야 된다.
``` swift
let interaction = UIPencilInteraction()
interaction.delegate = self
view.addInteraction(interaction)

func pencilInteractionDidtap(_ interaction: UIPencilInteraction) {
    switch UIPencilInteraction.preferredTapAction {
        // ...
    }
}
```

좋은 펜슬 경험 만들기, 참 어렵다. 근데 이걸 쉽게 만들어주는 API가 있다면 어떨까?

# PencilKit
잔짜잔~ PencilKit. (Applause)

펜슬킷은 운영체제 전반적으로 사용되고 있는 애플 펜슬 프레임워크.
코드 단 세 줄로 펜슬 기능을 추가할 수 있다.
``` swift
let canvas = PKCanvasView(frame: bounds)
view.addSubview(canvas)
canvas.tool = PKInkingTool(.pen, color: .black, width: 30)
```

예시 앱을 보여줍니다~
노트를 적거나, 그림을 그리거나. 다크 모드에 유동적으로 대응하는 것도 가능하다.
팔레트 UI는 화면 어디로든 옮겨갈 수 있다.
자 도구를 사용해 직선으로 그릴 수 있다.
벡터 지우개를 사용해 선을 따고, 픽셀(비트맵) 지우개를 사용해 "영역별로" 지울 수 있다.

PKCanvasView: 주로 그리는 공간.
PKDrawing: 데이터 모델. 획... 이라고 하면 되려나?
PKToolPicker: 도구함 인터페이스.
PKTools
    PKInkingTool
        .pen
        .pencil
        .marker
    PKEraserTool
    PKLassoTool

## PKCanvasView
화면을 이동할 땐 스크롤 뷰를 사용한다.
drawing을 통해 데이터 모델을 가져올 수 있다.
tool을 통해 상호작용 모드를 바꿀 수 있다.
변경을 감지하기 위해 delegate을 사용할 수 있다.

## PKDrawing
data로 변환할 수 있고, 이미지를 만든다.
더해지거나 변환도 가능하고, macOS에서도 쓸 수 있다.
썸네일을 만들 때 쓸 수 있다.
``` swift
    /// Helper method to cause regeneration of a specific thumbnail, using the current user interface style

    /// of the thumbnail view controller.

    private func generateThumbnail(_ index: Int) {

        let drawing = drawings[index]

        let aspectRatio = DataModelController.thumbnailSize.width / DataModelController.thumbnailSize.height

        let thumbnailRect = CGRect(x: 0, y: 0, width: DataModel.canvasWidth, height: DataModel.canvasWidth / aspectRatio)

        let thumbnailScale = UIScreen.main.scale * DataModelController.thumbnailSize.width / DataModel.canvasWidth

        let traitCollection = thumbnailTraitCollection

        thumbnailQueue.async {

            traitCollection.performAsCurrent {

                let image = drawing.image(from: thumbnailRect, scale: thumbnailScale)

                DispatchQueue.main.async {

                    self.updateThumbnail(image, at: index)

                }

            }

        }

    }
```

## PKToolPicker
화면 안에서 다이나믹하게 움직이는 툴 픽커. 펜 마커 펜슬 지우개 색깔선택 undo/redo 자 등등
``` swift
canvasView.tool = PKInkingTool(.pen, color: .blue, width: 10)
```

도구별로 가능한 획의 너비를 정할 수도 있다. 눕혀서 쓰면 칠하듯 써지는거. 그런 걸 구현하려고 할 때.
지우개는 PKEraserTool. .vector 지우개와 .bitmap 지우개를 선택할 수 있다.
선택을 위핸 PKLassoTool. 사용자가 선택한 범위가 "선택"되고, 드래그나 드랍, 복붙 등을 할 수 있다.
자 도구는 의외로 PKTool 계열은 아니다. 캔버스의 프로퍼티다.
``` swift
canvasView.rulerActive = true
```
그러면 PKToolPicker를 화면에서 어떻게 조절해야 할까?
얘는 뷰가 아니다. 캔버스 뷰와는 독립적인 존재이며, 화면 어디든 위치시킬 수 있다. Responder 기반의 오브젝트이다. 굳이 따지면 키보드에 가깝다.
``` swift
// iOS 13에서는 Singleton이지만, 
// 예제 프로젝트를 보면 iOS 14에서는 PKToolPicker() 인스턴스를 생성해줍니다. 
let toolPicker = PKToolPicker.shared(for: window)
toolPicker.addObserver(canvasView)
toolPicker.setVisible(true, forFirstResponder: canvasView)
canvasView.becomeFirstResponder()
```

팔레트가 안 보였으면 하고, 제한된 도구만 사용하게 하고 싶을 때도 활용할 수 있다.
다른 responder가 나왔을 때 팔레트가 보이게 유지할 수도 있다.
``` swift
public func set(_ visible: Bool, for responder: UIResponder)
```

컴팩트 레이아웃 UI도 있다. 아이폰같이 사이즈가 작은 기기에서 팔레트를 보여주려면 필요하다. (floating, docked라는 키워드가 있네용)
이 경우 고려해야 할 사항이 있다.
    컴팩트 ui가 캔버스를 가리지 않도록, 캔버스 뷰의 높이를 고려해 UI를 짜야 한다.
    undo, redo 버튼이 기본적으로 포함되어 있지 않다. 자체적으로 구현해야 한다.
``` swift
// 툴 픽커의 프레임이 바뀐 것을 감지
optional func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker)
// 바뀐 것을 토대로 컨텐츠 크기 조정
public func frameObscured(in view: UIView) -> CGrect
```

delegate을 통해 여러 변화를 감지할 수 있다.
    터치하기 시작했을 때: canvasViewDidBeginUsingTool
    터치가 끝났을 때: canvasViewDidEndUsingTool
    마지막 필압 데이터가 전달되었을 때: canvasViewDrawingDidChange

그림을 캔버스 뷰에 불러오거나, 줌을 하거나, 움직였을 때 canvasViewDidFinishRendering 메서드가 불려온다.

손가락으로 그리게 할 수도 있다. 이 경우 두 손가락으로 움직이면 스크롤하게 된다.
기본값은 펜으로 그리고 한 손가락으로 스크롤.
``` swift
var allowsFingerDrawing: Bool { get set }
```

드로잉 제스처 자체를 인식할 수도 있다. (개인적으론 여기서까지 제스처를 쓰고 싶지 않아..)
``` swift
var drawingGestureRecognizer: UIGestureRecognizer { get set }
```

이외에..
``` swift
// 캔버스가 보이는 것에 대한 옵션
canvasView.opaque = false
canvasView.backgroundColor = .clear

// 다크 모드 관련 - 기본적으로는 지원하게 돼 있음
// 이건 항상 라이트 모드로 두는 코드
canvasView.overrideUserInterfaceStyle: .light
```

# Markup Everywhere
스크린샷 API에 관한 소개.
오른쪽 아래에서 삭 끌면 스샷 찍어지는거 아시죠?
상단에 screen과 full-page 세그먼트가 있는데, 후자로 전환하면 보이는 것 뿐만 아니라 보고 있는 페이지 전체를 스크린샷으로 남길 수 있다.
지도의 경우, 지도"만" 남길 수도 있다! 장소에 대한 상세설명 이런거 없이.
이것도 단 몇 줄의 코드로 구현할 수 있다.
``` swift
class DrawingViewController: UIScreenshotServiceDelegate {
    override func viewWillAppear() {
        super.viewWillAppear()
        view.window.windowScene.screenshotService.delegate = self
    }

    // 스샷을 pdf로 내보내주는 것. WWDC17 Introducing PDFKit on iOS 참조
    func screenshotService(UIScreenshotService,
                           generatePDFRepresentationWithCompletion:
                           (Data?, Int, CGrect) -> Void) {
        // ... 
    }
    // indexOfCurrentPage, rectInCurrentPage 프로퍼티가 있다.
    // 저 rect는 pdf 좌표로 이루어진다. 좌하단이 0, 0이기 때문에 iOS의 좌표계와 다르다.
    // 이걸 어떻게 잘 이어붙여서 풀 스크린 스샷을 만들라는 건가봐여..
}
```

# References
예제 프로젝트
https://developer.apple.com/documentation/pencilkit/drawing_with_pencilkit
