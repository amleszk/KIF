
#import "KIFUITestActor.h"

typedef NS_ENUM(NSInteger, KIFUIElementType) {
    KIFUIElementTypeSingleTappable,
    KIFUIElementTypeDoubleTappable,
    KIFUIElementTypeLongPressable,
    KIFUIElementTypeSwipeable,
    KIFUIElementTypeTextField
};

typedef KIFTestStepResult (^KIFStepBlock) (NSError **error);

@interface KIFUIElementRecognizer : NSObject

- (id)initWithActor:(KIFUITestActor*)actor;

-(void) setProbability:(float)probability ofChosingElement:(KIFUIElementType)elementType;
-(void) setDefaultProbabilities;

- (KIFStepBlock)nextStep;

@property BOOL shouldIgnoreEmailShareButton;
@property BOOL shouldIgnoreSocialShareButtons;

@end
