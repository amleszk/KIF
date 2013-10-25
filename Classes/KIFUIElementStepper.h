
#import "KIFUITestActor.h"

typedef NS_ENUM(NSInteger, KIFUIElementType) {
    KIFUIElementTypeSingleTappable,
    KIFUIElementTypeDoubleTappable,
    KIFUIElementTypeLongPressable,
    KIFUIElementTypeSwipeable,
    KIFUIElementTypeTextField
};

@interface KIFUIElementStepper : NSObject

- (id)init;

-(void) setProbability:(float)probability ofChosingElement:(KIFUIElementType)elementType;
-(void) setDefaultProbabilities;

- (KIFTestExecutionBlock)nextStep;

@property BOOL shouldIgnoreEmailShareButton;
@property BOOL shouldIgnoreSocialShareButtons;

@end
