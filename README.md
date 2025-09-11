# Granite 모노레포 프로젝트

하나의 iOS 앱에서 여러 Granite React Native 앱을 브라운필드 방식으로 통합하는 모노레포입니다.

## 📁 프로젝트 구조

```
granite-monorepo/
├── ios/                    # iOS 네이티브 프로젝트
├── packages/               # Granite RN 앱들
│   ├── home/              # 홈 화면 RN 앱
│   ├── login/             # 로그인 화면 RN 앱
│   └── profile/           # 프로필 화면 RN 앱
├── shared/                # 공통 코드 (컴포넌트, 유틸, 타입)
├── scripts/               # 빌드/개발 스크립트
├── docs/                  # 프로젝트 문서들
└── MONOREPO_GUIDE.md      # 상세 사용 가이드
```

## 🚀 빠른 시작

```bash
# 의존성 설치
yarn install

# iOS Pods 설치  
yarn ios:pods

# 모든 앱 개발 서버 시작
yarn dev

# iOS 앱에서 각 RN 모듈 테스트
# Xcode에서 ios/ios.xcworkspace 열기
```

## 📱 지원 모듈

- **Home**: 메인 기능들 (포트 8081)
- **Login**: 로그인 관련 기능들 (포트 8082)  
- **Profile**: 프로필 관련 기능들 (포트 8083)

## 📚 문서

자세한 사용법은 [MONOREPO_GUIDE.md](./MONOREPO_GUIDE.md)를 참고하세요.
