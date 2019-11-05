//
//  CLLocation+BNKTrackToolKit.h
//  BNKTrackTool
//
//  Created by szbd on 2019/9/24.
//  Copyright © 2019 chenxintao01. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 CLLocation BNKTrackToolKit分类
 */
@interface CLLocation (BNKTrackToolKit)

/**
 是否是通过BNKTrackTool的postLocation方法产生的点，如果是bnkFake为YES，否则为NO
 */
@property (assign, nonatomic) BOOL bnkFake;

@end

NS_ASSUME_NONNULL_END
