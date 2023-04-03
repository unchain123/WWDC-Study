Regular Expression. 문자열을 처리하기 위한 방법이죠~

## Collection 다루기
- 원소 기반: map, filter, split
- 저수준 인덱스 기반: index(after:), firstIndex(of:), 슬라이싱 subscript

``` swift
// 컬렉션을 다루는 방법으로 문자열을 다루었을 경우

let transaction = "DEBIT     03/05/2022    Doug's Dugout Dogs         $33.27"

let fragments = transaction.split(whereSeparator: \.isWhitespace)
// ["DEBIT", "03/05/2022", "Doug\'s", "Dugout", "Dogs", "$33.27"]

var slice = transaction[...]

// Extract a field, advancing `slice` to the start of the next field
func extractField() -> Substring {
  let endIdx = {
    var start = slice.startIndex
    while true {
      // Position of next whitespace (including tabs)
      guard let spaceIdx = slice[start...].firstIndex(where: \.isWhitespace) else {
        return slice.endIndex
      }

      // Tab suffices
      if slice[spaceIdx] == "\t" {
        return spaceIdx
      }

      // Otherwise check for a second whitespace character
      let afterSpaceIdx = slice.index(after: spaceIdx)
      if afterSpaceIdx == slice.endIndex || slice[afterSpaceIdx].isWhitespace {
        return spaceIdx
      }

      // Skip over the single space and try again
      start = afterSpaceIdx
    }
  }()
  defer { slice = slice[endIdx...].drop(while: \.isWhitespace) }
  return slice[..<endIdx]
}

let kind = extractField()
let date = try Date(String(extractField()), strategy:  Date.FormatStyle(date: .numeric))
let account = extractField()
let amount = try Decimal(String(extractField()), format: .currency(code: "USD"))

```

딱 봐도 문제가 있어 보이죠..

## 정규 표현식
많은 언어에서 이런 문제를 해결하기 위해 사용하는 것. 원래 목적은 이것만은 아니지만, 입력값의 부분을 추출하고 실행을 제어 및 명령하며 표현력을 강화한다.
Swift의 정규 표현식 문법은 많은 언어와 호환된다.

``` swift
// Regex literals
let digits = /\d+/
// digits: Regex<Substring>

// Run-time construction 런타임에 만들어지는 정규 표현식
let runtimeString = #"\d+"#
let digits = try Regex(runtimeString)
// digits: Regex<AnyRegexOutput> 캡쳐되는 유형과 수는 런타임시까지 알 수 없기 때문.

// Regex builders 정규식 빌더를 사용해 선언적이고 더 구조화된 정규식을 작성할 수 있다.
let digits = OneOrMore(.digit)
// digits: Regex<Substring>
```

``` swift
// 정규식 빌더를 활용해 위에서 썼던 split을 대체해 보자면
let transaction = "DEBIT     03/05/2022    Doug's Dugout Dogs         $33.27"

let fragments = transaction.split(separator: /\s{2,}|\t/)
// \s는 공백 문자, {2,}는 2회 이상, |는 혹은, \t는 탭을 나타낸다.
// ["DEBIT", "03/05/2022", "Doug's Dugout Dogs", "$33.27"]
// 결과를 join해도 되지만...
let transaction = "DEBIT     03/05/2022    Doug's Dugout Dogs         $33.27"

let normalized = transaction.replacing(/\s{2,}|\t/, with: "\t")
// DEBIT»03/05/2022»Doug's Dugout Dogs»$33.27
// 이렇게 replacing을 활용해 하나의 공백으로 대체해줄 수 있다.
```

Swift의 정규식은 기존 정규식의 문제를 보완한 혁신이 있는 정규식이다.. 4가지 영역에서
- 기존 정규식은 (간결하고 표현력이 뛰어나지만) 너무 축약적이어서 읽기 어렵다. 이러면 새로운 기능이 추가될 때마다 거의 암호화된다.
    - Swift에서는 Regex Builder를 사용해 소스 코드를 구조화하고 조직화할 수 있다. 리터럴은 간결하고 빌더는 구조를 제공한다.
- 데이터 텍스트 표현은 너무 복잡하다보니, 표준을 따르는 파서가 필요하다.
    - Swift 정규식은 강력한 파서를 제공한다. 라이브러리 확장 방식으로 수행이 된다.
- 너무 고릿적 도구다. 아스키 시절에 쓰이던 건데. 그래서 표현식도 아스키만 쓸 수 있다.
    - Swift 정규식은 유니코드를 쓰면서 표현력을 유지한다.
- 정규식을 쓰면 (광범위한 검색을 할 수 있는 대신) 어떻게 작동하는지 감이 안 온다.
    - Swift 정규식은 실행을 예측할 수 있고, 제어 문자를 쉽게 볼 수 있다.

``` swift
// CREDIT    03/02/2022    Payroll from employer         $200.23
// CREDIT    03/03/2022    Suspect A                     $2,000,000.00
// DEBIT     03/03/2022    Ted's Pet Rock Sanctuary      $2,000,000.00
// DEBIT     03/05/2022    Doug's Dugout Dogs            $33.27

import RegexBuilder
 
let fieldSeparator = /\s{2,}|\t/
let transactionMatcher = Regex {
  /CREDIT|DEBIT/ // 이 둘 중 하나
  fieldSeparator // 위에서 정의한 "공백 기준"
  One(.date(.numeric, locale: Locale(identifier: "en_US"), timeZone: .gmt)) // 날짜 부분 - 여기서는 미국 로케일을 사용함 + 1개만
  fieldSeparator // 공백
  OneOrMore { // + 1개 이상
    NegativeLookahead { fieldSeparator } // 공백은 아닌 문자 중에서 (NegativeLookahead는... 이건 인식한 걸로 안 친다, 같은 느낌이랄까)
    CharacterClass.any // 모든 문자
  }
  fieldSeparator // 공백
  One(.localizedCurrency(code: "USD").locale(Locale(identifier: "en_US"))) // 화폐 단위 - 여기서는 미국 달러 + 1개만
}
// 이렇게~ 구성된 문자열 데이터를 찾아봐라 라는 것입니다.

// 그리고 데이터 인식뿐만 아니라 추축을 하고 싶은 거니까
let transactionMatcher = Regex {
  Capture { /CREDIT|DEBIT/ }
  fieldSeparator

  Capture { One(.date(.numeric, locale: Locale(identifier: "en_US"), timeZone: .gmt)) }
  fieldSeparator

  Capture {
    OneOrMore {
      NegativeLookahead { fieldSeparator }
      CharacterClass.any
    }
  }
  fieldSeparator
  Capture { One(.localizedCurrency(code: "USD").locale(Locale(identifier: "en_US"))) }
}
// Capture를 통해 추출도 해 줍니다.
// transactionMatcher: Regex<(Substring, Substring, Date, Substring, Decimal)>
```

근데 만약 (개빡치게도) 같이 일하는 사람들은 String으로 데이터를 유지하고자 한다면? 하..

이번엔 확장된 구분자를 활용해 정규식을 만들어 봅시다!
``` swift
let regex = #/
  (?<date>     \d{2} / \d{2} / \d{4})
  (?<middle>   \P{currencySymbol}+)
  (?<currency> \p{currencySymbol})
/#
// Regex<(Substring, date: Substring, middle: Substring, currency: Substring)>
// 이런 식으로 쓰면, 슬래시를 이스케이핑 문자 처리 하지 않고도 내부에 넣을 수 있다. 공백 무시 모드도 지원해서, 일반 코드처럼 가독성을 위해 공백을 사이사이에 넣어 줄 수 있다.
// 슬래시가 왜 이스케이핑 문자인지, 공백이 어떤 의미인지는.. 정규 표현식 자체에 대해 알아봐야 해요.

// foundation의 날짜/구문 분석기를 활용해 하드코딩을 방지
// 통화 종류에 따라 날짜 표시 형식의 정책을 정하는 헬퍼 함수
func pickStrategy(_ currency: Substring) -> Date.ParseStrategy {
  switch currency {
  case "$": return .date(.numeric, locale: Locale(identifier: "en_US"), timeZone: .gmt)
  case "£": return .date(.numeric, locale: Locale(identifier: "en_GB"), timeZone: .gmt)
  default: fatalError("We found another one!")
  }
}

// 그리고 이를 기반으로 캡쳐해서 날짜의 표시형식 파악하고 추출하기
ledger.replace(regex) { match -> String in
  let date = try! Date(String(match.date), strategy: pickStrategy(match.currency))

  // ISO 8601, it's the only way to be sure 국제표준으로 날짜 형식을 변환하는 과정
  let newDate = date.formatted(.iso8601.year().month().day()) 

  // 유니코드를 지원하기 때문에 통화기호도 잘 가져온다.
  return newDate + match.middle + match.currency
}
```

유니코드를 지원한다는 건, 이모지도 지원한다는 것.
극단적으로, Unicode extended grapheme clusters라는 것이 있다. 하나 이상의 유니코드 스칼라 값으로 제공된다. UnicodeScalarView를 통해 각각의 값에 액세스할 수 있게 한다.
문자가 메모리에 저장되면 유니코드(UTF-8)로 인코딩되고, 이 값을 utf8 메서드로 볼 수 있다.
    참조. UTF-8은 가변 너비 인코딩! 하나의 스케일러에 여러 바이트가 필요할 수 있고, 하나의 문자에 여러 스케일러가 필요할 수도 있다.

``` swift
let aZombieLoveStory = "🧟‍♀️💖🧠"
// Characters: 🧟‍♀️, 💖, 🧠

aZombieLoveStory.unicodeScalars
// Unicode scalar values: U+1F9DF, U+200D, U+2640, U+FE0F, U+1F496, U+1F9E0

aZombieLoveStory.utf8
// UTF-8 code units: F0 9F A7 9F E2 80 8D E2 99 80 EF B8 8F F0 9F 92 96 F0 9F A7 A0

```

영어 이외의 언어를 다룰 때는 정확히 같은 문자가 다른 스케일러로 표현되는 경우도 있다.

``` swift
"café".elementsEqual("cafe\u{301}")
// true

"café".elementsEqual("cafe\u{301}")
// true

// 스케일러나 UTF-8 등 더 저수준의 관점에서는 두 가지 문자열이 다를 수 있다는 것.
"café".unicodeScalars.elementsEqual("cafe\u{301}".unicodeScalars)
// false

"café".utf8.elementsEqual("cafe\u{301}".utf8)
// false
```

Swift 정규식은 기본적으로 유니코드를 엄격히 따른다구. 하지만 표현력이 떨어지지 않는다.

``` swift
switch ("🧟‍♀️💖🧠", "The Brain Cafe\u{301}") {
case (/.\N{SPARKLING HEART}./, /.*café/.ignoresCase()): // /N은 모든 문자라는 뜻. 따라서, 반짝이는 하트라고 명명된 모든 문자와, 대소문자를 무시한 카페 단어
  print("Oh no! 🧟‍♀️💖🧠, but 🧠💖☕️!")
default:
  print("No conflicts found")
}

let input = "Oh no! 🧟‍♀️💖🧠, but 🧠💖☕️!"

input.firstMatch(of: /.\N{SPARKLING HEART}./)
// 🧟‍♀️💖🧠

input.firstMatch(of: /.\N{SPARKLING HEART}./.matchingSemantics(.unicodeScalar))
// ️💖🧠
// 둘의 차이? 유니코드 스케일러에서 보는, 말하자면 더 저수준에서 매칭했을 때의 차이
// 기억해봅시다. 저 세 개 짜리 이모지는 Unicode extended grapheme clusters다. 따라서 sparkling heart가 포함돼 있으므로, 매칭이 되는 것이다.
// 하지만 유니코드 스케일러 관점에선 엄연히 "다른 문자".
```

좋다. 이제 정확성과 정밀성에는 의심의 여지가 없다.
아까 쓰던 금융 데이터에서, 미리 주어진 데이터 대신 실시간으로 거래 현황을 알 수 있게 프로그램을 바꾸었다면?
빡치지만, Swift Regex를 활용해 이 문제를 해결할 수 있다.
아까와의 차이점은, 날짜 대신 정확한 타임스탬프가 있다는 것. 되게 "지들만 알아듣는" 100년 전 스타일로 써 있지만, 오케이라고 합니다.
개인과 식별 정보 필드는, 입력에서 파생된 런타임 컴파일 정규식을 사용해 필터링할 수 있다. 관심 없는 거래는 애시당초 제외시키려구.
금액과 체크섬은 애시당초 잘 있다.

``` swift
let timestamp = Regex { ... } // proprietary
let details = try Regex(inputString)
let amountMatcher = /[\d.]+/

// CREDIT    <proprietary>      <redacted>        200.23        A1B34EFF     ...
// 이번 트랜잭션 매처는 이전에 우리가 만든 것과 비슷하다만, 확장성이 떨어진다.
// 정규식은 단일 필드에서만 실행되도록 하는 것이 이상적인데..
let fieldSeparator = /\s{2,}|\t/
let transactionMatcher = Regex {
  Capture { /CREDIT|DEBIT/ }
  fieldSeparator

  Capture { timestamp }
  fieldSeparator

  Capture { details }
  fieldSeparator

  // ...
}

let field = OneOrMore {
  NegativeLookahead { fieldSeparator }
  CharacterClass.any
}
// 필드 구분자를 찾을 때까지 문자와 매칭되며, 이를 사용해 정규식을 포함하고자 한다.
// 0번째 줄이 항상 필드를 나타낸다고 상술했었죠.

// 이를 기반으로 리팩토링하면..
// CREDIT    <proprietary>      <redacted>        200.23        A1B34EFF     ...
let fieldSeparator = /\s{2,}|\t/
let field = OneOrMore {
  NegativeLookahead { fieldSeparator }
  CharacterClass.any
}
let transactionMatcher = Regex {
  Capture { /CREDIT|DEBIT/ }
  fieldSeparator

  TryCapture(field) { timestamp ~= $0 ? $0 : nil }
  fieldSeparator

  TryCapture(field) { details ~= $0 ? $0 : nil }
  fieldSeparator

  // ...
}
// TryCapture가 적극적으로 매칭에 관여한다.
```

한편, 우리가 정의했던 fieldSeparator는 2개 이상의 공백이나 단일 탭과 매칭되는데..
이후에 이게 실패하게 되면, 쭉 앞으로 갔다가 돌아와서 재시도 전에 실패한 부분을 제외하고 매칭하고, 그런 식으로 진행된다. 8개의 공백이 있다고 하면, 해당 패턴은 8개의 공백이 될 수도 있고, 7개의 공백이 될 수도 있고, ... 2개의 공백이 될 수도 있는 것이다. 아무튼 잠재적으로 그 패턴이랑 매치가 되니까.
이런 식으로 모든 경우의 수를 매칭하고자 시도하는 것을 전역 백트래킹, 혹은 클레이니 클로저라고 한다. 이 기능을 통해 정규식의 힘은 더 강해지지만... 이 경우 우리는 리니어한 검색 공간이 필요하지. 모든 공백을 빠짐없이 탐색하고자 할 뿐이다. 
우리의 fieldSeparator를 전역 범위가 아닌 로컬 백트래킹 범위에 넣어 보자. 
로컬 빌더는 스코프를 생성하는데, 정규식이 성공적으로 매칭되지 않으면 시도되지 않은 alternative는 버려진다.

``` swift
// CREDIT    <proprietary>      <redacted>        200.23        A1B34EFF     ...
let fieldSeparator = Local { /\s{2,}|\t/ } 
let field = OneOrMore {
  NegativeLookahead { fieldSeparator }
  CharacterClass.any
}
let transactionMatcher = Regex {
  Capture { /CREDIT|DEBIT/ }
  fieldSeparator

  TryCapture(field) { timestamp ~= $0 ? $0 : nil }
  fieldSeparator

  TryCapture(field) { details ~= $0 ? $0 : nil }
  fieldSeparator

  // ...
}
```

정규식의 기본값인 전역 매칭은 검색에 유용하고, 로컬은 정확하게 지정된 토큰을 매칭할 때 유용하다.

참조 (정규식): https://github.com/dream-ellie/regex
정규식 강좌: https://school.programmers.co.kr/learn/courses/11/11-%EC%A0%95%EA%B7%9C%ED%91%9C%ED%98%84%EC%8B%9D
