//
//  CLLocation+BNKTrackToolKit.m
//  BNKTrackTool
//
//  Created by szbd on 2019/9/24.
//  Copyright © 2019 chenxintao01. All rights reserved.
//

#import "CLLocation+BNKTrackToolKit.h"
#import <objc/runtime.h>

#define     Location_Fake                    @"location_fake"

@implementation CLLocation (BNKTrackToolKit)


/**
bnkFake set方法

 @param fake fake的值
 */
- (void)setBnkFake:(BOOL)fake
{
    objc_setAssociatedObject(self, (const void *)Location_Fake, @(fake), OBJC_ASSOCIATION_RETAIN);
}


/**
 bnkFake get方法

 @return bnkFake的值
 */
- (BOOL)bnkFake
{
    NSNumber* fake = objc_getAssociatedObject(self, (const void *)Location_Fake);
    return [fake boolValue];
}


@end
