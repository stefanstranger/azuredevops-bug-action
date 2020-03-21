<#
    PowerShell script to create an Azure DevOps Bug work item.

    Pre-requisites:
    - PowerShell Module VSteam
    
#>

Param( 
    [string]$OrganizationName,
    [string]$PAT,
    [string]$ProjectName,
    [string]$AreaPath,
    [string]$IterationPath,
    [string]$GithubToken,
    [string]$WorkflowFileName
) 

#region Output for input fields
Write-Output -InputObject ('Input fields:')
Write-Output -InputObject ('OrganizationName: {0}' -f $OrganizationName)
Write-Output -InputObject ('ProjectName: {0}' -f $ProjectName)
Write-Output -InputObject ('AreaPath: {0}' -f $AreaPath)
Write-Output -InputObject ('WorkflowFileName: {0}' -f $WorkflowFileName)
#endregion

#region call Get-GithubRunDetail.ps1 script
\tmp\scripts\\Get-GithubRunDetail.ps1 -GithubToken $GithubToken -WorkflowFileName $WorkflowFileName
#endregion

#region retrieve ServiceConnection Secret via Environment Variable
Write-Output -InputObject ('Retrieving Environment variable for PAT value')
$PATValue = [Environment]::GetEnvironmentVariable($PAT)
#endregion

#region variables
$WorkflowName = $($env:GITHUB_WORKFLOW)
$Repository = $($env:GITHUB_REPOSITORY)
$BugTitle = ('Github Workflow failed - {0} - {1}' -f $($env:GITHUB_WORKFLOW), $(Get-Date -format 'yyyyMMddhhmmss'))
#endregion

#region authenticate
Set-VSTeamAccount -Account $OrganizationName -PersonalAccessToken $PATValue
Set-VSTeamDefaultProject $ProjectName
#endregion

#region create Bug WorkItem
$ReproSteps = @"
<p><span style="color: red;"> <strong>The Workflow $WorkflowName in $Repository failed!</strong></span></p>
<table>
<tr>
<td>Github Repository</td>
<td>$Repository</td>
</tr>
<tr>
<td>Workflow Name</td>
<td>$WorkflowName</td>
</tr>
<tr>
<td>Github Run</td>
<td><a href="$Html_url">$Html_url</a></td>
</tr>
<tr>
<td>Github Run Details</td>
<td><a href="$Details_url">$Details_url</a></td>
</tr>
</table>
"@
$additionalFields = @{"System.AreaPath" = $AreaPath; 'Microsoft.VSTS.TCM.ReproSteps' = $ReproSteps }
$params = @{
    'Title'            = $BugTitle
    'WorkItemType'     = 'Bug'
    'Description'      = 'This is a description'
    'AdditionalFields' = $additionalFields
    'IterationPath'    = $IterationPath

}
Write-Output -InputObject ('Creating Azure DevOps Bug WorkItem')
Add-VSTeamWorkItem @params
#endregion