###### tags: `WWDC 스터디`

# [WWDC 2019] LLDB: Beyond "po"

> 평소에 사용하는 po 명령어를 뛰어넘어 LLDB를 활용하여 효율적인 디버깅을 하고 싶어서 이 영상을 보게 되었다. 

### po-command 를 사용해서 얻을 수 있는 정보이다. 
![](https://i.imgur.com/YwXZq9z.png)
▼ debugDescription을 변경해줄 수 있다. 
![](https://i.imgur.com/fcaPn2w.png)

이런 식의 명령어를 이용할 수도 있다. 
```swift
(lldb) po cruise.name.uppercased()
(lldb) po cruise.destination.sorted()
```

po 는 `expression --object-description -- ` 와 같다. 

```swift

(lldb) command alias "별명" expression --object-description
```

이렇게 하면 별명으로 뒤에 명령어를 실행할 수 있게 된다. 


### p-command를 이용할 수 있다. 
![](https://i.imgur.com/53MgIZj.png)

결과 값이 `$R0` 라는 변수에 할당이 된다. 이것은 LLDB의 특별한 컨벤션이다. 
결과값이 증가하는 숫자를 포함하는 변수에 할당이 된다. `$R0`,`$R1`,`$R2`...
이 값들은 변수처럼 사용할 수 있다. 

```swift
(lldb) p $R0.destination
```

po와 마찬가지로, p 는 first-class command 가 아니다. "expression"의 alias 커멘드 이다.

Trip이 임의의 Activity라는 protocol을 채택하고, cruise 상수에 Activity 타입 어노테이션을 해줄 시,

접근에러가 난다. static 접근은 에러가 나지만, dynamic 접근은 가능하다.

p-command로 접근하는 것은 static 접근이다.

```swift
(lldb) p cruise.name // 접근에러
(lldb) p (cruise as! Trip).name // 성공
(lldb) v cruise.name // 성공
```

Formatter는 사람이 읽을 수 있게 만들어준다. Formatter가 없이 출력한다면,

```swift
(lldb) expression --raw -- cruise.name 
// 결과 
(Swift.String) $R0 = {
  _guts = {
    _object = {
      _countAndFlagsBits = {
        _value = -3458764513820540908
      }
      _object = 0x8000000100003dd0 (0x0000000100003dd0) CommandLineTool`symbol stub for: Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () + 4
    }
  }
}
```

### v-command를 이용할 수 있다. 
- v 는 기본적으로 p와 같은 결과를 반환한다. 
- v는 frame variable 커맨드의 alias 이다. 
- 이전 두 커맨드와는 다르게 v 커맨드는 코드를 컴파일,실행하지 않아서 속도가 빠르다 
```swift
(lldb) v cruise.name.isEmpty // 실행불가
(lldb) v cruise.name.count // 실행불가

// computed property는 -> p 와 po 에선 사용 가능
```
![](https://i.imgur.com/OAiReSq.jpg)

v 와 p 커맨드의 가장 큰 차이점은 

> The formatter indeed performs dynamic types resolution only once

v는 cuise가(Activity 프로토콜이 채택되어 있더라도) Trip 객체라는 것을 알고 접근할 수 있다. 


### Displaying Variables

![](https://i.imgur.com/40Kifyu.png)

### Customizing Data Formatters

- Filters
```swift
(lldb) type filter add 파일명.타입명 --child 프로퍼티명 // 필터추가
(lldb) v 인스턴스 // 필터링된 결과 반환
(lldb) type filter delete 파일명.타입명 // 필터 제거

```

- String summaries

콘솔창 왼쪽에 나타나는 요소들을 말한다. 
```swift
(lldb) type summary add CommandLineTool.Trip --summary-string "${var.name} from ${var.destination[0]} to ${var.destination[2]}"
(lldb) v cruise
// (CommandLineTool.Trip) cruise = "Mediterranean Cruise" from "Sorrento" to "Taormina"
```

이렇게 하드코딩 하는 방법 이외에 파이썬 포맷을 이용하는 방법도 있다. 

- Synthetic children


# [WWDC18 - Advanced Debugging with Xcode and LLDB]

### expr 의 활용

### 디버깅중 원하는 코드를 주입시키기
> 코드수정을 위해 recompiling 할 필요를 없애준다!! 컴파일시간이 긴 무거운 프로젝트를 다룰 때 유용하게 사용될듯

- symbolic breakpoint를 만들어서 특정 메서드에 breakpoint를 걸 수 있다. 

원하는 코드변경을 한 후, 다시 빌드하는 경우가 많은데, 이렇게 하지 않고 바로 밑줄에 브레이크 포인트를 걸어 expr 로 값변화를 
시켜주면 간단하다 (자동 넘어가기 설정 체크 [16:00 ~]

### 디버깅중 특정 코드줄 건너뛰기 

> 이는 문제를 야기할 수 있다.
```
thread jump --by 1
```
코드로 해당 코드를 뛰어넘고 다른 작업을 수행하거나 생략 하도록 만들어줄 수 있다. 

### Watchpoints 로 지정하여 해당 프로퍼티가 변경될 때 감지할 수 있다. 
![](https://i.imgur.com/Phbjckb.jpg)


### Debugger 에서 UI 수정하는 방법
```
(lldb) exression -l objc -O -- [`self.view` recursiveDescription]
```
위 명령을 이용하여 view 의 정보를 확인할 수 있다. recursiveDescription이란 메서드는 objc 메서드라 이렇게 실행해 주어야 한다. 

objc 명령을 alias를 통해 간단하게 만들어 주어야 겠다. 

```
(lldb)command alias poc expression -l objc -O --
```
```
// UI 요소의 원하는 주소값을 대입하면 해당 객체의 정보를 확인할 수 있다. po 명령으로는 안됨
poc 0x12e308670

// po를 사용해서 볼 수 있는 방법은 이런 메서드를 사용하면 된다.

po unsafeBitCast(0x12e308670, to: ProductDetailViewController.self)
```
이 명령어를 통해 해당 UI에 접근이 가능하다. frame 에 접근할 수 있다.

```
po unsafeBitCast(0x12e308670, to: ProductDetailViewController.self).center.y = 200
expression CATransaction.flush() 

```

이렇게 하면 디버거에서 UI의 위치를 옮겨줄 수 있다. 
python script를 import 하여 사용하면 편리하게 이용할 수 있다. [31:10]

나의 최신버전 Xcode의 경우 그냥 디버거에서 UI 요소에 접근만 되면 `po CATransaction.flush()` 메서드를 이용해 간단하게 UI 를 변경해줄 수 있었다. (업데이트 되면서 간편해진건가?)

![](https://i.imgur.com/bJIzYE7.gif)


`po CATransaction.flush()` 명령을 계속 쳐줘야 해서 불편함이 있다. 그래서 파이썬 스크립트를 이용하는건가 싶다...

이 방법을 이용하면 디버깅 중 UI에 접근하여 layout을 변경하거나 backgroundColor를 변경하는 등 다양한 접근을 할 수 있어서 re-run, re-compile 하지 않고도 UI 변경 사항을 확인할 수 있어 시간절약에 도움이 될 것 같다!

# Reference 
- [WWDC19 - LLDB: Beyond "po"](https://developer.apple.com/wwdc19/429)
- [WWDC18 - Advanced Debugging with Xcode and LLDB](https://developer.apple.com/wwdc18/412 )

