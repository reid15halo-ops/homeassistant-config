# Quick reload script using curl.exe
$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhNTYxNTg2ZjI1OTM0OWNjOWRhMzE5MDU1YzAwYzM3OCIsImlhdCI6MTczNjUxMzQ3NCwiZXhwIjoyMDUxODczNDc0fQ.MiOiJhYThhNTIwMDk3ODNzZyYjI3YTE0NDMzN2E1NE1NWM5MSIsImlhdCI6MTc2ODA0Mzc4MiwiZXhwIjoyMDgzNDAzNzgyfQ.KLEL344KZijaM2Uta_DA"
$base_url = "https://192.168.178.70:8123"

Write-Host "Reloading Home Assistant..." -ForegroundColor Cyan

function Reload-Service($domain) {
    $url = "$base_url/api/services/$domain/reload"
    Write-Host "Reloading $domain..." -NoNewline
    # Use curl.exe with -k (insecure) to bypass SSL errors
    $output = curl.exe -s -k -X POST -H "Authorization: Bearer $token" -H "Content-Type: application/json" $url
    if ($LASTEXITCODE -eq 0) {
        Write-Host " Done!" -ForegroundColor Green
    }
    else {
        Write-Host " Failed!" -ForegroundColor Red
        Write-Host $output
    }
}

Reload-Service "script"
Reload-Service "automation"
Reload-Service "input_boolean"
Reload-Service "template"
