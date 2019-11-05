//
//  NSObject+TTSwizzle.m
//  TTLocationSimulator
//
//  Created by Chen,Xintao on 2019/11/5.
//  Copyright © 2019 Chen,Xintao. All rights reserved.
//

#import "NSObject+TTSwizzle.h"
#import <objc/runtime.h>

@implementation NSObject (TTSwizzle)

+ (BOOL)ttls_swizzleMethod:(SEL)origSel
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
