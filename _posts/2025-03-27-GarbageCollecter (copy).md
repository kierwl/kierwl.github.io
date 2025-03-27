---
layout: single
comments: true
title:  "애니메이션 컨트롤러와 상태머신"
excerpt: "코드 학습"
categories: 
- 유니티
- 스파르타
tags:
- TIL
 
toc_label: 개인학습
toc: true
toc_sticky: true
 
date: 2025-03-27
last_modified_at: 2025-03-27
---

### 📆 오늘의 TIL (Today I Learned)



## 애니메이션 컨트롤러의 주요 구성요소

1. **상태(State)**: 각각의 애니메이션 클립을 나타냅니다. 예를 들어 '대기', '걷기', '뛰기' 등의 상태가 있을 수 있습니다.
2. **전이(Transition)**: 한 상태에서 다른 상태로 전환하는 조건을 정의합니다.
3. **파라미터(Parameter)**: 전이 조건을 제어하는 변수입니다. float, int, bool, trigger 타입이 있습니다.
4. **레이어(Layer)**: 여러 애니메이션을 동시에 재생할 수 있게 해주는 기능입니다. 예를 들어 상체와 하체의 애니메이션을 분리할 수 있습니다.
5. **블렌드 트리(Blend Tree)**: 여러 애니메이션을 부드럽게 혼합할 수 있는 도구입니다.

## 스테이트 머신의 작동 방식

애니메이션 컨트롤러의 스테이트 머신은 다음과 같은 방식으로 작동합니다:

1. 항상 하나의 상태가 현재 활성화된 상태입니다.
2. 활성화된 상태의 애니메이션이 재생됩니다.
3. 파라미터 값에 따라 전이 조건이 충족되면 다른 상태로 전환됩니다.
4. 새 상태의 애니메이션이 재생되기 시작합니다.

## 코드에서의 제어

스크립트에서 애니메이션 컨트롤러를 제어하는 방법은 다음과 같습니다:

```
// Animator 컴포넌트 참조
Animator animator = GetComponent<Animator>();

// 파라미터 설정
animator.SetBool("isRunning", true);
animator.SetFloat("Speed", 5.0f);
animator.SetInteger("WeaponType", 1);
animator.SetTrigger("Jump");

// 현재 상태 정보 얻기
AnimatorStateInfo stateInfo = animator.GetCurrentAnimatorStateInfo(0); // 0은 레이어 인덱스
bool isRunning = stateInfo.IsName("Run");
```



투사체 애니메이션을 공격모션에 맞게 발사 시키려고 한다.

## 1. 애니메이션 이벤트 활용하기

공격 애니메이션에 특정 시점에 투사체를 생성하고 발사하는 이벤트를 추가하는 것으로 적절한 타이밍에 투사체를 발사 시킬 수 이싿.

1. Unity 애니메이션 창에서 공격 애니메이션을 엽니다.
2. 투사체가 발사되어야 하는 정확한 프레임에 애니메이션 이벤트를 추가합니다.
3. 이벤트 함수명을 설정합니다(예: "FireProjectile").
4. 캐릭터 스크립트에 해당 함수를 구현합니다:

```
csharp복사public GameObject projectilePrefab;
public Transform firePoint;

// 애니메이션 이벤트에서 호출됨
public void FireProjectile()
{
    GameObject projectile = Instantiate(projectilePrefab, firePoint.position, firePoint.rotation);
    Rigidbody rb = projectile.GetComponent<Rigidbody>();
    rb.velocity = firePoint.forward * projectileSpeed;
}
```

## 2. 소켓 시스템 사용하기

캐릭터 모델의 특정 부위(손, 무기 끝 등)에 빈 게임 오브젝트(소켓)를 자식으로 추가하고, 이 소켓의 위치에서 투사체를 발사합니다.

```
public Transform weaponSocket;
public GameObject projectilePrefab;
private bool isFiring = false;

void Update()
{
    // 공격 애니메이션 도중 특정 조건이 만족되면 투사체 발사
    if (animator.GetCurrentAnimatorStateInfo(0).IsName("Attack") && 
        animator.GetCurrentAnimatorStateInfo(0).normalizedTime >= 0.5f && 
        !isFiring)
    {
        FireProjectile();
        isFiring = true;
    }
    
    // 애니메이션이 끝나면 발사 상태 초기화
    if (!animator.GetCurrentAnimatorStateInfo(0).IsName("Attack"))
    {
        isFiring = false;
    }
}

void FireProjectile()
{
    GameObject projectile = Instantiate(projectilePrefab, weaponSocket.position, weaponSocket.rotation);
    // 투사체 설정...
}
```

## 3. 트레일 렌더러를 이용한 시각적 효과

투사체의 경로를 시각화하거나 투사체 자체를 표현할 때 트레일 렌더러를 사용할 수 있습니다.

```
csharp복사void SetupProjectileVisual(GameObject projectile)
{
    TrailRenderer trail = projectile.AddComponent<TrailRenderer>();
    trail.startWidth = 0.1f;
    trail.endWidth = 0.0f;
    trail.time = 0.5f; // 트레일이 남아있는 시간
    // 트레일 머티리얼 설정...
}
```

## 4. IK(Inverse Kinematics)를 활용한 정교한 조절

더 복잡한 경우, IK를 사용하여 캐릭터의 손이나 무기가 투사체의 발사 방향을 정확히 가리키도록 할 수 있습니다.

```
csharp복사public Transform target;

private void OnAnimatorIK(int layerIndex)
{
    // 오른손의 IK 설정
    animator.SetIKPositionWeight(AvatarIKGoal.RightHand, 1f);
    animator.SetIKPosition(AvatarIKGoal.RightHand, target.position);
    
    // 오른손의 회전도 설정 가능
    animator.SetIKRotationWeight(AvatarIKGoal.RightHand, 1f);
    animator.SetIKRotation(AvatarIKGoal.RightHand, target.rotation);
}
```

## 5. 파티클 시스템 활용

투사체를 파티클 시스템으로 구현하여 애니메이션과 동기화할 수도 있습니다.

```
csharp복사public ParticleSystem projectileParticleSystem;

public void TriggerProjectileEffect()
{
    projectileParticleSystem.Play();
}
```

이중 가장 쉽고 효과적인 방법은 애니메이션 프레임에 이벤트로 함수를 호출 하는 것 이었다.

```
 // 애니메이션 이벤트 수신 메서드
 public void OnAttackAnimationEventReceived()
 {
     if (currentTarget != null) // 타겟이 있을 때만 발사
     {
         FireProjectile();
     }
 }
```

를 사용하여 애니메이션이 있는 스크립트에 연결해주면, 애니메이션이 동작 할때마다 특정 프레임에서 이벤트가 호출되게 된다.
