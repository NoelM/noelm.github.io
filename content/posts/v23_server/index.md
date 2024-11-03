+++
author = "Noël"
title = "Operate a Minitel V.23 Server with modems"
date = "2024-11-03"
draft = false
+++

[The Minitel](https://en.wikipedia.org/wiki/Minitel) is a digital terminal developped by the national operator France Télécom. The operator offered for free the Minitel to any landline subscriber during from the 80s to the 00s. Despite its tremendous popularity in France, France Télécom (now Orange) closed the service in 2012.

However, this terminal uses a V.23 modem (1200/75 bauds) and can still connect to any amateur server using the same standard! As of 2024, you can count [about 5 servers up-and-running](https://fr.wikipedia.org/wiki/Micro-serveur_Minitel).

![The most famous version, the Minitel 1B](images/m1b.jpg)
{{<center>}}The most famous version, the Minitel 1B{{</center>}}

## The Modem

The number of used modems is plethoric on eBay, Leboncoin, etc... But, I've chosen a standard one, the _US Robotics 56k Faxmodem_, because:

* it is easier to replace,
* and it is well documented!

![A view of the _multivoie_ server with the 2 US Robotics modems](images/notel_server.jpg)
{{<center>}}A view of the _multivoie_ server with the 2 US Robotics modems{{</center>}}

The modem connects to the computer through a serial connection, which uses the [RS-232 standard](https://en.wikipedia.org/wiki/RS-232).
The standard defines two elements:

* Data Circuit-terminating Equipment (DCE), the modem;
* Data Terminal Equiment (DTE), the computer.

The communication between the DTE and the DCE uses the [Hayes set of commands](https://en.wikipedia.org/wiki/Hayes_AT_command_set). This set prefixes each command the word `AT`. For instance reply to a call is the `A` command, so the full message becomes `ATA`.

I recommend [minicom](https://packages.debian.org/en/sid/minicom) to exchange and test the modem. Do not forget to run it as a sudoer: `sudo minicom -D /dev/ttyUSB0`.

By default the modem echoes the written keys and acknowledges the commands with:

* `OK`,
* `ERROR`,
* `CONNECT`.

## Setup

When the modem starts or after a call, I recommend to reset it configuration to a reproductible basis. The modem has a NVRAM (Non-Volatile RAM) that contains manufacturer and user configurations. The configurations are accessible with the `Zn` command, with `n` a number.

In my case I use the `ATZ0` as a reset command.

When the modem is known state you can set it up, [here is mine](https://github.com/NoelM/minigo/blob/main/notel/notel-conf.json):
```
ATE0L0M0X4&A0&N2S0=1S27=16

E0      no echo of the commands from the modem
L0      mute speaker
M0      always deactivate speaker, even before "CONNECT"
X4      highest level of verbosity
&A0     auto reply to a call after 0 rings
&N2     connect speed 1200 bauds
S0=1    "Data Send Ready" always active
S27=16  fallback on the V.23 standard
```
