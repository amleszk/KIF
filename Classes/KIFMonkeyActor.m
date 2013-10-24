
#import "KIFMonkeyActor.h"
#import "UIApplication-KIFAdditions.h"
#import "UIAccessibilityElement-KIFAdditions.h"

@interface KIFMonkeyActor ()
@property UIView *rootViewControllerView;
@property NSArray *viewClassesForTapping;
@property NSArray *viewClassesForSwiping;
@property NSArray *viewClassesForTextEntry;
@property NSArray *alertViewClasses;
@property NSArray *stepSelectorStrings;
@property NSArray *stepSelectorStringsWeighting;
@end

@implementation KIFMonkeyActor

- (void)releaseTheMonkey
{
    self.rootViewControllerView = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
    self.alertViewClasses = @[
        NSClassFromString(@"UIAlertButton"),
        NSClassFromString(@"UIActivityButton"),
    ];
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
    self.stepSelectorStringsWeighting = @[@(0.5),@(0.4),@(0.1)];

    [self stepStateMachine];
}

#pragma mark - State machine

- (void)stepStateMachine
{
    __block __typeof__(self) weakSelf = self;

    [self runBlock:^KIFTestStepResult(NSError **error) {
        
        //Dismiss alerts
        UIAccessibilityElement *alertElement = [weakSelf findRandomAccessibilityElementInClasses:self.alertViewClasses];
        if (alertElement) {
            [self tapElement:alertElement];
        } else {
            while (YES) {
                NSString *randomSelectorString = [self
                    randomArrayElement:self.stepSelectorStrings
                    withWeighting:self.stepSelectorStringsWeighting];
                
                SEL randomStepSelector = NSSelectorFromString(randomSelectorString);
                BOOL foundElement = [self performSelector:randomStepSelector];
                if (foundElement) break;
            }
        }
        
        return KIFTestStepResultSuccess;
        
    } complete:^(KIFTestStepResult result, NSError *error) {
        [weakSelf stepStateMachine];
    }];
}

#pragma mark Random Step Generators

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
        [self swipeViewWithAccessibilityLabel:swipeElement.accessibilityLabel inDirection:[self randomSwipeDirection]];
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
        [self enterTextIntoCurrentFirstResponder:enterString];
        return YES;
    }
    return NO;
}

#pragma mark Tap

- (void) tapElement:(UIAccessibilityElement*)element
{
    [self highlightAccessibilityElement:element];
    UIView *containerView = [UIAccessibilityElement viewContainingAccessibilityElement:element];
    [self tapAccessibilityElement:element inView:containerView];
}

#pragma mark - Helpers

- (UIAccessibilityElement*)findRandomAccessibilityElementInClasses:(NSArray*)classes
{
    NSMutableArray *allPotentialElements = [NSMutableArray array];
    for (Class viewClass in classes) {
        NSArray *elementsForViewClass =
        [[UIApplication sharedApplication] accessibilityElementsMatchingBlock:^BOOL(UIAccessibilityElement *element) {
            UIView *containerView = [UIAccessibilityElement viewContainingAccessibilityElement:element];
            if (![containerView isKindOfClass:[UIView class]]) {
                return NO;
            }
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

- (BOOL)isShowingKeyboard
{
    return NO;
}

- (void)highlightAccessibilityElement:(UIAccessibilityElement*)element
{
    UIView *highlightView = [[UIView alloc] initWithFrame:element.accessibilityFrame];
    highlightView.backgroundColor = [UIColor redColor];
    [self.rootViewControllerView addSubview:highlightView];
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

-(KIFSwipeDirection) randomSwipeDirection
{
    KIFSwipeDirection direction = arc4random() % 3;
    return direction;
}

@end
