//
//  DetectViewController.m
//  Beacon Toolkit
//
//  Created by Justin Ramos on 3/31/16.
//  Copyright © 2016 Justin Ramos. Released under the MIT license.
//

#import "Acuminous.h"
#import "DetectViewController.h"
#import "SPEvent.h"

@interface DetectViewController ()

@property (nonatomic, strong) SPTracker *tracker;

@end

@implementation DetectViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 3;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self setTracker:[Acuminous sharedTracker]];
    [self initRegion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initRegion {
    NSString *beaconIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:@"beaconIdentifier"];

    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_beacon.proximityUUID
                                                                major:_beacon.major.shortValue
                                                                minor:_beacon.minor.shortValue
                                                           identifier:beaconIdentifier];

    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void) trackBeaconSighting:(CLBeacon *)beacon withProximity:(NSString *)proximity {
    if (
        [self.locationManager location] &&
        beacon.accuracy < 10.0 &&
        beacon.accuracy > 0.0
    ) {
        SPStructured *event = [SPStructured build:^(id<SPStructuredBuilder> builder) {
            [builder setCategory:@"beacon"];
            [builder setAction:@"detect"];
            [builder setLabel:beacon.proximityUUID.UUIDString];
            [builder setProperty:proximity];
            [builder setValue:_beacon.accuracy];
        }];
        
        [[Acuminous sharedInstance] setGeoContextFor:[self.locationManager location]];
        [self.tracker trackStructuredEvent:event];
    }
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
        [self trackBeaconSighting:_beacon withProximity:@"Immediate"];
    } else if (_beacon.proximity == CLProximityNear) {
        self.distanceLabel.text = @"Near";
        [self trackBeaconSighting:_beacon withProximity:@"Near"];
    } else if (_beacon.proximity == CLProximityFar) {
        self.distanceLabel.text = @"Far";
        [self trackBeaconSighting:_beacon withProximity:@"Far"];
    }

    self.rssiLabel.text = [NSString stringWithFormat:@"%li", (long)_beacon.rssi];
}

// MARK: MapKit

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    MKCoordinateRegion mapRegion;
    mapRegion.center = mapView.userLocation.coordinate;
    [mapView setRegion:mapRegion];
}

@end
