# Fix Dell opencode.json ConfigInvalidError - run in pwsh7 as georg
$path = "C:\Users\georg\.config\opencode\opencode.json"
Write-Host "[*] Fixing $path" -ForegroundColor Cyan
if (!(Test-Path $path)) { Write-Error "Not found: $path"; exit 1 }
$raw = Get-Content $path -Raw | ConvertFrom-Json
# Fix agent system-design mode secondary -> subagent
if ($raw.agent -and $raw.agent."system-design" -and $raw.agent."system-design".mode -eq "secondary") {
  $raw.agent."system-design".mode = "subagent"
  Write-Host "[OK] agent.system-design.mode -> subagent" -ForegroundColor Green
}
# Fix MCP entries: type stdio -> local + enabled true
if ($raw.mcp) {
  foreach ($name in @("desktop-control","naturo","control-mcp")) {
    if ($raw.mcp.$name) {
      if ($raw.mcp.$name.type -eq "stdio") { $raw.mcp.$name.type = "local"; Write-Host "[OK] mcp.$name.type -> local" -ForegroundColor Green }
      if (-not (Get-Member -InputObject $raw.mcp.$name -Name "enabled")) {
        $raw.mcp.$name | Add-Member -NotePropertyName "enabled" -NotePropertyValue $true
      } else { $raw.mcp.$name.enabled = $true }
      Write-Host "[OK] mcp.$name.enabled -> true" -ForegroundColor Green
    }
  }
}
$raw | ConvertTo-Json -Depth 10 | Set-Content $path -Encoding UTF8
Write-Host "[OK] Saved fixed config" -ForegroundColor Green
Get-Content $path | Write-Host
