
#import <KIF/KIF.h>
#import <KIF/KIFTestStepValidation.h>

@interface MonkeyTests : KIFTestCase
@end

@implementation MonkeyTests

- (void)testReleasingTheMonkey
{
    [monkey releaseTheMonkey];
}

@end
