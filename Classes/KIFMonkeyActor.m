
#import "KIFMonkeyActor.h"
#import "UIApplication-KIFAdditions.h"
#import "UIAccessibilityElement-KIFAdditions.h"

@interface KIFMonkeyActor ()
@property UIView *rootViewControllerView;
@property NSArray *viewClassesForTapping;
@property NSArray *alertViewClasses;
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
        NSClassFromString(@"UISearchBar"),
        NSClassFromString(@"UITextField"),
        NSClassFromString(@"UINavigationItemButtonView"),
    ];

    [self stepStateMachine];
}

#pragma mark - State machine

- (void)stepStateMachine
{
    __block __typeof__(self) weakSelf = self;

    [self runBlock:^KIFTestStepResult(NSError **error) {
        
        UIAccessibilityElement *tapElement;
        
        //Dismiss alerts
        tapElement = [weakSelf findRandomAccessibilityElementInClasses:self.alertViewClasses];

        //get any element
        if (!tapElement) {
            tapElement = [weakSelf findRandomAccessibilityElementInClasses:self.viewClassesForTapping];
        }
        
        if (!tapElement) return KIFTestStepResultWait;
        
        [weakSelf highlightAccessibilityElement:tapElement];

        UIView *containerView = [UIAccessibilityElement viewContainingAccessibilityElement:tapElement];
        [weakSelf tapAccessibilityElement:tapElement inView:containerView];
        
        return KIFTestStepResultSuccess;
    } complete:^(KIFTestStepResult result, NSError *error) {
        [weakSelf stepStateMachine];
    }];
}

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
        NSInteger randomIndex = arc4random() % allPotentialElements.count;
        return allPotentialElements[randomIndex];
    } else {
        return nil;
    }
}

- (BOOL)shouldTapFromRootViewController
{
    return [self isKeyWindowRootViewControllerWindow] && ![self isShowingUIActivityWindow];
}

- (BOOL)isKeyWindowRootViewControllerWindow
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView *rootView = keyWindow.rootViewController.view;
    return rootView.window == keyWindow;
}

- (BOOL)isShowingUIActivityWindow
{
    BOOL isShowingUIActivityWindow = [self.rootViewControllerView subviewsWithClassNamePrefix:@"UIActivity"].count > 0;
    NSLog(@"isShowingUIActivityWindow %@", isShowingUIActivityWindow ? @"YES" : @"NO");
    return isShowingUIActivityWindow;
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

@end
