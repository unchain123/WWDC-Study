[WWDC 2018 - iOS Memory Deep Dive](https://developer.apple.com/videos/play/wwdc2018/416/)

목차
    Why Reduce Memory?
    Memory Footprint
    Footprint Profiling Tools
    Image
    Optimizing when in Background
    Demo

** 오늘의 개념을 이해하기 위해 필요한 CS 개념으로 가상 메모리와 페이징이 있습니다 **

### 선 요약
메모리는 유한하고, 공유된 자원이다. 그러니까 메모리 사용에는 항상 주의하고, 필요한 만큼만 써야 한다.
Xcode의 메모리 리포트는 디버깅시 아주 중요하다.
이미지 렌더링 포맷을 올바르게 고르는 것만으로도 75%까지나! 메모리를 줄일 수 있다.
ImageIO 쓰는 것을 잊지 말자.
화면에 리소스가 없을 때, 리소스가 메모리에서 해제되게 하자.
Memgraph를 통해 더 섬세한 메모리 관리를 할 수 있다.

### Why Reduce Memory?
한 마디로, 사용자 경험이 좋아지기 때문..
앱이 빨리 켜지는 것 뿐만 아니라, 실행하다가 튕기는 일이 훨씬 덜 일어나고, 백그라운드에도 더 오래 남아있을 수 있다.

### Memory Footprint
메모리 사용 줄이기 - 사실은 Footprint를 줄여야 한다는 것. 
모든 메모리가 평등하게 할당되는 것은 아니다.
메모리 "페이지"
- 시스템에 의해 부여되며, 힙 공간에 여러 오브젝트를 가지고 있을 수 있다.
- Clean or Dirty
- 보통 16KB 사이즈
앱의 메모리 사용량은 사실 사용하고 있는 메모리 페이지의 갯수다.
메모리를 처음 alloc하면 클린하지만, 한번 쓰면 dirty해진다.
한편, 용량에 따라 완전히 꽉 채워지지 않은 페이지도 있기 마련이다.

Clean Memory
- paged out될 수 있는 메모리다.
    - 여기서 페이지 아웃이란, 가상 메모리에서 Page Fault가 발생했을 때 만약 메모리가 부족하다면, 메모리에 있는 내용 중 기록할 만 한 내용을 디스크에 기록하는 것을 말한다.
    - 참조 : https://brocess.tistory.com/269
- Memory에 할당된 파일이다. 이미지라던지 데이터 blob이라던지.
- 프레임워크. 모든 프레임워크는 DATA_CONST 섹션이 있다.

Dirty Memory
- 앱에 의해 쓰인 메모리
- heap allocation
- 디코딩된 이미지 버퍼
- 프레임워크의 DATA와 DATA_DIRTY 섹션

프레임워크를 두 번 언급했지? 프레임워크는 클린 메모리 영역과 더티 메모리 영역이 있다.
프레임워크를 만든다면, 싱글턴과 전역 이니셜라이저는 더티 메모리 양을 줄이는 아주 좋은 수단이다.
싱글턴은 객체가 만들어지고 나서 항상 메모리 위에 있을 거기 때문에, 그리고 전역 이니셜라이저는 프레임워크가 링크됐거나 클래스가 로드됐을 때 항상 불려올 것이기 때문에.

Compressed Memory는 꽤 신기하지? iOS가 전통적인 Disk Swap 대신 쓰는 거다.
얼마간 액세스되지 않은 페이지를 압축해놓는 것. 액세스될 때 압축이 풀린다.
메모리 워닝을 받았을 떄 캐시를 다 지우는 로직을 사용한다고 가정해 보면..
Compressed Memory가 일단 decompressed되고(지우려면 액세스해야 하기 때문) 지워진다. 단지 지우기만 하고 싶었는데, 순간적으로 메모리 사용량이 팍 튈 수가 있다.
그래서 메모리 워닝을 다룰 때는 주의해야 한다. 이게 캐싱에서 중요한 부분.

캐싱을 통해 CPU가 반복작업하는 것을 줄일 수 있다. 하지만 너무 많이 캐싱하면 메모리가 모자라게 된다.
메모리 컴프레싱을 통해 뭘 캐싱할지, 뭘 나중에 재계산할지 조절할 수 있다.
NSCache를 통해 또한, 스레드 세이프하게 캐싱할 수 있다.

Memory Footprint는 Dirty Memory와 Compressed Memory에 한한다.
모든 앱은 풋프린트 제한이 있다. 디바이스 종류에 따라 바뀐다.
    앱의 풋프린트 제한은 사실 꽤 널널한 편인데, extension의 풋프린트 제한은 꽤 적다. extension을 쓸 때는 그래서 한 번 생각을 해야 된다.

### Tools for Profiling Footprint
Xcode Memory Gauge
Instruments
- Allocations
- Leaks
- VM Tracker - 더티 메모리, 압축된 메모리 찾는 데 아주 유용
- VM Memory Trace - By Operation 탭

메모리가 넘치면 EXC resource exception 오류가 나오게 된다.
이를 찾기 위한 메모리 디버거. Memgraph 파일 포맷을 사용하고, 앱의 메모리 사용에 대한 정보를 그림으로 담는다.
    File - Export Memgraph
이 memgraph 파일을, zsh 등의 콘솔에서 vmmap 명령어를 통해 열어서 상세한 메모리 사용량을 볼 수 있다.
leaks App.memgraph와 같이 leaks 명령어를 통해서 릭도 체크할 수 있다.
heap 명령어도 똑같이 사용할 수 있고, -sortBySize나 -addresses와 같은 추가 조건을 뒤에 달아줄 수 있다.

스킴 에디터에 Logging Malloc Stack을 활성화하면, 모든 메모리 allocation에 대해 로그를 남긴다. 이 로그는 Memgraph를 익스포트할 때 함께 기록된다.
이걸 어디다 쓰냐? 버그 리포트를 할 때 쓸 수 있다.

메모리 문제를 면했을 때 뭘 쓸 수 있을까?
객체 생성? 참조 주소? 인스턴스의 크기? 뭘 보고 싶냐에 따라 다르다.
    생성은 malloc_history
    참조 주소는 leaks
    크기는 vmmap, heap

### Images
이미지의 메모리 사용은 이미지의 파일 크기가 아니라 해상도와 관련이 있다.
해상도가 높으면 메모리를 더 많이 쓴다.

iOS의 이미지는 Load - Decode - Render의 과정을 거친다. 
예시로 나온 590킬로바이트 이미지는 압축된 JPEG 포맷이고, 디코딩 과정에서 압축이 풀리면서 10메가(!!)의 공간을 차지하게 된다.

렌더링 과정에서 쓰이는 포맷에 따라 픽셀당용량이 다르다.
- 대표적으로 쓰이는 sRGB - 픽셀당 4바이트, 풀 컬러 이미지
- iOS 기기에서 다룰 수 있는 Wide format - 픽셀당 8바이트, "슈퍼 정확한 색상". 와이드 컬러 디스플레이에서만 유용하다.
- Luminance and Alpha 8 - 픽셀당 2바이트. 밝기와 알파값. 그림자에 많이 쓰인다.
- Alpha 8 - 픽셀당 1바이트. 흑백 이미지를 나타낼 때 아주 좋다. 용량이 일단 작으니까.

어떻게 올바른 포맷을 고를까? 임의로 고르려 하지 말고, UIGraphicsImageRenderer를 통해 알맞을 포맷이 나를 고르게끔 하자.
메모리 절약이 오늘의 테마임을 상기! 이미지 렌더링에 올바른 포맷을 사용하는 것은 메모리를 효과적으로 사용하는 지름길이다.

또 하나의 방법은 다운샘플링. 썸네일 같은 걸 만들 때는 이런 방법이 좋다.
단, UIImage를 사용해 다운샘플링할 생각일랑 말자. 이렇게 되면 새로 그리는 게 돼서, Compressed Memory를 풀어헤쳐서 계산해야 하기 때문에 메모리적으로 그다지 효율적이지 않다.
대신 ImageIO 프레임워크를 사용할 수 있다. 다운샘플링을 하고, 이미지 결과값에 따라 만들어지는 Dirty Memory에 대한 비용만 부담하면 된다.

### Optimizing when in the Background 
앱이 백그라운드로 가도 이미지는 아직도 메모리에 있다.
- (되게 자연스럽게, 이미지 얘기를 하면서 백그라운드 얘기로 넘어갔다.)
큰 리소스는 unload하는 게 바람직하고, 라이프사이클을 통해 이를 조절할 수 있다. 
- 앱 라이프사이클, 뷰 라이프사이클 다 포함이다.
loadImages(), unloadImages() 메서드를 정의... 했나? (잘 못 봄) 이걸 라이프사이클에 따라 불러와 줌으로써 메모리를 조절해주는 것이다.

(데모 - 앞에서 말했던 것들을 실제로 보여주는 과정)

참조 : https://seizze.github.io/2019/12/20/iOS-%EB%A9%94%EB%AA%A8%EB%A6%AC-%EB%9C%AF%EC%96%B4%EB%B3%B4%EA%B8%B0,-%EB%A9%94%EB%AA%A8%EB%A6%AC-%EC%9D%B4%EC%8A%88-%EB%94%94%EB%B2%84%EA%B9%85%ED%95%98%EA%B8%B0,-%EB%A9%94%EB%AA%A8%EB%A6%AC-%EB%A6%AD-%EC%B0%BE%EA%B8%B0.html
