---
layout: single
comments: true
title:  "무빙플랫폼"
excerpt: "유니티 개인 프로젝트"
categories: 
- 유니티
- 스파르타
tags:
- TIL
 
toc_label: 무빙플랫폼
toc: true
toc_sticky: true
 
date: 2025-03-07
last_modified_at: 2025-03-07
---



### 📆 오늘의 TIL (Today I Learned)

---

오늘은 무빙플랫폼을 구현해 보았다.

단순히 한방향으로 움직이는 것이 아닌 특정 좌표를 기준으로 반복이동을 하는 것을 목표로 삼았다.



```
public class WaypointPath : MonoBehaviour
{
    public Transform GetWaypoint(int waypoint)
    {
        return transform.GetChild(waypoint);
    }

    public int GetNextWaypointIndex(int currentwaypointIndex)
    {
        int nextWaypointIndex = currentwaypointIndex + 1;
        if (nextWaypointIndex == transform.childCount)
        {
            nextWaypointIndex = 0;
        }
        return nextWaypointIndex;
    }
}
```

먼저 웨이포인트 패스를 만들어 빈오브젝트에 스크립트를 넣고 자식으로 생성되는 transform 좌표들에게 index로 번호를 매겨 순차적으로 움직 일 수 있도록 했다.

```
public class MovingPlatform : MonoBehaviour
{
    [SerializeField]
    private WaypointPath _waypointPath;

    public float moveSpeed = 2f;  // 이동 속도
    private int _targetWaypointIndex; // 다음 목표 위치 인덱스

    private Transform _previousWaypoint; // 이전 위치
    private Transform _targetWaypoint;   // 목표 위치

    private float timeToWaypoint = 0f; // 목표 위치까지의 시간
    private float elapsedTime = 0f;    // 경과 시간
    public LayerMask playerLayer; // 플레이어 감지 레이어
    public Vector3 detectionSize = new Vector3(2f, 0.5f, 2f); // 감지 범위


    private void Start()
    {
        TargetNextWaypoint();
    }
    private void FixedUpdate()
    {
        elapsedTime += Time.deltaTime;
        float elapsedPercent = elapsedTime / timeToWaypoint;

        elapsedPercent = Mathf.SmoothStep(0, 1, elapsedPercent);
        transform.position = Vector3.Lerp(_previousWaypoint.position, _targetWaypoint.position, elapsedPercent);
        //transform.rotation = Vector3.Lerp(_previousWaypoint.rotation, _targetWaypoint.rotation, elapsedPercent);

        if (elapsedPercent >= 1)
        {
            TargetNextWaypoint();
        }
    }
    private void TargetNextWaypoint()
    {
        _previousWaypoint = _waypointPath.GetWaypoint(_targetWaypointIndex);
        _targetWaypointIndex = _waypointPath.GetNextWaypointIndex(_targetWaypointIndex);
        _targetWaypoint = _waypointPath.GetWaypoint(_targetWaypointIndex);

        elapsedTime = 0f;

        float distance = Vector3.Distance(_previousWaypoint.position, _targetWaypoint.position);
        timeToWaypoint = distance / moveSpeed;
    }

    private void OnTriggerEnter(Collider other)
    {
        other.transform.SetParent(transform);
    }
    private void OnTriggerExit(Collider other)
    {
        other.transform.SetParent(null);
    }
}
```

`FixedUpdate()`는 물리 연산이 포함된 프레임에서 호출된다. 여기서 **플랫폼의 이동**을 처리한다.

`elapsedTime`은 목표 지점에 도달하는 데 걸리는 **경과 시간**을 추적한다.

`elapsedPercent`는 **현재 위치**가 목표 지점까지의 비율로 나타내며, `Mathf.SmoothStep`은 부드럽게 가속하는 함수로 비율을 보정

`Vector3.Lerp()`는 **보간법**을 이용해 이전 위치에서 목표 위치로 **플랫폼을 이동**시킨다.

목표 지점에 도달하면 `TargetNextWaypoint()`를 호출하여 **다음 목표 지점**으로 이동



```
private void TargetNextWaypoint()
{
    _previousWaypoint = _waypointPath.GetWaypoint(_targetWaypointIndex);
    _targetWaypointIndex = _waypointPath.GetNextWaypointIndex(_targetWaypointIndex);
    _targetWaypoint = _waypointPath.GetWaypoint(_targetWaypointIndex);

    elapsedTime = 0f;

    float distance = Vector3.Distance(_previousWaypoint.position, _targetWaypoint.position);
    timeToWaypoint = distance / moveSpeed;
}

```

**다음 목표 지점**을 설정하는 메서드로

`GetWaypoint()`: `WaypointPath` 클래스에서 특정 **인덱스**의 웨이포인트를 반환한다.

`GetNextWaypointIndex()`: 현재 목표 지점의 다음 인덱스를 반환하여 플랫폼이 계속 순차적으로 이동한다.

목표 지점까지의 **이동 시간**(`timeToWaypoint`)은 현재 지점과 목표 지점 간의 거리를 **이동 속도**로 나누어 계산



기존 코드는 기둥 오브젝트와 충돌시 플레이어만 자식으로 포함되어야 하는데 기둥과 연결된 모든 오브젝트가 자식으로 포함되는 바람에 이상한 물리력이 생기게 되었고, 도착지점에서 플레이어가 기둥의 콜라이더와 충돌하면 물리력을 받아 위로 높게 날아가는 버그를 발견하였다.



```
private void OnTriggerEnter(Collider other)
{
    // 플레이어 레이어에 속한 객체만 자식으로 설정
    if (((1 << other.gameObject.layer) & playerLayer) != 0)
    {
        other.transform.SetParent(transform);
    }
}

private void OnTriggerExit(Collider other)
{
    // 플레이어 레이어에 속한 객체만 부모에서 해제
    if (((1 << other.gameObject.layer) & playerLayer) != 0)
    {
        other.transform.SetParent(null);
    }
}
```

해당부분을 플레이어 레이어에 속한 객체만으로 제한 두는 것으로 이를 해결 할 수 있었다.

이제 정상적으로 움직이는 무빙플랫폼이 완성되었다.
