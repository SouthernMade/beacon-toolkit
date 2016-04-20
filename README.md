# beacon-toolkit

Detect, transmit and log iBeacon sightings.

By default, UUID `C48C6716-193F-477B-B73A-C550CE582A22` is used with `00` for major/minor.

You can change the UUID and major/minor in the app settings.

## Detecting

The default UUID is searched for on all major/minors. You can use my [pi-beacon configuration](https://github.com/jramos/raspbian-ua-netinst-conf#pi-beacon) to convert a Raspberry Pi into an iBeacon that broadcasts the default UUID.

## Transmitting

The default UUID is broadcast with default major/minor. You can use another iOS device running this app to detect the beacon. A combination of `hcitool lescan` and `hcidump --raw` can also be used to detect the beacon.
