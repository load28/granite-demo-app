#!/bin/bash

# 개발 서버를 여러 포트에서 동시 실행하는 스크립트
# 각 Granite 앱마다 독립적인 Metro 서버 실행

echo "🚀 Starting Granite Monorepo Development Servers..."

# 백그라운드 프로세스들을 추적하기 위한 배열
declare -a PIDS

# 포트가 사용 중인지 확인하는 함수
check_port() {
    local port="$1"
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 1  # 포트가 사용 중
    else
        return 0  # 포트가 사용 가능
    fi
}

# 터미널 정리를 위한 함수
cleanup() {
    echo ""
    echo "🛑 Stopping all development servers..."
    for pid in "${PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            echo "  📱 Stopping PID: $pid"
            kill -TERM "$pid" 2>/dev/null
        fi
    done
    
    # 모든 프로세스가 종료될 때까지 대기
    sleep 2
    
    # 강제 종료가 필요한 프로세스들 처리
    for pid in "${PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            echo "  🔥 Force killing PID: $pid"
            kill -KILL "$pid" 2>/dev/null
        fi
    done
    
    echo "✅ All servers stopped."
    exit 0
}

# Ctrl+C 시그널 처리
trap cleanup SIGINT SIGTERM

# 각 앱별 개발 서버 시작
start_app() {
    local app_name="$1"
    local port="$2"
    
    echo "📱 Starting $app_name on port $port..."
    
    # 포트 사용 여부 확인
    if ! check_port "$port"; then
        echo "❌ Port $port is already in use! Please free the port first."
        echo "   You can kill processes using: lsof -ti:$port | xargs kill -9"
        return 1
    fi
    
    # 패키지 디렉토리 확인
    if [ ! -d "packages/$app_name" ]; then
        echo "❌ Package directory not found: packages/$app_name"
        return 1
    fi
    
    cd "packages/$app_name"
    
    # 개발 서버 시작 (백그라운드)
    echo "  🌐 Starting Metro server for $app_name..."
    yarn dev > "../../../logs/${app_name}.log" 2>&1 &
    local pid=$!
    PIDS+=("$pid")
    cd "../.."
    
    # 서버 시작 대기
    echo "  ⏳ Waiting for $app_name server to start..."
    local max_attempts=30
    local attempts=0
    
    while [ $attempts -lt $max_attempts ]; do
        if curl -s "http://localhost:$port/status" >/dev/null 2>&1; then
            echo "  ✅ $app_name server ready at http://localhost:$port (PID: $pid)"
            return 0
        fi
        sleep 1
        attempts=$((attempts + 1))
        echo -n "."
    done
    
    echo ""
    echo "  ⚠️  $app_name server started (PID: $pid) but health check failed"
    echo "     Check logs at logs/${app_name}.log if needed"
}

# 로그 디렉토리 생성
mkdir -p logs

# 메인 실행
echo "🏠 Starting development servers for all Granite apps..."
echo ""

# 각 앱을 다른 포트에서 실행
start_app "home" "8081"
echo ""
start_app "login" "8082"
echo ""
start_app "profile" "8083"

echo ""
echo "🎉 All development servers are running!"
echo ""
echo "📱 Available services:"
echo "   🏠 Home:    http://localhost:8081"
echo "   🔐 Login:   http://localhost:8082"
echo "   👤 Profile: http://localhost:8083"
echo ""
echo "📋 Logs are available in:"
echo "   📄 logs/home.log"
echo "   📄 logs/login.log"
echo "   📄 logs/profile.log"
echo ""
echo "💡 iOS 앱에서 각 모듈을 테스트할 수 있습니다."
echo "🛑 Press Ctrl+C to stop all servers"
echo ""

# 모든 백그라운드 프로세스가 끝날 때까지 대기
wait