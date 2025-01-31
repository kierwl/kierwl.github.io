---
layout: single
comments: true
title: "스네이크 게임 "
categories: TIL
---





### 📆 오늘의 TIL (Today I Learned)

---

## 스네이크 게임 개발 과정

정수 `num1`과 `num2`가 매개변수로 주어질 때, `num1`을 `num2`로 나눈 값에 1,000을 곱한 후 정수 부분을 return 하도록 soltuion 함수를 완성할것



입출력 예 #1

- `num1`이 3, `num2`가 2이므로 3 / 2 = 1.5에 1,000을 곱하면 1500

입출력 예 #2

- `num1`이 7, `num2`가 3이므로 7 / 3 = 2.33333...에 1,000을 곱하면 2333.3333.... 이 되며, 정수 부분은 2333

입출력 예 #3

- `num1`이 1, `num2`가 16이므로 1 / 16 = 0.0625에 1,000을 곱하면 62.5가 되며, 정수 부분은 62

```
using System;

public class Solution {
    public float solution(float num1, float num2) {
        float answer = 0;
        answer = (int)((float)num1 / num2 * 1000);
        return answer;
    }
}
```

