function IsReportSafe {
  param (
    [Parameter(Mandatory=$true)]
    [string]
    $report
  )
  
  $isAGoodReport = $true  
  $reportValues = $report -split '\s+'
  
  # We need to track asc vs desc, so we'll just store whether the first is smaller than the second  
  $isAscending = [int]$reportValues[0] -lt [int]$reportValues[1]
  
  # Yes we're rechecking whether the first 2 values are doing the thing we used them to determine, but I didn't want to make counters
  ## and crap for a while and order matters so can't foreach where my brain tells me the enumerator returned is not guaranteed to be sorted
  for ($i = 0; ($i -lt $reportValues.Count - 1) -and $isAGoodReport; $i++) 
  {    
    if($isAscending)
    {        
        $isAGoodReport = ( ( [int]$reportValues[$i] -lt [int]$reportValues[$i+1] ) -and ( ( ( [int]$reportValues[$i+1] - [int]$reportValues[$i] ) -ge 1 ) -and ( ( [int]$reportValues[$i+1] - [int]$reportValues[$i] ) -le 3 ) ) )                
    }
    else
    {
        $isAGoodReport = ( ( [int]$reportValues[$i] -gt [int]$reportValues[$i+1] ) -and ( ( ( [int]$reportValues[$i] - [int]$reportValues[$i+1] ) -ge 1 ) -and ( ( [int]$reportValues[$i] - [int]$reportValues[$i+1] ) -le 3 ) ) )        
    }
  }

  $isAGoodReport
}

function IsReportSafeWithDampening {
  param (
    [Parameter(Mandatory=$true)]
    [string]
    $report,
    [Parameter(Mandatory=$false)]
    [bool]
    $wasDampened = $false
  )

  $isAGoodReport = $true  
  # Turns out the arrays PS makes by default are fixed size. So we're going to use the fresh Generic.List
  # So what we're going to do
  $reportValues = $report -split '\s+'
   
  # We need to track asc vs desc, so we'll just store whether the first is smaller than the second  
  $isAscending = [int]$reportValues[0] -lt [int]$reportValues[1]
  
  # Yes we're rechecking whether the first 2 values are doing the thing we used them to determine, but I didn't want to make counters
  ## and crap for a while and order matters so can't foreach where my brain tells me the enumerator returned is not guaranteed to be sorted
  for ($i = 0; ($i -lt $reportValues.Count - 1) -and $isAGoodReport; $i++) 
  {    
    if($isAscending)
    {   
        $isAGoodReport = ( ( [int]$reportValues[$i] -lt [int]$reportValues[$i+1] ) -and ( ( ( [int]$reportValues[$i+1] - [int]$reportValues[$i] ) -ge 1 ) -and ( ( [int]$reportValues[$i+1] - [int]$reportValues[$i] ) -le 3 ) ) )
        # Write-Host "Ascending. Current offset $i . Values $($reportValues[$i]) $($reportValues[$i+1]). IsAGoodReport: $isAGoodReport"
    }
    else
    {        
        $isAGoodReport = ( ( [int]$reportValues[$i] -gt [int]$reportValues[$i+1] ) -and ( ( ( [int]$reportValues[$i] - [int]$reportValues[$i+1] ) -ge 1 ) -and ( ( [int]$reportValues[$i] - [int]$reportValues[$i+1] ) -le 3 ) ) )
        # Write-Host "Descending. Current offset $i . Values $($reportValues[$i]) $($reportValues[$i+1]). IsAGoodReport: $isAGoodReport"
    }

    if((-not $isAGoodReport) -and (-not $wasDampened))
    {
      # So we're going to just do a recursive call with $i and $i+1 removed and isDampened $true
      [string]$currentValueRemoved = ($reportValues[0 .. ($i-1)] + $reportValues[($i+1) .. ($reportValues.Count)]) -join ' '
      [string]$nextValueRemoved = ($reportValues[0 .. ($i)] + $reportValues[($i+2) .. ($reportValues.Count)]) -join ' '
      
      $isAGoodReport = IsReportSafeWithDampening($currentValueRemoved, $true) -and IsReportSafeWithDampening($nextValueRemoved, $true)
    }
  }

  $isAGoodReport
}

$puzzleInput = Get-Content .\originalinput.txt

# For part 1, the criteria for any given line is "must be either all desc or asc" && "diff between 2 values must be 1 .. 3"
$goodReport = 0
$goodDampenedReport = 0

foreach($report in $puzzleInput)
{

  if(IsReportSafe -report $report)
  {
    $goodReport++
  }

  if(IsReportSafeWithDampening -report $report)
  {
    $goodDampenedReport++
  }
  
}
  
Write-Host "Number of Good reports is: $goodReport"
Write-Host "Number of Good dampened reports is: $goodDampenedReport"
