$puzzleInput = Get-Content .\originalinput.txt

# For part 1, the criteria for any given line is "must be either all desc or asc" && "diff between 2 values must be 1 .. 3"
$goodReport = 0
$goodDampenedReport = 0

foreach($report in $puzzleInput)
{
  # Yes the constant casting is sorta silly, but PS gets a bit weird about how it handles objects and arrays so I'd rather cast the
  ## original over and over to have some certainty I'm referencing the correct thing than find and figure some esoteric
  ## "Oh PS jsut makes a pointer in this case and you're not actually dealing with a new object" or some such
  
  # Initializing return value; again, starting with good assumption for ease of short circuit
  $isAGoodReport = $true
  $DampenedCounter = 0
  
  # Each level is a series of digits separated by white space so just splitting then walking through the list
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

  if($isAGoodReport)
  {
    $goodReport++
  }

  # As constructed, had to just run the loop again with a different short circuit.
  for ($i = 0; ($i -lt $reportValues.Count - 1) -and ((-not $isAGoodReport) -and ($DampenedCounter -le 1)); $i++) 
  {    
    if($isAscending)
    {        
        $isAGoodReport = ( ( [int]$reportValues[$i] -lt [int]$reportValues[$i+1] ) -and ( ( ( [int]$reportValues[$i+1] - [int]$reportValues[$i] ) -ge 1 ) -and ( ( [int]$reportValues[$i+1] - [int]$reportValues[$i] ) -le 3 ) ) )                
    }
    else
    {
        $isAGoodReport = ( ( [int]$reportValues[$i] -gt [int]$reportValues[$i+1] ) -and ( ( ( [int]$reportValues[$i] - [int]$reportValues[$i+1] ) -ge 1 ) -and ( ( [int]$reportValues[$i] - [int]$reportValues[$i+1] ) -le 3 ) ) )        
    }

    if(-not $isAGoodReport)
    {
        $DampenedCounter++
    }
    
    if($isAGoodReport)
    {
        $goodDampenedReport++
    }
    elseif((-not $isAGoodReport) -and ($DampenedCounter -le 1))
    {
        $goodDampenedReport++
    }    
  }

}
  
Write-Host "Number of Good reports is: $goodReport"
Write-Host "Number of Good dampened reports is: $goodDampenedReport"
