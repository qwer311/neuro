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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    DeviceLabel.text = [NSString stringWithFormat:@"Device connection:NO"];
    ServerLabel.text = [NSString stringWithFormat:@"Server connection:NO"];
    
    rawData = [[NSMutableArray alloc]init];
    emotionData = [[NSArray alloc]init];
    callCount = 0;

    //Set up for MindWave
    [[TGAccessoryManager sharedTGAccessoryManager] setDelegate:self];
    
    if([[TGAccessoryManager sharedTGAccessoryManager] accessory] != nil)
    {
        [[TGAccessoryManager sharedTGAccessoryManager] startStream];
    }
    self.emotionTextView.text = @"Like: \nInterest: \nConcentration: \nDrowsiness: \nStress: ";
    
    self.idTextField.delegate = self;
}

- (IBAction)connectButton:(id)sender {
    //Set up for socketIO
    socket = [[AZSocketIO alloc] initWithHost:@"49.212.129.143" andPort:@"3000" secure:NO];
    
    // Setting Event Listener
    [socket setEventRecievedBlock:^(NSString *eventName, id data) {
        if([eventName isEqual:@"result"])
            [self setEmotion:data];
    }];
    
    [socket connectWithSuccess:^{
        ServerLabel.text = [NSString stringWithFormat:@"Server connection:YES"];

        NSArray *key = [NSArray arrayWithObjects:@"user_id", @"user_display_id", nil];
        NSArray *value =
        [NSArray arrayWithObjects:@"4C869DAE-2978-4AE0-9862-5B1FCDB5D33B", idTextField.text, nil];
        id dic = [NSDictionary dictionaryWithObjects:value forKeys:key];
        [socket emit:@"set_user_data" args:dic error:nil];

    } andFailure:^(NSError *error) {
        ServerLabel.text = [NSString stringWithFormat:@"Server connection:Error"];
    }];
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
    
    // start the data stream to the accessory
    [[TGAccessoryManager sharedTGAccessoryManager] startStream];
}

//  This method gets called by the TGAccessoryManager when a ThinkGear-enabled
//  accessory is disconnected.
- (void)accessoryDidDisconnect {
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
    
    NSString * temp = [[NSString alloc] init];
    NSDate * date = [NSDate date];
    
    if([data valueForKey:@"blinkStrength"])
        blinkStrength = [[data valueForKey:@"blinkStrength"] intValue];
    
    if([data valueForKey:@"raw"]) {
        rawValue = [[data valueForKey:@"raw"] shortValue];
        
        if([rawData count]==SAMPLERATE)//processing 1s EEG Data
        {
            [self sendEEGData:rawData];
            [rawData removeAllObjects];
        }

        [rawData addObject:[NSString stringWithFormat:@"%d",(int)rawValue]];
    }
    
    if([data valueForKey:@"poorSignal"]) {
        DeviceLabel.text = [NSString stringWithFormat:@"Device connecttion:YES"];
        poorSignalValue = [[data valueForKey:@"poorSignal"] intValue];
        temp = [temp stringByAppendingFormat:@"%f: Poor Signal: %d\n", [date timeIntervalSince1970], poorSignalValue];
        //NSLog(@"buffered raw count: %d", buffRawCount);
        buffRawCount = 0;
        if(poorSignalValue == 200)
        {
            ElectrodeLabel.text = [NSString stringWithFormat:@"Electrodes attachment:YES"];
        }
        else
        {
            ElectrodeLabel.text = [NSString stringWithFormat:@"Electrodes attachment:NO"];
        }
    }
}

- (void)sendEEGData:(NSMutableArray*)_rawData{
    NSString *joinedString = [_rawData componentsJoinedByString:@"\n"];
    NSArray *key = [NSArray arrayWithObjects:@"user_id", @"data_id", @"data", @"timestamp", nil];
    NSArray *value =
    [NSArray arrayWithObjects:@"4C869DAE-2978-4AE0-9862-5B1FCDB5D33B", [NSString stringWithFormat:@"%d",callCount], joinedString, @"1401716309158", nil];
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
    self.emotionTextView.text = [NSString stringWithFormat:@"Like: %d\nInterest: %d\nConcentration: %d\nDrowsiness: %d\nStress: %d",
                          [[emotionData objectAtIndex:3] intValue],//Like
                          [[emotionData objectAtIndex:4] intValue],//Interest
                          [[emotionData objectAtIndex:5] intValue],//Concentration
                          [[emotionData objectAtIndex:6] intValue],//Drowsiness
                          [[emotionData objectAtIndex:7] intValue] //Stress
                          ];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

@end

