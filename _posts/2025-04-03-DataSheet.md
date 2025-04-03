---
layout: single
comments: true
title:  "Unity 데이터 다운로더 시스템 분석"
excerpt: "코드 학습"
categories: 
- 유니티
- 스파르타
tags:
- TIL
 
toc_label: 팀프로젝트
toc: true
toc_sticky: true
 
date: 2025-04-03
last_modified_at: 2025-04-03
---

### 📆 오늘의 TIL (Today I Learned)

## Unity 데이터 다운로더 시스템 분석

## 개요

오늘은 Unity에서 구글 스프레드시트 데이터를 직접 게임 내 ScriptableObject로 변환하는 데이터 다운로더 시스템을 분석했다. 이 시스템은 게임 개발 과정에서 기획자가 관리하는 데이터를 쉽게 Unity 프로젝트로 가져올 수 있게 해주는 효율적인 도구다.

## 주요 구성 요소

### 1. DataDownloaderWindow

- Unity 에디터 확장 창으로 구현
- 에디터 상단 메뉴의 "Tools > Data Downloader Tool"에서 접근 가능
- 단순한 버튼 인터페이스로 유닛, 몬스터, 스테이지 데이터 다운로드 기능 제공
- 임시 GameObject를 생성하고 적절한 다운로더 컴포넌트를 추가하는 방식으로 동작

### 2. CharacterDataDownloader

- 유닛과 몬스터 데이터 다운로드 담당
- Google 스프레드시트에서 TSV 형식으로 데이터를 가져옴
- TSV 데이터를 JSON으로 변환 후 ScriptableObject로 적용
- 유닛 데이터(ID, Name, HP, Atk, AtkRange, AtkDelay, SummonCost, CoolDown, AtkType)
- 몬스터 데이터(ID, Name, HP, Atk, AtkRange, AtkDelay, AttackRangeType, MoveSpeed, AtkType)

### 3. StageDataDownloader

- 스테이지 및 웨이브 데이터 다운로드 담당
- 웨이브별 몬스터 출현 정보를 관리
- 스테이지 번호를 키로 사용하여 동일한 스테이지의 여러 웨이브를 그룹화
- 각 웨이브에 대한 몬스터 ID 배열, 출현 수량, 출현 간격 등의 정보 포함

## 기술적 특징

### 비동기 처리

- UniTask 라이브러리를 활용한 효율적인 비동기 작업 처리
- `await www.SendWebRequest().ToUniTask()`와 같은 패턴으로 웹 요청 대기

### 데이터 변환 및 파싱

- TSV 형식을 JSON으로 변환하는 유틸리티 메서드 구현
- Newtonsoft.Json.Linq를 활용한 JSON 데이터 처리
- TryParse와 null 체크를 통한 안전한 데이터 파싱

### 에셋 관리

- 기존 ScriptableObject 파일 삭제 후 새로 생성하는 방식
- `AssetDatabase.CreateAsset`, `EditorUtility.SetDirty`, `AssetDatabase.SaveAssets`, `AssetDatabase.Refresh` 등을 통한 에셋 관리
- Unity 에디터 API를 활용한 에셋 생성 및 갱신

## 시스템 동작 흐름

1. 에디터 창에서 다운로드 버튼 클릭
2. 해당 다운로더 컴포넌트가 부착된 임시 GameObject 생성
3. Google 스프레드시트에서 TSV 데이터 다운로드
4. TSV 데이터를 JSON으로 변환
5. 기존 ScriptableObject 파일 삭제
6. JSON 데이터를 파싱하여 새 ScriptableObject 생성 및 설정
7. DataManager에 데이터 전달
8. 임시 GameObject 삭제

## 장점과 사용 사례

- 기획자와 개발자 간의 효율적인 워크플로우 구축
- 구글 스프레드시트를 통한 쉬운 데이터 관리
- 에디터 도구를 통한 원클릭 데이터 업데이트
- 타워 디펜스 게임과 같은 다양한 유닛과 스테이지 설정이 필요한 게임에 적합

## 개선 가능한 부분

- CharacterDataDownloader의 ApplyMonsterDataToSO 메서드에서 `unitSOData.Clear()`가 `monsterSOData.Clear()`로 수정되어야 함
- 에러 처리 및 로깅 강화
- 증분 업데이트(기존 데이터 유지하면서 변경된 부분만 업데이트) 기능 추가 가능성

## 결론

데이터 다운로더 시스템은 Unity 게임 개발 과정에서 기획 데이터를 효율적으로 관리하고 게임에 통합하는 우수한 툴이다. 구글 스프레드시트와 Unity 간의 직접 연결을 통해 개발 프로세스를 간소화하고, 데이터 관리의 유연성을 크게 향상시킬 수 있다.
