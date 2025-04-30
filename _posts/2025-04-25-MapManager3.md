---
layout: post
comments: true
title:  "맵 매니저3"
excerpt: "코드 학습"
categories: 
- 유니티
- 스파르타
tags:
- TIL
 
toc_label: 팀프로젝트
toc: true
toc_sticky: true
 
date: 2025-04-25
last_modified_at: 2025-04-25
---

### 📆 오늘의 TIL (Today I Learned)

# 청크 기반 맵 관리 시스템 분석 및 개발

## 학습 내용 요약

기존의 맵매니저에서 필요한 기능은 가져오고 청크 기반으로 맵을 생성 할 수 있게 재구성 하였습니다.

재구성을 진행하면서 수많은 오류들과 싸우게 되었고 예외처리와 비동기 로드에 대해 공부할 수 있는 기회가 되었습니다.

## 1. C# 코루틴과 예외 처리의 제약 사항

C# 언어의 코루틴과 예외 처리 간 구조적 제약을 발견하고 해결했습니다:

```csharp
// 불가능한 패턴 - try-catch 블록 내에서 yield return 사용
private IEnumerator LoadChunk(Vector2Int chunkId)
{
    try {
        // 작업 수행...
        yield return null; // 컴파일 오류 발생
    }
    catch (Exception e) {
        Debug.LogError(e.Message);
    }
}

// 해결책 - try-catch와 yield 분리
private IEnumerator LoadChunk(Vector2Int chunkId)
{
    try {
        // 초기화 및 예외 발생 가능 코드
    }
    catch (Exception e) {
        Debug.LogError(e.Message);
        yield break;
    }
    
    // yield는 try-catch 외부에 배치
    yield return null;
    
    try {
        // 다음 작업 수행
    }
    catch (Exception e) {
        Debug.LogError(e.Message);
    }
}
```

### 주요 통찰:

- C# 코루틴에서는 try-catch 블록 내에서 yield return 문을 사용할 수 없음
- 해결책: 예외 처리와 비동기 작업을 분리하는 패턴 적용
- 중요 로직을 별도 함수로 분리하거나 try-catch 블록을 여러 단계로 나누어 관리

## 2. Unity 데이터 타입 간 변환과 호환성

리스트와 배열 간 타입 관리 문제를 발견하고 해결했습니다:

```csharp
// RoomData 클래스 구조
[Serializable]
public class RoomData
{
    public List<PlacedModuleData> placedModules;
    
    [Serializable]
    public class PlacedModuleData
    {
        public string moduleGUID;
        public Vector2 position;
        public int rotationStep;
        public List<ConnectionData> connections;
    }
}

// 잘못된 접근
int moduleCount = chunkData.placedModules.Length; // 컴파일 오류: List에는 Length 속성이 없음

// 올바른 접근
int moduleCount = chunkData.placedModules.Count;

// 잘못된 변환
PlacedModuleData[] moduleArray = chunkData.placedModules.ToArray(); // 타입은 동일하지만 불필요한 메모리 사용

// 올바른 복제
List<PlacedModuleData> moduleList = new List<PlacedModuleData>(chunkData.placedModules); // 동일한 타입 유지
```

### 주요 통찰:

- List<T>와 배열(T[]) 간의 속성/메소드 차이 이해 (Count vs Length)
- 직렬화된 데이터 구조에서 올바른 컬렉션 타입 선택의 중요성
- 불필요한 변환 피하기 - 성능 및 메모리 최적화

## 3. 청크 기반 맵 관리 시스템 아키텍처

대규모 맵을 효율적으로 관리하기 위한 청크 시스템의 핵심 구조:

```csharp
public class ChunkBasedMapManager : MonoBehaviour
{
    // 설정 변수들
    public float chunkSize = 100f;
    public float loadDistance = 150f;
    public float unloadDistance = 200f;
    
    // 현재 로드된 청크 관리
    private HashSet<Vector2Int> loadedChunks = new HashSet<Vector2Int>();
    private HashSet<Vector2Int> chunksBeingLoaded = new HashSet<Vector2Int>();
    private Vector2Int currentPlayerChunk = new Vector2Int(int.MinValue, int.MinValue);
    
    // 플레이어 위치에 따른 청크 계산
    private Vector2Int GetChunkFromPosition(Vector3 position)
    {
        int x = Mathf.FloorToInt(position.x / chunkSize);
        int y = Mathf.FloorToInt(position.y / chunkSize);
        return new Vector2Int(x, y);
    }
    
    // 청크 관리 메인 로직
    private IEnumerator ManageChunks()
    {
        // 필요한 청크 계산
        HashSet<Vector2Int> neededChunks = new HashSet<Vector2Int>();
        int loadRadius = Mathf.CeilToInt(loadDistance / chunkSize);
        
        // 플레이어 주변 청크 계산
        for (int dx = -loadRadius; dx <= loadRadius; dx++)
        {
            for (int dy = -loadRadius; dy <= loadRadius; dy++)
            {
                Vector2Int chunkToCheck = new Vector2Int(currentPlayerChunk.x + dx, currentPlayerChunk.y + dy);
                if (GetChunkDistance(currentPlayerChunk, chunkToCheck) <= loadRadius)
                {
                    neededChunks.Add(chunkToCheck);
                }
            }
        }
        
        // 필요한 청크 로드
        foreach (Vector2Int chunk in neededChunks) {
            if (!loadedChunks.Contains(chunk)) {
                StartCoroutine(LoadChunk(chunk));
                yield return new WaitForSeconds(0.1f); // 로드 분산
            }
        }
        
        // 필요 없는 청크 언로드
        List<Vector2Int> chunksToUnload = new List<Vector2Int>();
        foreach (Vector2Int loadedChunk in loadedChunks) {
            if (GetChunkDistance(currentPlayerChunk, loadedChunk) > unloadDistance / chunkSize) {
                chunksToUnload.Add(loadedChunk);
            }
        }
        
        foreach (Vector2Int chunk in chunksToUnload) {
            StartCoroutine(UnloadChunk(chunk));
            yield return new WaitForSeconds(0.05f); // 언로드 분산
        }
    }
}
```

### 주요 통찰:

- 맨해튼 거리를 활용한 효율적인 청크 계산
- 로딩/언로딩 거리를 별도로 설정하여 빈번한 청크 전환 방지(히스테리시스 효과)
- 비동기 씬 로딩을 통한 성능 최적화
- 로드/언로드 작업의 시간적 분산을 통한 프레임 드랍 방지

## 4. 커스텀 에디터 확장 도구

맵 관리를 위한 사용자 친화적인 에디터 도구 구현:

```csharp
[CustomEditor(typeof(ChunkBasedMapManager))]
public class ChunkBasedMapManagerEditor : Editor
{
    // 탭 상태
    private enum Tab { Settings, Debugging, Help }
    private Tab currentTab = Tab.Settings;
    
    public override void OnInspectorGUI()
    {
        ChunkBasedMapManager mapManager = (ChunkBasedMapManager)target;
        
        // 탭 버튼
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Toggle(currentTab == Tab.Settings, "설정", EditorStyles.toolbarButton))
            currentTab = Tab.Settings;
        if (GUILayout.Toggle(currentTab == Tab.Debugging, "디버깅", EditorStyles.toolbarButton))
            currentTab = Tab.Debugging;
        if (GUILayout.Toggle(currentTab == Tab.Help, "도움말", EditorStyles.toolbarButton))
            currentTab = Tab.Help;
        EditorGUILayout.EndHorizontal();
        
        // 탭별 UI 렌더링
        switch (currentTab)
        {
            case Tab.Settings:
                DrawSettingsTab(mapManager);
                break;
            case Tab.Debugging:
                DrawDebuggingTab(mapManager);
                break;
            case Tab.Help:
                DrawHelpTab();
                break;
        }
    }
    
    // 디버깅 기능 - 런타임에만 활성화
    private void DrawDebuggingTab(ChunkBasedMapManager mapManager)
    {
        if (Application.isPlaying)
        {
            // 텔레포트 기능
            showTeleportTool = EditorGUILayout.Foldout(showTeleportTool, "텔레포트 도구", true);
            if (showTeleportTool)
            {
                teleportPosition = EditorGUILayout.Vector2Field("텔레포트 위치", teleportPosition);
                if (GUILayout.Button("텔레포트"))
                {
                    mapManager.TeleportPlayer(teleportPosition);
                }
                
                // 청크 격자 빠른 텔레포트
                EditorGUILayout.BeginHorizontal();
                for (int x = -2; x <= 2; x++)
                {
                    EditorGUILayout.BeginVertical();
                    for (int y = 2; y >= -2; y--)
                    {
                        if (GUILayout.Button($"({x}, {y})"))
                        {
                            Vector2 newPos = new Vector2(
                                (x * mapManager.chunkSize) + (mapManager.chunkSize / 2),
                                (y * mapManager.chunkSize) + (mapManager.chunkSize / 2)
                            );
                            mapManager.TeleportPlayer(newPos);
                        }
                    }
                    EditorGUILayout.EndVertical();
                }
                EditorGUILayout.EndHorizontal();
            }
        }
    }
}
```

### 주요 통찰:

- 탭 기반 UI로 복잡한 기능을 논리적으로 구성
- 런타임/에디터 상태에 따른 조건부 기능 제공
- 빠른 텔레포트 그리드로 효율적인 테스트 지원
- 사용자 친화적인 도움말로 시스템 사용법 안내

## 5. JSON 데이터와 씬 하이브리드 접근법

맵 데이터 관리를 위한 하이브리드 접근 방식:

```csharp
private IEnumerator LoadModulesFromJson(Vector2Int chunkId, ChunkInfo chunkInfo)
{
    string jsonFileName = string.Format(jsonFileFormat, chunkId.x, chunkId.y);
    TextAsset jsonAsset = Resources.Load<TextAsset>(Path.Combine(resourcesJsonFolder, jsonFileName));
    
    if (jsonAsset == null)
    {
        Debug.LogWarning($"JSON 파일을 찾을 수 없음: {jsonFileName}");
        yield break;
    }
    
    // JSON 파싱
    RoomData chunkData = JsonUtility.FromJson<RoomData>(jsonAsset.text);
    
    // 모듈 인스턴스화 - 배치 처리로 성능 최적화
    int moduleCount = 0;
    int batchSize = 5; // 한 번에 처리할 모듈 수
    
    for (int i = 0; i < chunkData.placedModules.Count; i++)
    {
        var moduleData = chunkData.placedModules[i];
        GameObject instance = InstantiateModuleFromData(moduleData, chunkId);
        
        if (instance != null)
        {
            moduleCount++;
        }
        
        // 프레임 드랍 방지
        if (chunkData.placedModules.Count > 20 && (i + 1) % batchSize == 0)
        {
            yield return null;
        }
    }
    
    // 모듈 간 연결 설정
    SetupModuleConnections(chunkData);
}
```

### 주요 통찰:

- 모듈 데이터는 JSON으로 관리, 씬은 환경 구조만 담당
- 배치 처리를 통한 인스턴스화 작업 분산으로 성능 최적화
- 모듈 인스턴스 캐싱으로 메모리 및 연산 최적화
- 모듈 간 연결 정보도 JSON에서 관리하여 유연성 확보

## 발견한 문제점 및 해결책

1. **코루틴 예외 처리 문제**:
   - 발견: try-catch 블록 내에서 yield return 사용 불가
   - 해결: 예외 처리와 비동기 로직 분리, 별도 함수로 구조화
2. **데이터 타입 불일치**:
   - 발견: List와 배열 간 프로퍼티 차이로 인한 오류
   - 해결: 일관된 컬렉션 타입 사용 및 적절한 프로퍼티 접근
3. **모듈 인스턴스화 성능 문제**:
   - 발견: 대량 모듈 생성 시 프레임 드랍 발생
   - 해결: 배치 처리와 yield return null을 통한 작업 분산
4. **청크 경계 처리 문제**:
   - 발견: 청크 경계에 걸친 모듈 연결 관리 어려움
   - 해결: 모든 모듈과 연결 정보를 중앙 관리자에서 관리하는 접근법 채택

## 다음 개발 계획

1. **청크 간 연결 및 경계 관리 개선**:
   - 청크 경계에 걸친 모듈 간 연결 처리 로직 강화
   - 경계 영역에서의 시각적 일관성 보장
2. **비동기 로딩 최적화**:
   - 모듈 로딩 우선순위 시스템 구현
   - LOD(Level of Detail) 시스템 통합
3. **메모리 관리 도구 개발**:
   - 런타임 메모리 사용량 모니터링 시스템
   - 자동 메모리 최적화 기능
4. **경로 찾기 및 내비게이션 시스템 통합**:
   - 청크 기반 내비게이션 메시 관리
   - 청크 간 경로 찾기 최적화
5. 텔레포트시 청크 로딩 수정

이번 개발을 통해 대규모 오픈 월드 맵은 해당방식과 비슷하게 청크를 로딩하는 식으로 맵을 구성한다는 것을 알았고  특히 코루틴의 제약 사항과 비동기 작업의 최적화 방법에 대해 깊이 이해할 수 있었습니다. 다음 단계에서는 청크 간 경계 처리와 메모리 최적화에 초점을 맞추어 더 견고한 시스템으로 발전시킬 계획입니다.
