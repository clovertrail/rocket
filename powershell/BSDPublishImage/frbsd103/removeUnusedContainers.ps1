$currentWorkingDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. $currentWorkingDir\env_asm.ps1

function removeStorageContainers(
   [String] $subscriptionName,
   [String] $stroageAccount,
   [String] $containerName,
   [String] $pattern)
{
	Select-AzureSubscription -SubscriptionName $subscriptionName
    $StorageKey = (Get-AzureStorageKey -StorageAccountName $stroageAccount).Primary
    if ($? -eq $False) {
		return $False
	}
    gLogMsg "Storage primary key: $StorageKey"
    $sourceContext = New-AzureStorageContext -StorageAccountName $storageAccount -StorageAccountKey $StorageKey
	$existingContainers = Get-AzureStorageContainer
	foreach ($cont in $existingContainers)
	{
		if ($cont.Name -match $pattern) {
			Write-Host $cont.Name
			Remove-AzureStorageContainer -Name $cont.Name -Context $sourceContext -Force
		}
	}
}

gLogin

removeStorageContainers $subscriptionName $storageAccount $containerName "^bootdiagnostics*"
