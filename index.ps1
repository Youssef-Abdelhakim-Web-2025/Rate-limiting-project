# ==========================================
# PowerShell Rate Limit & Load Tester (Newline-Proof)
# ==========================================

Clear-Host;

$myUrl = "http://localhost:3000/api/login";
$headers = @{ "Content-Type" = "application/json" };
$body = '{"username":"admin","password":"wrongpassword"}';

$totalRequests = 10;

Write-Host "=== Starting Rate Limit Test ===" -ForegroundColor Cyan;
Write-Host "Sending requests to: $myUrl`n" -ForegroundColor Yellow;

$totalStopwatch = [System.Diagnostics.Stopwatch]::StartNew();$results = @();

for ($i = 1; $i -le$totalRequests; $i++) {$reqStopwatch = [System.Diagnostics.Stopwatch]::StartNew();
    
    try {
        $requestParams = @{
            Uri                = $myUrl;
            Method             = 'Post';
            Headers            = $headers;
            Body               = $body;
            SkipHttpErrorCheck = $true;
            TimeoutSec         = 5;
        };

        $response = Invoke-WebRequest @requestParams;
        $reqStopwatch.Stop();

        $remaining =$response.Headers["RateLimit-Remaining"];
        if (-not $remaining) {$remaining = "N/A"; 
        }

        $results += [PSCustomObject]@{
            RequestIndex = $i;
            StatusCode   = $response.StatusCode;
            TimeMs       = $reqStopwatch.ElapsedMilliseconds;
            Remaining    = $remaining;
            Error        = $null;
        };
    }
    catch {
        $reqStopwatch.Stop();$results += [PSCustomObject]@{
            RequestIndex = $i;
            StatusCode   = "Error";
            TimeMs       = $reqStopwatch.ElapsedMilliseconds;
            Remaining    = "N/A";
            Error        = $_.Exception.Message;
        };
    }

    Start-Sleep -Milliseconds 100;
}

$totalStopwatch.Stop();

# ==========================================
# Results & Summary
# ==========================================
Write-Host "`n=== Test Results Summary ===" -ForegroundColor Cyan;

foreach ($res in $results) {
    if ($res.StatusCode -eq 401) {
        Write-Host "[$($res.RequestIndex)] Status: 401 (Unauthorized) | Time: $($res.TimeMs)ms | Remaining: $($res.Remaining)" -ForegroundColor Green;
    }
    elseif ($res.StatusCode -eq 429) {
        Write-Host "[$($res.RequestIndex)] Status: 429 (Rate Limited)  | Time: $($res.TimeMs)ms | Remaining: $($res.Remaining)" -ForegroundColor Yellow;
    }
    else {
        Write-Host "[$($res.RequestIndex)] Status: $($res.StatusCode) | Error: $($res.Error)" -ForegroundColor Red;
    }
}

$successCount = ($results | Where-Object { $_.StatusCode -eq 401 }).Count;
$limitedCount = ($results | Where-Object { $_.StatusCode -eq 429 }).Count;
$errorCount   = ($results | Where-Object { $_.StatusCode -eq "Error" }).Count;
$avgTime      = ($results | Measure-Object -Property TimeMs -Average).Average;

Write-Host "`n----------------------------------------" -ForegroundColor DarkGray;
Write-Host "Total Execution Time : $($totalStopwatch.ElapsedMilliseconds) ms" -ForegroundColor White;
Write-Host "Successful Requests  : $successCount" -ForegroundColor Green;
Write-Host "Rate-Limited (429)   : $limitedCount" -ForegroundColor Yellow;
Write-Host "Failed/Errors        : $errorCount" -ForegroundColor Red;
Write-Host "Average Response Time: $([Math]::Round($avgTime, 2)) ms" -ForegroundColor White;
Write-Host "----------------------------------------" -ForegroundColor DarkGray;