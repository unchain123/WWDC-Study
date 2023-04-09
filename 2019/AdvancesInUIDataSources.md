# [Advances in UI Data Sources](https://developer.apple.com/videos/play/wwdc2019/220)

## 기존의 Data Sources
- 기존에는 Datasource Protocol을 통해 UITableView 및 UICollectionView가 Data Sources와 상호작용을 했습니다.
- 점차 앱은 복잡해지고 있고, 보통 Data Sources는 ViewController와 함께 있습니다.

### 문제점

<img src="https://i.imgur.com/jdIgZUA.png" width="500" height="200"/>

- 업데이트가 잘못되면 곧바로 크래시로 이어집니다.
- 이를 해결하기 위해 많은 사람들이 `reloadData` 를 호출합니다.
- 그러나 이 메서드를 호출하면 애니메이션 효과가 발생하지 않아 사용자 경험을 손상시킬 수 있다고 합니다.
- 그렇기 때문에 애플은`reloadData`메서드 호출은 좋지 않다고 합니다.

<br>

## DiffableDataSource가 기존과 다른점

### 1. `apply()`
- DiffableDataSource는 `performBatchUpdates()`가 없습니다.
- 대신 `apply()`가 있습니다.

<img src="https://i.imgur.com/s71IqSY.png" width="400" height="250"/>

<br>
<br>

### 2. snapshots
- IndexPaths 대신 identifier 사용하여 업데이트합니다.

<img src="https://i.imgur.com/zbHi8rl.png" width="400" height="200"/>

---

## DiffableDataSource 예시
> 예시를 통해 DiffableDataSource가 어떻게 작동하는지에 대한 메커니즘을 실제로 파악해 봅시다.
> [예시 다운로드 받기](https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/implementing_modern_collection_views)


### 1. 스냅샷 구성하기
- 새로운 NSDiffableData SourceSnapshot을 만듭니다.
-  스냅샷에 섹션을 추가합니다.
    - 여기서는 임의로 `main`이라는 섹션을 추가했으므로, 명칭은 달라져도 됩니다.
    - 섹션 추가는 하나 이상 가능합니다.
- 스냅샷에 업데이트하고 싶은 데이터를 추가합니다.
    - `appendItems`를 통해 identifier 배열을 추가합니다.

```swift
let snapshot = NSDiffableDataSourceSnapshot<Section, MountainsController.Mountain>()
snapshot.appendSections([.main])
snapshot.appendItems(mountains)
```

### 2. 스냅샷 적용하기
- DiffableDataSource의 `apply`를 호출하여 스냅샷을 적용하도록 요청하는 것입니다.
- apply가 완료되면 UI가 변경됩니다.

```swift
dataSource.apply (snapshot, animatingDifferences: true)
```

<br>

## 섹션을 enum으로 하면 좋은 이유
- Swift의 열거형에 대한 한 가지 좋은 점은 자동으로 해시 가능하다는 것입니다.
- 여기서 해시가 중요한 이유는 각 섹션과 Identifier에는 Hashable 프로토콜을 준수하는 고유 식별자가 있어야 하기 때문입니다.

---

## Snapshots 더 알아보기

### 스냅샷을 만드는 방법
1. 빈 스냅샷 생성
```swift
let snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
```

2. DiffableDataSource의 스냅샷 가져오기
```swift
let snapshot = dataSource.snapshot()
```
- 아주 작은 것 하나를 수정해야하는 특정 작업이 발생할 때 유용합니다.

## 정리
- 선형 diff에 많은 수의 항목이 있는 경우 백그라운드 큐나 Main큐에서`apply` 메서드를 호출하는 것이 안전합니다.
- 단 백그라운드 대기열에서 `apply` 를 호출하기 위해 이 모델을 선택하는 경우 일관성을 유지해야합니다. (Main과 백그라운드를 혼용하면 안됨.)

> apply에 애니메이션이 있는데 어떻게 백그라운드 큐에서도 작동할까?
