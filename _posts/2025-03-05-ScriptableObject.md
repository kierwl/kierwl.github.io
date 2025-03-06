---
layout: single
comments: true
title: " 스크립터블 오브젝트 "
categories: TIL
---





### 📆 오늘의 TIL (Today I Learned)

---

- ### **스크립터블 오브젝트 (ScriptableObject)란?**

  **스크립터블 오브젝트(ScriptableObject)**는 Unity에서 제공하는 데이터 저장을 위한 특별한 클래스이다. 

  주로 게임의 **설정값, 데이터, 리소스 관리** 등에 사용되며, 인스턴스를 생성해도 씬(Scene)에 종속되지 않고 **프로젝트 자산(Asset)으로 저장**된다.

  ------

  ## **📌 주요 특징**

  1. **씬에 종속되지 않음** → 씬이 변경되어도 데이터가 유지됨
  2. **데이터를 독립적으로 관리** → 다수의 오브젝트가 동일한 데이터를 공유 가능
  3. **인스펙터에서 편집 가능** → 에셋 파일로 저장되어 직관적으로 관리 가능
  4. **메모리 효율적** → 게임 오브젝트처럼 인스턴스를 생성하는 것이 아니라 **참조 방식**으로 사용됨

  ------

  ## **🛠 사용 예시**

  ### **1. 데이터 저장 및 관리**

  스크립터블 오브젝트는 주로 **아이템, 캐릭터 능력치, 퀘스트 데이터** 등의 저장용으로 사용

  ### **2. 게임 설정 (Game Settings)**

  - 게임 내 **볼륨, 난이도, 컨트롤 설정** 등을 저장하는 데 활용 가능

  ### **3. 이벤트 시스템 (Event System)**

  - UI 업데이트, 퀘스트 진행, 게임 상태 변화 등의 데이터 공유

  ------

  ## **📌 기본 사용법**

  ### **1️⃣ 스크립터블 오브젝트 생성**

  ```
  csharp복사편집using UnityEngine;
  
  [CreateAssetMenu(fileName = "NewItemData", menuName = "Game/ItemData")]
  public class ItemData : ScriptableObject
  {
      public string itemName;
      public int itemID;
      public Sprite itemIcon;
  }
  ```

  - `CreateAssetMenu`를 추가하면 **우클릭 → Create → Game → ItemData** 로 에셋을 쉽게 생성 가능

  ### **2️⃣ 스크립터블 오브젝트 인스턴스 생성**

  1. **프로젝트 창에서 우클릭 → Create → Game → ItemData**
  2. 생성된 `ItemData` 에셋에서 `itemName`, `itemID` 등을 직접 수정 가능

  ### **3️⃣ 스크립터블 오브젝트 사용**

  ```
  csharp복사편집using UnityEngine;
  
  public class ItemManager : MonoBehaviour
  {
      public ItemData itemData;
  
      void Start()
      {
          Debug.Log($"아이템 이름: {itemData.itemName}, ID: {itemData.itemID}");
      }
  }
  ```

  - `ItemManager` 오브젝트의 **인스펙터에서 `itemData` 필드에 스크립터블 오브젝트 할당 가능**
  - 여러 오브젝트가 **같은 `itemData`를 참조**하여 데이터 공유 가능

  ------

  ## **📌 장점과 단점**

  ### **✅ 장점**

  ✔ **재사용 가능** → 같은 데이터를 여러 개의 오브젝트가 참조 가능
  ✔ **데이터 유지** → 씬이 변경되어도 데이터가 유지됨
  ✔ **메모리 효율적** → 불필요한 인스턴스 생성 방지

  ### **❌ 단점**

  ❌ **실행 중 데이터 변경 후 저장되지 않음** → 런타임 중 수정된 값은 에디터를 다시 실행하면 초기화됨
  ❌ **비직관적인 로직 처리** → 동적인 로직(예: 캐릭터 이동, 물리 연산)에는 적합하지 않음

  ------

  ## **📌 스크립터블 오브젝트 활용 예시**

  ### **1️⃣ 아이템 시스템**

  - `ItemData`를 만들어 아이템의 **이름, 공격력, 설명, 아이콘** 등을 저장

  ### **2️⃣ 캐릭터 능력치 저장**

  - `CharacterStats` 클래스로 **체력, 공격력, 스피드** 등의 데이터를 관리

  ### **3️⃣ 설정값 저장**

  - `GameSettings` 클래스를 만들어 **사운드 볼륨, 해상도, 컨트롤 설정** 등을 관리

  ### **4️⃣ 퀘스트 시스템**

  - `QuestData` 클래스로 **퀘스트 목표, 보상, 조건** 등을 저장

  ------

  ## **🔍 결론**

  스크립터블 오브젝트는 **데이터 저장과 관리에 특화된 기능**을 제공하며, 씬과 무관하게 데이터를 공유할 수 있어 **설정값 관리, 아이템 시스템, 이벤트 시스템 등에서 유용하게 사용**
