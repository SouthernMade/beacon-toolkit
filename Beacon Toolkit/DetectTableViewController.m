//
//  DetectTableViewController.m
//  Beacon Toolkit
//
//  Created by Justin Ramos on 4/2/16.
//  Copyright © 2016 Justin Ramos. Released under the MIT license.
//

#import "DetectViewController.h"
#import "DetectTableViewCell.h"
#import "DetectTableViewController.h"

@interface DetectTableViewController ()

@end

@implementation DetectTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self initRegion];
    [self.locationManager requestWhenInUseAuthorization];

}

- (void)initRegion {
    NSString *beaconUUID = [[NSUserDefaults standardUserDefaults] stringForKey:@"beaconUUID"];
    NSString *beaconIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:@"beaconIdentifier"];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beaconUUID];
    
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    _beacons = beacons;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _beacons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"beaconCell" forIndexPath:indexPath];
    CLBeacon *beacon = _beacons[indexPath.row];

    cell.majorLabel.text = [beacon.major stringValue];
    cell.minorLabel.text = [beacon.minor stringValue];
    cell.accuracyLabel.text = [NSString stringWithFormat:@"%d", (int) round(beacon.accuracy)];

    if (beacon.proximity == CLProximityUnknown) {
        cell.distanceLabel.text = @"Unknown";
    } else if (beacon.proximity == CLProximityImmediate) {
        cell.distanceLabel.text = @"Immediate";
    } else if (beacon.proximity == CLProximityNear) {
        cell.distanceLabel.text = @"Near";
    } else if (beacon.proximity == CLProximityFar) {
        cell.distanceLabel.text = @"Far";
    }

    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *cell = sender;
    DetectViewController *destination = [segue destinationViewController];
    CLBeacon *beacon = _beacons[[[self.tableView indexPathForCell:cell] row]];    
    destination.beacon = beacon;
}

@end
