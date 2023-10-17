# Replace these values with your GitHub repository and registration token
$repository = "AWS-event"
$token = "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"

# Set the runner name and labels as needed
$runnerName = "MyEC2Runner"
$runnerLabels = "windows, ec2, self-hosted"

# Set the URL for the GitHub API
$apiUrl = "https://api.github.com/repos/$repository/actions/runners/registration-token"

# Get the registration token from GitHub
$headers = @{
    "Authorization" = "token $token"
}
$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get

if ($response.token) {
    $registrationToken = $response.token
    Write-Output "Registration token: $registrationToken"
} else {
    Write-Error "Failed to get registration token from GitHub."
    exit 1
}

# Download the GitHub runner package and configure it
$downloadUrl = "https://github.com/$repository/actions/runners/download"
Invoke-WebRequest -Uri $downloadUrl -OutFile runner.zip
Expand-Archive -Path .\runner.zip -DestinationPath .
Remove-Item runner.zip

# Configure the runner
.\config.cmd --url "https://github.com/$repository" --token $registrationToken --name $runnerName --labels $runnerLabels --unattended

# Start the runner
Start-Service GitHubActionsRunner

