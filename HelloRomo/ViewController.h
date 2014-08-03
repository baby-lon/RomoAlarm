//
//  ViewController.h
//  HelloRomo
//

#import <UIKit/UIKit.h>
#import <RMCore/RMCore.h>
#import <RMCharacter/RMCharacter.h>

enum RomoState{
    ROMOSTATE_NULL,
    ROMOSTATE_SLEEP,
    ROMOSTATE_WAKEUP,
    ROMOSTATE_ESCAPE
};

@interface ViewController : UIViewController <RMCoreDelegate>{
    NSTimer* MainTimer;
    int Frame;
    int Loop;
    enum RomoState State;
}
@property (nonatomic, strong) RMCoreRobotRomo3 *Romo3;
@property (nonatomic, strong) RMCharacter *Romo;

// デバッグ用テキスト表示
@property IBOutlet UILabel* debugLabel;

- (void)addGestureRecognizers;

@end
