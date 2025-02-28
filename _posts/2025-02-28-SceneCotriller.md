---
layout: single
comments: true
title: " 씬컨트롤러 "
categories: TIL
---





### 📆 오늘의 TIL (Today I Learned)

---

### **씬 컨트롤러의 장점**

### 1️⃣ **일관된 씬 전환 관리**

- 씬을 이동할 때 중복되는 코드 없이 한 곳(Scene Controller)에서 일괄적으로 관리할 수 있다.
- `LoadScene()`, `UnloadScene()`, `Additive Scene` 로딩 등을 체계적으로 처리 가능.

### 2️⃣ **데이터 유지 및 공유**

- 씬 간 데이터(예: 플레이어 상태, 점수, 설정 값)를 유지하고 공유하기 용이함.
- `DontDestroyOnLoad`을 활용하여 중요한 객체를 유지할 수 있음.

### 3️⃣ **로딩 및 최적화 관리**

- 씬을 비동기적으로 로딩하여 부드러운 화면 전환 가능. (`SceneManager.LoadSceneAsync()`)
- 메모리 최적화를 위해 이전 씬을 언로드(Unload)할 수도 있음.

### 4️⃣ **전환 효과 및 UI 적용 가능**

- 씬 전환 시 페이드 효과나 로딩 화면을 추가하기 용이함.
- 특정 씬에서만 필요한 UI를 유지하고, 불필요한 UI는 정리 가능.

### 5️⃣ **미니게임 & 로비 시스템 관리에 적합**

- 현재 사용자의 **로비 → 미니게임 씬 이동** 구현 시 중앙에서 컨트롤할 수 있음.
- **점수 저장 및 게임 상태 관리**를 쉽게 처리할 수 있음.

------

### ✅ **사용 예시 (씬 컨트롤러 코드)**

```
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneController : MonoBehaviour
{
    public static SceneController Instance;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    // 씬 변경 메서드
    public void ChangeScene(string sceneName)
    {
        SceneManager.LoadScene(sceneName);
    }

    // 비동기 로딩 (로딩 화면 추가 가능)
    public void LoadSceneAsync(string sceneName)
    {
        StartCoroutine(LoadSceneCoroutine(sceneName));
    }

    private IEnumerator LoadSceneCoroutine(string sceneName)
    {
        AsyncOperation operation = SceneManager.LoadSceneAsync(sceneName);
        while (!operation.isDone)
        {
            yield return null;
        }
```

씬 컨트롤러를 사용하면 **일관된 씬 전환, 데이터 공유, 최적화, UI 관리**를 쉽게 할 수 있어 **개발 효율성과 유지보수성이 높아진다.**
