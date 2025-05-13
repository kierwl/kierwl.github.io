---
layout: post
comments: true
title: 딕셔너리와 델리게이트를 활용한 리팩토링
excerpt: 코드 학습
categories:
  - 유니티
  - 스파르타
tags:
  - TIL
toc_label: 팀프로젝트
toc: true
toc_sticky: true
date: 2025-05-13
last_modified_at: 2025-05-13
---

### 📆 오늘의 TIL (Today I Learned)

### 딕셔너리와 델리게이트를 활용한 Bullet 클래스 리펙토링

팀 프로젝트를 진행 하던중, 각자 필요한 기능이나 구조가 필요하면, 사용하지 않는 시간대에, 해당 코드를 수정하는 방식으로 , 프로젝트를 진행하였다. 하지만 이방식은 각자의 코드작업의 방법이 다양하기 때문에
일관성있게 코드가 짜여지지 않았고, 코드가 길어질 수록 보기 어렵다는 단점 이 있었다.
Bullet 클래스를 살펴보면
- 기존에는 if문이나 switch문으로 태그별로 충돌 처리를 분기했지만,
오늘은 Unity에서 충돌 처리 코드를 더 깔끔하고 확장성이 좋게 구조를 바꿔 보려한다.

딕셔너리와 델리게이트(Action)를 활용하면 If문으로 늘여놓은 태그별 충돌 처리를 한 곳에 등록할 수 있고 OnTriggerEnter2D에서는 딕셔너리 조회만으로 간결하게 처리할 수 있다.
- 이 구조는 새로운 태그가 추가되거나,태그별 충돌 로직이 바뀔 때코드 수정이 매우 쉽고,가독성도 좋아진다.
- 실제로 Bullet.cs에 적용해보니충돌 처리 코드가 훨씬 정돈되고,유지보수성이 높아졌다.
앞으로 Unity에서 태그별/종류별 분기 처리가 필요할 때 딕셔너리+델리게이트 패턴을 적극적으로 활용해야 할 필요를 느꼈다.

### 구조 설명

현재 Bullet 클래스의 충돌 처리 구조는 다음과 같다.

1. 딕셔너리 + 델리게이트 패턴 사용

- Dictionary<string, Action<Collider2D>> collisionHandlers를 선언하여,태그별로 충돌 처리 함수를 미리 등록한다.

- 예시:

- "Mirror" → HandleMirrorCollision

- "Destructible" → HandleDestructibleCollision

- "Boss" → HandleBossCollision

- "Enemy" → HandleEnemyCollision

1. Awake에서 딕셔너리 초기화

- Awake()에서 각 태그에 맞는 처리 함수를 딕셔너리에 등록한다.

1. OnTriggerEnter2D에서 통합 처리

- 충돌한 오브젝트의 태그가 딕셔너리에 있으면, 해당 델리게이트(함수)를 실행한다.

- 태그가 없으면, 레이어(벽, 장애물 등)로 추가 분기하여 처리한다.

- 플레이어 및 플레이어 자식과의 충돌은 무시한다.

1. 각 태그별 처리 함수

- 예를 들어, HandleEnemyCollision에서는 적에게 데미지, 넉백, 특수효과, 과열 반동 등을 처리한다.

- 각 태그별로 필요한 로직을 함수로 분리하여 관리할 수 있다.

----
이로 인해 새로 추가되는 Boss에게 피해를 넣거나, 데미지를 받는 오브젝트에 충돌 처리를 보다 쉽게 넣을 수 있게 되었다.
