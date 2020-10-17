@{
    Candidates = @(
        @{
            Name = "FriendlyName"
            Project = "AzureDevOpsProject"
            DefinitionId = 1111
            BranchFilter = "master"
            Tags = @( @{ Value = 'SomeTag'; CancelingTags = @('SomeCancelingTag'); ThrowIfExists = $true } )
        }
    )
}	