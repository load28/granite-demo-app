# Granite.js iOS 네이티브 앱 연동 아키텍처 가이드

## 목차
1. [전체 아키텍처 개요](#1-전체-아키텍처-개요)
2. [핵심 기술 구성 요소](#2-핵심-기술-구성-요소)
3. [코드별 상세 분석](#3-코드별-상세-분석)
4. [데이터 플로우 및 생명주기](#4-데이터-플로우-및-생명주기)
5. [주요 개념 용어집](#5-주요-개념-용어집)

---

## 1. 전체 아키텍처 개요

### 1.1 브라운필드 방식 연동 구조

Granite.js는 **브라운필드(Brownfield)** 방식으로 iOS 네이티브 앱에 연동됩니다. 이는 기존 네이티브 앱 내에서 특정 화면이나 기능만을 React Native로 구현하여 임베딩하는 방식입니다.

```
┌─────────────────────────────────────┐
│           iOS Native App            │
│  ┌─────────────────────────────────┐ │
│  │         SwiftUI Views           │ │
│  │  ┌─────────────────────────────┐│ │
│  │  │      GraniteManager         ││ │
│  │  │  ┌─────────────────────────┐││ │
│  │  │  │   RCTRootView          │││ │
│  │  │  │  ┌─────────────────────┤││ │
│  │  │  │  │   React Native     │││ │
│  │  │  │  │   Granite.js App   │││ │
│  │  │  │  └─────────────────────┘││ │
│  │  │  └─────────────────────────┘│ │
│  │  └─────────────────────────────┘│ │
│  └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 1.2 주요 컴포넌트와 책임

| 컴포넌트 | 역할 | 위치 |
|---------|------|------|
| **GraniteManager** | Granite 앱의 생명주기 관리 | `ios/ios/GraniteManager.swift` |
| **GraniteViewController** | React Native 뷰 컨테이너 | `ios/ios/GraniteViewController.swift` |
| **GraniteModule** | 네이티브-JS 브릿지 모듈 | `ios/ios/GraniteModule.swift` |
| **RCTRootView** | React Native 앱 렌더링 뷰 | React Native 내장 |
| **RCTBridge** | JavaScript-네이티브 통신 브릿지 | React Native 내장 |

---

## 2. 핵심 기술 구성 요소

### 2.1 RCTRootView란?

**RCTRootView**는 React Native에서 제공하는 iOS 네이티브 뷰입니다. JavaScript로 작성된 React Native 앱을 iOS 네이티브 앱 내에서 렌더링할 수 있게 해주는 핵심 컨테이너입니다.

```swift
// GraniteViewController.swift:105-109
let rootView = RCTRootView(
    bridge: bridge,              // JavaScript와 네이티브 간 통신 브릿지
    moduleName: appName,         // 등록된 React Native 앱 이름 ("rn")
    initialProperties: initialProps  // 초기 props 데이터
)
```

#### RCTRootView의 주요 특징:
- **브릿지 연결**: RCTBridge를 통해 JavaScript 엔진과 연결
- **모듈 식별**: `moduleName`으로 특정 React Native 앱 컴포넌트를 지정
- **데이터 전달**: `initialProperties`를 통해 네이티브에서 JavaScript로 데이터 전달

### 2.2 RCTBridge란?

**RCTBridge**는 React Native의 핵심 통신 메커니즘입니다. JavaScript 코드와 네이티브 코드 간의 양방향 통신을 담당합니다.

```swift
// GraniteManager.swift:49
bridge = RCTBridge(bundleURL: jsCodeLocation, moduleProvider: nil, launchOptions: nil)
```

#### RCTBridge의 역할:
1. **JavaScript 번들 로딩**: Metro bundler 또는 번들된 JS 파일 로드
2. **모듈 등록**: 네이티브 모듈을 JavaScript에서 사용 가능하도록 등록
3. **메시지 전달**: JavaScript ↔ 네이티브 간 함수 호출 및 데이터 전달

### 2.3 브릿징 헤더 (Bridging Header)

Swift와 Objective-C, 그리고 React Native 간의 상호운용성을 위한 헤더 파일입니다.

```h
// ios-Bridging-Header.h
#import <React/RCTBridgeModule.h>    // 브릿지 모듈 인터페이스
#import <React/RCTBridge.h>          // 브릿지 핵심 기능
#import <React/RCTRootView.h>        // RootView 클래스
#import <React/RCTBundleURLProvider.h> // JS 번들 URL 제공
```

### 2.4 TurboModule 패턴

현대적인 React Native에서 사용하는 네이티브 모듈 구현 방식입니다.

```swift
// GraniteModule.swift:11-12
@objc(GraniteModule)
class GraniteModule: NSObject, RCTBridgeModule
```

```objc
// GraniteModule.m:11-15
@interface RCT_EXTERN_MODULE(GraniteModule, NSObject)
RCT_EXTERN_METHOD(closeView)
RCT_EXTERN__BLOCKING_SYNCHRONOUS_METHOD(schemeUri)
RCT_EXTERN_METHOD(setScheme:(NSString *)scheme)
```

---

## 3. 코드별 상세 분석

### 3.1 iOS 네이티브 레이어

#### 3.1.1 GraniteManager (싱글톤 매니저)

```swift
class GraniteManager: NSObject {
    static let shared = GraniteManager()    // 싱글톤 인스턴스
    
    private var bridge: RCTBridge?          // React Native 브릿지
    private var isInitialized = false       // 초기화 상태
```

**주요 책임:**
- React Native 브릿지 초기화 및 관리
- JavaScript 번들 URL 설정 (개발/프로덕션 환경 분기)
- Granite 앱 생성 및 표시 로직

**핵심 메서드:**
```swift
// 1. 매니저 초기화
func initialize(bundleURL: URL? = nil)

// 2. Granite 앱을 기존 네비게이션에 푸시
func presentGraniteApp(from viewController: UIViewController, ...)

// 3. Granite 앱을 새로운 모달로 표시  
func presentGraniteAppModally(from viewController: UIViewController, ...)
```

#### 3.1.2 GraniteViewController (뷰 컨테이너)

```swift
class GraniteViewController: UIViewController {
    private var rootView: RCTRootView?    // React Native 뷰 참조
```

**주요 책임:**
- RCTRootView를 iOS ViewController로 래핑
- 네비게이션 바 설정 (뒤로가기 버튼 등)
- 생명주기 이벤트 처리 (viewWillAppear/Disappear)

**팩토리 메서드:**
```swift
static func createGraniteApp(
    appName: String,              // "rn" - AppRegistry에 등록된 이름
    scheme: String = "granite://rn",  // 라우팅 스키마
    initialProps: [String: Any] = [:], // 초기 데이터
    bridge: RCTBridge             // React Native 브릿지
) -> GraniteViewController?
```

#### 3.1.3 GraniteModule (브릿지 모듈)

```swift
@objc(GraniteModule)
class GraniteModule: NSObject, RCTBridgeModule {
    @objc public var initialScheme: String = "granite://rn"
    @objc public var bridge: RCTBridge?
```

**JavaScript에서 호출 가능한 메서드:**
```swift
@objc public func closeView()                    // 뷰 닫기
@objc public var schemeUri: String              // 현재 스키마 반환
@objc public func setScheme(_ scheme: String)   // 스키마 설정
```

### 3.2 React Native 레이어

#### 3.2.1 앱 등록 및 초기화

```typescript
// index.ts - React Native 앱 등록
import { register } from '@granite-js/react-native';
import App from './src/_app';

register(App);  // AppRegistry에 앱 등록
```

```typescript
// src/_app.tsx - Granite 앱 정의
export default Granite.registerApp(AppContainer, {
  appName: 'rn',                    // iOS에서 사용할 모듈명
  context,                          // 페이지 컨텍스트
  initialScheme: 'granite://rn',    // 라우팅 스키마
});
```

#### 3.2.2 페이지 기반 라우팅

```typescript
// src/pages/index.tsx - 파일 기반 라우팅
import { createRoute } from '@granite-js/react-native';

export const Route = createRoute('/', {
  component: Page,  // 렌더링할 컴포넌트
});

function Page() {
  const navigation = Route.useNavigation();  // 네비게이션 훅
  
  const goToAboutPage = () => {
    navigation.navigate('/about');  // 페이지 이동
  };
```

---

## 4. 데이터 플로우 및 생명주기

### 4.1 앱 초기화 플로우

```
1. iOS App 시작
   ↓
2. GraniteManager.shared.initialize() 호출
   ↓
3. RCTBridge 생성 (JS Bundle 로드)
   ├─ 개발모드: Metro bundler에서 로드
   └─ 프로덕션: 번들된 main.jsbundle 로드
   ↓
4. JavaScript 엔진 시작
   ↓
5. register(App) 실행 → AppRegistry에 'rn' 앱 등록
   ↓
6. Granite.registerApp으로 앱 컴포넌트 정의
```

### 4.2 Granite 뷰 표시 플로우

```
1. 네이티브에서 showGraniteApp() 호출
   ↓
2. GraniteViewController.createGraniteApp() 호출
   ├─ bridge: RCTBridge 인스턴스
   ├─ moduleName: "rn" 
   ├─ initialProperties: 초기 데이터
   └─ scheme: "granite://rn"
   ↓
3. RCTRootView 생성
   ├─ JavaScript에서 AppRegistry.getAppKeys() 확인
   └─ "rn" 모듈명으로 앱 컴포넌트 찾기
   ↓
4. React Native 앱 렌더링 시작
   ├─ _app.tsx의 AppContainer 실행
   ├─ 라우터 초기화 (파일 기반 라우팅)
   └─ 초기 페이지 ('/') 렌더링
   ↓
5. iOS ViewController에 뷰 표시
```

### 4.3 네이티브 ↔ JavaScript 통신

#### 네이티브 → JavaScript
```swift
// 초기 데이터 전달
let initialProps = [
    "userId": "ios_user_123",
    "source": "native_app"
]

// RCTRootView 생성 시 전달
let rootView = RCTRootView(
    bridge: bridge,
    moduleName: "rn",
    initialProperties: initialProps  // JavaScript에서 props로 접근 가능
)
```

#### JavaScript → 네이티브
```typescript
// GraniteModule 메서드 호출
import { NativeModules } from 'react-native';

const { GraniteModule } = NativeModules;

// 뷰 닫기
GraniteModule.closeView();

// 현재 스키마 조회
const currentScheme = GraniteModule.schemeUri;
```

### 4.4 뷰 생명주기 관리

```swift
// GraniteViewController 생명주기 이벤트
override func viewWillAppear(_ animated: Bool) {
    // Granite 앱 활성화 알림
    NotificationCenter.default.post(
        name: NSNotification.Name("GraniteViewWillAppear"),
        object: nil
    )
}

override func viewWillDisappear(_ animated: Bool) {
    // Granite 앱 비활성화 알림
    NotificationCenter.default.post(
        name: NSNotification.Name("GraniteViewWillDisappear"),
        object: nil
    )
}
```

---

## 5. 주요 개념 용어집

### 5.1 앱 아키텍처 패턴

#### 브라운필드 (Brownfield) vs 그린필드 (Greenfield)

| 구분 | 브라운필드 | 그린필드 |
|------|-----------|----------|
| **정의** | 기존 네이티브 앱에 RN 부분 추가 | 처음부터 RN으로 전체 앱 개발 |
| **사용 사례** | 특정 화면/기능만 RN으로 구현 | 전체 앱을 RN으로 구현 |
| **장점** | 기존 앱 코드 재사용, 점진적 도입 | RN 생태계 완전 활용 |
| **단점** | 복잡한 통합 과정, 두 기술 스택 관리 | 네이티브 기능 제약 |

**현재 프로젝트**: 브라운필드 방식으로 iOS 네이티브 앱 내에서 Granite 화면만 표시

### 5.2 React Native 핵심 개념

#### AppRegistry
React Native에서 JavaScript 앱을 등록하는 시스템입니다.

```typescript
// 내부적으로 실행되는 코드
AppRegistry.registerComponent('rn', () => App);

// 네이티브에서 호출할 때
const rootView = RCTRootView(moduleName: "rn", ...) // 'rn' 이름으로 앱 검색
```

#### Metro Bundler
React Native의 JavaScript 번들링 도구입니다.
- **개발 모드**: 실시간으로 JS 코드를 번들링하여 제공
- **프로덕션 모드**: 최적화된 단일 `.jsbundle` 파일 생성

### 5.3 iOS 개발 개념

#### Swift - Objective-C 브릿징
Swift로 작성된 코드를 Objective-C에서 사용하기 위한 메커니즘입니다.

```objc
// Objective-C에서 Swift 클래스 사용
@interface RCT_EXTERN_MODULE(GraniteModule, NSObject)
// Swift의 GraniteModule 클래스를 Objective-C에서 참조
```

#### 싱글톤 패턴 (Singleton)
앱 전체에서 하나의 인스턴스만 존재하는 객체 패턴입니다.

```swift
class GraniteManager: NSObject {
    static let shared = GraniteManager()  // 전역 공유 인스턴스
    
    private override init() {             // 외부에서 인스턴스 생성 불가
        super.init()
    }
}

// 사용 방법
GraniteManager.shared.initialize()       // 어디서든 같은 인스턴스 접근
```

### 5.4 Granite.js 특화 개념

#### 파일 기반 라우팅
페이지 파일 구조를 바탕으로 자동으로 라우팅을 생성하는 시스템입니다.

```
src/pages/
├── index.tsx        → '/' 경로
├── about.tsx        → '/about' 경로
└── _404.tsx         → 404 에러 페이지
```

#### 스키마 기반 네비게이션
URL 스키마를 통해 네이티브와 React Native 간 네비게이션을 처리합니다.

```
granite://rn/        → 루트 페이지
granite://rn/about   → /about 페이지
```

---

## 결론

이 아키텍처는 다음과 같은 장점을 제공합니다:

1. **점진적 도입**: 기존 iOS 앱을 유지하면서 필요한 부분만 React Native로 구현
2. **양방향 통신**: RCTBridge를 통한 네이티브 ↔ JavaScript 간 자유로운 데이터 교환
3. **생명주기 관리**: iOS 네이티브 앱의 생명주기와 완전히 통합
4. **개발 효율성**: Granite.js의 파일 기반 라우팅으로 빠른 개발 가능

프론트엔드 개발자도 iOS 네이티브 개발 지식 없이 Granite.js를 통해 모바일 앱 개발에 참여할 수 있으며, 네이티브 개발자는 복잡한 UI 로직을 React Native에 위임하여 효율적인 협업이 가능합니다.