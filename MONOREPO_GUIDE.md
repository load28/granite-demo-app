# Granite 모노레포 가이드

하나의 iOS 앱에서 여러 Granite React Native 앱을 브라운필드 방식으로 통합하는 모노레포 구조입니다.

## 📁 프로젝트 구조

```
granite-monorepo/
├── ios/                        # iOS 네이티브 프로젝트
│   ├── ios.xcodeproj/
│   ├── ios/
│   │   ├── GraniteModuleManager.swift  # 여러 RN 모듈 관리
│   │   └── ContentView.swift          # 메인 UI
│   ├── Podfile                        # 통합 Podfile
│   └── bundles/                       # 프로덕션 번들 저장소
├── packages/                          # Granite RN 앱들
│   ├── home/                         # 홈 화면 RN 앱
│   ├── login/                        # 로그인 화면 RN 앱
│   └── profile/                      # 프로필 화면 RN 앱
├── shared/                           # 공통 코드
│   ├── components/                   # 공통 컴포넌트
│   ├── utils/                        # 공통 유틸리티
│   └── types/                        # 공통 타입 정의
├── scripts/                          # 빌드/개발 스크립트
│   ├── dev-start.sh                  # 개발 서버 시작
│   └── build-all.sh                  # 전체 빌드
└── package.json                      # Yarn workspaces 설정
```

## 🚀 시작하기

### 1. 의존성 설치

```bash
yarn install
```

### 2. iOS Pods 설치

```bash
yarn ios:pods
```

### 3. 개발 서버 시작

```bash
# 모든 앱의 개발 서버를 동시에 시작
yarn dev

# 개별 앱 개발 서버 시작
yarn dev:home     # http://localhost:8081
yarn dev:login    # http://localhost:8082
yarn dev:profile  # http://localhost:8083
```

### 4. iOS 앱 실행

1. Xcode에서 `ios/ios.xcworkspace` 열기
2. 프로젝트 빌드 및 실행
3. 각 Granite 모듈 테스트

## 📱 사용 방법

### iOS에서 RN 모듈 호출

```swift
// 네비게이션으로 푸시
viewController.pushGraniteModule(.home, initialProperties: [
    "userId": "123",
    "source": "native"
])

// 모달로 표시
viewController.presentGraniteModule(.login, initialProperties: [
    "returnUrl": "home"
])
```

### React Native에서 네이티브 데이터 받기

```typescript
// Granite 앱에서 초기 props 사용
export default function App({ userId, source, module }: Props) {
    console.log(`User: ${userId}, Source: ${source}, Module: ${module}`);
    
    return (
        <View>
            <Text>Hello from {module}!</Text>
        </View>
    );
}
```

## 🔧 개발 명령어

```bash
# 개발
yarn dev                    # 모든 앱 개발 서버 시작
yarn dev:home              # Home 앱만 개발 서버 시작
yarn dev:login             # Login 앱만 개발 서버 시작
yarn dev:profile           # Profile 앱만 개발 서버 시작

# 빌드
yarn build                 # 모든 앱 프로덕션 빌드
yarn build:home           # Home 앱만 빌드
yarn build:login          # Login 앱만 빌드
yarn build:profile        # Profile 앱만 빌드

# 테스트 및 검사
yarn test                 # 모든 앱 테스트 실행
yarn typecheck           # TypeScript 타입 검사
yarn lint                # ESLint 실행

# 정리
yarn clean               # 모든 node_modules, dist 정리
```

## 🏗️ 아키텍처 설명

### GraniteModuleManager

- **역할**: 여러 RN 모듈의 라이프사이클 관리
- **기능**:
  - 각 모듈별 독립적인 RCTBridge 관리
  - 메모리 효율적인 모듈 로드/언로드
  - 개발/프로덕션 환경별 번들 로딩

### 브라운필드 통합

1. **독립적인 앱들**: 각 RN 앱은 완전히 독립적으로 개발
2. **공통 의존성**: React Native, Granite 등은 루트에서 공유
3. **네이티브 통합**: iOS에서 필요에 따라 각 RN 화면 로드
4. **상태 격리**: 각 RN 앱은 독립적인 상태 관리

## 🔄 워크플로우

### 개발 워크플로우

1. **개별 개발**: 각 팀이 `packages/` 하위에서 독립 개발
2. **공통 컴포넌트**: `shared/` 에서 공통 코드 관리
3. **통합 테스트**: iOS 앱에서 모든 모듈 통합 테스트
4. **배포**: 각 모듈별 독립 배포 가능

### 추가 모듈 생성

```bash
# 새 Granite 앱 생성
mkdir packages/new-module
cd packages/new-module

# package.json 복사 및 수정
cp ../home/package.json .
# name을 "new-module"로 변경

# 필요한 파일들 복사
cp -r ../home/{src,pages,*.ts,*.js,*.json} .

# GraniteModuleManager.swift에 새 모듈 추가
# enum GraniteModule에 case 추가
```

## 🚨 주의사항

1. **포트 충돌**: 개발 시 각 앱마다 다른 포트 사용
2. **번들 이름**: 각 모듈의 번들 이름은 고유해야 함
3. **메모리 관리**: 사용하지 않는 모듈은 `destroyModule()` 호출
4. **의존성 호이스팅**: 공통 의존성은 루트 레벨에서 관리

## 📚 참고 자료

- [Granite 공식 문서](https://www.granite.run/)
- [React Native Brownfield Integration](https://reactnative.dev/docs/integration-with-existing-apps)
- [Yarn Workspaces](https://yarnpkg.com/features/workspaces)