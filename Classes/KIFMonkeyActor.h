
#import "KIFUITestActor.h"
#import <UIKit/UIKit.h>

#define monkey KIFActorWithClass(KIFMonkeyActor)


@interface KIFMonkeyActor : KIFUITestActor

- (void)releaseTheMonkeyForTimeInterval:(NSTimeInterval)timeInterval;

@end
