
# [WWDC18] Core Data Best Practices
> 지난 WWDC15 What's New in CoreData에 이어 Core Data Best Practices 에 대해 살펴봅니다. 

![](https://i.imgur.com/DEKF1nu.jpg)

코어데이터를 저장하는 방법입니다. 흔한 게시글 같이 사진과 글이 있는 경우 이런 식의 모델링을 할 수 있습니다.

여기서 post 와 comment의 relations 가 필요합니다. 시간이 지날수록 디스크 내의 많은 양의 데이터가 쌓일텐데, 관리하기 위해 NSPersistentstoreCoordinator를 사용할 수 있습니다. 

coordinator 는 앱의 모델을 store의 버전과 비교할 수 있고, 앱이 진화함에 따라 자동으로 migration을 합니다. 
NSManagedObjectContext 는 안전하고 빠르고 예측가능하게 데이터에 접근할 수 있도록 합니다.
심지어 query generation, connection pooling, history tracking 와 같은 기능들에서도 사용 가능합니다. (?)
 
![](https://i.imgur.com/pJFCg4D.jpg)

원래는 위와 같이 복잡한 코드를 작성해야 했다면, 

![](https://i.imgur.com/dM9uXJ3.jpg)

코어데이터를 이용하면 boilerplate 코드를 줄여줄 수 있습니다. 
persistantContainer은 Main Bundle 외부에서 데이터를 load 할 것입니다. 

코어데이터는 앱이 성장함에 따라 사용하기에 좋도록 설계 되었습니다.

![](https://i.imgur.com/McVOL6E.jpg)

Container가 모델을 찾는 방법입니다.

![](https://i.imgur.com/GCmlzNV.jpg)

Container가 모델을 찾는 향상된 방법입니다. 

![](https://i.imgur.com/y3vX18d.jpg)

저장소가 저장되는 공간을 커스터마이징 합니다. 

![](https://i.imgur.com/vULdlxe.jpg)

향상된 방법입니다. 코어데이터는 생성될 때 기본 경로가 생성됩니다. 

### Generalizing Controllers

> Core Data를 사용하는 Controller에게 필요한 것!

- Data
    - Managed object(DetailView에서 필요)
    - Fetch request(ListView에서 필요)
- Managed obejct context
    - container's view context 또는
    - some other main queue context 
- Controller에 CoreData를 적용하는 것은 UI 뿐만 아니라 Utility 에도 잘 적용됩니다.
- Getting view controllers what they need when using(context와 fetchRequest를 주입하는 각각의 방법)
    - Segues 를 사용할 때
    ![](https://i.imgur.com/9eNaEtV.png)
    - Storyboards 나 nibs를 사용할 때
    ![](https://i.imgur.com/Ec5ePWT.png)
    - Code를 사용할 때
    ![](https://i.imgur.com/sXZ2n4i.png)


### Turning Fetch Requests Into List Views

> 위에서 fetchRequest와 context를 잘 주입해 주었습니다. 이 두 객체를 이용하여 결과값을 얻으려면, fetch request 를 조금 더 구성해주어야 합니다. 왜냐하면 훌륭한 성능을 보장하기 위해서 입니다. 

- Configure the results'behaviour
    - Fetch limit 
    - Batch size
- Use the fetched results controller (데이터의 변화가 일어날 때 UI 업데이트를 해주는 방법)
    - 날짜별로 게시글을 그룹화 하고싶다면, 이렇게 할 수 있다. 
    ![](https://i.imgur.com/adCNqyc.png)

### Matching UIs to the Model
>만약 하루에 게시글을 올리는 수를 파악하기 위한 차트를 만들고 싶다면?

![](https://i.imgur.com/oMQU0wr.png)

- 복잡한 fetch request를 만들어야 합니다.
![](https://i.imgur.com/blo8wvq.png)
    - 1. 범위를 지정합니다. 우리는 지난 30일간의 데이터가 필요합니다. 
    - 2. 같은 날짜끼리 그룹화를 시켜줍니다. 각각의 객체를 받아오는 것이 아니므로 감각적인 result type으로 변경해야 합니다. 지금의 경우는 dictionary 타입 입니다. 
    - 3. 각 그룹 안의 객체 수를 나타내는 표현을 정의합니다. (NSExpression)

### Denormalization
> 여전히 SQLite는 그래프의 수를 계산할 때 메모리를 통해 모든 게시글을 읽습니다. 데이터가 너무 많아지면 어떻게 해결해야 할까요?

- Denormalization은 추가적인 bookkeeping 이 값비쌀 때, 읽기 성능 향상을 위해 데이터의 잉여 복사본들 또는 메타데이터를 추가하는 것을 의미합니다. 데이터베이스 인덱스가 그 예시 중 하나입니다. 

### Matching UIs to the Model
- New entity
    - PublishedPostCountPerDay
        - day(Date)
        - count(UInt)
- 1년치의 데이터를 fetch request 한다고 가정 했을 때, 성능 향상을 위해 새로운 entity를 만들어 주는 방법이 있습니다.
- 방법은 아주 간단합니다. 이전에 해주었던 fetch request와 유사합니다. 
![](https://i.imgur.com/tCyI48X.png)
- 게시글이 추가되면 count +1 삭제되면 count -1 처리를 해주는 작업
![](https://i.imgur.com/CHoAaLb.png)
- 이는 database에 commit 되기 전에 context에 영향을 줍니다.  

### Managing Growth
> 앱이 성장함에 따라 데이터는 더욱 복잡해지고, 카오스를 불러일으킵니다. CoreData를 이용하면 이 카오스를 막을 수 있습니다. 

- 사용자 입장의 metrics
    - 일관된 UI
    - 반응형 스크롤링
    - customer 기쁨

- 엔지니어 metrics
    - peak 메모리 소비
    - 배터리 소모
    - CPU 시간
    - 입출력

<img src="https://i.imgur.com/UOTgJFZ.png" width="500">

- Download : 서버에서 파일을 다운로드 합니다.
- Post All : 서버로 파일을 올립니다. 
- "+ 버튼" : 파일을 추가합니다. 

사용자와 상호작용하는 위 세개의 버튼이 동시적으로 일어날 때, 카오스가 일어납니다. 
적은 양의 상호작용 임에도 불구하고, 동시적으로 일어났을 때 수많은 다른 상태변화를 일으킵니다. 
 
<img src="https://i.imgur.com/8wJWb1X.png" width="400">

나쁜 사용자 경험을 선사할 수 있습니다..
이는 query generations에게 도움을 받을 수 있습니다.

### Consistent Experiences with Query Generations
> What's new in coredata 에서 소개된 녀석입니다. (어려워서 잘 못봤던거..)
> 오직 SQLite 에서 작동합니다. 

- managed object context 를 경쟁 작업으로부터 고립시키는 것이 목적입니다.
- Query generation은 주어진 시점에 다른 context에서 데이터베이스에 쓰기작업을 하는 것을 상관하지 않고 동일한 결과를 받아오는 데이터베이스의 지속적이고 튼튼한 뷰를 제공합니다

queryGeneration을 설정하는 방법입니다. 
![](https://i.imgur.com/EkJ4Fkq.png)

기존의 방법대로 mergeChanges를 통해 업데이트 합니다. 
![](https://i.imgur.com/Cp6PSv5.png)


위 방법을 이용하여 앱 데이터의 명백한 변화를 UI에 즉각 나타낼 수 있습니다. 

만약 우리가 쓰는 데이터가 코멘트를 다운받는 것처럼 UI와 연관이 없다면 어떨까요?
이때는 데이터가 UI에 보여지지 않길 원합니다.(변경 사항이 사용자에게 표시되지 않기 때문)
그래서 이런 업데이트는 history tracking으로 필터링 합니다. (wwdc17 what's new in core data에서 소개되었다.)

### Filtering Updates with Persistent History Tracking

- 영구 기록 추적은 데이터베이스에 연결되는 각 트랜잭션의 영구 기록을 얻을 수 있는 좋은 방법이며 이는 몇 가지 다른 이유로 우리에게 유용합니다.
- 사용할 수 있는 클래스 소개.
![](https://i.imgur.com/u1H6BJB.png)

#### 예시

![](https://i.imgur.com/6d6qe3O.png)

    - 위같은 **POST** 데이터가 들어왔을 때, 우리는 UI를 새로고침 해주고 싶을 것이다. 
    - NSPersistentHistoryTransaction을 사용할 수 있다. 
![](https://i.imgur.com/H7b1ew8.png)

![](https://i.imgur.com/cplpBaO.png)

    - 하지만 **Comment** 데이터가 들어온다면 UI 새로고침 하고싶지 않을 것이다. 
    - POST 작업만 뽑도록 필터링 해줄 수 있다. 
![](https://i.imgur.com/GvLdvHT.png)

생각해보면 POST Entity에 프로퍼티가 title 과 image 밖에 없습니다. 

![](https://i.imgur.com/1ebfK7S.png)

entity로 필터링 하는 방법 말고 history changes 를 이용하여 업데이트된 프로퍼티를 기준으로 필터링도 해줄 수 있습니다. 

 [20:15]
 
### Bulk Editing with Batch Operation

<img src="https://i.imgur.com/8BKIohu.png" width="400">

데이터가 복잡해지고 커질 수 있습니다. 이때 몇몇 editing 작업이 어려워 질 수 있습니다.

CoreData는 위와 같은 multi-selection의 경우 Batch Operation을 통해 지원 가능합니다. 

▼ **BatchUpdateRequest**
![](https://i.imgur.com/tNtjczj.png)

▼ **BatchDeleteRequest**
![](https://i.imgur.com/sFWpQht.png)

### NSManagedObject.delete vs NSBatchDeleteRequest

메모리에 객체 faulting 하는 것과는 다른 방법으로 커집니다. 예를들어 delete(NSManagedObejct.delete를 이용하는) 를 하는 동안에 database의 record 사이즈를 늘릴 것입니다. 객체를 delete 함에 따라 메모리는 fault 될 것입니다. 이는 database가 커짐에 따라 비용도 비싸질 것입니다. 그러나 BatchOperation을 이용하면 메모리의 일부만으로 동일한 mutation을 수행할 수 있습니다. 이는 데이터가 증가함에 따라 메모리 사용량이 줄어드는 곡선을 가지게 합니다. 
![](https://i.imgur.com/Lg7Blr9.png)
 
이것은 사용자의 기기에 자원을 저장하는데에 아주 파워풀한 방법입니다. 하지만 전통적인 문제중 하나는 batch operation을 이용하여 작업하기 어렵다는 것입니다. 이유는 save notification을 생성하지 않기 때문입니다. 그래서 history tracking이 다시 시작됩니다. 

![](https://i.imgur.com/jODF9ud.png)

`objectIDNotification()` 이 save notification의 역할을 해줄 수 있습니다. 이러한 방식으로 가져온 result controller 또는 애플리케이션의 다른 컨텍스트는 이러한 알림을 점진적으로 업데이트할 수 있습니다.

여기까지 CoreData를 이용해 커지는 데이터를 관리하는 방법이었습니다. 하지만 workflow는 어떨까요?


### Help Future You (요약만 23:00)
NSKeyedArchiver API is changing
Default value transformer
- Old - nil or NSKeyedUnarchiveFromDataTransformerName
- New - NSSecureUnarchiveFromDataTransformerName

Transparent for plist types
- Custom classes need a custom transformer
- Come see us in lab!



▼ 추후 이렇게 기본값으로 정해질 것이다. 
![](https://i.imgur.com/K1utZhu.png)

▼코드로 적용해주는 방법이다. 
![](https://i.imgur.com/RmCT9Vi.png)

▼ 확인해보니 이렇게 되어있다. value transformer 라는게 없다..
![](https://i.imgur.com/1DKPLXd.png)

## 마무리

core data 관련 wwdc 는 항상 데이터베이스 관련 내용이 같이 나와 이해하기가 어려운 것 같습니다. 이번에도 마찬가지로 후반부의 내용은 db관련 심화 내용(Help Us Help You [23:00] 이후내용)이 포함되어있어 정리하지 못했지만, 추후 코어데이터를 헤비하게 사용하게 된다면 찾아봐도 좋을 것 같습니다. 
이번 wwdc 를 한마디로 요약해보자면, "앱이 버전업 함에 따라 데이터가 복잡해지고, 이를 관리해주기 힘들텐데 CoreData 를 이용하면 쉽게 관리해줄 수 있다!" 입니다. 
 

## References
- [WWDC18 - Core Data Best Practice](https://developer.apple.com/wwdc18/224)
