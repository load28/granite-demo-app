# Granite iOS 브라운필드 연동 가이드

## 개요

이 문서는 iOS 네이티브 앱에서 Granite React Native 앱을 브라운필드 방식으로 연동하는 방법을 설명합니다.

## 구현된 구조

### 1. 핵심 컴포넌트

#### GraniteModule.swift
- TurboModule 인터페이스 구현
- React Native와 iOS 네이티브 간 브릿지 역할
- `closeView()`, `schemeUri` 속성 제공

#### GraniteViewController.swift  
- UIViewController를 상속하여 Granite 화면을 관리
- RCTRootView를 래핑하여 네이티브 네비게이션과 통합
- 생명주기 이벤트 처리

#### GraniteManager.swift
- Singleton 패턴으로 Granite 시스템 중앙 관리
- RCTBridge 초기화 및 관리
- 편의 메서드 제공

### 2. 주요 기능

- **앱 등록**: Granite.registerApp을 통한 React Native 앱 등록
- **화면 전환**: Push/Modal 방식 화면 전환 지원  
- **데이터 전달**: initialProps를 통한 네이티브 → React Native 데이터 전달
- **생명주기 관리**: 앱 표시/숨김 이벤트 처리

## 사용 방법

### 1. 초기 설정

```swift
// 앱 시작 시 GraniteManager 초기화
GraniteManager.shared.initialize()
```

### 2. Granite 앱 열기

#### Navigation Push 방식
```swift
viewController.showGraniteApp(
    appName: "rn",
    scheme: "granite://rn", 
    initialProps: [
        "userId": "user123",
        "source": "native_app"
    ]
)
```

#### Modal 방식
```swift
viewController.showGraniteAppModally(
    appName: "rn",
    scheme: "granite://rn",
    initialProps: [
        "userId": "user456", 
        "source": "native_modal"
    ]
)
```

### 3. 데이터 흐름

```
iOS Native App → initialProps → Granite App → useInitialProps()
                     ↓
            Granite App Logic
                     ↓
            closeView() → iOS Native App
```

## 설정 요구사항

### 1. Podfile 설정
```ruby
# React Native 및 Granite 의존성
use_react_native!(:path => '../rn/node_modules/react-native')
```

### 2. Bridging Header
```objc
#import <React/RCTBridgeModule.h>
#import <React/RCTRootView.h>
```

### 3. iOS 프로젝트 설정
- iOS 13.0+ 타겟
- Swift와 Objective-C 브릿징 설정
- React Native 라이브러리 링크

## 디렉토리 구조

```
app/
├── ios/                    # iOS 네이티브 프로젝트
│   ├── ios/
│   │   ├── GraniteModule.swift     # TurboModule 구현
│   │   ├── GraniteModule.m         # Objective-C 브릿지
│   │   ├── GraniteViewController.swift  # 뷰 컨트롤러
│   │   ├── GraniteManager.swift    # 중앙 매니저
│   │   ├── ContentView.swift       # 메인 화면 (예시)
│   │   └── ios-Bridging-Header.h   # 브릿징 헤더
│   └── Podfile                     # CocoaPods 설정
├── rn/                     # Granite React Native 프로젝트
│   ├── src/
│   ├── granite.config.ts
│   └── index.ts
└── granite-analysis.md     # 구조 분석 문서
```

## 테스트 시나리오

### 1. 기본 연동 테스트
1. iOS 앱 실행
2. "Granite RN 앱 열기" 버튼 탭
3. Granite 화면이 네이티브 네비게이션으로 표시됨
4. "닫기" 버튼으로 네이티브 앱으로 복귀

### 2. 모달 연동 테스트  
1. "Granite RN 앱 (모달)" 버튼 탭
2. Granite 화면이 전체 화면 모달로 표시됨
3. Granite 앱 내 "닫기" 기능으로 모달 해제

### 3. 데이터 전달 테스트
1. initialProps로 userId, source 전달
2. Granite 앱에서 useInitialProps()로 데이터 수신 확인
3. 전달된 데이터가 올바르게 표시되는지 검증

## 주의사항

### 1. Bundle 로드
- 개발 모드: Metro bundler에서 동적 로드
- 프로덕션: 번들된 main.jsbundle 파일 로드

### 2. 메모리 관리
- RCTBridge와 RCTRootView의 생명주기 관리 필요
- Strong reference cycle 방지

### 3. Thread Safety
- UI 업데이트는 반드시 Main Queue에서 실행
- Bridge 초기화는 적절한 타이밍에 수행

## 확장 가능성

### 1. 다중 Granite 앱 지원
```swift
// 여러 Granite 앱 동시 관리
GraniteManager.shared.registerApp("shopping", bundleURL: shoppingBundleURL)
GraniteManager.shared.registerApp("payment", bundleURL: paymentBundleURL)
```

### 2. 네이티브 함수 호출
```swift
// Granite 앱에서 네이티브 함수 호출
GraniteModule.invokeNativeFunction("showAlert", args: ["Hello"])
```

### 3. 이벤트 시스템
```swift
// 네이티브 → Granite 이벤트
NotificationCenter.default.post(name: "UserLocationChanged", object: location)
```

이 구현을 통해 iOS 네이티브 앱에서 Granite React Native 화면을 자연스럽게 통합하여 사용할 수 있습니다.