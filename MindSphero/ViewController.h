//
//  ViewController.h
//  MindSphero
//
//  Created by Maria Stoica on 1/29/14.
//  Copyright (c) 2014 Maria Stoica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RobotKit/RobotKit.h>
#import "RobotUIKit/RobotUIKit.h"
#import "TGAccessoryDelegate.h"
#import "TGAccessoryManager.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import "AppDelegate.h"

#import "SWRevealViewController.h"
#import "MindColorKeeper.h"


// the eSense values
typedef struct {
    int attention;
    int meditation;
} ESenseValues;

@interface ViewController : UIViewController <RUIColorPickerDelegate, RUICalibrateButtonGestureHandlerProtocol, TGAccessoryDelegate> {
    // Sphero properties
    BOOL robotOnline;
    BOOL allowCalibrating;
    
    // Controls calibration gestures
    RUICalibrateButtonGestureHandler *calibrateAboveHandler;
    // Controls two finger calibration gestures
    //RUICalibrateGestureHandler *calibrateTwoFingerHandler;
    // Buttons from NIB that link to a calibration gesture handler
    IBOutlet UIButton *calibrateAboveButton;
    IBOutlet UIButton *colorButton;
    IBOutlet UIButton *sleepButton;
    
    // for MindWave
    NSThread * updateThread;
    ESenseValues eSenseValues; // has attention and meditation - see struct above
    int blinkStrength;
    int signal;
    
    // for the magic
    double start;
    double turn;
    int direction;
    bool started;
    bool turned;
    bool go;
    double speed;
    UIImage *noSpheroImag;
    UIImage *okSpheroImag;
    UIImage *connectingSpheroImag;
    int pieces; // what's the size of a 1 attention on the bar
    
}

@property (nonatomic, strong) IBOutlet UIImageView *MindWaveConnectionStatusImage;
@property (nonatomic, strong) IBOutlet UIImageView *SpheroConnectionStatusImage;

@property (nonatomic, strong) IBOutlet UIButton *sidebarButton;

@property (nonatomic, strong) IBOutlet UIImageView *attentionTag;
@property (nonatomic, strong) IBOutlet UIImageView *blinkTag;
@property (nonatomic, strong) IBOutlet UIImageView *attentionBar;
@property (nonatomic, strong) IBOutlet UIImageView *blinkBar;


// Sphero methods
-(void)setupRobotConnection;
-(void)handleRobotOnline;
-(IBAction)sleepPressed:(id)sender;
-(IBAction)colorPressed:(id)sender;

// MindWave methods
- (void)dataReceived:(NSDictionary *)data;
- (void)accessoryDidConnect:(EAAccessory *)accessory;
- (void)accessoryDidDisconnect;



@end
