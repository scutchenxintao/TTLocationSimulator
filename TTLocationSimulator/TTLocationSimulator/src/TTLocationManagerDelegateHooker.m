//
//  TTLocationManagerDelegateHooker.m
//  TTLocationSimulator
//
//  Created by Chen,Xintao on 2019/11/5.
//  Copyright © 2019 Chen,Xintao. All rights reserved.
//

#import "TTLocationManagerDelegateHooker.h"
#import "NSObject+TTSwizzle.h"
#import "TTLocationSimulator.h"
#import "CLLocationManager+TTLocationSimulator.h"
#import <objc/runtime.h>

static void ttls_targetInvokeSelector (id target, SEL selector, int paramCount, ...)
{
    NSMethodSignature*signature = [[target class] instanceMethodSignatureForSelector:selector];
    
    NSInvocation*invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    
    invocation.selector = selector;
    
    if (paramCount > 0)
    {
        va_list list;
        va_start(list, paramCount);
        int i = 0;
        while (paramCount)
        {
            id param = va_arg(list, id);
            [invocation setArgument:&param atIndex:i + 2];
            i++;
            paramCount --;
        }
        va_end(list);
    }
    [invocation invoke];
}


static id locationManager_didUpdateLocations(id<CLLocationManagerDelegate> delegate, SEL sel,CLLocationManager* manager, NSArray* locations)
{
    if ([locations count] > 0)
    {
        CLLocation* firstLocation = locations[0];
        if ([[TTLocationSimulator getInstance] isLocationSimulation])
        {
            if (firstLocation.simulate)
            {
                ttls_targetInvokeSelector(delegate, @selector(ttls_locationManager:didUpdateLocations:),2,manager,locations);
            }
        }
        else
        {
            ttls_targetInvokeSelector(delegate, @selector(ttls_locationManager:didUpdateLocations:),2,manager,locations);
        }
    }
    return delegate;
}

static id locationManager_didUpdateToLocation_fromLocation(id<CLLocationManagerDelegate> delegate, SEL sel,CLLocationManager* manager, CLLocation * newLocation, CLLocation * oldLocation)
{
    if ([[TTLocationSimulator getInstance] isLocationSimulation])
    {
        if (newLocation.simulate)
        {
            ttls_targetInvokeSelector(delegate, @selector(ttls_locationManager:didUpdateToLocation:fromLocation:),3,manager,newLocation,oldLocation);
        }
    }
    else
    {
        ttls_targetInvokeSelector(delegate, @selector(ttls_locationManager:didUpdateToLocation:fromLocation:),3,manager,newLocation,oldLocation);
    }
    return delegate;
}

static id locationManager_didFailWithError(id<CLLocationManagerDelegate> delegate, SEL sel,CLLocationManager* manager, NSError* error)
{
    if ([[TTLocationSimulator getInstance] isLocationSimulation])
    {
        
    }
    else
    {
        ttls_targetInvokeSelector(delegate, @selector(ttls_locationManager:didFailWithError:),2,manager,error);
    }
    return delegate;
}

@interface TTLocationManagerDelegateHooker ()

@property (strong, nonatomic) NSMutableDictionary* hookerSelectorDict;

@end

@implementation TTLocationManagerDelegateHooker


+ (instancetype)getInstance
{
    static TTLocationManagerDelegateHooker* sharedHooker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHooker = [[TTLocationManagerDelegateHooker alloc] init];
    });
    return sharedHooker;
}

+ (void)restore
{
    [[[self class] getInstance] restore];
}


+ (void)hooker:(id<CLLocationManagerDelegate>)delegate
{
    [[self class] hookerLocationManagerDelegate:delegate selector:@selector(locationManager:didUpdateLocations:) function:(IMP)locationManager_didUpdateLocations];
    
    [[self class] hookerLocationManagerDelegate:delegate selector:@selector(locationManager:didUpdateToLocation:fromLocation:) function:(IMP)locationManager_didUpdateToLocation_fromLocation];
    
    [[self class] hookerLocationManagerDelegate:delegate selector:@selector(locationManager:didFailWithError:) function:(IMP)locationManager_didFailWithError];
}


+ (void)hookerLocationManagerDelegate:(id<CLLocationManagerDelegate>)delegate
                             selector:(SEL)selector
                             function:(IMP)function
{
    Class theClass = [delegate class];
    NSString* selectorName = NSStringFromSelector(selector);
    NSString* newSelectorName = [NSString stringWithFormat:@"ttls_%@",selectorName];
    SEL newSel = NSSelectorFromString(newSelectorName);
    if (![delegate respondsToSelector:newSel])
    {
        Method origMethod = class_getInstanceMethod(theClass, selector);
        class_addMethod(theClass, newSel, (IMP)function, method_getTypeEncoding(origMethod));
    }
    [[[self class] getInstance] hooker:delegate selector:selector];
    
}


- (void)restore
{
    NSArray* keys = self.hookerSelectorDict.allKeys;
    for (NSString* key in keys)
    {
        NSMutableArray* selectors = self.hookerSelectorDict[key];
        Class theClass = NSClassFromString(key);
        for (NSString* theSel in selectors)
        {
            NSError* error = nil;
            [theClass ttls_swizzleMethod:NSSelectorFromString(theSel) withMethod:NSSelectorFromString([NSString stringWithFormat:@"ttls_%@",theSel]) error:&error];
            if (error)
            {
                NSLog(@"restore error %@",theSel);
            }
        }
    }
    [self.hookerSelectorDict removeAllObjects];
}

- (void)hooker:(id<CLLocationManagerDelegate>)delegate
      selector:(SEL)selector
{
    if (!delegate)
        return;
    if ([self isHooker:delegate selector:selector])
        return;
    Class theClass = [delegate class];
    NSString* selectorName = NSStringFromSelector(selector);
    NSString* newSelectorName = [NSString stringWithFormat:@"ttls_%@",selectorName];
    SEL newSel = NSSelectorFromString(newSelectorName);
    NSError* error = nil;
    [theClass ttls_swizzleMethod:selector withMethod:newSel error:&error];
    if (error)
    {
        NSLog(@"hooker error %@ %@",delegate,NSStringFromSelector(selector));
    }
    [self addHooker:delegate selector:selector];
}

- (BOOL)isHooker:(id)object selector:(SEL)sel
{
    if (!object)
        return NO;
    NSString* className = NSStringFromClass([object class]);
    
    NSMutableArray* selectors = self.hookerSelectorDict[className];
    if (!selectors)
    {
        return NO;
    }
    NSString* selectorName = NSStringFromSelector(sel);
    BOOL bFound = NO;
    for (NSString* sel in selectors)
    {
        if ([sel isEqualToString:selectorName])
        {
            bFound = YES;
            break;
        }
    }
    return bFound;
}


- (void)addHooker:(id)object selector:(SEL)selector
{
    if (!object)
        return;
    NSString* className = NSStringFromClass([object class]);
    
    NSMutableArray* selectors = self.hookerSelectorDict[className];
    if (!selectors)
    {
        selectors = [NSMutableArray array];
        self.hookerSelectorDict[className] = selectors;
    }
    
    NSString* selectorName = NSStringFromSelector(selector);
    BOOL bFound = NO;
    for (NSString* sel in selectors)
    {
        if ([sel isEqualToString:selectorName])
        {
            bFound = YES;
            break;
        }
    }
    if (!bFound)
    {
        [selectors addObject:selectorName];
    }
}

- (void)removeHooker:(id)object selector:(SEL)selector
{
    if (!object)
        return;
    NSString* className = NSStringFromClass([object class]);
    
    NSMutableArray* selectors = self.hookerSelectorDict[className];
    if (!selectors)
        return;
    
    NSString* selectorName = NSStringFromSelector(selector);
    int index = -1;
    for (int i = 0; i < selectors.count; ++i)
    {
        NSString* sel = selectors[i];
        if ([sel isEqualToString:selectorName])
        {
            index = i;
            break;
        }
    }
    if (index >= 0)
    {
        [selectors removeObjectAtIndex:index];
    }
    
}

- (NSMutableDictionary*)hookerSelectorDict
{
    if (!_hookerSelectorDict)
    {
        _hookerSelectorDict = [[NSMutableDictionary alloc] init];
    }
    return _hookerSelectorDict;
}

@end
