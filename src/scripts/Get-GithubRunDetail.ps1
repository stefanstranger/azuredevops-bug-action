<#
    PowerShell script to retrieve Annotation information for Github Action workflow.
    More info: https://developer.github.com/v3/
#>

Param( 
    [string]$GithubToken,
    [string]$WorkflowFileName
) 

#region retrieve variables via Environment Variables
Write-Output -InputObject ('Retrieving Environment variable for Github Token value')
$GitHubToken = [Environment]::GetEnvironmentVariable($GithubToken)
$GitHubRepository = [Environment]::GetEnvironmentVariable('GITHUB_REPOSITORY')
$GithubUserName = $GitHubRepository.split('/')[0]
$GithubRepo = $GitHubRepository.split('/')[1]
#endregion

#region get Workflow runs
Write-Output -InputObject ('Get Workflow runs')
$WorkflowFileName = $WorkflowFileName
$uri = ('https://api.github.com/repos/{0}/{1}/actions/workflows/{2}/runs' -f $GithubUserName, $GithubRepo, $WorkflowFileName)
$params = @{
    ContentType = 'application/json'
    Headers     = @{
        'authorization' = "token $($GithubToken)"
        'accept'        = 'application/vnd.github.everest-preview+json'
    }
    Method      = 'Get'
    URI         = $Uri
}
  
$Result = Invoke-RestMethod @params
$global:Html_Url = $($Result.workflow_runs[0].html_url)
#endregion


#region List check runs in a check suite
Write-Output -InputObject ('List check runs in a check suite')
$CheckSuiteId = $($Result.workflow_runs[0].check_suite_url).split('/')[-1]
$uri = ('https://api.github.com/repos/{0}/{1}/check-suites/{2}/check-runs' -f $GithubUserName, $GithubRepo, $CheckSuiteId)
$params = @{
    ContentType = 'application/json'
    Headers     = @{
        'authorization' = "token $($GithubToken)"
        'accept'        = 'application/vnd.github.antiope-preview+json'
    }
    Method      = 'Get'
    URI         = $Uri
}
  
$CheckRuns = Invoke-RestMethod @params
$global:Details_url = $($checkruns.check_runs.details_url)
#endregion