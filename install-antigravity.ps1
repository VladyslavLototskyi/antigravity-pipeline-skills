param(
    [switch]$Global = $true,
    [switch]$Local,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$src = $PSScriptRoot

if ($Local) {
    $targetSkills = Join-Path (Get-Location) '.agents\skills'
    $targetRules  = Join-Path (Get-Location) '.agents\rules'
} else {
    $targetSkills = Join-Path $env:USERPROFILE '.gemini\antigravity-cli\skills'
    $targetRules  = Join-Path $env:USERPROFILE '.gemini\antigravity-cli\rules'
}

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "   Antigravity Skills & Rules Installer" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Целевая директория Skills: $targetSkills"
Write-Host "Целевая директория Rules:  $targetRules`n"

# 1. Установка скиллов
$skills = @('pipeline', 'launch-web', 'launch-security')

foreach ($skill in $skills) {
    $from = Join-Path $src "skills\$skill"
    if (-not (Test-Path $from)) {
        Write-Warning "Пропуск: исходная папка $from не найдена."
        continue
    }

    $dest = Join-Path $targetSkills $skill
    $verb = if (Test-Path $dest) { "обновлён" } else { "установлен" }

    if ($DryRun) {
        Write-Host "[dry-run] Скилл $skill -> $dest ($verb)" -ForegroundColor Yellow
        continue
    }

    if (-not (Test-Path $targetSkills)) {
        New-Item -ItemType Directory -Path $targetSkills -Force | Out-Null
    }

    if (Test-Path $dest) {
        Remove-Item -Path $dest -Recurse -Force
    }

    Copy-Item -Path $from -Destination $dest -Recurse -Force
    Write-Host "Скилл '$skill' — $verb" -ForegroundColor Green
}

# 2. Установка правил (rules/AGENTS.md)
$rulesFrom = Join-Path $src 'rules\AGENTS.md'
if (Test-Path $rulesFrom) {
    $rulesDest = Join-Path $targetRules 'AGENTS.md'
    $ruleVerb = if (Test-Path $rulesDest) { "обновлён" } else { "установлен" }

    if ($DryRun) {
        Write-Host "[dry-run] Правила AGENTS.md -> $rulesDest ($ruleVerb)" -ForegroundColor Yellow
    } else {
        if (-not (Test-Path $targetRules)) {
            New-Item -ItemType Directory -Path $targetRules -Force | Out-Null
        }
        Copy-Item -Path $rulesFrom -Destination $rulesDest -Force
        Write-Host "Правила 'AGENTS.md' — $ruleVerb" -ForegroundColor Green
    }
}

Write-Host "`n"
if ($DryRun) {
    Write-Host "Режим DryRun: файлы не изменялись." -ForegroundColor Yellow
} else {
    Write-Host "Установка успешно завершена! Скиллы активируются в новой сессии Antigravity." -ForegroundColor Cyan
}
