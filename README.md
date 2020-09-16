# CloudKeyHunter
SMB based scanner that connects to targets in a text file and checks them for common cloud credential files for AWS/Azure/GCP.

The PowerShell script loops through a target list file and attempts to access each user's directory to search for common paths for AWS, 
Azure, and GCP cloud key files.

Requirements
============
This script requires local admin rights (and a configuration that allows local access) or domain admin rights on the servers being 
scanned. This can be performed via:
1. An already logged domain admin account, 
2. An already logged in local account with the same username and password as the target(s), 
3. Using 'runas /netonly /user:DOMAIN\USER "powershell -exec bypass"' for domain accounts, or 
4. Using 'runas /netonly /user:LOCAL\USER "powershell -exec bypass"' for a local account.

Usage
=====
<pre>
NAME    
  Invoke-CloudKeyHunter
  
SYNOPSIS    
  This module loops through a target list and searches each user's directory for AWS, Azure, and GCP cloud key files.
  
    CloudKeyHunter Function: Invoke-CloudKeyHunter
    Author: Josh Berry (@codewatchorg)
    License: BSD 3-Clause
    Required Dependencies: None
    Optional Dependencies: None

SYNTAX    
  Invoke-CloudKeyHunter [[-targets] &lt;Object&gt;] [-verbose] [&lt;CommonParameters&gt;]

DESCRIPTION    
This module loops through C:\Users\<Username>\ directories and attempts to enumerate cloud credential files.  The script 
takes a list of targets and a username/password combination to authenticate over SMB to list the files. This requires 
administrative credentials.

Example CloudKeyHunter.ps1 usage:
<pre>
    # Without verbose mode
    Invoke-CloudKeyHunter -targets .\targets.txt
    
    # With verbose mode
    Invoke-CloudKeyHunter -targets .\targets.txt -verbose
</pre>
