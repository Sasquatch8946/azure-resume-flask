Get-InstalledModule `
| ? { $_.Repository -eq 'PSGallery1' } `
| % { Install-Package -Name $_.Name -Source PSGallery -Force }
