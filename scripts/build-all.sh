#!/bin/bash

# 모든 Granite 앱을 프로덕션용으로 빌드하는 스크립트

echo "🔨 Building all Granite apps for production..."

# 빌드 결과를 저장할 디렉토리 생성
mkdir -p "ios/bundles"

# 각 앱을 빌드하는 함수
build_app() {
    local app_name="$1"
    echo "📱 Building $app_name..."
    
    cd "packages/$app_name"
    
    # Granite 빌드 실행
    if yarn build; then
        echo "✅ $app_name build completed"
        
        # 빌드된 번들을 iOS 디렉토리로 복사 (만약 번들 파일이 생성된다면)
        if [ -f "dist/index.bundle" ]; then
            cp "dist/index.bundle" "../../ios/bundles/${app_name}.jsbundle"
            echo "📦 $app_name bundle copied to iOS"
        fi
        
        if [ -f "dist/assets" ]; then
            cp -r "dist/assets" "../../ios/bundles/${app_name}_assets"
            echo "🖼️  $app_name assets copied to iOS"
        fi
        
    else
        echo "❌ $app_name build failed"
        cd "../.."
        exit 1
    fi
    
    cd "../.."
}

# 의존성 설치
echo "📦 Installing dependencies..."
if ! yarn install; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "🏗️  Building all packages..."

# 각 앱 빌드
build_app "home"
build_app "login"
build_app "profile"

echo "🎉 All Granite apps built successfully!"
echo "📁 Bundles are available in ios/bundles/"

# iOS 빌드 가이드
echo ""
echo "📱 Next steps for iOS:"
echo "1. Open ios/ios.xcworkspace in Xcode"
echo "2. Build and run the iOS project"
echo "3. Test each Granite module from the native app"