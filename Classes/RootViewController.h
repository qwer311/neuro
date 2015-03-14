//
//  RootViewController.h
//
//  Created by yuppon on 15/3/09.
//  Copyright yuppon Inc. 2015. All rights reserved.
//

#import "TGAccessoryManager.h"
#import "TGAccessoryDelegate.h"
#import <CFNetwork/CFNetwork.h>
#import <AZSocketIO/AZSocketIO.h>
#import "GraphView.h"

#define SAMPLERATE 512

@interface RootViewController : UIViewController <TGAccessoryDelegate,
UITextFieldDelegate,
AZSocketIOTransportDelegate> {
    
    //domestic variables
    short rawValue;
    int buffRawCount;
    int poorSignalValue;
    
    NSMutableArray* rawData;
    NSArray* emotionData;
    NSInteger callCount;
    NSInteger dataCount;
    
    //application variables
    AZSocketIO *socket;
    IBOutlet UILabel *DeviceLabel;
    IBOutlet UILabel *ElectrodeLabel;
    IBOutlet UILabel *ServerLabel;
    IBOutlet UILabel *EmotionLabel;
    bool sending;

    NSTimer *timer;

    //for graph
@public
    double t1, t2, t3, t4, t5;
    double m1, m2, m3, m4, m5;

}

@property (weak, nonatomic) IBOutlet GraphView *graphView;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *abortButton;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;

- (IBAction)find:(id)sender;

// TGAccessoryDelegate protocol methods
- (void)accessoryDidConnect:(EAAccessory *)accessory;
- (void)accessoryDidDisconnect;
- (void)dataReceived:(NSDictionary *)data;

@end