---
layout: single
comments: true
title:  "3D 퍼즐 게임"
excerpt: "유니티 개인 프로젝트"
categories: 
- 유니티
- 스파르타
tags:
- TIL
 
toc_label: 3D 퍼즐 요소
toc: true
toc_sticky: true
 
date: 2025-03-12
last_modified_at: 2025-03-12
---



### 📆 오늘의 TIL (Today I Learned)

---

3D 퍼즐 게임의 퍼즐 기믹 중 하나인 잉크 색 맞추기를 구현해 보려고 한다.

`PrintPuzzle` 클래스는 **퍼즐 정답 검증 및 출력 기능을 담당**하며, **특정 위치에 배치된 `Ink`들의 색상을 합산하여 목표 색상과 비교하는 역할**을 한다.

------

### **🔍 주요 기능**

#### **1️⃣ `Update()`**

- `Space` 키를 누르면 `CheckAndPrint()`를 호출하여 정답 여부를 확인함.

#### **2️⃣ `CheckAndPrint()`**

- `IsCorrect()`를 실행하여 현재 `Ink`들의 색상이 목표 색상과 일치하는지 확인.
- 정답이면 `Debug.Log`를 통해 `combinedColor`를 출력.

#### **3️⃣ `FindInk()`**

- `inkPositions` 리스트에 저장된 위치를 기준으로 **해당 위치에 배치된 `Ink`들의 색상을 탐색**.
- `Physics.OverlapSphere()`를 사용하여 **각 위치에 있는 `Ink` 객체를 감지**.
- 감지된 `Ink`의 색상을 모두 합산하여 `combinedColor`를 계산.
- **RGB 값이 0~1 범위를 초과하지 않도록 `Mathf.Clamp01()`으로 정규화**.

#### **4️⃣ `IsCorrect()`**

- `FindInk()`를 먼저 실행하여 `combinedColor`를 업데이트.
- `combinedColor`와 `targetColor`의 차이가 허용 오차(`tolerance = 0.05f`) 이내인지 확인.
- **정답이라면 `PrintPaper()`를 호출하여 종이를 출력**.

#### **5️⃣ `PrintPaper()`**

- `paperPrefab`과 `printPoint`가 존재하면 **종이 프리팹을 해당 위치에 생성**.

------

### **📌 핵심 학습 내용**

✅ **`Physics.OverlapSphere()`를 사용한 충돌 감지**

- 특정 위치 주변의 **충돌체(Collider)를 검색**하여 해당 위치에 `Ink`가 있는지 확인.

✅ **RGB 색상 정규화 및 조합 (`Mathf.Clamp01()`)**

- `combinedColor`를 0~1 범위 내에서 유지하여 **잘못된 색상 오버플로우 방지**.

✅ **오차 허용 범위(`tolerance`)를 활용한 비교 연산**

- `Mathf.Abs()`를 사용하여 두 색상의 **RGB 값 차이가 `tolerance` 이하인지 판별**.

✅ **정답 검증 후 오브젝트 인스턴스화 (`Instantiate()`)**

- **정답일 경우 `paperPrefab`을 `printPoint`에 생성**하여 퍼즐 완료 시 피드백 제공.

------

### **🚀 개선 아이디어**

🔹 `FindInk()` 실행 후 **정답 여부가 변할 때만 `PrintPaper()` 실행**
 → 매번 `PrintPaper()`를 호출하는 것이 아니라 상태 변화 시에만 실행되도록 개선 가능.
 🔹 `Debug.Log` 출력 내용을 **더 직관적인 메시지로 변경**
 → `Debug.Log($"Correct! Printed Paper with Color: {combinedColor}")`

------

### **📌 결론**

`PrintPuzzle` 클래스는 **퍼즐 색상 조합 로직을 체계적으로 구현**하며, `Physics.OverlapSphere()`를 활용해 `Ink` 객체를 감지하고 색상을 조합하여 목표 색상과 비교하는 구조를 갖고 있다. 🎯

스페이스바를 눌러 정답을 확인하면 , 종이를 해당위치에 생성한다.
