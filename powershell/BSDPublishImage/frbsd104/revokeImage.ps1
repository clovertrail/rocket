$env_script         = "env_asm.ps1"
$unreplicate_script = "unreplicateAsmImage.ps1"
$removeImage_script = "removeImage.ps1"

$currentWorkingDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$env_ps1 = join-path $currentWorkingDir $env_script
. $env_ps1

$ret=gValidateParameters
if (!$ret) {
   gLogMsg "Invalid parameters, please specify correct parameters. See comments of env_config.ps1"
   return $ret
}

$unreplicate_ps1 = join-path $currentWorkingDir $unreplicate_script
. $unreplicate_ps1

$removeImage_ps1 = join-path $currentWorkingDir $removeImage_script
. $removeImage_ps1
