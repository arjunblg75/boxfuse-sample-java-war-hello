$ResGroupName = ""
$WebAppName = ""

# Get publishing profile for web application
$WebApp = Get-AzWebApp -Name $WebAppName -ResourceGroupName $ResGroupName
[xml]$publishingProfile = Get-AzWebAppPublishingProfile -WebApp $WebApp

# Create Base64 authorization header
$username = $publishingProfile.publishData.publishProfile[0].userName
$password = $publishingProfile.publishData.publishProfile[0].userPWD
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))

$bodyToPOST = @{  
                  command = "find . -mindepth 1 -delete"  
                  dir = "/home/site/wwwroot"  
}  
# Splat all parameters together in $param  
$param = @{  
            # command REST API url  
            Uri = "https://$WebAppName.scm.azurewebsites.net/api/command"  
            Headers = @{Authorization=("Basic {0}" -f $base64AuthInfo)}  
            Method = "POST"  
            Body = (ConvertTo-Json $bodyToPOST)  
            ContentType = "application/json"  
}  
# Invoke REST call  
Invoke-RestMethod @param  
