//
//  TransmitterViewController.m
//  Beacon Toolkit
//
//  Created by Justin Ramos on 4/1/16.
//  Copyright © 2016 Justin Ramos. Released under the MIT license.
//

#import "TransmitterViewController.h"

@interface TransmitterViewController ()

@end

@implementation TransmitterViewController

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
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beaconUUID];

    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                major:0
                                                                minor:0
                                                           identifier:@"com.github.jramos"];
}

- (IBAction)transmitBeacon:(UIButton *)sender {
    self.beaconPeripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:nil];
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                     queue:nil
                                                                   options:nil];
}

- (void)setLabels {
    self.uuidLabel.text = self.beaconRegion.proximityUUID.UUIDString;
    self.majorLabel.text = [NSString stringWithFormat:@"%@", self.beaconRegion.major];
    self.minorLabel.text = [NSString stringWithFormat:@"%@", self.beaconRegion.minor];
    self.identityLabel.text = self.beaconRegion.identifier;
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        [self.peripheralManager startAdvertising:self.beaconPeripheralData];
        self.transmitButton.titleLabel.text = @"Stop Beacon";
    } else if (peripheral.state == CBPeripheralManagerStatePoweredOff) {
        [self.peripheralManager stopAdvertising];
        self.transmitButton.titleLabel.text = @"Start Beacon";
    }
}

@end
