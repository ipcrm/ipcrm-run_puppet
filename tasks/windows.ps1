[CmdletBinding()]
Param(
  [Parameter(Mandatory = $False)]
  [String]
  $noop
)

if ($noop -eq 'true') {
  $cmd = 'puppet.bat agent -t --noop 2>&1'
} elseif ($noop -eq $null -or $noop -eq "" -or $noop -eq "false") {
  $cmd = 'puppet.bat agent -t --no-noop 2>&1'
} else {
  Throw "Unknown argument value for 'noop'.  Accepts true/false, not [${noop}]"
}

try {
 $out = Invoke-Expression $cmd
} catch {
 $e = $_
}
$rt = $LASTEXITCODE

If(@(0,2).contains($rt))
{

  ConvertTo-JSON -InputObject @{status="success";message=$out;resultcode=$rt}
  exit 0

} else {

  ConvertTo-JSON -InputObject @{status="failure";message=$e;resultcode=$rt}
  exit $rt

}
