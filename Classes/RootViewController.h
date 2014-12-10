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
#import <CoreLocation/CoreLocation.h>
#import "GraphView.h"

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

@interface RootViewController : UIViewController <TGAccessoryDelegate,
UITextFieldDelegate,
AZSocketIOTransportDelegate,
CLLocationManagerDelegate> {
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
    IBOutlet UILabel *LocationLabel;
    
    double lat;
    double lng;
    double accuracy;
    bool sending;

    NSTimer *timer;

@public
    double t1, t2, t3, t4, t5;
    double m1, m2, m3, m4, m5;

}

@property (weak, nonatomic) IBOutlet GraphView *graphView;
@property (weak, nonatomic) IBOutlet UITextField *idTextField;
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet UITextField *signalStrengthThreshold;
@property (weak, nonatomic) IBOutlet UISegmentedControl *courseSwitch;

@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *abortButton;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;

@property (strong) CLLocationManager* locationManager;

// TGAccessoryDelegate protocol methods
- (void)accessoryDidConnect:(EAAccessory *)accessory;
- (void)accessoryDidDisconnect;
- (void)dataReceived:(NSDictionary *)data;

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;


- (UIImage *)updateSignalStatus;

@property (nonatomic, retain) IBOutlet UIView * loadingScreen;

@end