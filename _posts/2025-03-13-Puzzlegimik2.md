---
layout: single
comments: true
title:  "3D 퍼즐 게임 "
excerpt: "유니티 개인 프로젝트"
categories: 
- 유니티
- 스파르타
tags:
- TIL
 
toc_label: 3D 퍼즐 요소
toc: true
toc_sticky: true
 
date: 2025-03-13
last_modified_at: 2025-03-13
---



### 📆 오늘의 TIL (Today I Learned)

---

3D 오브젝트의 색상을 변경하는데 같은 메테리얼을 사용하는 오브젝트들의 색상이 전부 색이 바뀌는 문제가 발생했다.



objectRenderer = GetComponentInChildren<Renderer>

이를 해결하기 위해 겟 컴포넌트를 사용하여 해당 메테리얼 렌더러를 불러와서

직접 색상을 변경해 주었더니 색이 변경되었다.



그러나 쉐이더를 적용하자 다시 색상변경이 되지 않았고



private static readonly string ColorPropertyName = "_Colour";

색상 프로퍼티 이름을 불러와서 색을 변경해주니 

변경이 되었다.
