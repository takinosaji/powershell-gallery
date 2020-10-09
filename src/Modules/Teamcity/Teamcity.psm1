#---------------------------------------
#----PRIVATE----------------------------
#---------------------------------------



#---------------------------------------
#----PUBLIC-----------------------------
#---------------------------------------
function Get-TeamcityProperty {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter(Mandatory=$true)]
        [string]$PlanId,
        [Parameter(Mandatory=$true)]
        [string]$Login,
        [Parameter(Mandatory=$true)]
        [string]$Password,
        [Parameter(Mandatory=$true)]
        [string]$RestApiUrl,
        [Parameter(ParameterSetName="Parameter")]
        [switch]$Parameter,
        [Parameter(ParameterSetName="Setting")]
        [switch]$Setting,
        [Parameter(Mandatory=$false)]
        [string]$Proxy,
        [switch]$Project,
        [switch]$BuildConfiguration
    )

    begin {
        if (!$Project -and !$BuildConfiguration) {
            throw "Please specify property of what kind of Teamcity Plan you want to get using -Project or -BuildConfiguration siwtches"
        }

        $commonParams = @{
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }

        $moduleName = "Utilities"
        "$PSScriptRoot/../../Modules/$moduleName/$moduleName.psd1" | 
            Import-Module -Force -Scope Global @commonParams 
    }
    process {
        $headers = @{ Authorization = (Get-BasicAuthHeader -Login $Login -Password $Password) }
        $params = @{
            Method = 'GET';
            Headers = $headers
        }
        if (!!$Proxy) {
            $params.Proxy = $Proxy
        }

        if($Project) {
            $planType = 'projects'
        } else {
            $planType = 'buildTypes'
        }

        if (!!$Parameter) {
            $propertyPath = "parameters/$Name/value"
        } else {
            $propertyPath = "settings/$Name"
        }

        $uri = "$RestApiUrl/$planType/id:$PlanId/$propertyPath"

        return Invoke-RestMethod -Uri $uri @params @commonParams
    }
    end {}
}

function Put-TeamcityProperty {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter(Mandatory=$true)]
        [string]$Value,
        [Parameter(Mandatory=$true)]
        [string]$PlanId,
        [Parameter(Mandatory=$true)]
        [string]$Login,
        [Parameter(Mandatory=$true)]
        [string]$Password,
        [Parameter(Mandatory=$true)]
        [string]$RestApiUrl,
        [Parameter(ParameterSetName="Parameter")]
        [switch]$Parameter,
        [Parameter(ParameterSetName="Setting")]
        [switch]$Setting,
        [Parameter(Mandatory=$false)]
        [string]$Proxy,
        [switch]$Project,
        [switch]$BuildConfiguration
    )
    begin {
        if (!$Project -and !$BuildConfiguration) {
            throw "Please specify property of what kind of Teamcity Plan you want to get using -Project or -BuildConfiguration siwtches"
        }

        $commonParams = @{
            ErrorAction = $ErrorActionPreference;
            Verbose = $VerbosePreference -ne 'SilentlyContinue'
        }

        $moduleName = "Utilities"
        "$PSScriptRoot/../../Modules/$moduleName/$moduleName.psd1" | 
            Import-Module -Force -Scope Global @commonParams 
    }
    process {
        if (!!$Proxy) {
            $params.Proxy = $Proxy
        }

        if($Project) {
            $planType = 'projects'
        } else {
            $planType = 'buildTypes'
        }

        if (!!$Parameter) {
            $propertyPath = "parameters/$Name/value"
        } else {
            $propertyPath = "settings/$Name"
        }

        $uri = "$RestApiUrl/$planType/id:$PlanId/$propertyPath"
        $headers = @{ Authorization = (Get-BasicAuthHeader -Login $Login -Password $Password) }
        $params = @{
            Uri = $uri
            Method = 'PUT'
            Headers = $headers
            Body = $Value
            ContentType = "text/plain"
        }

        return Invoke-RestMethod @params @commonParams
    }
    end {}
}

function Trigger-TeamcityBuild {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$BuildConfigurationId,
        [Parameter(Mandatory=$true)]
        [string]$Login,
        [Parameter(Mandatory=$true)]
        [string]$Password,
        [Parameter(Mandatory=$true)]
        [string]$RestApiUrl,
        [Parameter(Mandatory=$false)]
        [hashtable]$Properties,
        [Parameter(Mandatory=$false)]
        [string]$Proxy,
        [switch]$Personal
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
        if (!!$Proxy) {
            $params.Proxy = $Proxy
        }

        $propertyText = ""
        foreach ($key in $Properties.Keys) {
            $value = $Properties[$key]
            $propertyText = $propertyText + "<property name=`"$key`" value=`"$value`"/>"
        }

        $node =
"<build personal=`"$Personal`">
    <buildType id=`"$BuildConfigurationId`"/>
    <comment><text>Triggered using Powershell Gallery</text></comment>
    <properties>
        $propertyText
    </properties>
</build>"
        $uri = "$RestApiUrl/buildQueue"
        $headers = @{ Authorization = (Get-BasicAuthHeader -Login $Login -Password $Password) }
        $params = @{
            Uri = $uri
            Method = 'POST'
            Headers = $headers
            Body = $node
            ContentType = "application/xml"
        }

        return Invoke-RestMethod @params @commonParams
    }
    end {}
}



#---------------------------------------
#----------------EXPORTS----------------
#---------------------------------------
Export-ModuleMember -Function Get-TeamcityProperty
Export-ModuleMember -Function Put-TeamcityProperty
Export-ModuleMember -Function Trigger-TeamcityBuild