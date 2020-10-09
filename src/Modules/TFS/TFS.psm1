$TFSParameters = @{
    ApiVersionNumber = '3.0-preview.3'
}



function Find-TFSReleaseDefinitions
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$ReleaseDefinitionName,
        [Parameter(Mandatory=$true)]
        [string]$ReleaseApiUrl,
        [Parameter(Mandatory=$false)]
        [string]$AccessToken,
        [Parameter(Mandatory=$false)]
        [string]$Proxy
    )
    begin {
        $commonParams = @{        
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }

        $moduleName = "Utilities"
        "$PSScriptRoot/../../Modules/$moduleName/$moduleName.psd1" | 
            Import-Module -Force -Scope Global @commonParams 
    }
    process {       
        $headers = @{ "Content-Type" = "application/json" } 

        $releaseDefinitionsUri =  "$ReleaseApiUrl/definitions?api-version=$($TFSParameters.ApiVersionNumber)"
        $params = @{
            Uri = $releaseDefinitionsUri
            Method = 'GET'
            Headers = $headers
        }

        if ($AccessToken) {
            $headers.Authorization = Get-BasicAuthHeader -Token $AccessToken @commonParams     
        }
        else {       
            $params.UseDefaultCredentials = $true
        }

        if (!!$Proxy) {
            $params.Proxy = $Proxy
        }
        $response = Invoke-RestMethod @params @commonParams
        return $response.value
    }
    end {} 
}

function Find-TFSReleaseDefinition
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [int]$ReleaseDefinitionId,
        [Parameter(Mandatory=$true)]
        [string]$ReleaseApiUrl,
        [Parameter(Mandatory=$false)]
        [string]$AccessToken,
        [Parameter(Mandatory=$false)]
        [string]$Proxy
    )
    begin {
        $commonParams = @{        
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }

        $moduleName = "Utilities"
        "$PSScriptRoot/../../Modules/$moduleName/$moduleName.psd1" | 
            Import-Module -Force -Scope Global @commonParams 
    }
    process {
        $headers = @{ "Content-Type" = "application/json" }   

        $releaseDefinitionsUri =  "$ReleaseApiUrl/definitions/$($ReleaseDefinitionId)?api-version=$($TFSParameters.ApiVersionNumber)"     
        $params = @{
            Uri = $releaseDefinitionsUri
            Method = 'GET'
            Headers = $headers
        }
        if ($AccessToken) {
            $headers.Authorization = Get-BasicAuthHeader -Token $AccessToken @commonParams     
        }
        else {       
            $params.UseDefaultCredentials = $true
        }

        if (!!$Proxy) {
            $params.Proxy = $Proxy
        }
        $response = Invoke-RestMethod @params @commonParams
        return $response
    }
    end {} 
}

function Find-TFSRelease
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$ReleaseDefinitionId,
        [Parameter(Mandatory=$true)]
        [string]$ReleaseNumber,
        [Parameter(Mandatory=$true)]
        [string]$ReleaseApiUrl,
        [Parameter(Mandatory=$false)]
        [int]$Top = 10,
        [Parameter(Mandatory=$false)]
        [string]$AccessToken,
        [Parameter(Mandatory=$false)]
        [string]$Proxy
    )
    begin {
        $commonParams = @{        
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }

        $moduleName = "Utilities"
        "$PSScriptRoot/../../Modules/$moduleName/$moduleName.psd1" | 
            Import-Module -Force -Scope Global @commonParams 
    }
    process {
        $headers = @{ "Content-Type" = "application/json" }
        
        $releasesUri =  "$ReleaseApiUrl/Releases?definitionId=$ReleaseDefinitionId&top=$Top&api-version=$($TFSParameters.ApiVersionNumber)"
        $params = @{
            Uri = $releasesUri
            Method = 'GET'
            Headers = $headers
        }
        if ($AccessToken) {
            $headers.Authorization = Get-BasicAuthHeader -Token $AccessToken @commonParams     
        }
        else {       
            $params.UseDefaultCredentials = $true
        }

        if (!!$Proxy) {
            $params.Proxy = $Proxy
        }
        $response = Invoke-RestMethod @params @commonParams
        return $response.value | ? name -like "* $ReleaseNumber *"
    }
    end {} 
}

function Start-TFSRelease
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [int]$ReleaseId,
        [Parameter(Mandatory=$true)]
        [int]$EnvironmentId,
        [Parameter(Mandatory=$true)]
        [string]$ReleaseApiUrl,
        [Parameter(Mandatory=$false)]
        [string]$AccessToken,
        [Parameter(Mandatory=$false)]
        [string]$Proxy
    )
    begin {
        $commonParams = @{        
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }

        $moduleName = "Utilities"
        "$PSScriptRoot/../../Modules/$moduleName/$moduleName.psd1" | 
            Import-Module -Force -Scope Global @commonParams 
    }
    process {
        $headers = @{ "Content-Type" = "application/json" }
        
        $deployReleaseUri = 
            "$ReleaseApiUrl/releases/$($ReleaseId)/environments/$($EnvironmentId)?api-version=$($TFSParameters.ApiVersionNumber)"
        $params = @{
            Uri = $DeployReleaseUri
            Body = '{"status":"inprogress"}'
            Method = 'PATCH'
            Headers = $headers
        }
        if ($AccessToken) {
            $headers.Authorization = Get-BasicAuthHeader -Token $AccessToken @commonParams     
        }
        else {       
            $params.UseDefaultCredentials = $true
        }

        if (!!$Proxy) {
            $params.Proxy = $Proxy
        }
        return Invoke-RestMethod @params @commonParams
    }
    end {} 
}

function Create-TFSRelease
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [int]$ReleaseDefinitionId,
        [Parameter(Mandatory=$true)]
        [string]$ReleaseDescription,
        [Parameter(Mandatory=$true)]
        [string]$ReleaseApiUrl,
        [Parameter(Mandatory=$false)]
        [string]$AccessToken,
        [Parameter(Mandatory=$false)]
        [string]$Proxy
    )
    begin {
        $commonParams = @{        
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }

        $moduleName = "Utilities"
        "$PSScriptRoot/../../Modules/$moduleName/$moduleName.psd1" | 
            Import-Module -Force -Scope Global @commonParams 
    }
    process {
        $headers = @{ "Content-Type" = "application/json" }
        
        $createReleaseUri = "$ReleaseApiUrl/releases?api-version=$($TFSParameters.ApiVersionNumber)"
        $createReleasePayloadObject = @{
            definitionId = $ReleaseDefinitionId
            description = $ReleaseDescription
            artifacts = @()
        }
        $body = $createReleasePayloadObject | ConvertTo-Json -Compress -Depth 8
        $params = @{
            Uri = $createReleaseUri
            Body = $body
            Method = 'POST'
            Headers = $headers
        }
        "Create TFS Release body: $body" | Write-Verbose

        if ($AccessToken) {
            $headers.Authorization = Get-BasicAuthHeader -Token $AccessToken @commonParams     
        }
        else {       
            $params.UseDefaultCredentials = $true
        }

        if (!!$Proxy) {
            $params.Proxy = $Proxy
        }

        return Invoke-RestMethod @params @commonParams
    }
    end {} 
}

function Update-TFSRelease
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        $ReleaseResponse,
        [Parameter(Mandatory=$true)]
        [hashtable]$Variables,
        [Parameter(Mandatory=$true)]
        [string]$ReleaseApiUrl,
        [Parameter(Mandatory=$false)]
        [string]$AccessToken,
        [Parameter(Mandatory=$false)]
        [string]$Proxy
    )
    begin {
        $commonParams = @{        
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }

        $moduleName = "Utilities"
        "$PSScriptRoot/../../Modules/$moduleName/$moduleName.psd1" | 
            Import-Module -Force -Scope Global @commonParams 
    }
    process {
        $headers = @{ "Content-Type" = "application/json" }
        
        $updatedFields = @{ variables = $ReleaseResponse.variables }
        $updatedFields.modifiedBy = 'null'
        $updatedFields.modifiedOn = 'null'
        $updatedFields.status = 'active'
    
        $Variables.Keys | % { 
            if($updatedFields.variables[$_]) {
                $updatedFields.variables[$_].value = $Variables[$_]
            }
        }

        $releaseUri = "$ReleaseApiUrl/releases/$($ReleaseResponse.id)?api-version=$($TFSParameters.ApiVersionNumber)"
        $body = $updatedFields | ConvertTo-Json -Compress -Depth 8
        $params = @{
            Uri = $releaseUri
            Body = $body
            Method = 'PATCH'
            Headers = $headers
        }
        "Update TFS Release body: $body" | Write-Verbose

        if ($AccessToken) {
            $headers.Authorization = Get-BasicAuthHeader -Token $AccessToken @commonParams     
        }
        else {       
            $params.UseDefaultCredentials = $true
        }

        if (!!$Proxy) {
            $params.Proxy = $Proxy
        }
        #update release number
        return Invoke-RestMethod @params @commonParams
    }
    end {} 
}

function Update-TFSReleaseDefinition
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        $ReleaseDefinitionResponse,
        [Parameter(Mandatory=$true)]
        [hashtable]$Variables,
        [Parameter(Mandatory=$true)]
        [string]$ReleaseApiUrl,
        [Parameter(Mandatory=$false)]
        [string]$AccessToken,
        [Parameter(Mandatory=$false)]
        [string]$Proxy
    )
    begin {
        $commonParams = @{        
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }

        $moduleName = "Utilities"
        "$PSScriptRoot/../../Modules/$moduleName/$moduleName.psd1" | 
            Import-Module -Force -Scope Global @commonParams 
    }
    process {
        $headers = @{ "Content-Type" = "application/json" }
        
        $releaseDefinitionUri =  "$ReleaseApiUrl/definitions/$($ReleaseDefinitionResponse.id)?api-version=$($TFSParameters.ApiVersionNumber)"        
        $Variables.Keys | % { 
            if($ReleaseDefinitionResponse.variables.$_) {
                $ReleaseDefinitionResponse.variables.$_.value = $Variables.$_
            }
        }
        $body = $ReleaseDefinitionResponse | ConvertTo-Json -Compress -Depth 16
        $params = @{
            Uri = $releaseDefinitionUri
            Body = $body
            Method = 'PUT'
            Headers = $headers
        }    
        "Update TFS ReleaseDefinition body: $body" | Write-Verbose

        if ($AccessToken) {
            $headers.Authorization = Get-BasicAuthHeader -Token $AccessToken @commonParams     
        }
        else {       
            $params.UseDefaultCredentials = $true
        }
        
        if (!!$Proxy) {
            $params.Proxy = $Proxy
        }

        #update release number
        return Invoke-RestMethod @params @commonParams
    }
    end {} 
}

function  Get-TFSReleaseDetails
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [int]$ReleaseId,
        [Parameter(Mandatory=$true)]
        [string]$ReleaseApiUrl,
        [Parameter(Mandatory=$false)]
        [string]$AccessToken,
        [Parameter(Mandatory=$false)]
        [string]$Proxy
    )
    begin {
        $commonParams = @{        
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }

        $moduleName = "Utilities"
        "$PSScriptRoot/../../Modules/$moduleName/$moduleName.psd1" | 
            Import-Module -Force -Scope Global @commonParams 
    }
    process {
        $headers = @{ "Content-Type" = "application/json" }
        
        $releaseDetailUri = "$ReleaseApiUrl/releases/$($ReleaseId)?includeAllApprovals=true"
        $params = @{
            Uri = $releaseDetailUri
            Method = 'GET'
            Headers = $headers
        }
        
        if ($AccessToken) {
            $headers.Authorization = Get-BasicAuthHeader -Token $AccessToken @commonParams     
        }
        else {       
            $params.UseDefaultCredentials = $true
        }
       
        if (!!$Proxy) {
            $params.Proxy = $Proxy
        }
        return Invoke-RestMethod @params @commonParams
    }
    end {} 
}

function  Wait-TFSRelease
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [int]$ReleaseId,
        [Parameter(Mandatory=$true)]
        [string]$EnvironmentName,
        [Parameter(Mandatory=$true)]
        [string]$ReleaseApiUrl,
        [Parameter(Mandatory=$false)]
        [string]$AccessToken,
        [Parameter(Mandatory=$false)]
        [string]$IntervalSeconds = 5,
        [Parameter(Mandatory=$false)]
        [string]$TimeoutMinutes = 20,
        [Parameter(Mandatory=$false)]
        [string]$Proxy
    )
    begin {
        $commonParams = @{        
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }
    }
    process {
        $startTime = Get-Date

        while ($true) {
            $currentTime = Get-Date
            $timeDiff = $currentTime - $startTime
            if ($timeDiff.TotalMinutes -ge $TimeoutMinutes) {
                return "timedOut"
            }

            $releaseDetailResponse = $ReleaseId | Get-TFSReleaseDetails -ReleaseApiUrl $ReleaseApiUrl `
                                                                        -AccessToken $AccessToken `
                                                                        -Proxy $Proxy `
                                                                        @commonParams
            $releaseToEnvironment = $releaseDetailResponse.environments | ? name -eq $EnvironmentName
            "Current TFS release status for $($releaseToEnvironment.name): $($releaseToEnvironment.status)" | Out-Default
            switch ($releaseToEnvironment.status) {
                "succeeded" { return "succeeded" }
                "partiallySucceeded" { return "partiallySucceeded" }
                "rejected" { return "rejected" }
                "failed" { return "failed" }
                "canceled" { return "canceled" }
                Default { start-sleep -seconds $IntervalSeconds }
            }            
        }
    }
    end {} 
}


#---------------------------------------
#---------------FUNCTIONS---------------
#--------------------------------------- 
Export-ModuleMember -Function Find-TFSReleaseDefinitions
Export-ModuleMember -Function Find-TFSReleaseDefinition
Export-ModuleMember -Function Find-TFSRelease
Export-ModuleMember -Function Start-TFSRelease
Export-ModuleMember -Function Create-TFSRelease
Export-ModuleMember -Function Update-TFSRelease
Export-ModuleMember -Function Update-TFSReleaseDefinition
Export-ModuleMember -Function Get-TFSReleaseDetails
Export-ModuleMember -Function Wait-TFSRelease


#---------------------------------------
#---------------VARIABLES---------------
#---------------------------------------