//
//  ObjectivePlurkAppDelegate.m
//  ObjectivePlurk
//
//  Created by zonble on 12/5/09.
//  Copyright Lithoglyph Inc. 2009. All rights reserved.
//

#import "ObjectivePlurkAppDelegate.h"
#import "RootViewController.h"


@implementation ObjectivePlurkAppDelegate

- (void)dealloc
{
	[navigationController release];
	[window release];
	[super dealloc];
}


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application
{  
    
    // Override point for customization after app launch    

	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	
	ObjectivePlurk *plurk = [ObjectivePlurk sharedInstance];
	plurk.APIKey = API_KEY;
	[plurk loginWithUsername:ACCOUNT password:PASSWD delegate:self];
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)plurk:(ObjectivePlurk *)plurk didLoggedIn:(NSDictionary *)result
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
//	NSLog(@"result:%@", [result description]);
//	[plurk retrieveMyProfileWithDelegate:self];
//	[plurk retrievePublicProfileWithUserIdentifier:@"3291538" delegate:self];
//	[plurk retrieveMessagesWithDateOffset:nil limit:20 user:nil isResponded:NO isPrivate:NO delegate:self];
	NSString *file = [[NSBundle mainBundle] pathForResource:@"priyanka" ofType:@"jpeg"];
	[plurk updatePictureWithFile:file delegate:self];
}
- (void)plurk:(ObjectivePlurk *)plurk didFailLoggingIn:(NSError *)error
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"error:%@", [error description]);
}


- (void)plurk:(ObjectivePlurk *)plurk didUpdatePicture:(NSDictionary *)result
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"result:%@", [result description]);
}
- (void)plurk:(ObjectivePlurk *)plurk didFailUpdatingPicture:(NSError *)error
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"error:%@", [error description]);
}


- (void)plurk:(ObjectivePlurk *)plurk didRetrieveMessages:(NSDictionary *)result
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"result:%@", [result description]);
}
- (void)plurk:(ObjectivePlurk *)plurk didFailRetrievingMessages:(NSError *)error
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"error:%@", [error description]);
}



#pragma mark -
#pragma mark Memory management


@synthesize window;
@synthesize navigationController;

@end

