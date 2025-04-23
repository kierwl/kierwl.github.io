---
layout: single
comments: true
title:  "맵 매니저"
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

# Unity 맵 관리 시스템

Unity에서 지난시간에 맵에디터로 생성한 Json 파일을 토대로 2d 플랫포머의 맵 관리를 위한 `MapManager` 클래스를 제작하기 위해 기능 분석을 해보았다. 이 시스템은 JSON 데이터를 기반으로 모듈식 맵을 구성하고, 씬 로딩을 최적화하는 기능을 제공합니다.

## 핵심 기능 분석

### 1. 모듈식 맵 시스템

- JSON 파일에서 맵 데이터를 로드하여 모듈을 배치
- 모듈 간 연결(도어, 게이트 등)을 설정
- GUID를 사용하여 모듈 에셋을 참조
- 모듈에 `RoomBehavior` 컴포넌트를 추가하여 개별적인 동작을 정의

### 2. 멀티 씬 최적화

- 플레이어 위치에 따라 필요한 씬만 동적으로 로드/언로드
- 환경 테마별로 모듈을 그룹화하여 별도의 씬으로 관리
- 비동기 씬 로딩으로 게임 진행 중 끊김을 최소화

### 3. 모듈-씬 매핑 시스템

- 각 모듈 GUID를 특정 씬에 매핑
- 플레이어 주변의 필요한 씬만 로드하여 메모리와 성능을 최적화
- 기본 씬(메인 씬)은 항상 로드된 상태를 유지

## 새로운 기능 추가 제안

맵 관리 시스템을 확장하기 위해 해당기능의 추가여부를 고려중이다:

```csharp
// 모듈 LOD(Level of Detail) 시스템 구현
public void SetupModuleLOD()
{
    foreach (var moduleEntry in instancedModules)
    {
        GameObject moduleInstance = moduleEntry.Value;
        LODGroup lodGroup = moduleInstance.AddComponent<LODGroup>();
        
        // LOD 설정 (거리에 따라 자세한 모델, 간략화된 모델, 아주 간략화된 모델 활성화)
        Renderer[] renderers = moduleInstance.GetComponentsInChildren<Renderer>();
        LOD[] lods = new LOD[3];
        
        lods[0] = new LOD(0.6f, renderers);
        
        // 간략화된 모델 로드
        string moduleGuid = moduleEntry.Key.Split('_')[0];
        RoomModule moduleAsset = GetModuleByGUID(moduleGuid);
        
        if (moduleAsset.lodPrefabs != null && moduleAsset.lodPrefabs.Length > 0)
        {
            // LOD 모델 인스턴스화 및 설정
            for (int i = 0; i < Mathf.Min(2, moduleAsset.lodPrefabs.Length); i++)
            {
                if (moduleAsset.lodPrefabs[i] != null)
                {
                    GameObject lodInstance = Instantiate(
                        moduleAsset.lodPrefabs[i],
                        moduleInstance.transform.position,
                        moduleInstance.transform.rotation,
                        moduleInstance.transform
                    );
                    
                    Renderer[] lodRenderers = lodInstance.GetComponentsInChildren<Renderer>();
                    lods[i + 1] = new LOD(0.3f - (i * 0.15f), lodRenderers);
                    
                    // 초기에는 비활성화
                    lodInstance.SetActive(false);
                }
            }
        }
        
        lodGroup.SetLODs(lods);
        lodGroup.RecalculateBounds();
    }
}

// 모듈 오클루전 컬링 시스템 구현
public void SetupOcclusionCulling()
{
    // 각 모듈에 오클루전 영역 추가
    foreach (var moduleEntry in instancedModules)
    {
        GameObject moduleInstance = moduleEntry.Value;
        
        // 이미 오클루더가 있는지 확인
        if (moduleInstance.GetComponent<OcclusionArea>() == null)
        {
            OcclusionArea occlusionArea = moduleInstance.AddComponent<OcclusionArea>();
            
            // 모듈 크기에 맞게 오클루전 영역 설정
            Renderer[] renderers = moduleInstance.GetComponentsInChildren<Renderer>();
            Bounds combinedBounds = new Bounds();
            
            if (renderers.Length > 0)
            {
                combinedBounds = renderers[0].bounds;
                for (int i = 1; i < renderers.Length; i++)
                {
                    combinedBounds.Encapsulate(renderers[i].bounds);
                }
                
                // 약간의 여유 공간 추가
                Vector3 size = combinedBounds.size * 1.1f;
                occlusionArea.size = size;
            }
        }
    }
    
    Debug.Log("Occlusion culling areas set up for all modules");
}

// 모듈 연결 지점의 자동 시각화
public void VisualizeConnectionPoints()
{
    foreach (var moduleEntry in instancedModules)
    {
        GameObject moduleInstance = moduleEntry.Value;
        string moduleGuid = moduleEntry.Key.Split('_')[0];
        RoomModule moduleAsset = GetModuleByGUID(moduleGuid);
        
        if (moduleAsset != null && moduleAsset.connectionPoints != null)
        {
            for (int i = 0; i < moduleAsset.connectionPoints.Length; i++)
            {
                // 연결 지점 시각화 오브젝트 생성
                GameObject vizObject = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                vizObject.name = $"Connection_{i}";
                vizObject.transform.localScale = Vector3.one * 0.3f;
                
                // 모듈의 로컬 좌표로 변환
                vizObject.transform.parent = moduleInstance.transform;
                vizObject.transform.localPosition = moduleAsset.connectionPoints[i].position;
                
                // 연결 상태에 따라 색상 변경
                Renderer renderer = vizObject.GetComponent<Renderer>();
                RoomBehavior roomBehavior = moduleInstance.GetComponent<RoomBehavior>();
                
                if (roomBehavior != null && roomBehavior.IsConnectionActive(i))
                {
                    renderer.material.color = Color.green; // 연결됨
                }
                else
                {
                    renderer.material.color = Color.red; // 연결 안됨
                }
                
                // 게임 플레이 중에는 보이지 않도록 설정
                #if UNITY_EDITOR
                vizObject.hideFlags = HideFlags.DontSaveInBuild;
                #else
                vizObject.SetActive(false);
                #endif
            }
        }
    }
}
```

## 학습 요점

1. 모듈식 디자인의 이점
   - 재사용 가능한 모듈을 조합하여 다양한 맵 생성 가능
   - 에디터에서 직관적인 맵 편집 도구 개발 가능
   - 개별 모듈의 독립적인 업데이트/수정 용이
2. 성능 최적화 기법
   - 플레이어 위치 기반 동적 씬 로드/언로드
   - 비동기 씬 관리로 게임 진행 중 끊김 방지
   - 테마별 모듈 그룹화로 관련 에셋 효율적 관리
3. GUID 기반 에셋 참조
   - 파일 경로가 변경되어도 에셋 참조 유지
   - 에디터와 런타임 간 일관된 에셋 관리
   - 모듈 에셋 캐싱으로 중복 로드 방지
4. 확장 가능한 아키텍처
   - LOD 시스템 통합 가능
   - 오클루전 컬링으로 추가 최적화 가능
   - 모듈 연결 시각화 도구로 디버깅 용이

이 맵 관리 시스템은 대규모 오픈 월드나 모듈식 레벨 구성이 필요한 게임에 특히 유용하게끔 만들려고 한다.

모듈 간 연결과 씬 관리를 효과적으로 처리하여 메모리 사용과 성능을 최적화해 게임플레이시 불편함을 없애고자 하였다.
