########################################################################################
<#
.DESCRIPTION
    Name:           Deploy-AzTemplate.ps1

    Description:    Deploy ARM Template via Azure Pipelines.
                    
    Author:         James Ferrari

    Version:        1.0

    Date:           01/01/2021

    Requires:       N/A

.CHANGE LOG
    Version 1.0     01/01/2021    First Release                        

.EXAMPLE
#>
########################################################################################

param 
(
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [ValidateSet('uksouth','ukwest')]
    [string]
    $Location,

    [Parameter(Mandatory=$true)]
    [ValidateSet('Deploy','Test')]
    [string]
    $DeployOrTest,

    [Parameter(Mandatory=$true)]
    [string]
    $Environment
)

####################################################################
# Test or Deploy ARM Template Deployment. ##########################

switch ($DeployOrTest) 
{
    'Test' {

        
        # Output Parameters to Pipeline Console.
        ########################################

        Write-Host ""
        Write-Host "##[section]Parameter Values:"
        Write-Host "##[section]     Resource Group  : $ResourceGroupName" 
        Write-Host "##[section]     Azure Location  : $Location"
        Write-Host "##[section]     Environment     : $Environment"
        Write-Host ""

        
        # Test ARM Template with -WhatIf
        #################################

        New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
            -TemplateFile 'webAppLinux\webAppLinux.json' `
            -TemplateParameterFile "webAppLinux\parameters\$Environment.parameters.json" `
            -WhatIf `
            -Verbose
    }

    'Deploy' {

        # Output Parameters to Pipeline Console.
        ########################################

        Write-Host ""
        Write-Host "##[section]Parameter Values:"
        Write-Host "##[section]     Resource Group  : $ResourceGroupName" 
        Write-Host "##[section]     Azure Location  : $Location"
        Write-Host "##[section]     Environment     : $Environment"
        Write-Host ""
        

        # Deploy ARM Template.
        #######################

        New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
            -TemplateFile "$Env:Build_BuildId\webAppLinux\webAppLinux.json" `
            -TemplateParameterFile "$Env:Build_BuildId\webAppLinux\parameters\$Environment.parameters.json" `
            -Verbose `
            -ErrorVariable Errors
            

        # Check For Non Terminating Errors, Stop Pipeline if Found.
        # Required as Pipeline Could Continue if Deployment Has Success & Failures.
        ################################################################################

        if ($Errors) 
        {
            Write-Error "Deployment Failed, Stopping Pipeline..." -ErrorAction Stop
        }
    }
}