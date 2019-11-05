//
//  TTLocationSimulator.m
//  TTLocationSimulator
//
//  Created by Chen,Xintao on 2019/11/5.
//  Copyright © 2019 Chen,Xintao. All rights reserved.
//

#import "TTLocationSimulator.h"
#import "CLLocationManager+TTLocationSimulator.h"

NSString* const TTLSPostOneLocationNotification = @"TTLSPostOneLocationNotification";


@interface TTLocationSimulator ()

@property (assign, nonatomic) BOOL locationSimulation;

@end

@implementation TTLocationSimulator

+ (instancetype)getInstance
{
    static dispatch_once_t onceToken;
    static TTLocationSimulator* shareInstance = nil;
    dispatch_once(&onceToken, ^{
        shareInstance = [[TTLocationSimulator alloc] init];
    });
    return shareInstance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _locationSimulation = NO;
    }
    return self;
}

#pragma mark -- public method

- (BOOL)isLocationSimulation
{
    return _locationSimulation;
}

- (void)startLocationSimulation
{
    _locationSimulation = YES;
}

- (void)stopLocationSimulation
{
    _locationSimulation = NO;
}

- (void)postLocation:(CLLocation*)location
{
    if (!location)
        return;
    location.simulate = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:TTLSPostOneLocationNotification object:nil userInfo:@{@"location":location}];
}

@end
