//
//  NSObject+TTSwizzle.h
//  TTLocationSimulator
//
//  Created by Chen,Xintao on 2019/11/5.
//  Copyright © 2019 Chen,Xintao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (TTSwizzle)

+ (BOOL)ttls_swizzleMethod:(SEL)origSel
                withMethod:(SEL)altSel
                     error:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
