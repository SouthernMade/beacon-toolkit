//
//  DetectTableViewController.h
//  Beacon Toolkit
//
//  Created by Justin Ramos on 4/2/16.
//  Copyright © 2016 Justin Ramos. Released under the MIT license.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface DetectTableViewController : UITableViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *beacons;

@end
