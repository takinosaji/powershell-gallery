#---------------------------------------
#----PRIVATE----------------------------
#---------------------------------------
 
 

#---------------------------------------
#----PUBLIC-----------------------------
#--------------------------------------- 
function Get-BasicAuthHeader {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Login,
        [Parameter(Mandatory=$true)]
        [string]$Password
    )
    Begin {}
    Process {
        $pair = "$($Login):$($Password)"
        $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
        return "Basic $encodedCreds"
    }
    End {}
}



function Invoke-CmdCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        $ScriptBlock,
        [Parameter(Mandatory = $false)]
        [int[]]$AllowedExitCodes,
        [Parameter(Mandatory = $false)]
        [switch]$AllowErrors
    )
 
    begin {
        $commonParams = @{
            'ErrorAction' = $ErrorActionPreference;
            'Verbose' = $VerbosePreference -ne 'SilentlyContinue'
        }
    }
    process {
        "Executing: $ScriptBlock" | Write-Verbose
        Invoke-Command -scriptblock $ScriptBlock @commonParams | Tee-Object -Variable output | Out-Default
        if ($LASTEXITCODE -ne 0) {
            if ($AllowErrors -or ($AllowedExitCodes -contains $LASTEXITCODE)) {
                return $output
            }
 
            throw "LastExitCode is $LASTEXITCODE."
        } 
            
        return $output
    }
    end {}
}


 
function Retry-ScriptBlock {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)]
        [scriptblock]$ScriptBlock,
    
        [Parameter(Mandatory=$false)]
        [int]$MaxAttempts = 3,
    
        [Parameter(Mandatory=$false)]
        [int]$DelaySeconds = 60
    )
    
    begin {
        $counter = 0
    }
    
    process {
        do {
            $counter++
            try {
                Write-Host "Executing $counter/$MaxAttempts attempt ..."
                return $ScriptBlock.Invoke()
            } catch {
                Write-Warning $_.Exception.InnerException.Message
                Start-Sleep -Milliseconds ($DelaySeconds*1000)
            }
        } while ($counter -lt $MaxAttempts)
    
        # Throw an error after # unsuccessful invocations. Doesn't need
        # a condition, since the function returns upon successful invocation.
        throw 'Execution failed. Won`t keep retrying.'
    }
 
    end {}
}


 
#---------------------------------------
#----EXPORTS----------------------------
#---------------------------------------
Export-ModuleMember -Function Get-BasicAuthHeader
Export-ModuleMember -Function Invoke-CmdCommand
Export-ModuleMember -Function Retry-ScriptBlock