---
layout: single
comments: true
title: "C#숫자야구 만들기 2 "
categories: TIL
tags: [C#]
---

### 📆 오늘의 TIL (Today I Learned)

------

- 랜덤 숫자 생성

  :

  - 컴퓨터가 중복되지 않는 3자리 숫자를 생성합니다.

- 사용자 입력

  :

  - 사용자가 3자리 숫자를 입력합니다.

- 결과 계산

  :

  - `스트라이크`와 `볼`을 계산하여 알려줍니다.

- 반복

  :

  - 사용자가 정답(3 스트라이크)을 맞출 때까지 게임이 반복됩니다.

------

### **코드 설명**

#### 1. `Main()` 메서드

**게임의 핵심 로직**이 담겨 있습니다.

- 역할

  :

  - 게임을 시작하고, 사용자 입력을 받아 결과를 계산하며, 정답을 맞출 때까지 반복합니다.

- 흐름

  :

  1. 랜덤 숫자 생성

     :

     - `GenerateTargetNumber` 메서드를 호출하여 컴퓨터가 3자리 랜덤 숫자를 생성합니다.

  2. 사용자 입력

     :

     - 사용자로부터 숫자를 입력받아 유효성 검사를 진행합니다.

  3. 결과 계산

     :

     - `스트라이크`(위치와 숫자 모두 맞음)와 `볼`(숫자는 맞지만 위치가 다름)을 계산하여 출력합니다.

  4. 정답 확인

     :

     - 3 스트라이크가 나오면 정답을 맞췄다고 출력하고 게임을 종료합니다.

------

#### 2. `GenerateTargetNumber` 메서드

- 역할

  :

  - 컴퓨터가 고유한 숫자로 구성된 3자리 숫자를 생성합니다.

- 어떻게 작동하나요?

  :

  1. `random.Next(0, 10)`을 이용하여 0부터 9 사이의 숫자를 생성합니다.
  2. 생성된 숫자가 이미 배열에 포함되어 있다면 다시 생성합니다.
  3. 배열에 3개의 숫자가 들어갈 때까지 반복합니다.

```
csharp코드 복사int digit;
do
{
    digit = random.Next(0, 10);
} while (Array.Exists(number, x => x == digit)); // 중복 검사
```

------

#### 3. `IsValidGuess` 메서드

- 역할

  :

  - 사용자가 입력한 숫자가 유효한지 검사합니다.
  - 입력이 3자리 숫자이고, 모든 숫자가 고유한지 확인합니다.

- 어떻게 작동하나요?

  :

  1. 입력된 값이 정확히 3자리 숫자인지 확인합니다.
     - 숫자가 아니거나 3자리가 아니면 `false`를 반환합니다.
  2. 배열로 변환 후 각 숫자가 고유한지 확인합니다.
  3. 조건을 만족하면 `true`를 반환하여 게임 진행을 계속합니다.

```
csharp코드 복사if (input.Length != 3 || !int.TryParse(input, out _)) // 입력 확인
{
    return false;
}
```

------

#### 4. 스트라이크와 볼 계산

- 역할

  :

  - 사용자 입력과 컴퓨터의 숫자를 비교하여 `스트라이크`와 `볼`을 계산합니다.

- 어떻게 작동하나요?

  :

  1. 반복문을 사용하여 각 자리의 숫자를 비교합니다.
     - **스트라이크**: 숫자와 위치가 모두 일치하는 경우.
     - **볼**: 숫자는 포함되지만 위치가 다른 경우.
  2. 계산된 결과를 출력합니다.

```
csharp코드 복사if (userGuess[i] == targetNumber[i])
{
    strikes++;
}
else if (Array.Exists(targetNumber, x => x == userGuess[i]))
{
    balls++;
}
```

------

### **게임 실행 예시**

1. **게임 시작**:

   ```
   vbnet코드 복사Welcome to the Number Baseball Game!
   Try to guess the 3-digit number. The digits are unique.
   ```

2. **사용자 입력과 결과 확인**:

   - 사용자가 

     ```
     123
     ```

     을 입력한 경우:

     ```
     scss코드 복사Enter your guess (3 unique digits): 123
     1 Strike(s), 1 Ball(s)
     ```

   - 사용자가 

     ```
     456
     ```

     을 입력한 경우:

     ```
     scss코드 복사Enter your guess (3 unique digits): 456
     0 Strike(s), 2 Ball(s)
     ```

3. **정답 맞추기**:

   - 정답을 맞추면 축하 메시지가 출력됩니다:

     ```
     scss코드 복사Enter your guess (3 unique digits): 789
     3 Strike(s), 0 Ball(s)
     Congratulations! You've guessed the number in 5 attempts.
     ```

------

### **게임 사용 방법**

1. Visual Studio 또는 다른 C# IDE에서 새 콘솔 프로젝트를 생성합니다.
2. 위 코드를 복사하여 붙여넣습니다.
3. 프로그램을 실행합니다.
4. 화면에 나오는 안내에 따라 3자리 숫자를 입력하며 정답을 맞추세요.

----

```

```

