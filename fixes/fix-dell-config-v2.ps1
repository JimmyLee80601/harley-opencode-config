# Harley Dell Auto-Fix v2 - auto diagnoses & fixes, with undo - run in pwsh7
param([switch]$Undo)
$path = "C:\Users\georg\.config\opencode\opencode.json"
$bak = "$path.bak.$(Get-Date -Format yyyyMMdd_HHmmss)"
$latestBak = Get-ChildItem "$path.bak.*" 2>$null | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($Undo) {
  if ($latestBak) { Copy-Item $latestBak $path -Force; Write-Host "[OK] Restored backup $($latestBak.Name)" -ForegroundColor Green; exit 0 } else { Write-Error "No backup found"; exit 1 }
}
Write-Host "[*] Harley Auto-Diagnosing $path" -ForegroundColor Cyan
if (!(Test-Path $path)) { Write-Error "Not found"; exit 1 }
Copy-Item $path $bak -Force; Write-Host "[OK] Backup -> $bak" -ForegroundColor Green
$raw = Get-Content $path -Raw | ConvertFrom-Json
$fixed=0
# Diagnose A: agent system-design mode
if ($raw.agent -and $raw.agent."system-design") {
  $m=$raw.agent."system-design".mode
  if ($m -eq "secondary") { $raw.agent."system-design".mode="subagent"; Write-Host "[FIX A] agent.system-design.mode secondary -> subagent" -ForegroundColor Green; $fixed++ }
  elseif ($m -notin @("subagent","primary","all")) { $raw.agent."system-design".mode="subagent"; Write-Host "[FIX A] agent mode $m -> subagent" -ForegroundColor Yellow; $fixed++ }
  else { Write-Host "[OK] agent mode $m is valid" -ForegroundColor Gray }
}
# Diagnose B: mcp entries
if ($raw.mcp) {
  foreach ($name in @("desktop-control","naturo","control-mcp")) {
    if ($raw.mcp.$name) {
      $t=$raw.mcp.$name.type
      if ($t -eq "stdio") { $raw.mcp.$name.type="local"; Write-Host "[FIX B] mcp.$name.type stdio -> local" -ForegroundColor Green; $fixed++ }
      elseif ($t -ne "local" -and $t -ne "remote") { $raw.mcp.$name.type="local"; Write-Host "[FIX B] mcp.$name.type $t -> local" -ForegroundColor Yellow; $fixed++ }
      if (-not (Get-Member -InputObject $raw.mcp.$name -Name "enabled" -ErrorAction SilentlyContinue)) {
        $raw.mcp.$name | Add-Member -NotePropertyName "enabled" -NotePropertyValue $true; Write-Host "[FIX B] mcp.$name.enabled added true" -ForegroundColor Green; $fixed++ 
      } elseif ($raw.mcp.$name.enabled -ne $true) { $raw.mcp.$name.enabled=$true; Write-Host "[FIX B] mcp.$name.enabled -> true" -ForegroundColor Green; $fixed++ }
      else { Write-Host "[OK] mcp.$name already good" -ForegroundColor Gray }
    }
  }
}
if ($fixed -eq 0) { Write-Host "[OK] No fixes needed, already clean" -ForegroundColor Green; Remove-Item $bak -Force; exit 0 }
$raw | ConvertTo-Json -Depth 10 | Set-Content $path -Encoding UTF8
Write-Host "[OK] Fixed $fixed issues, saved. Backup at $bak" -ForegroundColor Green
Write-Host "To undo: pwsh -File $PSCommandPath -Undo" -ForegroundColor Cyan
Get-Content $path | Write-Host
