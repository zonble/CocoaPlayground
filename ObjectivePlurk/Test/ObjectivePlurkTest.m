#import "ObjectivePlurkTest.h"

@implementation ObjectivePlurkTest

- (void)testLogin
{
	ObjectivePlurk *plurk = [ObjectivePlurk sharedInstance];
	[plurk loginWithUsername:ACCOUNT password:PASSWD delegate:self];
//	STFail(@"%@", [plurk description]);
}



@end
