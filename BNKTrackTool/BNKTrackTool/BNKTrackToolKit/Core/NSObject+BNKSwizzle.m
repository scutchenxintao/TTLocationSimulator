//
//  NSObject+BNKSwizzle.m
//  BNKTrackTool
//
//  Created by szbd on 2019/9/24.
//  Copyright © 2019 chenxintao01. All rights reserved.
//

#import "NSObject+BNKSwizzle.h"
#import <objc/runtime.h>

@implementation NSObject (BNKSwizzle)

/**
 实现OC方法交换
 
 @param origSel 原方法
 @param altSel 替换后的方法
 @param error 错误
 @return 是否替换成功
 */
+ (BOOL)bnk_swizzleMethod:(SEL)origSel
               withMethod:(SEL)altSel
                    error:(NSError**)error
{
    Method origMethod = class_getInstanceMethod(self, origSel);
    if (!origMethod) {
        return NO;
    }
    
    Method altMethod = class_getInstanceMethod(self, altSel);
    if (!altMethod) {
        return NO;
    }
    
    class_addMethod(self,
                    origSel,
                    class_getMethodImplementation(self, origSel),
                    method_getTypeEncoding(origMethod));
    class_addMethod(self,
                    altSel,
                    class_getMethodImplementation(self, altSel),
                    method_getTypeEncoding(altMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(self, origSel), class_getInstanceMethod(self, altSel));
    return YES;
}

@end
