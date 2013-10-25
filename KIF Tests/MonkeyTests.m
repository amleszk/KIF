
#import <KIF/KIF.h>

@interface MonkeyTests : KIFTestCase
@end

@implementation MonkeyTests

- (void)testReleasingTheMonkey
{
    [monkey releaseTheMonkeyForTimeInterval:60.];
}

@end
