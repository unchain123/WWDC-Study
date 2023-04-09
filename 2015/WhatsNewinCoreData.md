# [WWDC 2015] What's New in CoreData

> 코어데이터란 무엇인가요 ? 데이터의 영구저장을 하기 위해 사용하는 프레임워크 입니다. 

저장하는 데이터의 모델간 관계가 있을 것입니다. 이는 꽤 복잡할 수 있습니다. 이러한 관계를 자동으로 관리해준다고 합니다.
![](https://i.imgur.com/eGK3mN0.jpg)

### Object Management
당신의 데이터를 간단하게 Cocoa Model Layer와 연결시켜줍니다.
당신의 선택(SQLite 또는 커스텀스토어)에 따라 데이터를 보존합니다.
당신이 정의한 데로 삭제를 전파합니다.

### NSFetchRequest

필요한 데이터를 찾을 때 사용하는 클래스입니다.

-  Predicate를 이용하여 원하는 데이터를 찾을 수 있습니다.
- Batching
    - 이렇게 하면 가져오기 요청으로 인해 발생할 수 있는 데이터 세트의 개체 중 더 작은 부분만 가져올 수 있으므로 데이터를 살펴볼 때 더 작은 데이터 청크를 가질 수 있습니다.
- Relationship prefetching
    - 관계가 있는 모든 데이터를 prefetching 합니다. 데이터를 가로질러 찾을 때 여전히 메모리에서 가능합니다.
- Then tie this with your UI and...

### View and Controller Support

데이터의 추가 삭제를 가능하게 합니다. 이에 따른 결과가 바로 UI 에 보여지게 만들 수 있습니다.

### Multi-Writer Conflict Handling

>Now there may be a scenario where your user is manipulating the object on the main context and on a background context you're ingesting the same new object and possibly updating the object the user currently is also manipulating.

이제 사용자가 메인 컨텍스트에서 객체를 조작하고 background 컨텍스트에서 동일한 새 객체를 수집하고 사용자가 현재 조작하고 있는 객체를 업데이트하는 시나리오가 있을 수 있습니다.
이것은 Multi-Writer Conflict라고 불립니다. 

CoreData는 이 부분까지 처리합니다. 

모든 객체를 버전화 하고, 당신이 merge 정책을 설정할 수 있도록 합니다. 만약 merge 정책을 설정하지 않는다면 당신이 context에 저장할 때 우리는 기본적으로 에러를 반환합니다. 그리고 충돌을 해결할 수 있도록 충돌에러를 반환합니다. 

> On your mark, set that merge policy, and done

코어데이터는 모든 객체를 version 합니다.
몇몇 타입의 머지정책이 이용 가능합니다.
- Default to error
- Persistent store vs. in-memory

### Memory Efficiencies
> API with benefits

훌륭한 메모리 확장성
적극적인 lazy loading
- 메모리에 올라갈 필요가 있는 녀석들만 메모리에 올려줍니다.
- 코어데이터를 이용하면 메모리 족적을 50~ 70 퍼센트 줄일 수 있습니다.


### API Enhancements (새롭게 추가된 내용들을 설명)

#### hasPersistentChangedValues
> NSManagedObject

```swift
var hasPersistentChangedValues: Bool { get }
```
- No false positive setting a value to itself
- Skips transient properties
- hasChanged 프로퍼티를 사용하는 것보다 좋다..?


#### objectIDsForRelationshipNamed
> NSManagedObject

```swift
func objectIDsForRelationshipNamed(key: String) -> [NSManagedObjectID]
```

캐시를 읽거나 objectIDs를 받아옵니다.
전체관계를 구체화하지 않습니다. 
크고, 다대다 관계인 경우 유용하게 사용됩니다.

관계 key 에 속하는 객체들의 id 배열을 반환합니다.

```swift
let relations = person.objectIDsForRelationshipNamed("family")

let fetchFamily = NSFetchRequest(entityName: "Person") 
fetchFamily.fetchBatchSize = 100
fetchFamily.predicate = NSPredicate(format: "self IN %@", relations)

let batchedRelations = managedObjectContext.executeFetchRequest(fetchFamily)

for relative in batchedRelations {
    // work with relations 100 rows at a time
}
                                 
```

전체 데이터를 통해 다루지 않고, 특정 Key 값에 관련이 있는 데이터만 뽑아서 관리하다 보니 메모리 절약에 도움을 줄 수 있습니다.

#### refreshAllObjects()
> NSManagedObjectContext

```swift
func refreshAllObjects()
```
- 컨텍스트에 등록된 모든 개체에 영향을 줍니다.
- 저장되지 않은 변경사항을 유지합니다. 
- Managed Object 참조는 계속 유효합니다. 
- retain cycle을 깨는데 유용합니다.

### mergeChangesFromRemoteContextSave
> NSManagedObjectContext

```swift
class func mergeChangesFromRemoteContextSave(
    changeNotificationData: [NSObject : AnyObject],
    intoContexts contexts: [NSManagedObjectContext]
)
```

다른 coordinator로부터의 변경사항에 대응하기에 더 낫다. 
최근의 row data를 불러옵니다. 
중첩문맥의 순서를 관리합니다.
 
### No Love for Exceptions 
> This is not the data you are looking for 

Why is Core Data unable to fulfill a fault?
Managed objects are implicit futures
- Cocoa place holders for a row of data
- Often lazily loaded 
- Part of a larger graph

Data deleted out from underneath this reference

▼ 위 같은 문제를 해결하기 위해 나온 프로퍼티 
### shouldDeleteInaccessibleFaults
> NSManagedObjectContext

```swift
var shouldDeleteInaccessibleFault: Bool
```

- Defaults to YES
- Does not effect APIs with error parameters
Bad faults marked deleted
Missing data treated as NULL/nil/0 

위같이 크래쉬를 방지 해줍니다. 

[8:58] ---

## NSPersistentStoreCoordinatorAPI

데이터베이스를 자르고 복사할 때 사용하는 클래스 입니다. 
API계층을 우회하지 마세요.
- NSFileManager와 POSIX는 데이터베이스에 좋지 않습니다. 
- 만약 개방연결이 존재한다면 당신의 파일을 손상시킬 것입니다. 
open locks로 파일을 제거하는 것은 나쁜 결과를 부릅니다.

### DestroyPersistentStoreAtURL
> NSPersistentStoreCoordinator


### ReplacePersistentStoreAtURL
> NSPersistentStoreCoordinator

## Unique Constraints

### Find or Create Pattern
> Unique Constriants

유니크 값을 부여해서 중복을 찾는다

```swift
managedObjectContext.performBlock {
  let createRequest = NSFetchRequest(entityName: "Recipe")
  createRequest.resultType = ManagedObjectIDResultType
  let predicate =
    NSPredicate(format: "source = %@ AND externalID = %@", source,externalID)
  let results = self.managedObjectContext.executeFetchRequest(createRequest)
  if (results.count) {
      //update it!
  } else {
      //create it!
  }
}
```

Unique Constraints는 한번 설정되면 객체의 생명주기 동안 수정되지 않습니다. 
수정하면 충돌이 발생할 것입니다.


유니크 값을 부여하는 방법입니다.

![](https://i.imgur.com/EJKLY8Q.png)


## Deleting Multiple Objects

### Object Deletion

데이터를 삭제하는 과정입니다.

![](https://i.imgur.com/mArYzcc.png)

각각의 객체에 이런 반복작업을 수행해주어야 하기 때문에 효율성이 떨어지고 시간도 오래 걸립니다. 
![](https://i.imgur.com/jiJxOqV.jpg)




### NSBatchDeleteRequest

해결방안: 

메모리에 접근하기 않고 바로 Persistent Store 에서 직접 처리해주는 것이 좋습니다.

![](https://i.imgur.com/hWUcw6S.jpg)


중복을 모두 찾아 제거하는 것은 이상적이지 않습니다.
 
 중복을 제거하기 위해 `NSBatchDeleteRequest` 클래스를 이용하면 간단히 제거해줄 수 있다. 
 

## Model Versioning

기존 모델에 새로운 프로퍼티를 추가한다면 (Model Change를 한다면)
에러가 발생합니다.

>While working on this, we open up the model, adding the two attributes build and run and right away we had an error. I highlighted the most important part. We incurred a migration because the model changed but we forgot to include the original source model because it was what we used to change and the pattern of having to copy your old model in order to create a new one is really cumbersome when you're reiterating your apps. And if you forget to deploy a model to the hands of a customer that's running that version it's really dangerous

이를 해결하기 위해 Model Caching 이 등장했습니다. 

### Model Caching

NSManagedObjectModel 은 store에 복사됩니다. 
기존의 store를 자동 업데이트 합니다.
LigLightweight migrations 은 store에서 모델을 받아옵니다. 

>Whenever you have a store that's created or migrated or just opened on the new iOS from an older version the managed object model used to create it is cached into the store and it is used by lightweight migrations when they fail to find appropriate source model as sort of a last-ditch effort.

적합한 모델 찾기에 실패했을 때 캐싱된 모델을 가져온다는 뜻 같습니다. 

두개의 한계점이 있습니다. 이것은 오직 SQLite store 에서만 가능하고, cached model은 heavyweight migration을 할 수 없습니다.

>If you're doing heavyweight migrations you have your model ready anyways because you need to know what you're actually transitioning from and to.

### Generics and Nullability
> Better living through more explicit types

nonnull(default), nullable, and null_resettable
kindof allow for easier casting
Generated subclasses use generics for to-many relationships



### Generated Subclasses

Core Data Performance
![[스크린샷 2023-04-09 오후 6.25.45.png]]

### Concurency

### Concurrency Performance

### Slow Can Be Surprising

Scale differs between development and production
The simulator is faster than the device
Users use devices in production

CoreData Instrument를 이용하여 cache miss를 확인할 수 있습니다 

### Large Fetches

데이터를 많이 가져와야 하는 경우 보여줄 필요가 있는 녀석들만 Fetch 해오도록 만듭니다.
fetchBatchSize 프로퍼티를 이용할 수 있습니다.

```swift
var recipeRequest = NSFetchRequest(entityName: "Recipe")

let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
recipeRequest.sortDescriptors = [sortDescriptor]

recipeRequest.fetchBatchSize = 30
context.executeFetchRequest(recipeRequest)
```

## 마무리
후반부의 내용이 어려워 제대로 정리하지 못했습니다. 추후 다시 정리하도록 하겠습니다. 

## Reference
- [[WWDC15] What's New in CoreData![](https://velog.velcdn.com/images/lwb112/post/b1ecdd59-922f-4c8d-81c7-25a4cde97160/image.png)
](https://developer.apple.com/videos/play/wwdc2015/220/)
