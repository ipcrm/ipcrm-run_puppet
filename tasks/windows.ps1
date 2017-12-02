[CmdletBinding()]
Param(
  [Parameter(Mandatory = $False)]
  [String]
  $noop
)

if ($noop -eq 'true') {
  $noop_arg = '--noop'
} elseif ($noop -eq $null -or $noop -eq "" -or $noop -eq "false") {
  $noop_arg = '--no-noop'
} else {
  Throw "Unknown argument value for 'noop'.  Accepts true/false, not [${noop}]"
}

try {
 $out = Invoke-Command -ScriptBlock {puppet agent -t ${noop_arg} 2>&1}
} catch {
 $e = $_
}
$rt = $LASTEXITCODE
$msg = $out | Out-string

If(@(0,2).contains($rt))
{
  "{ status: 'success', message: $msg, resultcode: $rt }" | ConvertTo-Json -Compress
} else {
  $error = $e | Out-string
  "{ status: 'failure', message: $error, resultcode: $rt }" | ConvertTo-Json -Compress
}
