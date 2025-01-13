---
layout: single
comments: true
title: "C#행맨 만들기"
categories: TIL
tags: [C#]
---

### 📆 오늘의 TIL (Today I Learned)

------

# 행맨 게임 만들기

- 사용자로부터 문자를 입력받아 숨겨진 단어를 맞추는 행맨 게임을 작성하세요. 사용자가 단어의 모든 문자를 맞추거나 주어진 기회 내에 맞추지 못할 때까지 반복합니다.
  - **게임 설명**: 행맨 게임은 사용자가 단어를 추측하는 게임입니다. 사용자는 알파벳을 하나씩 입력하고, 맞출 때마다 단어의 해당 위치에 문자가 표시됩니다. 틀릴 경우, 기회가 줄어듭니다.
  - **배열 사용**: `char[]` 배열을 사용하여 단어를 저장하고, 추측된 문자를 저장합니다.
  - **반복문 사용**: 게임은 사용자가 단어를 맞추거나 기회가 끝날 때까지 반복됩니다.
  - **조건문 사용**: 각 입력된 문자가 단어에 포함되는지 확인합니다.

## 사용변수 설명

- `secretWord`: 맞춰야 할 단어입니다. 예제에서는 "hangman"으로 설정되어 있습니다.
- `guessWord`: 사용자가 맞춘 문자를 저장하는 문자 배열로, 초기에는 언더스코어(`_`)로 채워져 있습니다.
- `attempts`: 사용자가 틀릴 수 있는 기회의 수로, 초기에는 6으로 설정되어 있습니다.
- `wordGuessed`: 사용자가 단어를 모두 맞췄는지를 나타내는 불리언 변수입니다.

## 예상 출력

```
현재 단어: ha___a_
남은 기회: 6
문자를 추측하세요: l
틀렸어요! 다시 시도하세요.

현재 단어: ha___a_
남은 기회: 5
문자를 추측하세요: g
잘 했어요! 맞춘 문자입니다.

현재 단어: ha_g_a_
남은 기회: 5
문자를 추측하세요: m
잘 했어요! 맞춘 문자입니다.

현재 단어: ha_gma_
남은 기회: 5
문자를 추측하세요: a
틀렸어요! 다시 시도하세요.

현재 단어: ha_gma_
남은 기회: 4
문자를 추측하세요: n
잘 했어요! 맞춘 문자입니다.

축하합니다! 단어를 맞췄습니다: hangman
```



### 1.  문자열 설정

---

```
string secretWord = "hangman";
// 틀릴 수 있는 기회의 수
int attempts = 6;
// 단어를 맞췄는지 여부
bool wordGuessed = false;
```

- 맞춰야 하는 문자열 설정

- 도전 횟수

- 정답여부

  


### 2. 사용자가 숫자를 입력하는 방법

---

```
// 사용자가 맞춘 문자를 저장하는 배열
char[] guessWord = new char[secretWord.Length];
for (int i = 0; i < secretWord.Length; i++)
{
    guessWord[i] = '_';
}
```

- 공백이 문자열로 변경된다.

### 3. 단어 자리 맞추기

---

```
// 사용자가 맞춘 문자를 저장하는 배열
char[] guessWord = new char[secretWord.Length];
for (int i = 0; i < secretWord.Length; i++)
{
    guessWord[i] = '_';
}
while (attempts > 0 && !wordGuessed)
{
    Console.WriteLine("\n현재 단어: " + new string(guessWord));
    Console.WriteLine("남은 기회: " + attempts);
    Console.Write("문자를 추측하세요: ");
    char guess = char.ToLower(Console.ReadKey().KeyChar);
    Console.WriteLine();

    // 입력된 문자가 단어에 포함되는지 확인
    bool letterFound = false;
    for (int i = 0; i < secretWord.Length; i++)
    {
        if (secretWord[i] == guess && guessWord[i] == '_')
        {
            guessWord[i] = guess;
            letterFound = true;
        }
    }

    if (letterFound)
    {
        Console.WriteLine("잘 했어요! 맞춘 문자입니다.");
    }
    else
    {
        attempts--;
        Console.WriteLine("틀렸어요! 다시 시도하세요.");
    }
```

- 현재 단어의 알파벳과 일치하면 도전 횟수의 차감없이
  - 공백이 문자열로 변경된다.

- 틀리면 도전 횟수 차감

### 정답을 입력하여 게임종료

---

```
// 게임 종료 메시지
        if (wordGuessed)
        {
            Console.WriteLine("\n축하합니다! 단어를 맞췄습니다: " + new string(guessWord));
        }
        else
        {
            Console.WriteLine("\n아쉽게도 기회가 모두 사라졌습니다. 정답은: " + secretWord);
        }
```

- 게임 종료 메시지

----

```
using System;

class Hangman
{
    static void Main()
    {
        // 맞춰야 할 단어
        string secretWord = "hangman";

        // 사용자가 맞춘 문자를 저장하는 배열
        char[] guessWord = new char[secretWord.Length];
        for (int i = 0; i < secretWord.Length; i++)
        {
            guessWord[i] = '_';
        }

        // 틀릴 수 있는 기회의 수
        int attempts = 6;

        // 단어를 맞췄는지 여부
        bool wordGuessed = false;

        Console.WriteLine("행맨 게임을 시작합니다!");

        while (attempts > 0 && !wordGuessed)
        {
            Console.WriteLine("\n현재 단어: " + new string(guessWord));
            Console.WriteLine("남은 기회: " + attempts);
            Console.Write("문자를 추측하세요: ");
            char guess = char.ToLower(Console.ReadKey().KeyChar);
            Console.WriteLine();

            // 입력된 문자가 단어에 포함되는지 확인
            bool letterFound = false;
            for (int i = 0; i < secretWord.Length; i++)
            {
                if (secretWord[i] == guess && guessWord[i] == '_')
                {
                    guessWord[i] = guess;
                    letterFound = true;
                }
            }

            if (letterFound)
            {
                Console.WriteLine("잘 했어요! 맞춘 문자입니다.");
            }
            else
            {
                attempts--;
                Console.WriteLine("틀렸어요! 다시 시도하세요.");
            }

            // 단어를 모두 맞췄는지 확인
            wordGuessed = true;
            for (int i = 0; i < secretWord.Length; i++)
            {
                if (guessWord[i] == '_')
                {
                    wordGuessed = false;
                    break;
                }
            }
        }

        // 게임 종료 메시지
        if (wordGuessed)
        {
            Console.WriteLine("\n축하합니다! 단어를 맞췄습니다: " + new string(guessWord));
        }
        else
        {
            Console.WriteLine("\n아쉽게도 기회가 모두 사라졌습니다. 정답은: " + secretWord);
        }
    }
}

```

