
$currentWorkingDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. $currentWorkingDir\env_asm.ps1

echo "VM image name: '$vmImageName'"

.\uploadvhdAsm.ps1
gLogMsg "finish upload VHD"

.\addAsmImage.ps1
gLogMsg "finish add vm image"

.\updateAsmImage.ps1
gLogMsg "finish update image"

.\replicateAsmImage.ps1
gLogMsg "start replicate image"
