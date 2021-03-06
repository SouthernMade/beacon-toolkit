# beacon-toolkit

Detect, transmit and log iBeacon sightings.

By default, UUID `C48C6716-193F-477B-B73A-C550CE582A22` is used with `00` for major/minor.

You can change the UUID and major/minor in the app settings.

## Detecting

The default UUID is searched for on all major/minors. The BKON beacons have been configured to broadcast this UUID.

### Logging

When detecting, an Acuminous event will be emitted every 30 seconds with the beacon information and a geolocation context for the user. The app_id is `beacon_toolkit`.

## Transmitting

The default UUID is broadcast with default major/minor. You can use another iOS device running this app to detect the beacon. A combination of `hcitool lescan` and `hcidump --raw` can also be used to detect the beacon.
