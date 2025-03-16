cls
$wordfile = Import-Csv ".\words_categories.csv"
$whash = @{}
$round = 1
$totalscore = 0
$sound = $true

function playSound($path) {
    $player = New-Object System.Media.SoundPlayer $path
    $player.Play()
} 

Write-Host ("=" * 47) -ForegroundColor Yellow
write-host ""
Write-Host ("=" * 47) -ForegroundColor Yellow

[System.Console]::SetCursorPosition(0, [System.Console]::CursorTop - 2)

playSound -path ".\Sounds\wheel of fortune.wav"
sleep -Milliseconds 750
write-host "              Wheel " -NoNewline -fore yellow

sleep -Milliseconds 1300
write-host "of " -NoNewline -fore yellow

sleep -Milliseconds 1400
write-host "Fortune!" -fore yellow

write-host "`n`n1: 1 Player`n2: 2 Players`n3: Sound Options`n"
$menuChoice = read-host "Enter a selction"

switch ($menuChoice) {
    "1" {}
    "2" {}
    "3" { cls; write-host "1: Sound Off`n"; $schoice = read-host "Make a selection"; if ($schoice -eq 1) {$sound = $false} }
}

foreach ($entry in $wordfile) {
    $category = $entry.category
    $word = $entry.word.ToUpper()

    if (-not $whash.ContainsKey($category)) {
        $whash[$category] = @()
    }
    
    $whash[$category] += $word
}

do {
    $randomcat = $whash.Keys | Get-Random
    $word = ($whash[$randomcat] | Get-Random).ToCharArray()
    $dword = @("_") * $word.Length
    $used = @{}
    $score = 0
    $message = ""
    $vowels = @("A","E","I","O","U")
    $misses = 0
    $gimme = @("R", "S", "T", "L", "N", "E")

    # Reveal spaces
    $dword = @($word | ForEach-Object { if ($_ -eq " ") { " " } else { "_" } })

    function bonusDisplay {
        param ($message, $dword, $randomcat, $vowels)
        cls
        Write-Host ("=" * 47) -ForegroundColor Yellow
        Write-Host "          Powershell Wheel of Fortune" -ForegroundColor Yellow
        Write-Host "                 Bonus Round" -ForegroundColor Yellow
        Write-Host ("=" * 47) -ForegroundColor Yellow
        Write-Host "`nPuzzle: $($dword -join " ")"
        Write-Host "Message: $message`n"
        Write-Host "Category: $randomcat"
        Write-Host "Vowels Available: $($vowels -join ", ")`n"
        Write-Host ("*" * 47) -ForegroundColor Cyan
    }
    
    function bonusRound {
        $randomcat = $whash.Keys | Get-Random
        $script:word = ($whash[$randomcat] | Get-Random).ToCharArray()
        $vowels = @("A","E","I","O","U")
        $dword = @("_") * $word.Length
        $dword = @($word | ForEach-Object { if ($_ -eq " ") { " " } else { "_" } })

        bonusDisplay -message "We will give you the letters R, S, T, L, N, and E" -dword $dword -randomcat $randomcat -vowels $vowels
    
        foreach ($letter in $gimme) {
            for ($i = 0; $i -lt $word.length; $i++) {
                if ($word -contains $letter) {
                    if ($word[$i] -eq $letter) { $dword[$i] = $letter; $vowels = $vowels | ? { $_ -ne "E" } }
                }
            }
        }

        start-sleep -milliseconds 1500
        bonusDisplay -message "Enter three consonants and a vowel" -dword $dword -randomcat $randomcat -vowels $vowels
        $response = Read-Host "Enter your guess"
        $answer = ($response.ToUpper()).ToCharArray()
    
        foreach ($letter in $answer) {
            for ($i = 0; $i -lt $word.length; $i++) {
                if ($word -contains $letter) {
                    if ($word[$i] -eq $letter) { $dword[$i] = $letter; $vowels = $vowels | ? { $_ -ne $letter } }
                }
            }
        }
    
        bonusDisplay -message "You have one chance to solve" -dword $dword -randomcat $randomcat -vowels $vowels
        $brresponse = Read-Host "Enter your guess"
    
        if ($brresponse -eq ($word -join "")) { $script:bonus = $true; break } else { $script:bonus = $false; break }
    }
    function spin {
        $wheelvalue = @("100","200","300","400","500","600","700","800","900","1000","BANKRUPT","LOSE A TURN")
        $result = $wheelvalue | Get-Random
        return @{ value = if ($result -match "^\d+$") { [int]$result } else { 0 }; display = $result }
    }

    function wheelspin {
        param($spintab)
        $wheelvalue = @("100","200","300","400","500","600","700","800","900","1000","BANKRUPT","LOSE A TURN")
        $delay = 50

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
                    if ($sound -eq $true) { playSound -path ".\Sounds\wheel spin.wav" }
                    sleep -Milliseconds 325
                    break
                }
            }

        } while ($true)
        
        $delay = [math]::round(1500 / $currentLength)
        $spinAmmount = [math]::round($currentLength * 2)
        
        for ($t = 0; $t -lt $spinAmmount; $t++) {
            cls
            Write-Host ("=" * 36) -ForegroundColor Yellow
            Write-Host "           Spinning Wheel" -ForegroundColor Yellow
            Write-Host ("=" * 36) -ForegroundColor Yellow
            Write-Host "`n`rWheel Spin: $( $wheelvalue | Get-Random )" -NoNewline
            Start-Sleep -Milliseconds $delay
            if ($t -ge ($spinAmmount / 2)) { $delay += 5 }
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

    if ($sound -eq $true) { playSound -path ".\Sounds\reveal.wav" }

    while ($dword -join "" -ne ($word -join "") -and $round -lt 4 -and $misses -ne 12) {
        cls
        Write-Host ("=" * 47) -ForegroundColor Yellow
        Write-Host "          Powershell Wheel of Fortune" -ForegroundColor Yellow
        Write-Host "                   Round $round" -ForegroundColor Yellow
        Write-Host ("=" * 47) -ForegroundColor Yellow
        Write-Host "`nPuzzle: $($dword -join " ")"
        Write-Host "Message: $message`n"
        Write-Host "Category: $randomcat"
        write-host "Spin Value: $($value)"
        Write-Host "Score: $score"
        Write-Host "Vowels Available: $($vowels -join ", ")"
        Write-Host "Letters Guessed: $($used.keys -join ", ")`n"
        Write-Host ("*" * 47) -ForegroundColor Cyan
        
        if ($userSpin -eq $true) { 
            $guess = (Read-Host "Enter a consonant").ToUpper()
            $userSpin = $false 
        } else { 
            $response = Read-Host "Press [s]Spin [b]Buy a vowel [r]Solve" 
            
            if ($response -eq "s") {
                $spinresult = spin
                $value = $spinresult.display
                wheelspin -spintab $spinresult.display
                $userSpin = $true
    
                if ($spinresult.display -eq "BANKRUPT") {
                    $message = "BANKRUPT!! Sorry, better luck next time!"
                    $score = 0
                    $userSpin = $false
                    if ($sound -eq $true) { playSound -path ".\Sounds\bankrupt.wav" }
                    continue
                } elseif ($spinresult.display -eq "LOSE A TURN") {
                    $message = "Awww, lost a turn! Try again!"
                    $userSpin = $false
                    $misses++
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
                    $round++
                    $totalscore += $score
                    break
                } else {
                    $message = "Nope, that's not it!"
                    Start-Sleep -Seconds 1
                    continue
                }
            }
        }

        if ($guess -notmatch "^[A-Z]$") {
            $message = "Enter a valid character!"
            Start-Sleep -Seconds 2
        } elseif ($used.ContainsKey($guess)) {
            $message =  "You already used that one!"
            Start-Sleep -Seconds 2
        } elseif ($word -contains $guess) {
            $count = 0
            for ($i = 0; $i -lt $word.Length; $i++) {
                if ($word[$i] -eq $guess) {
                    if ($sound -eq $true) { playSound -path ".\Sounds\ding.wav" }
                    $dword[$i] = $guess
                    sleep -milliseconds 1250
                    $count++
                }
            }
            $used[$guess] = $true
            if (!($vowels -contains $guess)) { $score += calculateScore $count $spinresult.value }
            $multiResponse = @("Yes there are $($count) $($guess)'s", "Congrats there are $($count) $($guess)'s", "$($count) $($guess)'s", "There are a couple $($guess)'s")
            $singleResponse = @("Yes there is one $($guess)", "One $($guess)", "There is an $($guess)")
            $message = if ($count -gt 1) { $multiResponse | get-random } else { $singleResponse | get-random }
        } else {
            if ($sound -eq $true) { playSound -path ".\Sounds\buzzer.wav" }
            $response = @("Sorry there are no $($guess)'s", "Nope, no $($guess)'s in this one", "There are no $($guess)'s", "Sorry, try again")
            $message = $response | get-random
            $used[$guess] = $true
            $misses++
        }
    }
    if ($round -eq 4) { bonusRound } elseif ($misses -eq 12) { break }
}
until ($round -gt 4)

if ($misses -eq 12) {
	cls
	Write-Host $("=" * 36) -ForegroundColor Yellow
	Write-Host "              Game Over" -ForegroundColor Yellow
	Write-Host $("=" * 36) -ForegroundColor Yellow
	Write-Host "`nPuzzle:"$($word -join "")
	Write-Host "Message: You get nothing! You lose! Good day, sir!`n"
	Write-Host "Final Score: $totalscore"
} elseif ($bonus -eq $true) {
	cls
    if ($sound -eq $true) { playSound -path ".\Sounds\puzzle solve.wav" }
    sleep -Milliseconds 250
	Write-Host $("=" * 36) -ForegroundColor Yellow
	Write-Host "              Game Over" -ForegroundColor Yellow
	Write-Host $("=" * 36) -ForegroundColor Yellow
	Write-Host "`nPuzzle:"$($word -join "")
	Write-Host "Message: Congrats! You got it!`n"
	Write-Host "Final Score: $totalscore"
} elseif ($bonus -eq $false) {
    cls
	Write-Host $("=" * 36) -ForegroundColor Yellow
	Write-Host "              Game Over" -ForegroundColor Yellow
	Write-Host $("=" * 36) -ForegroundColor Yellow
	Write-Host "`nPuzzle:"$($word -join "")
	Write-Host "Message: You missed the bonus round!`n"
	Write-Host "Final Score: $totalscore"
}
