Function Write-Log 
{ 
  [CmdletBinding()] 
  Param 
  ( 
    [Parameter(Mandatory = $false)] 
    [string]$Message,   
    [Parameter(Mandatory = $false)] 
    [string]$Path,
    [Parameter(Mandatory = $false)] 
    [string]$FormattedDate,
    [Parameter(Mandatory = $false)] 
    [string]$LogID,
    [Parameter(Mandatory = $false)] 
    [ValidateSet('Error','Warn','Info')] 
    [string]$Level = 'Info',
    [Parameter(Mandatory = $false)] 
    [string]$ScriptName,
    [Parameter(Mandatory = $false)] 
    [string]$FunctionName,
    [Parameter(Mandatory = $false)] 
    [string]$ErrorMessage = 'No Error',  
    [Parameter(Mandatory = $false)] 
    [string]$Reason,
    [Parameter(Mandatory = $false)] 
    [string]$TargetName,
    [Parameter(Mandatory = $false)] 
    [string]$ScriptLineNumber,
    [Parameter(Mandatory = $false)] 
    [string]$OffsetInLine,
    [Parameter(Mandatory = $false)]
    [Object]$Parameters
  ) 
 
  Begin 
  {   
    if (!$Path) 
    {
      $Path = ($Env:ALLUSERSPROFILE) +'\Logs\Log.log'
      Write-Verbose -Message ('No log specified using default location of {0}' -f $Path)
    }
  } 
  Process 
  {  
 
    If (!(Test-Path -Path $Path)) 
    { 
      Write-Verbose -Message ('Creating {0}.' -f $Path) 
      $null = New-Item -Path $Path -Force -ItemType File
      Write-Verbose -Message ('Log file location: {0}.' -f $Path)
    } 
  
 
    switch ($Level) { 
      'Error' 
      { 
        Write-Host "******************************" -ForegroundColor Yellow
        Write-Host $Message -ForegroundColor White
        Write-Host "Error: "$ErrorMessage -ForegroundColor Red
        Write-Host "******************************" -ForegroundColor Yellow
        Write-Error -Message $Message
        Write-Error -Message $ErrorMessage
        $LevelText = 'ERROR' 
      } 
      'Warn' 
      { 
        Write-Warning -Message $Message
        Write-Warning -Message $ErrorMessage 
        $LevelText = 'WARNING' 
      } 
      'Info' 
      { 
        Write-Verbose -Message $Message
        $LevelText = 'INFO' 
      } 
    } 
         
    ('{0} {1} {2} {3} {4} {5} {6} {7} {8} {9} {10}' -f "$FormattedDate;", "$LogID;", "$LevelText;", "Script Name:$ScriptName;", "Function Name: $FunctionName;", "Message:$Message;", "ErrorMessage:$ErrorMessage;", "Reason:$Reason;", "Target Name: $TargetName;", "Script Line Number:$ScriptLineNumber;", "Offset In Line:$OffsetInLine;" ) | Out-File -FilePath $Path -Append 
    if ($Parameters) 
    {
      $Parameters | ForEach-Object -Process{
        ('{0} {1} {2} {3} {4} {5} {6} {7} {8}' -f "$FormattedDate;", "$LogID;", "$LevelText;", 'Parameter Name:', $_.Name, ';', 'Parameter Value:', $_.Value, ';') | Out-File -FilePath $Path -Append
      }
    }
  } 
  End 
  { 
  } 
}
 
##########################################
Function Use-ErrorHandle ($Message)
{
  Try
  {
    $FormattedDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss' 
    $LogID = 'LogID' + (Get-Date -Format 'yyyyMMddHHmmssfff')
    $LogFilePath = (Get-Variable -Name 'LogFilePath').Value
    [Management.Automation.ErrorRecord]$ErrorRecord = $_     
    $FunctionName = $PSCmdlet.MyInvocation.InvocationName
    $ParameterList = (Get-Command -Name $FunctionName).Parameters
    foreach ($Parameter in $ParameterList) 
    {
      $ParameterInputs = @(Get-Variable -Name $Parameter.Values.Name -ErrorAction SilentlyContinue)
    }
  }
  Catch
  {
 
  }
  Finally
  {
    Write-Host $Message -ForegroundColor Red
    Write-Log -Path $LogFilePath -FormattedDate $FormattedDate -LogID $LogID -Level Error -ScriptName $ErrorRecord.InvocationInfo.ScriptName -FunctionName $FunctionName -Message $Message -ErrorMessage $ErrorRecord.Exception.Message -Reason $ErrorRecord.CategoryInfo.Reason -TargetName $ErrorRecord.CategoryInfo.TargetName  -ScriptLineNumber $ErrorRecord.InvocationInfo.ScriptLineNumber -OffsetInLine $ErrorRecord.InvocationInfo.OffsetInLine -Parameters $ParameterInputs
  }
}
 
##########################################
Function Use-WarnHandle ($Message)
{
  Try
  {
    $FormattedDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss' 
    $LogID = 'LogID' + (Get-Date -Format 'yyyyMMddHHmmssfff')
    $LogFilePath = (Get-Variable -Name 'LogFilePath').Value
    [Management.Automation.ErrorRecord]$ErrorRecord = $_     
    $FunctionName = $PSCmdlet.MyInvocation.InvocationName
    $ParameterList = (Get-Command -Name $FunctionName).Parameters
    foreach ($Parameter in $ParameterList) 
    {
      $ParameterInputs = @(Get-Variable -Name $Parameter.Values.Name -ErrorAction SilentlyContinue)
    }
  }
  Catch
  {
 
  }
  Finally
  {
    Write-Log -Path $LogFilePath -FormattedDate $FormattedDate -LogID $LogID -Level Warn -ScriptName $ErrorRecord.InvocationInfo.ScriptName -FunctionName $FunctionName -Message $Message -ErrorMessage $ErrorRecord.Exception.Message -Reason $ErrorRecord.CategoryInfo.Reason -TargetName $ErrorRecord.CategoryInfo.TargetName  -ScriptLineNumber $ErrorRecord.InvocationInfo.ScriptLineNumber -OffsetInLine $ErrorRecord.InvocationInfo.OffsetInLine -Parameters $ParameterInputs
  }
}
 
##########################################
Function Use-LogHandle ($Message)
{
  Try
  {
    $FormattedDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss' 
    $LogID = 'LogID' + (Get-Date -Format 'yyyyMMddHHmmssfff')
    $LogFilePath = (Get-Variable -Name 'LogFilePath').Value
    $FunctionName = $PSCmdlet.MyInvocation.InvocationName
    $ParameterList = (Get-Command -Name $FunctionName).Parameters
    foreach ($Parameter in $ParameterList) 
    {
      $ParameterInputs = @(Get-Variable -Name $Parameter.Values.Name -ErrorAction SilentlyContinue)
    }
  }
  Catch
  {
 
  }
  Finally
  {
    Write-Log -Path $LogFilePath -FormattedDate $FormattedDate -LogID $LogID -Level INFO -FunctionName $FunctionName -Message $Message -Parameters $ParameterInputs
  }
}
#############################
Function Invoke-Unzip
{
  param
  (
   # [Parameter(Mandatory = $true)]
    #[String]$ZipDirectory,
    [Parameter(Mandatory = $true)]
    [String]$ZipFilename,
    [Parameter(Mandatory = $false)]
    [String]$OutDirectory
  )
        #Use-LogHandle -Message ('Unzip {0} to {1}' -f ($ZipDirectory + $ZipFilename) ,$OutDirectory)
        if(!(Test-Path $OutDirectory))
                {
                New-Item -ItemType Directory -Path $OutDirectory | Out-Null 
                }


        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [IO.Compression.ZipFile]::ExtractToDirectory($ZipFilename,$OutDirectory)


 }


##################################################
Function Invoke-DownloadWebFile
 
{
  param
  (
    [Parameter(Mandatory = $true)]
    [String]$Url,
    [Parameter(Mandatory = $true)]
    [String]$FileName,
    [Parameter(Mandatory = $false)]
    [String]$DownloadFolder
  )
 

    Try
    {
        Use-LogHandle -Message "Attempting to download $FileName from $Url "
        if(!(Test-Path $DownloadFolder)){
                New-Item -ItemType Directory -Path $DownloadFolder | Out-Null 
            }
        $FullUrl = $Url+ $FileName
        $FullDownloadPath = $DownloadFolder + $FileName
        $WebClient = New-Object System.Net.WebClient
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type)
        {
        $CertCallback = @"
            using System;
            using System.Net;
            using System.Net.Security;
            using System.Security.Cryptography.X509Certificates;
            public class ServerCertificateValidationCallback
            {
                public static void Ignore()
                {
                    if(ServicePointManager.ServerCertificateValidationCallback ==null)
                    {
                        ServicePointManager.ServerCertificateValidationCallback += 
                            delegate
                            (
                                Object obj, 
                                X509Certificate certificate, 
                                X509Chain chain, 
                                SslPolicyErrors errors
                            )
                            {
                                return true;
                            };
                    }
                }
            }
"@
        Add-Type $CertCallback
        }
        [ServerCertificateValidationCallback]::Ignore()
        $WebClient.DownloadFile($FullUrl,$FullDownloadPath)
        Use-LogHandle -Message "$FileName downloaded to $DownloadFolder "
    }
    Catch
     {
        Use-ErrorHandle -Message "Unable to download file"
        Throw
     }
}

#############################################
Function Invoke-RunPowershellScripts
 
{
  param
  (
    [Parameter(Mandatory = $true)]
    [String]$Folder
  )
  Try
  {
    if(!(Test-Path $Folder )){
            Use-ErrorHandle -Message "Unable to run each .ps1 file in $Folder - Folder does not exist"
            Throw "Unable to run each .ps1 file in $Folder - Folder does not exist"
            }
    else
    {
        Use-LogHandle "Run each .ps1 file in $Folder "
        foreach($File in (Get-ChildItem -Path $Folder))
            {
            if($File.Extension -eq ".ps1")
                {
                Try
                    {
                    $FullFilePath = $File.FullName
                    Use-LogHandle "Running $FullFilePath "
                    Invoke-Expression -Command $FullFilePath
                    }
                Catch
                    {
                    Use-ErrorHandle -Message "Running $FullFilePath Failed"
                    }
            
                }
            }
            if(!$FullFilePath)
                    {
                    Use-WarnHandle "No ps1 files found in $Folder"
                    }
        }

    }
    Catch
     {
        Use-ErrorHandle -Message "Unable to run each .ps1 file in $Folder "
     }
}
#############################################

Function Remove-Folder
{
  param
  (
    [Parameter(Mandatory = $true)]
    [String]$FolderPath,
    [Parameter(Mandatory = $false)]
    [switch]$Confirm
  )

Try
    {
    if(Test-Path $FolderPath)
        {
        Use-LogHandle "$FolderPath found"
        if($Confirm)
            {
            Remove-Item $FolderPath -Recurse -Confirm
            }
        else
            {
            Remove-Item $FolderPath -Recurse
            }
        if(Test-Path $FolderPath)
            {
            Throw "Unable to remove item: $FolderPath : Try to delete manually. If file is locked please restart the computer"
            }
        else
            {
            Use-LogHandle "$FolderPath has been removed"
            }
        }
    else
        {
        Use-LogHandle "$FolderPath not found or is not a folder"
        }
      }
Catch
    {
    Use-ErrorHandle
    Throw
    }
}

##############################################
Function Invoke-ImportPowershellModules
 
{
  param
  (
    [Parameter(Mandatory = $true)]
    [String]$Folder
  )
  Try
  {
    if(!(Test-Path $Folder )){
            Use-ErrorHandle -Message "Unable to import each .psm1 file in $Folder - Folder does not exist"
            Throw "Unable to import each .psm1 file in $Folder - Folder does not exist"
            }
    else
    {
        Use-LogHandle "Import each .psm1 file in $Folder "
        foreach($File in (Get-ChildItem -Path $Folder))
            {
            if($File.Extension -eq ".psm1")
                {
                Try
                    {
                    $FullFilePath = $File.FullName
                    Use-LogHandle "Import-Module $FullFilePath "
                    Import-Module $FullFilePath
                    }
                Catch
                    {
                    Use-ErrorHandle -Message "Running $FullFilePath Failed"
                    }
            
                }
            }
            if(!$FullFilePath)
                    {
                    Use-LogHandle "No psm1 files found in $Folder"
                    }
        }

    }
    Catch
     {
        Use-ErrorHandle -Message "Unable to Import each .psm1 file in $Folder "
     }
}
##################################################
Function Invoke-CheckUrl
 
{
  param
  (
    [Parameter(Mandatory = $true)]
    [String]$Url,
    [Parameter(Mandatory = $true)]
    [String]$FileName
  )
 

    Try
    {
        Use-LogHandle -Message "Attempting to connect to $FileName from $Url "
        $FullUrl = $Url+ $FileName
        $WebClient = New-Object System.Net.WebClient
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type)
        {
        $CertCallback = @"
            using System;
            using System.Net;
            using System.Net.Security;
            using System.Security.Cryptography.X509Certificates;
            public class ServerCertificateValidationCallback
            {
                public static void Ignore()
                {
                    if(ServicePointManager.ServerCertificateValidationCallback ==null)
                    {
                        ServicePointManager.ServerCertificateValidationCallback += 
                            delegate
                            (
                                Object obj, 
                                X509Certificate certificate, 
                                X509Chain chain, 
                                SslPolicyErrors errors
                            )
                            {
                                return true;
                            };
                    }
                }
            }
"@
        Add-Type $CertCallback
        }
        [ServerCertificateValidationCallback]::Ignore()
        $WebClient.OpenRead($FullUrl)
        Use-LogHandle -Message "Connected to $FullUrl"
    }
    Catch
     {
        Use-LogHandle -Message "Unable to connect to $FullUrl"
        Throw
     }
}

##############################################
Function Invoke-ImportZipFiles
 
{
  param
  (
    [Parameter(Mandatory = $true)]
    [String]$Folder,
    [Parameter(Mandatory = $true)]
    [String]$OutDirectory
  )
  Try
  {
    if(!(Test-Path $Folder )){
            Use-ErrorHandle -Message "Unable to import each .zip file in $Folder - Folder does not exist"
            Throw "Unable to import each .zip file in $Folder - Folder does not exist"
            }
    else
    {
        Use-LogHandle "Unzip each .zip file in $Folder "
        foreach($File in (Get-ChildItem -Path $Folder))
            {
            if($File.Extension -eq ".zip")
                {
                Try
                    {
                    $FullFilePath = $File.FullName
                    Use-LogHandle "Unzip $FullFilePath "
                    if(!(Test-Path $OutDirectory)){
                        Use-LogHandle "$OutDirectory does not exist. Create new folder"
                        New-Item -ItemType Directory -Path $OutDirectory | Out-Null 
                        }
                    Invoke-Unzip -ZipFilename $FullFilePath -OutDirectory $OutDirectory
                    
                    }
                Catch
                    {
                    Use-ErrorHandle -Message "Uzipping $FullFilePath Failed"
                    }
            
                }
            }
            if(!$FullFilePath)
                    {
                    Use-LogHandle "No .zip files found in $Folder"
                    }
        }

    }
    Catch
     {
        Use-ErrorHandle -Message "Unable to unzip each .zip file in $Folder "
     }
}
##############################################
Function Invoke-LogCurrentDetails
{

  Try
  {
    $Whoami = whoami
    $Location = Get-Location
    $RunningAsAdmin  = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    Use-LogHandle ("Running as Admin:" + (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    Use-LogHandle ("Whoami: $Whoami") 
    Use-LogHandle ("CurrentLocation: $Location") 
    }
    Catch
     {
        Use-ErrorHandle -Message "Unable to log current details "
     }
}
##################################################


