---
layout: post
comments: true
title:  "맵 매니저2"
excerpt: "코드 학습"
categories: 
- 유니티
- 스파르타
tags:
- TIL
 
toc_label: 팀프로젝트
toc: true
toc_sticky: true
 
date: 2025-04-23
last_modified_at: 2025-04-23

---

### 📆 오늘의 TIL (Today I Learned)

# 멀티 씬 최적화 기법에 대한 상세 설명

## 1. 플레이어 위치 기반 동적 씬 로드/언로드

`MapManager` 클래스의 멀티 씬 최적화는 플레이어의 현재 위치를 기준으로 필요한 씬만 메모리에 유지하는 방식으로 작동합니다.

### 핵심 구현 원리:

```csharp
 
private void ManageSceneLoading()
{
    // 플레이어 위치를 기준으로 근처에 있는 모듈 확인
    Vector3 playerPos = playerTransform.position;
    HashSet<string> neededScenes = new HashSet<string> { SceneManager.GetActiveScene().name };
    
    foreach (var moduleEntry in instancedModules)
    {
        GameObject moduleInstance = moduleEntry.Value;
        float distance = Vector3.Distance(playerPos, moduleInstance.transform.position);
        
        if (distance < sceneLoadDistance)
        {
            string moduleGuid = moduleEntry.Key.Split('_')[0]; // instanceId에서 GUID 추출
            
            if (moduleSceneMap.TryGetValue(moduleGuid, out string sceneName))
            {
                neededScenes.Add(sceneName);
            }
        }
    }
    
    // 로드/언로드 처리...
}
csharp
```

### 상세 설명:

1. 거리 기반 판단

   :

   - `sceneLoadDistance` 변수를 통해 플레이어로부터 특정 거리 내에 있는 모듈만 활성화합니다.
   - 이 거리는 게임의 시야 거리, 모듈 크기, 성능 목표에 따라 조정할 수 있습니다.

2. 모듈-씬 매핑

   :

   - 각 모듈은 특정 씬에 속해 있으며, `moduleSceneMap` 딕셔너리를 통해 모듈 GUID와 씬 이름을 연결합니다.
   - 이를 통해 특정 모듈이 필요할 때 해당 모듈이 포함된 씬만 로드할 수 있습니다.

3. 씬 로드/언로드 관리

   :

   - 필요한 씬 목록(`neededScenes`)에는 없지만 현재 로드된 씬 목록(`loadedScenes`)에 있는 씬을 언로드합니다.
   - 필요하지만 아직 로드되지 않은 씬을 새로 로드합니다.
   - 메인 씬(활성 씬)은 항상 로드된 상태를 유지합니다.

## 2. 환경 테마별 모듈 그룹화

이 시스템은 맵의 모듈들을 환경 테마별로 그룹화하여 별도의 씬으로 관리합니다.

### 에디터 도구 구현:



```csharp
public void OrganizeModulesIntoScenes()
{
    Dictionary<RoomModule.EnvironmentTheme, List<string>> themeModules = new Dictionary<RoomModule.EnvironmentTheme, List<string>>();
    
    // 테마별로 모듈 분류
    foreach (var entry in instancedModules)
    {
        string guid = entry.Key.Split('_')[0];
        RoomModule moduleAsset = GetModuleByGUID(guid);
        
        if (moduleAsset != null)
        {
            if (!themeModules.ContainsKey(moduleAsset.theme))
            {
                themeModules[moduleAsset.theme] = new List<string>();
            }
            
            themeModules[moduleAsset.theme].Add(guid);
        }
    }
    
    // SceneModuleData 생성
    sceneModules.Clear();
    foreach (var themePair in themeModules)
    {
        string sceneName = $"Scene_{themePair.Key}";
        
        SceneModuleData sceneData = new SceneModuleData
        {
            sceneName = sceneName,
            moduleGuids = themePair.Value
        };
        
        sceneModules.Add(sceneData);
    }
}
```

### 상세 설명:

1. 테마 기반 그룹화

   :

   - 각 모듈은 특정 환경 테마(예: 숲, 동굴, 도시 등)에 속합니다.
   - `RoomModule.EnvironmentTheme` 열거형을 사용하여 모듈의 테마를 정의합니다.
   - 같은 테마의 모듈들은 동일한 씬에 배치됩니다.

2. 에셋 관리 효율성

   :

   - 관련된 텍스처, 모델, 머티리얼을 함께 그룹화하여 메모리 사용을 최적화합니다.
   - 유사한 에셋을 함께 로드함으로써 GPU 배치 처리(batching)를 향상시킵니다.

3. 개발 워크플로우 향상

   :

   - 여러 개발자가 서로 다른 테마/영역을 동시에 작업할 수 있습니다.
   - 특정 테마에 대한 변경사항이 다른 테마에 영향을 미치지 않습니다.

## 3. 비동기 씬 로딩

게임 플레이 중 끊김을 최소화하기 위해 비동기 씬 로딩을 구현했습니다.

### 핵심 구현:

```csharp
private void LoadScene(string sceneName)
{
    AsyncOperation asyncLoad = SceneManager.LoadSceneAsync(sceneName, LoadSceneMode.Additive);
    asyncLoad.completed += (op) => { loadedScenes.Add(sceneName); };
    Debug.Log($"Loading scene: {sceneName}");
}
​
private void UnloadScene(string sceneName)
{
    AsyncOperation asyncUnload = SceneManager.UnloadSceneAsync(sceneName);
    asyncUnload.completed += (op) => { loadedScenes.Remove(sceneName); };
    Debug.Log($"Unloading scene: {sceneName}");
}
```

### 상세 설명:

1. 백그라운드 로딩

   :

   - `LoadSceneAsync`와 `UnloadSceneAsync` 메서드를 사용하여 메인 스레드를 차단하지 않고 씬을 로드/언로드합니다.
   - 이를 통해 씬 전환 중에도 게임 진행이 중단되지 않습니다.

2. Additive 씬 로딩

   :

   - `LoadSceneMode.Additive` 모드를 사용하여 기존 씬을 유지한 채 새 씬을 추가합니다.
   - 여러 씬이 동시에 메모리에 존재할 수 있어 점진적인 전환이 가능합니다.

3. 콜백 처리

   :

   - `completed` 이벤트를 통해 씬 로드/언로드가 완료된 후 필요한 작업을 수행합니다.
   - 로드된 씬 목록(`loadedScenes`)을 업데이트하여 씬 관리 상태를 유지합니다.

## 구현 확장 가능성

이 멀티 씬 최적화 시스템은 다음과 같은 방향으로 확장할 수 있습니다:

1. 로딩 우선순위 설정

   :

   - 플레이어에게 더 중요한 씬(시야 내 씬)에 높은 로딩 우선순위 부여
   - `asyncLoad.priority = ThreadPriority.High;` 등으로 구현 가능

2. 로딩 화면/시각적 피드백

   :

   - 씬 로딩 중 진행 상태를 표시하는 UI 요소 추가
   - `asyncLoad.progress` 값을 사용하여 로딩 진행률 표시

3. 예측 로딩

   :

   - 플레이어의 이동 방향을 고려하여 앞으로 필요할 씬을 미리 로드
   - 이동 속도와 방향 벡터를 사용하여 예상 위치 계산

4. 레벨 스트리밍

   :

   - 더 세밀한 제어를 위해 Unity의 Addressable Asset System과 통합
   - 씬 단위가 아닌 에셋 단위의 로딩 관리 가능

이러한 멀티 씬 최적화 기법은 특히 대규모 오픈 월드 게임이나 복잡한 레벨 구조를 가진 게임에서 메모리 사용량과 로딩 시간을 크게 줄일 수 있는 방법중 하나이다.
