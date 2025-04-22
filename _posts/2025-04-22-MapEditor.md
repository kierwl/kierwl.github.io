---
layout: single
comments: true
title:  "맵 에디터 제작하기"
excerpt: "코드 학습"
categories: 
- 유니티
- 스파르타
tags:
- TIL
 
toc_label: 팀프로젝트
toc: true
toc_sticky: true
 
date: 2025-04-22
last_modified_at: 2025-04-22
---

### 📆 오늘의 TIL (Today I Learned)



# 유니티 2D 플랫포머 맵 에디터

## 기본 개념 및 구조 비교

유니티 에서 스크립트를 통해 구현할 수 있는 맵 에디터를 만들기 위해 기능을 분석해 보았다.

기본 맵 에디터는 간단한 오브젝트 배치, 저장/불러오기 기능을 제공하는 반면, 만들고자 하는 맵 에디터는 레이어 시스템, 타일셋 관리, 다양한 브러시, 언두/리두 시스템 등이 필요하다.



```csharp
// 기본 맵 에디터
public class MapEditorWindow : EditorWindow {
    private List<MapObject> mapObjects = new List<MapObject>();
    private string mapName = "NewMap";
    
    // 단순한 편집 기능만 제공
}

// 확장 맵 에디터
public class ExtendedMapEditorWindow : EditorWindow {
    private List<TilesetData> tilesets = new List<TilesetData>();
    private List<LayerData> layers = new List<LayerData>();
    private List<MapObject> mapObjects = new List<MapObject>();
    private List<UndoRedoAction> undoActions = new List<UndoRedoAction>();
    
    // 다양한 고급 기능 제공
}
```

## 주요 배운 점

### 1. 유니티 에디터 확장의 강력함

EditorWindow` 클래스 상속과 `MenuItem` 속성을 통해 커스텀 도구를 만들 수 있었다.

```csharp
[MenuItem("Window/2D Platformer Map Editor (Extended)")]
public static void ShowWindow() {
    GetWindow<ExtendedMapEditorWindow>("확장 맵 에디터");
}
```

`SceneView.duringSceneGui` 이벤트를 활용하면 씬 뷰에서 직접 오브젝트를 편집할 수 있습니다:



```csharp
private void OnEnable() {
    SceneView.duringSceneGui += OnSceneGUI;
}

private void OnSceneGUI(SceneView sceneView) {
    // 씬 뷰 상호작용 처리
    Event e = Event.current;
    HandleInputs(e, sceneView);
}
```

### 2. 객체 지향 설계와 데이터 구조의 중요성

잘 설계된 데이터 구조는 복잡한 에디터 도구의 기반이 됩니다. 맵 에디터에서는 `MapObject`, `LayerData`, `TilesetData` 등의 클래스가 핵심 데이터를 관리하고 있었다.

```csharp
public class MapObject {
    public string Type;
    public Vector2 Position;
    public int InstanceID;
    public int LayerIndex;
    public TileVariant TileVariant;
    public string PrefabID;
    
    public MapObject Clone() { /* 깊은 복사 구현 */ }
}

public class LayerData {
    public string Name;
    public bool Visible;
    public bool Locked;
    
    public LayerData Clone() { /* 깊은 복사 구현 */ }
}
```

이러한 객체 지향적 설계는 코드의 유지보수성과 확장성을 높여줄 수 있다.

### 3. 이벤트 처리와 사용자 인터랙션

유니티의 `Event` 시스템을 활용한 사용자 인터랙션 처리는 에디터를 제작하는데 있어 핵심적인 부분이다:

```csharp
private void HandleInputs(Event e, SceneView sceneView) {
    switch (e.type) {
        case EventType.MouseDown:
            if (e.button == 0) { // 왼쪽 마우스 클릭
                HandleLeftMouseDown(e, mousePosition);
            }
            break;
        case EventType.KeyDown:
            HandleKeyDown(e);
            break;
    }
}
```

마우스와 키보드 이벤트에 적절히 반응하는 메서드를 구현함으로써 직관적인 인터페이스를 제공할 수 있다.

### 4. 깊은 복사를 통한 상태 관리와 언두/리두 구현

언두/리두 시스템은 깊은 복사를 통한 상태 보존과 복원을 기반으로 합니다:

```csharp
private class UndoRedoAction {
    public string ActionName;
    public List<MapObject> MapObjects; // 깊은 복사된 객체들
    public List<LayerData> Layers;     // 깊은 복사된 레이어들
    
    public UndoRedoAction(string name, List<MapObject> objects, List<LayerData> layers) {
        // 깊은 복사로 상태 저장
        MapObjects = objects.Select(obj => obj.Clone()).ToList();
        Layers = layers.Select(layer => layer.Clone()).ToList();
    }
}

private void Undo() {
    // 현재 상태를 리두 스택에 저장
    // 언두 스택에서 이전 상태 복원
    RestoreState(lastAction);
}
```

이 패턴은 복잡한 에디터 기능에서 상태 관리의 중요성을 보여준다.

### 5. 타일 변형과 다양한 브러시 시스템

확장된 맵 에디터는 타일 회전, 반전 등의 변형과 다양한 브러시 유형을 지원한다.:

```csharp
private void ApplyTileVariant(GameObject obj, TileVariant variant) {
    switch (variant) {
        case TileVariant.FlipX:
            obj.transform.localScale = new Vector3(-originalScale.x, originalScale.y, originalScale.z);
            break;
        case TileVariant.Rotate90:
            obj.transform.Rotate(Vector3.forward, 90);
            break;
        // 다른 변형들...
    }
}

private void PlaceObjectsInRect(Vector2 endPosition) {
    // 사각형 영역 내 모든 그리드 위치에 오브젝트 배치
    for (float x = minX; x <= maxX; x += snapValue) {
        for (float y = minY; y <= maxY; y += snapValue) {
            PlaceObject(new Vector2(x, y));
        }
    }
}
```

이러한 다양한 브러시 시스템은 맵 제작의 효율성을 크게 높여줄 수 있다.

### 6. 레이어 시스템과 시각적 관리

레이어 시스템은 복잡한 맵을 체계적으로 관리할 수 있어 배경을 나눌때 편리하다:

```csharp
private void SetLayerVisibility(int layerIndex, bool visible) {
    foreach (MapObject obj in mapObjects) {
        if (obj.LayerIndex == layerIndex) {
            GameObject instance = EditorUtility.InstanceIDToObject(obj.InstanceID) as GameObject;
            if (instance != null) {
                Renderer renderer = instance.GetComponent<Renderer>();
                if (renderer != null) {
                    renderer.enabled = visible;
                }
            }
        }
    }
}
```

레이어별 가시성과 잠금 상태를 관리하면 복잡한 맵 작업을 훨씬 효율적으로 할 수 있습니다.

### 7. 저장 및 불러오기 시스템

맵 데이터의 직렬화/역직렬화를 통한 저장 및 불러오기는 보다 편한 제작된 맵을 관리하는 필수 요소이다:

```csharp
private void SaveMap() {
    // 맵 데이터 구성
    ExtendedMapData mapData = new ExtendedMapData { /* 데이터 설정 */ };
    
    // JSON 직렬화
    string json = JsonUtility.ToJson(mapData, true);
    File.WriteAllText(path, json);
}

private void LoadMap() {
    // JSON 파일 읽기
    string json = File.ReadAllText(path);
    ExtendedMapData mapData = JsonUtility.FromJson<ExtendedMapData>(json);
    
    // 맵 데이터 복원
    RestoreMapFromData(mapData);
}
```

프리팹과 같은 유니티 에셋은 GUID를 사용하여 참조함으로써 프로젝트 내에서의 안정적인 참조를 보장할 수 있다..

## 통합 학습 결과

이 두 맵 에디터를 분석하면서 얻은 가장 중요한 교훈은 단순한 기능에서 시작하여 점진적으로 복잡한 기능을 추가하는 개발 방식의 효과입니다. 기본 맵 에디터는 핵심 기능만을 갖추고 있지만, 확장 맵 에디터는 이를 기반으로 다양한 고급 기능을 체계적으로 추가했습니다.

또한 객체 지향 설계, 이벤트 처리, 상태 관리, GUI 구현 등의 프로그래밍 패턴이 실제 도구 개발에 어떻게 적용되는지 배울 수 있었습니다. 이러한 패턴들은 단순히 게임 개발뿐만 아니라 다양한 소프트웨어 개발에 적용될 수 있는 유용한 지식입니다.

유니티 에디터 확장을 통해 게임 개발 워크플로우를 크게 개선할 수 있다는 점, 그리고 잘 설계된 도구가 창의적인 작업에 얼마나 큰 도움이 될 수 있는지를 배운 것은 매우 가치 있는 경험이었습니다.
