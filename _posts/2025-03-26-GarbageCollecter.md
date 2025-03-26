---
layout: single
comments: true
title:  "가비지컬렉터"
excerpt: "코드 학습"
categories: 
- 유니티
- 스파르타
tags:
- TIL
 
toc_label: 개인학습
toc: true
toc_sticky: true
 
date: 2025-03-26
last_modified_at: 2025-03-26
---

### 📆 오늘의 TIL (Today I Learned)

## 가비지 컬렉터(Garbage Collector)란?

가비지 컬렉터(Garbage Collector, GC)는 프로그래밍에서 동적으로 할당된 메모리를 자동으로 관리하는 기능이다. 개발자가 명시적으로 메모리를 해제하지 않아도, 사용되지 않는 객체를 찾아 해제하여 메모리 누수를 방지한다.

### 1. **가비지 컬렉션의 필요성**

- 동적으로 할당된 객체가 더 이상 필요하지 않을 경우, 해당 메모리를 수동으로 해제해야 한다.
- 하지만 사람이 직접 메모리를 관리하면 **메모리 누수(memory leak)**나 **댕글링 포인터(dangling pointer)** 문제가 발생할 수 있다.
- 이를 해결하기 위해 **GC는 필요 없는 객체를 자동으로 정리하여 메모리 관리를 최적화**한다.

### 2. **가비지 컬렉션 동작 방식**

GC는 기본적으로 **더 이상 참조되지 않는 객체**를 찾아서 메모리에서 해제하는 방식으로 동작한다. 주요 방식은 다음과 같다.

#### ① **참조 카운팅(Reference Counting)**

- 객체가 몇 개의 참조를 받고 있는지 추적하는 방식
- 참조 카운트가 0이 되면 자동으로 해제
- 단점: **순환 참조(circular reference) 문제**가 발생할 수 있음

#### ② **마크 앤 스위프(Mark and Sweep)**

- 루트 객체(전역 변수, 스택의 지역 변수 등)에서 도달할 수 있는 객체를 **마킹(marking)**
- 마킹되지 않은 객체를 **스위핑(sweeping, 삭제)**하여 메모리를 정리
- 단점: **일시적인 성능 저하** 발생

#### ③ **카피 컬렉션(Copy Collection)**

- 객체를 두 개의 메모리 영역(예: 새 공간과 오래된 공간)으로 나눠서 관리
- 객체를 한쪽으로 복사하면서 필요 없는 객체를 자연스럽게 제거
- 단점: **메모리 낭비가 발생**할 수 있음

#### ④ **세대별 가비지 컬렉션(Generational GC)**

- 객체의 수명을 기준으로 **Young Generation(신생 객체), Old Generation(오래된 객체)** 등으로 구분
- 신생 객체는 자주 수집하고, 오래된 객체는 적게 수집하여 성능 최적화
- 대표적인 방식: **JVM의 G1 GC, .NET의 GC**

### 3. **언어별 가비지 컬렉션**

| 언어       | GC 사용 여부 | 주요 방식                                      |
| ---------- | ------------ | ---------------------------------------------- |
| Java       | O            | JVM의 G1 GC, ZGC 등                            |
| C#         | O            | .NET GC (세대별 GC)                            |
| Python     | O            | 참조 카운팅 + Mark and Sweep                   |
| JavaScript | O            | V8 엔진의 세대별 GC                            |
| C/C++      | X            | 수동 메모리 관리 (`malloc/free`, `new/delete`) |

### 4. **GC 최적화 방법**

- **불필요한 객체 참조 해제**: 사용이 끝난 객체는 `null` 할당
- **큰 객체의 할당 최소화**: 큰 객체는 Old Generation으로 이동 가능성이 높아 GC 부담 증가
- **WeakReference 활용**: 강한 참조를 피하고, 필요할 때만 객체 유지



📌 **오늘의 키포인트**

- GC는 메모리 자동 관리 시스템으로, 명시적인 `free()` 없이도 동작한다.
- 세대별 GC가 성능 최적화에 많이 사용된다.
- GC를 효율적으로 사용하려면 불필요한 객체 참조를 줄이는 것이 중요하다.



### C#에서 가비지 컬렉션(Garbage Collection) 예시

C#에서는 **.NET의 GC (Garbage Collector)**가 자동으로 메모리를 관리해준다.
 GC는 `System.GC` 클래스를 통해 직접 제어할 수도 있지만, **일반적으로는 명시적으로 호출하지 않는 것이 좋다.**

------

### 1️⃣ **기본적인 GC 동작 예시**

```
using System;

class Program
{
    static void Main()
    {
        CreateObjects();

        // GC 호출 전 메모리 상태 확인
        Console.WriteLine($"메모리 사용량 (GC 호출 전): {GC.GetTotalMemory(false)} bytes");

        // 가비지 컬렉터 강제 실행
        GC.Collect();
        GC.WaitForPendingFinalizers();

        // GC 호출 후 메모리 상태 확인
        Console.WriteLine($"메모리 사용량 (GC 호출 후): {GC.GetTotalMemory(true)} bytes");
    }

    static void CreateObjects()
    {
        for (int i = 0; i < 10000; i++)
        {
            object obj = new object();
        }
    }
}
```

🔹 **설명:**

- `CreateObjects()`에서 10,000개의 `object` 인스턴스를 생성
- 이후 `GC.Collect()`를 호출하여 명시적으로 가비지 컬렉션 실행
- `GC.GetTotalMemory(false/true)`를 통해 메모리 사용량을 비교

**결과:**
 GC가 동작하면 불필요한 객체가 제거되고 메모리 사용량이 감소할 수 있다.

------

### 2️⃣ **Finalize()와 GC 동작 예시**

C#에서는 객체가 제거될 때 `Finalize()` 또는 `IDisposable` 패턴을 사용할 수 있다.

```
using System;

class MyClass
{
    // 소멸자(Finalizer)
    ~MyClass()
    {
        Console.WriteLine("MyClass 객체가 GC에 의해 수거됨!");
    }
}

class Program
{
    static void Main()
    {
        MyClass obj = new MyClass();
        obj = null; // 객체 참조 제거

        GC.Collect(); // GC 강제 실행
        GC.WaitForPendingFinalizers(); // 소멸자 실행 대기

        Console.WriteLine("GC 실행 완료");
    }
}
```

🔹 **설명:**

- `~MyClass()` 소멸자를 정의하여, 객체가 GC에 의해 제거될 때 메시지 출력
- `obj = null;`로 객체 참조를 해제한 후 `GC.Collect()` 실행
- `GC.WaitForPendingFinalizers();`를 사용하여 소멸자가 실행될 때까지 대기

**출력 예시:**

```
MyClass 객체가 GC에 의해 수거됨!
GC 실행 완료
```

⚠️ **주의:**

- `Finalize()`는 명시적으로 호출할 수 없으며, GC가 객체를 제거할 때 실행됨
- **성능 저하 가능성이 있기 때문에 `Dispose()` 패턴을 사용하는 것이 권장됨**

------

### 3️⃣ **IDisposable을 활용한 가비지 컬렉션 관리**

`IDisposable` 인터페이스를 사용하면 `using` 문을 통해 명시적으로 자원을 해제할 수 있다.

```
using System;

class MyResource : IDisposable
{
    public void Use()
    {
        Console.WriteLine("리소스 사용 중...");
    }

    public void Dispose()
    {
        Console.WriteLine("리소스 해제됨!");
        GC.SuppressFinalize(this); // Finalize() 호출 방지
    }
}

class Program
{
    static void Main()
    {
        using (MyResource resource = new MyResource())
        {
            resource.Use();
        } // using 블록이 끝나면 자동으로 Dispose() 호출됨

        Console.WriteLine("GC 실행 전...");
        GC.Collect();
        Console.WriteLine("GC 실행 후...");
    }
}
```

🔹 **설명:**

- `IDisposable`을 구현하고 `Dispose()` 메서드에서 자원을 해제
- `using` 블록을 사용하면 **블록을 벗어날 때 자동으로 `Dispose()` 실행됨**
- `GC.SuppressFinalize(this);`를 호출하면 **GC가 `Finalize()`를 실행하지 않도록 방지**

**출력 예시:**

```
리소스 사용 중...
리소스 해제됨!
GC 실행 전...
GC 실행 후...
```
