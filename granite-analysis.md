# Granite 라이브러리 구조 분석 보고서

## 개요
Granite는 토스에서 개발한 React Native 기반 마이크로 프론트엔드 플랫폼입니다. 이 보고서는 브라운필드 방식으로 iOS 네이티브 앱에 Granite을 연동하기 위한 구조 분석 결과를 정리합니다.

## 1. 핵심 패키지 구조

### 1.1 packages/native
- **역할**: 네이티브 모듈과 라이브러리들의 허브 역할
- **주요 기능**:
  - React Native 네이티브 라이브러리들의 중앙 관리
  - TurboModule 기반 네이티브 브릿지 제공
  - 네이티브 의존성 통합 관리

**주요 exports**:
```typescript
// 네이티브 라이브러리 의존성들
./@react-native-async-storage/async-storage
./@react-navigation/native
./react-native-webview
./react-native-safe-area-context
./react-native-gesture-handler
```

### 1.2 packages/react-native
- **역할**: Granite 프레임워크의 핵심 구현체
- **주요 기능**:
  - Granite 앱 등록 및 관리
  - 컴포넌트 생명주기 관리
  - 네이티브-JS 브릿지 통신

**주요 exports**:
```typescript
// 핵심 모듈들
.                    // 메인 API
./async-bridges      // 비동기 브릿지
./constant-bridges   // 상수 브릿지
./config            // 설정
./cli               // CLI 도구
```

## 2. 브라운필드 연동 핵심 컴포넌트

### 2.1 GraniteModule (TurboModule)
```typescript
interface GraniteModule {
  // 앱 등록
  registerApp(appId: string, config: AppConfig): Promise<void>
  
  // 앱 시작
  startApp(appId: string, initialProps?: object): Promise<void>
  
  // 네이티브 함수 호출
  invokeNativeFunction(functionName: string, args: any[]): Promise<any>
}
```

### 2.2 AppRegistry 시스템
Granite은 React Native의 AppRegistry를 확장하여 멀티앱 등록을 지원:

```typescript
import { AppRegistry } from '@granite-js/react-native'

// 앱 컴포넌트 등록
AppRegistry.registerComponent('MyGraniteApp', () => MyApp)

// 글로벌 설정
AppRegistry.setGlobalConfig({
  cdnHost: 'https://d2dzky5bdhec40.cloudfront.net',
  apiEndpoint: 'https://api.example.com'
})
```

### 2.3 InitialProps와 Context
```typescript
interface GraniteAppProps {
  appId: string
  initialProps?: object
  context?: {
    userId?: string
    sessionToken?: string
    [key: string]: any
  }
}
```

## 3. 네이티브 브릿지 구조

### 3.1 TurboModule 기반 아키텍처
- **GraniteCoreModule**: 핵심 네이티브 기능 제공
- **GraniteNavigationModule**: 네이티브 네비게이션 통합
- **GraniteStorageModule**: 네이티브 스토리지 접근

### 3.2 브릿지 통신 메커니즘
```typescript
// 네이티브에서 JS로 이벤트 전달
NativeEventEmitter.emit('granite:appReady', { appId: 'myApp' })

// JS에서 네이티브 함수 호출
await GraniteModule.invokeNativeFunction('showNativeAlert', ['Hello'])
```

## 4. 네이티브 앱 로드 메커니즘

### 4.1 앱 등록 과정
1. **Bundle 로드**: CDN 또는 로컬에서 JS Bundle 다운로드
2. **앱 등록**: AppRegistry에 컴포넌트 등록
3. **초기화**: 초기 props와 context 설정
4. **렌더링**: RCTRootView를 통한 화면 렌더링

### 4.2 스킴 기반 라우팅
```
granite://showcase  -> Showcase 앱 실행
granite://counter   -> Counter 앱 실행
granite://myapp?param=value -> 파라미터와 함께 앱 실행
```

### 4.3 라이프사이클
```typescript
// 1. 앱 등록
AppRegistry.registerComponent('MyApp', () => MyApp)

// 2. 네이티브에서 앱 시작 요청
GraniteModule.startApp('MyApp', { userId: '123' })

// 3. React Native 컴포넌트 마운트
// 4. 네이티브 뷰에 렌더링
```

## 5. 브라운필드 연동 전략

### 5.1 iOS 연동 구현 요소
1. **GraniteModule 구현**: Swift/Objective-C TurboModule
2. **RCTRootView 관리**: Granite 앱을 위한 루트 뷰
3. **Bundle 관리**: JS Bundle 로드 및 캐싱
4. **Navigation 통합**: UINavigationController와 연동

### 5.2 필요한 iOS 구성 요소
```swift
// GraniteModule.swift
@objc(GraniteModule)
class GraniteModule: NSObject, RCTBridgeModule {
  @objc func registerApp(_ appId: String, config: NSDictionary) {
    // 앱 등록 로직
  }
  
  @objc func startApp(_ appId: String, initialProps: NSDictionary?) {
    // RCTRootView 생성 및 표시
  }
}
```

### 5.3 연동 플로우
1. **네이티브 앱 시작** → iOS 앱 런치
2. **Granite 초기화** → GraniteModule 로드
3. **Bundle 준비** → JS Bundle 다운로드/로드
4. **앱 등록** → AppRegistry에 컴포넌트 등록
5. **뷰 생성** → RCTRootView 생성
6. **화면 표시** → UIViewController에 Granite 뷰 추가

## 6. 결론

Granite는 TurboModule 기반의 견고한 브릿지 시스템을 제공하며, AppRegistry를 통한 멀티앱 관리 기능을 지원합니다. 브라운필드 방식 연동을 위해서는:

1. **GraniteModule TurboModule 구현** (iOS Swift/Objective-C)
2. **RCTRootView를 활용한 뷰 관리 시스템**
3. **Bundle 로드 및 캐싱 메커니즘**
4. **네이티브-JS 간 데이터 교환 인터페이스**

이를 통해 기존 네이티브 앱에 Granite 화면을 자연스럽게 통합할 수 있습니다.