
#import "KIFMonkeyActor.h"
#import "UIApplication-KIFAdditions.h"
#import "KIFUIElementStepper.h"
#import "KIFSystemEventStepper.h"

@interface KIFMonkeyActor ()
@property UIView *rootViewControllerView;
@property KIFUIElementStepper *uiElementStepper;
@property KIFSystemEventStepper *systemStepper;
@property BOOL isRunningStep;
@end

@implementation KIFMonkeyActor

- (void)releaseTheMonkeyForTimeInterval:(NSTimeInterval)timeInterval
{
    self.rootViewControllerView = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
    
    self.systemStepper = [[KIFSystemEventStepper alloc] init];
    self.uiElementStepper = [[KIFUIElementStepper alloc] init];
    [self.uiElementStepper setDefaultProbabilities];
    
    [self monkeyRunLoopForTimeInterval:timeInterval];
}

#pragma mark - State machine

- (void)monkeyRunLoopForTimeInterval:(NSTimeInterval)timeInterval
{
    NSDate *startDate = [NSDate date];
    NSUInteger stepNumber = 0;
    while (-[startDate timeIntervalSinceNow] < timeInterval) {
        if (!_isRunningStep) {
            _isRunningStep = YES;
            __block __typeof__(self) weakSelf = self;
            [self runBlock:[self kifExecutionBlockForStepNumber:stepNumber] complete:^(KIFTestStepResult result, NSError *error) {
                weakSelf.isRunningStep = NO;
            }];
            stepNumber++;
        }
        CFRunLoopRunInMode([[UIApplication sharedApplication] currentRunLoopMode] ?: kCFRunLoopDefaultMode, 0.1, false);
    }
}

-(KIFTestExecutionBlock) kifExecutionBlockForStepNumber:(NSUInteger)step
{
    switch (step % 5) {
        case 0: return [_systemStepper nextStep];
        default: return [_uiElementStepper nextStep];
    }
}

@end
