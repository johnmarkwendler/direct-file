# Direct File Troubleshooting Script

Write-Host "🔍 Direct File Troubleshooting..." -ForegroundColor Yellow
Write-Host ""

# Check prerequisites
Write-Host "📋 Checking Prerequisites:" -ForegroundColor Cyan

try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker not found or not running" -ForegroundColor Red
}

try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js not found" -ForegroundColor Red
}

try {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "✅ Java: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Java not found" -ForegroundColor Red
}

Write-Host ""

# Check Docker services
Write-Host "🐳 Checking Docker Services:" -ForegroundColor Cyan

$services = @("direct-file-db", "direct-file-api", "localstack")
foreach ($service in $services) {
    try {
        $status = docker ps --filter "name=$service" --format "table {{.Names}}\t{{.Status}}"
        if ($status -like "*$service*") {
            Write-Host "✅ $service is running" -ForegroundColor Green
        } else {
            Write-Host "❌ $service is not running" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Cannot check $service status" -ForegroundColor Red
    }
}

Write-Host ""

# Check ports
Write-Host "🌐 Checking Ports:" -ForegroundColor Cyan

$ports = @(3000, 8080, 5435)
foreach ($port in $ports) {
    try {
        $connection = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue
        if ($connection.TcpTestSucceeded) {
            Write-Host "✅ Port $port is open" -ForegroundColor Green
        } else {
            Write-Host "❌ Port $port is not accessible" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Cannot test port $port" -ForegroundColor Red
    }
}

Write-Host ""

# Check environment file
Write-Host "⚙️ Checking Configuration:" -ForegroundColor Cyan

if (Test-Path ".env.local") {
    Write-Host "✅ .env.local file exists" -ForegroundColor Green
} else {
    Write-Host "❌ .env.local file missing" -ForegroundColor Red
    Write-Host "   Run the start-dev.ps1 script to create it" -ForegroundColor Gray
}

if (Test-Path "df-client/df-client-app/node_modules") {
    Write-Host "✅ Frontend dependencies installed" -ForegroundColor Green
} else {
    Write-Host "❌ Frontend dependencies not installed" -ForegroundColor Red
    Write-Host "   Run: cd df-client/df-client-app && npm install" -ForegroundColor Gray
}

Write-Host ""

# Quick fixes
Write-Host "🛠️ Quick Fixes:" -ForegroundColor Cyan
Write-Host "   Reset everything: docker-compose down -v && docker-compose up -d" -ForegroundColor Gray
Write-Host "   View API logs: docker-compose logs -f api" -ForegroundColor Gray
Write-Host "   Rebuild containers: docker-compose build --no-cache" -ForegroundColor Gray
Write-Host "   Kill port conflicts: netstat -ano | findstr :8080" -ForegroundColor Gray
Write-Host "" 