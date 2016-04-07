//
//  Acuminous.h
//  Beacon Toolkit
//
//  Created by Justin Ramos on 4/5/16.
//  Copyright © 2016 Justin Ramos. Released under the MIT license.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "SPTracker.h"
#import "SPRequestCallback.h"

@interface Acuminous : NSObject <SPRequestCallback>

+ (instancetype)sharedInstance;
+ (SPTracker*)sharedTracker;

- (void) setUserId:(NSString *)uid;
- (void) setTimezone:(NSString *)timezone;
- (void) setLanguage:(NSString *)language;
- (void) setGeoContextFor:(CLLocation *) location;

- (void) flushBuffer;

@end
