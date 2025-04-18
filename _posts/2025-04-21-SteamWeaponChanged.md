---
layout: single
comments: true
title:  "무기 속성에 맞는 탄환 발사하기"
excerpt: "코드 학습"
categories: 
- 유니티
- 스파르타
tags:
- TIL
 
toc_label: 팀프로젝트
toc: true
toc_sticky: true
 
date: 2025-04-21
last_modified_at: 2025-04-21
---

### 📆 오늘의 TIL (Today I Learned)

# 무기 속성 시스템 연동하기

## 개요

무기 속성 시스템의 연동 방식에 대해 많은 고민을 하였다. 처음에는 아이템데이터의 정보를 토대로 속성을 부여하고 속성별로 탄환 프리팹을 저장하여 해당 데이터의 탄환을 발사하는 방법을 연구했지만 이 방법은 무기를 전환하는 과정에서 오류가 많이 났다. 무엇보다 해당 시스템과 차징시스템이 겹치게 되어 프리팹이 여러개가 필요한 경우가 있기도 했고, 기존의 시스템과 맞지않아 구조를 짜는데 머리가 아팠다. 이렇게 고민하던 중에 이전에 배운 팩토리메서드 패턴이 생각났고 탄환을 만들고 무기를 관리하는 매니저에서 해당 팩토리를 통해 아이템 데이터에 맞는 속성의 탄환을 제작한다. 이 시스템은 인벤토리 시스템, 무기 매니저, 총알 팩토리 간의 상호작용을 통해 게임 내 다양한 속성의 공격을 구현할 수 있다.

## 주요 컴포넌트

### 1. ElementType 열거형

모든 속성을 정의하는 열거형 타입이다.

```csharp
public enum ElementType
{
    Normal,
    Rust,
    Iron,
    Poison,
    Water,
    Flame,
    Ice
}
```

### 2. BulletFactory 클래스

다양한 속성의 총알을 생성하는 팩토리 패턴 구현체이다.

```csharp
public class BulletFactory : MonoBehaviour
{
    // 속성별 총알 프리팹
    [SerializeField] private GameObject normalBulletPrefab;
    [SerializeField] private GameObject rustBulletPrefab;
    [SerializeField] private GameObject ironBulletPrefab;
    [SerializeField] private GameObject poisonBulletPrefab;
    [SerializeField] private GameObject waterBulletPrefab;
    [SerializeField] private GameObject flameBulletPrefab;
    [SerializeField] private GameObject iceBulletPrefab;
    
    // 총알 생성 메서드
    public GameObject CreateBullet(ElementType type, Vector3 position, Quaternion rotation, bool isOvercharged = false)
    {
        GameObject bulletObject = null;
        
        // 속성 타입에 따른 총알 생성
        switch (type)
        {
            case ElementType.Normal:
                bulletObject = Instantiate(normalBulletPrefab, position, rotation);
                break;
            case ElementType.Rust:
                bulletObject = Instantiate(rustBulletPrefab, position, rotation);
                break;
            case ElementType.Iron:
                bulletObject = Instantiate(ironBulletPrefab, position, rotation);
                break;
            case ElementType.Poison:
                bulletObject = Instantiate(poisonBulletPrefab, position, rotation);
                break;
            case ElementType.Water:
                bulletObject = Instantiate(waterBulletPrefab, position, rotation);
                break;
            case ElementType.Flame:
                bulletObject = Instantiate(flameBulletPrefab, position, rotation);
                break;
            case ElementType.Ice:
                bulletObject = Instantiate(iceBulletPrefab, position, rotation);
                break;
            default:
                bulletObject = Instantiate(normalBulletPrefab, position, rotation);
                break;
        }
        
        // 총알이 생성됐다면 과열 상태 설정
        if (bulletObject != null)
        {
            Bullet bulletComponent = bulletObject.GetComponent<Bullet>();
            if (bulletComponent != null)
            {
                bulletComponent.isOvercharged = isOvercharged;
            }
        }
        
        return bulletObject;
    }
}
```

### 3. WeaponManager 클래스 (부분 코드)

무기와의 연동 부분을 담당하는 매니저이다. 현재 무기에 설정된 속성을 저장하고 BulletFactory를 사용하여 총알을 생성한다.

```csharp
public class WeaponManager : Singleton<WeaponManager>
{
    // (기존 코드 생략)
    
    [Header("불릿 팩토리 설정")]
    [SerializeField] private BulletFactory bulletFactory;    // 불릿 팩토리 참조
    [SerializeField] private ElementType currentBulletType = ElementType.Normal; // 현재 총알 속성
    
    // (중략)
    
    // 총알 발사 로직
    public void FireNormalBullet()
    {
        // (생략)
        
        // BulletFactory를 사용하여 총알 생성
        GameObject bullet = bulletFactory.CreateBullet(currentBulletType, spawnPosition, Quaternion.identity);
        
        // (생략)
    }
    
    // 차징 공격 총알 발사
    private void FireSteamPressureBullet()
    {
        // (생략)
        
        // BulletFactory를 사용하여 총알 생성 (오버차지 여부 전달)
        GameObject bullet = bulletFactory.CreateBullet(currentBulletType, spawnPosition, Quaternion.identity, isOvercharged);
        
        // (생략)
    }
    
    // 현재 사용 중인 총알 속성 설정
    public void SetBulletType(ElementType type)
    {
        currentBulletType = type;
        Debug.Log($"무기 속성이 {type}으로 변경되었습니다.");
    }
    
    // 총알 속성 가져오기
    public ElementType GetBulletType()
    {
        return currentBulletType;
    }
}
```

### 4. InventoryManager 클래스 (부분 코드)

인벤토리와 장착 아이템 관리를 담당하는 매니저이다. 무기 속성 아이템 장착 시 WeaponManager와 연동된다.

```csharp
public class InventoryManager : MonoBehaviour
{
    // (기존 코드 생략)
    
    // 현재 장착된 무기 속성
    [SerializeField] private ItemData equippedWeaponAttribute;
    
    public ItemData EquippedWeaponAttribute => equippedWeaponAttribute;
    
    // 이벤트 델리게이트
    public delegate void ItemEventHandler(ItemData item);
    public event ItemEventHandler OnWeaponAttributeChanged;// 무기 속성 변경 이벤트
    
    // (중략)
    
    private void Start()
    {
        // (생략)
        
        // 시작 시 현재 무기 속성이 있으면 WeaponManager에 설정
        if (equippedWeaponAttribute != null)
        {
            UpdateWeaponBulletType(equippedWeaponAttribute);
        }
    }
    
    // 무기 속성 장착
    public bool EquipWeaponAttribute(ItemData weaponAttribute)
    {
        if (weaponAttribute == null || !weaponAttributes.Contains(weaponAttribute)) return false;

        // 이전 속성과 다를 때만 이벤트 발생
        if (equippedWeaponAttribute != weaponAttribute)
        {
            equippedWeaponAttribute = weaponAttribute;
            
            // 무기 속성 장착 이벤트 발생
            OnItemEquipped?.Invoke(weaponAttribute);
            
            // 무기 속성 변경 이벤트 발생
            OnWeaponAttributeChanged?.Invoke(weaponAttribute);
            
            // WeaponManager에 불릿 타입 설정
            UpdateWeaponBulletType(weaponAttribute);
            
            Debug.Log($"무기 속성 장착: {weaponAttribute.ItemName}");
        }
        
        return true;
    }
    
    // WeaponManager의 총알 타입 업데이트
    private void UpdateWeaponBulletType(ItemData weaponAttribute)
    {
        if (WeaponManager.Instance != null)
        {
            ElementType bulletType = ElementType.Normal; // 기본값
            
            // 무기 속성이 있으면 해당 속성의 ElementType으로 설정
            if (weaponAttribute != null && weaponAttribute.itemType == ItemType.WeaponAttribute)
            {
                bulletType = weaponAttribute.elementType;
            }
            
            // WeaponManager에 총알 타입 설정
            WeaponManager.Instance.SetBulletType(bulletType);
            
            Debug.Log($"무기 총알 타입이 {bulletType}으로 변경되었습니다.");
        }
    }
}
```

## 시스템 연동 과정

### 1. 아이템의 ElementType 정의

각 무기 속성 아이템은 `ItemData`에 `elementType` 속성을 가지고 있다.

```csharp
public class ItemData : ScriptableObject
{
    // (일부 생략)
    public ElementType elementType; // 무기 속성 아이템의 원소 타입
}
```

### 2. 아이템 장착 시 속성 전파 과정

1. 플레이어가 인벤토리에서 무기 속성 아이템 장착
2. `InventoryManager.EquipWeaponAttribute()` 메서드 호출
3. `weaponAttribute` 변수에 선택된 아이템 저장
4. `OnWeaponAttributeChanged` 이벤트 발생
5. `UpdateWeaponBulletType()` 메서드가 해당 속성의 ElementType을 WeaponManager에 전달
6. `WeaponManager.SetBulletType()` 메서드가 호출되어 currentBulletType 업데이트

### 3. 총알 발사 시 속성 적용 과정

1. 플레이어가 공격 버튼 누름
2. `WeaponManager`의 발사 메서드 호출
3. `BulletFactory.CreateBullet()` 메서드 호출 시 현재 설정된 `currentBulletType` 전달
4. 팩토리는 타입에 맞는 프리팹 인스턴스화
5. 총알 객체 생성 후 필요한 속성 설정 (isOvercharged 등)
6. 생성된 총알이 발사되어 해당 속성의 효과 구현

## 시스템 구조적 이점

1. **모듈화**
   - 각 컴포넌트가 자신의 책임에 집중하며 필요한 정보만 서로 공유
   - InventoryManager: 아이템 관리와 장착 상태 관리
   - WeaponManager: 무기 상태와 발사 로직 관리
   - BulletFactory: 다양한 총알 생성 담당
2. **확장성**
   - 새로운 원소 속성을 추가하려면:
     1. ElementType 열거형에 새 타입 추가
     2. 해당 속성의 총알 프리팹 제작
     3. BulletFactory에 새 프리팹 필드와 switch 케이스 추가
   - 다른 시스템들은 수정할 필요 없음
3. **이벤트 기반 통신**
   - 직접적인 함수 호출 대신 이벤트를 통한 느슨한 결합
   - OnWeaponAttributeChanged 이벤트로 다른 시스템도 무기 속성 변경을 감지할 수 있음
4. **싱글톤 패턴 활용**
   - WeaponManager와 InventoryManager가 싱글톤으로 구현되어 접근성 향상
   - 시스템 간 참조가 간단해짐

## 배운 점

1. **팩토리 패턴의 활용**
   - 다양한 타입의 객체를 생성하는 로직을 중앙화하여 코드 중복 방지
   - 객체 생성과 사용을 분리하여 유지보수성 향상
2. **이벤트 기반 아키텍처의 장점**
   - 시스템 간 직접적인 의존성 감소
   - 코드 변경의 영향 범위 최소화
3. **속성 시스템 설계 방법**
   - 열거형을 활용한 타입 정의
   - 아이템, 무기, 총알로 이어지는 속성 전파 흐름
4. **게임 시스템 간 연동 방법**
   - 직접 호출, 이벤트, 인터페이스 등 다양한 통신 방법 선택
   - 적절한 수준의 추상화로 유연성 확보

## 다음에 시도해볼 것

1. **속성 조합 시스템**
   - 두 가지 속성을 합쳐 새로운 효과를 만들 수 있는 기능 구현
   - 예: Rust + Water = 더 강력한 부식 효과
2. **속성 저항/약점 시스템** - 보스별 기믹을 추가할 예정이다
   - 적 유닛에 속성별 저항/약점 추가
   - 속성 상성 시스템으로 전략적 게임플레이 강화
3. **환경 상호작용** - 특정 퍼즐 기믹에서 철탄환이 적용하는 물리엔진으로 상호작용할 예정이다.
   - 총알 속성이 환경과 상호작용하는 기능
   - 예: 화염 속성이 나무에 닿으면 불이 붙고, 부식 속성이 금속 장애물을 약화시킴
4. **시각적 피드백 향상**
   - 속성별 고유한 파티클 이펙트와 사운드 추가
   - 속성 변경 시 무기 외관 변화 구현
