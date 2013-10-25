
#import "KIFSystemEventStepper.h"

@interface KIFSystemEventStepper ()
@property KIFSystemTestActor* actor;
@end


@implementation KIFSystemEventStepper

- (id)init
{
    self = [super init];
    if (self) {
        self.actor = [[KIFSystemTestActor alloc] init];
    }
    return self;
}

- (KIFTestExecutionBlock)nextStep
{
    __block __typeof__(self) weakSelf = self;
    return [^(NSError **error){
            KIFSystemEventType randomType = (KIFSystemEventType)(arc4random() % 2);
            switch (randomType) {
                case KIFSystemEventTypeMemoryWarning:{
                    [weakSelf.actor simulateMemoryWarning];
                    NSLog(@"Simulating memory warning");
                    break;
                }
                case KIFSystemEventTypeRotation:{
                    [weakSelf.actor simulateDeviceRotationToOrientation:[weakSelf randomDeviceOrientation]];
                    break;
                }
            }
            return KIFTestStepResultSuccess;
    } copy];
}

-(UIDeviceOrientation) randomDeviceOrientation
{
    switch ((arc4random() % 6)) {
        case 0: return UIDeviceOrientationPortrait;
        case 1: return UIDeviceOrientationPortraitUpsideDown;
        case 2: return UIDeviceOrientationLandscapeLeft;
        case 3: return UIDeviceOrientationLandscapeRight;
        case 4: return UIDeviceOrientationFaceDown;
        case 5: return UIDeviceOrientationFaceUp;
    }
    return UIDeviceOrientationPortrait;
}

@end
