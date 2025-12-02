# Define source folder
$DownloadsPath = "C:\Users\<username>\Downloads"
$ReportPath    = "$DownloadsPath\Downloads_Report.txt"

Write-Host "Scanning $DownloadsPath ..."

# Get all files
$files = Get-ChildItem -Path $DownloadsPath -File

# -------------------------------
# Phase 1: Review & Report
# -------------------------------

# Group files by extension (Type-based)
$typeGroups = $files | Group-Object Extension | Sort-Object Count -Descending

# Group files by Year/Month (Date-based)
$dateGroups = $files | Group-Object { $_.LastWriteTime.ToString("yyyy-MM") } | Sort-Object Name

# Build recommendations for type-based
$typeRecommendations = foreach ($group in $typeGroups) {
    $ext = $group.Name
    $count = $group.Count

    switch -Regex ($ext) {
        "\.(docx|doc|pdf|txt|xls|xlsx|ppt|pptx)" { $folder = "Documents" }
        "\.(jpg|jpeg|png|gif|bmp|svg)"           { $folder = "Images" }
        "\.(mp4|mov|avi|mkv)"                    { $folder = "Videos" }
        "\.(zip|rar|7z|tar|gz)"                  { $folder = "Compressed" }
        "\.(exe|msi|bat)"                        { $folder = "Software" }
        default                                 { $folder = "Misc" }
    }

    [PSCustomObject]@{
        Extension = $ext
        Count     = $count
        SuggestedFolder = $folder
    }
}

# Output report
"Downloads Folder Review Report" | Out-File $ReportPath
"================================" | Out-File $ReportPath -Append

"--- Type-based Recommendations ---" | Out-File $ReportPath -Append
foreach ($rec in $typeRecommendations) {
    $line = "Extension: {0} | Count: {1} | Suggested Folder: {2}" -f $rec.Extension, $rec.Count, $rec.SuggestedFolder
    Write-Host $line
    $line | Out-File $ReportPath -Append
}

"`n--- Date-based Recommendations ---" | Out-File $ReportPath -Append
foreach ($group in $dateGroups) {
    $line = "Period: {0} | File Count: {1}" -f $group.Name, $group.Count
    Write-Host $line
    $line | Out-File $ReportPath -Append
}

Write-Host "`nReport saved to $ReportPath"
Write-Host "Review the suggested folder hierarchies before proceeding."

# -------------------------------
# Phase 2: Ask user choice
# -------------------------------
$choice = Read-Host "Do you want to organize by Type or by Date? (Type/Date/N)"

if ($choice -match "^[Tt]ype$") {
    foreach ($rec in $typeRecommendations) {
        $targetFolder = Join-Path $DownloadsPath $rec.SuggestedFolder

        # Create folder only if missing
        if (-not (Test-Path $targetFolder)) {
            Write-Host "Creating missing folder: $targetFolder"
            New-Item -Path $targetFolder -ItemType Directory | Out-Null
        } else {
            Write-Host "Folder already exists: $targetFolder"
        }

        # Move files of this extension
        Get-ChildItem -Path $DownloadsPath -File | 
            Where-Object { $_.Extension -eq $rec.Extension } | 
            ForEach-Object {
                Write-Host "Moving $($_.Name) -> $targetFolder"
                Move-Item -Path $_.FullName -Destination $targetFolder -Force
            }
    }
    Write-Host "✅ Files have been organized by Type."
}
elseif ($choice -match "^[Dd]ate$") {
    foreach ($group in $dateGroups) {
        $targetFolder = Join-Path $DownloadsPath $group.Name

        # Create folder only if missing
        if (-not (Test-Path $targetFolder)) {
            Write-Host "Creating missing folder: $targetFolder"
            New-Item -Path $targetFolder -ItemType Directory | Out-Null
        } else {
            Write-Host "Folder already exists: $targetFolder"
        }

        # Move files for this period
        foreach ($file in $group.Group) {
            Write-Host "Moving $($file.Name) -> $targetFolder"
            Move-Item -Path $file.FullName -Destination $targetFolder -Force
        }
    }
    Write-Host "✅ Files have been organized by Date (Year-Month)."
}
else {
    Write-Host "No changes made. You can rerun the script later."
}