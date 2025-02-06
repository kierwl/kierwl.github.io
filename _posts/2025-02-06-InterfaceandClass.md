---
layout: single
comments: true
title: "인터페이스와 클래스 "
categories: TIL
---





### 📆 오늘의 TIL (Today I Learned)

---

## 인터페이스와 클래스

- 인터페이스란 무엇이고 왜 사용하는가?
- 클래스의 프로퍼티를 지정하는것과 뭐가 다른가?
  - 인터페이스에 프로퍼티를 추가하면 **모든 구현 클래스가 특정 데이터를 반드시 가져야 한다는 규칙을 만들 수 있음**

- 인터페이스의 한계
  - A 와 B 인터페이스를 만들었지만 A와 B를 포함하는 새로운 메서드를 필요로 할때
  - 새로운 클래스로 만들어 A와 B를 상속받으면 된다.






### **1. 인터페이스**

---

- 인터페이스는 **클래스나 구조체가 구현해야 할 메서드 ,속성 등을 정의한 틀**
  - ~한 기능을 가져야 한다 를 강제하는 역할

- 인터페이스의 특징
  - 다중 상속 가능
  - 메서드, 속성 , 인덱서, 이벤트만 선언 가능(필드x)
  - 인스턴스를 만들 수 없음
  - 모든 메서드는 자동으로public 상태이므로 (명시적으로 public을 붙이지 않아도 된다.)


```
// 인터페이스 정의
interface IEnemy
{
    void Attack();   // 공격 메서드 (선언만, 구현 없음)
    void GetDamage(); // 피해를 받을 때 실행할 메서드
}

// 인터페이스 구현 (Enemy 클래스)
class Enemy : IEnemy
{
    public void Attack()
    {
        Console.WriteLine("적이 공격합니다!");
    }

    public void GetDamage()
    {
        Console.WriteLine("적이 피해를 입었습니다!");
    }
}

class Program
{
    static void Main()
    {
        IEnemy enemy = new Enemy(); // IEnemy 타입으로 객체 생성 가능 (다형성)
        enemy.Attack();
        enemy.GetDamage();
    }
}

```

`IEnemy` 인터페이스는 `Attack()`과 `GetDamage()` 메서드를 정의

`Enemy` 클래스가 `IEnemy`를 **구현**하면서 `Attack()`과 `GetDamage()`의 실제 내용을 작성

`IEnemy` 타입의 객체로 `Enemy`를 생성하면, **다형성(Polymorphism)** 을 활용가능하다.



### 2.인터페이스와 추상 클래스의 차이점

---

| 비교 항목       | 인터페이스 (Interface)              | 추상 클래스 (Abstract Class) |
| --------------- | ----------------------------------- | ---------------------------- |
| 목적            | 기능(규칙) 정의                     | 공통된 동작 및 기능 제공     |
| 상속 방식       | 다중 구현 가능                      | 단일 상속만 가능             |
| 구현 여부       | 모든 메서드는 구현 없이 선언만 가능 | 일부 또는 전체 구현 가능     |
| 필드(변수) 사용 | 불가능                              | 가능                         |
| 접근 제한자     | 모든 멤버가 기본적으로 public       | private, protected 사용 가능 |

##### 인터페이스 예제

```
interface ICharacter
{
    void Move();
}

class Player : ICharacter
{
    public void Move()
    {
        Console.WriteLine("플레이어가 이동합니다.");
    }
}

```

##### 추상 클래스 예제

```
abstract class Character
{
    public abstract void Move();  // 추상 메서드 (자식이 반드시 구현해야 함)

    public void Speak()           // 일반 메서드 (공통 기능)
    {
        Console.WriteLine("대화 중...");
    }
}

class Player : Character
{
    public override void Move()
    {
        Console.WriteLine("플레이어가 이동합니다.");
    }
}

```

**핵심 차이점:**

- `ICharacter`(인터페이스)에는 `Move()` 메서드의 **구현이 없음**
- `Character`(추상 클래스)에는 `Move()`는 반드시 구현해야 하지만, `Speak()` 같은 일반 메서드를 포함할 수 있음

### 3.인터페이스의 활용 예제

---

##### 다형성을 이용한 인터페이스 활용

```
interface IAttackable
{
    void Attack();
}

class Warrior : IAttackable
{
    public void Attack()
    {
        Console.WriteLine("전사가 검을 휘두릅니다!");
    }
}

class Mage : IAttackable
{
    public void Attack()
    {
        Console.WriteLine("마법사가 불ball을 던집니다!");
    }
}

class Program
{
    static void Main()
    {
        List<IAttackable> characters = new List<IAttackable>
        {
            new Warrior(),
            new Mage()
        };

        foreach (var character in characters)
        {
            character.Attack();  // 다형성 활용
        }
    }
}

```

##### 결과

```
전사가 검을 휘두릅니다!
마법사가 불ball을 던집니다!

```

**인터페이스를 활용하면, 서로 다른 클래스(Warrior, Mage)도 같은 `Attack()` 메서드를 호출할 수 있음**



### **4. 인터페이스를 사용하는 이유**

---



1. **코드의 일관성을 유지할 수 있음**
   - 같은 인터페이스를 구현하면 메서드명이 동일해져, 여러 클래스에서도 일관된 동작을 유지 가능
2. **다형성을 활용할 수 있음**
   - 인터페이스를 구현한 여러 객체를 `List<인터페이스>`에 담아서 같은 방식으로 처리 가능
3. **유지보수성과 확장성이 뛰어남**
   - 새로운 클래스가 추가되더라도 기존 코드 변경 없이 쉽게 확장 가능

