---
layout: single
comments: true
title: "본캠프 1일차 TIL "
categories: TIL
tags: [C#,Unity,#sparta]

---

### 📆 오늘의 TIL (Today I Learned)

------

## Git hub, VSC 환경 구성하기



- `Github`를 협업에 사용하기

1. 팀장이 하나의 공용 `Upstream(원본) repositories(폴더(?))` 를 만들고 팀원들을 초대한다.
2. 팀원들은 초대받은 `깃 주소`를 복사해 `pull`받는다.
3. 팀원들은 미리 역할분담하여 자신이 맡은 부분의 파일들을 코딩+수정한다.
4. 작업이 끝나면 (보통 1일 1회의 1머지 여러 커밋) 팀원들은 `git add > commit > push`를 한다.
5. 자신의 깃허브에 들어가서 팀공용 repository 폴더를 선택하고 들어가서 자신이 push 한 내역을 확인하고, 충돌이 일어난 부분이 있는지 확인한다.
6. 충돌이 일어나지 않았다면 바로 `Create pull request` - `merge`를 하여 팀 공용 repository에 merge시켜주고,
   충돌이 일어났다면 다시 충돌이 일어난 부분을 수정한 뒤 최종 `push`후 `merge`까지 하면 된다.

// 어렵지만 아무튼 해결했다.
