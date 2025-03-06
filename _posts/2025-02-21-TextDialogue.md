---
layout: single
comments: true
title: "대화창 만들기 "
categories: TIL
---





### 📆 오늘의 TIL (Today I Learned)

---

상호작용을 응용해서 대화창을 만들어 보았다.

```
public DialogueManager dialogueManager;
public DialogueManager.Dialogue dialogue;

public float triggerRadius = 3f; // 감지 범위
private GameObject player;
private bool dialogueStarted = false;
```

- `dialogueManager`: `DialogueManager`를 참조하여 다이얼로그를 실행하는 데 사용됨.
- `dialogue`: 현재 실행할 다이얼로그 데이터.
- `triggerRadius`: 플레이어가 **이 거리 내에 들어오면 대화가 시작됨**.
- `player`: **플레이어 객체를 저장**하기 위한 변수.
- `dialogueStarted`: **이미 대화가 실행되었는지 여부를 체크**하는 변수.

```
void Start()
{
    player = GameObject.FindGameObjectWithTag("Player"); // 플레이어 태그로 찾기
}
```

- `FindGameObjectWithTag("Player")`를 사용하여 `"Player"` 태그가 있는 객체를 찾음.
- **플레이어가 존재하는지 확인하고, 변수에 저장**

```
void Update()
{
    if (player == null) return;

    float distance = Vector2.Distance(transform.position, player.transform.position);
    
    if (distance <= triggerRadius && !dialogueStarted)
    {
        TriggerDialogue();
    }
}
```

- `Vector2.Distance()`를 사용하여 **현재 오브젝트와 플레이어 간 거리**를 계산.
- `distance <= triggerRadius`일 때 → **플레이어가 감지 범위 내에 들어오면 다이얼로그 실행**.
- `dialogueStarted`가 `false`일 때만 실행 → **중복 실행 방지**.

```
private void TriggerDialogue()
{
    if (dialogueManager != null && dialogue != null)
    {
        dialogueManager.StartDialogue(dialogue);
        dialogueStarted = true; // 대화 중복 실행 방지
    }
    else
    {
        Debug.LogWarning("DialogueManager 또는 Dialogue가 설정되지 않았습니다!");
    }
}
```

- `dialogueManager.StartDialogue(dialogue)`를 호출하여 **다이얼로그 실행**.
- `dialogueStarted = true;`로 설정하여 **같은 대화가 여러 번 실행되지 않도록 방지**.
- `null` 체크 후, **설정이 안 되어 있으면 경고 메시지 출력**.

```
private void OnDrawGizmos()
{
    Gizmos.color = Color.green; // 기즈모 색상
    Gizmos.DrawWireSphere(transform.position, triggerRadius); // 감지 범위 표시
}
```

- `Gizmos.color = Color.green;` → 기즈모 색상을 초록색으로 설정.
- `Gizmos.DrawWireSphere(transform.position, triggerRadius);` → **Scene 창에서 감지 범위를 원으로 표시**.

---

- **플레이어가 특정 거리 내에 접근하면 자동으로 다이얼로그 실행**
-  **기즈모를 이용해 감지 범위를 Scene 창에서 시각적으로 표시**
-  **게임은 멈추지만 UI는 정상적으로 작동하도록 설계**
-  **중복 실행 방지 로직을 추가하여 불필요한 다이얼로그 실행 방지**

이제 **플레이어가 NPC에 가까이 가면 자동으로 다이얼로그가 실행** 되며 범위를 0으로 두면 직접 상호작용이 가능하다.
