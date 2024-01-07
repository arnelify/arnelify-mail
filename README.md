<!-- START CONTENTS -->

## Prerequisites

Requirements

* CPU: Apple M1 / Intel Core i7 / AMD Ryzen 7
* RAM: 8 GB
* OS: Debian 12 / MacOS 14 / Windows 11 with <a href="https://learn.microsoft.com/en-us/windows/wsl/install">WSL2</a>.
* LAN: 100 MB/s

## Setup

Run production
```
$ ./setup.sh prod
```

Enter development environment
```
$ ./setup.sh dev
```

Remove from Docker
```
$ ./setup.sh clean
```
## Usage

Create Mailboxes
```
$ setup email add dmarc@example.com
$ setup email add support@example.com
$ setup email add user@example.com
```

Create aliases
```
$ setup alias add support@example.com user@example.com
```

Setup DKIM
```
$ setup config dkim
```

Setup Fail2Ban
```
$ setup fail2ban [<ban|unban> <IP>]
```

## DNS-Records
MX
```
@     IN  A      127.0.0.1
mail  IN  A      127.0.0.1
@     IN  MX  5  mail.example.com.
```
SPF
```
@  IN  TXT  v=spf1 ip4:127.0.0.1 a mx ~all
```
DKIM
```
mail._domainkey  IN  TXT  v=DKIM1; h=sha256; k=rsa; p=MIIBIj...
```
DMARC
```
_dmarc  IN  TXT  v=DMARC1; p=quarantine; sp=quarantine; fo=0; adkim=r; aspf=r; pct=100; rf=afrf; ri=86400; rua=mailto:dmarc@example.com; ruf=mailto:dmarc@example.com
```

<!-- END CONTENTS -->
