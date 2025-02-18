---
layout: single
comments: true
title: "namespace "
categories: TIL
---





### 📆 오늘의 TIL (Today I Learned)

---

- `namespace`는 C#에서 **코드를 논리적으로 그룹화하고 이름 충돌을 방지하기 위해 사용**된다. Unity에서도 `namespace`를 활용하면 프로젝트를 더 체계적으로 관리할 수 있다.

  ##  Unity에서 `namespace`를 쓰는 이유

  1. **이름 충돌 방지**

     - Unity 프로젝트가 커질수록 여러 개의 스크립트와 클래스가 생기는데, 같은 이름의 클래스나 메서드가 존재할 수 있음.
     - `namespace`를 사용하면 같은 이름을 가진 클래스가 있어도 서로 다른 `namespace` 내에 있기 때문에 충돌을 방지할 수 있음.

     ```
     namespace PlayerSystem {
         public class Player {
             public void Move() {
                 Debug.Log("Player Moving...");
             }
         }
     }
     
     namespace EnemySystem {
         public class Player {  // 같은 이름이지만 다른 네임스페이스
             public void Attack() {
                 Debug.Log("Enemy Player Attacking...");
             }
         }
     }
     ```

  2. **코드 정리 및 모듈화**

     - 기능별로 코드를 분리하면 유지보수가 쉬워짐.
     - 예를 들어, `Player`, `Enemy`, `UI` 등의 기능을 각각의 `namespace`로 분리하면 코드를 체계적으로 관리할 수 있음.

     ```
     namespace UI {
         public class Menu {
             public void OpenMenu() {
                 Debug.Log("Menu Opened");
             }
         }
     }
     ```

  3. **라이브러리 및 패키지 관리**

     - Unity에서 제공하는 기본적인 기능은 `UnityEngine` 네임스페이스에 포함되어 있음.
     - 예를 들어, `MonoBehaviour`를 사용하려면 `using UnityEngine;`이 필요함.
     - 만약 `using UnityEngine;`을 생략하면 Unity의 기본 클래스와 메서드를 사용할 수 없음.

     ```
     using UnityEngine; // Unity 기능을 사용하려면 필수
     
     public class Example : MonoBehaviour {
         void Start() {
             Debug.Log("Hello, Unity!");
         }
     }
     ```

  4. **같은 프로젝트 내에서 기능 분리 가능**

     - 여러 명이 협업할 때, 특정 기능별로 `namespace`를 지정하면 충돌을 줄일 수 있음.
     - 예를 들어, `namespace Game.AI`와 `namespace Game.Physics`를 구분하여 사용하면 AI 관련 코드와 물리 엔진 관련 코드를 쉽게 구분할 수 있음.

  ------

  ##  `namespace` 사용 예제

  ### 📌 네임스페이스 선언 및 사용 방법

  ```
  namespace Game {
      public class Player {
          public void Move() {
              Debug.Log("Player is moving");
          }
      }
  }
  
  namespace Game.Enemy {
      public class Enemy {
          public void Attack() {
              Debug.Log("Enemy is attacking");
          }
      }
  }
  ```

  ### 📌 네임스페이스 사용하기

  ```
  using Game; // Game 네임스페이스 포함
  
  public class Test : MonoBehaviour {
      void Start() {
          Player player = new Player();
          player.Move();
      }
  }
  ```

  또는 **네임스페이스 없이 직접 호출**할 수도 있음.

  ```
  csharp복사편집void Start() {
      Game.Player player = new Game.Player();
      player.Move();
  }
  ```

  ------

  ##  정리

  🔹 **네임스페이스를 사용하면**

  - 이름 충돌을 방지할 수 있음.
  - 코드를 체계적으로 정리할 수 있음.
  - 협업 및 유지보수가 쉬워짐.
  - Unity의 기본 기능(`UnityEngine`)을 사용하려면 `using UnityEngine;`이 필요함.
