//
//  NSObject+BNKSwizzle.h
//  BNKTrackTool
//
//  Created by szbd on 2019/9/24.
//  Copyright © 2019 chenxintao01. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (BNKSwizzle)

/**
 实现OC方法交换

 @param origSel 原方法
 @param altSel 替换后的方法
 @param error 错误
 @return 是否替换成功
 */
+ (BOOL)bnk_swizzleMethod:(SEL)origSel
               withMethod:(SEL)altSel
                    error:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
