//
//  CLLocationManager+BNKTrackToolKit.m
//  BNKTrackTool
//
//  Created by szbd on 2019/9/24.
//  Copyright © 2019 chenxintao01. All rights reserved.
//

#import "CLLocationManager+BNKTrackToolKit.h"
#import "NSObject+BNKSwizzle.h"
#import "BNKLocationManagerDelegateHooker.h"
#import "BNKConstant.h"
#import "BNKTrackTool.h"
#import <objc/runtime.h>


#define     LocationManager_theRealDelegate         @"locationmanager_therealdelegate"
#define     LocationManager_UpdateLocation          @"locationmanager_updatelocation"


@implementation CLLocationManager (BNKTrackToolKit)

/**
 重载load方法，交换CLLocationManager部分方法的系统实现
 */
+ (void)load
{
    [super load];
    
    [NSClassFromString(@"CLLocationManager") bnk_swizzleMethod:@selector(setDelegate:) withMethod:@selector(bnk_setDelegate:) error:NULL];
    
    [NSClassFromString(@"CLLocationManager") bnk_swizzleMethod:@selector(startUpdatingLocation) withMethod:@selector(bnk_startUpdatingLocation) error:NULL];
    [NSClassFromString(@"CLLocationManager") bnk_swizzleMethod:@selector(stopUpdatingLocation) withMethod:@selector(bnk_stopUpdatingLocation) error:NULL];
}

/**
 重写CLLocationManager的setDelegate:方法
 
 @param delegate CLLocationManager的delegate
 */
- (void)bnk_setDelegate:(id<CLLocationManagerDelegate>)delegate
{
    self.theRealDelegate = delegate;
    [self bnk_setDelegate:delegate];
    [BNKLocationManagerDelegateHooker hooker:delegate];
    
}

/**
 重写CLLocationManager的startUpdatingLocation方法
 */
- (void)bnk_startUpdatingLocation
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievePostGPSNotification:) name:BNKPostOneGPSNotification object:nil];
    [self bnk_startUpdatingLocation];
}

/**
 重写CLLocationManager的stopUpdatingLocation方法
 */
- (void)bnk_stopUpdatingLocation
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BNKPostOneGPSNotification object:nil];
    [self bnk_stopUpdatingLocation];
}

/**
 接收到BNKTrackTool的postLocation方法抛送的gps点

 @param ns 消息对象，ns.userInfo[@"gps"]为CLLocation对象
 */
- (void)recievePostGPSNotification:(NSNotification*)ns
{
    CLLocation* location = ns.userInfo[@"gps"];
    if (!location)
        return;
    if ([self.theRealDelegate respondsToSelector:@selector(locationManager:didUpdateLocations:)])
    {
        [self.theRealDelegate locationManager:self didUpdateLocations:@[location]];
    }
}

/**
 重写CLLocationManager的delegate方法
 */
- (id<CLLocationManagerDelegate>)delegate
{
    return self.theRealDelegate;
}

/**
 设置CLLocationManager的delegate

 @param theRealDelegate CLLocationManager的delegate
 */
- (void)setTheRealDelegate:(id<CLLocationManagerDelegate>)theRealDelegate
{
    objc_setAssociatedObject(self, (const void *)LocationManager_theRealDelegate, theRealDelegate, OBJC_ASSOCIATION_ASSIGN);
}


/**
 获取CLLocationManager的delegate

 @return CLLocationManager的delegate
 */
- (id<CLLocationManagerDelegate>)theRealDelegate
{
    return objc_getAssociatedObject(self, (const void *)LocationManager_theRealDelegate);
}

@end
