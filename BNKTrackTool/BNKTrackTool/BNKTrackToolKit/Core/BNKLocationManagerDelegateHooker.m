//
//  BNKLocationManagerDelegateHooker.m
//  BNKTrackTool
//
//  Created by szbd on 2019/9/24.
//  Copyright © 2019 chenxintao01. All rights reserved.
//

#import "BNKLocationManagerDelegateHooker.h"
#import "CLLocation+BNKTrackToolKit.h"
#import "NSObject+BNKSwizzle.h"
#import "BNKTrackTool.h"

#import <objc/runtime.h>


/**
 C函数实现某个OC方法

 @param target OC对象
 @param selector 具体的OC方法
 @param paramCount 参数个数
 @param ... 不定参数
 */
static void bnk_targetInvokeSelector (id target, SEL selector, int paramCount, ...)
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


/**
 重新实现locationmanager的delegate locationManager:didUpdateLocations:方法

 @param delegate locationManager delegate
 @param sel 替换的方法
 @param manager locationManagers实例对象
 @param locations 新的位置信息
 @return locationManager delegate
 */
static id locationManager_didUpdateLocations(id<CLLocationManagerDelegate> delegate, SEL sel,CLLocationManager* manager, NSArray* locations)
{
    if ([locations count] > 0)
    {
        CLLocation* firstLocation = locations[0];
        if ([[BNKTrackTool getInstance] isLocationSimulation])
        {
            if (firstLocation.bnkFake)
            {
                bnk_targetInvokeSelector(delegate, @selector(bnk_locationManager:didUpdateLocations:),2,manager,locations);
            }
        }
        else
        {
            bnk_targetInvokeSelector(delegate, @selector(bnk_locationManager:didUpdateLocations:),2,manager,locations);
        }
    }
    return delegate;
}


/**
 重新实现locationManager delegate的locationManager:didUpdateToLocation:fromLocation:方法实现

 @param delegate locationManager delegate
 @param sel 替换的方法
 @param manager locationManagers实例对象
 @param newLocation 新的location
 @param oldLocation 老的location
 @return locationManager delegate
 */
static id locationManager_didUpdateToLocation_fromLocation(id<CLLocationManagerDelegate> delegate, SEL sel,CLLocationManager* manager, CLLocation * newLocation, CLLocation * oldLocation)
{
    if ([[BNKTrackTool getInstance] isLocationSimulation])
    {
        if (newLocation.bnkFake)
        {
            bnk_targetInvokeSelector(delegate, @selector(bnk_locationManager:didUpdateToLocation:fromLocation:),3,manager,newLocation,oldLocation);
        }
    }
    else
    {
        bnk_targetInvokeSelector(delegate, @selector(bnk_locationManager:didUpdateToLocation:fromLocation:),3,manager,newLocation,oldLocation);
    }
    return delegate;
}

static id locationManager_didFailWithError(id<CLLocationManagerDelegate> delegate, SEL sel,CLLocationManager* manager, NSError* error)
{
    if ([[BNKTrackTool getInstance] isLocationSimulation])
    {
        
    }
    else
    {
        bnk_targetInvokeSelector(delegate, @selector(bnk_locationManager:didFailWithError:),2,manager,error);
    }
    return delegate;
}

static BNKLocationManagerDelegateHooker* sharedHooker = nil;

@interface BNKLocationManagerDelegateHooker ()

@property (strong, nonatomic) NSMutableDictionary* hookerSelectorDict;

@end

@implementation BNKLocationManagerDelegateHooker


/**
 获取BNKLocationManagerDelegateHooker单例

 @return BNKLocationManagerDelegateHooker单例
 */
+ (instancetype)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHooker = [[BNKLocationManagerDelegateHooker alloc] init];
    });
    return sharedHooker;
}

/**
 恢复交换的方法
 */
+ (void)restore
{
    [[[self class] getInstance] restore];
}


/**
 hook CLLocationManager delegate的位置回调方法
 
 @param delegate CLLocationManager的delegate
 */
+ (void)hooker:(id<CLLocationManagerDelegate>)delegate
{
    [[self class] hookerLocationManagerDelegate:delegate selector:@selector(locationManager:didUpdateLocations:) function:(IMP)locationManager_didUpdateLocations];
    
    [[self class] hookerLocationManagerDelegate:delegate selector:@selector(locationManager:didUpdateToLocation:fromLocation:) function:(IMP)locationManager_didUpdateToLocation_fromLocation];
    
    [[self class] hookerLocationManagerDelegate:delegate selector:@selector(locationManager:didFailWithError:) function:(IMP)locationManager_didFailWithError];
}


/**
 hook locationmanager delegate的selector方法

 @param delegate locationmanager的delegate
 @param selector 要替换的locationmanager delegate方法
 @param function 使用的c方法实现
 */
+ (void)hookerLocationManagerDelegate:(id<CLLocationManagerDelegate>)delegate
                             selector:(SEL)selector
                             function:(IMP)function
{
    Class theClass = [delegate class];
    NSString* selectorName = NSStringFromSelector(selector);
    NSString* newSelectorName = [NSString stringWithFormat:@"bnk_%@",selectorName];
    SEL newSel = NSSelectorFromString(newSelectorName);
    if (![delegate respondsToSelector:newSel])
    {
        Method origMethod = class_getInstanceMethod(theClass, selector);
        class_addMethod(theClass, newSel, (IMP)function, method_getTypeEncoding(origMethod));
    }
    [[[self class] getInstance] hooker:delegate selector:selector];
    
}


/**
 恢复所有交换的方法
 */
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
            [theClass bnk_swizzleMethod:NSSelectorFromString(theSel) withMethod:NSSelectorFromString([NSString stringWithFormat:@"bnk_%@",theSel]) error:&error];
            if (error)
            {
                NSLog(@"restore error %@",theSel);
            }
        }
    }
    [self.hookerSelectorDict removeAllObjects];
}


/**
 hook locationmanager delegate的某个方法

 @param delegate locationmanager delegate
 @param selector 要hook的方法
 */
- (void)hooker:(id<CLLocationManagerDelegate>)delegate
      selector:(SEL)selector
{
    if (!delegate)
        return;
    if ([self isHooker:delegate selector:selector])
        return;
    Class theClass = [delegate class];
    NSString* selectorName = NSStringFromSelector(selector);
    NSString* newSelectorName = [NSString stringWithFormat:@"bnk_%@",selectorName];
    SEL newSel = NSSelectorFromString(newSelectorName);
    NSError* error = nil;
    [theClass bnk_swizzleMethod:selector withMethod:newSel error:&error];
    if (error)
    {
        NSLog(@"hooker error %@ %@",delegate,NSStringFromSelector(selector));
    }
    [self addHooker:delegate selector:selector];
}


/**
 某个object的方法是否已经被hook

 @param object 被hook的对象
 @param sel 被hook的方法
 @return 是否被hook
 */
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


/**
 添加某个hook对象和该对象的方法

 @param object hook对象
 @param selector hook的方法
 */
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


/**
 移除某个对象的hook方法

 @param object hook对象
 @param selector 移除的方法
 */
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


/**
 hook方法字典

 @return hook方法字典
 */
- (NSMutableDictionary*)hookerSelectorDict
{
    if (!_hookerSelectorDict)
    {
        _hookerSelectorDict = [[NSMutableDictionary alloc] init];
    }
    return _hookerSelectorDict;
}

@end
