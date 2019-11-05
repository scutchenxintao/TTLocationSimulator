//
//  CLLocationManager+TTLocationSimulator.m
//  TTLocationSimulator
//
//  Created by Chen,Xintao on 2019/11/5.
//  Copyright © 2019 Chen,Xintao. All rights reserved.
//

#import "CLLocationManager+TTLocationSimulator.h"
#import <objc/runtime.h>
#import "NSObject+TTSwizzle.h"
#import "TTLocationManagerDelegateHooker.h"

#define     Location_Simulate                    @"location_simulate"
#define     LocationManager_theRealDelegate         @"locationmanager_therealdelegate"
#define     LocationManager_UpdateLocation          @"locationmanager_updatelocation"

extern NSString* const TTLSPostOneLocationNotification;

@implementation CLLocation (TTLocationSimulator)

- (void)setSimulate:(BOOL)simulate
{
    objc_setAssociatedObject(self, (const void *)Location_Simulate, @(simulate), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)simulate
{
    NSNumber* value = objc_getAssociatedObject(self, (const void *)Location_Simulate);
    return [value boolValue];
}

@end

@implementation CLLocationManager (TTLocationSimulator)

/**
 重载load方法，交换CLLocationManager部分方法的系统实现
 */
+ (void)load
{
    [NSClassFromString(@"CLLocationManager") ttls_swizzleMethod:@selector(setDelegate:) withMethod:@selector(ttls_setDelegate:) error:NULL];
    
    [NSClassFromString(@"CLLocationManager") ttls_swizzleMethod:@selector(startUpdatingLocation) withMethod:@selector(ttls_startUpdatingLocation) error:NULL];
    [NSClassFromString(@"CLLocationManager") ttls_swizzleMethod:@selector(stopUpdatingLocation) withMethod:@selector(ttls_stopUpdatingLocation) error:NULL];
}

- (void)ttls_setDelegate:(id<CLLocationManagerDelegate>)delegate
{
    self.theRealDelegate = delegate;
    [self ttls_setDelegate:delegate];
    [TTLocationManagerDelegateHooker hooker:delegate];
    
}

- (void)ttls_startUpdatingLocation
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievePostGPSNotification:) name:TTLSPostOneLocationNotification object:nil];
    [self ttls_startUpdatingLocation];
}

- (void)ttls_stopUpdatingLocation
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTLSPostOneLocationNotification object:nil];
    [self ttls_stopUpdatingLocation];
}

- (void)recievePostGPSNotification:(NSNotification*)ns
{
    CLLocation* location = ns.userInfo[@"location"];
    if (!location)
        return;
    if ([self.theRealDelegate respondsToSelector:@selector(locationManager:didUpdateLocations:)])
    {
        [self.theRealDelegate locationManager:self didUpdateLocations:@[location]];
    }
}

- (id<CLLocationManagerDelegate>)delegate
{
    return self.theRealDelegate;
}

- (void)setTheRealDelegate:(id<CLLocationManagerDelegate>)theRealDelegate
{
    objc_setAssociatedObject(self, (const void *)LocationManager_theRealDelegate, theRealDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<CLLocationManagerDelegate>)theRealDelegate
{
    return objc_getAssociatedObject(self, (const void *)LocationManager_theRealDelegate);
}

@end
