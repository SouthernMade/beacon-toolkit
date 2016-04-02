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

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)initRegion {
    NSString *beaconUUID = [[NSUserDefaults standardUserDefaults] stringForKey:@"beaconUUID"];
    NSInteger beaconMajor = [[NSUserDefaults standardUserDefaults] integerForKey:@"beaconMajor"];
    NSInteger beaconMinor = [[NSUserDefaults standardUserDefaults] integerForKey:@"beaconMinor"];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beaconUUID];

    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                major:beaconMajor
                                                                minor:beaconMinor
                                                           identifier:@"com.github.jramos"];

    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    self.beaconFoundLabel.text = @"No";
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    CLBeacon *beacon = [[CLBeacon alloc] init];
    beacon = [beacons firstObject];
    
    self.beaconFoundLabel.text = @"Yes";
    self.proximityUUIDLabel.text = beacon.proximityUUID.UUIDString;
    self.majorLabel.text = [NSString stringWithFormat:@"%@", beacon.major];
    self.minorLabel.text = [NSString stringWithFormat:@"%@", beacon.minor];
    self.accuracyLabel.text = [NSString stringWithFormat:@"%f", beacon.accuracy];

    if (beacon.proximity == CLProximityUnknown) {
        self.distanceLabel.text = @"Unknown";
    } else if (beacon.proximity == CLProximityImmediate) {
        self.distanceLabel.text = @"Immediate";
    } else if (beacon.proximity == CLProximityNear) {
        self.distanceLabel.text = @"Near";
    } else if (beacon.proximity == CLProximityFar) {
        self.distanceLabel.text = @"Far";
    }

    self.rssiLabel.text = [NSString stringWithFormat:@"%li", (long)beacon.rssi];
}

@end
