---
layout: single
comments: true
title:  "기획 분석"
excerpt: "코드 학습"
categories: 
- 유니티
- 스파르타
tags:
- TIL
 
toc_label: 팀프로젝트
toc: true
toc_sticky: true
 
date: 2025-04-04
last_modified_at: 2025-04-04
---

### 📆 오늘의 TIL (Today I Learned)

# 레퍼런스 게임 록맨X5 분석

## 오늘의 학습: 록맨X5의 게임 메커니즘과 유니티 적용 방안

### 1. 캐릭터 시스템 분석

**록맨X5의 캐릭터 시스템:**

- 두 개의 플레이어블 캐릭터(X와 제로)를 제공하여 게임플레이 다양성 확보
- 각 캐릭터별 고유 특성:
  - X: 원거리 공격, 다양한 특수 무기 습득 가능, 방어구 업그레이드
  - 제로: 근접 공격, 콤보 시스템, 다양한 검술 기술

**유니티 구현 방안:**

```
// 캐릭터 베이스 클래스
public abstract class Character : MonoBehaviour
{
    public float health;
    public float speed;
    
    protected Rigidbody2D rb;
    protected Animator animator;
    
    public abstract void Attack();
    public abstract void SpecialAttack();
    
    // 공통 이동 로직
    public virtual void Move(float direction)
    {
        rb.velocity = new Vector2(direction * speed, rb.velocity.y);
        animator.SetFloat("Speed", Mathf.Abs(direction));
    }
}

// X 캐릭터 클래스
public class MegamanX : Character
{
    public GameObject bulletPrefab;
    public List<SpecialWeapon> specialWeapons;
    
    public override void Attack()
    {
        // 원거리 공격 구현
        Instantiate(bulletPrefab, transform.position, Quaternion.identity);
    }
    
    public override void SpecialAttack()
    {
        // 현재 장착된 특수 무기 사용
        if (currentWeapon != null)
            currentWeapon.Use();
    }
}

// 제로 캐릭터 클래스
public class Zero : Character
{
    public float attackRange;
    public int comboCount;
    
    public override void Attack()
    {
        // 근접 공격 구현
        Collider2D[] hitEnemies = Physics2D.OverlapCircleAll(attackPoint.position, attackRange, enemyLayers);
        
        foreach(Collider2D enemy in hitEnemies)
        {
            enemy.GetComponent<Enemy>().TakeDamage(attackDamage);
        }
        
        // 콤보 증가
        comboCount++;
    }
    
    public override void SpecialAttack()
    {
        // 특수 검술 기술 구현
    }
}
```

### 2. 보스 디자인 및 패턴 분석

**록맨X5의 보스 시스템:**

- 8명의 메이버릭 보스, 각각 고유한 능력과 패턴 보유
- 보스 취약점 시스템 (특정 무기에 약점)
- 단계별 공격 패턴 변화 (체력에 따른 패턴 변화)

**유니티 구현 방안:**

```
public class Boss : MonoBehaviour
{
    public string bossName;
    public float health;
    public WeaponType weakness;
    
    [SerializeField] private BossPhase[] phases;
    private int currentPhase = 0;
    
    private void Update()
    {
        // 현재 체력에 따라 페이즈 업데이트
        UpdatePhase();
        
        // 현재 페이즈의 패턴 실행
        phases[currentPhase].ExecutePattern(this);
    }
    
    private void UpdatePhase()
    {
        float healthPercentage = health / maxHealth;
        
        // 체력에 따라 페이즈 변경
        if (healthPercentage < 0.3f && currentPhase < 2)
            currentPhase = 2;
        else if (healthPercentage < 0.7f && currentPhase < 1)
            currentPhase = 1;
    }
    
    public void TakeDamage(float damage, WeaponType weaponType)
    {
        // 약점 무기일 경우 추가 데미지
        if (weaponType == weakness)
            damage *= 2;
            
        health -= damage;
    }
}

// 보스 페이즈 클래스
[System.Serializable]
public class BossPhase
{
    public List<BossPattern> patterns;
    private int currentPatternIndex = 0;
    
    public void ExecutePattern(Boss boss)
    {
        // 패턴 실행 로직
        patterns[currentPatternIndex].Execute(boss);
        
        // 다음 패턴으로 순환
        currentPatternIndex = (currentPatternIndex + 1) % patterns.Count;
    }
}
```

### 3. 무기 습득 및 업그레이드 시스템

**록맨X5의 무기 시스템:**

- 보스 처치 후 특수 무기 습득
- 히든 업그레이드 아이템(하트 탱크, 서브 탱크, 특수 아머 등)
- 아머 파츠 시스템(다양한 능력 부여)

### 4. 스테이지 디자인 분석

**록맨X5의 스테이지 디자인:**

- 각 보스별 테마가 있는 독특한 스테이지
- 환경 기반 퍼즐과 장애물(중력 변화, 물 아래, 강한 바람 등)
- 다양한 경로와 숨겨진 아이템
- 중간 보스와 메인 보스 구조

### 5. 진행 시스템 및 게임플레이 루프

**록맨X5의 진행 시스템:**

- 8개 스테이지 자유롭게 선택 가능
- 시간 제한 시스템(엔딩에 영향)
- 다양한 엔딩과 분기점
- 능력치 및 파츠 수집이 게임 진행에 영향

### 6. UI 및 입력 시스템

**록맨X5의 UI 및 입력:**

- 직관적인 체력 및 에너지 바 표시
- 무기 선택 인터페이스
- 반응성 높은 컨트롤

### 7. 록맨X5의 레벨 디자인 철학과 유니티 적용

**록맨X5의 레벨 디자인 철학:**

- 진입 장벽이 낮지만 숙련도에 따른 도전적인 콘텐츠 제공
- 패턴 학습과 반복을 통한 숙련도 향상
- 다양한 플레이 스타일 지원(공격적, 방어적, 수집 지향적)
- 보상과 도전의 균형 있는 배치

**유니티에서 이 철학 구현 방안:**

1. 난이도 조절 시스템
2. 패턴 기반 적 AI 설계
3. 다양한 플레이 스타일을 위한 업그레이드 패스 제공
4. 레벨 레이아웃에 도전과 휴식 구간 적절히 배치
