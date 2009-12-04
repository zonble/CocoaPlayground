#import "ObjectivePlurkTest.h"

@implementation ObjectivePlurkTest

- (void)testLogin
{
	ObjectivePlurk *plurk = [ObjectivePlurk sharedInstance];
	[plurk setShouldWaitUntilDone:YES];
	[plurk loginWithUsername:ACCOUNT password:PASSWD delegate:self];
}


- (void)plurk:(ObjectivePlurk *)plurk didLoggedIn:(NSDictionary *)result
{
}
- (void)plurk:(ObjectivePlurk *)plurk didFailLoggingIn:(NSError *)error
{
}


@end
