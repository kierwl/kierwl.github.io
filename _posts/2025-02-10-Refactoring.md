---
layout: single
comments: true
title: "가독성 "
categories: TIL
---





### 📆 오늘의 TIL (Today I Learned)

---

## 가독성을 높이는 방법

 코드는 이해하기 쉬워야 한다.

- 가독성 좋은 코드란? 다른 사람 그리고 1년 후의 내가 코드를 이해하는 데 필요한 시간을 최소화한 것이라는 의미이다.
- "가독성이 좋은 것"이 "분량이 적은 것"보다 더 중요하다.
- 함수이름, 변수이름을 지을 때 구체적인 단어를 사용한다.

- get, size, stop은 지나치게 보편적인 단어이므로 사용하지 않는다. get은 fetch 또는 download, size는 height 또는 number of node, memory bytes, stop은 kill 또는 pause 등 여러 가지로 해석될 수 있으므로 구체적인 단어를 사용한다.
- 필요하면 긴 이름을 사용한다.
- 단위 또는 보안 관련 버그 등 세부 정보를 반영한다. 
  ex) throttleDownload(limit: Float) → throttleDownload(max_kbps: Float)
  ex) untrustedUrl, unsafeMessageBody
- 중의적으로 해석되는 단어를 피하고, 구체적인 단어를 사용한다.

- 예를 들어 clip(text, length) 을 truncate(text, max_chars) 으로 수정하면, 텍스트의 처음부터 특정 문자의 개수까지 잘라낸다는 뜻을 명시할 수 있다.
- 경계를 나타낼 때 관습적으로 사용하는 단어가 있다.
  - 경계를 포함하는 한계값은 min/max 접두사를 사용한다. ex) cartTooBigLimit → maxItemsInCart
  - 경계를 포함하는 범위는 first/last 를 사용한다. ex) start & stop → start & last
  - 경계의 시작만 포함하고, 마지막은 배제하는 범위는 begin/end 를 사용한다. ex) printEventsInRange(begin: "OCT 16 12:00am", end: "OCT 17 12:00am")
- 불리언 변수는 is, has, can, should 로 의미를 구체화한다. 또한 부정문 형태를 피한다.
  - ex) readPassword → need_password 또는 user_is_authenticated 를 사용하여 중의적인 단어 read 대신, "패스워드를 읽을 필요가 있는지" 또는 "이미 읽힌 패스워드인지" 명시한다.
  - ex) spaceLeft → hasSpaceLeft 를 사용하여 불리언값을 반환함을 명시한다.
  - ex) disableUrl = false → useUrl = true 를 사용하면 부정문이 아니라서 이해가 쉽다.
- 개발자의 관행에 따른다.
  - get은 관행적으로 가벼운 접근자 (lightweight accessors)로 단순히 내부 멤버를 반환할 때 사용한다.
    ex) 복잡한 연산을 통해 Mean을 구할 경우 getMean → computeMean을 사용한다.
- 미학적으로 보기 좋은 코드가 가독성도 좋다. 코드를 읽는 사람에게 친숙한 레이아웃을 사용한다.

- 비슷한 기능의 코드는 서로 비슷해 보이게 만든다. (줄바꿈 위치, 들여쓰기 위치, 공백 간격 등을 통일하여 일관된 형식을 유지한다.)
- 여러 개의 변수를 선언할 때, 중요도가 높은 순으로 배치한다.
- (글의 내용을 문단으로 나누듯이) 줄바꿈을 통해 코드의 논리적 단계를 구분한다.
- 주석의 목적은 코드를 읽는 사람이 코드 작성자만큼 코드를 잘 이해하도록 돕는 것이다. 

- 코드에서 빠르게 유추 가능한 내용은 주석으로 달지 않는다.
- 주석을 달기 전에 함수이름이나 변수이름을 고칠 수 있는지 확인한다. (좋은 코드 > 나쁜 코드 + 좋은 주석)
- 코딩을 하는 당시의 고려사항 및 중요 정보를 기록한다.
  - ex) // 놀랍게도, 이 데이터에서 이진트리는 해시테이블보다 40% 정도 빠르다. 해시를 계산하는 비용이 좌/우 비교를 능가한다. 를 사용하여 코드를 읽는 사람이 코드 최적화에 시간을 낭비하지 않도록 한다.
  - ex) // 이 주먹구구식 논리는 몇 가지 단어를 생략할 수 있다. 를 사용하여 버그를 수정하기 위해 테스트하는데 시간을 낭비하지 않도록 한다.
  - ex) // TODO(Kevin): JPEG 이외의 다른 이미지 포맷도 처리할 수 있어야 한다. 를 사용하여 개선 아이디어를 전달한다. *TODO:, maybeLater: 아직 하지 않은 일, FIXME: 오동작을 일으킨다고 알려진 코드, HACK: 바람직하지 않은 해결책, XXX: 큰 문제가 있음
- 중요한 상수는 값의 설정 기준을 기록한다.
- 다른 사람들이 쉽게 놓칠 수 있는 부분을 기록한다.
- 상위수준 주석을 통해 클래스 간의 상호작용이나 데이터의 흐름 등 코드의 큰 그림을 설명하고, 하위수준 주석을 통해 함수 내부의 코드를 기능 단위로 설명한다.
- 주석은 명확하고 간결하게 작성한다.

- 모호한 대명사를 피한다.
  ex) // Insert the data into the cache, but check if it's too big first. → // If the data is small enough, insert it into the cache. 로 사용하여 it 이 가르키는 것이 chache가 아니라 data임을 명시한다.

- 함수의 동작이 복잡할 경우, 구체적인 입/출력 예시를 추가 작성한다.

  ```
  // 입력된 'source'의 'chars'라는 접두사 및 접미사를 제거한다.
  // 예: Strip(source: "abba/a/ba", "ab")은 "/a/"를 반환한다.  <- 구체적인 입출력 예시
  func Strip(source: String, chars: String) -> String {...}
  ```

  

- 코드가 수행하는 동작이 아니라 코드의 의도를 명시한다.
  ex) // 리스트를 역순으로 반복한다. → // 각 가격을 높은 값에서 낮은 값 순으로 나타낸다. 코드의 기능을 이해하기 쉬우므로 코드를 검증 (중복검사)을 하는 효과가 있다.

- Swift, Python 등과 같이 함수의 매개변수 이름을 제공하는 언어가 아니라면 (C++, Java 등), 매개변수 앞에 주석을 단다.

  ```
  Connect(/* timeout_ms = */ 10, /* use_encryption = */ false);
  ```

- Control Flow와 관련된 조건문/반복문은 자연스럽게 만든다. 코드를 읽다가 다시 앞으로 되돌아가지 않게 한다.

- 조건문에서 왼쪽에 유동적인 대상, 오른쪽에 고정값을 두는 것이 자연스럽다.
  ex) if length > 10 {...} 이 if 10 < length {...} 보다 자연스럽다. (영어 어순과 일치한다. "길이가 10보다 크다"가 "10이 길이보다 작다" 보다 자연스럽다.)

- if-else문에서 if문에 부정문보다는 긍정문 형태를 사용한다. if a == b {...} else {...} 이 if a != b {...} else {...} 보다 자연스럽다.

- 삼항연산자 A ? B : C 는 B 및 C가 매우 간단할 때만 사용한다.
  ex) timeString += (hour >= 12) ? "pm" : "am" 는 좋지만, return (exponent >= 0) ? mantissa * (1 << exponent) : mantissa / (1 << -exponent) 는 가독성이 떨어지므로 if-else 문으로 작성하는 것이 낫다.

- 중첩을 최소화한다. if문 내부에 if문을 중첩하는 것보다 2개의 독립적인 if문을 사용하는 것이 가독성이 좋다.

- 스레딩, 시그널/인터럽트 핸들러, 예외, 함수 포인터 및 익명 함수, 가상 메서드는 꼭 필요할 때 사용한다. 과도하게 사용하면 코드 흐름을 파악하기 어렵다.

- repeat-while 루프 (C++에서는 do-while 루프)보다는 while 루프를 사용한다. repeat 내용을 읽고, while의 조건을 읽은 뒤에 다시 repeat의 내용을 읽어야 하기 때문이다. 또한 repeat-while 루프에서 *continue 사용을 피한다.

  ```
  var count = 0
  
  repeat {
      count += 1
      continue
  } while false
  print(count) // count의 출력값은 2일 것 같지만, 1이다.
  ```

- 거대한 코드를 소화하기 쉽도록 여러 조각으로 나눈다.

- 의미 단위로 코드를 분리하여 핵심 개념을 쉽게 파악하도록 한다.

  ```
  if inputString.split("/")[0].strip() == "root"
  
  // 개선
  userName = inputString.split("/")[0].strip() // 설명 변수/추가 변수 (하위 표현의 의미를 설명하는 변수)를 사용한다.
  if userName == "root"
  ```

  ```
  if a == b {
  }
  if a != b {
  }
  
  // 개선
  let userOwnsDocument: Boolean = (a == b) // 요약 변수 (코드의 핵심 내용을 짧은 이름으로 대체하는 변수)를 사용한다.
  if userOwnsDocument {
  }
  if !userOwnsDocument {
  }
  ```

- 드모르간의 법칙을 적용하여 Boolean 표현을 명확히 한다. 즉, if !(A && !B) 보다 if (!A || B) 가 좋다. 

  ```
  // 드모르간의 법칙
  not (A or B or C)   <=> (not A) and (not B) and (not C)
  not (A and B and C) <=> (not A) or (not B) or (not C)
  ```

  

- 복잡한 논리를 다룰 경우, 원하는 기능의 반대 개념을 코드로 구현하는 것이 보다 쉬울 수도 있다.

- 변수의 사용범위를 최소화한다. 

  - 전역변수를 피한다.

  - 변수를 클래스 내부 또는 함수 내부로 옮겨서 보다 제한적인 범위에서 사용한다. 

    ```
    class LargeClass {
    var classVariable: String = ""  // 클래스 내부에서 사용되는 변수
    
    func methodA() {
        classVariable = //...
        methodB()
    }
    
    func methodB() {
    	// classVariable를 이용한다.
    }
    
    // 개선
    class LargeClass {
    
    func methodA() {
        var stringA: String = ""
        methodB(stringB: stringA)  // 함수 내부에서 사용하도록 강등시킨다. (변수 사용범위를 최소화한다.)
    }
    
    func methodB(stringB: String) {
    	// stringB를 이용한다.
    }
    ```

- 주요 기능과 관련이 적은 하위문제는 분리하여 별도의 함수로 만든다.

- 프로그래밍은 큰 문제를 작은 문제들로 쪼개고, 각 문제에 대한 해결책을 구한 뒤, 다시 하나의 해결책으로 통합하는 작업이다. 이때 큰 그림과 관련이 적은 하위문제를 찾아서 추출해야 한다. (함수를 호출한 코드가 간단해진다. 또한 독립적인 기능을 수행하므로 다른 프로젝트에서도 사용 가능하다.)
- 문자열 변경, 해시테이블 사용, 파읽 읽기/쓰기 등 기본 유틸리티 기능은 별도 함수로 구현한다. 
- 기존 인터페이스가 복잡하면 별도 함수를 생성하여 단순한 형태로 만든다.
- 프로그램의 실질적인 기능과 관련이 적은 접착 코드 (glue code, 함수에 주어진 입력을 설정하거나 출력된 결과를 처리하는 등의 작업을 수행함)는 별도의 함수로 생성한다.
- 한 번에 1개의 작업만 수행하도록 코드를 구성한다.

- 필요한 작업을 나열하고, 각 작업을 함수로 구분한다.
- 비전문가에게 쉽게 설명하듯이 코딩한다.

- 디버깅할 때 말로 소리 내어 설명하는 것이 도움이 된다. (Rubber ducking 기법)
- 불필요한 코드를 삭제한다.

- 표준 라이브러리를 활용한다. 매일 15분씩 표준 라이브러리의 모든 함수/모듈/타입의 이름을 읽는 버릇을 들인다.
  ex. 중복 요소가 없는 Collection이 필요하면, 중복 제거 메서드를 구현하는 대신 Set 타입을 활용한다.
- 유닉스 도구를 활용한다.
- 테스트 코드 (코드가 수행하는 작업을 검사하는 목적)는 읽고, 유지보수하기 쉽도록 만든다.

- 테스트 코드에서 중요도가 낮은 내용을 숨겨서 중요한 내용이 돋보이게 한다.
  ex) checkScoresBeforeAfter("-5, 1, 4, -999.8, 3", "4, 3, 1") 라는 코드는 element를 내림차순으로 정렬하고, 점수가 0보다 낮은 것을 제거한다, 라는 의도가 명확히 드러난다.
- 숫자 형태의 비교값은 모든 조건을 포함하되, 가장 간단한 값으로 사용한다.
  ex) checkScoresBeforeAfter("-5, 1, 4, -999.8, 3", "4, 3, 1") 보다는 checkScoresBeforeAfter("1, 2, -1, 3", "3, 2, 1") 이 좋다.
- 필요하면 여러 개의 테스트 케이스를 만든다.
  ex) 내림차순으로 정렬하는 기능, 음수를 필터링하는 기능을 2가지 테스트 케이스로 구현한다.
- 에러 메시지는 assert 메서드를 사용한다.
  ex) assert(someInt == 0, "검증A 실패") 조건이 false이면 동작을 중지하고, 에러 메시지로 "검증A 실패"를 전달한다.
- 테스트 함수에 이름을 붙인다. test1 보다는 테스트할 함수 또는 테스트할 상황 등 테스트 내용을 나타내는 이름을 사용한다.
- 테스트 코드를 염두에 두고 코딩을 한다. (Test-Driven Development, 테스트 주도 개발 즉, 코드 작성 전에 테스트 코드부터 작성하는 프로그래밍 스타일도 있다.)
