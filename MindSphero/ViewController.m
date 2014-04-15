//
//  ViewController.m
//  MindSphero
//
//  Created by Maria Stoica on 1/29/14.
//  Copyright (c) 2014 Maria Stoica. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*Register for application lifecycle notifications so we known when to connect and disconnect from the robot*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    robotOnline = NO;
    
    // Setup a calibration gesture handler on our view to handle button
    // gestures and give visual feeback to the user.  Defaults to above
    calibrateAboveHandler = [[RUICalibrateButtonGestureHandler alloc]
                             initWithView:self.view
                             button:calibrateAboveButton];
    
    // Make the size of the calibration widget smaller for phones
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        calibrateAboveHandler.calibrationRadius = 200;
    }
    // Larger for iPads
    else {
        calibrateAboveHandler.calibrationRadius = 500;
    }
    // Open the circle widget above the button, can switch to pop out and cardinal direction
    calibrateAboveHandler.calibrationCircleLocation = RUICalibrationCircleLocationAbove;
    // Change color of the button
    [calibrateAboveHandler setBackgroundWithColor:[UIColor colorWithRed:0.1 green:0.5 blue:1 alpha:1]];
    [calibrateAboveHandler setForegroundWithColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    
    // Setup two finger two calibration method
    //calibrateTwoFingerHandler = [[RUICalibrateGestureHandler alloc] initWithView:self.view];
    
    // linia asta... linia asta.... oh... linia asta... #!@#@#!!!
    [[TGAccessoryManager sharedTGAccessoryManager] setDelegate:self];
    // deci ei acolo in table sample se foloseau de un navigationController ca sa ia acest self :) how touching...
    
    start = 0;
    turn = 0;
    started = NO;
    turned = NO;
    direction = 0; // it starts with from = 0
    speed = 0;
    noSpheroImag = [UIImage imageNamed:@"SpheroDisconnected.png"];
    okSpheroImag = [UIImage imageNamed:@"SpheroConnected.png"];
    connectingSpheroImag = [UIImage imageNamed:@"SpheroIng.png"];
    pieces = _blinkBar.frame.size.height / 100;
    
    // pt sidebar
    // Change button color
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.96f alpha:0.2f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    //_sidebarButton.target = self.revealViewController;
    //_sidebarButton.action = @selector(revealToggle:);
    [_sidebarButton addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
    // Set the gesture for the sidebar - se suprapune cu gestul pt calibrare - I don't need this
    //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // separate thread - careful: no UI here or it will either crash or ignore it
    if(updateThread == nil) {
        updateThread = [[NSThread alloc] initWithTarget:self selector:@selector(updateLabels) object:nil];
        [updateThread start];
    }
    
    if([[TGAccessoryManager sharedTGAccessoryManager] accessory] != nil){
        [[TGAccessoryManager sharedTGAccessoryManager] startStream];
    }
    
    NSLog(@"TGAccessory version: %d", [[TGAccessoryManager sharedTGAccessoryManager] getVersion]);
    
    
}



// my stuff

-(void)appDidBecomeActive:(NSNotification*)notification {
    /*When the application becomes active after entering the background we try to connect to the robot*/
    [self setupRobotConnection];
}

-(void)appWillResignActive:(NSNotification*)notification {
    /*When the application is entering the background we need to close the connection to the robot*/
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RKDeviceConnectionOnlineNotification object:nil];
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:0.0 blue:0.0];
    [[RKRobotProvider sharedRobotProvider] closeRobotConnection];
    [_SpheroConnectionStatusImage setImage:noSpheroImag];
}


-(IBAction)sleepPressed:(id)sender {
    //RobotUIKit resources like images and nib files stored in an external bundle and the path must be specified
    NSString* rootpath = [[NSBundle mainBundle] bundlePath];
    NSString* ruirespath = [NSBundle pathForResource:@"RobotUIKit" ofType:@"bundle" inDirectory:rootpath];
    NSBundle* ruiBundle = [NSBundle bundleWithPath:ruirespath];
    
    //Present the slide to sleep view controller
    RUISlideToSleepViewController *sleep = [[RUISlideToSleepViewController alloc] initWithNibName:@"RUISlideToSleepViewController" bundle:ruiBundle];
    sleep.view.frame = self.view.bounds;
    [self presentModalLayerViewController:sleep animated:YES];
}

-(IBAction)colorPressed:(id)sender {
    //RobotUIKit resources like images and nib files stored in an external bundle and the path must be specified
    NSString* rootpath = [[NSBundle mainBundle] bundlePath];
    NSString* ruirespath = [NSBundle pathForResource:@"RobotUIKit" ofType:@"bundle" inDirectory:rootpath];
    NSBundle* ruiBundle = [NSBundle bundleWithPath:ruirespath];
    
    //Present the color picker and set the starting color to white
    RUIColorPickerViewController *colorPicker = [[RUIColorPickerViewController alloc] initWithNibName:@"RUIColorPickerViewController" bundle:ruiBundle];
    [colorPicker setCurrentRed:1.0 green:1.0 blue:1.0];
    colorPicker.delegate = self;
    [self presentModalLayerViewController:colorPicker animated:YES];
}

//Color picker delegate callbacks
-(void) colorPickerDidChange:(UIViewController*)controller withRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b {
    //Send the color to Sphero when the user picks a new color in the picker
    [RKRGBLEDOutputCommand sendCommandWithRed:r green:g blue:b];
}


-(void) colorPickerDidFinish:(UIViewController*)controller withRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b {
    //Use this callback to dismiss the color picker, since we are presenting it as a modalLayerViewController it will dismiss itself
}

-(BOOL)calibrateGestureHandlerShouldAllowCalibration:(RUICalibrateButtonGestureHandler*)sender {
    return YES;
}

- (void)handleRobotOnline {
    /*The robot is now online, we can begin sending commands*/
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:1.0 blue:0.0];
    [_SpheroConnectionStatusImage setImage:okSpheroImag];
    robotOnline = YES;
}

-(void)setupRobotConnection {
    /*Try to connect to the robot*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRobotOnline) name:RKDeviceConnectionOnlineNotification object:nil];
    
    if ([[RKRobotProvider sharedRobotProvider] isRobotUnderControl]) {
        [_SpheroConnectionStatusImage setImage:connectingSpheroImag];
        [[RKRobotProvider sharedRobotProvider] openRobotConnection];
    }
    else{
        [_SpheroConnectionStatusImage setImage:noSpheroImag];
    }
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// MindWave methods

- (void)dataReceived:(NSDictionary *)data {

    if([data valueForKey:@"eSenseAttention"]){
        eSenseValues.attention  = [[data valueForKey:@"eSenseAttention"] intValue];
        eSenseValues.meditation = [[data valueForKey:@"eSenseMeditation"] intValue];
        // move attentionTag
        // 100% - - - 189
        //   0% - - - 689
        // lungimea e 500 deci 1% = 5
        // latime tag ipad = 50
        // latime tag iphone = 30
        // latime bara ipad = 78
        // latime bara iphone = 44
        // x_blinktag = blinkBar_tag.x + (blinkbar.width - blinktag.width) / 2;
        int attentionX = _attentionBar.frame.origin.x + (_attentionBar.frame.size.width - _attentionTag.frame.size.width)/2;
        int attentionY = (_attentionBar.frame.origin.y + _attentionBar.frame.size.height - _attentionTag.frame.size.height) - pieces*eSenseValues.attention;
        [UIView animateWithDuration:1.0f animations:^{
            _attentionTag.frame = CGRectMake(attentionX, attentionY, _attentionTag.frame.size.width, _attentionTag.frame.size.height);
        }];
    }
    if([data valueForKey:@"blinkStrength"]){
        blinkStrength = [[data valueForKey:@"blinkStrength"] intValue];
        int blinkX = _blinkBar.frame.origin.x + (_blinkBar.frame.size.width - _blinkTag.frame.size.width)/2;
        int blinkY = (_blinkBar.frame.origin.y + _blinkBar.frame.size.height - _blinkTag.frame.size.height) - pieces*eSenseValues.attention;
        if(blinkY < _blinkBar.frame.origin.y)
            blinkY = _blinkBar.frame.origin.y;
        [UIView animateWithDuration:1.0f animations:^{
            _blinkTag.frame = CGRectMake(blinkX, blinkY, _blinkTag.frame.size.width, _blinkTag.frame.size.height);
        }];
    }
    if([data valueForKey:@"poorSignal"]) {
        //   0 - - - 100%
        // 200 - - -   0%
        signal = [[data valueForKey:@"poorSignal"] intValue];
    }
    
    [_MindWaveConnectionStatusImage setImage:[self updateSignalStatusImage]];
}

- (void)accessoryDidConnect:(EAAccessory *)accessory {
    [[TGAccessoryManager sharedTGAccessoryManager] startStream];
}

- (void)accessoryDidDisconnect {
}

-(void)updateLabels{
    while(1){
        
        // where the magic happens :D
        
        speed = eSenseValues.attention;
        double now = CACurrentMediaTime();
        
        // focus for > 3 seconds to move foward
        if(now - start >= 3)
            [RKRollCommand sendCommandWithHeading:direction velocity:speed];
        
        if(now - turn >= 1)
            turned = NO;
        
        // go forward if paying attention
        if(eSenseValues.attention >= 40){
            if(!started){
                start = CACurrentMediaTime();
                started = YES;
            }
        }
        else{
            speed = 0;
            [RKRollCommand sendStop];
            started = NO;
            start = CACurrentMediaTime();
        }
        if(blinkStrength >= 90){
            if(!turned){
                turn = CACurrentMediaTime();
                turned = YES;
                direction += 90;
                direction = direction % 360;
                [RKRollCommand sendCommandWithHeading:direction velocity:speed];
            }
        }
        
        // colors go from 0 ... 255
        // attention and meditation go from 0 ... 100 so
        // if we get attention 25 and meditation 50
        // the color will be
        // 100 - - - 255
        //  25 - - - x for attention
        //  50 - - - y for meditation
        // x = 25*2.55 = 63.75 for red  (so that's  ~  64)
        // y = 50*2.55 = 127.5 for blue (and that's ~ 128)
        // 190 - - - 255
        // blk - - - z
        // z = blk*1.34
        
        if([MindColorKeeper getMindColor])
        {
            double atColor    = eSenseValues.attention  * 2.55;
            double medColor   = eSenseValues.meditation * 2.55;
            double blinkColor = blinkStrength * 1.34;
            [RKRGBLEDOutputCommand sendCommandWithRed:atColor green:blinkColor blue:medColor];
        }
        
        // update photo of sphero after it sleeps
        // make sure you use this for the UIImageView otherwise it's not gonna wothout a dispatcher because it's not on the main thread
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Add code here to do background processing
            
            
            dispatch_async( dispatch_get_main_queue(), ^{
                // Add code here to update the UI/send notifications based on the
                // results of the background processing
                
                if(![[RKRobotProvider sharedRobotProvider] isRobotConnected ])
                {
                    [_SpheroConnectionStatusImage setImage:noSpheroImag];
                    // just in case a sphero is connected to bluetooth - connect to it - no need to restart the app to see sphero
                    [self setupRobotConnection];
                }
                
            });
        });
        
        [NSThread sleepForTimeInterval:0.15];
    }
}

- (UIImage *)updateSignalStatusImage {
    if(signal == 0) {
        return [UIImage imageNamed:@"Signal_Connected"];
    }
    else if(signal > 0 && signal < 50) {
        return [UIImage imageNamed:@"Signal_Connecting3"];
    }
    else if(signal > 50 && signal < 200) {
        return [UIImage imageNamed:@"Signal_Connecting2"];
    }
    else if(signal == 200) {
        return [UIImage imageNamed:@"Signal_Connecting1"];
    }
    else {
        return [UIImage imageNamed:@"Signal_Disconnected"];
    }
}

@end





