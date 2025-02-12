---
layout: single
comments: true
title: "While문과 break "
categories: TIL
---





### 📆 오늘의 TIL (Today I Learned)

---

## While

- break; 는 switch문 뿐만 아니라 다양하게 사용가능하다.
- While문에서 또한 사용 할 수 있으며 해당 루프를 빠져나가는데 쓰인다.
- While(true)>> 진행 조건이 참인경우 무한루프를 하게되는데 
- While문의 마지막에 break;를 사용해서 루프를 종료 할 수있다.
- if문 또는 Switch case 문에서도 사용 할 수있으며
- 계속 진행하기를 원한다면 continue, 반환값을 요구하면 return 해당 루프를 종료하고 싶다면 break등
- 상황에 맞는 연출이 필요하다. 




### **1. 진입점 ***

---

- While 문과 if문 그리고 스위치 문을 사용할때는 항상 진입점이 중요하다.

- 여러개의 Whil문을 사용한다면 절대 헷갈리지 않도록 코드가 어떻게 진행되어야 하는지 알아야한다.

- ```
  while (a < 10)
  {
      Console.WriteLine(a);
  }
  ```

  

이런식으로 무한루프에 빠지게 되면 탈출 할 수 없으니 마지막에 break;를 잊지말자..

### **1. 단일 진입점(Single Entry Point)**

- 프로그램이나 함수가 실행될 때, 진입할 수 있는 지점이 단 하나만 존재하는 것.
- 일반적으로 함수는 한 곳에서만 호출되도록 설계됨.
- `Main()` 함수가 프로그램의 단일 진입점이 되는 대표적인 예시.

```
class Program
{
    static void Main()
    {
        StartGame(); // 단 하나의 진입점(Main)에서 실행 시작
    }

    static void StartGame()
    {
        Console.WriteLine("게임 시작!");
    }
}

```

`Main()` 함수가 유일한 진입점이다.

프로그램 실행이 시작되면 `Main()` 함수에서 흐름이 시작된다.

### **2. 단일 종료점(Single Exit Point)**

- 함수 또는 프로그램이 종료되는 지점이 단 하나만 존재하는 것.
- 여러 개의 `return` 문을 사용하면 코드의 흐름이 복잡해질 수 있으므로, 단일 `return`을 유지하는 것이 좋다.
- -> 이 문제로 4시간을 머리를 붙잡고 있었다... 

#### **잘못된 예시 (Multiple Exit Points)**

```
csharp복사편집int GetNumber(string input)
{
    if (input == "one") return 1;
    if (input == "two") return 2;
    return 0; // 여러 개의 종료 지점이 있음
}
```

- 여러 개의 `return` 문이 있어서 코드 흐름을 이해하기 어려움.

#### **좋은 예시 (Single Exit Point)**

```
csharp복사편집int GetNumber(string input)
{
    int result = 0;
    if (input == "one") result = 1;
    else if (input == "two") result = 2;
    return result; // 단일 종료 지점
}
```

- `return` 문이 하나만 있어서 코드 가독성이 좋아짐.

------

### **3. 단일 진입점과 단일 종료점이 중요한 이유**

✅ **가독성 향상**: 코드의 흐름을 쉽게 이해할 수 있음.
✅ **유지보수 용이**: 함수의 종료 지점이 하나라서 디버깅이 쉬움.
✅ **예외 처리 간편화**: 예외(Exception) 처리가 일관되게 가능함.

------

### **4. 예외 처리와 함께 단일 종료점 유지**

```
csharp복사편집int Divide(int a, int b)
{
    if (b == 0) 
    {
        throw new DivideByZeroException("0으로 나눌 수 없습니다.");
    }

    return a / b; // 단일 종료점 유지
}
```

- 예외(Exception)를 사용하면 조건에 따라 함수를 종료하는 것이 아니라, 예외적인 상황을 처리하면서 흐름을 유지할 수 있음.

------

### **결론**

- **단일 진입점**: 프로그램이나 함수는 한 곳에서만 실행을 시작해야 함.
- **단일 종료점**: 함수가 한 곳에서만 종료되도록 설계해야 가독성과 유지보수가 용이함.
- **예외 상황을 처리할 때도 단일 종료점을 유지하는 것이 좋음**.
