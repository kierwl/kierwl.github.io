---
layout: single
comments: true
title:  "UnityAction<T>"
excerpt: "코드 학습"
categories: 
- 유니티
- 스파르타
tags:
- TIL
 
toc_label: 팀프로젝트
toc: true
toc_sticky: true
 
date: 2025-03-31
last_modified_at: 2025-03-31
---

### 📆 오늘의 TIL (Today I Learned)

## UnityAction<T>이란?

오늘 Unity의 이벤트 처리 시스템에서 사용되는 `UnityAction<T>`를 사용해 보기위해 알아 보았다. 이것은 Unity에서 제공하는 제네릭 델리게이트로, C#의 기본 `Action` 델리게이트와 유사하지만 Unity의 이벤트 시스템과 더 잘 통합된다.

```
// 예시: PlayerUnit을 매개변수로 받는 UnityAction 선언
public UnityAction<PlayerUnit> OnPlayerDeadAction;
```

## 주요 특징

1. **매개변수 전달**: `<PlayerUnit>`은 이 델리게이트가 `PlayerUnit` 타입의 매개변수를 하나 받는 메서드를 참조할 수 있다는 의미다.
2. **Inspector 연동**: 일반 C# 델리게이트와 달리 Unity Inspector에서 볼 수 있고 연결할 수 있다.
3. **이벤트 호출 방법**: `OnPlayerDeadAction?.Invoke(this)`와 같은 형태로 호출하며, null 체크를 통해 안전하게 사용할 수 있다.

## 일반적인 사용 패턴

```
// 이벤트 선언 (유닛 클래스에서)
public UnityAction<PlayerUnit> OnPlayerDeadAction;

// 이벤트 발생 (Die 메서드 내에서)
private void Die()
{
    OnPlayerDeadAction?.Invoke(this);
    // 추가 처리...
}

// 이벤트 구독 (다른 클래스에서)
playerUnit.OnPlayerDeadAction += HandlePlayerDeath;

// 이벤트 핸들러
private void HandlePlayerDeath(PlayerUnit deadUnit)
{
    // deadUnit 객체를 활용한 처리...
}
```

## 일반 C# 델리게이트와의 비교

`UnityAction<T>`는 일반 C# 델리게이트/이벤트와 비슷하지만 Unity 생태계에 더 최적화되어 있다. 단, 매개변수의 형태만 다를 뿐 기본적인 작동 방식은 동일하다.

이러한 이벤트 시스템은 게임 내 다양한 객체 간의 느슨한 결합을 유지하면서 통신할 수 있게 해준다. 특히 캐릭터가 죽었을 때 해당 정보와 위치 데이터를 필요로 하는 다른 시스템(사운드, 이펙트, 게임 상태 관리 등)에 알리는 데 유용하다.

팀원이 유닛이 죽었을때의 정보를 요청했고 UnityAction<T>를 사용하여 플레이어유닛의 데이터를 넘겨줄수 있는 액션을 죽었을 경우 Die()메서드에 추가하여 유닛이 죽으면 데이터를 넘겨줄 수 있게 만들었다.
