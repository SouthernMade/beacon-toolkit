//
//  ViewController.m
//  Beacon Toolkit
//
//  Created by Justin Ramos on 3/31/16.
//  Copyright © 2016 Justin Ramos. Released under the MIT license.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    [self initRegion];
    [self.locationManager requestAlwaysAuthorization];
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
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
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beaconUUID];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.github.jramos"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Beacon found");
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Left region");
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    self.beaconFoundLabel.text = @"No";
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    CLBeacon *beacon = [[CLBeacon alloc] init];
    beacon = [beacons lastObject];
    
    self.beaconFoundLabel.text = @"Yes";
    self.proximityUUIDLabel.text = beacon.proximityUUID.UUIDString;
    self.majorLabel.text = [NSString stringWithFormat:@"%@", beacon.major];
    self.minorLabel.text = [NSString stringWithFormat:@"%@", beacon.minor];
    self.accuracyLabel.text = [NSString stringWithFormat:@"%f", beacon.accuracy];

    if (beacon.proximity == CLProximityUnknown) {
        self.distanceLabel.text = @"Unknown Proximity";
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
