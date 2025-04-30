---
layout: post
comments: true
title:  "복장 시스템"
excerpt: "코드 학습"
categories: 
- 유니티
- 스파르타
tags:
- TIL
 
toc_label: 팀프로젝트
toc: true
toc_sticky: true
 
date: 2025-04-15
last_modified_at: 2025-04-15
---

### 📆 오늘의 TIL (Today I Learned)

# 복장 시스템

몬스터 헌터, 록맨등의 게임에서 등장하는 옷을 바꿔입고 특수한 기능을 사용할 수 있는 시스템을 개발하려고 한다.

레퍼런스인 록맨의 경우 플레이를 하는도중 복장의 파츠 4개를 모으면 특수 기능이 해금된 복장을 얻을 수 있다. 

복장은 유틸적 측면에서 다양한 기능을 하고 있고,  유저의 편의성과 해당 기능으로만 갈 수 있는 수집요소를 찾는데 도움을 주는 시스템이다.

## 주요 구성 요소

### 1. 데이터 모델 설계

```csharp
// 파츠 타입 열거형
public enum PartsType
{
    None,
    Head,
    Body,
    Arms,
    Legs
}

// 아이템 데이터 확장
public class ItemData : ScriptableObject
{
    // 기존 필드
    public string ItemName;
    public Sprite Icon;
    public ItemType itemType;
    
    // 복장 시스템용 추가 필드
    public PartsType partsType = PartsType.None;
    public string costumeSetId;
}

// 복장 세트 데이터
public class CostumeSetData : ScriptableObject
{
    public string costumeId;
    public string costumeName;
    public string description;
    public Sprite icon;
    public List<ItemData> requiredParts;
    public bool isUnlocked;
}
```

복장을 4파츠로 나누어 구분하고 해당 파츠는 다른복장의 파츠들과 겹치지 않게 하기 위해 복장에 ID를 적용하여

구분하였다.

### 2. 복장 관리자



```csharp
public class CostumeManager : MonoBehaviour
{
    private static CostumeManager instance;
    public static CostumeManager Instance => instance;
    
    // 수집한 파츠 ID 목록
    private HashSet<int> collectedPartIds = new HashSet<int>();
    
    // 파츠 추가
    public bool AddPart(ItemData part)
    {
        if (part == null || part.itemType != ItemType.CostumeParts)
            return false;
            
        if (collectedPartIds.Contains(part.id))
            return false;
            
        collectedPartIds.Add(part.id);
        CheckCostumeUnlocks(part.costumeSetId);
        return true;
    }
    
    // 복장 활성화
    public bool ActivateCostume(string costumeId)
    {
        CostumeSetData costumeSet = GetCostumeSet(costumeId);
        if (costumeSet == null || !costumeSet.isUnlocked)
            return false;
            
        // 기존 효과 비활성화 및 새 효과 활성화
        // ...
        
        return true;
    }
}
```

수집한 파츠를 관리하며, 파츠를 전부 모으면 복장을 해금하는 기능을 가진 매니저이다.

### 3. 아이템 스크립트 통합



```csharp
public class Item : MonoBehaviour
{
    [SerializeField] private ItemData itemData;
    [SerializeField] private SpriteRenderer spriteRenderer;
    
    // 아이템 획득 처리
    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            // 아이템 타입에 따른 처리
            if (itemData.itemType == ItemType.CostumeParts)
            {
                // 파츠 아이템은 인벤토리에 추가
                if (ItemManager.Instance != null)
                {
                    ItemManager.Instance.AddItem(itemData);
                    Debug.Log($"<color=cyan>파츠 획득:</color> {itemData.ItemName}");
                }
            }
            else if (itemData.itemAttributeType == ItemAttributeType.HealItem)
            {
                // 회복 아이템은 즉시 사용
                PlayerHP playerHP = other.GetComponent<PlayerHP>();
                if (playerHP != null)
                {
                    playerHP.Heal(itemData.effectValue);
                }
            }
            
            // 아이템 제거
            Destroy(gameObject);
        }
    }
}
```

임시로 만들어둔 아이템과, 앞으로 추가될 무기와, 다른 히든 피스 들을 인벤토리에 넣기 위해 기능을 통합하였다.

록맨의 레퍼런스처럼, 즉시 회복아이템과, 충전형 아이템을 구분하였다.

### 4. 복장 UI 구현

```csharp
public class CostumeStatusUI : MonoBehaviour
{
    [SerializeField] private Transform costumeSetContainer;
    [SerializeField] private GameObject costumeSetPrefab;
    
    // 복장 세트 목록 업데이트
    public void UpdateCostumeSetList()
    {
        // 기존 항목 제거
        foreach (Transform child in costumeSetContainer)
            Destroy(child.gameObject);
            
        // 복장 세트 목록 가져오기
        List<CostumeSetData> costumeSets = CostumeManager.Instance.GetAllCostumeSets();
        
        // 복장 세트 버튼 생성
        foreach (CostumeSetData set in costumeSets)
        {
            GameObject setObj = Instantiate(costumeSetPrefab, costumeSetContainer);
            CostumeSetUI setUI = setObj.GetComponent<CostumeSetUI>();
            if (setUI != null)
                setUI.SetCostumeSetData(set);
        }
    }
}
```

현재 가지고 있는 복장을 보여준느 UI 스크립트다. 

## 학습 포인트

1. ScriptableObject 활용
   - 에디터에서 쉽게 아이템과 복장 데이터 관리 가능
   - 변경 사항을 빠르게 테스트 가능
2. 이벤트 시스템
   - 아이템 획득, 파츠 수집, 복장 해금 등의 이벤트로 다른 시스템과 통신
   - 낮은 결합도로 유지보수성 향상
3. 싱글톤 패턴
   - 매니저 클래스의 전역 접근을 위한 싱글톤 패턴 활용
   - 다른 컴포넌트에서 쉽게 매니저 기능 사용 가능

복잡한 기능을 모듈화된 방식으로 구현하는 방법과 기존 시스템과의 통합하는 과정에서 기존에 배웠던 기술들을 사용 해 볼 수 있었다. 특히 ScriptableObject와 이벤트 시스템을 활용한 접근법이 확장성과 유지보수성 측면에서 효과적이고 편리하다는 것을 다시금 확인하였다. 
