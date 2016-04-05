//
//  Acuminous.m
//  Beacon Toolkit
//
//  Created by Justin Ramos on 4/5/16.
//  Copyright © 2016 Justin Ramos. Released under the MIT license.
//

#import <CoreLocation/CoreLocation.h>
#import "Acuminous.h"
#import "SPEmitter.h"
#import "SPSubject.h"
#import "SPTracker.h"

@interface Acuminous ()

@property (nonatomic, retain) SPTracker *tracker;
@property (nonatomic, retain) NSDictionary *config;

@end

@implementation Acuminous

+ (instancetype)sharedInstance {
    static Acuminous *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

+ (SPTracker*)sharedTracker {
    return [[self sharedInstance] tracker];
}

- (instancetype)init {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Acuminous" ofType:@"plist"];
    _config = [[[NSDictionary alloc] initWithContentsOfFile:path] objectForKey:@"Acuminous"];
    
    return [self initWithUrl:[_config objectForKey:@"TrackerHostname"]];
}

- (instancetype)initWithUrl:(NSString *)url_ {
    self = [super init];
    
    if (self) {
        _tracker = [SPTracker build:^(id<SPTrackerBuilder> builder) {
            [builder setAppId:[_config objectForKey:@"AppId"]];
            [builder setTrackerNamespace:[_config objectForKey:@"TrackerNamespace"]];
            [builder setBase64Encoded:[_config objectForKey:@"Base64Encoded"]];
            [builder setSessionContext:[_config objectForKey:@"InitSessionContext"]];
            [builder setEmitter:[SPEmitter build:^(id<SPEmitterBuilder> builder) {
                [builder setUrlEndpoint:url_];
                [builder setProtocol:SPHttp];
                [builder setHttpMethod:SPRequestPost];
            }]];
        }];
        
        [_tracker setSubject:[[SPSubject alloc] initWithPlatformContext:[_config objectForKey:@"InitPlatformContext"]
                                                          andGeoContext:[_config objectForKey:@"InitGeoContext"]]];
        [_tracker.emitter setCallback:self];
    }
    
    return self;
}

- (void) setUserId:(NSString *)uid {
    SPSubject *subject = [[self class] sharedTracker].subject;
    [subject setUserId:uid];
}

- (void) setTimezone:(NSString *)timezone {
    SPSubject *subject = [[self class] sharedTracker].subject;
    [subject setTimezone:timezone];
}

- (void) setLanguage:(NSString *)language {
    SPSubject *subject = [[self class] sharedTracker].subject;
    [subject setLanguage:language];
}

- (void) setGeoContextFor:(CLLocation *) location {
    SPSubject *subject = [[self class] sharedTracker].subject;

    [subject setGeoLatitude:[location coordinate].latitude];
    [subject setGeoLongitude:[location coordinate].longitude];
    [subject setGeoLatitudeLongitudeAccuracy:[location horizontalAccuracy]];
    [subject setGeoAltitude:[location altitude]];
    [subject setGeoAltitudeAccuracy:[location verticalAccuracy]];
    [subject setGeoBearing:[location course]];
    [subject setGeoSpeed:[location speed]];
}

- (void) flushBuffer {
    SPEmitter *emitter = [[self class] sharedTracker].emitter;
    [emitter flushBuffer];
}

// Callback Functions

- (void) onSuccessWithCount:(NSInteger)successCount {
    NSLog(@"Tracked %li events successfully", successCount);
}

- (void) onFailureWithCount:(NSInteger)failureCount successCount:(NSInteger)successCount {
    NSLog(@"Failed to track %li events", failureCount);
}

@end
