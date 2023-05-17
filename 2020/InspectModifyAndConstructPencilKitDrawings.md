# WWDC 2020 Inspect, modify, and construct PencilKit drawings

https://developer.apple.com/videos/play/wwdc2020/10148/
https://developer.apple.com/documentation/pencilkit/inspecting_modifying_and_constructing_pencilkit_drawings

펜슬킷의 데이터 모델인 PKDrawing에 관한 내용입니다~
시연 앱: 글자 쓰기 연습 앱. 빨간 점이 회색 글씨 위를 오가고, 회색 글씨 위에 일치도 높게 따라 쓰면 다음 글자로 넘어가는!!! 앱.

여기서의 핵심은 텍스트를 펜슬킷 드로잉으로 만들고, 애니메이션을 적용하고, 쓴 것을 인식한다. 의 세 가지
드로잉은 많은 수의 stroke(일단 획이라고 합시다)로 이루어진다.

시연 앱에서는, 소문자를 일단 손글씨로 먼저 다 써 둔 다음 텍스트를 인식하기 위해 각각의 글자를 나누었다.
그리고 각각의 글자(stroke)를 array의 원소로 접근한다. 드로잉은 획의 배열이기 때문.

그럼 획은 뭘까? 뭐가 스트로크를 만들까?
    path: 획의 모양. 펜이 지나간 경로.. 라고 할 수 있다.
    ink: 획의 외관. 색이나 타입.
    transform: 획의 시작점과 위치.
    mask
    renderBounds: 렌더링이 끝났을 때 획이 차지하는 공간을 감싸는.. 박스? 상술한 모든 프로퍼티의 영향을 받는다.

ink는 획의 외관을 결정하며, 잉크의 타입과 색을 말한다. 너비는 의외로 없다. 너비는 path에 따라 다를 수 있다.
path는 획의 모양을 묘사한다. path의 지점 지점에 따라 획의 모양은 달라질 수 있다.
    사실, PencilKit의 path는 stroke point들의 uniform cubic B-spline이다.
        cf) B-spline 곡선은 주어진 여러 개의 점에서 정의되는 매끄러운 곡선이며, 베지어 곡선과 함께 컴퓨터 그래픽 분야에서 널리 이용되는 곡선이다. 종류가 여러 가지 있는데, 이 중 uniform b-spline 곡선을 사용한다는 것.
        uniform b-spline은 knot vector가 균일하게 분포된 b-spline이라고 한다.
    그러니까, 보간법이랑 미분 등이랑 관련이 있다고 일단 알아두면 되겠다..
        여기서는, path의 내용물이 b-spline의 컨트롤 포인트라고 생각하면 된다는 것이다. 

이 때문에, path는 컨트롤 포인트의 배열이지만, draw 메서드를 통해 각각의 포인트를 그릴 경우 모든 포인트가 획 위에 있지는 않다. uniform cubic B-spline 곡선은 반드시 컨트롤 포인트를 지나지는 않기 때문. 실제 펜 경로 위에 있는 점을 얻어내려면, Interpolation(보간) 작업을 해 주어야 한다.
``` swift
// 이렇게 그리면 영 딴판인 경로가 나올 가능성이 높다
for point in path {
    draw(point)
}

// 이 메서드를 이용해 보간해줘야 한다
for point in path.interpolatedPoints(strideBy: .distance(50)) {
    draw(point)
}
```

상기 코드에서, distance값을 통해 그리는 점의 간격을 조절할 수 있다.
다만, 어떤 경우에도 획이 끝나는 지점에서의 마지막 점은 생성된다.
stride도 또한 거리뿐만 아니라 시간이나 매개변수값..? parametric value를 사용해도 된다.
``` swift
for parametricValue in path.indicies {
    draw(path.interpolatedPoint(at: CGFloat(parametricValue)))
}
```
포인트들의 인덱스를 찾아가는 시점에서, float를 넣어 줌으로써 원하는 위치에 있는 어떤 점이라도 탐지하고 그릴 수 있다.

또한 이렇게 경로를 되짚어갈 때, 일정하게(uniform) 그리는 것뿐만 아니라 parametricValue(offsetBy:)를 통해 임의의 거리만큼 떨어져 있는 점들 사이를 일정하지 않게 오갈 수도 있다. 
    글씨 연습할 때 유용하게 사용된다. 각각의 프레임마다 여기를 쓰세요~ 하면서 움직이는 빨간 점은, 이전 프레임으로부터 임의의 시간만큼 떨어져 있는 부분까지 indicate를 해 준다.
이게 중요한 이유? 애니메이션 프레임이 항상 일정한 간격으로 만들어져 있지는 않기 때문.
    어떤 기기는 30fps, 어떤 기기는 60fps, ...

``` swift
// 예시에 쓰인 코드
func stepAnimation() {
    let currentTime = Date()
    // 델타 타임을 먼저 구한다
    // 델타 타임이란 한 마디로 이전 프레임까지 수행하는데 걸린 시간.
    // 그래서 30프레임이면 초당 30개니까 보통 프레임당 0.033의 시간이 나와야 되고
    // 60프레임이면 그 절반 정도
    // 이게 왜 중요하냐면, 어쨌든 임의의 시간 동안 움직인 거리는 같아야 하기 때문
    let delta = currentTime.timeIntervalSince(animationLastFrameTime)
    
    // 이 델타값을 parametricValue에 넣어 줌으로써 획을 나눈다.
    // 이를 통해 유저가 글자를 쓰는 데 걸린 속도와 같은 속도를 만들 수 있다.
    animationParametricValue = path.parametricValue(
        animationParametricValue,
        offsetBy: .time(delta)
    )
    
    // 이 값을 통해 글자 위를 떠다니는 인디케이터, 빨간 점의 위치를 조정한다.
    markerLayer.position = path.interpolatedLocation(
        at: animationParametricValue
    )
    
    // 마지막으로 함수 외부의 animationLastFrameTime 프로퍼티를 업데이트해 준다.
    animationLastFrameTime = currentTime  
}
```

path 위의 컨트롤 포인트와 보간된 포인트 모두 펜슬킷의 스트로크 포인트랍니다~ 이것을 통해 path와 획을 쌓아나가는 것. 특정 위치에서의 획의 모양과 터치 정보를 모두 갖고 있으며, 살짝 압축해서 저장한다.

PKStrokePoint가 가지고 있는 것들 (외관)
    location: 포인트의 좌표
    size: 해당 포인트에서 획의 굵기 
    azimuth: rotation angle. 해당 지점이 수직과 얼마나 각도 차이가 나는지
    opacity: 투명도

PKStrokePoint가 가지고 있는 것들 (터치 정보) -> 얘네를 인식해서 가해진 힘에 따른, 펜의 각도에 따른, 쓰여진 시간에 따른 획의(잉크의) 모양을 임의로 정해줄 수 있다.
    force: 가해진 힘
    altitude
    timeInterval: 획이 시작되고 나서 얼마 후에 만들어졌는지. 획의 시작점으로부터의 거리를 나타낸다라고도 볼 수 있음

그리고.. 아까 잠깐 미뤄뒀던 마스킹.
마스크된 획은 어떻게 만들어지냐? 픽셀 지우개로 획을 일부만 지웠을 때 만들어진다.
이 마스크라는 프로퍼티를 통해 유저는 지우개 상호작용할 수 있다.
만약 캔버스에서 획을 끊는 지우개를 수행했을 경우, 각각의 부분이 독립된 획으로 기능하게 된다.
    아까 하던 대로 포인트를 가져오면 그런데, 나눠지지 않은 획의 포인트 정보들이 나온다.
    이를 방지하기 위해..
``` swift
// 마스킹을 수행하고 난 뒤의 범위만 카운팅한다
for pathRange in stroke.maskedPathRanges {
    for point in path.interpolatedPoints(
        in: pathRange, 
        strideBy: .distance(50)) {
        draw(point)
    }
}
```
이를 통해 일정 부분만 움직이던지 하는 컨트롤을 구현할 수 있다.

마스킹된 포인트의 범위는 하나도 없을 수도 있고, 여러 개 있을 수도 있다. (13:40)
    예를 들어 획의 중심부를 포함한 거의 모든 부분을 지우개로 지웠다면, path 위의 포인트들이 전부 지워진 것이라고 인식한다.
    아니면 획의 중심부쯤에 구멍이 뽕뽕 뚫린 획이라면, 여러 개의 마스킹 범위가 존재할 수도 있다.

# 참조
https://ko.wikipedia.org/wiki/B-%EC%8A%A4%ED%94%8C%EB%9D%BC%EC%9D%B8_%EA%B3%A1%EC%84%A0
https://wergia.tistory.com/313
https://developer.apple.com/documentation/pencilkit/pkstroke
https://developer.apple.com/documentation/pencilkit/pkstrokepath (이거 보다보니 publisher라는 프로퍼티도 있네요. 거쳐가는 점에 따라 퍼블리싱을 해주는 프로퍼티인듯)
https://developer.apple.com/documentation/pencilkit/pkstrokepoint
