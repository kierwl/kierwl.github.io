---
layout: single
comments: true
title:  "플레이어 인풋액션"
excerpt: "코드 학습"
categories: 
- 유니티
- 스파르타
tags:
- TIL
 
toc_label: 팀프로젝트
toc: true
toc_sticky: true
 
date: 2025-04-05
last_modified_at: 2025-04-05
---

### 📆 오늘의 TIL (Today I Learned)

# 플레이어 컨트롤러 구현

할로우나이트와 같은 조작감을 위해 인풋액션을 활용하여 플레이어 컨트롤러를 만들어 보려고 했다.

레퍼런스 게임이었던 록맨과 같이 다양한 상태가 있기에 FSM을 선택했고 앞으로 상태가 추가되더라도 직접 구현하는것보다 상태를 불러오는게 더 효과적이라 생각했다. -> 확장성에 용이? 한것 같다



## 1. 상태 머신 패턴

이 코드는 상태 머신 패턴을 사용하여 플레이어의 다양한 상태(대기, 달리기, 점프, 낙하, 벽 슬라이딩, 대시)를 관리하게되고. 각 상태는 별도의 클래스로 구현되고, 플레이어의 행동은 현재 상태에 따라 결정된다.

```
// 상태 머신 구현
private Dictionary<PlayerStateType, IPlayerState> states = new Dictionary<PlayerStateType, IPlayerState>();
private IPlayerState currentState;
```

상태 변화는 `ChangeState` 메서드를 통해 이루어집니다:

```
public void ChangeState(PlayerStateType newState)
{
    currentState?.Exit();
    currentStateType = newState;
    currentState = states[newState];
    currentState.Enter();
}
```

## 2. 입력 시스템

Unity의 새 Input System을 사용하여 플레이어 입력을 처리

```
// Input System
private PlayerControls playerControls;

// Input System 초기화
playerControls = new PlayerControls();
playerControls.Player.SetCallbacks(this);
```

입력 콜백은 인터페이스 구현을 통해 처리됩니다:

```
public class PlayerController : MonoBehaviour, PlayerControls.IPlayerActions
```

## 3. 물리 기반 이동 시스템

이 코드는 `Rigidbody2D`를 사용하여 물리 기반 이동을 구현합니다. 특히 눈에 띄는 점은 선형적인 속도 변화가 아닌, 비선형 가속도를 적용하여 더 자연스러운 움직임을 만들어냅니다:

```
// 비선형 가속을 위한 승수 적용
float movement = Mathf.Pow(Mathf.Abs(speedDiff) * accelRate, velocityPower) * Mathf.Sign(speedDiff);
```

## 4. 고급 플랫포머 메커니즘

코드는 플랫폼 게임에서 자주 사용되는 여러 고급 메커니즘을 구현합니다:

### 코요테 타임 (Coyote Time)

플레이어가 플랫폼 가장자리를 벗어난 후에도 짧은 시간 동안 점프가 가능하게 하는 기능:

```
[SerializeField] private float coyoteTime = 0.15f;
```

### 점프 버퍼 (Jump Buffer)

플레이어가 땅에 닿기 직전에 점프 키를 눌러도 점프가 실행되게 하는 기능:

```
[SerializeField] private float jumpBufferTime = 0.1f;
```

### 벽 슬라이딩 및 벽 점프

플레이어가 벽을 타고 미끄러지거나 벽에서 반대 방향으로 점프할 수 있는 기능:

```
public void WallJump()
{
    // 벽에서 반대 방향으로 점프
    Vector2 direction = new Vector2(-FacingDirection * wallJumpDirection.x, wallJumpDirection.y);
    Rb.velocity = Vector2.zero;
    Rb.AddForce(direction * wallJumpForce, ForceMode2D.Impulse);
}
```

### 대시

플레이어가 순간적으로 빠르게 이동할 수 있는 능력:

```
public IEnumerator Dash()
{
    // 대시 중 중력 비활성화
    float originalGravity = Rb.gravityScale;
    Rb.gravityScale = 0;
    
    // 대시 속도 설정
    Rb.velocity = new Vector2(dashDirection * dashSpeed, 0);
    
    yield return new WaitForSeconds(dashDuration);
    
    // 대시 종료 후 상태 변경
    IsDashing = false;
    Rb.gravityScale = originalGravity;
}
```

## 5. 레이캐스트를 이용한 충돌 감지

지면이나 벽과의 충돌을 감지하기 위해 `Physics2D.BoxCast`를 사용한다.:

```
public bool IsGrounded()
{
    RaycastHit2D hit = Physics2D.BoxCast(
        BoxCollider.bounds.center,
        new Vector2(BoxCollider.bounds.size.x * 0.95f, 0.2f),
        0f,
        Vector2.down,
        0.5f,
        groundLayer
    );
    
    return hit.collider != null;
}
```

## 6. 코루틴을 활용한 시간 제어

대시나 일시적인 움직임 제한과 같은 기능에 코루틴을 사용하여 시간을 제어한다:

```
private IEnumerator DisableMovement(float duration)
{
    // 입력 비활성화
    MoveInput = Vector2.zero;
    
    // 지정된 시간만큼 대기
    yield return new WaitForSeconds(duration);
    
    // 입력 복원
    if (wasControlsDisabled && MoveInput == Vector2.zero)
    {
        MoveInput = cachedInput;
    }
}
```

## 결론

상태 머신 패턴을 사용하여 코드를 구조화하고, 새로운 입력 시스템을 적용하며, 물리 기반 이동 시스템과 플랫포머 메커니즘을 구현했다. 특히 비선형 가속, 코요테 타임, 점프 버퍼와 같은 세부 구현은 더 자연스럽고 반응성 있는 게임플레이를 만들기 위해 지금까지 만들어온 프로젝트에서 배운 요소를 적용해 보았다.

다만 애니메이션 관리중에 부자연스러운 부분이 있는 것 같아 아직 수정이 필요해 보인다.

