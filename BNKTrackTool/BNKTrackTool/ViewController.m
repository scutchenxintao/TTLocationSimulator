//
//  ViewController.m
//  BNKTrackTool
//
//  Created by szbd on 2019/9/24.
//  Copyright © 2019 chenxintao01. All rights reserved.
//

#import "ViewController.h"
#import "GPSProducer.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<CLLocationManagerDelegate>

@property (strong, nonatomic) GPSProducer* gpsProducer;

@property (strong, nonatomic) CLLocationManager* locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.gpsProducer = [[GPSProducer alloc] init];
    [self.gpsProducer startPostGPS];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (!locations.count)
        return;
    CLLocation* location = locations[0];
    NSLog(@"location.latitude = %f, location.longitude = %f", location.coordinate.latitude, location.coordinate.longitude);
}


@end
