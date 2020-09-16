function Invoke-CloudKeyHunter {
<#
  .SYNOPSIS

    This module loops through C:\Users\<Username>\ directories on targeted machines searching for cloud credential files used by Azure, AWS, and GCP.

    CloudKeyHunter Function: Invoke-CloudKeyHunter
    Author: Josh Berry (@codewatchorg)
    License: BSD 3-Clause
    Required Dependencies: None
    Optional Dependencies: None

  .DESCRIPTION

    This module loops through C:\Users\<Username>\ directories and attempts to enumerate cloud credential files.  The script takes a list of targets and a username/password combination to authenticate over SMB to list the files. This requires administrative credentials.

  .PARAMETER targets

    The type of service to test.  Supported services are Outlook Web Access (owa), ActiveSync (as), Outlook Anywhere (oa), WMI (wmi), SMB (smb), and Microsoft Online (msol).

  .PARAMETER username

    The administrative username to use for authentication.

  .PARAMETER password

    The administrative password to use for authentication.


  .PARAMETER verbose

    The verbose parameter causes CloudKeyHunter to print off details for each request.


  .EXAMPLE

    C:\PS> Invoke-CloudKeyHunter -targets cloudtargets.txt

    Description
    -----------
    This command will attempt to connect to each target in the targets.txt file.

  .EXAMPLE

    C:\PS> Invoke-CloudKeyHunter -targets cloudtargets.txt -verbose

    Description
    -----------
    This command will attempt to connect to each target in the targets.txt file, and print to screen each attempt.
#>

  # Do not report exceptions and set variables
  param($targets, [switch]$verbose);

  # Create array of cloud files
  $cloudfiles = @{};
  $cloudfiles["AWS"] = @{};
  $cloudfiles["AWS"][0] = ".aws\credentials";
  $cloudfiles["AWS"][1] = "AppData\Roaming\s3cmd.ini";
  $cloudfiles["AWS"][2] = ".elasticbeanstalk\aws_credential_file";
  $cloudfiles["Azure"] = @{};
  $cloudfiles["Azure"][0] = ".azure\accessTokens.json";
  $cloudfiles["GCP"] = @{};
  $cloudfiles["GCP"][0] = "AppData\Roaming\gcloud\credentials";
  $cloudfiles["GCP"][1] = "AppData\Roaming\gcloud\credentials.db";
  $cloudfiles["GCP"][2] = "AppData\Roaming\gcloud\access_tokens.db";
  $cloudfiles["AWS/GCP"] = @{};
  $cloudfiles["AWS/GCP"][0] = ".boto";
  $cloudfiles["AWS/GCP"][1] = ".boto_user_account";
  $cloudfiles["AWS/GCP"][2] = ".boto_service_account";

  # Set encoding to UTF8
  $EncodingForm = [System.Text.Encoding]::UTF8;

  # Loop through targets
  Get-Content $targets | ForEach-Object -Process {
    $target = $_;

    # Connect to target and get list of user directories
    $accounts = Get-ChildItem -Force -Path "\\$target\c$\Users\*" -Directory -ErrorAction SilentlyContinue

    # Loop through each user directory
    ForEach ($account in $accounts.name) {

      # Loop through the cloud key files
      $cloudfiles.Keys | ForEach-Object { 
        $cloudtype = $_; 
        $cloudfiles[$_].Keys | ForEach-Object { 
          $check = $cloudfiles[$cloudtype][$_];

          # If verbose mode is set, print off each connection attempt
          If ($verbose -eq $true) {
            Write-Host -ForegroundColor Yellow "Checking for \\$target\c$\Users\$account\$check";
          }

          # Check if the file exists, if so, print it
          If (Get-ChildItem -Force -Path "\\$target\c$\Users\$account\$check" -ErrorAction SilentlyContinue) {
            Write-Host -ForegroundColor Green "!!! FOUND $cloudtype key on $target at C:\Users\$account\$check !!!";
          }
        }
      }
    }
  }
}