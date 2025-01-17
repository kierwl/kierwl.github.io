---
layout: single
comments: true
title: "유니티 Enum 데이터 타입 "
categories: TIL
tags: [C#,DataType,Unity]

---

### 📆 오늘의 TIL (Today I Learned)

------

## **프로젝트의 커스텀 Enum 데이터 타입들을 모아놓을 클래스 파일을 생성한다.**

유니티 개발 과정에서 다양한 열거형 타입들을 사용하게 될 것이다. 이 데이터 타입들 중에서는 특정 클래스에 귀속되어야 하는 타입도 존재하겠지만 글로벌하게 사용되어야 하는 공통 데이터 타입들도 존재한다. 빠르게 개발을 진행할 때를 위해 마음놓고 정의할 공간이 필요하다. 타입들을 네임스페이스로 묶어두면 클래스 타입과 네이밍이 겹칠 일이 없으며, 자동완성의 이점도 누릴 수 있다. 

다만, 이러한 공용 공간이 생기는 경우 생각 없이 이 파일에 데이터 타입을 추가하게 될 수 있다. 그 중, 특별한 모듈에만 국한되어 있어야 하는 데이터 타입이 추가될 수도 있는데, 이런 데이터 타입들은 해당 모듈쪽으로 분리시켜주어야 할 것이다.

```xml
namespace EnumTypes
{
	public enum AttackTypes
	{
		None, Melee, Range
	}

	public enum CardRanks
	{
		Normal, Special, Rare
	}

	public enum CardHowToUses
	{
		Normal, TargetGround, TargetEntity
	}

	public enum CardAfterUses
	{
		Discard, Destruct, Spawn
	}

	public enum GameFlowState
	{
		InitGame, SelectStage, Setting, Wave, EventFlow, Ending
	}
}
```

 

 

## **프로젝트의 커스텀 Struct 데이터 타입들을 모아놓을 클래스 파일을 생성한다.**

열거형 타입과 마찬가지의 이유로 구조체 타입들을 모아놓을 공간이 필요하다. 열거형과 마찬가지로 특정 모듈 내에서만 사용되는 데이터 타입은 분리하도록 한다.


```xml
namespace Structs
{
	[Serializable]
	public struct AttackData
	{
		public AttackTypes attackType;
		public int attackAnimationIndex;

		public ScriptableObjects.MeleeTrace meleeTrace;
		public ScriptableObjects.Projectile projectile;
	}

	[Serializable]
	public struct StatModifierData
	{
		public StatTypes statType;
		public ModifierTypes modifierType;
		public float value;
	}

	//..
}
```

 

## **프로젝트의 유틸리티 함수를 모아놓을 클래스를 생성한다.**

언리얼에서 작업을 진행하게 되면, 굉장히 많은 기능들과 방대한 코드 속에서 그때그때 예제를 만들며 많은 시간을 낭비하게 된다. 시간을 좀 더 효율적으로 활용하기 위해 제작해본 예제들을 기능 단위로 유틸리티 함수에 쌓아두어야 할 것이다. 유틸리티 함수는 일반화된 작업들을 수행하는 함수들로, 모두 static함수로 구성되어 있고 클래스 또한 static class로 정의한다. 이렇게 하면 인스턴싱으로 인한 부분은 아예 신경쓸 일이 없을 것이다.

 

```xml
public static class Utils
{
	public static void SetTimeScale(float timescale)
	{
		Time.timeScale = timescale;
		Time.fixedDeltaTime = 0.02f * Time.timeScale;
	}

	public static int GenerateID<T>()
	{
		return GenerateID(typeof(T));
	}
	public static int GenerateID(System.Type type)
	{
		return Animator.StringToHash(type.Name);
	}

	public static float DirectionToAngle(float x, float y)
	{
		float cos = x;
		float sin = y;
		return Mathf.Atan2(sin, cos) * Mathf.Rad2Deg;
	}
    // ..
}
```

 

 

## **프로젝트의 글로벌 변수들을 모아놓을 클래스를 정의한다.**

개발 과정중에는 종종 글로벌 변수를 이용해야 하는 상황이 생긴다. 특히 문자열 같은 경우 여러 클래스에 걸쳐 같은 문자열이 사용된다면 이를 글로벌 변수로 정의하여 공유하도록 하는것이 현명하다. 단, 여기서 말하는 글로벌 변수들은 변하지 않는 변수들을 의미하므로 모두 const와 readonly로 정의한다. (값이 변할 수 있는 글로벌 변수는 되도록이면 이용하지 않도록 한다.) 그리고 클래스는 Utils와 마찬가지의 이유로 클래스와 변수를 static으로 정의한다. 

```xml
public static class Globals
{
	public const int WorldSpaceUISortingOrder = 1;
	public const int CharacterStartSortingOrder = 10;

	public static class LayerName
	{
		public static readonly string Default = "Default";
		public static readonly string UI = "UI";
		public static readonly string Card = "Card";
		public static readonly string Obstacle = "Obstacle";
	}
    
    // ..
}
```

 


## **생성될 객체들을 관리할 관리자 클래스를 정의한다.**

게임 내에 정의될 모든 객체들을 Child로 갖는 하나의 관리자 클래스를 정의한다. 만약 관리자 클래스가 여러 개가 정의되어야 한다면 꼭대기의 가장 핵심적인 관리자 클래스를 두고 그 Child로 파생 관리자 객체들을 두면 된다. 아래 예제는 가장 꼭대기에 GameManager 클래스가 하위 관리자로 CharacterManager, UIManager, CameraController, MapManager, EffectManager를 갖는 형태로 설계되어 있다. 이렇게 설계를 해 두고 GameManager에 대한 역참조만 정의해둔다면, 모든 클래스가 다른 모든 클래스에 접근할 수 있게 된다. 이 클래스는 Scene의 가장 루트 GameObject로 단 하나만 미리 인스턴싱 해두도록 한다.

```xml
public class GameManager : MonoBehaviour, IGameManager
{
	[SerializeField]
	private CharacterManager _characterManager;

	[SerializeField]
	private UIManager _uiManager;

	[SerializeField]
	private CameraController _cameraController;

	[SerializeField]
	private MapManager _mapManager;

	[SerializeField]
	private EffectManager _effectManager;
    
    // ..
}
```


GameManager의 하위 관리자는 GameManager로의 역참조를 갖도록 한다.

```xml
public class CharacterManager : MonoBehaviour
{
	private IGameManager _gameManager;
	private List<BaseCharacter> _guardians = new List<BaseCharacter>();
    
	public IGameManager GameManager
	{
		get { return _gameManager; }
	}
	
	public void Init(IGameManager gameManager)
	{
		_gameManager = gameManager;
	}
	// ..
}
```


CharacterManager의 하위 객체는 CharacterManager로의 역참조를 갖는다. 이렇게 되면 모든 객체는 다른 모든 객체를 참조해올 수 있다.

```xml
public class BaseCharacter : MonoBehaviour
{
	protected CharacterManager _manager;
	public void Init(CharacterManager manager)
	{
		_manager = manager;
	}
}
```


시니어 개발자 중에는 관리자 클래스에 대해 부정적인 의견을 갖는 경우가 많다. 하지만 개인적인 경험으로는 관리자 클래스를 이용하는 것이 가성비가 더 좋다. 물론 프레임워크의 크기가 거대하고 객체들의 종류와 종속성이 복잡하다면 좀 다른 방법을 써야겠지만, 유니티를 이용하는 정도 사이즈의 게임들은 매니저 클래스를 이용하는 정도로 충분하다. 만약 충분하지 않더라도 중간에 리펙토링을 하면 되고, 초반부터 오버 아키텍쳐링을 하는것이 더 비효율적이라 본다. 빠르고 직관적이게 개발을 하기 위해 이런 트리 형태의 참조, 역참조 관계를 만들어 두고 추후에 차근차근 리펙토링을 하면서 종속성을 제거해 나가는 것이 효과적이다.
\+ 혹시라도 이보다 더 견고한 구조를 원한다면 언리얼의 GameInstance-Subsystem 구조를 참고해도 좋다.
\+ 만약 이걸로도 만족이 안된다면 Dependency Injection 프레임워크(Zenject, VContainer)를 이용해보자.


## **Scene 전환에 걸쳐서도 GameObject를 갖으며 존재하는 단 하나의 객체를 정의하여, Scene 전환에 걸쳐서도 유지되어야 하는 데이터들을 관리하도록 한다.**

위에서 언급한 GameManager의 경우 Scene의 루트 오브젝트로서 존재한다. 즉, Scene이 변경되면 파괴되는 객체이다. 하지만 게임개발을 진행하다 보면 Scene의 변경과 상관없이 관리되어야 하는 객체들과 데이터들이 존재한다. 예를 들면 서버로부터 받은 계정 정보를 저장한다거나, 게임의 Scene 전환 후에도 이전 데이터를 참조해야하는 경우 등이 있을 것이다. 이를 위해 MonoBehaviour를 포함하는 싱글턴 오브젝트를 정의하도록 한다. 추가적으로 관리되어야 하는 객체들이 있다면 이 객체의 하위로 보내면 되므로 싱글턴 객체는 하나 이상은 필요 없다. 


```xml
public class GameInstance : Singleton<GameInstance>
{
	private LogGUI _logGUI;
	private DebugStatGUI _debugStatGUI;

	private ScriptableObjects.GamePrefabs _gamePrefabs;

	private HttpManager _httpManager;
    
    // ..
}
```

 

```xml
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Singleton<T> : MonoBehaviour where T : Component
{
	private static T instance;

	public static T Instance
	{
		get
		{
			if (instance == null)
			{
				instance = FindObjectOfType<T>();
				if (instance == null)
				{
					GameObject obj = new GameObject();
					obj.name = typeof(T).Name;
					instance = obj.AddComponent<T>();
				}
			}
			return instance;
		}
	}

	protected virtual void Awake()
	{
		if (instance == null)
		{
			instance = this as T;
			DontDestroyOnLoad(gameObject);
		}
		else
		{
			Destroy(gameObject);
		}
	}
}
```


싱글턴 객체에 대해서도 부정적인 의견이 많다. 하지만 제대로 관리를 해줄 수 있다면 싱글턴 객체를 이용함으로써 얻는 이점이 더 많다. 싱글턴의 단점을 알아보자.

### **1. 전역 변수로서의 문제**



전역 변수가 갖는 문제는 자명하다. 변수를 어디에서나 접근할 수 있기 때문에 모든 영역에 걸쳐서 코드가 변경될 수 있는 가능성이 생긴다. 그러므로 변수에 이상한 값이 들어가 있을 때 이 변수를 사용하는 모든 부분들을 의심해봐야 한다. 하지만 이 문제는 전역변수의 값이 수정 불가능하다면 애초에 발생하지 않을 문제이다. 싱글턴 객체 내부의 리소스들은 마음껏 Read 가능하도록 하되, Write에 대해서는 철저하게 관리하도록 설계한다면 이 문제는 해결될 수 있다. 특히 GamePrefabs와 같은 객체는 게임 내 대부분의 리소스를 참조할 수 있는 통로인데, 어차피 이 객체의 프로퍼티는 에디터에서만 변경되면 충분하기 때문에 모든 하위 객체를 포함하여 property로 set을 막아두도록 한다. 
하지만, HttpManager와 같이 내부 변수들이 변하는 객체들도 분명 존재할 것이다. 이런 객체들의 값 변경은 최대한 이벤트를 이용해 내부적으로 처리하도록 하고, 외부에서 값을 변경시키는 상황은 철저하게 관리해야 할 것이다.

### **2. 코드 결합도(Coupling) 문제**

모든 기능을 싱글턴 객체로 만들고 사방에서 싱글턴 객체를 호출하는 형태로 코드를 작성하면 프레임워크의 규모가 커질 때 관리가 불가능해질 것이다. 현재 코드로 이 상황을 완전히 피할 수는 없다. 하지만 최소화시킬 방법은 있는데, 싱글턴 객체를 딱 하나만 정의하고 그 외의 모든 싱글턴으로서 이용하고 싶은 객체들을 하위 객체로 넣는 것이다. 이렇게 설계하면 최소 싱글턴의 상호참조로 인한 커플링은 막을 수 있다. 그리고 개인적으로는 이 정도 구조로도 웬만한 게임을 개발하기에는 충분하다.

이 논쟁에 대해서도, 위의 관리자 객체를 이용하는 상황과 마찬가지로 더 일반화된 구조를 원한다면 언리얼 엔진의 GameInstance와 SubSystem이나 Dependency Injection 프레임워크를 이용하여 해결할 수 있다. 결국 이런 설계적인 논쟁에는 끝이 없다. 프로젝트 사이즈에 맞게 최소의 자원으로 최대의 효율을 낼 수 있는 적절한 타협점을 찾는것이 중요하다. (항상 프로젝트의 완성이 최우선 목표가 되어야한다.)


### **3. 단일 책임 원칙 위배**

하나의 객체는 하나의 책임을 담당하며, 그 책임을 완전히 캡슐화해야한다는 원칙이다. 현재 단 하나의 싱글턴 객체를 정의했기 때문에, 이 객체가 많은 책임을 갖게 될 수 있다. 그러므로 새로운 책임이 생길 때마다 새로운 하위 객체를 갖는 형태로 구성하도록 한다. 위에 예제로 보면 GamePrefabs 객체를 통해 리소스 참조의 책임을 넘겼고, HttpManager 객체를 통해 REST API 네트워킹에 대한 책임을 넘겼다. 이처럼 싱글턴을 이용하더라도 단일 책임 원칙을 위배하지 않도록 설계할 방법은 있다.


### **4. 초기화와 소멸 타이밍을 잡기 어려운 문제**

서버개발자들이 싱글턴 객체를 싫어하는 이유 중 하나는 멀티스레드 환경에서 공유자원의 영역이 커진다는 것이고, 다른 하나는 초기화와 소멸 타이밍을 잡기 어렵다는 것이다. 먼저 유니티의 게임 루프는 싱글 스레드 기반이기 때문에 첫번째 문제는 배제할 수 있다. 그렇다면 초기화와 소멸 타이밍은 어떻게 잡을 수 있을까? 유니티 엔진이 제공하는 기능들을 활용하면 된다. 다음 함수를 GameInstance 객체에 넣어서 초기화 타이밍을 잡기 위해 활용한다.

```xml
// 어떤 Scene이 시작되기 전 호출
[RuntimeInitializeOnLoadMethod]
static void OnBeforeSceneLoadRuntimeMethod()
{
	// 초기화가 필요한 경우 여기서 싱글턴을 초기화한다.
    // GameInstance.Instance.Init();
}
```



다음으로 소멸 타이밍은 어떻게 잡아야할까? 결론부터 말하자면 이 부분은 아직 완벽하게 해결할 방법을 찾지 못했다. 사용자가 프로그램을 언제 종료시킬지 모르기 때문에 명시적인 타이밍을 잡기 어렵다. 유니티에서는 OnApplicationQuit 이라는 이벤트가 있는데, 딱 봤을 때 앱이 종료될 때 호출될 것 같지만 공식 문서에서는 항상 호출됨을 보장하지 않는다고 한다. 다행히도 대체할 이벤트가 있다. OnApplicationPause을 이용하면 된다. OnApplicationPause (bool) 이벤트의 경우 모바일에서 창이 전환될 때 바로 호출되기 때문에 종료되기 전에 반드시 호출됨을 보장할 수 있다. 다만 창만 내렸다가 다시 돌아오는 경우가 있기 때문에 bool 인자를 통해 창이 내려가면서 발생된 이벤트인지 창이 올라오면서 발생한 이벤트인지 구분해야한다. 그리고 소멸 메커니즘을 만들었다면 회복 메커니즘도 만들어줘야할 것이다. 다만 모든 상황에 대한 회복 메커니즘을 만드는 작업과, 창을 내렸다가 올릴때마다 다시 로딩하는것이 사용자에게 좋은 경험일지는 모르므로 완벽한 해결방법이라고 하기는 어려울 수 있다.


```xml
private void OnApplicationPause(bool pause)
{
	Debug.LogError($"GameInstance OnApplicationPause {pause}");
}
```
