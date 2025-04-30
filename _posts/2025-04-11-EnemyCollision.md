---
layout: post
comments: true
title:  "적 충돌 처리"
excerpt: "코드 학습"
categories: 
- 유니티
- 스파르타
tags:
- TIL
 
toc_label: 팀프로젝트
toc: true
toc_sticky: true
 
date: 2025-04-11	
last_modified_at: 2025-04-11
---

### 📆 오늘의 TIL (Today I Learned)

적과의 충돌 처리를 위해 TakeDamage 메서드를 인터페이스로 만들고 하나의 코드로 여러곳에서 재활용 할 수 있도록 만들었다.

```
using UnityEngine;

public class Bullet : MonoBehaviour
{
    public float damage = 10f;
    public float knockbackForce = 5f;

    private void OnTriggerEnter2D(Collider2D other)
    {
        // 적 레이어 확인
        if (other.CompareTag("Enemy"))
        {
            // 적에게 데미지 주기
            BaseEnemy enemy = other.GetComponent<BaseEnemy>();//Enemy로 수정 필요

            if (enemy != null)
            {
                enemy.TakeDamage(damage);

                // 넉백 적용
                Rigidbody2D enemyRb = other.GetComponent<Rigidbody2D>();
                if (enemyRb != null)
                {
                    Vector2 knockbackDirection = (other.transform.position - transform.position).normalized;
                    enemyRb.AddForce(knockbackDirection * knockbackForce, ForceMode2D.Impulse);
                }
            }

            // 총알 제거
            Destroy(gameObject);
        }
        // 벽이나 다른 장애물과 충돌
        else if (((1 << other.gameObject.layer) & (LayerMask.GetMask("Ground", "Wall"))) != 0)
        {
            // 총알 제거
            Destroy(gameObject);
        }
    }
}
```

Enemy 태그를 찾은뒤 대상의 컴포넌트중 BaseEnemy가 있다면 해당 객체에게 데미지를 주는 코드이다.

적 의 코드를 보면 파괴가능한 오브젝트 인터페이스를 상속 받고 있어서 실질적인 TakeDamage는 이곳에  선언되어있었다.

- Enemy 클래스 → BaseEnemy를 상속 → DestructibleEntity를 상속

이 경우 GetComponent<DestructibleEntity>()를 사용해도 TakeDamage는 호출되지만, 상속 계층 구조에서 가장 자식 클래스에 있는 Enemy 클래스의 오버라이드된 TakeDamage 메서드를 호출하려면 GetComponent<Enemy>()로 수정하는 것이 좋은데

EnemyBase를 상속받는 객체들이 있기 때문에 에너미의 이름이 많아진 상황이다.

이를 해결하기 위해 에너미의 공통적으로 상속받는 BaseEnemy를 호출하여 사용하였다.



### 객체지향 프로그래밍에서 상속 관계가 있을 때:

1. GetComponent<Enemy>()는 Enemy 타입의 컴포넌트만 반환하므로 Enemy 클래스의 고유한 구현이나 오버라이드된 메서드에 접근할 수 있다.

1. GetComponent<BaseEnemy>()나 GetComponent<DestructibleEntity>()를 사용하면 더 일반적인 타입으로 객체를 참조하게 되어, 자식 클래스에서 오버라이드한 메서드가 있다면 다형성에 의해 그 메서드가 호출된다.

Bullet이 Enemy에게 데미지를 줄 때 Enemy 클래스에 정의된(또는 오버라이드된) TakeDamage 메서드가 직접 호출되게 된다.



##### 먼저 "Enemy" 태그를 가진 객체에 충돌했는지 확인합니다.

1. 충돌한 객체에서 IDamageable 인터페이스를 구현한 컴포넌트를 찾습니다.

- IDamageable을 찾았다면 해당 인터페이스의 TakeDamage 메서드를 호출합니다.

- 이렇게 하면 IDamageable을 구현한 모든 종류의 에너미에 대해 동작합니다.

1. IDamageable을 찾지 못했다면 대안으로 DestructibleEntity 컴포넌트를 찾아봅니다.

- 이는 상속 계층에서 기본 클래스인 DestructibleEntity를 찾아 데미지를 주는 방식

- 모든 에너미가 이 클래스를 상속받는다면 작동한다.

이 방식을 사용하면 다양한 에너미 타입에 대해 태그나 레이어만 같다면 데미지를 줄 수 있으며, 특정 에너미 타입에 의존하지 않게 됩니다. 따라서 새로운 에너미 타입을 추가해도 이 코드를 수정할 필요가 없다는 장점이 있다.
