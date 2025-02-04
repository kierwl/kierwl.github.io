---
layout: single
comments: true
title: "스네이크 게임 "
categories: TIL
---





### 📆 오늘의 TIL (Today I Learned)

---

## 스네이크 게임 개발 과정

- 뱀이 과일을 몇개 먹지 않았음에도 튕기는 문제 발생

```
public Point CreateFood()
{
    Random rand = new Random();  // 매번 새로운 Random 객체 생성
    int x = rand.Next(0, width);
    int y = rand.Next(0, height);
    return new Point(x, y, symbol);
}
```

랜덤객체가 여러번 생성되어 같은 값의 반복이 일어 날 수 있음

즉 음식과, 뱀의 몸통이 겹침

뱀이 음식을 먹자마자 몸통위치에 음식이 생겨 충돌판정이 된것



```
public class FoodCreator
{
    private int width;
    private int height;
    private char symbol;
    private Random rand; // Random 객체를 한 번만 생성

    public FoodCreator(int width, int height, char symbol)
    {
        this.width = width;
        this.height = height;
        this.symbol = symbol;
        this.rand = new Random(); // Random 객체를 한 번만 생성
    }

    public Point CreateFood()
    {
        int x = rand.Next(0, width);
        int y = rand.Next(0, height);
        return new Point(x, y, symbol);
    }
}

```

이렇게 수정해 주니 오류는 해결되었다.



그외 다양한 방법

| **1. `Random` 객체를 매번 생성** | 같은 난수 값이 반복되어 음식이 같은 위치에 생성됨 | `Random` 객체를 한 번만 생성하여 재사용 |
| -------------------------------- | ------------------------------------------------- | --------------------------------------- |
|                                  |                                                   |                                         |

| **2. 음식이 뱀의 몸에 생성됨** | 뱀의 몸에 음식이 생성되면서 충돌 판정이 잘못됨 | 음식 생성 시, 뱀의 몸과 겹치는지 검사 |
| ------------------------------ | ---------------------------------------------- | ------------------------------------- |
|                                |                                                |                                       |

| **3. 잘못된 꼬리 추가 방식** | 뱀의 방향에 따라 꼬리의 위치가 잘못 추가될 가능성 | 꼬리를 현재 방향에 맞게  추가 |
| ---------------------------- | ------------------------------------------------- | ----------------------------- |
|                              |                                                   |                               |
