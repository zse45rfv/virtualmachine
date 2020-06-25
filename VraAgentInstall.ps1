#requires -version 2
<#
.SYNOPSIS
  This script is used to download, unzip and install the Vra Guest Agent for a Windows Server template
.DESCRIPTION
  <Brief description of script>
.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>
.INPUTS
  None
.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>
.NOTES
  Version:        1.0
  Author:         DW – Vmware PSO
  Creation Date:  DW – Vmware PSO
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

# Parameters from the commandline to set the default variables


#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Continue
$ErrorActionPreference = "Continue"
$VerbosePreference = "Continue"

#Dot Source required Function Libraries

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Folder and File Info 
$VraIaasUrl = "https://vra/software/download/"
$VraIaasUrlFile = "prepare_vra_template_windows.zip"
$DownloadFolder = $env:ALLUSERSPROFILE + "\VraPrepareTemplate\Downloaded\"
$WorkingFolder = $env:ALLUSERSPROFILE + "\VraPrepareTemplate\Working\"
$ExtractedFolder = $env:ALLUSERSPROFILE + "\VraPrepareTemplate\Working\Unzipped\"
$global:LogFilePath = $env:ALLUSERSPROFILE + "\VraPrepareTemplateLogs\install.log"

#vRA Agent Install Arguements 
$ApplianceHost = "vra"
$ManagerServiceHost = "MGTST01VRI01.MGT.local"
$ApplianceFingerprint = ""
$ManagerFingerprint = ""
$CloudProvider = "vsphere"


#-----------------------------------------------------------[Functions]------------------------------------------------------------

#All Functions found in the VraGuestFunctionsvX.psm1. Please ensure psm1 file is stored with this script

#-----------------------------------------------------------[Execution]------------------------------------------------------------
Invoke-LogCurrentDetails

Try
    {
    Invoke-CheckUrl -Url $VraIaasUrl -FileName $VraIaasUrlFile
    }
Catch
    {
    Use-LogHandle "Invoke-CheckUrl -Url $VraIaasUrl -FileName $VraIaasUrlFile :Unable to connect or file not found: Now exiting" 
    exit
    }
 
Try
    {
    Write-Host "Logfile located: $LogFilePath" -ForegroundColor Yellow
    Write-Host "Agent Logfile located: C:\opt\agentinstall.txt" -ForegroundColor Yellow
    Remove-Folder $DownloadFolder -Confirm
    Remove-Folder $WorkingFolder -Confirm
    Remove-Folder $ExtractedFolder -Confirm

    Use-LogHandle "Invoke-DownloadWebFile -Url $VraIaasUrl -FileName $VraIaasUrlFile -DownloadFolder $DownloadFolder "
    Invoke-DownloadWebFile -Url $VraIaasUrl -FileName $VraIaasUrlFile -DownloadFolder $DownloadFolder
    
    Use-LogHandle "Invoke-Unzip -ZipFilename ($DownloadFolder + $VraIaasUrlFile) -OutDirectory $ExtractedFolder"
    Invoke-Unzip -ZipFilename ($DownloadFolder + $VraIaasUrlFile) -OutDirectory $ExtractedFolder
    Use-LogHandle "Stop-Service VCACGuestAgentService"
    Stop-Service VCACGuestAgentService -ErrorAction SilentlyContinue
    Stop-Service vRASoftwareAgentBootstrap -ErrorAction SilentlyContinue
    Use-LogHandle "Sleep for 15 Seconds before starting installtion"
    Start-Sleep -Seconds 15
    Use-LogHandle "Run powershell script $ExtractedFolder\prepare_vra_template_windows\prepare_vra_template.ps1 " -ForegroundColor
    Invoke-Expression "& `"$ExtractedFolder\prepare_vra_template_windows\prepare_vra_template.ps1`" -ApplianceHost vra.mgt.local -ManagerServiceHost MGTST01VRI01.MGT.local -ApplianceFingerprint 5F:00:F7:3C:31:2E:CC:D8:C9:D9:BF:1C:18:9D:C7:C7:48:CC:A9:DB -ManagerFingerprint 5F:00:F7:3C:31:2E:CC:D8:C9:D9:BF:1C:18:9D:C7:C7:48:CC:A9:DB  -CloudProvider vsphere# -SoftwareLocalSystem"
    Use-LogHandle "VRAGuestAgent Install Completed"
    Write-Host "Logfile located: $LogFilePath " -ForegroundColor Yellow
    Write-Host "Agent Logfile located: C:\opt\agentinstall.txt" -ForegroundColor Yellow
    }
Catch
    {
    Use-ErrorHandle -Message "VRAGuestAgent Install did not complete"
    Write-Host "VRAGuestAgent Install did not complete" -ForegroundColor Yellow
    Write-Host "Logfile located: $LogFilePath " -ForegroundColor Yellow
    Write-Host "Agent Logfile located: C:\opt\agentinstall.txt" -ForegroundColor Yellow
    } 

