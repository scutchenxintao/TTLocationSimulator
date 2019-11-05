//
//  CLLocationManager+TTLocationSimulator.h
//  TTLocationSimulator
//
//  Created by Chen,Xintao on 2019/11/5.
//  Copyright © 2019 Chen,Xintao. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLLocation (TTLocationSimulator)

@property (assign, nonatomic) BOOL simulate;

@end

@interface CLLocationManager (TTLocationSimulator)


@end

NS_ASSUME_NONNULL_END
