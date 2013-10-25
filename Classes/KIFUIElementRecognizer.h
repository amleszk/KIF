
typedef NS_ENUM(NSInteger, KIFUIElementType) {
    KIFUIElementTypeAlert = 0,
    KIFUIElementTypeSingleTappable,
    KIFUIElementTypeDoubleTappable,
    KIFUIElementTypeLongPressable,
    KIFUIElementTypeSwipeable
};

@interface KIFUIElementRecognizer : NSObject

-(void) setProbability:(float)probability ofChosingElement:(KIFUIElementType)elementType;


@end
