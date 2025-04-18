---
layout: single
comments: true
title:  "압력계 구현하기"
excerpt: "코드 학습"
categories: 
- 유니티
- 스파르타
tags:
- TIL
 
toc_label: 팀프로젝트
toc: true
toc_sticky: true
 
date: 2025-04-18
last_modified_at: 2025-04-18
---

### 📆 오늘의 TIL (Today I Learned)

# 압력 게이지 구현하기

## 개요

오늘은 유니티에서 스팀펑크 스타일의 압력 게이지 시스템을 구현하는 방법에 대해 배웠다. 이 시스템은 `WeaponManager`와 `SteamPressureEffect` 두 개의 핵심 클래스로 구성되어 있으며, 차징 공격과 시각적 피드백을 보여주는 역할을 하고 있다. 이전 개인프로젝트를 진행하던준 스크립트만으로 UI를 만들던 영상이 떠올라 자료를 찾아보았고 이를 참고하여 해당 게이지를 제작하게 되었다.

## 핵심 구성 요소

### 1. 압력 게이지 시각적 표현

`SteamPressureEffect` 클래스는 압력 게이지의 시각적 표현을 담당한다:

```csharp
// 압력 게이지 생성
private void CreatePressureGauge()
{
    pressureGaugeObj = new GameObject("PressureGauge");
    pressureGaugeObj.transform.parent = transform;
    
    // 게이지 배경 생성
    GameObject gaugeBackground = new GameObject("GaugeBackground");
    SpriteRenderer bgRenderer = gaugeBackground.AddComponent<SpriteRenderer>();
    bgRenderer.sprite = CreateCircleSprite(32, Color.black, Color.gray);
    
    // 게이지 표시기 생성
    GameObject gaugeIndicator = new GameObject("GaugeIndicator");
    SpriteRenderer indicatorRenderer = gaugeIndicator.AddComponent<SpriteRenderer>();
    indicatorRenderer.sprite = CreateGaugeIndicatorSprite();
    
    // 게이지 바늘 생성
    GameObject gaugeNeedle = new GameObject("GaugeNeedle");
    SpriteRenderer needleRenderer = gaugeNeedle.AddComponent<SpriteRenderer>();
    needleRenderer.sprite = CreateNeedleSprite();
}
```

### 2. 프로그래매틱 스프라이트 생성

모든 시각적 요소는 코드로 생성된다:

```csharp
// 원형 스프라이트 생성
private Sprite CreateCircleSprite(int resolution = 32, Color centerColor = default, Color edgeColor = default)
{
    Texture2D texture = new Texture2D(resolution, resolution);
    Color[] colors = new Color[resolution * resolution];
    
    // 원 그리는 로직...
    
    texture.SetPixels(colors);
    texture.Apply();
    
    return Sprite.Create(texture, new Rect(0, 0, resolution, resolution), new Vector2(0.5f, 0.5f));
}
```

### 3. 압력에 반응하는 시각적 요소

압력 수준에 따라 게이지의 바늘 회전과 색상이 변경된다:

```csharp
private void UpdateVisuals()
{
    // 바늘 회전 업데이트
    Transform needle = pressureGaugeObj.transform.Find("GaugeNeedle");
    float rotationAngle = -90f + currentPressure * 180f; // -90도에서 +90도까지
    needle.localRotation = Quaternion.Euler(0, 0, rotationAngle);
    
    // 압력 레벨에 따른 색상 변경
    Transform indicator = pressureGaugeObj.transform.Find("GaugeIndicator");
    SpriteRenderer indicatorRenderer = indicator.GetComponent<SpriteRenderer>();
    
    Color pressureColor;
    if (currentPressure < 0.33f)
        pressureColor = lowPressureColor; // 녹색
    else if (currentPressure < 0.66f)
        pressureColor = mediumPressureColor; // 노란색
    else
        pressureColor = highPressureColor; // 빨간색
        
    indicatorRenderer.color = pressureColor;
}
```

### 4. 움직이는 기어와 파이프

기어는 압력에 따라 회전 속도가 달라지며, 파이프는 압력에 따라 색상이 변한다:

```csharp
// 기어 업데이트 (회전)
private void UpdateGears()
{
    float pressureBasedSpeed = 30f + (currentPressure * 90f); // 압력에 따른 회전 속도
    
    foreach (var gear in gearObjs)
    {
        GearRotation rotation = gear.GetComponent<GearRotation>();
        if (rotation.isClockwise)
            gear.transform.Rotate(0, 0, -pressureBasedSpeed * Time.deltaTime);
        else
            gear.transform.Rotate(0, 0, pressureBasedSpeed * Time.deltaTime);
    }
}
```

### 5. 증기 파티클 시스템

압력 수준에 따라 파이프에서 증기가 방출된다:

```csharp
private void EmitSteamParticle()
{
    // 랜덤 방출 위치 선택
    int emitPoint = Random.Range(0, pipeObjs.Count);
    
    // 파티클 생성 및 설정
    GameObject particle = new GameObject("SteamParticle");
    SpriteRenderer particleRenderer = particle.AddComponent<SpriteRenderer>();
    particleRenderer.sprite = CreateCloudSprite();
    
    // 파티클 애니메이션 시작
    StartCoroutine(AnimateSteamParticle(particle, direction, speed));
}
```

### 6. 압력 차징 시스템

`WeaponManager`는 버튼을 누르고 있으면 압력이 차오르는 차징 시스템을 구현한다:

```csharp
private void UpdateCharging()
{
    currentChargeTime += Time.deltaTime;
    
    // 차징 레벨 결정
    if (currentChargeTime >= chargingLevel2Time)
        currentChargeLevel = 2;
    else if (currentChargeTime >= chargingLevel1Time)
        currentChargeLevel = 1;
    else
        currentChargeLevel = 0;
    
    // 압력 이펙트 업데이트
    if (pressureEffect != null)
    {
        float pressure = Mathf.Clamp01(currentChargeTime / chargingLevel2Time);
        pressureEffect.SetPressure(pressure);
    }
}
```

### 7. 차징 레벨에 따른 총알 발사

차징 레벨에 따라 다른 종류의 총알이 발사된다:

```csharp
private void FireSteamPressureBullet()
{
    // 압력 차징 레벨에 따른 총알 타입 결정
    float damage;
    Vector3 scale;
    Color bulletColor;
    bool isOvercharged = false;
    
    if (currentChargeLevel == 2)
    {
        // 2단계 차징샷 (강력한 증기압) - 오버차지 상태
        damage = level2Damage;
        scale = level2BulletScale;
        bulletColor = new Color(1.0f, 0.5f, 0.1f, 1.0f); // 주황색 (고온 증기)
        isOvercharged = true;
    }
    else if (currentChargeLevel == 1)
    {
        // 1단계 차징샷 (중간 증기압)
        damage = level1Damage;
        scale = level1BulletScale;
        bulletColor = new Color(0.7f, 0.7f, 0.7f, 1.0f); // 회색 (일반 증기)
    }
    else
    {
        // 차징이 충분하지 않으면 일반 총알
        damage = 10f;
        scale = normalBulletScale;
        bulletColor = Color.white;
    }
    
    // 총알 생성 및 발사...
}
```

## 새롭게 배운 개념들

### 1. 프로그래매틱 스프라이트 생성

코드로 직접 스프라이트를 생성하는 방법을 배웠다. `Texture2D`를 생성하고 픽셀별로 색상을 설정한 다음 `Sprite.Create()`로 스프라이트를 만든다.

```csharp
Texture2D texture = new Texture2D(resolution, resolution);
Color[] colors = new Color[resolution * resolution];
// 색상 설정 로직...
texture.SetPixels(colors);
texture.Apply();
return Sprite.Create(texture, new Rect(0, 0, resolution, resolution), pivot);
```

### 2. 런타임에 동적 오브젝트 생성

게임 오브젝트를 코드로 동적 생성하고 컴포넌트를 추가하는 방법:

```csharp
GameObject newObj = new GameObject("ObjectName");
newObj.transform.parent = parentTransform;
SpriteRenderer renderer = newObj.AddComponent<SpriteRenderer>();
renderer.sprite = mySprite;
```

### 3. 파티클 시스템을 코루틴으로 구현

코루틴을 사용하여 파티클 애니메이션을 구현하는 방법:

```csharp
private IEnumerator AnimateSteamParticle(GameObject particle, Vector3 direction, float speed)
{
    float lifetime = 0f;
    float maxLifetime = steamLifetime;
    
    while (lifetime < maxLifetime && particle != null)
    {
        lifetime += Time.deltaTime;
        float normalizedTime = lifetime / maxLifetime;
        
        // 이동
        particle.transform.position += velocity * Time.deltaTime;
        
        // 크기 및 투명도 변화
        particle.transform.localScale = Vector3.Lerp(initialScale, targetScale, normalizedTime);
        Color color = initialColor;
        color.a = initialColor.a * (1f - normalizedTime);
        
        yield return null;
    }
    
    Destroy(particle);
}
```

### 4. 시각적 피드백 시스템 설계

압력 수준에 따라 색상, 회전 속도, 파티클 방출 빈도 등을 변경하여 사용자에게 직관적인 피드백을 제공하는 방법을 학습할 수 있었고, UI에셋이 부족하여 어떻게 구현해야하나 고민을 했었는데 이렇게 작은 UI들은 코드로 구현할 수 있다는 것을 알았다. 이 기능이 최적화적인 부분에서 어떤 영향을 미칠지는 잘 모르겠으나 멋은 있으니 일단 한잔하도록 한다.

## 유용한 테크닉

1. **동적 스프라이트 생성**: 에셋 없이 코드만으로 시각적 요소 생성
2. **계층적 객체 구조**: 관련 객체들을 부모-자식 관계로 구성
3. **변수 드라이븐 애니메이션**: 단일 변수(압력)로 여러 시각 요소 제어
4. **코루틴 기반 파티클**: 간단한 파티클 시스템 구현
5. **사운드 연동**: 시각적 변화와 함께 사운드 피드백 제공

## 다음에 시도해볼 것

1. **셰이더 활용**: 더 화려한 증기 및 압력 시각 효과를 위한 셰이더 구현
2. **물리 시스템 연동**: 증기 압력이 주변 객체에 물리적 영향 주기
3. **압력 누적 시스템**: 게임플레이와 연동된 압력 관리 메카닉 구현
4. **과압 폭발 효과**: 압력이 너무 높아지면 발생하는 폭발 이펙트
5. **압력 메터 다양화**: 다양한 스타일의 압력계 디자인 시도
