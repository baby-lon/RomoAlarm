//
//  ViewController.m
//  HelloRomo
//

#import "ViewController.h"

@implementation ViewController

#pragma mark - View Management
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MainTimer = nil;
    Frame = 0;
    State = ROMOSTATE_NULL;
    Loop = 0;
    
    // To receive messages when Robots connect & disconnect, set RMCore's delegate to self
    [RMCore setDelegate:self];
    
    // Grab a shared instance of the Romo character
    self.Romo = [RMCharacter Romo];
    [RMCore setDelegate:self];
    
    [self addGestureRecognizers];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    // Add Romo's face to self.view whenever the view will appear
    [self.Romo addToSuperview:self.view];

    // LABEL
    CGRect labelRect = CGRectMake(0.0, 450.0, CGRectGetWidth(self.view.frame), 90.0);
    self.debugLabel = [[UILabel alloc] initWithFrame:labelRect];
    self.debugLabel.backgroundColor = [UIColor clearColor];
    self.debugLabel.textAlignment = NSTextAlignmentCenter;
    self.debugLabel.textColor = [UIColor whiteColor];
    self.debugLabel.font = [UIFont systemFontOfSize:30];
    [self.view addSubview:self.debugLabel];
    self.debugLabel.text = @"起動したよ";
}

#pragma mark - RMCoreDelegate Methods
- (void)robotDidConnect:(RMCoreRobot *)robot
{
    // Currently the only kind of robot is Romo3, so this is just future-proofing
    if ([robot isKindOfClass:[RMCoreRobotRomo3 class]]) {
        self.Romo3 = (RMCoreRobotRomo3 *)robot;
        
        // Change Romo's LED to be solid at 80% power
        [self.Romo3.LEDs setSolidWithBrightness:0.8];
        
        // When we plug Romo in, he get's excited!
        self.Romo.expression = RMCharacterExpressionExcited;
        
        self.debugLabel.text = @"つながったよ!";
    }
}

- (void)robotDidDisconnect:(RMCoreRobot *)robot
{
    if (robot == self.Romo3) {
        self.Romo3 = nil;
        
        // When we plug Romo in, he get's excited!
        self.Romo.expression = RMCharacterExpressionSad;
    }
}

#pragma mark - Gesture recognizers

- (void)addGestureRecognizers
{
    // Let's start by adding some gesture recognizers with which to interact with Romo
/*    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedUp:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeUp];
    
    UITapGestureRecognizer *tapReceived = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedScreen:)];
    [self.view addGestureRecognizer:tapReceived];*/
}


- (void)swipedLeft:(UIGestureRecognizer *)sender
{
    // When the user swipes left, Romo will turn in a circle to his left
    [self.Romo3 driveWithRadius:-1.0 speed:1.0];
}

- (void)swipedRight:(UIGestureRecognizer *)sender
{
    // When the user swipes right, Romo will turn in a circle to his right
    [self.Romo3 driveWithRadius:1.0 speed:1.0];
}

// Swipe up to change Romo's emotion to some random emotion
- (void)swipedUp:(UIGestureRecognizer *)sender
{
    int numberOfEmotions = 7;
    
    // Choose a random emotion from 1 to numberOfEmotions
    // That's different from the current emotion
    RMCharacterEmotion randomEmotion = 1 + (arc4random() % numberOfEmotions);
    
    self.Romo.emotion = randomEmotion;
}

// Simply tap the screen to stop Romo
- (void)tappedScreen:(UIGestureRecognizer *)sender
{
    [self.Romo3 stopDriving];
}

#pragma mark -- Touch Events --

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [[touches anyObject] locationInView:self.view];
    [self lookAtTouchLocation:touchLocation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [[touches anyObject] locationInView:self.view];
    [self lookAtTouchLocation:touchLocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.Romo lookAtDefault];
    
    // Constants for the number of expression & emotion enum values
/*    int numberOfExpressions = 19;
    int numberOfEmotions = 7;
    
    // Choose a random expression from 1 to numberOfExpressions
    RMCharacterExpression randomExpression = 1 + (arc4random() % numberOfExpressions);
    
    // Choose a random expression from 1 to numberOfEmotions
    RMCharacterEmotion randomEmotion = 1 + (arc4random() % numberOfEmotions);
    
    [self.Romo setExpression:randomExpression withEmotion:randomEmotion];*/
    
    [self.Romo say:@""];
    
//    [self.Romo3.LEDs pulseWithPeriod:1.0 direction:RMCoreLEDPulseDirectionUpAndDown];
    
//    [self.Romo3 tiltByAngle:20.0f completion:^(BOOL success) {}];

    
    switch(State){
        case ROMOSTATE_NULL:
        {
            if(MainTimer != nil){
                [self.Romo3 stopDriving];
                [MainTimer invalidate];
                MainTimer = nil;
            }
            [self.Romo3.LEDs setSolidWithBrightness:0.5];
            [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(timerTriger:) userInfo:nil repeats:NO];
            self.debugLabel.text = @"タイマーセット!";
            self.Romo.emotion = RMCharacterEmotionSleeping;
            State = ROMOSTATE_SLEEP;
            break;
        }
        case ROMOSTATE_SLEEP:
        {
            self.debugLabel.text = @"停止したよ!";
            [self.Romo3.LEDs setSolidWithBrightness:0.1];
            [self.Romo3 stopDriving];
            [MainTimer invalidate];
            MainTimer = nil;
            Frame = 0;
            break;
        }
        case ROMOSTATE_WAKEUP:
        {
            State = ROMOSTATE_ESCAPE;
            [self.Romo3 stopDriving];
            [MainTimer invalidate];
            MainTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(timerFuncEscape:) userInfo:nil repeats:YES];
            self.debugLabel.text = @"";
            Frame = 0;
            Loop = 0;
            break;
        }
        case ROMOSTATE_ESCAPE:
        {
            //捕まったとき
            self.debugLabel.text = @"おはよっ！目覚めた?";
            [self.Romo3.LEDs setSolidWithBrightness:0.1];
            self.Romo.expression = RMCharacterExpressionHappy;
//            self.Romo.emotion = RMCharacterEmotionHappy;
            [self.Romo3 stopDriving];
            [MainTimer invalidate];
            MainTimer = nil;
            Frame = 0;
            [self.Romo say:@""];
            State = ROMOSTATE_NULL;
            break;
        }
        default:
            break;
    }

    
    // If Romo3 is driving, let's stop driving
/*    BOOL RomoIsDriving = (self.Romo3.leftDriveMotor.powerLevel != 0) || (self.Romo3.rightDriveMotor.powerLevel != 0);
    
    if (RomoIsDriving) {
        // Change Romo's LED to be solid at 80% power
        [self.Romo3.LEDs setSolidWithBrightness:0.8];
        
        // Tell Romo3 to stop
        [self.Romo3 stopDriving];
    } else {
        // Change Romo's LED to pulse
        [self.Romo3.LEDs pulseWithPeriod:1.0 direction:RMCoreLEDPulseDirectionUpAndDown];
        
        // Romo's top speed is around 0.75 m/s
//        float speedInMetersPerSecond = 0.5;
        
        // Drive a circle about 0.25 meter in radius
        float radiusInMeters = 0.25;
        
        // Give Romo the drive command
//        [self.Romo3 driveWithRadius:radiusInMeters speed:speedInMetersPerSecond];
        [self.Romo3 driveBackwardWithSpeed:radiusInMeters];
        
        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(timerFunc:) userInfo:nil repeats:YES];
    }*/
}

-(void)timerTriger:(NSTimer*)timer{
    [self.Romo3.LEDs setSolidWithBrightness:1.0];
    self.debugLabel.text = @"そろそろ起きてえええ!";
    State = ROMOSTATE_WAKEUP;
    self.Romo.emotion = RMCharacterEmotionIndifferent;
    MainTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(timerFunc:) userInfo:nil repeats:YES];
}

// 起こす動き
-(void)timerFunc:(NSTimer*)timer{
    if(Frame == 0){
        self.debugLabel.text = @"起きてええええええ";
    }

    if(0<=Frame && Frame <60){
        float speed = (float)Frame * 0.005;
        [self.Romo3 driveForwardWithSpeed:speed];
    }
    if(Frame == 80){
        if(Loop == 0){
            self.Romo.emotion = RMCharacterEmotionExcited;
        }
        else{
            self.Romo.emotion = RMCharacterEmotionIndifferent;
            self.Romo.expression = RMCharacterExpressionAngry;
        }
    }
    else if(81 <= Frame && Frame <= 110){
        if(Frame % 2 == 0){
            [self.Romo3 driveForwardWithSpeed:0.75];
        }
        else{
            [self.Romo3 driveBackwardWithSpeed:0.75];
        }
    }
    else if(111 <= Frame && Frame <= 150){
        if((Frame/2) % 2 == 0){
            [self.Romo3 driveForwardWithSpeed:0.75];
        }
        else{
            [self.Romo3 driveBackwardWithSpeed:0.75];
        }
    }
    else if(Frame ==151){
        [self.Romo3 driveForwardWithSpeed:0.75];
    }
    else if(Frame ==152){
        [self.Romo3 stopDriving];
    }
    else if(160 <= Frame && Frame <= 250){
        if((Frame/2) % 2 == 0){
            [self.Romo3 turnByAngle:5 withRadius:RM_DRIVE_RADIUS_TURN_IN_PLACE speed:0.75
                finishingAction:RMCoreTurnFinishingActionStopDriving completion:nil];
        }
        else{
            [self.Romo3 turnByAngle:-5 withRadius:RM_DRIVE_RADIUS_TURN_IN_PLACE speed:0.75
                finishingAction:RMCoreTurnFinishingActionStopDriving completion:nil];
        }
    }
    else if(Frame == 251){
        [self.Romo3 stopDriving];
        Frame = 79;
        Loop++;
    }
/*    else if(Frame == 254){
        [self.Romo3 driveBackwardWithSpeed:0.5];
    }
    else if(Frame == 273){
        [self.Romo3 stopDriving];[self.Romo3 stopDriving];

    }
    else if(Frame == 303){
        [self.Romo3 driveForwardWithSpeed:0.75];
    }
    
    if(110< Frame && Frame % 20 == 0){
        [self.Romo say:@""];
    }*/
    
    Frame++;
}

// 逃げる動き
-(void)timerFuncEscape:(NSTimer*)timer{
    if(Frame == 0){
        [self.Romo3 driveBackwardWithSpeed:0.75];
    }
    else if(Frame == 15){
        self.Romo.emotion = RMCharacterEmotionIndifferent;
        [self.Romo3 turnByAngle:150 withRadius:RM_DRIVE_RADIUS_TURN_IN_PLACE speed:0.5
            finishingAction:RMCoreTurnFinishingActionStopDriving completion:nil];
    }
    else if(Frame == 51){
        [self.Romo3 driveForwardWithSpeed:0.6];
    }
    else if(Frame == 75){
        [self.Romo3 stopDriving];
    }
    else if(Frame == 76){
        [self.Romo3 turnByAngle:-140 withRadius:RM_DRIVE_RADIUS_TURN_IN_PLACE speed:0.5
                finishingAction:RMCoreTurnFinishingActionStopDriving completion:nil];
    }
    else if(Frame == 105){
        self.debugLabel.text = @"俺を止めてみせろ!!";
        self.Romo.expression = RMCharacterExpressionTalking;
        [self.Romo say:@""];
    }
    else if(Frame == 106){
        [self.Romo3 driveBackwardWithSpeed:0.75];
    }
    else if(Frame == 107){
        [self.Romo3 driveForwardWithSpeed:0.75];
    }
    else if(Frame == 108){
        [self.Romo3 driveBackwardWithSpeed:0.75];
    }
    else if(Frame == 109){
        [self.Romo3 driveForwardWithSpeed:0.75];
    }
    else if(Frame == 110){
        [self.Romo3 driveBackwardWithSpeed:0.75];
    }
    else if(Frame == 111){
        [self.Romo3 driveForwardWithSpeed:0.75];
    }
    else if(Frame == 112){
        [self.Romo3 stopDriving];
    }
    else if(Frame == 120){
        self.Romo.emotion = RMCharacterEmotionExcited;
    }
    if(Frame == 179){
        [self.Romo3 turnByAngle:150 withRadius:RM_DRIVE_RADIUS_TURN_IN_PLACE speed:0.5
                finishingAction:RMCoreTurnFinishingActionStopDriving completion:nil];
    }
    else if(Frame == 210){
        [self.Romo3 driveForwardWithSpeed:0.6];
    }
    
    Frame++;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Tell Romo to reset his eyes
    [self.Romo lookAtDefault];
}

- (void)lookAtTouchLocation:(CGPoint)touchLocation
{
    // Maxiumum distance from the center of the screen = half the width
    CGFloat w_2 = self.view.frame.size.width / 2;
    
    // Maximum distance from the middle of the screen = half the height
    CGFloat h_2 = self.view.frame.size.height / 2;
    
    // Ratio of horizontal location from center
    CGFloat x = (touchLocation.x - w_2)/w_2;
    
    // Ratio of vertical location from middle
    CGFloat y = (touchLocation.y - h_2)/h_2;
    
    // Since the touches are on Romo's face, they
    CGFloat z = 0.0;
    
    // Romo expects a 3D point
    // x and y between -1 and 1, z between 0 and 1
    // z controls how far the eyes diverge
    // (z = 0 makes the eyes converge, z = 1 makes the eyes parallel)
    RMPoint3D lookPoint = RMPoint3DMake(x, y, z);
    
    // Tell Romo to look at the point
    // We don't animate because lookAtTouchLocation: runs at many Hertz
    [self.Romo lookAtPoint:lookPoint animated:NO];
    
}

@end
