cls
$wordfile = Import-Csv "C:\temp\words_categories.csv"
$whash = @{}

foreach ($entry in $wordfile) {
    $category = $entry.category
    $word = $entry.word.ToUpper()

    if (-not $whash.ContainsKey($category)) {
        $whash[$category] = @()
    }
    
    $whash[$category] += $word
}

$randomcat = $whash.Keys | Get-Random
$word = ($whash[$randomcat] | Get-Random).ToCharArray()
$dword = @("_") * $word.Length
$used = @{}
$score = 0
$message = ""
$vowels = @("A","E","I","O","U")

# Reveal spaces
$dword = @($word | ForEach-Object { if ($_ -eq " ") { " " } else { "_" } })

function spin {
    $wheelvalue = @("100","200","300","400","500","600","700","800","900","1000","BANKRUPT","LOSE A TURN")
    $result = $wheelvalue | Get-Random
    return @{ value = if ($result -match "^\d+$") { [int]$result } else { 0 }; display = $result }
}

function wheelspin {
    param ($spintab)
    $wheelvalue = @("100","200","300","400","500","600","700","800","900","1000","BANKRUPT","LOSE A TURN")

    cls
    Write-Host ("=" * 36) -ForegroundColor Yellow
    Write-Host "           Spinning Wheel" -ForegroundColor Yellow
    Write-Host ("=" * 36) -ForegroundColor Yellow

    $maxLength = 30  # Length of the progress bar
    $step = 1        # How many "#" to add/remove per step
    $direction = 1   # 1 for increasing, -1 for decreasing
    $currentLength = 0

    Write-Host "`nPress 'Enter' to spin..." -ForegroundColor Yellow

    do {
        # Build the progress bar
        $bar = "[" + ("#" * $currentLength).PadRight($maxLength) + "]"

        # Display the progress bar on the same line
        Write-Host "`r$bar" -NoNewline

        # Wait for a short time to create the animation effect
        Start-Sleep -Milliseconds 25

        # Change bar length based on direction
        $currentLength += $step * $direction

        # Reverse direction at max/min length
        if ($currentLength -ge $maxLength -or $currentLength -le 0) {
            $direction *= -1
        }

        # Check for Enter key press
        if ([console]::KeyAvailable) {
            $key = [console]::ReadKey($true)
            if ($key.Key -eq "Enter") {
                break
            }
        }

    } while ($true)

    $delay = [math]::round(1500 / $currentLength)
    $spinAmount = [math]::round($currentLength * 2)

    for ($t = 0; $t -lt $spinAmount; $t++) {
        cls
        Write-Host ("=" * 36) -ForegroundColor Yellow
        Write-Host "           Spinning Wheel" -ForegroundColor Yellow
        Write-Host ("=" * 36) -ForegroundColor Yellow
        Write-Host "`n`rWheel Spin: $( $wheelvalue | Get-Random )" -NoNewline
        Start-Sleep -Milliseconds $delay
        if ($t -ge ($spinAmount / 2)) { $delay += 5 }
    }

    cls
    Write-Host ("=" * 36) -ForegroundColor Yellow
    Write-Host "           Spinning Wheel" -ForegroundColor Yellow
    Write-Host ("=" * 36) -ForegroundColor Yellow
    Write-Host "`nWheel Spin: $spintab" -ForegroundColor Cyan
    Start-Sleep -Milliseconds 1250
}

function calculateScore {
    param ([int]$count, [int]$spinvalue)
    return $count * $spinvalue
}


$value = ""
$userSpin = $false

while ($dword -join "" -ne ($word -join "")) {
    cls
    Write-Host ("=" * 47) -ForegroundColor Yellow
    Write-Host "          Powershell Wheel of Fortune" -ForegroundColor Yellow
    Write-Host ("=" * 47) -ForegroundColor Yellow
    Write-Host "`nPuzzle: $($dword -join " ")"
    Write-Host "Message: $message`n"
    Write-Host "Category: $randomcat"
    write-host "Spin Value: $($value)"
    Write-Host "Score: $score"
    Write-Host "Vowels Available: $($vowels -join ", ")"
    Write-Host "Letters Used: $($used.values -join ", ")`n"
    Write-Host ("*" * 47) -ForegroundColor Cyan
    $response = Read-Host "Press [s]Spin [g]Guess [b]Buy a vowel [r]Solve"

    if ($response -eq "s") {
        $spinresult = spin
        $value = $spinresult.display
        wheelspin -spintab $spinresult.display
        $userSpin = $true

        if ($spinresult.display -eq "BANKRUPT") {
            $message = "BANKRUPT!! Sorry, better luck next time!"
            $score = 0
            $userSpin = $false
            continue
        } elseif ($spinresult.display -eq "LOSE A TURN") {
            $message = "Awww, lost a turn! Try again!"
            $userSpin = $false
            continue
        }
        
        $message = ""
        continue
    } elseif ($response -eq "b") {
        if ($score -ge 250) {
            $guess = (Read-Host "Enter a vowel").ToUpper()
            if ($vowels -notcontains $guess) {
                $message = "Vowels only!!!"
                continue
            }
            $score -= 250
            $vowels = $vowels | ? { $_ -ne $guess }
        } else {
            $message = "You need 250 or more to buy a vowel!"
            continue
        }
    } elseif ($response -eq "r") {
        if ((Read-Host "Enter the solution").ToUpper() -eq ($word -join "")) {
            $count = ($dword | ? { $_ -eq '_' } | measure-object).count
            $score += calculateScore $count $spinresult.value
            break
        } else {
            $message = "Nope, that's not it!"
            Start-Sleep -Seconds 1
            continue
        }
    } elseif ($response -eq "g") {
        if ($userSpin -eq $true) {
            $guess = (Read-Host "Enter a consonant").ToUpper()
            $userSpin = $false
        } else {
            $message = "You need to spin the wheel first before taking a guess!"
            continue
        }
        
        if ($vowels -contains $guess) {
            $message = "Vowels need to be bought!"
            sleep -seconds 1
            continue
        }
    }

    if ($guess -notmatch "^[A-Z]$") {
        $message = "Enter a valid character!"
        continue
    } elseif ($used.ContainsKey($guess)) {
        Write-Host "You already used that one!"
        Start-Sleep -Seconds 2
    } elseif ($word -contains $guess) {
        $count = 0
        for ($i = 0; $i -lt $word.Length; $i++) {
            if ($word[$i] -eq $guess) {
                $dword[$i] = $guess
                $count++
            }
        }
        $used[$guess] = $guess
        if(!($vowels -contains $guess)) { $score += calculateScore $count $spinresult.value }
        $multiResponse = @("Yes there are $($count) $($guess)'s", "Congrats there are $($count) $($guess)'s", "$($count) $($guess)'s", "There are a couple $($guess)'s")
        $singleResponse = @("Yes there is one $($guess)", "One $($guess)", "There is an $($guess)")
        $message = if ($count -gt 1) { $multiResponse | get-random } else { $singleResponse | get-random }
    } else {
        $response = @("Sorry there are no $($guess)'s", "Nope, no $($guess)'s in this one", "There are no $($guess)'s", "Sorry, try again")
        $message = $response | get-random
        $used[$guess] = $guess
    }
}

cls
Write-Host "Puzzle:"$($word -join "")
Write-Host "Message: Congrats, you got it!"
Write-Host "Final Score: $score"
