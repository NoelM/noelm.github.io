+++
author = "Noël"
title = "My Journey Building a Magnetic Loop Antenna"
date = "2022-12-18"
draft = false
+++

Currently, I am living in a Parisian flat, and I love doing HF. But you probably know that the antenna length is proportional to wavelength, and dozens of meters cannot be found in a Parisian flat, believe me. So, I found mag-loop antennas a good compromise to operate from the inside of my flat. I've looked for numerous antenna models, but for all of them, the price is always high, at least 300€.

## Antenna Design

There are a lot of designs available on the internet; the one I found the most interesting was made by OM0ET and him [Ultralight MagLoop Antenna MC-20](https://www.om0et.com/ultralight-mla-mc-20.html). The antenna covers almost all the HF bands (except the 80 meters), and the main loop remains relatively compact with 1 meter of diameter.

However, instead of building it with a coax, I preferred a copper pipe. The pipe is thicker with its 2 millimeters, allowing higher currents (proportional with the TX power). Also, the pipe has a section that is wider, with 16 millimeters, which improves the antenna efficiency. The efficiency is defined as the ratio of power converted to RF (instead of heat) concerning the input power.

As you may know, the antenna requires a capacitor that joins the tails of the loop. The capacitor must allow high voltage and reach hundreds of picofarads. I recommend using the [Mag Loop Computer](https://miguelvaca.github.io/vk3cpu/magloop.html) from VK3CPU to determine the required value. _At the opening, all the curves are displayed. First toggle only: "Tunning Cap", "Vcap", "Efficiency", and "Q". Then use the sliders to adjust the size of your antenna._

With respect to the antenna dimensions (outer loop ⌀1m, conductor ⌀16mm), the maximum capacity and voltage values are:

* Tunning Capacity: 181pF (@ 7MHz)
* V Cap: 6kV (@ 10MHz)

I bought my first capacitor on eBay, but recently I found a better place [elektrodump.nl](https://elektrodump.nl/en/48-variable-capacitor). Never bought from them, but the quality looks better, and the descriptions are more detailed. Unfortunately, my capacitor (the one from eBay) is not designed for high voltages. The maximum voltage a capacitor allows can be inferred for the [spacing between the plates](https://ham.stackexchange.com/a/6294). The last solution is doing it yourself; one can find [a relevant tutorial](https://www.instructables.com/Lets-Build-High-Voltage-Butterfly-Variable-Air-Cap/).

![Global view of the antenna](https://mastodon.radio/system/media_attachments/files/109/534/089/914/206/493/original/164e340f6d688553.jpeg)
![The tuning capacitor](https://mastodon.radio/system/media_attachments/files/109/534/084/667/475/306/original/ef53dd0f9aee6dd0.jpeg)

## Epilogue

This antenna was terrible regarding SWR; even with a nanoVNA, I couldn't find its best configuration...

![Testing the antenna, but with poor SWR](https://mastodon.radio/system/media_attachments/files/109/530/955/279/661/076/original/5f51743f87e747d9.jpeg)
