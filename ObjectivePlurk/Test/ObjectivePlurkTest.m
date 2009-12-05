#import "ObjectivePlurkTest.h"

@implementation ObjectivePlurkTest

- (void)testLogin
{
	ObjectivePlurk *plurk = [ObjectivePlurk sharedInstance];
	[plurk setShouldWaitUntilDone:YES];
	[plurk loginWithUsername:ACCOUNT password:PASSWD delegate:self];
	[plurk addMessageWithContent:@"This is a test for testing the Objective-C API" qualifier:@"says" canComment:OPEveryOneCanComment lang:@"en" limitToUsers:[NSArray array] delegate:self];
}


- (void)plurk:(ObjectivePlurk *)plurk didLoggedIn:(NSDictionary *)result
{
}
- (void)plurk:(ObjectivePlurk *)plurk didFailLoggingIn:(NSError *)error
{
}


- (void)plurk:(ObjectivePlurk *)plurk didAddMessage:(NSDictionary *)result
{
}
- (void)plurk:(ObjectivePlurk *)plurk didFailAddingMessage:(NSError *)error
{
}


@end
