---
layout: single
comments: true
title:  "2d 넉백기능 구현"
excerpt: "코드 학습"
categories: 
- 유니티
- 스파르타
tags:
- TIL
 
toc_label: 팀프로젝트
toc: true
toc_sticky: true
 
date: 2025-03-28
last_modified_at: 2025-03-28
---

### 📆 오늘의 TIL (Today I Learned)

# Unity 2D 넉백 시스템 구현

오늘 Unity 2D 게임에서 대상을 지정하는 넉백 시스템을 구현해 보았다. 처음에는 반경 내 모든 적에게 영향을 주는 전역 넉백 스킬로 시작했지만, 이후 더 제어된 움직임으로 단일 대상에 집중하도록 개선했다.

목표는 격자 칸만큼 움직이도록 하는 것이 최종 목표이다.

## 주요 학습 내용

### 대상 선택

- 초기에는 `Physics2D.OverlapCircleAll()`을 사용하여 적을 감지하고 범위 내 모든 적에게 넉백을 적용했다
- `FindClosestEnemy()` 메서드를 구현하여 플레이어에게 가장 가까운 적을 계산하는 단일 대상 접근 방식으로 전환했다
- 이 접근법은 광역 효과(AOE) 능력보다 집중적인 효과를 원하는 정밀한 게임플레이에 더 적합하다

### 물리 기반 vs. 직접 이동

- 처음에는 물리 기반 넉백 효과를 만들기 위해 

  ```
  AddForce()
  ```

  를 사용했다:

  ```csharp
  enemyRb.AddForce(knockbackDirection * actualForce, ForceMode2D.Impulse);
  ```

- 이 접근법은 물리적 상호작용에 따라 예측할 수 없는 결과를 보였다

- 어떤적이든 물리적인 힘이 계속 가해지게 되어 우측으로 조금씩 움직이는 현상이 생겼다.

- 그래서 직접적인 위치 조작이 더 일관된 결과를 제공한다는 것을 알게되었다:

  ```csharp
  Vector2 newPosition = enemyRb.position + new Vector2(moveDistance, 0f);enemyRb.position = newPosition;
  ```

### 방향 제어

- 처음에는 플레이어에서 적으로의 방향 벡터를 계산했다:

  ```csharp
  Vector2 knockbackDirection = ((Vector2)enemy.transform.position - (Vector2)owner.transform.position).normalized;
  ```

- 이렇게 하면 방향상관없이 힘이 가해지기에 우측에서 적이 오기때문에 변경하게 되었다.

- 이후 `Mathf.Sign()`을 사용하여 좌/우 방향을 결정하는 X축 전용 넉백으로 발전했다

- 마지막으로 일관된 게임 메카닉을 위해 고정 방향(항상 오른쪽) 넉백을 구현했다

### 다양한 적 유형 처리

- Rigidbody2D 컴포넌트가 있는 적과 없는 적 모두 처리하는 방법을 배웠다:

  ```csharp
  if (enemyRb != null) {    // Rigidbody2D 처리} else {    // Transform 직접 조작}
  ```

- 이렇게 하면 넉백 시스템이 모든 유형의 게임 오브젝트에서 작동한다

## 실용적인 교훈

1. **예측 가능성 vs. 현실성**: 물리 기반 이동(AddForce 사용)은 더 현실적인 상호작용을 만들지만, 직접적인 위치 변경은 더 예측 가능한 게임플레이를 제공한다
2. **레이어 마스킹**: `Physics2D.OverlapCircleAll()`을 사용할 때는 올바른 게임 오브젝트를 감지하기 위해 적절한 레이어 마스크를 설정하는 것이 중요하다
3. **엣지 케이스 처리**: null 컴포넌트를 확인하고 대체 구현을 제공하여 방어적으로 코딩하는 것이 중요하다
4. **물리 디버깅**: Unity의 물리 시스템은 디버깅이 어려울 수 있다 - Gizmos로 시각적 반경 표시기를 추가하고 콜라이더 감지를 로깅하면 문제를 진단하는 데 도움이 될 수 있다
5. **성능 고려 사항**: 범위 내의 모든 적에게 영향을 주는 것보다 대상을 지정하는 접근 방식이 많은 엔티티가 있는 장면에서 성능에 더 좋을 수 있다

이러한 구현 과정은 기본 메커니즘이 어떻게 더 예측 가능하고 게임플레이에 적합한 효과를 만들기 위해 개선될 수 있는지 보여준다.
