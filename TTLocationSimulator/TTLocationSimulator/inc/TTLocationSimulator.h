//
//  TTLocationSimulator.h
//  TTLocationSimulator
//
//  Created by Chen,Xintao on 2019/11/5.
//  Copyright © 2019 Chen,Xintao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TTLocationSimulator : NSObject

+ (instancetype)getInstance;

- (void)startLocationSimulation;

- (void)stopLocationSimulation;

- (BOOL)isLocationSimulation;

- (void)postLocation:(CLLocation*)location;

@end
