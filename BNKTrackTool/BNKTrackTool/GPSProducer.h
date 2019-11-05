//
//  GPSProducer.h
//  BNKTrackTool
//
//  Created by szbd on 2019/9/25.
//  Copyright © 2019 chenxintao01. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GPSProducer : NSObject

- (void)startPostGPS;

- (void)stopPostGPS;

@end

NS_ASSUME_NONNULL_END
