//
//  BNKTrackTool.h
//  BNKTrackTool
//
//  Created by szbd on 2019/9/24.
//  Copyright © 2019 chenxintao01. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 BNKTrackTool库对外暴露的接口类
 */
@interface BNKTrackTool : NSObject


/**
 获取BNKTrackTool单例

 @return BNKTrackTool单例
 */
+ (instancetype)getInstance;


/**
 开始定位模拟
 */
- (void)startLocationSimulation;


/**
 结束定位模拟
 */
- (void)stopLocationSimulation;


/**
 是否开启定位模拟

 @return 是否开启定位模拟
 */
- (BOOL)isLocationSimulation;


/**
 抛送一个定位信息点

 @param location 定位信息
 */
- (void)postLocation:(CLLocation*)location;



@end

NS_ASSUME_NONNULL_END
