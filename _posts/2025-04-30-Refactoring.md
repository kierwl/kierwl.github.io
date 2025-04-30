---
layout: post
comments: true
title: 복장시스템 리팩토링
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

# CostumeManager 클래스 메서드 분석

기존의 복장시스템의 코드가 난잡하다고 여겨져 잘 읽히지도 않고 이해하기도 힘들다고 생각했다.

해당 코드를 리팩토링하기 위해 필요한 것이 뭔지 알아보는 시간을 가져 보기 위해 코드를 분석해 보았다.



## 1. 싱글톤 패턴 구현 메서드

### `Awake()`

```csharp
private void Awake()
{
    if (Instance == null)
    {
        Instance = this;
        DontDestroyOnLoad(gameObject);
    }
    else if (Instance != this)
    {
        Destroy(gameObject);
    }
}
```

**역할**: 클래스의 싱글톤 인스턴스를 초기화하고 씬 전환 시에도 객체가 파괴되지 않도록 함 

**사용 이유**:

- **전역 접근성**: 게임 내 어디서든 복장 시스템에 접근할 수 있도록 함
- **데이터 일관성**: 복장 상태가 씬 전환 시에도 유지되도록 보장
- **중복 방지**: 여러 인스턴스가 생성되어 충돌이 발생하는 것을 방지

## 2. 초기화 및 설정 메서드

### `Start()`

```csharp
private void Start()
{
    inventoryManager = InventoryManager.Instance;
    Debug.Log("CostumeManager 시작됨");

    if (inventoryManager != null)
    {
        // 인벤토리 변경 이벤트 구독
        inventoryManager.OnItemAdded += OnItemAdded;
        Debug.Log("인벤토리 매니저에 이벤트 구독 완료");
        
        // 기존 인벤토리에서 파츠 불러오기
        LoadPartsFromInventory();
    }
    else
    {
        Debug.LogWarning("inventoryManager가 null입니다.");
    }

    // 초기 복장 해금 상태 검사
    Debug.Log($"초기 수집된 파츠 수: {collectedPartIds.Count}");
    CheckAllCostumeUnlocks();
}
```

**역할**: 매니저 초기화, 인벤토리 시스템과 연결, 기존 데이터 로드 

**사용 이유**:

- **시스템 연동**: 인벤토리 시스템과 복장 시스템의 연결 설정
- **이벤트 기반 설계**: 느슨한 결합을 위해 이벤트 구독 방식 채택
- **초기 상태 설정**: 게임 시작 시 저장된 복장 데이터 복원

### `OnDestroy()`

```csharp
private void OnDestroy()
{
    if (inventoryManager != null)
    {
        inventoryManager.OnItemAdded -= OnItemAdded;
    }
}
```

**역할**: 객체 파괴 시 이벤트 구독 해제 

**사용 이유**:

- **메모리 누수 방지**: 이벤트 구독을 해제하여 메모리 누수 방지
- **예외 상황 대비**: 객체가 파괴된 후 이벤트 호출로 인한 NullReferenceException 방지

## 3. 파츠 관리 메서드

### `AddPart(ItemData part)`

```csharp
public bool AddPart(ItemData part)
{
    if (part == null || part.itemType != ItemType.CostumeParts)
    {
        Debug.LogWarning($"AddPart: 유효하지 않은 파츠입니다. (null: {part == null})");
        return false;
    }

    Debug.Log($"파츠 추가 시도: {part.ItemName} (ID: {part.id})");
    
    // 이미 수집한 파츠인지 확인
    if (collectedPartIds.Contains(part.id))
    {
        Debug.Log($"이미 수집한 파츠입니다: {part.ItemName} (ID: {part.id})");
        return false;
    }

    // 파츠 추가
    collectedPartIds.Add(part.id);
    Debug.Log($"파츠를 성공적으로 추가했습니다: {part.ItemName} (ID: {part.id})");
    Debug.Log($"현재 수집한 총 파츠 수: {collectedPartIds.Count}");

    // 이벤트 발생
    OnPartCollected?.Invoke(part);

    // 복장 해금 상태 검사
    if (!string.IsNullOrEmpty(part.costumeSetId))
    {
        Debug.Log($"복장 세트 해금 검사: {part.costumeSetId}");
        CheckCostumeUnlocks(part.costumeSetId);
    }
    else
    {
        Debug.LogWarning($"파츠에 costumeSetId가 없습니다: {part.ItemName} (ID: {part.id})");
        // 모든 복장 세트를 검사하여 파츠가 어떤 세트에 속하는지 확인
        CheckAllCostumeUnlocks();
    }

    return true;
}
```

**역할**: 새로운 파츠 아이템을 컬렉션에 추가하고 관련 이벤트 발생 

**사용 이유**:

- **중복 방지**: HashSet을 사용하여 중복 파츠 추가 방지
- **이벤트 기반 업데이트**: 파츠 추가 시 이벤트를 발생시켜 UI 등이 반응할 수 있도록 함
- **자동 해금 검사**: 파츠 추가 시 자동으로 복장 세트 해금 가능 여부 확인
- **방어적 프로그래밍**: null 체크 및 타입 검사로 잠재적 오류 방지

### `OnItemAdded(ItemData item)`

```csharp
private void OnItemAdded(ItemData item)
{
    // 파츠 아이템인 경우 처리
    if (item.itemType == ItemType.CostumeParts)
    {
        AddPart(item);
    }
}
```

**역할**: 인벤토리에 아이템이 추가될 때 호출되어 파츠 아이템이면 처리 

**사용 이유**:

- **시스템 간 연동**: 인벤토리와 복장 시스템을 느슨하게 연결
- **관심사 분리**: 인벤토리는 모든 아이템을, 복장 시스템은 파츠만 처리
- **자동화**: 플레이어가 파츠를 획득하면 자동으로 복장 시스템에 추가됨

### `LoadPartsFromInventory()`

```csharp
private void LoadPartsFromInventory()
{
    if (inventoryManager == null) return;
    
    List<ItemData> inventoryParts = inventoryManager.GetCostumeParts();
    Debug.Log($"인벤토리에서 {inventoryParts.Count}개의 파츠를 발견했습니다.");
    
    foreach (ItemData part in inventoryParts)
    {
        if (part != null && part.itemType == ItemType.CostumeParts)
        {
            if (!collectedPartIds.Contains(part.id))
            {
                collectedPartIds.Add(part.id);
                Debug.Log($"인벤토리에서 파츠 로드: {part.ItemName} (ID: {part.id})");
            }
        }
    }
    
    Debug.Log($"파츠 로드 후 컬렉션 크기: {collectedPartIds.Count}");
}
```

**역할**: 인벤토리에서 기존에 보유한 파츠를 복장 시스템으로 로드 

**사용 이유**:

- **상태 복원**: 게임 재시작 시 이전 상태 복원
- **시스템 동기화**: 인벤토리와 복장 시스템 간 데이터 일관성 유지
- **초기화 최적화**: 게임 시작 시 일괄 처리로 성능 최적화

## 4. 복장 세트 해금 메서드

### `CheckCostumeUnlocks(string costumeSetId)`

```csharp
private void CheckCostumeUnlocks(string costumeSetId)
{
    if (string.IsNullOrEmpty(costumeSetId))
    {
        Debug.LogWarning("CheckCostumeUnlocks: costumeSetId가 null 또는 빈 문자열입니다.");
        return;
    }

    CostumeSetData costumeSet = allCostumeSets.Find(c => c.costumeId == costumeSetId);
    if (costumeSet == null)
    {
        Debug.LogWarning($"CheckCostumeUnlocks: costumeId '{costumeSetId}'를 가진 복장 세트를 찾을 수 없습니다.");
        return;
    }

    if (costumeSet.isUnlocked)
    {
        Debug.Log($"복장 세트 '{costumeSet.costumeName}'는 이미 해금되어 있습니다.");
        return;
    }

    Debug.Log($"복장 세트 '{costumeSet.costumeName}' 해금 검사 시작...");

    // 모든 필요 파츠를 수집했는지 확인
    bool allPartsCollected = true;
    foreach (ItemData part in costumeSet.requiredParts)
    {
        if (part == null) continue;

        bool hasPart = collectedPartIds.Contains(part.id);
        Debug.Log($"파츠 '{part.ItemName}' (ID: {part.id}) 보유 여부: {hasPart}");
        
        if (!hasPart)
        {
            allPartsCollected = false;
            Debug.Log($"파츠 '{part.ItemName}'가 없어서 '{costumeSet.costumeName}' 복장 해금이 불가능합니다.");
            break;
        }
    }

    // 모든 파츠를 수집했으면 복장 해금
    if (allPartsCollected)
    {
        costumeSet.isUnlocked = true;
        Debug.Log($"모든 파츠를 수집하여 '{costumeSet.costumeName}' 복장이 해금되었습니다!");
        OnCostumeUnlocked?.Invoke(costumeSet);
    }
    else
    {
        Debug.Log($"'{costumeSet.costumeName}' 복장을 해금하기 위한 모든 파츠가 아직 수집되지 않았습니다.");
    }
}
```

**역할**: 특정 복장 세트의 해금 조건을 검사하고 충족 시 해금 

**사용 이유**:

- **조건부 잠금 해제**: 모든 필요 파츠를 모아야 복장이 해금되는 게임플레이 메커니즘 구현
- **세분화된 검사**: 특정 세트만 검사하여 성능 최적화
- **상태 변경 알림**: 해금 시 이벤트를 통해 UI 업데이트
- **상세 로깅**: 디버깅을 위한 자세한 진행 로그

### `CheckAllCostumeUnlocks()`

```csharp
private void CheckAllCostumeUnlocks()
{
    Debug.Log($"모든 복장 세트 해금 상태 검사 시작 (총 {allCostumeSets.Count}개 세트)");
    
    foreach (CostumeSetData costumeSet in allCostumeSets)
    {
        if (costumeSet == null)
        {
            Debug.LogWarning("null인 복장 세트가 발견되었습니다.");
            continue;
        }
        
        Debug.Log($"복장 세트 '{costumeSet.costumeName}' 검사 중 (해금됨: {costumeSet.isUnlocked})");
        
        if (!costumeSet.isUnlocked)
        {
            bool allPartsCollected = true;
            
            Debug.Log($"  필요한 파츠 수: {costumeSet.requiredParts.Count}");
            
            foreach (ItemData part in costumeSet.requiredParts)
            {
                if (part == null)
                {
                    Debug.LogWarning($"  null인 파츠가 '{costumeSet.costumeName}' 세트에 포함되어 있습니다.");
                    continue;
                }
                
                bool hasPart = collectedPartIds.Contains(part.id);
                Debug.Log($"  파츠 '{part.ItemName}' (ID: {part.id}) 보유 여부: {hasPart}");
                
                if (!hasPart)
                {
                    allPartsCollected = false;
                    Debug.Log($"  파츠 '{part.ItemName}'가 없어서 '{costumeSet.costumeName}' 복장 해금이 불가능합니다.");
                    break;
                }
            }

            if (allPartsCollected)
            {
                costumeSet.isUnlocked = true;
                Debug.Log($"모든 파츠를 수집하여 '{costumeSet.costumeName}' 복장이 해금되었습니다!");
                OnCostumeUnlocked?.Invoke(costumeSet);
            }
            else
            {
                Debug.Log($"'{costumeSet.costumeName}' 복장을 해금하기 위한 모든 파츠가 아직 수집되지 않았습니다.");
            }
        }
    }
}
```

**역할**: 모든 복장 세트의 해금 조건을 검사하고 충족된 세트 해금 

**사용 이유**:

- **종합적 검사**: 모든 세트를 한 번에 검사하여 해금 누락 방지
- **초기 상태 설정**: 게임 시작 시 이전에 모은 파츠로 세트 해금 가능 여부 확인
- **세트 ID 누락 대응**: 파츠에 세트 ID가 없는 경우에도 올바른 세트 해금 가능
- **강건성**: null 체크 등으로 안정적인 처리

## 5. 복장 활성화 관련 메서드

### `ActivateCostume(string costumeId)`

```csharp
public bool ActivateCostume(string costumeId)
{
    CostumeSetData costumeSet = allCostumeSets.Find(c => c.costumeId == costumeId);
    if (costumeSet == null || !costumeSet.isUnlocked)
    {
        return false;
    }

    // 이전 복장 비활성화
    DeactivateCurrentCostume();

    // 새 복장 활성화
    activeCostumeSet = costumeSet;

    // 복장 효과 활성화
    ActivateCostumeEffect(costumeSet);

    // 이벤트 발생
    OnCostumeActivated?.Invoke(costumeSet);

    return true;
}
```

**역할**: 특정 복장을 활성화하고 관련 효과 적용 

**사용 이유**:

- **상태 전환**: 이전 복장에서 새 복장으로 전환하는 과정 관리
- **효과 시스템 연동**: 복장마다 다른 게임플레이 효과 적용
- **상태 변경 알림**: 이벤트를 통해 UI 및 다른 시스템에 알림
- **검증 로직**: 해금되지 않은 복장은 활성화할 수 없도록 방지

### `DeactivateCurrentCostume()`

```csharp
private void DeactivateCurrentCostume()
{
    if (activeCostumeSet != null && activeEffect != null)
    {
        activeEffect.DeactivateEffect();
        Destroy(activeEffect);
        activeEffect = null;
    }

    activeCostumeSet = null;
}
```

**역할**: 현재 활성화된 복장과 효과를 제거 

**사용 이유**:

- **리소스 관리**: 사용하지 않는 효과 컴포넌트 제거로 메모리 관리
- **충돌 방지**: 새 복장 적용 전 기존 효과 비활성화로 충돌 방지
- **상태 초기화**: 새 복장 적용을 위한 깨끗한 상태 준비

### `ActivateCostumeEffect(CostumeSetData costumeSet)`

```csharp
private void ActivateCostumeEffect(CostumeSetData costumeSet)
{
    if (costumeSet == null) return;

    // 복장 ID에 따라 적절한 효과 컴포넌트 추가
    switch (costumeSet.costumeId)
    {
        case "wing":
            activeEffect = gameObject.AddComponent<WingSuitEffect>();
            break;

        // 다른 복장 효과 추가...

        default:
            return;
    }

    if (activeEffect != null)
    {
        activeEffect.costumeData = costumeSet;
        activeEffect.ActivateEffect();
    }
}
```

**역할**: 복장 ID에 따라 적절한 효과 컴포넌트를 생성하고 활성화 **사용 이유**:

- **다형성 활용**: 복장마다 다른 효과를 구현할 수 있는 구조
- **컴포넌트 기반 설계**: Unity의 컴포넌트 패턴을 활용한 효과 시스템
- **확장성**: 새로운 복장과 효과를 쉽게 추가할 수 있는 구조

## 6. 조회 및 유틸리티 메서드

### `HasPart(int partId)`

```csharp
public bool HasPart(int partId)
{
    return collectedPartIds.Contains(partId);
}
```

**역할**: 특정 파츠 보유 여부 확인 **사용 이유**:

- **간단한 확인 기능**: UI 등에서 파츠 보유 상태를 쉽게 확인할 수 있는 인터페이스
- **캡슐화**: 내부 데이터 구조를 숨기고 기능적 인터페이스 제공

### `GetPartsCollectionStatus(string costumeId)`

```csharp
public Dictionary<int, bool> GetPartsCollectionStatus(string costumeId)
{
    // 잘못된 costumeId 처리
    if (string.IsNullOrEmpty(costumeId))
    {
        Debug.LogWarning("GetPartsCollectionStatus: costumeId가 null 또는 빈 문자열입니다.");
        return new Dictionary<int, bool>();
    }

    // allCostumeSets가 null이거나 비어있는지 확인
    if (allCostumeSets == null || allCostumeSets.Count == 0)
    {
        Debug.LogWarning("GetPartsCollectionStatus: allCostumeSets가 초기화되지 않았거나 비어 있습니다.");
        return new Dictionary<int, bool>();
    }

    CostumeSetData costumeSet = allCostumeSets.Find(c => c != null && c.costumeId == costumeId);
    if (costumeSet == null)
    {
        Debug.LogWarning($"GetPartsCollectionStatus: costumeId '{costumeId}'를 가진 복장 세트를 찾을 수 없습니다.");
        return new Dictionary<int, bool>();
    }

    Dictionary<int, bool> result = new Dictionary<int, bool>();

    foreach (ItemData part in costumeSet.requiredParts)
    {
        if (part != null)
        {
            result[part.id] = collectedPartIds.Contains(part.id);
        }
    }

    return result;
}
```

**역할**: 특정 복장 세트의 모든 파츠 수집 상태를 사전 형태로 반환 

**사용 이유**:

- **UI 지원**: 복장 세트의 수집 진행 상황을 UI에 표시하기 위한 데이터 제공
- **방어적 프로그래밍**: 다양한 오류 상황 처리로 안정성 확보
- **사용 편의성**: 특정 세트의 모든 파츠 상태를 한 번에 조회할 수 있는 편의 기능

### `GetAllCostumeSets()`

```csharp
public List<CostumeSetData> GetAllCostumeSets()
{
    return new List<CostumeSetData>(allCostumeSets);
}
```

**역할**: 모든 복장 세트 데이터의 복사본 반환 

**사용 이유**:

- **데이터 보호**: 원본 리스트를 새 리스트로 복사하여 의도치 않은 변경 방지
- **UI 지원**: 복장 목록을 표시하기 위한 데이터 제공

### `GetCostumeSet(string costumeId)`

```csharp
public CostumeSetData GetCostumeSet(string costumeId)
{
    // 잘못된 costumeId 처리
    if (string.IsNullOrEmpty(costumeId))
    {
        Debug.LogWarning("GetCostumeSet: costumeId가 null 또는 빈 문자열입니다.");
        return null;
    }

    // allCostumeSets가 null이거나 비어있는지 확인
    if (allCostumeSets == null || allCostumeSets.Count == 0)
    {
        Debug.LogWarning("GetCostumeSet: allCostumeSets가 초기화되지 않았거나 비어 있습니다.");
        return null;
    }

    return allCostumeSets.Find(c => c != null && c.costumeId == costumeId);
}
```

**역할**: 특정 ID를 가진 복장 세트 데이터 반환 

**사용 이유**:

- **방어적 프로그래밍**: 여러 오류 상황에 대한 검사로 안정성 확보
- **편의성**: 복장 세트를 ID로 쉽게 조회할 수 있는 기능 제공

### `IsActiveCostume(string costumeId)`

```csharp
public bool IsActiveCostume(string costumeId)
{
    return activeCostumeSet != null && activeCostumeSet.costumeId == costumeId;
}
```

**역할**: 특정 복장이 현재 활성화되어 있는지 확인

**사용 이유**:

- **상태 확인**: UI 등에서 현재 선택된 복장을 표시하기 위한 기능
- **간결성**: 복잡한 조건을 간단한 메서드로 캡슐화

### `GetActiveCostume()`

```csharp
public CostumeSetData GetActiveCostume()
{
    return activeCostumeSet;
}
```

**역할**: 현재 활성화된 복장 데이터 반환 

**사용 이유**:

- **상태 조회**: 현재 착용 중인 복장 정보 제공
- **캡슐화**: 내부 상태 변수에 직접 접근하지 않고 메서드로 제공



-----

### 개선 가능한 부분

----

##### 에러 처리: null 검사는 많이 하고 있으나, 로그 메시지만 출력하고 실제 대응은 미흡한 부분이 있음

##### 효과 시스템 확장: 현재 switch문으로 처리하는 부분을 더 유연한 팩토리 패턴이나 전략 패턴으로 개선 가능 -> 아직 복장의 기능이 정해진 것이 없음으로 조금 더 생각 할 필요가 있음

##### 성능 최적화: Find() 메서드를 자주 사용하는데, 복장 세트가 많아지면 Dictionary 등으로 O(1) 검색이 가능하도록 개선 필요

##### 데이터 영속성: 현재 코드에는 저장/로드 기능이 명시적으로 구현되어 있지 않음
