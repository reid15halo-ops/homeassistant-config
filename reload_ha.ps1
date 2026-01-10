# Quick reload script
$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhNTYxNTg2ZjI1OTM0OWNjOWRhMzE5MDU1YzAwYzM3OCIsImlhdCI6MTczNjUxMzQ3NCwiZXhwIjoyMDUxODczNDc0fQ.MiOiJhYThhNTIwMDk3ODNzZyYjI3YTE0NDMzN2E1NE1NWM5MSIsImlhdCI6MTc2ODA0Mzc4MiwiZXhwIjoyMDgzNDAzNzgyfQ.KLEL344KZijaM2Uta_DA"
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json"
}

Write-Host "Reloading Home Assistant..." -ForegroundColor Cyan

try {
    Invoke-RestMethod -Uri "http://192.168.178.70:8123/api/services/script/reload" -Method POST -Headers $headers | Out-Null
    Write-Host "Scripts reloaded!" -ForegroundColor Green
    
    Invoke-RestMethod -Uri "http://192.168.178.70:8123/api/services/automation/reload" -Method POST -Headers $headers | Out-Null
    Write-Host "Automations reloaded!" -ForegroundColor Green
    
    Invoke-RestMethod -Uri "http://192.168.178.70:8123/api/services/input_boolean/reload" -Method POST -Headers $headers | Out-Null
    Write-Host "Input booleans reloaded!" -ForegroundColor Green
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
