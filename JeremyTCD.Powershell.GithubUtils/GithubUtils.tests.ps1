# $PSCommandPath holds the path of the current file
# Split-Path $PSCommandPath returns the directory of the current file
# Set-Location is equivalent to cd in cmd.exe
Split-Path $PSCommandPath | Set-Location
Import-Module (".\" + (Split-Path -Leaf $PSCommandPath).Replace(".tests.ps1", ".psd1"))

Describe "Set-GithubReleaseFromTag" {
	Context "When tag exists"{
		# Arrange
		$testOwner = 'testOwner'
		$testRepo = 'testRepo'
		$testToken = 'testToken'
		$testMessage = 'testMessage'
		$testTag = 'testTag'
		$testBranch = 'testBranch'

		Mock -ModuleName GithubUtils Read-GitTagMessage { return $testMessage}
		Mock -ModuleName GithubUtils Invoke-RestMethod {} 

		# Act
		Set-GithubReleaseFromTag $testTag $testOwner $testRepo $testBranch $testToken 

		# Assert
		# TODO simplify
		It "Calls Invoke-ResetMethod" {
			$headers = New-Object 'System.Collections.Generic.Dictionary[[String],[String]]'
			$headers.Add('Authorization', "token $testToken")
			$input = @{
			  tag_name = $testTag
			  target_commitish = $testBranch
			  name = $testTag
			  body = $testMessage
			  draft = $false
			  prerelease = $testTag.Contains('-')
			}
			$inputAsJson = $input | ConvertTo-Json

			Assert-MockCalled -ModuleName GithubUtils Invoke-RestMethod 1 -ParameterFilter{
				$Uri -eq "https://api.github.com/repos/$testOwner/$testRepo/releases" -and `
				$Method -eq 'Post' -and `
				$Headers -eq $headers -and `
				$Body -eq $inputAsJson
				$ContentType -eq 'application/json'
			}
		}
	}
} 