function OutWarning ( [String] $Message ) {
    Add-AppVeyorMessage -Message $Message -Category 'Warning'
    Write-Warning -Message "`n$Message`n"
}

function OutInfo ( [String] $Message ) {
    Add-AppVeyorMessage -Message $Message -Category 'Information'
    Write-Host -Object "`n$Message`n" -ForegroundColor 'Yellow'
}

$message = $null
$messageForm = "Skipping publish to the PowerShell Gallery & GitHub for {0}: '{1}'."
$skipKeyword = 'skip publish'
$commitMessageKeyword = 'commit message keyword'

if ( $env:APPVEYOR -ne $true ) {
    Write-Warning -Message ( $messageForm -f 'continuous integration platform', $env:CI_NAME )
}
elseif ( $env:APPVEYOR_REPO_COMMIT_MESSAGE -match "\[${skipKeyword}\]" ) {
    OutWarning( ( $messageForm -f $commitMessageKeyword, "[${skipKeyword}]" ) )
}
elseif ( $env:APPVEYOR_REPO_TAG -eq $true ) {
    OutWarning( ( $messageForm -f 'tag build', $true ) )
}
elseif ( $env:CI_PULL_REQUEST -gt 0 ) {
    OutWarning( ( $messageForm -f 'pull request', $env:CI_PULL_REQUEST ) )
}
elseif ( $env:APPVEYOR_JOB_NUMBER -ne 1 ) {
    OutWarning( ( $messageForm -f 'job', $env:APPVEYOR_JOB_NUMBER ) )
}
elseif ( $env:APPVEYOR_JOB_NUMBER -eq 1 ) {
    $publishForm = "Publishing module: '{0}' version: '{1}' to {2}."

    if ( $env:CI_BRANCH -eq 'master' ) {
        $skipKeyword = 'skip psgallery'
        if ( $env:APPVEYOR_REPO_COMMIT_MESSAGE -match "\[${skipKeyword}\]" ) {
            OutWarning( ( $messageForm -f $commitMessageKeyword, "[${skipKeyword}]" ) )
        }
        else {
            OutInfo( ( $publishForm -f $env:CI_PROJECT_NAME, $env:CI_MODULE_VERSION, 'The PowerShell Gallery' ) )

            # Publish the new version to the PowerShell Gallery
            Publish-Module -Path $env:CI_MODULE_PATH -NuGetApiKey $env:NUGET_API_KEY -ErrorAction 'Stop'
        }
    }

    OutInfo( ( $publishForm -f $env:CI_MODULE_NAME, $env:APPVEYOR_BUILD_VERSION, 'GitHub' ) )

    # Publish the new version back to GitHub
    git checkout --quiet $env:CI_BRANCH
    git add --all
    git status
    git commit --signoff --message "${env:CI_NAME}: Update version to ${env:CI_MODULE_VERSION} [ci skip]"
    git push --porcelain --set-upstream origin $env:CI_BRANCH

    if ( $env:CI_BRANCH -eq 'master' ) {
        $tag = "v${env:CI_MODULE_VERSION}"
        git tag --annotate $tag --message $tag
        git push --porcelain origin $tag
    }

    Write-Host -Object ''
}
else {
    throw 'Unknown deployment condition.'
}
