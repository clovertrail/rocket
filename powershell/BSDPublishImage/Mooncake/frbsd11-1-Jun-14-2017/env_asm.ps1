$env_config_script = "env_config.ps1"
$currentWorkingDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$env_config_ps1    = join-path $currentWorkingDir $env_config_script

. $env_config_ps1

#### global variables ####
$storageAccount       = "honzhanbsdimgstore"
$containerName        = "honzhanbsdimgcontainer"
$location             = "China East"
$subscriptionName     = "FreeBSD"
$containerPermission  = "Off"
$imageDescription     = "FreeBSD 11.0 for Microsoft Azure provided by Microsoft Corporation. FreeBSD is an advanced computer operating system used to power modern servers, desktops and embedded platforms. The FreeBSD Logo and the mark FreeBSD are registered trademarks of The FreeBSD Foundation and are used by Microsoft Corporation with the permission of The FreeBSD Foundation."

$billingTag           = "76c00aea-81e2-421e-b623-6ba4f0e74d48"
$binDir               = "bin"
$billingTagDir        = "BillingTag"
$billingTagExe        = "BillingTag.exe"

$offer               = "FreeBSD"
$sku                 = "11.0"
$publisher           = "Microsoft"
$osType              = "Linux"
$vmLabelImageFamily  = "FreeBSD 11.0"
$recommendedVMSize   = "Large"
#$eula                = "http://www.redhat.com/licenses/cloud_CSSA/Red_Hat_Cloud_Software_Subscription_Agreement_for_Microsoft_Azure.pdf"
$publishSettingsFileName = "FreeBSD.publishsettings"
$publishSettingsFilePath = join-path $currentWorkingDir $publishSettingsFileName

#### utility functions ####
function gLogMsg([String] $msg)
{
   $Timestamp = Get-Date -Format yyyy-MM-dd-HH-mm-ss
   $OutputMsg = $Timestamp + ":" + $msg
   write-host $OutputMsg
}

function gFindBillingExePath()
{
   ## Find powershell directory from "powershell/BSDPublishImage/Mooncake/XXX"
   $powershellDir = (get-item $currentWorkingDir).parent.parent.parent.fullname
   $billingTagExePath = join-path $powershellDir $binDir
   $billingTagDirPath = join-path $billingTagExePath $billingTagDir
   $billingExePath    = join-path $billingTagDirPath $billingTagExe
   gLogMsg "BillingTag exe: $billingExePath"
   return $billingExePath
}

function gSetBillingTag(
   [String] $storageAccount,
   [String] $storagePrimaryKey,
   [String] $vhdUrl)
{
   $billingExePath = gFindBillingExePath
   $setCmd = "$billingExePath /medialink:$vhdUrl /account:$storageAccount /key:$storagePrimaryKey /action:set /id:$billingTag"
   $getCmd = "$billingExePath /medialink:$vhdUrl /account:$storageAccount /key:$storagePrimaryKey /action:get"
   
   gLogMsg $setCmd
   $ret = Invoke-Expression $setCmd
   gLogMsg $getCmd
   $ret = Invoke-Expression $getCmd
   $tag = $ret.Split()[3]
   gLogMsg "Tag has been set: '$tag'"
   if ($tag -eq $billingTag) {
      return $True
   } else {
      return $False
   }
}

function gGetBillingTag(
   [String] $storageAccount,
   [String] $storagePrimaryKey,
   [String] $vhdUrl)
{
   $billingExePath = gFindBillingExePath
   $getCmd = "$billingExePath /medialink:$vhdUrl /account:$storageAccount /key:$storagePrimaryKey /action:get"
   
   gLogMsg $getCmd
   $ret = Invoke-Expression $getCmd
   $tag = $ret.Split()[3]
   #gLogMsg "Tag has been set: '$tag'"
   return $tag
}

function gLoginSelectSubscription(
  [String] $publishSettingsFilePath,
  [String] $subscriptionName)
{
   Import-AzurePublishSettingsFile -publishsettingsFile $publishSettingsFilePath
   Select-AzureSubscription -Current -SubscriptionName $subscriptionName
}

function gLogin()
{
   gLoginSelectSubscription $publishSettingsFilePath $subscriptionName
}

function gValidateVHDFilePath(
   [String] $VHDFilePath)
{
   if (!(test-path $VHDFilePath -PathType Leaf)) {
       gLogMsg "VHD file $VHDFilePath is not existed!"
       return $false
   }
   return $True
}

function gImportModules()
{
   import-module "C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Compute\PIR.psd1"
}

