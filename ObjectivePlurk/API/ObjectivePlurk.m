//
//  ObjectivePlurk.m
//  ObjectivePlurk
//
//  Created by zonble on 12/5/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import "ObjectivePlurk.h"
#import "PlurkAPI.h"

#define API_URL @"https://www.plurk.com/API"

static NSString *loginAction = @"login";

static ObjectivePlurk *sharedInstance;

@implementation ObjectivePlurk

+ (ObjectivePlurk *)sharedInstance
{
	if (!sharedInstance) {
		sharedInstance = [[ObjectivePlurk alloc] init];
	}
	return sharedInstance;
}

- (void)dealloc
{
	[_request release];
	_request = nil;
	[_queue release];
	[super dealloc];
}

- (id)init
{
	self = [super init];
	if (self != nil) {
		_request = [[LFHTTPRequest alloc] init];
		[_request setDelegate:self];
		_queue = [[NSMutableArray alloc] init];
	}
	return self;
}

- (NSString *)GETStringFromDictionary:(NSDictionary *)inDictionary
{
	NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:inDictionary];
	[d setValue:API_KEY forKey:@"api_key"];
	
	NSMutableString *s = [NSMutableString string];
	for (NSString *key in [d allKeys]) {
		if ([key isEqual:[[d allKeys] objectAtIndex:0]]) {
			[s setString:@"?"];
		}
		[s appendFormat:@"%@=%@", key, [[d valueForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		if (![key isEqual:[[d allKeys] lastObject]]) {
			[s appendString:@"&"];
		}
	}
	return s;
}

- (void)cancelAllRequest
{
	[_request cancelWithoutDelegateMessage];
	[_queue removeAllObjects];
}
- (void)cancelAllRequestWithDelegate:(id)delegate
{
	if (!delegate) {
		return;
	}
	
	NSEnumerator *enumerator = [_queue objectEnumerator];
	id sessionInfo = nil;
	while (sessionInfo = [enumerator nextObject]) {
		id theDelegate = [sessionInfo objectForKey:@"delegate"];
		if (theDelegate == delegate) {
			[_queue removeObject:sessionInfo];
		}
	}
	if ([_request isRunning]) {
		id sessionInfo = [_request sessionInfo];
		id theDelegate = [sessionInfo objectForKey:@"delegate"];
		if (theDelegate == delegate) {
			[_request cancelWithoutDelegateMessage];
			[self runQueue];
		}
	}
}
- (void)runQueue
{
	if ([_queue count]) {
		id sessionInfo = [_queue objectAtIndex:0];
		NSURL *URL = [sessionInfo objectForKey:@"URL"];
		[_request setSessionInfo:sessionInfo];
		[_request performMethod:LFHTTPRequestGETMethod onURL:URL withData:nil];
		[_queue removeObject:sessionInfo];		
	}
}


- (void)addRequestWithURLPath:(NSString *)URLPath arguments:(NSDictionary *)arguments actionName:(NSString *)actionName successAction:(SEL)successAction failAction:(SEL)failAction delegate:(id)delegate
{
	NSString *URLString = [API_URL stringByAppendingString:URLPath];
	URLString = [URLString stringByAppendingString:[self GETStringFromDictionary:arguments]];
	NSURL *URL = [NSURL URLWithString:URLString];
	NSDictionary *sessionInfo = [NSDictionary dictionaryWithObjectsAndKeys:actionName, @"actionName", NSStringFromSelector(successAction), @"successAction", NSStringFromSelector(failAction), @"failAction", URL, @"URL", delegate, @"delegate", nil];
	
	if (![_queue count] && ![_request isRunning]) {
		[_request setSessionInfo:sessionInfo];
		[_request performMethod:LFHTTPRequestGETMethod onURL:URL withData:nil];
	}
	else {
		if ([_queue count]) {
			[_queue insertObject:sessionInfo atIndex:0];
		}
		else {
			[_queue addObject:sessionInfo];
		}
	}
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password delegate:(id)delegate
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", password, @"password", nil];
	[self addRequestWithURLPath:@"/Users/login" arguments:args actionName:loginAction successAction:@selector(loginDidSuccess:) failAction:@selector(loginDidFail:) delegate:delegate];
}

- (void)loginDidSuccess:(NSDictionary *)sessionInfo
{
	id delegate = [sessionInfo valueForKey:@"delegate"];
	if ([delegate respondsToSelector:@selector(plurk:didLoggedIn:)]) {
		NSDictionary *result = [sessionInfo valueForKey:@"result"];
		NSLog(@"result:%@", [result description]);
		[delegate plurk:self didLoggedIn:result];
	}
}

- (void)loginDidFail:(NSDictionary *)sessionInfo
{
	id delegate = [sessionInfo valueForKey:@"delegate"];
	if ([delegate respondsToSelector:@selector(plurk:didFailLoggingIn:)]) {
		NSError *error = [sessionInfo valueForKey:@"error"];
		NSLog(@"error:%@", [error description]);
		[delegate plurk:self didFailLoggingIn:error];
	}	
}

- (void)setShouldWaitUntilDone:(BOOL)flag
{
	[_request setShouldWaitUntilDone:flag];
}
- (BOOL)shouldWaitUntilDone
{
	return [_request shouldWaitUntilDone];
}

- (void)httpRequestDidComplete:(LFHTTPRequest *)request
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSString *s = [[[NSString alloc] initWithData:[request receivedData] encoding:NSUTF8StringEncoding] autorelease];
	NSDictionary *result = [NSDictionary dictionaryWithJSONString:s];
	NSDictionary *sessionInfo = [request sessionInfo];
	NSMutableDictionary *sessionInfoWithResult = [NSMutableDictionary dictionaryWithDictionary:sessionInfo];
	[sessionInfoWithResult setValue:result forKey:@"result"];
	SEL action = NSSelectorFromString([sessionInfo valueForKey:@"successAction"]);
	[self performSelector:action withObject:sessionInfoWithResult];
}
- (void)httpRequestDidCancel:(LFHTTPRequest *)request
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}
- (void)httpRequest:(LFHTTPRequest *)request didFailWithError:(NSString *)error
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"error:%@", [error description]);

	NSDictionary *sessionInfo = [request sessionInfo];
	NSMutableDictionary *sessionInfoWithError = [NSMutableDictionary dictionaryWithDictionary:sessionInfo];
	[sessionInfoWithError setValue:error forKey:@"error"];
	SEL action = NSSelectorFromString([sessionInfo valueForKey:@"failAction"]);
	[self performSelector:action withObject:sessionInfoWithError];	
}


@end
