//
//  DetectTableViewCell.h
//  Beacon Toolkit
//
//  Created by Justin Ramos on 4/7/16.
//  Copyright © 2016 Justin Ramos. Released under the MIT license.
//

#import <UIKit/UIKit.h>

@interface DetectTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@end
