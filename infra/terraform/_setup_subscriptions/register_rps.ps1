param (
  [Parameter(Mandatory = $true)]
  [ValidateScript(
    { [Guid]::TryParse($_, [ref]([Guid]::Empty)) -eq $true },
    ErrorMessage = "Invalid Azure Subscription Id format."
  )]
  [string]$SubscriptionId,

  [ValidateScript(
    { Test-Path -Path $_ },
    ErrorMessage = "A file for resource providers not found."
  )]
  [string]$ResourceProvidersFile = "./resource_providers.txt"
)

az account set --subscription ${SubscriptionId}

Get-Content $ResourceProvidersFile | ForEach-Object {
  $state = (az provider show --namespace $_ --query "registrationState" -o tsv)
  if ($state -ne "Registered") {
    Write-Host -NoNewline "Registering Resource Provider ($_)..."
    az provider register --namespace $_ --wait
    $exitCode = $LastExitCode
    if ($exitCode -ne 0) {
      Write-Host "Failed to register. Exit code: $exitCode"
    }
    else {
      Write-Host "Registered"
    }
  }
  else {
    Write-Host "Resource provider $_ is already registered."
  }
}
