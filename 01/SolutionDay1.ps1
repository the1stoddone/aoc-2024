$puzzleInput = gc .\originalinput.txt
# playing with parser 
# $puzzleInput | %{$foo = $_ -split '\s+'; write-host "Foo sub 0 is: $($foo[0])`nFoo sub 1 is : $($foo[1])";}
# initialize some empty arrays
[string[]]$list1 = @()
[string[]]$list2 = @()

foreach($line in $puzzleInput)
{
    $tempSplit = $line -split '\s+'
    $list1 += $tempSplit[0]
    $list2 += $tempSplit[1]
}

# I'm lazy and di this after instead of in flight
$sortedList1 = $list1 | sort
$sortedList2 = $list2 | sort

# Initialize the results holders
$part1Total = 0
$part2Total = 0

for($i = 0; $i -lt ($sortedList1.Count); $i++)
{
    # Part 1 is simply the sum of the absolute value of the diffs in each matching element of the sorted lists
    $part1Total += [Math]::Abs($sortedList1[$i] - $sortedList2[$i])

    # Part 2 is the sum of the product of the value from the first list and how many times it appears in the second list
    # This will get a little wierd as PS doesn't have an obvious "count this value in this array"; at least not self documenting
    # I'm also not going to bother making a helper function because lol
    # Here's what the second operand is doing - Pipe the second list to WhereEach-Object then you define the expression
    ### This will output a list of the results so we then pipe that list to Measure-Object which gives us a a few properties including Count
    ### -ExpandProperty then says "give me the value of this property". Then we let PS infer types and Bob's your uncle
    $part2Total += [int]$sortedList1[$i] * [int]($sortedList2 | ?{$_ -eq $sortedList1[$i]} | measure | select -ExpandProperty Count)
}

Write-Host "Part 1 Result: $part1Total"
Write-Host "Part 2 Result: $part2Total"