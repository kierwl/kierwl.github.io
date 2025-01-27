---
layout: single
comments: true
title: "본캠프 4일차 TIL "
categories: TIL



---

### 📆 오늘의 TIL (Today I Learned)

---

## 비동기 씬 전환

유니티에서 사용되는 대표적인 씬 전환 방법으로 유니티에서 지원하는 UnityEngine.SceneManagement에 포함되어있는 SceneManager.LoadScene을 사용한다.

이 경우 로딩해야되는 씬의 데이터가 많거나 하면, 씬 전환 간에 있어 플레이어는 멈춘 화면에서 긴시간 대기를 해야 할 것이다. 비 동기 씬 전환은 동기화가 되지 않은 채로 씬을 전환하는 것이다.



스크립트는 보통 Awake-> Start-> Update 순으로 작동된다. 이를 라이프 사이클이라고 하고 모든 객체는 라이프 사이클을 따른다.

유니티에서 테스트를 하기위해 플레이버튼을 누르면 라이프사이클을 따라 실행되게 된다.

이렇게 모두 순차적으로 실행되는 것을 동기화 된다고 하고

1>2>3>4



비동기화는 

1>2--3-->4 이런식으로 2번과 3번이 거의 동시에 진행된다.

다음 씬을 위한 데이터를 호출하기 위함이나, 비동기적으로 이루어 져야한다면 꼭 필요한 기술이된다.



비동기 씬 호출은  LoadSceneAsync를 사용 하는 것으로 아주 간단히 작동 할 수 있다. 



```
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LoadSceneManager : MonoBehaviour
{
    public void LoadScene(string name){
        SceneManager.LoadSceneAsync(name);
    }
}
```

잊지말고 build setting에서 씬을 추가하고 버튼을 다른 씬에 생성해 씬을 이동해보면 매우 빠르게 이동 된것을 확인 할 수 있다.

```
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LoadSceneManager : MonoBehaviour
{
    float time = 0;
    public void LoadScene(string name){
        StartCoroutine(LoadingAsync(name));
    }

    IEnumerator LoadingAsync(string name){
        AsyncOperation asyncOperation = SceneManager.LoadSceneAsync(name);
        asyncOperation.allowSceneActivation = false; //로딩이 완료되는대로 씬을 활성화할것인지
        
        while(!asyncOperation.isDone){ //isDone는 로딩이 완료되었는지 확인하는 변수
            time += Time.deltaTime; //시간을 더해줌
            print(asyncOperation.progress); //로딩이 얼마나 완료되었는지 0~1의 값으로 보여줌
            
            // 무거운 씬 로딩할땐 시간 체크
            //생략가능
            if(time > 3){ //3초 기다림(변동가능)
                asyncOperation.allowSceneActivation = true; //씬 활성화
            }
            yield return null;
        }
    }
}
```

비동기로 작동하는 코드는 코루틴을 사용한다.

allowSceneActivation - 씬 로딩 완료시 화면전환 여부 (true면 즉시전환)

isDone - 씬 전환 완료여부

progress 만 float 타입이고 나머지 둘은 bool타입이다.



이를 사용해 미니프로젝트에 사용되는 씬을 전환하려고 해보았다.

시작 > 로딩 > 메인 순으로 씬이 이동된다.



그런데 여기서 문제가 발생했다. 비동기로 작동하는 씬 전환에서 버튼이 작동하지 않게 되었다.

정확하게는 버튼이 아닌 버튼을 누름으로써 호출되는 스크립트 자체가 먹통이 되버렸다.

스크립트에 디버깅로그를 출력해 보지만 디버깅은 잘되는 기이한 현상이 생기게 된 것이다.



이런 저런 문제와 시행착오를 해보며 비동기로 씬을 로드하는 경우 일부 스크립트가 작동하지 않는 에러가 발생한다는 글을 찾게 되었다.  해당 글과 다르게 나는 모든 해결방법을 동원해 봐도 문제점을 찾을 수 없어 결국 비동기 씬 전환은 포기 하게 되었다. 간편하지만 리스크도 큰 방법을 오늘 하나 배워간다.

