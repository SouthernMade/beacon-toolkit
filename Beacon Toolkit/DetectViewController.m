//
//  DetectViewController.m
//  Beacon Toolkit
//
//  Created by Justin Ramos on 3/31/16.
//  Copyright © 2016 Justin Ramos. Released under the MIT license.
//

#import "DetectViewController.h"

@interface DetectViewController ()

@property (nonatomic, strong) NSMutableArray *locations;

@end

@implementation DetectViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];

    [self.mapView setRegion:[self mapRegion] animated: YES];
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

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *newLocation in locations) {
        if (newLocation.horizontalAccuracy < 10) {
            [_locations addObject:newLocation];
        }
    }
}

// MARK: MapKit

- (MKCoordinateRegion)mapRegion {
    MKCoordinateRegion region;
    CLLocation *initialLoc = _locations.firstObject;
    
    float minLat = initialLoc.coordinate.latitude;
    float minLng = initialLoc.coordinate.longitude;
    float maxLat = initialLoc.coordinate.latitude;
    float maxLng = initialLoc.coordinate.longitude;
    
    for (CLLocation *_location in _locations) {
        if (_location.coordinate.latitude < minLat) {
            minLat = _location.coordinate.latitude;
        }
        if (_location.coordinate.longitude < minLng) {
            minLng = _location.coordinate.longitude;
        }
        if (_location.coordinate.latitude > maxLat) {
            maxLat = _location.coordinate.latitude;
        }
        if (_location.coordinate.longitude > maxLng) {
            maxLng = _location.coordinate.longitude;
        }
    }
    
    region.center.latitude = (minLat + maxLat) / 2.0f;
    region.center.longitude = (minLng + maxLng) / 2.0f;
    
    region.span.latitudeDelta = (maxLat - minLat) * 1.1f; // 10% padding
    region.span.longitudeDelta = (maxLng - minLng) * 1.1f; // 10% padding
    
    return region;
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion mapRegion;
    mapRegion.center = mapView.userLocation.coordinate;    
    [mapView setRegion:mapRegion];
}

@end
