Start-Process "cmd.exe" "/k ngrok.exe http 5678"
Start-Sleep -Seconds 7

# Get public ngrok URL
$response = Invoke-RestMethod -Uri "http://127.0.0.1:4040/api/tunnels"
$ngrokUrl = $response.tunnels[0].public_url

# Update docker-compose.yml
$composeFile = "C:\N8N\self-hosted-ai-starter-kit\docker-compose.yml"
$content = Get-Content $composeFile
$content = $content -replace '    - WEBHOOK_URL=.*', "    - WEBHOOK_URL=$ngrokUrl"
Set-Content $composeFile $content

# Restart Docker
cd "C:\N8N\self-hosted-ai-starter-kit"
docker compose down
docker compose --profile cpu up -d
