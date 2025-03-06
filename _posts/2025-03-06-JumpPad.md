---
layout: single
comments: true
title: " 델리게이터 "
categories: TIL
---





### 📆 오늘의 TIL (Today I Learned)

---

델리게이트(Delegate)는 **C#에서 메서드를 참조하는 포인터(참조 타입) 역할**을 하는 객체
즉, **메서드를 변수처럼 저장하고 나중에 실행할 수 있는 기능**을 제공
이 기능을 활용하면 **코드를 유연하게 설계하고, 이벤트 처리, 콜백 함수, 디자인 패턴 등에 유용하게 사용 할 수 있다**

------

## ✅ **델리게이트의 주요 특징**

1️⃣ **메서드를 변수처럼 저장하고 호출할 수 있음**
2️⃣ **여러 개의 메서드를 연결하여 한 번에 실행 가능 (멀티캐스트 델리게이트)**
3️⃣ **이벤트(Event)와 함께 사용되어 동적 실행 가능**
4️⃣ **익명 함수, 람다식과 함께 사용 가능**

------

## 📌 **1. 기본적인 델리게이트 사용법**

```
using System;

public class Program
{
    // 델리게이트 선언 (반환 타입과 매개변수가 일치해야 함)
    delegate void MyDelegate(string message);

    // 델리게이트가 참조할 메서드
    static void PrintMessage(string msg)
    {
        Console.WriteLine("Message: " + msg);
    }

    public static void Main()
    {
        // 델리게이트 인스턴스 생성 (메서드 참조)
        MyDelegate del = PrintMessage;

        // 델리게이트 호출 (메서드 실행)
        del("Hello, Delegate!");
    }
}
```

### 🔹 **실행 결과**

```
vbnet


복사편집
Message: Hello, Delegate!
```

------

## 📌 **2. 멀티캐스트 델리게이트**

- **여러 개의 메서드를 델리게이트에 등록하여 한 번에 실행 가능**

```
using System;

public class Program
{
    delegate void MyDelegate(string message);

    static void Method1(string msg) => Console.WriteLine("Method1: " + msg);
    static void Method2(string msg) => Console.WriteLine("Method2: " + msg);

    public static void Main()
    {
        MyDelegate del = Method1;
        del += Method2;  // 두 번째 메서드 추가

        del("Hello"); // 두 개의 메서드가 실행됨
    }
}
```

### 🔹 **실행 결과**

```
Method1: Hello
Method2: Hello
```

------

## 📌 **3. 델리게이트와 익명 메서드**

- **이름 없는 익명 함수를 델리게이트에 직접 할당 가능**

```
using System;

public class Program
{
    delegate void MyDelegate(string message);

    public static void Main()
    {
        MyDelegate del = delegate (string msg) 
        {
            Console.WriteLine("Anonymous: " + msg);
        };

        del("Hello");
    }
}
```

### 🔹 **실행 결과**

```
makefile


복사편집
Anonymous: Hello
```

------

## 📌 **4. 델리게이트와 람다식 (Lambda)**

- **람다식을 사용하여 코드 간결화 가능**

```
using System;

public class Program
{
    delegate int MathOperation(int a, int b);

    public static void Main()
    {
        MathOperation add = (a, b) => a + b;  // 람다식 사용
        Console.WriteLine(add(10, 5));  // 결과: 15
    }
}
```

### 🔹 **실행 결과**

```

15
```

------

## 📌 **5. 델리게이트와 이벤트(Event)**

- **이벤트 시스템과 함께 사용하면 특정 조건에서 실행할 수 있음**

```
using System;

public class EventExample
{
    public delegate void Notify(); // 이벤트용 델리게이트 선언
    public event Notify OnProcessCompleted; // 이벤트 선언

    public void Process()
    {
        Console.WriteLine("Processing...");
        OnProcessCompleted?.Invoke(); // 이벤트 실행
    }
}

class Program
{
    static void Main()
    {
        EventExample obj = new EventExample();
        obj.OnProcessCompleted += () => Console.WriteLine("Process Completed!");
        
        obj.Process();
    }
}
```

### 🔹 **실행 결과**

```
Processing...
Process Completed!
```

------

## 🎯 **델리게이트를 사용하면 좋은 경우**

1️⃣ **콜백 함수 (Callback Function)**

- 어떤 작업이 끝났을 때 특정 함수를 실행할 필요가 있을 때.
- 예: 비동기 작업 후 결과를 처리하는 함수 전달.

2️⃣ **이벤트 기반 프로그래밍**

- UI 버튼 클릭, 플레이어가 몬스터를 죽였을 때 보상 지급 등.

3️⃣ **전략 패턴(Strategy Pattern)**

- 게임에서 공격 방식(근접, 원거리, 마법)을 유동적으로 변경할 때.

4️⃣ **멀티캐스트 기능을 활용한 효과 처리**

- 한 이벤트에서 여러 개의 동작을 동시에 실행할 때.

### **Unity에서 활용 예시**

**👾 예: UI 버튼 클릭 이벤트 처리**

```
using UnityEngine;
using UnityEngine.UI;

public class ButtonClickHandler : MonoBehaviour
{
    public Button myButton;

    void Start()
    {
        myButton.onClick.AddListener(() => Debug.Log("Button Clicked!"));
    }
}
```

**👾 예: 델리게이트를 활용한 공격 방식 변경**

```
using system;
using UnityEngine;

public class PlayerAttack : MonoBehaviour
{
    public delegate void AttackDelegate();
    public AttackDelegate currentAttack;

    void Start()
    {
        currentAttack = MeleeAttack; // 초기 공격 방식
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            currentAttack?.Invoke();
        }
    }

    void MeleeAttack()
    {
        Debug.Log("근접 공격!");
    }

    void RangedAttack()
    {
        Debug.Log("원거리 공격!");
    }

    public void ChangeAttack()
    {
        currentAttack = RangedAttack;
    }
}
```

🎯 **스페이스바를 누르면 `MeleeAttack()` 실행 → `ChangeAttack()` 호출 후 원거리 공격으로 변경**

------

### 💡 **🔥 핵심 정리**

- **델리게이트는 메서드를 참조하는 타입으로, 메서드를 변수처럼 저장하고 실행 가능**
- **이벤트와 결합하여 UI, 콜백 처리, 전략 패턴 등에 유용하게 사용**
- **Unity에서도 버튼 클릭, 플레이어 행동 처리 등에 활용 가능**
