//
//  BNKLocationManagerDelegateHooker.h
//  BNKTrackTool
//
//  Created by szbd on 2019/9/24.
//  Copyright © 2019 chenxintao01. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


/**
 关键类，负责hook CLLocationManager delegate的位置回调方法
 */
@interface BNKLocationManagerDelegateHooker : NSObject

/**
 hook CLLocationManager delegate的位置回调方法

 @param delegate CLLocationManager的delegate
 */
+ (void)hooker:(id<CLLocationManagerDelegate>)delegate;

@end
