+++
author = "Noël"
title = "My Journey Building a Magnetic Loop Antenna"
date = "2022-12-18"
draft = false
+++

Currently I am living within a parisian flat and I love doing HF... So, I found in magloop antennas a good compromise in order to operate from the inside of my flat. I've looked for numerous antenna models, but for all of them the price is always high, at least 300€.

## Antenna Design

There's a lot of designs available on the internet, the one I found the most interesting was made by OM0ET and him [Ultralight MagLoop Antenna MC-20](https://www.om0et.com/ultralight-mla-mc-20.html). The antenna covers almost all the HF bands (except the 80 meters), also the main loop remains quite compact with 1 meter of diameter.

However, instead of building it with a coax, I preferred a copper pipe. The pipe is thicker with its 2 millimeters, so it allows higher currents (proportional with the TX power). Also the pipe has a bigger section, of 16 millimeters, that improves the efficiency. The efficiency is defined as the ratio of power converted to RF (instead of heat) with respect to the input power.

As you may know, the antenna requires a capacitor that joins the tails of the loop. The capacitor must allow high voltage, and reach hundreds of picofarads. In order to determine the required value, I recommend using the [Mag Loop Computer](https://miguelvaca.github.io/vk3cpu/magloop.html) from VK3CPU. _At the opening, all the curves are displayed. I recommend first to toggle only: "Tunning Cap", "Vcap", "Efficiency" and "Q". Then use the sliders to adjust the size of your antenna._

With respect to the antenna dimensions (outer loop ⌀1m, conductor ⌀16mm), the maximum capacity and voltage values are:

* Tunning Capacity: 181pF (@ 7MHz)
* V Cap: 6kV (@ 10MHz)

I bought my first capacitor on ebay, but recently I found a better place [elektrodump.nl](https://elektrodump.nl/en/48-variable-capacitor). Never bought from them but the quality looks better and the description are accurate. Actually, my first capacitor (the one from ebay) is not designed for high voltages. The maximum voltage allowed by a capacitor can be inferred with respect to the [spacing between the plates](https://ham.stackexchange.com/a/6294). The last solution is doing it yourself, one can find here [a relevant tutorial](https://www.instructables.com/Lets-Build-High-Voltage-Butterfly-Variable-Air-Cap/).
