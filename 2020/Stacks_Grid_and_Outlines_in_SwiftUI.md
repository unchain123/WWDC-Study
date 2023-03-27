
# [WWDC20] Stacks, Grids and Outlines in SwiftUI

>The more photos my gallery needs to display, the longer it takes for the screen to become responsive when presented.

## Stacks

VStack 을 이용한 스크롤뷰 설명중, 요소가 많아지면 그 많은 요소를 다 책임져야 해서 좋지 않다고 설명, 



그래서 Lazy Stack에 대한 개념을 제시 

### Lazy VStack, Lazy HStack
>The view won't block the main thread loading and measuring every single image and the app's memory footprint won't grow unnecessarily large.

증가하는 컨텐츠가 보여질 때 불필요하게 메모리 사용량을 키우는 것을 막을 수 있다. 
![](https://i.imgur.com/7R2Gk6O.png)



이때 Lazy VStack을 사용했다고 해서 안에있는 rating HStack 도 Lazy로 선언해야 하는가? 아니다. 

>Adopt Lazy Stacks as a way to resolve performance bottlenecks that you find after profiling with Instruments
>
병목현상을 줄이려는 목적이 있을 때 이 LazyStack을 사용해라. 



## Grids
샌드위치 앱을 넓은 화면에서 봤을 때 이렇게 보인다. 

![](https://i.imgur.com/6tdzILu.png)

>Using a LazyVGrid, I can easily implement a multi-column layout to increase the sandwich density of my view. 

### Lazy VGrid, Lazy HGrid

![](https://i.imgur.com/b8vdD5j.png)

Lazy VStack -> Lazy VGrid 로 변경해주었다. 각 Grid의 width 는 columns 배열에서 "GridItem" 값이 지정해주고 있다. 

>Grid items are flexible by default, so this arrangement will fill the grid with columns of equal width.

GridItem은 기본적으로 유연하기 때문에 같은넓이를 할당받을 것이다. (가로모드일 때도 마찬가지로 같은 넓이를 할당받는다.)

Column의 최소 넓이값을 지정해주는 방식도 있다. 
![](https://i.imgur.com/VnOkMYY.png)

Lazy스택에서와 비슷하게 Grid의 Column 수가 많아질 때 사용할 수 있다. 
GridItem 배열을  LazyVGrid의 columns 파라미터에 넣어줄 수 있는데, GridItem 의 .adaptive 속성으로 minimum width를 지정해줄 수 있고, 이로인해 동적인 Column수를 대응할 수 있을 것 

## Lists
![](https://i.imgur.com/gfHxlNn.png)

List는 항상 lazy 속성이 적용되어 있다.  
위처럼 평탄하게 1차원으로 표현할 수도 있지만, 그룹으로 묶어서 계층을 나누어줄 수도 있다.

![](https://i.imgur.com/gf65OJS.png)

커스텀 outline을 만드는 방법이다. 

![](https://i.imgur.com/DzmF3ac.png)

라이브코딩
![](https://i.imgur.com/6leOFFV.png)

### DisclosureGroup 
>A DisclosureGroup provides a disclosure indicator, a label and content. 
>
![](https://i.imgur.com/skm3Pjc.png)


## Reference
- [WWDC20-Stacks, Grids, and Outlines in SwiftUI](https://developer.apple.com/wwdc20/10031)
