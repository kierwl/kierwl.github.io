---
layout: post
comments: true
title: 특성시스템에서 변경된 데미지가 적용되지 않던 문제 해결
excerpt: 코드 학습
categories:
  - 유니티
  - 스파르타
tags:
  - TIL
toc_label: 팀프로젝트
toc: true
toc_sticky: true
date: 2025-04-30
last_modified_at: 2025-04-30
---

### 📆 오늘의 TIL (Today I Learned)

# 특성 시스템에서 데미지 증가 효과 구현

## 문제 상황

- 특성을 통해서 bullet의 데미지를 5% 증가시키고 싶었음

- 현재 구조에서는 무기 속성을 변경하면 특성 효과가 초기화되는 문제 발생

- 첫 발사에서 특성 효과가 반영되지 않는 문제도 존재

## 원인 분석

1. 데미지 계산 구조

- 특성 효과는 WeaponManager.atkUpPercent로 관리

- 무기 속성 변경 시 SetBulletType에서 bulletDamage를 재계산하면서 특성 효과가 초기화됨

- atkUpPercent가 private으로 선언되어 외부 접근 불가

1. NullReferenceException 발생

- bulletFactory나 Bullet 컴포넌트가 없을 때 발생

- 프리팹 참조 문제로 인한 에러

## 해결 방법

1. 특성 효과 적용 구조 개선
    
```
    public void ATKUP(float effectValue)
    
       {
    
           if (effectValue <= 0) return;
    
           float percent = effectValue / 100f;
    
           // 1. atkUpPercent 갱신
    
           WeaponManager.Instance.SetAtkUpPercent(percent);
    
           // 2. 현재 무기 속성의 기본 데미지에 특성 효과 적용
    
           var type = WeaponManager.Instance.GetBulletType();
    
           var bulletPrefab = WeaponManager.Instance.BulletFactory.GetBulletPrefab(type);
    
           var bullet = bulletPrefab.GetComponent<Bullet>();
    
           if (bullet != null)
    
           {
    
               float newDamage = bullet.Damage * (1f + WeaponManager.Instance.AtkUpPercent);
    
               WeaponManager.Instance.SetBulletDamage(newDamage);
    
           }
    
       }
```

2. 접근성 개선

- WeaponManager에 AtkUpPercent 프로퍼티 추가

- bulletFactory를 public 프로퍼티로 노출

## 학습한 점

1. 데이터 흐름 관리

- 특성 효과와 무기 속성이 서로 독립적으로 동작하도록 구조 개선

- 즉시 반영이 필요한 경우 명시적으로 재계산 필요

1. Null 체크의 중요성

- 컴포넌트나 프리팹 참조 시 null 체크 필수

- 에러 발생 가능성이 있는 부분에 대한 방어적 프로그래밍

1. 접근 제어자 활용

- private 변수는 프로퍼티를 통해 안전하게 노출

- 캡슐화를 유지하면서도 필요한 접근성 제공

## 향후 개선 사항

1. 특성 효과 적용/해제 시 더 안정적인 처리

2. 무기 속성 변경 시 특성 효과 유지

3. 데미지 계산 로직 중앙화