# 🍸 칵테일러 🍹

> 칵테일러 FE repository

---

## 📋 목차

- [기술 스택](#-기술-스택)
- [팀원 역할 분담](#-팀원-역할-분담)
- [시작하기](#-시작하기)
- [폴더 구조](#-폴더-구조)
- [브랜치 전략](#-브랜치-전략)
- [커밋 컨벤션](#-커밋-컨벤션)
- [협업 규칙](#-협업-규칙)

---

## 🛠 기술 스택

| 항목 | 내용 |
|------|------|
| Framework | Flutter |
| Language | Dart |
| 버전관리 | Git / GitHub |

---

## 👥 팀원 역할 분담

각 스프린트 별 역할배분 예정, 추후 일정은 디스코드 참고

> 각자 담당 브랜치에서 작업 후 PR을 통해 `develop` 브랜치에 병합합니다. ex) featute/login ... 등

---

## 🏁 시작하기

### 사전 요구사항

- Flutter SDK 설치 완료
- Android Studio 또는 VS Code 설치
- Git 설치

### 1. 레포지토리 클론

```bash
git clone https://github.com/e2pi3/CAU-SWE-FE.git
cd CAU-SWE-FE
```
clone 한 파일로 이동

### 2. 패키지 설치

```bash
flutter pub get
```

### 3. 환경 설정

> `.env` 파일이나 별도 설정이 필요한 경우 아래 내용을 따라주세요.

```bash
# 예시: .env 파일 생성 (팀장에게 내용 문의)
cp .env.example .env
```

### 4. 앱 실행

```bash
# 연결된 디바이스 확인
flutter devices

# 앱 실행
flutter run
```

### 5. 내 브랜치로 이동 후 작업 시작

```bash
# develop 브랜치 최신화 (main이 아닌 develop에서 pull 해주세요)
git checkout develop
git pull origin develop

# 내 브랜치로 이동 (없으면 생성)
git checkout -b feature/my-part
```

---

## 📁 폴더 구조

```
lib/
├── main.dart              # 앱 진입점
├── screens/               # 각 화면 (담당자별 작업)
│   ├── home/
│   ├── login/
│   ├── mypage/
│   └── ...
├── widgets/               # 공통 재사용 위젯
├── models/                # 데이터 모델
├── services/              # API 통신 로직
└── utils/                 # 유틸 함수, 상수
```

> **규칙**: 내 담당 화면은 `screens/` 아래 폴더를 만들어 작업하고, 공통으로 쓰이는 위젯은 `widgets/`에 추가 후 팀원에게 공유해주세요.

---

## 🌿 브랜치 전략

```
main         ← 최종 배포용 (직접 push 금지)
  └── develop    ← 통합 개발 브랜치 (PR로만 병합)
        ├── feature/login
        ├── feature/home
        ├── feature/api
        └── feature/mypage
```

### 브랜치 생성 규칙

```bash
feature/기능명       # 새 기능 개발
fix/버그명           # 버그 수정
hotfix/긴급수정명    # 긴급 패치
```

---

## 💬 커밋 컨벤션

```
feat     : 새로운 기능 추가
fix      : 버그 수정
style    : 코드 포맷, UI 스타일 변경
refactor : 코드 리팩토링
chore    : 패키지 설치, 설정 변경
docs     : 문서 수정
```

### 커밋 예시

```bash
git commit -m "feat: 로그인 화면 UI 구현"
git commit -m "fix: 홈 화면 스크롤 오류 수정"
git commit -m "chore: http 패키지 추가"
```

---

## 🤝 협업 규칙

1. **직접 push 금지** `main`, `develop` 브랜치에는 절대 직접 push하지 않습니다.
2. **PR 필수** 작업 완료 후 반드시 Pull Request를 올리고, 팀원 1명 이상의 리뷰를 받아야 합니다.
3. **충돌 방지** 작업 시작 전 항상 `develop` 브랜치를 pull 받아 최신 상태를 유지합니다.
4. **pubspec.yaml 수정 시** 패키지를 추가/변경했다면 팀 채팅방에 꼭 공유해주세요.
5. **공통 파일 수정 시** `main.dart`, `pubspec.yaml` 등 공통 파일은 수정 전 팀원과 먼저 상의합니다.


---

## 기타 질문

문제가 생기면 팀 단톡방에 올려주세요
