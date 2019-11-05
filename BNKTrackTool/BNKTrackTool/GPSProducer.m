//
//  GPSProducer.m
//  BNKTrackTool
//
//  Created by szbd on 2019/9/25.
//  Copyright © 2019 chenxintao01. All rights reserved.
//

#import "GPSProducer.h"
#import <CoreLocation/CoreLocation.h>
#import "BNKTrackTool.h"

static NSTimeInterval GPSProducerInterval = 1.0f;

@interface GPSProducer()

@property (strong, nonatomic) NSTimer* timer;

@end

@implementation GPSProducer

- (void)startPostGPS
{
    if (self.timer)
        return;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:GPSProducerInterval target:self selector:@selector(produceGPS) userInfo:nil repeats:YES];
    [[BNKTrackTool getInstance] startLocationSimulation];
    [self.timer fire];
}

- (void)stopPostGPS
{
    if (!self.timer)
        return;
    [[BNKTrackTool getInstance] stopLocationSimulation];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)produceGPS
{
    CLLocation* location = [[CLLocation alloc] initWithLatitude:22.32 longitude:114.03];
    [[BNKTrackTool getInstance] postLocation:location];
}

@end
