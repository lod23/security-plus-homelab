# Lab 2.2: Attack Surface Reduction

## Objective
This lab covers three common sources of attack surface: network services with open ports, accounts that use default or missing credentials, and outdated applications with known vulnerabilities. Each one gives an attacker a way in without needing a sophisticated exploit, so finding and reducing them is one of the most effective defensive steps an organization can take.

## Environment
The lab used virtual machines in the ADATUM.com domain, including MAD-SVR2, a Windows server running a XAMPP web stack, and MAD-CL1, a Windows workstation joined to the domain.

## What I did

### Exercise 1: Open ports
I reviewed the services and listening ports on MAD-SVR2, where XAMPP was running Apache 2.4.58 and MariaDB 10.4.32. I captured the running services and the listening ports, then created Windows Firewall rules to block access to the exposed services and captured those rules as evidence.

Evidence: services.txt, listening-ports.txt, block-rules.txt (MAD-SVR2).

### Exercise 2: Default credentials
I examined the domain Guest account, which had no password. I found that disabling the account in Active Directory Users and Computers is not a complete fix on its own, because Group Policy still granted the "Allow log on locally" user right. A complete fix requires both disabling the account and removing the logon right through policy.

### Exercise 3: Vulnerable applications
On MAD-CL1, I opened a crafted PDF file (crash.pdf) in Adobe Reader 8.1, a very old version with known PDF-parsing vulnerabilities. The application hung, and the Application event log recorded the failure.

Evidence: crash-findings.txt.

## Results
- MAD-SVR2 exposed a web server and a database server through XAMPP, and firewall block rules were added to restrict access to them.
- The Guest account had an empty password, and disabling it alone did not remove its ability to log on while the Group Policy logon right remained in place.
- Adobe Reader 8.1 hung while parsing crash.pdf. The Application log on MAD-CL1 recorded Event 1002 (Application Hang) for Adobe Reader, followed by Event 1001 (Windows Error Reporting fault bucket), on Sep 19 at 11:08.

## Observations
- Development stacks such as XAMPP are designed for convenience, not security. Running one on a server exposes a web server and a database that may use default settings, so they should be removed from production systems or locked down and firewalled.
- Blocking ports with a firewall reduces exposure, but removing or disabling services that are not needed is a stronger control, because a firewall rule can be changed or bypassed later.
- Account controls work in layers. Disabling an account in Active Directory and removing its logon rights through Group Policy are separate controls, and relying on only one leaves a gap.
- An application hang followed immediately by a Windows Error Reporting fault bucket is a common indicator of attempted exploitation, especially when it happens right after a user opens a file from an untrusted source.
- The real fix for a vulnerable application is patching or replacing it. Adobe Reader 8.1 is long out of support, so it should be upgraded to a current version or removed.

## Evidence gaps
The HELIX console blocked the clipboard for part of this session, so evidence for Exercise 2 (the Guest account and its Group Policy logon right) was not captured as a file. The crash-findings.txt file was written on the Mac from a screenshot of the MAD-CL1 Application log, because the log could not be transferred directly before the lab timer ran out.

## Evidence index
| File | Contents |
|---|---|
| services.txt | Running services on MAD-SVR2 |
| listening-ports.txt | Listening ports on MAD-SVR2 |
| block-rules.txt | Firewall block rules added on MAD-SVR2 |
| crash-findings.txt | Adobe Reader crash events from the MAD-CL1 Application log |
