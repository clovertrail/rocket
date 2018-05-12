
$currentWorkingDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$env_asm_path      = join-path $currentWorkingDir "env_asm.ps1"
. $env_asm_path

function gGetAncestorDir()
{
   $dir = (get-item $env_asm_path).directory.parent.fullname
   echo $dir
}


echo $currentWorkingDir
#gLogin
$storageAccount = "honzhanbsdimgstore"
$primaryKey     = "gfQmrZ60UUw9hsAvZbUl+cHlDpYOVux7NdHentgeWaLWkuGSEhJ9OB+RGRANZwlIiDb8bx/RNuiKrLCnfUd5Pg=="
$url            = "https://honzhanbsdimgstore.blob.core.windows.net/honzhanbsdimgcontainer/FreeBSD_11_0_20170224.vhd"
gLogMsg $primaryKey
gLogMsg "$url"
gSetBillingTag $storageAccount $primaryKey $url

