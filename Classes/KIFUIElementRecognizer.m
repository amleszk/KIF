
#import "KIFUIElementRecognizer.h"

@interface KIFUIElementRecognizer ()
@property NSMutableDictionary *viewClassesToElementTypes;
@property NSArray *viewClassesForSwiping;
@property NSArray *viewClassesForTextEntry;
@property NSArray *alertViewClasses;
@property NSArray *stepSelectorStrings;
@property NSArray *stepSelectorStringsWeighting;
@end

@implementation KIFUIElementRecognizer

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void) setProbability:(float)probability ofChosingElement:(KIFUIElementType)elementType;
{
    
}

@end
