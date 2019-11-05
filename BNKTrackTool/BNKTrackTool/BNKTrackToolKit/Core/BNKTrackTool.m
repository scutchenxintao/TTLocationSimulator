//
//  BNKTrackTool.m
//  BNKTrackTool
//
//  Created by szbd on 2019/9/24.
//  Copyright © 2019 chenxintao01. All rights reserved.
//

#import "BNKTrackTool.h"
#import "BNKConstant.h"
#import "CLLocation+BNKTrackToolKit.h"

@interface BNKTrackTool()

@property (assign, nonatomic) BOOL locationSimulation;

@end

@implementation BNKTrackTool

#pragma mark -- BNKTrackTool单例

+ (instancetype)getInstance
{
    static dispatch_once_t onceToken;
    static BNKTrackTool* sharedTrackTool = nil;
    dispatch_once(&onceToken, ^{
        sharedTrackTool = [[BNKTrackTool alloc] init];
    });
    return sharedTrackTool;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [BNKTrackTool getInstance] ;
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [BNKTrackTool getInstance] ;
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
    location.bnkFake = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:BNKPostOneGPSNotification object:nil userInfo:@{@"gps":location}];
}

@end
