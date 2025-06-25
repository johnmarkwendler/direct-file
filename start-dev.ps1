# Direct File Development Startup Script
# Run this from the direct-file directory

Write-Host "🚀 Starting Direct File Development Environment..." -ForegroundColor Green

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Check if in correct directory
if (!(Test-Path "docker-compose.yaml")) {
    Write-Host "❌ Please run this script from the direct-file directory" -ForegroundColor Red
    exit 1
}

# Create .env.local if it doesn't exist
if (!(Test-Path ".env.local")) {
    Write-Host "📝 Creating .env.local file..." -ForegroundColor Yellow
    @"
# Basic Development Environment Variables
LOCAL_WRAPPING_KEY=oE3Pm+fr1I+YbX2ZxEe/n9INqJjy00KSl7oXXW4p5Xw=
DF_API_PORT=8080
DF_FE_PORT=3000
DF_DB_PORT=5435
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
SUBMIT_ETIN=11111
SUBMIT_ASID=22222222
SUBMIT_EFIN=333333
SUBMIT_ID_VAR_CHARS=dev
VITE_DISABLE_AUTO_LOGOUT=true
VITE_ALLOW_LOADING_TEST_DATA=true
VITE_BACKEND_URL=http://localhost:8080/df/file/api/
VITE_ENABLE_ESSAR_SIGNING=false
VITE_SADI_AUTH_ID=00000000-0000-0000-0000-000000000000
VITE_SADI_XFF_HEADER=127.0.0.1
VITE_SADI_TID_HEADER=11111111-1111-1111-1111-111111111111
VITE_SADI_LOGOUT_URL=http://localhost:3000/logout
DF_LISTEN_ADDRESS=127.0.0.1
"@ | Out-File -FilePath ".env.local" -Encoding UTF8
    Write-Host "✅ Created .env.local" -ForegroundColor Green
}

# Start infrastructure services
Write-Host "🐘 Starting database and infrastructure..." -ForegroundColor Cyan
docker-compose up -d db localstack redis

# Wait for database to be ready
Write-Host "⏳ Waiting for database to be ready..." -ForegroundColor Yellow
do {
    Start-Sleep -Seconds 2
    $dbReady = docker-compose exec -T db pg_isready -U postgres
} while ($dbReady -notlike "*accepting connections*")
Write-Host "✅ Database is ready" -ForegroundColor Green

# Start the API
Write-Host "🔧 Starting backend API..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; docker-compose up api"

# Wait a moment for API to start
Start-Sleep -Seconds 5

# Install frontend dependencies and start
Write-Host "⚛️ Starting frontend..." -ForegroundColor Cyan
if (Test-Path "df-client/df-client-app/node_modules") {
    Write-Host "📦 Node modules already installed" -ForegroundColor Green
} else {
    Write-Host "📦 Installing frontend dependencies..." -ForegroundColor Yellow
    Push-Location "df-client/df-client-app"
    npm install
    Pop-Location
}

Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD/df-client/df-client-app'; npm run start"

Write-Host ""
Write-Host "🎉 Development environment is starting!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Services:" -ForegroundColor White
Write-Host "  Frontend:  http://localhost:3000" -ForegroundColor Cyan
Write-Host "  Backend:   http://localhost:8080" -ForegroundColor Cyan
Write-Host "  Database:  localhost:5435" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔍 To monitor services:" -ForegroundColor White
Write-Host "  docker-compose logs -f api" -ForegroundColor Gray
Write-Host ""
Write-Host "🛑 To stop all services:" -ForegroundColor White
Write-Host "  docker-compose down" -ForegroundColor Gray
Write-Host "" 