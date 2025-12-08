# ---- Move Citrix ADMX/ADML Files to PolicyDefinitions ----

$SourceADMX1 = "C:\Program Files (x86)\Citrix\ICA Client\Configuration\CitrixBase.admx"
$SourceADMX2 = "C:\Program Files (x86)\Citrix\ICA Client\Configuration\receiver.admx"
$SourceADML1 = "C:\Program Files (x86)\Citrix\ICA Client\Configuration\en-US\CitrixBase.adml"
$SourceADML2 = "C:\Program Files (x86)\Citrix\ICA Client\Configuration\en-US\receiver.adml"

$DestADMXDir = "C:\Windows\PolicyDefinitions"
$DestADMLDir = "C:\Windows\PolicyDefinitions\en-US"

# Ensure destination directories exist
if (-not (Test-Path $DestADMXDir)) { New-Item -Path $DestADMXDir -ItemType Directory -Force }
if (-not (Test-Path $DestADMLDir)) { New-Item -Path $DestADMLDir -ItemType Directory -Force }

# Helper function to move files safely
function Move-CitrixFile {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (Test-Path $Source) {
        Write-Host "Moving: $Source → $Destination"
        Move-Item -Path $Source -Destination $Destination -Force
    }
    else {
        Write-Warning "File not found: $Source"
    }
}

# Move ADMX files
Move-CitrixFile -Source $SourceADMX1 -Destination $DestADMXDir
Move-CitrixFile -Source $SourceADMX2 -Destination $DestADMXDir

# Move ADML files
Move-CitrixFile -Source $SourceADML1 -Destination $DestADMLDir
Move-CitrixFile -Source $SourceADML2 -Destination $DestADMLDir

Write-Host "`n--- Citrix ADMX/ADML file move complete ---`n"


# ---------------------------------------------------------
# Create Citrix Receiver policy registry structure
# and add StoreFront / NetScaler Gateway configuration
# ---------------------------------------------------------

$BasePath = "HKLM:\SOFTWARE\Policies\Citrix"
$ReceiverPath = Join-Path $BasePath "Receiver"
$SitesPath = Join-Path $ReceiverPath "Sites"

# Ensure the Citrix -> Receiver -> Sites path exists
if (-not (Test-Path $BasePath)) {
    New-Item -Path $BasePath -Force | Out-Null
}

if (-not (Test-Path $ReceiverPath)) {
    New-Item -Path $ReceiverPath -Force | Out-Null
}

if (-not (Test-Path $SitesPath)) {
    New-Item -Path $SitesPath -Force | Out-Null
}

# StoreFront entry
$StoreValueName = "STORE0"
$StoreValueData = "CloudWorkspace;https://cloud.amegoinc.org;On;Citrix Cloud Workspace"

# Apply the policy value
New-ItemProperty -Path $SitesPath -Name $StoreValueName -Value $StoreValueData -PropertyType String -Force | Out-Null

Write-Host "`nCitrix StoreFront / NetScaler Gateway policy applied successfully."
Write-Host "Registry Path: $SitesPath"
Write-Host "Value: $StoreValueName = $StoreValueData"
Write-Host "`nRun 'gpupdate /force' to apply the policy."

