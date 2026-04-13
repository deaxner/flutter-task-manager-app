$preferredPort = 8080
$maxPort = 8180
$selectedPort = $preferredPort

while ($selectedPort -le $maxPort) {
    $inUse = Get-NetTCPConnection -LocalPort $selectedPort -ErrorAction SilentlyContinue
    if (-not $inUse) {
        break
    }

    $selectedPort++
}

if ($selectedPort -gt $maxPort) {
    throw "No free port found between $preferredPort and $maxPort."
}

$networkName = "portfolio_suite_network"
$existingNetwork = docker network ls --format "{{.Name}}" | Where-Object { $_ -eq $networkName }
if (-not $existingNetwork) {
    docker network create $networkName | Out-Null
}

$env:APP_PORT = [string]$selectedPort

Write-Host "Using Flutter web host port $selectedPort"
Write-Host "Using shared Docker network $networkName"
docker compose up --build -d

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host "Flutter web app available at http://localhost:$selectedPort"
