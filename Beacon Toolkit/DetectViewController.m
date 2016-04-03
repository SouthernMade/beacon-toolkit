//
//  DetectViewController.m
//  Beacon Toolkit
//
//  Created by Justin Ramos on 3/31/16.
//  Copyright © 2016 Justin Ramos. Released under the MIT license.
//

#import "DetectViewController.h"

@interface DetectViewController ()

@end

@implementation DetectViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    [self initRegion];
    [self.locationManager requestWhenInUseAuthorization];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initRegion {
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_beacon.proximityUUID
                                                                major:_beacon.major.shortValue
                                                                minor:_beacon.minor.shortValue
                                                           identifier:@"com.github.jramos"];

    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    self.beaconFoundLabel.text = @"No";
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    _beacon = [beacons firstObject];

    self.beaconFoundLabel.text = @"Yes";
    self.proximityUUIDLabel.text = _beacon.proximityUUID.UUIDString;
    self.majorLabel.text = _beacon.major.stringValue;
    self.minorLabel.text = _beacon.minor.stringValue;
    self.accuracyLabel.text = [NSString stringWithFormat:@"%f", _beacon.accuracy];

    if (_beacon.proximity == CLProximityUnknown) {
        self.distanceLabel.text = @"Unknown";
    } else if (_beacon.proximity == CLProximityImmediate) {
        self.distanceLabel.text = @"Immediate";
    } else if (_beacon.proximity == CLProximityNear) {
        self.distanceLabel.text = @"Near";
    } else if (_beacon.proximity == CLProximityFar) {
        self.distanceLabel.text = @"Far";
    }

    self.rssiLabel.text = [NSString stringWithFormat:@"%li", (long)_beacon.rssi];
}

@end
