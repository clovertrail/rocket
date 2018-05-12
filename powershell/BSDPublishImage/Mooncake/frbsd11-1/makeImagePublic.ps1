$currentWorkingDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. $currentWorkingDir\env_asm.ps1

function makeImagePublic([String] $imageName)
{
   set-azureplatformvmimage -ImageName $imageName -Permission Public
}

$ret=gValidateParameters
if (!$ret) {
   gLogMsg "Invalid parameters, please specify correct parameters. See comments of env_config.ps1"
   return $ret
}

gImportModules
gLogin
makeImagePublic $vmImageName
