# pozeni v PS ISE

# splosne spremenljivke
$webPage = 'http://www.sodisce.si/sodni_postopki/javne_obravnave/drazbe/'
$outFile0 = "$PSScriptRoot\drazbe.txt"
$outFile1 = "$PSScriptRoot\rawpovezave.txt"

# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-7
# Example 2: Use of stateful web service

# spletna stran ima polje z nazivom 'rpp' v spletni formi, katere vrednost nastavim na '9999', spustni meni 'prikazov na stran'
$show = @{rpp='9999'}
$drazbe = Invoke-WebRequest $webPage -SessionVariable 'session' -Body $show -Method 'POST'

# parsam vse vrstice tabele
$vrstice = ($drazbe.ParsedHtml.body.getElementsByTagName("tr") | Where-Object {($_.className -eq 'odd') -or ($_.className -eq 'even')}).outerHtml

# filtriram samo vrstice Okrajnega sodišča v Kopru in zapisem na v file na disk
$podatki = $vrstice | Select-String -Pattern "<td ?.*?>Okrajno sodišče v Kopru</td>" | Out-File $outFile0

# poiscem samo tiste vrstice s povezavami iz file-a zapisanega na disku
$vzorec = 'h(\r)*(\n)*r(\r)*(\n)*e(\r)*(\n)*f(\r)*(\n)*=(\r)*(\n)*"(\r)*(\n)*/(\r)*(\n)*m(\r)*(\n)*m(\r)*(\n)*a(\r)*(\n)*_(\r)*(\n)*b(\r)*(\n)*i(\r)*(\n)*n(\r)*(\n)*(\.)(\r)*(\n)*p(\r)*(\n)*h(\r)*(\n)*p(\r)*(\n)*(\?)(\r)*(\n)*i(\r)*(\n)*d(\r)*(\n)*=(\r)*(\n)*(\d{1})*(\r)*(\n)*(\d{1})*&(\r)*(\n)*a(\r)*(\n)*m(\r)*(\n)*p(\r)*(\n)*;(\r)*(\n)*s(\r)*(\n)*e(\r)*(\n)*t(\r)*(\n)*=(\r)*(\n)*a(\r)*(\n)*u(\r)*(\n)*c(\r)*(\n)*t(\r)*(\n)*i(\r)*(\n)*o(\r)*(\n)*n(\r)*(\n)*'
$povezave = Get-Content $outFile0 -Delimiter "<TD>" | Select-String -Pattern $vzorec | ForEach-Object {$_.Matches[0].Groups[0].Value} | Out-File $outFile1

# in shranim v locen file
$povezave = Get-Content $outFile1

#Write-Host "$($povezave[10])$($povezave[11])"
#$link = "$($povezave[0])$($povezave[1])"

# zdruzim vrstice, zamenjam prefix in shranim na disk .PDF datoteke
for (($i=0),($j=1); $j -lt $povezave.Count; ($i=$i+2),($j=$j+2)) {
    $temp = "$($povezave[$i])$($povezave[$j])"
    $tempUrl = $temp -replace 'href="', 'http://sodisce.si'
    $output = "$PSScriptRoot\file$i.pdf"
    Invoke-WebRequest -Uri $tempUrl -OutFile $output
    Write-Host $tempUrl
}

# pocisti za seboj
Remove-Item $outFile0
Remove-Item $outFile1
