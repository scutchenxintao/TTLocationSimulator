# TTLocationSimulator
一个可以方便模拟定位的工具，无需改变原工程代码，直接嵌入后，调用接口传点即可。<br>
只需以下几步，即可轻松实现定位模拟：<br>
（1）把TTLocationSimulator工程加入到自己的工程中，设置好头文件检索路径并确保other link flags添加-ObjC<br>
（2）#import "TTLocationSimulator.h"<br>
（3）调用startLocationSimulation和postLocation:方法，则app中所有的CLLocationManager实例都会收到回调方法，并且会忽略手机定位模块的GPS信息
只接收postLocation:的GPS信息<br>
    self.locationSimulator = [TTLocationSimulator getInstance];<br>
    [self.locationSimulator startLocationSimulation];<br>
    CLLocation* location = [[CLLocation alloc] initWithLatitude:22.32 longitude:114.03];<br>
    [self.locationSimulator postLocation:location];<br>
(4)如果需要关闭模拟定位，调用stopLocationSimulation，CLLocationManager实例重新接收手机定位模块的GPS信息<br>
