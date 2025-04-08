---
layout: single
comments: true
title:  "애니메이션 파라미터 트러블 슈팅"
excerpt: "코드 학습"
categories: 
- 유니티
- 스파르타
tags:
- TIL
 
toc_label: 팀프로젝트
toc: true
toc_sticky: true
 
date: 2025-04-08
last_modified_at: 2025-04-08
---

### 📆 오늘의 TIL (Today I Learned)

# Unity 애니메이터 파라미터 오류 트러블슈팅

## 문제 상황

Unity 프로젝트에서 다음과 같은 오류가 발생했다.

```
복사Parameter 'IsFalling' does not exist.
UnityEngine.Animator:SetBool (string,bool)
PlayerController:UpdateAnimations (PlayerStateType) (at Assets/03_Scripts/Player/Player.cs:426)
```

이 오류는 모든 애니메이션에서 동일하게 발생했다.

## 원인 분석

코드를 분석한 결과 다음과 같은 문제를 발견 할 수 있었다.

1. ```
   PlayerController
   ```

    클래스에 여러 버전의 

   ```
   UpdateAnimations()
   ```

    메서드가 오버로드되어 있었고

   - `UpdateAnimations()` (파라미터 없는 버전)
   - `UpdateAnimations(string stateType)`
   - `UpdateAnimations(PlayerStateType stateType)`

2. ```
   PlayerStateType
   ```

    매개변수를 받는 메서드에서 로직 오류를 찾을 수 있었다.

   ```
   if (stateType == null) // enum은 null이 될 수 없음
   {
       animator.SetTrigger(stateType.ToString()); // null일 경우 NullReferenceException 발생
   }
   ```

3. `UpdateAnimations()` 메서드들 중 어딘가에서 `animator.SetBool("IsFalling", ...)` 코드를 실행하고 있지만, 애니메이터에는 해당 파라미터가 정의되어 있지 않았던 것이 문제였다.

## 해결 방법

1. 애니메이터에 필요한 파라미터 추가

   - Unity 에디터에서 애니메이터 컨트롤러를 열기
   - Parameters 탭에서 + 버튼 클릭
   - "IsFalling" 이름의 Bool 타입 파라미터 추가

2. 코드 수정

   - `UpdateAnimations(PlayerStateType stateType)` 메서드의 로직 오류 수정:

   ```
   public void UpdateAnimations(PlayerStateType stateType)
   {
       if (animator != null)
       {
           // 기본 파라미터 설정 
           animator.SetFloat("Speed", Mathf.Abs(rb.velocity.x));
           animator.SetBool("IsSprinting", isSprinting);
           animator.SetFloat("VerticalVelocity", rb.velocity.y);
           animator.SetBool("IsGrounded", IsGrounded());
           animator.SetBool("IsWallSliding", isWallSliding);
           animator.SetBool("IsDashing", isDashing);
           
           // enum은 null이 될 수 없으므로 조건 제거
           animator.SetTrigger(stateType.ToString());
       }
   }
   ```

3. 일관된 네이밍 규칙 적용

   - 상태 이름이 "Falling"인 경우 애니메이터 파라미터 이름도 "Falling"으로 통일
   - 또는 애니메이터 파라미터가 "IsFalling"이라면 코드에서도 동일하게 사용

## 결론

1. 애니메이터 파라미터와 코드 동기화
   - 코드에서 참조하는 모든 애니메이터 파라미터가 실제 애니메이터에 정의되어 있는지 항상 확인해야 한다.
   - 파라미터를 추가하거나 변경할 때는 코드와 애니메이터 설정을 함께 수정해야 한다.
2. 타입 안전성 확보
   - enum 타입은 null이 될 수 없으므로 null 체크는 불필요하다.
   - 잘못된 null 체크는 로직 오류를 일으키고 예상치 못한 동작을 유발할 수 있었다.
3. 스택 트레이스 활용
   - 오류 메시지의 스택 트레이스는 문제가 발생한 정확한 위치를 찾는 데 매우 중요한 정보가 될 수 있다.
   - 메서드 호출 순서를 따라가며 문제 원인을 추적(디버깅) 할  수 있다.
4. 메서드 오버로드 주의
   - 여러 버전의 오버로드된 메서드가 있을 경우, 각 메서드의 역할과 동작을 명확히 구분해야 한다.
   - 비슷한 기능을 하는 여러 메서드가 있을 때 일관된 방식으로 작동하도록 해야 한다.

---

3D 프로젝트의 경험을 토대로 블렌더 트리를 사용한 부드러운 애니메이션 전환을 하고싶어 코드를 지금과 같이 설계하였는데, 상태가 많은 2d 플랫포머 게임에서는 애니메이션 전환보다, 상태를 확실하게 구분지을 수있는 bool 값이 어울릴 거 같다는 생각이 들었다. 해당 오류와 마주하면서 기존의 float 값을 통해 애니메이션을 전환하고 있던 부분을 전부 bool 로 바꾸고 상태에 따른 bool 값만을 호출하여 전환하니 자연스럽게 만들 수 있었다. 기존보다 더욱 부드럽게 전환되는 느낌이라 만족스러운 결과를 낼 수 있었다.

리팩토링을 진행하며 기존에 안되던 벽슬라이딩 문제도 해결했는데, 점프값과 이동값의 영향으로 벽에 붙어있지만 고정은 되지 않던게 원인이었다.

