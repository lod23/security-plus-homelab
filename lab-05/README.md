# Lab 2.3: Social Engineering Defense

## Objective
This lab covers defenses against social engineering, specifically phishing emails and password-guessing attacks against user accounts. Social engineering targets people rather than software, so the defenses combine user awareness, content filtering, and account controls that limit the damage when someone is fooled.

## Environment
The lab used two virtual machines in the ADATUM.com domain: MAD-DC1, a Windows Server 2022 domain controller, and MAD-CL1, a Windows 10 workstation joined to the domain.

## What I did

### Exercise 1: Phishing analysis and mail filtering
I examined two sample phishing emails on MAD-CL1 and documented their warning signs. The first impersonated Amazon using a lookalike sender domain with a zero in place of the letter "o", an urgent subject line, a generic greeting, a link to a .tk domain, and a threat of account suspension within 24 hours. The second impersonated an internal payroll department using an external domain, asked the employee to log in and update banking details through an outside link, and used pressure about a delayed payment.

Because the lab had no Exchange server, I built a simulated mail filter on MAD-DC1. It stored regular-expression rules as text files, scanned test emails against them, and moved any matching email into a quarantine folder with a report listing the rules it triggered. I then added one more rule for a generic greeting and reran the scan to compare the results before and after.

Evidence: cl1-01 to cl1-03 (MAD-CL1), dc1-01 to dc1-09 (MAD-DC1).

### Exercise 2: Logon banner and account lockout
I created a Group Policy Object that displays a security warning banner before sign-in, linked it at the ADATUM.com domain root, and set it to Enforced. After a policy update and restart, MAD-CL1 showed the banner at the logon screen.

I then created a second GPO that sets the account lockout threshold to 5 invalid attempts and linked it at the domain root. I created a test user, ran a script from MAD-CL1 that attempted six logons with the wrong password, and confirmed on MAD-DC1 that the account was locked out.

Evidence: cl1-04 to cl1-07 (MAD-CL1), dc1-10 to dc1-12 and dc1-17 to dc1-19 (MAD-DC1).

## Results
- The filter quarantined both phishing emails and allowed the legitimate email through. Before the extra rule, it loaded 6 rules; after adding the generic-greeting rule, it loaded 7, and the Amazon sample's detection count increased (dc1-05, dc1-06).
- The banner's registry values were written on both machines, and the captured files are the same size on MAD-CL1 and MAD-DC1 (1360 bytes each on the VM), which shows the domain policy applied consistently (cl1-05, dc1-12).
- The client's Group Policy results list the banner policy and the lockout policy among the applied GPOs (cl1-04, cl1-06).
- The test account's LockedOut property changed from False to True after the failed attempts, and the domain controller logged the lockout as event 4740 (dc1-17).

## Observations
- The simulated filter only matches text patterns in the message. It does not check sender authentication (SPF, DKIM, or DMARC), which would catch spoofed senders more reliably than keyword rules.
- Broad rules create false-positive risk. A pattern such as any "security@" address on a hyphenated .com domain would also flag legitimate vendors.
- The payroll email, which resembles business email compromise, triggered only two rules. Lures that avoid obvious urgency words and suspicious domains are harder for content filters to catch, so user training still matters.
- Account lockout stops repeated password guessing, but it can also be abused: anyone who knows a username can lock that user out on purpose. The threshold and lockout duration are a trade-off between security and availability.
- Account policies for domain users only take effect from a GPO linked at the domain root, which is why the lockout policy was linked at ADATUM.com.
- The logon banner establishes that users consent to monitoring before they sign in, which supports acceptable-use and legal enforcement.
- The failed logons left almost no trace on the domain controller. No Kerberos pre-authentication failures (event 4771) were found. The 4776 events that were present were dated January 2025, from when the lab image was built, not from this session. The failed-logon file on MAD-CL1 (event 4625) contained almost no data. In practice, a defender would have seen the account lock without seeing the guessing that caused it. Enabling failure auditing for Kerberos Authentication Service and Credential Validation on domain controllers would close this gap.

## Evidence gaps
Files dc1-13 to dc1-16 (the lockout GPO details, final GPO links, effective lockout policy, and test user state) were captured on MAD-DC1 but not transferred before the lab session closed. The lockout itself was confirmed live (LockedOut: True) and is recorded in event 4740 (dc1-17).

## Evidence index
Files starting with cl1- were captured on MAD-CL1, and files starting with dc1- were captured on MAD-DC1.

| File | Contents |
|---|---|
| cl1-01-host.txt | MAD-CL1 operating system and name |
| cl1-02-files.txt | Phishing sample and analysis files |
| cl1-03-hashes.txt | Hashes of the analysis files |
| cl1-04-gpresult.txt | Applied GPOs after the banner policy |
| cl1-05-banner-reg.txt | Banner registry values on the client |
| cl1-06-gpresult-final.txt | Applied GPOs after the lockout policy |
| cl1-07-event4625.txt | Failed logon events on the client |
| dc1-01-host.txt | MAD-DC1 operating system and name |
| dc1-02-tree.txt | Email filter folder structure |
| dc1-03-rules.txt | Filter rule patterns |
| dc1-04-listrules.txt | Rule listing from the filter |
| dc1-05-before.txt | Scan results with 6 rules |
| dc1-06-after.txt | Scan results with 7 rules |
| dc1-07-quarantine.txt | Quarantine folder contents |
| dc1-08-reports.txt | Detection reports |
| dc1-09-hashes.txt | Hashes of filter files |
| dc1-10-gpo.txt | Banner GPO details |
| dc1-11-links.txt | GPO links at the domain root |
| dc1-12-banner-reg.txt | Banner registry values on the DC |
| dc1-17-event4740.txt | Account lockout event |
| dc1-18-auditpol-logon.txt | Account Logon audit policy |
| dc1-19-authfail.txt | Credential validation events (4771/4776) |