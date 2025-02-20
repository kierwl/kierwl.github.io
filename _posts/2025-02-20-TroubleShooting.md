---
layout: single
comments: true
title: "트러블 슈팅 "
categories: TIL
---





### 📆 오늘의 TIL (Today I Learned)

---

##  TroubleShooting 문제해결과정

1. 같은이름의 다른 기능을 가지는 코드가 필요한 경우 > 게임매니저의 분리가 필요함
    - https://kierwl.github.io/til/NameSpace/


1. 플레이어의 이동로직 평면화면에서 점프 구현하기

    > 점프 자체는 쉽지만 Y축을 사용하지 못하게됨 중력의 on off 기능

2. 최고점수 다른 씬에서 보여주기 -리더보드

3. F키를 활용한 상호작용

    - https://kierwl.github.io/til/Interact/

---

#### 1. 같은이름의 다른 기능을 가지는 코드

---

개인 과제를 수행하던 중에 미니게임을 여러개 만들어야 하는 상황이 생겼다.

게임매니저에서 관련 로직을 전부 관리하자니 코드가 너무 길어져서 알아보기가 힘들었다.

계속 변수들의 이름또한 중복되어서 코드에 충돌이 나는바람에 막막해졌다.



일일히 이름들을 수정하자니 코드의 양이 생각보다 많았고 이를 해결하기 위해 알아보던 중 namespace에 대해 알게되었다.

namespace는 간단히 설명하면 이름충돌을 막아주는 아주 유용한 기능이다.

코드를 쉽게 구분할 수 있게 해주고  유지보수를 쉽게 해준다.

사용법도 아주 간단해서 쉽게 문제를 해결 할  수있었다.

코드를 namespace 기능묶음이름 {}의 괄호안에 쓰기만하면된다.



#### 2. 탑다운 뷰에서 점프 구현하기

---

구르기도 아니고 점프를 구현하려고 하니 막막했었다.

2d평면에서 점프를 하려면 일단 바닥이 있어야하는데 플랫포머도 아니고 탑다운뷰에서 바닥을 유지시키기란 힘든 조건이었다.

Rigidbody2d의 중력을 조작해 가면서 처음 점프위치를 기억하고 y축이동후(중력 on) 원래 위치에 도달하면 (중력off)하는 방식으로 구현을 해보았는데 아무래도 움직임이 너무 부자연스러웠다.

중력크기도 세밀하게 조절해야되서 조작감이 매우 별로였고 마치 달에 온듯한 움직임을 하고있었다.

두번째로 시도한 방법은 0을 바닥으로 고정하는 방법이다.

이 방법은 플랫포머와 같은 방식이지만 위로 이동후 점프를하면 0의 위치까지 수직낙하 해버리는 바람에 문제가 생겼다.



세번째 방법은 Z축을 활용하는 방법이다. 사실 이 방법은 왜 되는지 아직 이해가 안가는데

Y축의 이동범위만큼 Z축도 같이 이동해서 계단식 이동을 하는 방법이다. 3d로 보면 매우 어색할만 하지만 화면은 2d라서 되는것 같다. 대신 이 방법은 기존의 방향키를 사용할 수 없어지기에 새로 키입력을 지정해 주었다.

z축을 사용함으로써 방향이동이 좌우와 앞뒤로 움직인다.

```
protected void Move()
{
    float moveX = Input.GetAxis("Horizontal"); // 좌우 이동 (X축)
    float moveZ = Input.GetAxis("Vertical");   // 앞뒤 이동 (Z축)
    float moveY = 0f;

    if (Input.GetKey(KeyCode.W)) moveY = 1f;  // Y축 상승 (W 키)
    if (Input.GetKey(KeyCode.S)) moveY = -1f; // Y축 하강 (S 키)

    Vector3 moveVector = new Vector3(moveX, moveY * verticalMoveSpeed, moveZ).normalized * moveSpeed * Time.deltaTime;
    transform.position += moveVector;
}
```

#### **이동 방식**

- `Input.GetAxis("Horizontal")` → `A/D` 키 또는 `←/→` 방향키로 **좌우(X축) 이동**
- `Input.GetAxis("Vertical")` → `W/S` 키 또는 `↑/↓` 방향키로 **앞뒤(Z축) 이동**
- `W` (`moveY = 1f`), `S` (`moveY = -1f`) 입력 시 Y축으로 이동 (위/아래)

#### 🔹 **이동 벡터**

- `moveVector = new Vector3(moveX, moveY * verticalMoveSpeed, moveZ)`
- `normalized` 적용: 이동 방향 벡터의 크기를 1로 정규화해 대각선 이동 속도 균일화
- `moveSpeed * Time.deltaTime` 적용: **프레임 속도에 영향을 받지 않도록 이동 속도 조정**
- `transform.position += moveVector`: 현재 위치에서 계산된 벡터만큼 이동

```
protected void Jump()
{
    if (Input.GetKeyDown(KeyCode.Space) && !isJumping)
    {
        StartCoroutine(JumpRoutine());
    }
}
```

- `Space` 키를 누르면 `JumpRoutine()` 코루틴 실행 (점프 중이 아닐 때만)

- 점프를 부드럽게 하기 위해 코루틴을 사용

  ## **1. 코루틴 없이 점프하면?**

  만약 코루틴을 사용하지 않고 `Update()`에서 바로 점프 처리를 한다면, 다음과 같은 문제가 발생했다.

  ```
  protected void Jump()
  {
      if (Input.GetKeyDown(KeyCode.Space) && !isJumping)
      {
          isJumping = true;
          transform.position += new Vector3(0, jumpHeight, 0); // 한 번에 이동
          isJumping = false;
      }
  }
  ```

  🔹 **문제점**

  - 점프 입력(`Space`)을 받으면 `transform.position`을 즉시 변경하여 캐릭터가 **순간이동**함.
  - 부드러운 점프 애니메이션이 아니라 캐릭터가 **바로 위로 이동한 후 바로 아래로 복귀**함.
  - 중력 감속 없이 이동하므로, 현실적인 점프처럼 보이지 않음.

  

- `isJumping` 플래그를 사용해 점프 중복 입력 방지

- ```
  private IEnumerator JumpRoutine()
  {
      isJumping = true;
      originalPosition = transform.position;
      Vector3 jumpTarget = originalPosition + new Vector3(0, jumpHeight, 0);
  
      float elapsedTime = 0f;
      while (elapsedTime < jumpDuration / 2) // 상승
      {
          transform.position = Vector3.Lerp(originalPosition, jumpTarget, (elapsedTime / (jumpDuration / 2)));
          elapsedTime += Time.deltaTime;
          yield return null;// 다음 프레임 대기
      }
  
      transform.position = jumpTarget; // 최고점 유지
  
      elapsedTime = 0f;
      while (elapsedTime < jumpDuration / 2) // 하강
      {
          transform.position = Vector3.Lerp(jumpTarget, originalPosition, (elapsedTime / (jumpDuration / 2)));
          elapsedTime += Time.deltaTime;
          yield return null;
      }
  
      transform.position = originalPosition; // 원래 위치 복귀
      isJumping = false;
  }
  ```

#### 🔹 **점프 방식**

1. **점프 시작**
   - `originalPosition`에 점프 전 위치 저장
   - `jumpTarget = originalPosition + new Vector3(0, jumpHeight, 0)` → 점프 목표 위치 계산
2. **상승 단계**
   - `while (elapsedTime < jumpDuration / 2)`
   - `Vector3.Lerp(originalPosition, jumpTarget, (elapsedTime / (jumpDuration / 2)))` → `Lerp`를 이용한 부드러운 이동
3. **최고점 유지**
   - `transform.position = jumpTarget;`
4. **하강 단계**
   - `while (elapsedTime < jumpDuration / 2)`
   - `Vector3.Lerp(jumpTarget, originalPosition, (elapsedTime / (jumpDuration / 2)))`
5. **점프 종료**
   - 원래 위치로 복귀 후 `isJumping = false;` 설정

---

어찌저찌 점프를 구현 하는 것에 성공했다.



#### 3.리더보드

---

리더보드가 상당히 귀찮았는데 미니게임의 로직을 이미 만들면서 진행했기 때문에 이를 수정하는 과정이 조금 어렵게 느껴졌다. 설계의 필요성을 느낌



수정한 코드를 바탕으로 기존의 코드또한 작동해야 하기에 생각을 좀 잘 해야 했다.

내가 작성해놓고 구조가 이해가 안됨;;

코드의 가독성이 이래 중요하다.



아무튼 리더보드는 스택, 플래피버드의 점수를 담당하는 부분을 pref으로 저장하고 불러오면 무난히 되었다.

씬이 이동했을때 데이터가 남아야 함으로  스코어매니저에 DontDestroyOnLoad(gameObject)를 사용한다.

씬이 종료되어도 파괴되지 않음으로 데이터를 계속 유지한다. 저장된 데이터를 싱글톤으로 저장한다.

```
public static ScoreManager instance;
private const string StackBestScoreKey = "StackBestScore";
private const string FlappyBestScoreKey = "FlappyBestScore";
```

##### ** 점수 저장 (SaveStackBestScore & SaveFlappyBestScore)**

```
csharp복사편집public static void SaveStackBestScore(int score)
{
    int currentBestScore = PlayerPrefs.GetInt(StackBestScoreKey, 0);
    if (score > currentBestScore)
    {
        PlayerPrefs.SetInt(StackBestScoreKey, score);
        PlayerPrefs.Save();
    }
}
csharp복사편집public static void SaveFlappyBestScore(int score)
{
    int currentBestScore = PlayerPrefs.GetInt(FlappyBestScoreKey, 0);
    if (score > currentBestScore)
    {
        PlayerPrefs.SetInt(FlappyBestScoreKey, score);
        PlayerPrefs.Save();
    }
}
```

 **설명**

- `PlayerPrefs.GetInt(StackBestScoreKey, 0)`: 저장된 최고 점수를 가져오며, 기본값은 `0`.
- 새로운 점수가 기존 최고 점수보다 높으면 `PlayerPrefs.SetInt()`를 사용하여 저장.
- `PlayerPrefs.Save();`를 호출하여 즉시 저장.

##### **점수 불러오기 (LoadStackBestScore & LoadFlappyBestScore)**

```
csharp복사편집public static int LoadStackBestScore()
{
    return PlayerPrefs.GetInt(StackBestScoreKey, 0);
}
csharp복사편집public static int LoadFlappyBestScore()
{
    return PlayerPrefs.GetInt(FlappyBestScoreKey, 0);
}
```

✅ **설명**

- `PlayerPrefs.GetInt()`를 사용하여 저장된 최고 점수를 불러옴.
- 저장된 값이 없을 경우 기본값 `0`을 반환.

스코어 매니저에서 받아온 데이터를 리더보드 UI에 연동하는 것으로 리더보드를 완성하였다.

`animator`: UI의 애니메이션을 제어할 `Animator` 객체.

`isOpen`: 리더보드 UI가 열려 있는지 여부를 나타내는 불리언 값 (기본값 `false`).

`uiPanel`: 리더보드 UI 패널 (인스펙터에서 할당).

`StackbestScoreText`, `FlappybestScoreText`: 각각 "Stack" 게임과 "Flappy" 게임의 최고 점수를 표시하는 `TextMeshProUGUI` 객체.

구현해 놓았던 상호작용을 통해 패널을 열고 닫을 수 있도록 설계했다.

### **`UpdateLeaderboard()` (점수 갱신)**

```
csharp복사편집public void UpdateLeaderboard()
{
    int stackHighScore = ScoreManager.LoadStackBestScore();
    int flappyHighScore = ScoreManager.LoadFlappyBestScore();

    StackbestScoreText.text = $" : {stackHighScore}";
    FlappybestScoreText.text = $" : {flappyHighScore}";
}
```

- `ScoreManager.LoadStackBestScore()`와 `ScoreManager.LoadFlappyBestScore()`를 호출하여 각각 "Stack"과 "Flappy" 게임의 최고 점수를 불러옴.
- 해당 점수를 `TextMeshProUGUI`에 반영.

⚠️ **주의할 점**

- `ScoreManager` 클래스가 존재해야 하며, `LoadStackBestScore()`와 `LoadFlappyBestScore()` 메서드가 정적(static) 메서드로 구현되어 있어야 정상 작동함.

#### 5.상호작용

---

만든 기능중 제일 뿌듯했던 기능이다.

상호작용이 연상이 되질 않아 기능 구현에 애를 먹었는데 만들어 놓고 보니 생각 보다 간단했다.

먼저 상호작용이 가능한 물체들은 전부 IInteractable인터페이스를 상속받는다.

Interact메서드를 기본으로 가지고 있어 상호작용으로 호출되는 모든 기능은 이 메서드가 사용한다.



먼저 상호작용에 앞서 범위를 지정하고 상호작용이 가능한 객체를 감지를 해야된다.

```
public float interactionRange = 2f; // 상호작용 가능한 범위
public GameObject interactionUI; // UI참조
private IInteractable nearestInteractable = null;
```

- `interactionRange` → 플레이어 주변에서 상호작용 가능한 오브젝트를 감지하는 범위(기본값 2f).
- `interactionUI` → 상호작용 가능한 상태일 때 표시될 UI. 
- `nearestInteractable` → 가장 가까운 상호작용 가능한 오브젝트.

```
void FindNearestInteractable()
{
    nearestInteractable = null;
    Collider2D[] colliders = Physics2D.OverlapCircleAll(transform.position, interactionRange);

    foreach (Collider2D collider in colliders)
    {
        IInteractable interactable = collider.GetComponent<IInteractable>();
        if (interactable != null)
        {
            nearestInteractable = interactable;
            return;
        }
    }
}
```

- `Physics2D.OverlapCircleAll(transform.position, interactionRange)` → **현재 위치를 중심으로 원형 범위 안의 모든 Collider2D를 가져옴.**
- 반복문을 돌며 `IInteractable` 인터페이스를 가진 오브젝트를 찾음.
- 가장 가까운 한 개의 오브젝트를 찾으면 바로 반환(`return`)하여 성능을 최적화.

```
void Update()
{
    FindNearestInteractable(); // 가장 가까운 상호작용 가능한 오브젝트 찾기

    if (nearestInteractable != null)
    {
        interactionUI.SetActive(true); // UI 표시
        if (Input.GetKeyDown(KeyCode.F))
        {
            nearestInteractable.Interact(); // 'F' 키를 누르면 상호작용
        }
    }
    else
    {
        interactionUI.SetActive(false); // UI 숨김
    }
}
```

- `FindNearestInteractable()`을 호출해 플레이어 주변에서 가장 가까운 `IInteractable` 오브젝트를 찾음.
- 상호작용 가능한 오브젝트가 있다면 **UI를 활성화**하고, 'F' 키 입력 시 `Interact()`를 실행.
- 없다면 UI를 숨김.

```
void OnDrawGizmosSelected()
{
    Gizmos.color = Color.green;
    Gizmos.DrawWireSphere(transform.position, interactionRange);
}
```

- **에디터에서 플레이어 주변의 상호작용 가능 범위를 시각적으로 표시하는 기능.**
- 플레이어를 중심으로 반경 `interactionRange`만큼의 **녹색 원을 그려서 디버깅**할 수 있음.

---

상호작용을 구현하고 이 기능을 활용하여 다양한 기능을 만들어 보았는데

상자 열고닫기

UI 온오프

문 = 열고닫기 뿐만아니라 닫았을때 콜라이더가 활성화 되어 지나가지 못해야함

-> 가장 어려운 부분이라 생각했는데 컴포넌트의 콜라이더 속성을 enable = false로 두면 해결되었다.



맵이동하기

탈것 = 오류가 가장 많아 난해했다.

쉽다고 생각하는데 막상 쉽지 않았던 상호작용은 탑승후 움직임제어 => 별도 클래스 만들고 움직임 상속받아서 탑승여부 체크하는걸로 해결

플레이어 탑승하면 내리질 못함

```
protected override void Update()
{
    if (Input.GetKeyDown(KeyCode.F) && isRiding)// 탑승여부 관계없이 f를 눌러 내릴 수 있음
    {
        ExitRide();
        return;
    }

    if (isRiding)
    {
        base.Update(); // 탑승 중일 때만 이동 가능
    }
}

public void SetRiding(bool riding)
{
    isRiding = riding;
}
private void ExitRide()
{
    // Rideable 스크립트에서 탈출 기능을 실행하도록 설정
    GetComponent<Rideable>().Interact();
}
```

컴포넌트에서 인터렉트를 사용할 수 있게 만들어서 해결



---

기능 개발을 하면서 처음 배우는 기능도 써보고 강의에서 배운 UI 구조를 참조해서 활용하기도 하고 나름 코드를 쉽고 간략하게 만들려고 개선하면서 한달이라면 짧으면 짧고 길면 긴 시간동안 이번 프로젝트를 통해 알아가는게 제일 많았던것 같다.  다만 알아가는게 많은 만큼 내 것으로 만드는 시간이 길어서 목표를 달성하고 추가기능을 만든다는 다짐이 깨지게 되었다.  잠깐 무너질뻔 하기도 했지만 어떻게 해결해내서 그로 인한 뿌듯함에 다시 일어날 수 있었고 굉장히 도움되었던 프로젝트였다.



기능 개발에 아쉬운점도 많았는데 커스터마이징은 어떻게 해야할지 감도 잡히지 않아서 손도 대지 못했고 디버깅과 버그수정에 많은 시간을투자해서 마감이 촉박했던 것도 아쉬운 부분이다.
