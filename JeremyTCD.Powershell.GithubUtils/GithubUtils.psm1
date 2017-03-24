function Edit-GithubRelease {
	param([string] $input,
		[string] $owner,
		[string] $repo,
		[string] $id,
		[string] $token)

	$inputAsJson = @{body = $input} | ConvertTo-Json

	$url = "https://api.github.com/repos/$owner/$repo/releases/$id"
	Write-Host "Url: $url"

	$headers = New-Object 'System.Collections.Generic.Dictionary[[String],[String]]'
	$headers.Add('Authorization', "token $token")

	Invoke-RestMethod $url -Headers $headers -Method Patch -Body $inputAsJson -ContentType 'application/json'
}

function Set-GithubReleaseFromTag{
	param([string] $tag,
		[string] $owner,
		[string] $repo,
		[string] $branch,
		[string] $token)

	$message = Read-GitTagMessage $tag

	$input = @{
	  tag_name = $tag
	  target_commitish = $branch
	  name = $tag
	  body = $message
	  draft = $false
	  prerelease = $tag.Contains('-')
	}
	$inputAsJson = $input | ConvertTo-Json

	$url = "https://api.github.com/repos/$owner/$repo/releases"

	$headers = New-Object 'System.Collections.Generic.Dictionary[[String],[String]]'
	$headers.Add('Authorization', "token $token")

	Invoke-RestMethod $url -Headers $headers -Method Post -Body $inputAsJson -ContentType 'application/json'
}