//
//  RootViewController.m
//
//  Created by yuppon on 15/3/09.
//  Copyright yuppon Inc. 2015. All rights reserved.
//

#import "RootViewController.h"
#import "Konashi.h"

@interface RootViewController ()

@end

@implementation RootViewController

@synthesize connectButton;
@synthesize finishButton;
@synthesize abortButton;

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
    
    [Konashi initialize];
    
    [Konashi addObserver:self selector:@selector(ready) name:KONASHI_EVENT_READY];
    
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
    
    rawData = [[NSMutableArray alloc]init];
    emotionData = [[NSArray alloc]init];
    callCount = 0;
    
    //Set up for MindWave
    [[TGAccessoryManager sharedTGAccessoryManager] setDelegate:self];
    if([[TGAccessoryManager sharedTGAccessoryManager] accessory] != nil)
    {
        [[TGAccessoryManager sharedTGAccessoryManager] startStream];
    }

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
        NSArray *key = [NSArray arrayWithObjects:@"user_id", nil];
        NSArray *value = [NSArray arrayWithObjects:vendorUUID.UUIDString, nil];
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

//neurosky
//  This method gets called by the TGAccessoryManager when a ThinkGear-enabled
//  accessory is disconnected.
- (void)accessoryDidDisconnect {
    DeviceLabel.text = [NSString stringWithFormat:@"機器接続NG"];
    DeviceLabel.textColor = [UIColor redColor];
    sending = NO;
}

//neurosky
//  This method gets called by the TGAccessoryManager when data is received from the
- (void)dataReceived:(NSDictionary *)data {
    DeviceLabel.text = [NSString stringWithFormat:@"機器接続OK"];
    DeviceLabel.textColor = [UIColor grayColor];

    NSString * temp = [[NSString alloc] init];
    NSDate * date = [NSDate date];
    
    if([data valueForKey:@"poorSignal"]) {
        poorSignalValue = [[data valueForKey:@"poorSignal"] intValue];
        temp = [temp stringByAppendingFormat:@"%f: Poor Signal: %d\n", [date timeIntervalSince1970], poorSignalValue];
        //NSLog(@"buffered raw count: %d", buffRawCount);
        buffRawCount = 0;
        if(poorSignalValue >= 200)
        {
            ElectrodeLabel.text = [NSString stringWithFormat:@"電極接触OK"];
            ElectrodeLabel.textColor = [UIColor grayColor];
            sending = YES;
        }
        else
        {
            ElectrodeLabel.text = [NSString stringWithFormat:@"電極接触NG"];
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

//send raw values to API server
- (void)sendEEGData:(NSMutableArray*)_rawData{
    if(!sending){
        return;
    }
    NSString *joinedString = [_rawData componentsJoinedByString:@"\n"];
    NSArray *key = [NSArray arrayWithObjects:
                    @"user_id", @"data_id", @"data", @"timestamp", nil];
    
    NSUUID *vendorUUID = [UIDevice currentDevice].identifierForVendor;
    NSArray *value = [NSArray arrayWithObjects:vendorUUID.UUIDString, [NSString stringWithFormat:@"%d",callCount], joinedString, @"1401716309158", nil];
    id dic = [NSDictionary dictionaryWithObjects:value forKeys:key];
    [socket emit:@"data" args:dic error:nil];
    callCount++;
}

//split received data
-(void)setEmotion:(id)_data{
    emotionData = [[_data description] componentsSeparatedByString:@"\n"];
    NSLog(@"LIKE:%@", [[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:0]);
    NSLog(@"INTEREST:%@", [[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:1]);
    NSLog(@"CONCENTRATION:%@", [[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:2]);
    NSLog(@"DROWSINESS:%@", [[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:3]);
    NSLog(@"STRESS:%@", [[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:4]);
    
    t1 = [[[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:0] doubleValue];
    t2 = [[[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:1] doubleValue];
    t3 = [[[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:2] doubleValue];
    t4 = [[[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:3] doubleValue];
    t5 = [[[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:4] doubleValue];
    
    EmotionLabel.text = [NSString stringWithFormat:@"like:%@,interest:%@,concentration:%@,drowsiness:%@,stress:%@",
                          [[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:0],//Like
                          [[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:1],//Interest
                          [[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:2],//Concentration
                          [[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:3],//Drowsiness
                          [[[_data valueForKey:@"result"] objectAtIndex:0] objectAtIndex:4] //Stress
                          ];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (IBAction)find:(id)sender {
    [Konashi find];
}

- (void)ready
{
    [Konashi pinMode:LED2 mode:OUTPUT];
    [Konashi digitalWrite:LED2 value:HIGH];
    [Konashi pinMode:LED3 mode:OUTPUT];
    [Konashi digitalWrite:LED3 value:LOW];
    [Konashi pinMode:LED4 mode:OUTPUT];
    [Konashi digitalWrite:LED4 value:HIGH];
    [Konashi pwmMode:LED5 mode:KONASHI_PWM_ENABLE];
    [Konashi pwmPeriod:LED5 period:10000];
    [Konashi pwmDuty:LED5 duty:5000];
    
}
@end

