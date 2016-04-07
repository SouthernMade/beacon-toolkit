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
#import "SPSelfDescribingJson.h"

@interface DetectViewController ()

@property (nonatomic, strong) SPTracker *tracker;
@property (nonatomic) Boolean shouldTrackBeacon;

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

- (void)startBeaconTracking {
    [self allowBeaconTracking];

    [NSTimer scheduledTimerWithTimeInterval:30.0
                                     target:self
                                   selector:@selector(allowBeaconTracking)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)stopBeaconTracking {
    [NSTimer cancelPreviousPerformRequestsWithTarget:self selector:@selector(allowBeaconTracking) object:nil];
}

- (void)allowBeaconTracking {
    self.shouldTrackBeacon = true;
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
        self.shouldTrackBeacon &&
        [self.locationManager location] &&
        beacon.accuracy < 20.0 &&
        beacon.accuracy > 0.0
    ) {
        self.shouldTrackBeacon = false;
        [[Acuminous sharedInstance] setGeoContextFor:[self.locationManager location]];

        NSString *schema = @"iglu:io.acuminous.cumulo/ibeacon_sighting/jsonschema/1-0-0";
        NSDictionary *data = @{
            @"uuid": beacon.proximityUUID.UUIDString,
            @"major": beacon.major,
            @"minor": beacon.minor,
            @"accuracy": [NSNumber numberWithDouble:beacon.accuracy],
            @"proximity": proximity,
            @"rssi": [NSNumber numberWithLong:beacon.rssi]
        };

        SPSelfDescribingJson *sdj = [[SPSelfDescribingJson alloc] initWithSchema:schema
                                                                          andData:data];

        SPUnstructured *event = [SPUnstructured build:^(id<SPUnstructuredBuilder> builder) {
            [builder setEventData:sdj];
        }];
        
        [self.tracker trackUnstructuredEvent:event];
        [[Acuminous sharedInstance] flushBuffer];
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self startBeaconTracking];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self startBeaconTracking];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self stopBeaconTracking];
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

    if (![self.distanceLabel.text isEqual:@"Unknown"]) {
        [self trackBeaconSighting:_beacon withProximity:self.distanceLabel.text];
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
