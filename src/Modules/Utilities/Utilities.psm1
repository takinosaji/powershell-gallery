#---------------------------------------
#----PRIVATE----------------------------
#---------------------------------------
 
 

#---------------------------------------
#----PUBLIC-----------------------------
#--------------------------------------- 
function Get-BasicAuthHeader {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ParameterSetName = "Normal")]
        [Parameter(ParameterSetName = "NoLogin")]
        [string]$Login,
        [Parameter(Mandatory=$true, ParameterSetName = "Normal")]
        [Parameter(Mandatory=$true, ParameterSetName = "NoLogin")]
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
        [switch]$AllowErrors,
        [switch]$Interactive
    )
 
    begin {
        $commonParams = @{
            'ErrorAction' = $ErrorActionPreference;
            'Verbose' = $VerbosePreference -ne 'SilentlyContinue'
        }

        $isNonInteractiveMode = [bool]([Environment]::GetCommandLineArgs() -like '-noni*')
    }
    process {
        trap {
            if (!$isNonInteractiveMode -and $Interactive) {
                $_ | Out-Default
                $userinput = Read-Host -Prompt 'An error has occured. Type "Yes" if you want to continue. Any other input is considered as "No" and will cause trmination error"'
                if ($userinput -eq 'yes') {
                    continue
                }
            }

            break
        }

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


 
function Merge-HashTables {
    [CmdletBinding()]
    param(
        [hashtable[]]$Hashtables,
        [switch]$Override
    )

    if ($Hashtables.Count -eq 1) {
        return $Hashtables[0]
    }

    $resultHashtable = @{}
    
    for ($i = 0; $i -lt $Hashtables.Count; $i++) {
        $currentHashtableClone = $Hashtables[$i].Clone()

        foreach ($key in $Hashtables[$i].Keys) {

            if ($resultHashtable.ContainsKey($key)) {

                if (!$Override -and 
                    ($resultHashtable[$key] -is [System.Collections.IEnumerable]) -and 
                    ($currentHashtableClone[$key] -is [System.Collections.IEnumerable])) {

                    if (($resultHashtable[$key] -is [System.Collections.Hashtable]) -and 
                        ($currentHashtableClone[$key] -is [System.Collections.Hashtable])) {
                        $resultHashtable[$key] = Merge-HashTables @($resultHashtable[$key], $currentHashtableClone[$key])    
                    } else {
                        $resultHashtable[$key] += $currentHashtableClone[$key]
                    }

                    $currentHashtableClone.Remove($key)
                } else {
                    $resultHashtable.Remove($key)
                }
            }
        }

        $resultHashtable += $currentHashtableClone
    }

    return $resultHashtable
}



#---------------------------------------
#----EXPORTS----------------------------
#---------------------------------------
Export-ModuleMember -Function Get-BasicAuthHeader
Export-ModuleMember -Function Invoke-CmdCommand
Export-ModuleMember -Function Retry-ScriptBlock
Export-ModuleMember -Function Merge-HashTables