---
layout: post
comments: true
title: 무기 속성 시스템 부식 속성 구현하기
excerpt: 코드 학습
categories: 유니티,스파르타
tags:
  - TIL
toc_label: 팀프로젝트
toc: true
toc_sticky: true
date: 2025-05-07
last_modified_at: 2025-05-07
---

### 📆 오늘의 TIL (Today I Learned)
# 부식(산성) 효과 구현하기

오늘은 Unity에서 적에게 부식 효과를 어떻게 구현할 것인지 생각해 보았다. 일단 산성은 물체를 녹이는 느낌이 들고, 부식또한 물체를 점점 못쓰게 만드는 느낌이 들어 비슷하다고 생각했고 이를 엔티티한테 적용하기 위해 능력의 구현이 우선적으로 필요하다고 생각했다.

부식은 적을 약화시키는 기능이고
현재 구현된 기능만 적용시키자면 공격력 감소와 이동속도 감소정도가 될 것이다.

## 1. 부식식 총알 구현

```csharp
public class RustBullet : Bullet
{
    [SerializeField] private float rustDebuffDuration = 5f;     // 디버프 지속 시간
    [SerializeField] private float speedReductionPercent = 30f; // 속도 감소 비율 (%)
    [SerializeField] private float damageOverTimeAmount = 2f;   // 시간당 추가 데미지
    [SerializeField] private GameObject acidEffectPrefab;       // 산성 효과 VFX 프리팹
    
    protected override void Start()
    {
        bulletType = ElementType.Rust;
        base.Start();
    }

    protected override void ApplySpecialEffect(BaseEnemy enemy)
    {
        // 디버프 적용 로직
        // 이미 적용된 디버프가 있다면 지속 시간 초기화
        // 없다면 새로운 디버프 컴포넌트 추가
    }
}
```

주요 기능:

- 디버프 지속 시간, 속도 감소 비율, 시간당 데미지를 인스펙터에서 조정 가능
- 산성 효과 시각화를 위한 프리팹 적용

## 2. 디버프 효과 컴포넌트

디버프 효과를 관리하기 위한 `RustDebuffEffect` 컴포넌트를 만들었습니다.

```csharp
public class RustDebuffEffect : MonoBehaviour
{
    private BaseEnemy targetEnemy;
    private float duration;
    private float speedReductionFactor;
    private float damagePerSecond;
    private float originalSpeed;
    private float timer;
    
    public void Initialize(float debuffDuration, float speedReductionPercent, float dotDamage)
    {
        // 디버프 초기화 로직
        // 속도 감소 적용 및 시각적 효과 적용
    }
    
    private void Update()
    {
        // 타이머 업데이트
        // 1초마다 지속 데미지 적용
        // 디버프 지속시간 체크 및 종료 처리
    }
    
    private void RemoveDebuff()
    {
        // 디버프 효과 제거 및 원래 상태로 복구
    }
}
```

주요 기능:

- 적의 원래 속도를 저장하고 감소된 속도 적용
- 매 초마다 지속 데미지(DoT) 적용
- 디버프 지속 시간 관리 및 종료 시 원래 상태 복구

## 3. 부식 시각 효과 구현

부식 효과를 시각화하는 `RustEffect` 클래스를 만들었습니다.

```csharp
public class AcidEffect : MonoBehaviour
{
    [Header("Effect Settings")]
    [SerializeField] private ParticleSystem acidParticles;
    [SerializeField] private float effectDuration = 5f;
    [SerializeField] private Color acidColor = new Color(0.7f, 1f, 0.3f, 0.8f);
    // 기타 설정값...
    
    private void Awake()
    {
        // 파티클 시스템 초기화
    }
    
    private void SetupParticleSystem()
    {
        // 파티클 시스템 상세 설정
    }
    
    private void Update()
    {
        // 산성 거품 효과 생성
        // 산성 방울 생성
        // 효과 지속 시간 관리 및 페이드 아웃
    }
}
```

주요 기능:

- 산성 효과를 표현하는 파티클 시스템 설정
- 거품, 방울 효과를 주기적으로 생성
- 효과 지속 시간 관리 및 자연스러운 페이드 아웃

## 4. 산성 방울 효과

산성 방울이 떨어지는 효과를 위한 `AcidDrip` 클래스도 구현했다. 산성 또는 부식 이라는 개념을 하나로 합친 능력이라 생각하면 좋을 것 이다.

```csharp
public class AcidDrip : MonoBehaviour
{
    [SerializeField] private float fadeSpeed = 1.0f;
    [SerializeField] private float groundDetectionDistance = 0.5f;
    // 기타 설정값...
    
    private void Update()
    {
        // 바닥 감지 및 튀는 효과 생성
        // 페이드 아웃 처리
    }
}
```

주요 기능:

- 리지드바디를 이용해 자연스럽게 떨어지는 방울 구현
- 바닥에 닿으면 튀는 효과 생성 및 사운드 재생
- 시간에 따른 페이드 아웃

## 학습한 점

1. **컴포넌트 기반 디버프 시스템**:
    - 디버프를 컴포넌트로 구현하여 적에게 동적으로 부착/제거 가능
    - 디버프 효과의 중첩 처리 및 지속 시간 관리 방법
2. **파티클 시스템 상세 설정**:
    - 모듈별 세부 설정을 통한 산성 효과 표현
    - 코드를 통한 파티클 시스템 제어 방법
3. **물리 기반 효과**:
    - 리지드바디를 활용한 자연스러운 방울 움직임 구현
    - 레이캐스트를 통한 바닥 충돌 감지 및 효과 생성
4. **시리얼라이즈 필드 활용**:
    - 인스펙터에서 다양한 파라미터를 조정할 수 있도록 설계
    - 디자이너가 쉽게 효과를 조절할 수 있는 구조 구현
5. **효과 최적화**:
    - 적절한 시점에 효과 제거를 통한 메모리 관리
    - 파티클 수명 및 개수 제한을 통한 성능 최적화

문제점 : 웨이브 특성상 연속되는 공격이 가능하며 이는 예상치 못한 딜량을 요구 될 수 있다고 생각한다.

밸런스면에서 테스트를 많이 진행 할 필요가 있다.
