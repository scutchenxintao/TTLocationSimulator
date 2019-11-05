//
//  ViewController.m
//  TTLocationSimulatorDemo
//
//  Created by Chen,Xintao on 2019/11/5.
//  Copyright © 2019 Chen,Xintao. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "TTLocationSimulator.h"

@interface ViewController ()<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager* locationManager;

@property (strong, nonatomic) TTLocationSimulator* locationSimulator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

   self.locationManager = [[CLLocationManager alloc] init];
   self.locationManager.delegate = self;
   [self.locationManager startUpdatingLocation];
    
    /*
     模拟定位只需两步：
     （1）调用startLocationSimulation
     （2）postLocation：然后所有的locationManager的delegate都会收到回调方法
     如果需要停止定位模拟，则调用stopLocationSimulation
     */
    self.locationSimulator = [TTLocationSimulator getInstance];
    [self.locationSimulator startLocationSimulation];
    CLLocation* location = [[CLLocation alloc] initWithLatitude:22.32 longitude:114.03];
    [self.locationSimulator postLocation:location];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (!locations.count)
        return;
    CLLocation* location = locations[0];
    NSLog(@"location.latitude = %f, location.longitude = %f", location.coordinate.latitude, location.coordinate.longitude);
}


@end
