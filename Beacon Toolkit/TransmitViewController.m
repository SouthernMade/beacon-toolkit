//
//  TransmitterViewController.m
//  Beacon Toolkit
//
//  Created by Justin Ramos on 4/1/16.
//  Copyright © 2016 Justin Ramos. Released under the MIT license.
//

#import "TransmitViewController.h"

@interface TransmitViewController ()

@end

@implementation TransmitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initBeacon];
    [self setLabels];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initBeacon {
    NSString *beaconUUID = [[NSUserDefaults standardUserDefaults] stringForKey:@"beaconUUID"];
    NSInteger beaconMajor = [[NSUserDefaults standardUserDefaults] integerForKey:@"beaconMajor"];
    NSInteger beaconMinor = [[NSUserDefaults standardUserDefaults] integerForKey:@"beaconMinor"];
    NSString *beaconIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:@"beaconIdentifier"];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beaconUUID];

    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                major:beaconMajor
                                                                minor:beaconMinor
                                                           identifier:beaconIdentifier];
}

- (IBAction)transmitBeacon:(UIButton *)sender {
    if ([self.peripheralManager isAdvertising]) {
        self.transmitButton.titleLabel.text = @"Start Beacon";
        [self.peripheralManager stopAdvertising];
    } else {
        self.beaconPeripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:nil];
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                         queue:nil
                                                                       options:nil];
    }
}

- (void)setLabels {
    self.uuidLabel.text = self.beaconRegion.proximityUUID.UUIDString;
    self.majorLabel.text = [NSString stringWithFormat:@"%@", self.beaconRegion.major];
    self.minorLabel.text = [NSString stringWithFormat:@"%@", self.beaconRegion.minor];
    self.identityLabel.text = self.beaconRegion.identifier;
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        self.transmitButton.titleLabel.text = @"Stop Beacon";
        [self.peripheralManager startAdvertising:self.beaconPeripheralData];
    }
}

@end
