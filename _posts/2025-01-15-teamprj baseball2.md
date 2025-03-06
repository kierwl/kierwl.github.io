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



----

```
using System;

class NumberBaseballGame
{
    static void Main()
    {
        Random random = new Random();
        int[] targetNumber = GenerateTargetNumber(random); // 랜덤숫자 생성
        int attempts = 0; //도전회수
        bool guessedCorrectly = false; // 숫자의 정답여부

        Console.WriteLine("Start Number Baseball Game!");
        Console.WriteLine("Try to guess the 3-digit number. The digits are unique.");

        while (!guessedCorrectly)// 정답이 아니라면 계속 반복
        {
            attempts++; // 도전 회차 증가
            Console.Write("Enter your guess (3 unique digits): ");
            string input = Console.ReadLine();//입력된 문자열 읽어오기
            int[] userGuess; //유저가 입력한 배열로 등록

            if (!IsValidGuess(input, out userGuess)) // 입력된 데이터가 숫자가 아닌경우
            {
                Console.WriteLine("Invalid input. Please enter exactly 3 unique digits.");
                continue;
            }

            int strikes = 0, balls = 0; // 0으로 초기화
            for (int i = 0; i < 3; i++) // 자릿수 선정
            {
                if (userGuess[i] == targetNumber[i]) // 입력된 숫자의 위치와 숫자가 일치하는 경우
                {
                    strikes++;
                }
                else if (Array.Exists(targetNumber, x => x == userGuess[i])) //선택한 배열이 숫자가 일치하는지 확인 조건을 만족하면 true값
                {
                    balls++;
                }
            }

            Console.WriteLine($"{strikes} Strike(s), {balls} Ball(s)");

            if (strikes == 3)// 3개전부 일치하는 경우
            {
                guessedCorrectly = true;
                Console.WriteLine($"Congratulations! You've guessed the number in {attempts} attempts.");
            }
        }
    }

    // 고유한 숫자로 구성된 3자리 숫자를 생성
    static int[] GenerateTargetNumber(Random random) // 랜덤 숫자 생성
    {
        int[] number = new int[3];// 배열에 3입력 (0,1,2)
        for (int i = 0; i < 3; i++)
        {
            int digit;
            do
            {
                digit = random.Next(0, 10); // 0부터 9까지
            } while (Array.Exists(number, x => x == digit)); // 중복 숫자가 없도록 확인하고 다시 시도
            number[i] = digit; // number라는 배열안의 i번에 수를 집어넣음
        }
        return number;
    }

    // 사용자 입력을 유효성 검사하고 정수 배열로 변환
    static bool IsValidGuess(string input, out int[] guess)
    {
        guess = new int[3];
        if (input.Length != 3 || !int.TryParse(input, out _)) // 입력이 3자리 숫자인지 확인
        {
            return false;
        }

        for (int i = 0; i < 3; i++)// 유니코드변환 (3= 51)(0 = 48)>> 51- 48 =3
        {
            guess[i] = input[i] - '0';
        }

        // 고유한 숫자인지 확인
        return guess.Length == 3 && guess[0] != guess[1] && guess[1] != guess[2] && guess[0] != guess[2]; // 하드코딩 >> Hashset을 사용하여 대체가능
    }
}

```

