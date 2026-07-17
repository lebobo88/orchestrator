$ErrorActionPreference = 'SilentlyContinue'

function Get-PropertyValue {
    param($Object, [string]$Name, $Default = $null)
    if ($null -eq $Object) { return $Default }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) { return $Default }
    return $property.Value
}

function Truncate-Text {
    param([string]$Text, $Columns)
    $width = 0
    [void][int]::TryParse([string]$Columns, [ref]$width)
    if ($width -gt 0 -and $Text.Length -gt $width) {
        return $Text.Substring(0, [math]::Max(0, $width - 3)) + '...'
    }
    return $Text
}

$rawInput = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($rawInput)) { exit 0 }
try {
    $data = $rawInput | ConvertFrom-Json
} catch {
    exit 0
}

$columns = Get-PropertyValue $data 'columns' 0
$tasks = @(Get-PropertyValue $data 'tasks' @())
foreach ($task in $tasks) {
    $id = Get-PropertyValue $task 'id'
    if ([string]::IsNullOrWhiteSpace($id)) { continue }

    $name = Get-PropertyValue $task 'name' 'subagent'
    $status = Get-PropertyValue $task 'status' 'unknown'
    $label = Get-PropertyValue $task 'label'
    $model = Get-PropertyValue $task 'model'
    $tokenCount = Get-PropertyValue $task 'tokenCount'
    $windowSize = Get-PropertyValue $task 'contextWindowSize'

    $context = 'ctx: n/a'
    if ($null -ne $tokenCount -and $null -ne $windowSize -and [double]$windowSize -gt 0) {
        $percentage = [math]::Floor(([double]$tokenCount / [double]$windowSize) * 100)
        $percentage = [math]::Min(100, [math]::Max(0, $percentage))
        $context = "ctx: $percentage%"
    }

    $content = "$name · $status"
    if ($label) { $content += " · $label" }
    if ($model) { $content += " · $model" }
    $content += " · $context"
    $row = [ordered]@{ id = $id; content = (Truncate-Text $content $columns) }
    $row | ConvertTo-Json -Compress -Depth 3
}
