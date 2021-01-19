#---------------------------------------
#----PRIVATE----------------------------
#---------------------------------------
 
 

#---------------------------------------
#----PUBLIC-----------------------------
#--------------------------------------- 
function Get-Builds {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$RestApiUrl,    
        [Parameter(Mandatory=$true)]
        [string]$Collection,     
        [Parameter(Mandatory=$true)]
        [string]$Project,    
        [Parameter(Mandatory=$true)]
        [string]$Token,  
        [Parameter(Mandatory=$false)]
        [hashtable[]]$QueryParameters,
        [Parameter(Mandatory=$false)]
        [string]$Proxy,
        [Parameter(Mandatory=$false)]
        [int]$TimeoutSec = 300
    )
    
    begin {
        if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }

        $commonParams = @{
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }

        $moduleName = "Utilities"
        "$PSScriptRoot/../../Modules/$moduleName/$moduleName.psd1" | 
            Import-Module -Force -Scope Global @commonParams 
    }

    process {
        $authHeader = Get-BasicAuthHeader -Password $Token
        
        if(!!$QueryParameters) {
            $keyValuePairs = $QueryParameters | % { "$($_.Key)=$($_.Value)" }
            $query = [String]::Join('&', $keyValuePairs)
        }

        $params = @{
            Uri = "$RestApiUrl/$Collection/$Project/_apis/build/builds?$query"
            Method = "GET"
            Headers = @{ Authorization = $authHeader }
            TimeoutSec =  $TimeoutSec
        }
        if (!!$Proxy) {
            $params.Proxy = $Proxy
        }
        
        return Invoke-RestMethod @params @commonParams
    }
    end {}
}



function Update-Build {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$RestApiUrl,    
        [Parameter(Mandatory=$true)]
        [string]$Collection,     
        [Parameter(Mandatory=$true)]
        [string]$Project,    
        [Parameter(Mandatory=$true)]
        [string]$Token,     
        [Parameter(Mandatory=$true)]
        [int]$BuildId,  
        [Parameter(Mandatory=$true)]
        [hashtable]$UpdateParameters,
        [Parameter(Mandatory=$false)]
        [string]$ApiVersion = "5.0",
        [Parameter(Mandatory=$false)]
        [string]$Proxy,
        [Parameter(Mandatory=$false)]
        [int]$TimeoutSec = 300
    )
    
    begin {
        if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }

        $commonParams = @{
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }

        $moduleName = "Utilities"
        "$PSScriptRoot/../../Modules/$moduleName/$moduleName.psd1" | 
            Import-Module -Force -Scope Global @commonParams 
    }

    process {
        $authHeader = Get-BasicAuthHeader -Password $Token

        $params = @{
            Uri = "$RestApiUrl/$Collection/$Project/_apis/build/builds/$($BuildId)?api-version=$ApiVersion"
            Method = "PATCH"
            Headers = @{ Authorization = $authHeader }
            TimeoutSec =  $TimeoutSec
        }
        if (!!$Proxy) {
            $params.Proxy = $Proxy
        }
        
        return Invoke-RestMethod -ContentType 'application/json' `
                                 -Body (ConvertTo-Json $UpdateParameters) `
                                 @params `
                                 @commonParams
    }
    end {}
}



function Tag-Build {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$RestApiUrl,    
        [Parameter(Mandatory=$true)]
        [string]$Collection,     
        [Parameter(Mandatory=$true)]
        [string]$Project,    
        [Parameter(Mandatory=$true)]
        [string]$Token,     
        [Parameter(Mandatory=$true)]
        [int]$BuildId,  
        [Parameter(Mandatory=$true)]
        [string]$Tag,
        [Parameter(Mandatory=$false)]
        [string]$ApiVersion = "5.0",
        [Parameter(Mandatory=$false)]
        [string]$Proxy,
        [Parameter(Mandatory=$false)]
        [int]$TimeoutSec = 300
    )
    
    begin {
        if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }

        $commonParams = @{
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }

        $moduleName = "Utilities"
        "$PSScriptRoot/../../Modules/$moduleName/$moduleName.psd1" | 
            Import-Module -Force -Scope Global @commonParams 
    }

    process {
        $authHeader = Get-BasicAuthHeader -Password $Token

        $params = @{
            Uri = "$RestApiUrl/$Collection/$Project/_apis/build/builds/$BuildId/tags/$($Tag)?api-version=$ApiVersion"
            Method = "PUT"
            Headers = @{ Authorization = $authHeader }
            TimeoutSec =  $TimeoutSec
        }
        if (!!$Proxy) {
            $params.Proxy = $Proxy
        }
        
        return Invoke-RestMethod @params @commonParams
    }
    end {}
}



function Create-PullRequest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$RestApiUrl,    
        [Parameter(Mandatory=$true)]
        [string]$Collection,     
        [Parameter(Mandatory=$true)]
        [string]$Project,    
        [Parameter(Mandatory=$true)]
        [string]$Token,     
        [Parameter(Mandatory=$true)]
        [string]$RepositoryId,  
        [Parameter(Mandatory=$true)]
        [string]$SourceBranch, 
        [Parameter(Mandatory=$true)]
        [string]$TargetBranch, 
        [Parameter(Mandatory=$false)]
        [string]$AutoCompleteSetBy,
        [Parameter(Mandatory=$false)]
        [string]$ApiVersion = "5.0",
        [Parameter(Mandatory=$false)]
        [string]$Proxy,
        [Parameter(Mandatory=$false)]
        [int]$TimeoutSec = 300
    )
    
    begin {
        if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }

        $commonParams = @{
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }

        $moduleName = "WK.Utilities"
        "$PSScriptRoot/../../Modules/$moduleName/$moduleName.psd1" | 
            Import-Module -Force -Scope Global @commonParams 
    }

    process {
        $authHeader = Get-BasicAuthHeader -Password $Token

        $params = @{
            Uri = "$RestApiUrl/$Collection/$Project/_apis/git/repositories/$RepositoryId/pullrequests?api-version=$ApiVersion"
            Method = "POST"
            Headers = @{ Authorization = $authHeader }
            TimeoutSec =  $TimeoutSec
        }   
        if (!!$Proxy) {
            $params.Proxy = $Proxy
        }

        $body = {
            sourceRefName = $SourceBranch
            targetRefName = $TargetBranch
            title = "A new feature"
            description = "Adding a new feature"
        }
        
        return Invoke-RestMethod -ContentType 'application/json' `
                                 -Body (ConvertTo-Json $body) `
                                 @params `
                                 @commonParams
    }
    end {}
}



function Get-Repositories {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$RestApiUrl,    
        [Parameter(Mandatory=$true)]
        [string]$Collection,     
        [Parameter(Mandatory=$true)]
        [string]$Project,    
        [Parameter(Mandatory=$true)]
        [string]$Token,
        [Parameter(Mandatory=$false)]
        [string]$Proxy,
        [Parameter(Mandatory=$false)]
        [int]$TimeoutSec = 300
    )
    
    begin {
        if (!$PSBoundParameters.ContainsKey('ErrorAction')) { $ErrorActionPreference = 'Stop' }

        $commonParams = @{
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }

        $moduleName = "WK.Utilities"
        "$PSScriptRoot/../../Modules/$moduleName/$moduleName.psd1" | 
            Import-Module -Force -Scope Global @commonParams 
    }

    process {
        $authHeader = Get-BasicAuthHeader -Password $Token
   
        $params = @{
            Uri = "$RestApiUrl/$Collection/$Project/_apis/git/repositories?api-version=$ApiVersion"
            Method = "GET"
            Headers = @{ Authorization = $authHeader }
            TimeoutSec =  $TimeoutSec
        }
        if (!!$Proxy) {
            $params.Proxy = $Proxy
        }
        
        return Invoke-RestMethod @params @commonParams
    }
    end {}
}
 
#---------------------------------------
#----EXPORTS----------------------------
#---------------------------------------
Export-ModuleMember -Function Get-Builds
Export-ModuleMember -Function Update-Build
Export-ModuleMember -Function Tag-Build