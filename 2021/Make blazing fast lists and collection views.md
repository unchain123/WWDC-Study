###### tags: `WWDC 스터디`

# [WWDC 2021] Make blazing fast lists and collection views
> 대부분의 앱은 컬렉션 뷰로 이루어져 있다. 빠른 스크롤을 했을 때 부드럽게 보이는 것은 기분이 매우 좋다.

**주제**
1. Performance fundamentals
2. Cell prefretching
3. Updating cell content


## 1. Performance fundamentals
> 앱이 데이터를 어떻게 구축하는지 알아보자


DiffableDataSource 에 item identifier로 모델을 넣는 것이 아닌, 모델의 id값을 넣는 것이다. 



iOS 15 전에는, 애니메이션 없이 snapshot을 apply 하는 것은 내부적으로 reloadData를 하는 것과 같았다. 이는 성능상 좋지 않다. (모든 셀을 discard 한 다음 다시 만들어 내기 때문!)

▼ iOS 15 부터는 **reconfigureItems()** 메서드로 필요한 셀만 업데이트 할 것이다. 

![](https://i.imgur.com/RrpFmiS.png)

▼ Diffable DataSource 에서는 cellRegistration을 만든 후, 
dataSource 생성 클로저(cell provider) 안에서 collectionView.dequeueConfigureReusableCell 메서드에 파라미터로 넣어준다. 이는 collectionView가 셀을 재사용하지 않는다는 것을 의미한다.?


>Note how the registration is created outside the cell provider and then used inside. This is important for performance, as creating a registration inside the provider would mean that the collection view would never reuse any of its cells. 
>
![](https://i.imgur.com/EuahyP0.jpg)

### Cell lifecycle

셀 라이프 사이클은 두 페이즈로 나뉜다. 

![](https://i.imgur.com/oreebiD.jpg)

- Cell preparation
    - Dequeue cell (reuse pool에서 dequeue, 없으면 새로 initialize)
    - Registration configure cell
    - Sizing and layout

- Cell display
    - willDisplayCell
    - Cell is Visible (실제로 셀이 보여지는 단계)
    - didEndDisplayingCell -> 스크롤로 인해 셀이 다시 reuse pool로 들어감


hitch 는 스크롤 중 끊기는 현상이다.

아래 그림은 스크롤링 중에 셀의 커밋을 나타낸 것이다. 한 칸은 1프레임을 나타낸다 
(아이패드 프로의 경우 120Hz, 아이폰의 경우 60Hz 라고 한다. 아이패드의 Frame 간격이 더 짧다.)
어쨋든 한 커밋이 한 프레임 내에 실행되야 하는 것이다. reuseCell을 그대로 쓰면 짧은 시간안에 커밋 데드라인 안에 완료될 것이고, 무거운 작업은 커밋데드라인을 넘길 수 있다. ▼

![](https://i.imgur.com/lkdeF1x.png)
![](https://i.imgur.com/tPAt9td.png)

commit이 데드라인을 넘기면 hitch가 생긴다. 

관련 내용은 Explore UI animation hitches 비디오에 나온다. 

이 hitch를 예방하기 위한 방법은 prefetch 이다. 

## 2. Cell prefetching

iOS 15에서 collectionView, tableView를 위한 prefetching 메커니즘이 등장했다

hitch를 피하려면 모든 작업을 미리 해야한다. 

Frame 내에서 커밋이 일찍 끝나면, 커밋 데드라인 까지 시간이 남게 된다. 여기서 다음 프레임이 올때 까지 기다리는 것이 아닌, 이를 인지하고 남는 시간에 prefetching을 하게 된다. ▼

![](https://i.imgur.com/tjMcFMA.png)
![](https://i.imgur.com/u9N63bP.png)

위처럼 진행하게 되면 각 셀당 준비할 수 있는 시간이 기존에는 1frame 이었지만, 2배로 늘어난다.

컴포지셔널 레이아웃에서 prefetching 지원한다. 

prefetching은 hitch를 제거하여 스크롤을 부드럽게 만들어 줄 뿐만 아니라, power usage를 줄여주고 battery life 를 늘려준다. 

지금 당장 hitch 현상이 보이지 않더라도, cell configuration과 layout implementation을 가능한 효율적으로 만들어야 한다. 


아래 그림과  같이 prefetching을 하게되면 Cell preparation 과 Cell display 사이에 Prepared cells 라는 새로운 Phase 가 생기게 된다. 

>Given this new phase, there are two important considerations for apps. It is possible for a prepared cell to never be displayed, which could happen if the user suddenly changed the scroll direction. Then, once a cell is displayed, it can go right back into the **waiting state** after it goes off screen. The same cell can be displayed more than once for the same index path. **It's no longer the case that a cell will be immediately added to the reuse pool when it ends displaying.**
>
이때 앱에 2가지 고려할 점이 있다. 

1. 이 prepared cells 이 display 되지 않는 경우
- 갑자기 스크롤 방향을 역방향으로 하면 준비된 셀은 나오지 않는다. 그러면 이미 보여진 셀은 다시 wating state로 가게되고 같은 셀이 같은 indexPath에 보여질 수 있다. 
- 이제 cell이 display가 끝나면 reuse pool로 즉각 들어가는 것이 아니다. (캐싱처럼prepared cells로 들어갔다가 곧바로 나오는 것인가??)

![](https://i.imgur.com/VgutrN2.jpg)
<br>
prefetching은 스크롤을 부드럽게 하는 데 도움을 준다. 이는 오직 시간을 더 벌어주기 때문인 것이다. Frame rate가 높은 다른 디바이스 에는 여전히 hitch현상이 일어날 가능성이 있다. 

패트릭이 이미지를 받아오는 경우 커밋 시간을 줄이는 방법을 알려줄 것이다.



-----------------------------------------------------------


iOS 15에서 최대한 효율적으로 셀 prefetching을 하는 방법에 대해 알아보자 .

예시에선 file system에서 바로 가져와서 이미지를 바로 보여주지만, 만약 이미지를 서버에서 받아오는 경우 어떻게 될까? 처음엔 placeholder 이미지로 뜨다가 이미지가 받아와 지면 이미지를 업로드 시킬 것이다. 



> Cells are reused for different destinations, and by the time the asset store loads the final asset, the cell object we have captured could be configured for a different post. Instead of updating the cell directly, we must inform the collection view's data source of the needed update.

cell Registration 코드에서 만약 다운로드가 필요할 경우 이런식으로 이미지를 직접 할당하도록 처리할 수 있는데, **권장되지 않는 방법**이다. ▼

![](https://i.imgur.com/dSpvPPN.jpg)

왜냐하면 셀들은 각기다른 destination에서 재사용이 되고, asset store에서 최종 asset을 load했을 때, 우리가 캡쳐해왔던 셀 객체가 다른 포스트를 위해 구성될 수도 있기 때문이다. 이 방법 대신에 data source에 업데이트가 필요하다고 알리는 것이 더 좋다.

iOS15에 새로 등장한 **reconfigureItems()** 메서드를 이용하면 된다. ▼

![](https://i.imgur.com/hRrR3iH.jpg)

이 메서드를 실행하면 registration의 configuration handler 를 다시 실행 할 것이다.
reloadItems() 메서드 보다 reconfigureItems() 메서드를 이용하는 것이 좋은 이유는, 
dequeue 하거나 새로운 셀을 만드는 것이 아닌, 아이템의 존재하는 cell을 이용하기 때문이다. 

만약 placeholder 이미지라면, 이미지 다운로드 요청 후 응답이 왔을 때 해당 아이템에 reconfigureItems 메서드를 호출 해주면 다시 Cell Registration으로 들어와 isPlaceholder 조건에 들어가지 않고, 바로 셀에 text와 image를 할당하는 로직으로 넘어간다. (즉, 이미지 다운로드 요청 후 비동기적으로 reconfigureItems 메서드가 실행되고 -> 다시 Cell Registration 으로 들어온다는 것!) ▼

![](https://i.imgur.com/llrS9WF.jpg)

prepare time 을 최대화 하기 위해, prefetchingDataSource안에서 download메서드를 사용할 수 있다. 


![](https://i.imgur.com/gMVU5EO.jpg)





### Image loading hitches

- Placeholders appear okay
- Full assets cause hitches on display
- Interrupts user scrolling

모든 이미지는 display 하기위한 decoding 하는 시간이 많이 든다.  

비동기적으로 이미지를 다운로드 받은 후 reconfigureItem() 메서드로 인해 Image preparation이 실행되어도 하나의 프레임 내에 끝마치지 못한다.

### Image preparation
> Image preparation is a mandatory process that all images must undergo to be displayed
> Image preparation은 모든 이미지가 표시되기 위해 거쳐야 하는 필수 과정이다.

![](https://i.imgur.com/u4zTnri.png)


이미지는 다양한 포맷(HEIC, JPEG, PNG)(압축된)을 가지고, 이를 보여주기 위해서는 unpack 해야 한다.
ImageView는 새로운 이미지를 커밋할 때 MainThread에서 이 작업을 수행한다.

![](https://i.imgur.com/mkFtV4d.jpg)

가장 좋은 방법은 최종 preparation이 완료되었을 때 UI를 업데이트 하는 것이다. 이렇게 하면 MainThread를 block 하지 않고 hitch도 발생하지 않는다. 

![](https://i.imgur.com/njF3Y1o.png)

위 방법을 위해 ios15 에서 이미지 preparation 을 제공한다. (async 버전과 sync 버전)

![](https://i.imgur.com/D3f8Dev.jpg)

이렇게 사용할 수 있다. 

![](https://i.imgur.com/5mv5mSg.png)

이러한 기능들은 이미지가 많은 앱에서 hitch현상을 해결하는데 사용할 수 있다. 하지만 고려할 점이 있다. 

### Image preparation consideration
- Maintain small cache of prepared images
- Do not store on disk 
- prepare image는 원본 이미지의 raw pixel data를 포함한다. 

>It will remain free to display in an image view as long as it's retained in memory. But this also means it takes up a lot of memory, and they should be cached sparingly.

> Finally, because of their format, they are not ideal for disk storage. Instead, save the original asset to disk. 

>
prefetching은 이미지 다운로드 시간을 더 벌어준다.  




이미지의 크기가 큰 경우는 캐싱을 통해 저장해줄 수도 있다. 
![](https://i.imgur.com/RFjovRm.jpg)

아래와 같이 resizing을 통해 이미지 용량을 줄여줄 수도 있다. 이는 많은 CPU time과 메모리를 절약해줄 수 있는 방법이다. 

![](https://i.imgur.com/UpnLHWN.jpg)
![](https://i.imgur.com/d2UZp2U.jpg)

### High performance images
- Prepare images in advance
- Use placeholder images
- Reconfigure cells to update image view


### 결론 

- 이미지 place holder를 지정해라. 
- 이미지를 처리하는 유용한 api들이 생겼으니 잘 활용해봐라 (prefetch, preparingForDisplay, prepareThumbnail .. )
- 이미지 때문에 hitch 현상이 일어남으로, 이를 해결해라.


## 🔗 Reference
- [WWDC - Make blazing fast lists and collection views](https://developer.apple.com/videos/play/wwdc2021/10252/?time=147)
