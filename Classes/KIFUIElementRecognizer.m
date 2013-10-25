
#import "KIFUIElementRecognizer.h"
#import "UIAccessibilityElement-KIFAdditions.h"
#import "UIView-KIFAdditions.h"
#import "UIApplication-KIFAdditions.h"
#import "KIFUITestActor.h"

static NSUInteger DeviceSystemMajorVersion() {
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}



@interface KIFUIElementRecognizer ()
//@property NSMutableDictionary *viewClassesToElementTypes;
@property NSMutableDictionary *probabilitiesToElementTypes;
@property NSDictionary *elementTypeToSelector;
@property NSArray *viewClassesForTapping;
@property NSArray *viewClassesForSwiping;
@property NSArray *viewClassesForTextEntry;
@property NSArray *accessabilityLabelsToExclude;
@property NSArray *alertViewClasses;
@property NSArray *stepSelectorStrings;
@property NSArray *stepSelectorStringsWeighting;
@property float probabilityTotal;
@property KIFUITestActor* actor;
@end

@implementation KIFUIElementRecognizer

- (id)initWithActor:(KIFUITestActor*)actor
{
    self = [super init];
    if (self) {
    
    self.actor = actor;
    self.probabilitiesToElementTypes = [NSMutableDictionary dictionary];
    

    self.elementTypeToSelector = @{
        @(KIFUIElementTypeSingleTappable):@"searchForElementsToTap",
        @(KIFUIElementTypeDoubleTappable):@"searchForElementsToTap",
        @(KIFUIElementTypeLongPressable):@"searchForElementsToTap",
        @(KIFUIElementTypeSwipeable):@"searchForElementsToSwipe",
        @(KIFUIElementTypeTextField):@"searchForElementsToEnterText",
    };
    
    self.accessabilityLabelsToExclude = @[
        @"Mail",@"Facebook",@"Twitter", @"Weibo"
    ];
    
    if ((DeviceSystemMajorVersion() >= 7)) {
        self.alertViewClasses = @[
            NSClassFromString(@"UIAlertButton")
        ];
    }
    else {
        self.alertViewClasses = @[
            NSClassFromString(@"UIAlertButton"),
            NSClassFromString(@"UIActivityButton"),
        ];

    }
    
    self.viewClassesForTapping = @[
        [UITableViewCell class],
        [UIButton class],
        [UISwitch class],
        NSClassFromString(@"UINavigationButton"),
        NSClassFromString(@"UINavigationItemButtonView"),
    ];
    self.viewClassesForSwiping = @[
        [UIScrollView class],
    ];
    self.viewClassesForTextEntry = @[
        NSClassFromString(@"UISearchBar"),
        NSClassFromString(@"UITextField"),
    ];
    self.stepSelectorStrings = @[
        @"searchForElementsToTap",
        @"searchForElementsToSwipe",
        @"searchForElementsToEnterText",
    ];

    }
    return self;
}

-(void) updateTotalProbability
{
    _probabilityTotal = 0;
    for (NSNumber *typeNumber in _probabilitiesToElementTypes) {
        _probabilityTotal +=  [_probabilitiesToElementTypes[typeNumber] floatValue];
    }
}

-(void) setProbability:(float)probability ofChosingElement:(KIFUIElementType)elementType;
{
    _probabilitiesToElementTypes[@(elementType)] = @(probability);
    [self updateTotalProbability];
}

-(void) setDefaultProbabilities
{
    [_probabilitiesToElementTypes removeAllObjects];
    [self setProbability:10 ofChosingElement:KIFUIElementTypeSingleTappable];
    [self setProbability:1 ofChosingElement:KIFUIElementTypeDoubleTappable];
    [self setProbability:2 ofChosingElement:KIFUIElementTypeLongPressable];
    [self setProbability:5 ofChosingElement:KIFUIElementTypeSwipeable];
    [self setProbability:5 ofChosingElement:KIFUIElementTypeTextField];
    [self updateTotalProbability];
}

- (KIFStepBlock)nextStep
{
    UIAccessibilityElement *alertElement = [self findRandomAccessibilityElementInClasses:self.alertViewClasses];
    if (alertElement) {
        __block __typeof__(self) weakSelf = self;
        return [^(NSError **error){
            [weakSelf tapElement:alertElement];
            return KIFTestStepResultSuccess;
        } copy];
    }
    
    __block __typeof__(self) weakSelf = self;
    return [^(NSError **error){
        SEL randomStepSelector = NSSelectorFromString([weakSelf randomNextStepSelector]);
        id obj = [weakSelf performSelector:randomStepSelector];
        if (obj) {
            return KIFTestStepResultSuccess;
        }
        else {
            return KIFTestStepResultWait;
        }
        
    } copy];
}

- (UIAccessibilityElement*)findRandomAccessibilityElementInClasses:(NSArray*)classes
{
    NSMutableArray *allPotentialElements = [NSMutableArray array];
    for (Class viewClass in classes) {
        NSArray *elementsForViewClass =
        [[UIApplication sharedApplication] accessibilityElementsMatchingBlock:^BOOL(UIAccessibilityElement *element) {
            for (NSString *accessabilityLabelToExclude in _accessabilityLabelsToExclude) {
                if([accessabilityLabelToExclude isEqualToString:element.accessibilityLabel])
                    return NO;
            }
        
            UIView *containerView = [UIAccessibilityElement viewContainingAccessibilityElement:element];
            if (![containerView isKindOfClass:viewClass]) {
                return NO;
            }

            return [containerView isProbablyTappable];
        }];
        [allPotentialElements addObjectsFromArray:elementsForViewClass];
    }
    
    if (allPotentialElements.count) {
        return [self randomArrayElement:allPotentialElements];
    } else {
        return nil;
    }
}

#pragma mark Random Step Generators

- (NSString*)randomNextStepSelector {

    CGFloat randomPercent = (CGFloat)(arc4random() % 100)/100.;
    __block CGFloat rouletteWheelNumber = randomPercent*_probabilityTotal;
    __block NSNumber *elementTypeNumber;
    [_probabilitiesToElementTypes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        float wheelSize = [obj floatValue];
        if (wheelSize>rouletteWheelNumber) {
            elementTypeNumber = key;
            (*stop) = YES;
        }
        else {
            rouletteWheelNumber -= wheelSize;
        }
    }];
    return self.elementTypeToSelector[elementTypeNumber];
}

- (BOOL)searchForElementsToTap
{
    UIAccessibilityElement *tapElement = [self findRandomAccessibilityElementInClasses:self.viewClassesForTapping];
    if (tapElement) {
        [self tapElement:tapElement];
        return YES;
    }
    return NO;
}

- (BOOL)searchForElementsToSwipe
{
    UIAccessibilityElement *swipeElement = [self findRandomAccessibilityElementInClasses:self.viewClassesForSwiping];
    if (swipeElement) {
        [_actor swipeViewWithAccessibilityLabel:swipeElement.accessibilityLabel inDirection:[self randomSwipeDirection]];
        return YES;
    }
    return NO;
}

- (BOOL)searchForElementsToEnterText
{
    UIAccessibilityElement *element = [self findRandomAccessibilityElementInClasses:self.viewClassesForTextEntry];
    if (element) {
        [self tapElement:element];
        NSString *enterString = [NSString stringWithFormat:@"%@\n",[self generateRandomStringWithLength:10]];
        [_actor enterTextIntoCurrentFirstResponder:enterString];
        return YES;
    }
    return NO;
}

#pragma mark Tap

- (void) tapElement:(UIAccessibilityElement*)element
{
    [self highlightAccessibilityElement:element];
    UIView *containerView = [UIAccessibilityElement viewContainingAccessibilityElement:element];
    [_actor tapAccessibilityElement:element inView:containerView];
}

-(id) randomArrayElement:(NSArray*)array
{
    NSInteger randomIndex = arc4random() % array.count;
    return array[randomIndex];
}

-(id) randomArrayElement:(NSArray*)array withWeighting:(NSArray*)arrayWeights
{
    CGFloat randomPercent = (CGFloat)(arc4random() % 100)/100.;
    NSInteger index = 0;
    for (NSNumber *weightNumber in arrayWeights) {
        CGFloat weight = [weightNumber floatValue];
        if (randomPercent<weight) {
            break;
        }
        randomPercent -= weight;
        index++;
    }
    
    return array[index];
}


#pragma mark - Helpers

- (BOOL)isShowingKeyboard
{
    return NO;
}

- (void)highlightAccessibilityElement:(UIAccessibilityElement*)element
{
    UIView *containerView = [UIAccessibilityElement viewContainingAccessibilityElement:element];
    UIView *highlightView = [[UIView alloc] initWithFrame:containerView.bounds];
    highlightView.backgroundColor = [UIColor redColor];
    [containerView addSubview:highlightView];
    [UIView animateWithDuration:0.3 animations:^{
        highlightView.alpha = 0.;
    } completion:^(BOOL finished) {
        [highlightView removeFromSuperview];
    }];
}

NSString *letters = @"abcdefghijklmnopqrstuvwxyz ";
-(NSString *)generateRandomStringWithLength:(NSInteger)length
{
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    for (int i=0; i<length; i++) {
         [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

-(KIFSwipeDirection) randomSwipeDirection
{
    KIFSwipeDirection direction = arc4random() % 4;
    return direction;
}


@end
