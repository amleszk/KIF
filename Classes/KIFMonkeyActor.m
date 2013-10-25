
#import "KIFMonkeyActor.h"
#import "UIApplication-KIFAdditions.h"
#import "KIFUIElementRecognizer.h"

@interface KIFMonkeyActor ()
@property UIView *rootViewControllerView;
@property KIFUIElementRecognizer *elementRecognizer;
@property BOOL isRunningStep;
@end

@implementation KIFMonkeyActor

- (void)releaseTheMonkeyForTimeInterval:(NSTimeInterval)timeInterval
{
    self.rootViewControllerView = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
    self.elementRecognizer = [[KIFUIElementRecognizer alloc] initWithActor:self];
    [self.elementRecognizer setDefaultProbabilities];
    
    [self monkeyRunLoopForTimeInterval:timeInterval];
}

#pragma mark - State machine

- (void)monkeyRunLoopForTimeInterval:(NSTimeInterval)timeInterval
{
    NSDate *startDate = [NSDate date];
    while (-[startDate timeIntervalSinceNow] < timeInterval) {
        if (!_isRunningStep) {
            _isRunningStep = YES;
            __block __typeof__(self) weakSelf = self;
            [self runBlock:[_elementRecognizer nextStep] complete:^(KIFTestStepResult result, NSError *error) {
                weakSelf.isRunningStep = NO;
            }];
        }
        CFRunLoopRunInMode([[UIApplication sharedApplication] currentRunLoopMode] ?: kCFRunLoopDefaultMode, 0.1, false);
    }
}


@end
