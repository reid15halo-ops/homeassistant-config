
$HA_URL = "http://192.168.178.70:8123"
$token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI3OWYxOWU4Nzk0OTM0ZWI3YWY3OWQ3NDQ3MTJhNTM4NSIsImlhdCI6MTc2OTE4NzAyNiwiZXhwIjoyMDg0NTQ3MDI2fQ.hnjwIBvi2LSI37EwYuFQt55v8mGDnbzqN2QHXmuBQvs"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json"
}

try {
    Write-Host "Reloading Automations..."
    Invoke-RestMethod -Uri "$HA_URL/api/services/automation/reload" -Method POST -Headers $headers
    Write-Host "Success!"
}
catch {
    Write-Host "Error: $_"
    Write-Host "Exception: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody"
    }
}
