#---------------------------------------
#----PRIVATE----------------------------
#---------------------------------------
function Invoke-CmdCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        $ScriptBlock,
        [switch]$AllowErrors
    )

    begin {
        $commonParams = @{
            'ErrorAction' = $ErrorActionPreference;
            'Verbose' = $VerbosePreference -ne 'SilentlyContinue'
        }
    }
    process {
        "Executing: $ScriptBlock" | Out-Default
        Invoke-Command -scriptblock $ScriptBlock @commonParams | Tee-Object -Variable output | Out-Default
        if($LASTEXITCODE -ne 0 -and !$AllowErrors) {
            throw "LastExitCode is $LASTEXITCODE."
        }
        return $output
    }
    end {}
}


#---------------------------------------
#----PUBLIC-----------------------------
#---------------------------------------
function Create-GitBranch {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$RepositoryPath,
        [Parameter(Mandatory=$true)]
        [string]$BaseBranch,
        [Parameter(Mandatory=$true)]
        [string]$TargetBranch,
        [switch]$DeleteIfExists,
        [switch]$PushToRemote,
        [switch]$SwitchBack
    )

    begin {
        $params = @{
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }

        if (!(Test-Path "$RepositoryPath\.git" @params)) {
            throw "Git repository hasnt been found at specified path."
        }
    }
    process {
        trap {
            $currentExecutionPath | Set-Location @params
            break
        }

        $currentExecutionPath = Get-Location @params
        $RepositoryPath | Set-Location @params

        "Getting active branch in current repository" | Out-Default
        $currentBranchName =  Invoke-CmdCommand -scriptblock { git rev-parse --abbrev-ref HEAD } @params
        if($currentBranchName -eq 'HEAD') { throw "Could not get active branch name from $RepositoryPath" }

        "Checking if any remote exist" | Out-Default
        $remotes = Invoke-CmdCommand -scriptblock { git remote } @params
        if (!$remotes) { throw "Local repository [$RepositoryPath] is not connected to any remote repository" }
        $remote = ($remotes -split '\n')[0]

        "Fetching repository database" | Out-Default
        Invoke-CmdCommand -scriptblock { git fetch } @params | Out-Null

        $allBranches = Invoke-CmdCommand -scriptblock { git branch --all } @params |
            Select-Object -Property @{Name="trimmedBranchName"; Expression = {$_.Replace("* ", "").Trim()}} | 
            Select-Object -ExpandProperty trimmedBranchName

        (,"Detected branches:`r`n" + $allBranches) | Write-Verbose

        "Checking if local $BaseBranch exists" | Out-Default
        $baseBranchExists = $allBranches -match "^($BaseBranch|remotes/$remote/$BaseBranch)`$"
        if (!$baseBranchExists) { throw "$BaseBranch does not exist" }

        "Checking if local $TargetBranch exists" | Out-Default
        $localTargetBranchExists = $allBranches -match "^$TargetBranch`$"

        "Checking if remote $TargetBranch exists" | Out-Default
        $remoteTargetBranchExists = $allBranches -match "^remotes/$remote/$TargetBranch`$"

        "Stashing changes if required" | Out-Default
        $currentBranchStashResult = Invoke-CmdCommand -scriptblock { git stash } @params

        "Performing checkout of $BaseBranch" | Out-Default
        Invoke-CmdCommand -scriptblock { git checkout $BaseBranch } @params | Out-Null

        "Performing pulling of $BaseBranch" | Out-Default
        Invoke-CmdCommand -scriptblock { git pull } @params | Out-Null

        "Performing check to find pull-merge conflicts of $BaseBranch" | Out-Default
        $unmergedFilesExist = Invoke-CmdCommand -scriptblock { git ls-files -u } @params
        if($unmergedFilesExist) {
            Invoke-CmdCommand -scriptblock { git reset --hard ORIG_HEAD } @params | Out-Null
            Invoke-CmdCommand -scriptblock { git checkout $currentBranchName } @params | Out-Null
            if($currentBranchStashResult -ne "No local changes to save") {
                Invoke-CmdCommand -scriptblock { git stash pop } @params | Out-Null
            }
            throw "There are merge conflicts in $BaseBranch which havent been resolved."
        }

        if ($DeleteIfExists) {     
            if ($localTargetBranchExists) {
                "Deleting of $TargetBranch localy" | Out-Default    
                Invoke-CmdCommand -scriptblock { git branch -d $TargetBranch } @params | Out-Null
            }
            if ($remoteTargetBranchExists) {
                "Deleting of $TargetBranch from $remote" | Out-Default
                Invoke-CmdCommand -scriptblock { git push --delete $remote refs/heads/$TargetBranch } @params | Out-Null
            }
        }

        $gitAction = if($localTargetBranchExists -and !$DeleteIfExists) {''} else {'-b'}
        "Performing checkout of $TargetBranch" | Out-Default
        Invoke-CmdCommand -scriptblock { git checkout $gitAction $TargetBranch } @params | Out-Null

        if ($localTargetBranchExists -and !$DeleteIfExists) {
            "Pulling $TargetBranch from remote" | Out-Default
            Invoke-CmdCommand -scriptblock { git pull $TargetBranch } @params | Out-Null
        }

        "Performing check to find pull-merge conflicts of $TargetBranch" | Out-Default
        $unmergedFilesExist = Invoke-CmdCommand -scriptblock { git ls-files -u } @params
        if($unmergedFilesExist) {
            Invoke-CmdCommand -scriptblock { git reset --hard ORIG_HEAD } @params | Out-Null
            Invoke-CmdCommand -scriptblock { git checkout $currentBranchName } @params | Out-Null
            if($currentBranchStashResult -ne "No local changes to save") {
                Invoke-CmdCommand -scriptblock { git stash pop } @params | Out-Null
            }
            throw "There are merge conflicts in $TargetBranch which havent been resolved."
        }

        if($gitAction -eq '') {
            "Performing merge of $BaseBranch to $TargetBranch" | Out-Default
            Invoke-CmdCommand -scriptblock { git merge $BaseBranch } @params | Out-Null
        }

        # Get has of commit in HEAD of new branch
        $commitSHA = Invoke-CmdCommand -scriptblock { git rev-parse --verify HEAD } @params

        if($PushToRemote) {
            "Pushing $TargetBranch to remote" | Out-Default
            Invoke-CmdCommand -scriptblock { git push --set-upstream $remote refs/heads/$TargetBranch } @params | Out-Null
        }

        if ($SwitchBack -eq $true) {
            "Performing checkout of $currentBranchName" | Out-Default
            Invoke-CmdCommand -scriptblock { git checkout $currentBranchName } @params | Out-Null
            if($currentBranchStashResult -ne "No local changes to save") {
                "Performing unstash for $currentBranchName if required" | Out-Default
                Invoke-CmdCommand -scriptblock { git stash pop } @params | Out-Null
            }
        }

        $currentExecutionPath | Set-Location @params

        return $commitSHA
    }
    end {}
}

function Clone-GitRepository {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$LocalRepositoryPath,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$RemoteRepositoryUrl
    )

    begin {
        $params = @{
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }
    }
    process {
        trap {       
            if (!!(Test-Path $LocalRepositoryPath)) {
                Remove-Item -Path $LocalRepositoryPath @params
            }
            $currentExecutionPath | Set-Location @params
            break
        }

        $currentExecutionPath = Get-Location @params

        New-Item -Path $LocalRepositoryPath -ItemType Directory @params | Out-Null
        Set-Location $LocalRepositoryPath

        Invoke-CmdCommand -scriptblock { git clone $RemoteRepositoryUrl . } @params | Out-Null

        $currentExecutionPath | Set-Location @params
    }
    end {}
}

function Get-GitTagList {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$RepositoryPath,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Pattern
    )

    begin {
        $params = @{
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }
    }
    process {   
        trap {
            $currentExecutionPath | Set-Location @params
            break
        }

        $currentExecutionPath = Get-Location @params
        $RepositoryPath | Set-Location @params

        $tagStrings = Invoke-CmdCommand -scriptblock { git for-each-ref --sort=-taggerdate  refs/tags/$Pattern } @params
        $parsedTagInfos = $tagStrings | % { 
                            $tagInfoParts = $_ -split '\s'  
                            @{
                                CommitHash = $tagInfoParts[0]
                                Name = $tagInfoParts[2] -replace 'refs/tags/', ''
                            }
                        } @params

        $currentExecutionPath | Set-Location @params

        return $parsedTagInfos
    }
    end {}
}

function Create-GitTag {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$RepositoryPath,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Name,
        [Parameter(Mandatory=$false)]
        [string]$CommitHash,
        [Parameter(Mandatory=$false)]
        [string]$Description,
        [switch]$Annotated,
        [switch]$PushToRemote
    )

    begin {
        $params = @{
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }
    }
    process {
        trap {
            $currentExecutionPath | Set-Location @params
            break
        }

        $currentExecutionPath = Get-Location @params
        $RepositoryPath | Set-Location @params

        $commandText = "git tag {0} $Name {1} -m `"$Description`""

        $annotatedFormat = if ($Annotated) { '-a' } else { '' }
        $commandText = $commandText -replace '\{0\}', $annotatedFormat

        $commitHashFormat = if (!!$CommitHash) { $CommitHash } else { '' }
        $commandText = $commandText -replace '\{1\}', $commitHashFormat

        $scriptBlock = [Scriptblock]::Create($commandText)
        Invoke-CmdCommand -scriptblock $scriptBlock @params | Out-Null

        if ($PushToRemote) { 
            Invoke-CmdCommand -scriptblock { git push origin refs/tags/$Name } | Out-Null
        }

        $currentExecutionPath | Set-Location @params
    }
    end {}
}



#---------------------------------------
#----EXPORTS----------------------------
#---------------------------------------
Export-ModuleMember -Function Create-GitBranch
Export-ModuleMember -Function Clone-GitRepository
Export-ModuleMember -Function Get-GitTagList
Export-ModuleMember -Function Create-GitTag