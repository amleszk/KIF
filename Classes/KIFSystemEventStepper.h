
#import "KIFSystemTestActor.h"

typedef NS_ENUM(NSInteger, KIFSystemEventType) {
    KIFSystemEventTypeMemoryWarning,
    KIFSystemEventTypeRotation
};


@interface KIFSystemEventStepper : NSObject

- (id)init;
- (KIFTestExecutionBlock)nextStep;

@end
