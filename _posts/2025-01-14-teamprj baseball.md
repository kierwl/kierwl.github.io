---
layout: single
comments: true
title: "C#숫자야구 만들기"
categories: TIL
tags: [C#]
---

### 📆 오늘의 TIL (Today I Learned)

------

# 숫자야구 게임 만들기

- **숫자 야구 게임을 작성하세요. 컴퓨터가 3자리의 숫자를 선택하면 사용자가 그 숫자를 맞추는 게임을 구현하세요. 각 자리의 숫자를 비교하여 스트라이크와 볼의 개수를 출력합니다.**

  - **숫자 야구 게임 설명**

    숫자 야구 게임은 3자리의 숫자를 맞추는 게임입니다. 컴퓨터가 고른 3자리 숫자는 모두 다른 숫자로 이루어져 있습니다. 사용자는 3자리 숫자를 입력하고, 컴퓨터는 입력한 숫자와 자리수를 비교하여 스트라이크와 볼의 개수를 알려줍니다.

  - **스트라이크**: 숫자와 자리수가 모두 맞는 경우

  - **볼**: 숫자는 맞지만 자리수가 다른 경우

  예를 들어, 컴퓨터가 427을 선택하고 사용자가 123을 입력했을 때, 2는 맞지만 자리수가 다르므로 1볼, 1은 맞지 않으므로 0스트라이크입니다. 이 과정은 사용자가 정확한 숫자를 맞출 때까지 반복됩니다.

## 사용변수 설명

- `targetNumber`: 컴퓨터가 선택한 3자리의 숫자를 저장하는 배열입니다.
- `userGuess`: 사용자가 추측한 숫자를 저장하는 배열입니다.
- `strikes`: 자릿수와 숫자가 모두 맞는 경우의 개수를 저장합니다.
- `balls`: 자릿수는 맞지 않지만 숫자가 포함된 경우의 개수를 저장합니다.
- `guessedCorrectly`: 사용자가 숫자를 정확히 맞췄는지를 나타내는 불리언 변수입니다.

## 예상 출력

```
Enter your guess (3 digits): 123
0 Strike(s), 0 Ball(s)
Enter your guess (3 digits): 456
0 Strike(s), 0 Ball(s)
Enter your guess (3 digits): 789
0 Strike(s), 3 Ball(s)
Enter your guess (3 digits): 987
3 Strike(s), 0 Ball(s)
Congratulations! You've guessed the number in 4 attempts.
```



### 1. 랜덤 숫자 뽑기

---

```
Random random = new Random();
int[] targetNumber = new int[3];

for (int i = 0; i < 3; i++)
{
    int num;
    do
    {
        num = random.Next(1, 10); // 1부터 9까지 숫자를 랜덤으로 고름
    } while (targetNumber.Contains(num)); // 이미 뽑은 숫자는 다시 뽑지 않음
    targetNumber[i] = num; // 숫자를 배열에 넣음
}

```

- 컴퓨터가 무작위로 1부터 9까지 숫자 3개를 뽑는다.

- **중복되지 않게** 숫자를 선택

- 예를 들어, 컴퓨터가 "5, 7, 3"을 골랐을 경우

  

### 2. 사용자가 숫자를 입력하는 방법

---

```
Console.Write("Enter your guess (3 digits): ");
string input = Console.ReadLine();

// 숫자가 3자리인지 확인!
if (input.Length != 3 || !input.All(char.IsDigit))
{
    Console.WriteLine("Invalid input. Please enter exactly 3 digits.");
    continue;
}

```

- 컴퓨터가 "숫자 3개를 고르라고 한다."
- 우리가 입력한 숫자가 컴퓨터가 고른 숫자와 맞는지 비교한다.
  - 3자리가 아닌 경우 "다시 입력하라고 알려준다."

### 3. 스트라이크와 볼 계산하는법

---

```
int strikes = 0, balls = 0;
for (int i = 0; i < 3; i++)
{
    if (targetNumber[i] == userGuess[i]) // 숫자와 위치가 모두 맞으면
    {
        strikes++;
    }
    else if (targetNumber.Contains(userGuess[i])) // 숫자만 맞고 위치가 다르면
    {
        balls++;
    }
}

```

- 스트라이크 : 숫자와 위치가 맞는경우 +1
- 볼: 숫자만 맞고 위치는 틀린경우 +1
- 예시) 컴퓨터 5, 7, 3
  - 사용자 5, 3, 7
  - 1스트라이크 2볼

### 정답을 입력하여 게임종료

---

```
if (strikes == 3)
{
    Console.WriteLine($"Congratulations! You've guessed the number in {attempts} attempts.");
    break;
}

```

- 스트라이크 3개를 적은 회차로 맞출 수록 점수를 높게 받는다.
- 3개를 다 맞춘경우 축하문구가 출력되며 종료된다.

### 전체 코드

----

```
using System;
using System.Linq;

class NumberBaseballGame
{
    static void Main(string[] args)
    {
        Random random = new Random();
        int[] targetNumber = GenerateRandomNumber(random);

        // 디버깅용: 정답 출력 (필요 시 주석 해제)
        // Console.WriteLine("Secret Number: " + string.Join("", targetNumber));

        int attempts = 0; // 시도 횟수
        while (true)
        {
            attempts++;
            Console.Write("Enter your guess (3 digits): ");
            string input = Console.ReadLine();

            if (!IsValidInput(input, out int[] userGuess)) // 입력 검증 및 배열 변환
            {
                Console.WriteLine("Invalid input. Please enter 3 unique digits between 1 and 9.");
                continue;
            }

            int strikes = CountStrikes(targetNumber, userGuess);
            int balls = CountBalls(targetNumber, userGuess);

            Console.WriteLine($"{strikes} Strike(s), {balls} Ball(s)");

            if (strikes == 3)
            {
                Console.WriteLine($"Congratulations! You've guessed the number in {attempts} attempts.");
                break;
            }
        }
    }

    // 1~9 사이의 서로 다른 3자리 숫자 생성
    static int[] GenerateRandomNumber(Random random)
    {
        return Enumerable.Range(1, 9)
                         .OrderBy(_ => random.Next())
                         .Take(3)
                         .ToArray();
    }
    //1~9 사이의 숫자만 선택: 숫자 야구의 규칙에 따라 1~9의 범위를 고정.
OrderBy와 Take 활용: OrderBy로 무작위로 정렬한 후, Take(3)로 고유한 3개의 숫자를 추출. 이를 통해 코드가 간결해지고 의도가 명확해졌습니다.
재사용성: 랜덤한 숫자를 생성하는 로직이 다른 곳에서 필요하다면 그대로 사용할 수 있도록 독립성을 부여.

    // 입력 검증 및 변환
    static bool IsValidInput(string input, out int[] userGuess)
    {
        userGuess = null;
        if (input.Length != 3 || !input.All(char.IsDigit))
            return false;

        userGuess = input.Select(c => c - '0').ToArray();
        return userGuess.Distinct().Count() == 3 && userGuess.All(n => n >= 1 && n <= 9);
    }
    //유효성 검증과 변환 분리: 입력을 검증하는 동시에 배열로 변환하여 이중 작업을 방지.
명확한 조건 검증:
입력 길이가 3인지 확인.
입력 값이 숫자로만 구성되었는지 확인.
각 숫자가 1~9의 범위에 있고 중복되지 않는지 확인.
out 키워드 활용: 입력값을 변환한 결과를 호출부에 반환하여, 입력 검증 성공 시 결과를 즉시 사용할 수 있도록 설계.

    // 스트라이크 계산
    static int CountStrikes(int[] target, int[] guess)
    {
        return target.Where((num, idx) => num == guess[idx]).Count();
    }

    // 볼 계산
    static int CountBalls(int[] target, int[] guess)
    {
        return guess.Where(num => target.Contains(num)).Count() - CountStrikes(target, guess);
    }
}

```

