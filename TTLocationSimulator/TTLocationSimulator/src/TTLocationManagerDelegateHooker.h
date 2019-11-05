//
//  TTLocationManagerDelegateHooker.h
//  TTLocationSimulator
//
//  Created by Chen,Xintao on 2019/11/5.
//  Copyright © 2019 Chen,Xintao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTLocationManagerDelegateHooker : NSObject

+ (void)hooker:(id<CLLocationManagerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
