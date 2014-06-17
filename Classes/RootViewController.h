//
//  RootViewController.h
//  ThinkGearTouch
//
//  Created by Horace Ko on 12/2/09.
//  Copyright NeuroSky, Inc. 2009. All rights reserved.
//

#import "TGAccessoryManager.h"
#import "TGAccessoryDelegate.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <CFNetwork/CFNetwork.h>
#import <AZSocketIO/AZSocketIO.h>

#define SAMPLERATE 512

// the eSense values
typedef struct {
    int attention;
    int meditation;
} ESenseValues;

// the EEG power bands
typedef struct {
    int delta;
    int theta;
    int lowAlpha;
    int highAlpha;
    int lowBeta;
    int highBeta;
    int lowGamma;
    int highGamma;
} EEGValues;

@interface RootViewController : UIViewController <TGAccessoryDelegate,UITextFieldDelegate,MFMailComposeViewControllerDelegate,AZSocketIOTransportDelegate> {
    short rawValue;
    int rawCount;
    int buffRawCount;
    int blinkStrength;
    int poorSignalValue;
    int heartRate;
    float respiration;
    
    ESenseValues eSenseValues;
    EEGValues eegValues;
    
    bool logEnabled;
    NSFileHandle * logFile;
    NSString * output;
    
    UIView * loadingScreen;
    
    NSThread * updateThread;
    
    AZSocketIO *socket;
    
    NSMutableArray* rawData;
    NSArray* emotionData;
    NSInteger callCount;
    
    IBOutlet UILabel *DeviceLabel;
    IBOutlet UILabel *ElectrodeLabel;
    IBOutlet UILabel *ServerLabel;
    IBOutlet UILabel *EmotionsLabel;
    
    NSTimer *timer;
}

// TGAccessoryDelegate protocol methods
- (void)accessoryDidConnect:(EAAccessory *)accessory;
- (void)accessoryDidDisconnect;
- (void)dataReceived:(NSDictionary *)data;


- (UIImage *)updateSignalStatus;

@property (nonatomic, retain) IBOutlet UIView * loadingScreen;

@end