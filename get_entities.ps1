# Get all unique entity_ids from yaml files
$files = Get-ChildItem -Path "c:\Users\reid1\Documents\homeassistant-config" -Recurse -Include *.yaml
$pattern = "(light|switch|sensor|binary_sensor|cover|climate|fan|lock|media_player|input_boolean|input_text|input_number|input_select|timer|zone|script|automation|scene|person)\.[a-z0-9_]+"

$entities = @()

foreach ($file in $files) {
    $content = Get-Content $file.FullName
    $matches = [regex]::Matches($content, $pattern)
    foreach ($match in $matches) {
        $entities += $match.Value
    }
}

$entities | Select-Object -Unique | Sort-Object
