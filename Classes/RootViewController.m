//
//  RootViewController.m
//  ThinkGearTouch
//
//  Copyright NeuroSky, Inc. 2012. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

@synthesize loadingScreen;
@synthesize idTextField;
@synthesize numberTextField;
@synthesize connectButton;
@synthesize finishButton;
@synthesize abortButton;
@synthesize courseSwitch;

- (void) draw:(NSTimer *) timer {
    m1 += (t1 - m1) / 5;
    m2 += (t2 - m2) / 5;
    m3 += (t3 - m3) / 5;
    m4 += (t4 - m4) / 5;
    m5 += (t5 - m5) / 5;
    
    _graphView->m1 = m1;
    _graphView->m2 = m2;
    _graphView->m3 = m3;
    _graphView->m4 = m4;
    _graphView->m5 = m5;
    [_graphView setNeedsDisplay];
}


- (void) startDrawTimer {
    [NSTimer scheduledTimerWithTimeInterval:0.03
                                     target:self
                                   selector:@selector(draw:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void) valueChange:(NSTimer *) timer {
//    t1 = 30 * (double)random() / RAND_MAX + 60;
//    t2 = 30 * (double)random() / RAND_MAX + 70;
//    t3 = 30 * (double)random() / RAND_MAX + 50;
//    t4 = 30 * (double)random() / RAND_MAX + 50;
//    t5 = 30 * (double)random() / RAND_MAX + 50;
//
//    t1 = 100;
//    t2 = 100;
//    t3 = 100;
//    t4 = 100;
//    t5 = 100;

//    t1 = 1;
//    t2 = 1;
//    t3 = 1;
//    t4 = 1;
//    t5 = 1;
//
}

- (void) startChangeValueTimer {
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(valueChange:)
                                   userInfo:nil
                                    repeats:YES];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    // 枠線つける
    connectButton.layer.borderWidth = 0.6f;
    connectButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    connectButton.layer.cornerRadius = 8.0f;
    abortButton.layer.borderWidth = 0.6f;
    abortButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    abortButton.layer.cornerRadius = 8.0f;
    finishButton.layer.borderWidth = 0.6f;
    finishButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    finishButton.layer.cornerRadius = 8.0f;
    [connectButton setTitleColor:[UIColor colorWithRed:0.0 green:67.0/256 blue:146.0/256 alpha:1.0] forState:UIControlStateNormal];
    [finishButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [abortButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    // ここから位置情報
    lng = -1.0;
    lat = -1.0;
    accuracy = 0.0;
    // ロケーションマネージャーを作成
    BOOL locationServicesEnabled;
    self.locationManager = [[CLLocationManager alloc] init];
    locationServicesEnabled = [CLLocationManager locationServicesEnabled];
    if (locationServicesEnabled) {
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [self.locationManager startUpdatingLocation];
        [self.locationManager requestWhenInUseAuthorization];
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if(status == kCLAuthorizationStatusDenied ||
           status == kCLAuthorizationStatusRestricted){
            UIAlertView *alert =
            [[UIAlertView alloc]
             initWithTitle: @"位置情報が利用できません"
             message:@"設定 > プライバシー > 位置情報サービスからこのアプリによる位置情報の利用を許可してください。"
             delegate:nil
             cancelButtonTitle:nil
             otherButtonTitles:@"OK", nil
             ];
            [alert show];
        }else if(status == kCLAuthorizationStatusNotDetermined){
            NSLog(@"Not Determined");
        }
    }else{
        UIAlertView *alert =
        [[UIAlertView alloc]
         initWithTitle: @"位置情報が利用できません"
         message:@"設定 > プライバシー > 位置情報サービスから位置情報の利用を許可してください。"
         delegate:nil
         cancelButtonTitle:nil
         otherButtonTitles:@"OK", nil
         ];
        [alert show];
    }
    
    // ここまで位置情報
    finishButton.enabled = NO;
    abortButton.enabled = NO;

    // グラフの準備
     [self startChangeValueTimer];
    [self startDrawTimer];
    
    t1 = 1;
    t2 = 1;
    t3 = 1;
    t4 = 1;
    t5 = 1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    DeviceLabel.text = [NSString stringWithFormat:@"機器接続NG"];
    DeviceLabel.textColor = [UIColor redColor];
    ServerLabel.text = [NSString stringWithFormat:@"サーバ接続NG"];
    ServerLabel.textColor = [UIColor redColor];
    ElectrodeLabel.text = [NSString stringWithFormat:@"電極接続NG"];
    ElectrodeLabel.textColor = [UIColor redColor];
    LocationLabel.text = [NSString stringWithFormat:@"位置情報NG"];
    LocationLabel.textColor = [UIColor redColor];
    
    rawData = [[NSMutableArray alloc]init];
    emotionData = [[NSArray alloc]init];
    callCount = 0;
    numberTextField.text = @"10001";
    
    //Set up for MindWave
    [[TGAccessoryManager sharedTGAccessoryManager] setDelegate:self];
    
    if([[TGAccessoryManager sharedTGAccessoryManager] accessory] != nil)
    {
        [[TGAccessoryManager sharedTGAccessoryManager] startStream];
    }
    self.idTextField.delegate = self;
    self.numberTextField.delegate = self;
    [self.locationManager startUpdatingLocation];

}

- (IBAction)finishButton:(id)sender {
    [socket emit:@"finish" args:[NSMutableDictionary dictionary] error:nil ack:^{
        [socket disconnect];
    }];
}

- (IBAction)abortButton:(id)sender {
    [socket emit:@"abort" args:[NSMutableDictionary dictionary] error:nil ack:^{
        [socket disconnect];
    }];
}


- (IBAction)connectButton:(id)sender {
    [self.locationManager startUpdatingLocation];

    //Set up for socketIO
    socket = [[AZSocketIO alloc] initWithHost:@"133.242.211.204" andPort:@"2000" secure:NO withNamespace:@"/device"];
    
    // Setting Event Listener
    [socket setEventRecievedBlock:^(NSString *eventName, id data) {
        if([eventName isEqual:@"result"])
            [self setEmotion:data];
    }];
    
    [socket connectWithSuccess:^{
        NSLog(@"success");
        ServerLabel.text = [NSString stringWithFormat:@"サーバ接続OK"];
        ServerLabel.textColor = [UIColor grayColor];

        connectButton.enabled = NO;
        finishButton.enabled = YES;
        abortButton.enabled = YES;
        [connectButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [finishButton setTitleColor:[UIColor colorWithRed:0.0 green:67.0/256 blue:146.0/256 alpha:1.0] forState:UIControlStateNormal];
        [abortButton setTitleColor:[UIColor colorWithRed:0.0 green:67.0/256 blue:146.0/256 alpha:1.0] forState:UIControlStateNormal];

        
        NSUUID *vendorUUID = [UIDevice currentDevice].identifierForVendor;
        NSString *course = courseSwitch.selectedSegmentIndex == 1 ? @"long" : @"short";
        NSArray *key = [NSArray arrayWithObjects:@"user_id", @"client_id", @"course", nil];
        NSArray *value = [NSArray arrayWithObjects:vendorUUID.UUIDString, numberTextField.text, course, nil];
        id dic = [NSDictionary dictionaryWithObjects:value forKeys:key];
        [socket emit:@"set_user_data" args:dic error:nil];

    } andFailure:^(NSError *error) {
        ServerLabel.text = [NSString stringWithFormat:@"サーバ接続NG"];
        ServerLabel.textColor = [UIColor redColor];

        [connectButton setTitleColor:[UIColor colorWithRed:0.0 green:67.0/256 blue:146.0/256 alpha:1.0] forState:UIControlStateNormal];
        [finishButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [abortButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];

        connectButton.enabled = YES;
        finishButton.enabled = NO;
        abortButton.enabled = NO;
    }];
    
    [socket setDisconnectedBlock:^{
        [connectButton setTitleColor:[UIColor colorWithRed:0.0 green:67.0/256 blue:146.0/256 alpha:1.0] forState:UIControlStateNormal];
        [finishButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [abortButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];

        connectButton.enabled = YES;
        abortButton.enabled = NO;
        finishButton.enabled = NO;
        ServerLabel.text = [NSString stringWithFormat:@"サーバ接続NG"];
        ServerLabel.textColor = [UIColor redColor];
    
    }];
    connectButton.enabled = NO;
    finishButton.enabled = YES;
    abortButton.enabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [logFile closeFile];
    [updateThread cancel];
}

//  This method gets called by the TGAccessoryManager when a ThinkGear-enabled
//  accessory is connected.
- (void)accessoryDidConnect:(EAAccessory *)accessory {
    NSLog(@"MindWave DidConnect");
    // toss up a UIAlertView when an accessory connects
    UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Accessory Connected"
                                                 message:[NSString stringWithFormat:@"A ThinkGear accessory called %@ was connected to this device.", [accessory name]]
                                                delegate:nil
                                       cancelButtonTitle:@"Okay"
                                       otherButtonTitles:nil];
    [a show];
    
    DeviceLabel.text = [NSString stringWithFormat:@"機器接続OK"];
    DeviceLabel.textColor = [UIColor grayColor];
    sending = YES;

    // start the data stream to the accessory
    [[TGAccessoryManager sharedTGAccessoryManager] startStream];
}

//  This method gets called by the TGAccessoryManager when a ThinkGear-enabled
//  accessory is disconnected.
- (void)accessoryDidDisconnect {
    DeviceLabel.text = [NSString stringWithFormat:@"機器接続NG"];
    DeviceLabel.textColor = [UIColor redColor];
    sending = NO;

    // toss up a UIAlertView when an accessory disconnects
    /*UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Accessory Disconnected"
     message:@"The ThinkGear accessory was disconnected from this device."
     delegate:nil
     cancelButtonTitle:@"Okay"
     otherButtonTitles:nil];
     [a show];
     [a release];
     */
    // set up the appropriate view

}

//  This method gets called by the TGAccessoryManager when data is received from the
//  ThinkGear-enabled device.

- (void)dataReceived:(NSDictionary *)data {
    DeviceLabel.text = [NSString stringWithFormat:@"機器接続OK"];
    DeviceLabel.textColor = [UIColor grayColor];

    NSString * temp = [[NSString alloc] init];
    NSDate * date = [NSDate date];
    

    if([data valueForKey:@"blinkStrength"]){
        blinkStrength = [[data valueForKey:@"blinkStrength"] intValue];
        NSLog(@"%@", data);
    }
   
    
    if([data valueForKey:@"poorSignal"]) {
        poorSignalValue = [[data valueForKey:@"poorSignal"] intValue];
        temp = [temp stringByAppendingFormat:@"%f: Poor Signal: %d\n", [date timeIntervalSince1970], poorSignalValue];
        //NSLog(@"buffered raw count: %d", buffRawCount);
        buffRawCount = 0;
        if(poorSignalValue == 200)
        {
            ElectrodeLabel.text = [NSString stringWithFormat:@"電極接触OK", poorSignalValue];
            ElectrodeLabel.textColor = [UIColor grayColor];
            sending = YES;
        }
        else
        {
            ElectrodeLabel.text = [NSString stringWithFormat:@"電極接触NG", poorSignalValue];
            ElectrodeLabel.textColor = [UIColor redColor];
            sending = NO;
        }
    }

    if([data valueForKey:@"raw"]) {
        rawValue = [[data valueForKey:@"raw"] shortValue];
        
        if([rawData count]==SAMPLERATE)//processing 1s EEG Data
        {
            [self sendEEGData:rawData];
            [rawData removeAllObjects];
        }
        
        [rawData addObject:[NSString stringWithFormat:@"%d",(int)rawValue]];
    }
}

- (void)sendEEGData:(NSMutableArray*)_rawData{
    if(!sending){
        return;
    }
    NSString *joinedString = [_rawData componentsJoinedByString:@"\n"];
    NSArray *key = [NSArray arrayWithObjects:
                    @"user_id", @"data_id", @"data", @"timestamp", @"course",
                    @"lat", @"lng", @"accuracy", nil];

    NSUUID *vendorUUID = [UIDevice currentDevice].identifierForVendor;
    NSString *course = courseSwitch.selectedSegmentIndex == 1 ? @"long" : @"short";

    NSArray *value = [NSArray arrayWithObjects:vendorUUID.UUIDString, [NSString stringWithFormat:@"%d",callCount], joinedString, @"1401716309158", course,
                      [[NSNumber alloc]initWithDouble:lat],
                      [[NSNumber alloc]initWithDouble:lng],
                      [[NSNumber alloc]initWithDouble:accuracy],
                    nil];
    id dic = [NSDictionary dictionaryWithObjects:value forKeys:key];
    [socket emit:@"data" args:dic error:nil];
    callCount++;
}

- (BOOL) textFieldShouldReturn:(UITextField *)theTextField
{
    NSLog(@"test");
    [theTextField resignFirstResponder];
    return YES;
}


-(void)setEmotion:(id)_data{
    emotionData = [[_data description] componentsSeparatedByString:@"\n"];
    NSLog(@"%@", [[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:0]);
    
    t1 = [[[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:0] doubleValue];
    t2 = [[[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:1] doubleValue];
    t3 = [[[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:2] doubleValue];
    t4 = [[[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:3] doubleValue];
    t5 = [[[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:4] doubleValue];
    
//    self.emotionTextView.text = [NSString stringWithFormat:@"Like: %@\nInterest: %@\nConcentration: %@\nDrowsiness: %@\nStress: %@",
//                          [[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:0],//Like
//                          [[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:1],//Interest
//                          [[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:2],//Concentration
//                          [[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:3],//Drowsiness
//                          [[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:4] //Stress
//                          ];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"位置情報受信開始");
    CLLocation* location = [locations lastObject];
    LocationLabel.text = [NSString stringWithFormat:@"位置情報OK"];
    LocationLabel.textColor = [UIColor grayColor];
    
    lng = location.coordinate.longitude;
    lat = location.coordinate.latitude;
    accuracy = location.horizontalAccuracy;

}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"位置情報受信開始");
    LocationLabel.text = [NSString stringWithFormat:@"位置情報OK"];
    LocationLabel.textColor = [UIColor grayColor];

    // 位置情報更新
    lng = newLocation.coordinate.longitude;
    lat = newLocation.coordinate.latitude;
    accuracy = newLocation.horizontalAccuracy;
}

// 位置情報が取得失敗した場合にコールされる。
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error) {

        LocationLabel.text = [NSString stringWithFormat:@"位置情報NG"];
        LocationLabel.textColor = [UIColor redColor];

        NSString* message = nil;
        switch ([error code]) {
                // アプリでの位置情報サービスが許可されていない場合
            case kCLErrorDenied:
                // 位置情報取得停止
                [self.locationManager stopUpdatingLocation];
                message = [NSString stringWithFormat:@"このアプリは位置情報サービスが許可されていません。"];
                break;
            default:
                break;
        }
        if (message) {
            // アラートを表示
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil
                                                 cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

@end

