//
//  CLLocationManager+BNKTrackToolKit.h
//  BNKTrackTool
//
//  Created by szbd on 2019/9/24.
//  Copyright © 2019 chenxintao01. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 CLLocationManager的BNKTrackToolKit分类，重写CLLocationManager部分方法的实现
 */
@interface CLLocationManager (BNKTrackToolKit)

/**
 重写CLLocationManager的setDelegate:方法

 @param delegate CLLocationManager的delegate
 */
- (void)bnk_setDelegate:(id<CLLocationManagerDelegate>)delegate;

/**
 重写CLLocationManager的startUpdatingLocation方法
 */
- (void)bnk_startUpdatingLocation;

/**
 重写CLLocationManager的stopUpdatingLocation方法
 */
- (void)bnk_stopUpdatingLocation;

@end

NS_ASSUME_NONNULL_END
