# [Source Control Workflows in Xcode](https://developer.apple.com/videos/play/wwdc2018/418/)

## Source Control을 사용하여 Github에 Repository 만드는 법
### 0. 커밋 작성자 설정하기
- Xcode에서 로그를 확인할 때, 작성자 명을 변경하고 싶으면 다음 과정을 수행합니다.
- `Xcode -> Settings -> Source Control -> Git` 로 이동합니다.
- 이름과 이메일을 입력해 주세요.

<img src="https://i.imgur.com/hcPHOn9.png" width="400" height="250"/>

### 1. git 계정과 연결하기
- `Xcode -> Settings -> Accounts` 로 이동합니다.
- 왼쪽 하단에 `+` 버튼을 누른 후, `GitHub`를 선택해 주세요.

<img src="https://i.imgur.com/0Um3BZA.png" width="400" height="250"/>

### 2. 프로젝트 만들기
- 프로젝트 저장 시, Source Control을 체크해주면 자동으로 `.Git`폴더가 생성 됩니다.
- 터미널에서 `git init` 명령어를 입력하는 것과 동일한 작업입니다.

<img src="https://i.imgur.com/9JWWiSk.png" width="400" height="300"/>

### 3. remote Repository 만들기
- `Source Control Navigator -> Repositories -> Remotes` 마우스 우클릭을 해주세요.
- `New [프로젝트명] Remote...` 선택해주세요.

<img src="https://i.imgur.com/wlDVoAi.png" width="400" height="300"/>

### 4. remote Repository 설정하기
- Repository 이름 및 Visibility 등을 설정 후 `Create` 버튼을 눌러 주세요.

<img src="https://i.imgur.com/b2NkeFp.png" width="400" height="300"/>

### 5. GitHub에서 확인하기
- GitHub에서 새로 Repository를 만들지 않아도 생성된 것을 확인할 수 있습니다.

<img src="https://i.imgur.com/BkftTZj.png" width="400" height="130"/>

<br>
<br>

## Source Control을 사용하여 Commit 하는 법

### 1. `Commit` 클릭하기
- `Source Control -> Commit` 을 클릭합니다.

<img src="https://i.imgur.com/Sw7besl.png" width="600" height="180"/>

### 2. Commit 내역 확인하기
- `Commit`을 누르면 현재 프로젝트의 모든 변경 사항이 표시됩니다.
- 커밋 시트는 변경전과 후를 나란히 비교하여 보여줍니다.
- 커밋 시트 왼쪽 메뉴에서 커밋에 포함할 파일을 선택할 수 있습니다.
- 커밋 시트 가운데에서 커밋에 특정 변경 사항을 선택할 수 있습니다.

<img src="https://i.imgur.com/UDkFX39.png" width="600" height="180"/>

### 3. Commit 메세지 입력 후 Commit 하기
- 적절한 변경 사항을 선택 후, 아래 창에 커밋 메세지를 입력합니다.
- 줄바꿈을 통해 커밋 타이틀과 커밋 바디를 구분 지을 수 있습니다.
- `Push to remote`를 체크하면 commit과 push를 동시에 할 수 있습니다.
- `Amend commit`을 체크하면 commit했던 내용을 수정할 수 있습니다.
단, push를 한 commit은 수정할 수 없습니다.
- 파란색 `Commit ...` 버튼을 누르면 Commit이 완료 됩니다.

<img src="https://i.imgur.com/M0NEQ5R.png" width="600" height="150"/>

<br>
<br>

## Source Control을 사용하여 Push 하는 법

### 1. `Push` 클릭하기
- `Source Control -> Push`를 클릭합니다.

<img src="https://i.imgur.com/9uDBc0U.png" width="600" height="300"/>

### 2. 브랜치 선택 후`Push` 클릭하기
- push할 브랜치를 선택 후 `Push`를 클릭합니다.

<img src="https://i.imgur.com/G2r8EMR.png" width="400" height="150"/>

<br>
<br>

## Source Control을 사용하여 Pull 하는 법
### 1. `Pull` 클릭하기
- `Source Control -> Pull`을 클릭합니다.

<img src="https://i.imgur.com/J7twjzM.png" width="600" height="300"/>

### 2. 충돌 해결하기
- Pull을 할 때, 가져오는 코드와 현재 코드 사이에 충돌이 발생할 수 있습니다.
- 커밋 시트와 유사한 시트로 충돌을 해결할 수 있습니다.

<img src="https://i.imgur.com/pUQxWiW.jpg" width="600" height="250"/>


<br>
<br>

## Github에 있는 Repository Clone 하는 법
### 1. `Clone` 클릭하기
- `Source Control -> Clone` 을 클릭합니다.

<img src="https://i.imgur.com/1lwLEF9.png" width="400" height="250"/>

### 2. Clone할 Repository 선택하기
- `Clone`을 누르면 나의 Repository 목록이 뜹니다.
- 만약 다른 사람의 레포지토리를 가져오고 싶다면, 상단에 검색 필드에 레포지토리명이나 URL을 입력해 주세요.
- Repository 선택이 끝났다면, 오른쪽 하단에 `Clone` 버튼을 클릭합니다.

<img src="https://i.imgur.com/4h8NtLa.png" width="400" height="200"/>

<br>
<br>

## Xcode의 다양한 기능 
### 1. 코드 변경 사항 확인
- 코드가 변경되면 변경 막대가 생성됩니다.
- 또한 해당 코드의 파일이 변경되었다는 상태 플래그가 생성됩니다.

<img src="https://i.imgur.com/BbqP9IK.png" width="400" height="150"/>


### 2. 편집기 모드
- Xcode에서 편집기 모드를 선택한 동안 하단의 이동 막대를 사용하여 보고 있는 파일의 버전을 변경할 수 있습니다.
- 하단의 이동 막대를 클릭하면 작성자,커밋 날짜, 커밋 메세지를 확인할 수 있습니다.
- 파일 버전을 변경하면, 선택한 버전과 현재 상태를 비교하여 보여줍니다.
<img src="https://i.imgur.com/l0UvKqU.png" width="600" height="250"/>


### 3. Source Control Navigator
- `Source Control Navigator`에서 브랜치 별로 로그를 확인할 수 있습니다. 
- `Tags`를 등록해놨다면 Tag 별로도 확인할 수 있습니다.
<img src="https://i.imgur.com/Jp3eqAv.png" width="600" height="250"/>

### 4. Source Control
- `Xcode -> Settings -> Source Control -> General` 에서 여러 설정을 선택할 수 있습니다.
<img src="https://i.imgur.com/IAPzazZ.png" width="400" height="250"/>

