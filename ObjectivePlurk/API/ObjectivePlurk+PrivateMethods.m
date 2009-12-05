//
//  ObjectivePlurk+PrivateMethods.m
//  ObjectivePlurk
//
//  Created by zonble on 12/5/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import "ObjectivePlurk+PrivateMethods.h"


@implementation ObjectivePlurk(PrivateMethods)

- (void)loginDidSuccess:(NSDictionary *)sessionInfo
{
	id delegate = [sessionInfo valueForKey:@"delegate"];
	NSDictionary *result = [sessionInfo valueForKey:@"result"];	
	if ([result valueForKey:@"user_info"]) {
		NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:result];
		[userInfo removeObjectForKey:@"plurks"];
		[userInfo removeObjectForKey:@"plurks_users"];
		self.currentUserInfo = userInfo;
	}
	
	_isLoggedIn = YES;
	
	if ([delegate respondsToSelector:@selector(plurk:didLoggedIn:)]) {
		[delegate plurk:self didLoggedIn:result];
	}
}

- (void)loginDidFail:(NSDictionary *)sessionInfo
{
	id delegate = [sessionInfo valueForKey:@"delegate"];
	NSError *error = [sessionInfo valueForKey:@"error"];
	if ([delegate respondsToSelector:@selector(plurk:didFailLoggingIn:)]) {
		[delegate plurk:self didFailLoggingIn:error];
	}	
}

- (void)commonAPIDidSuccess:(NSDictionary *)sessionInfo
{
	id delegate = [sessionInfo valueForKey:@"delegate"];
	NSDictionary *result = [sessionInfo valueForKey:@"result"];	
	NSString *actionName = [sessionInfo valueForKey:@"actionName"];	
	if ([actionName isEqualToString:addMessageAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didLoggedIn:)]) {
			[delegate plurk:self didAddMessage:result];
		}
	}
	else if ([actionName isEqualToString:retriveMessageAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRetrieveMessage:)]) {
			[delegate plurk:self didRetrieveMessage:result];
		}
	}	
	else if ([actionName isEqualToString:retriveMessagesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRetrieveMessages:)]) {
			[delegate plurk:self didRetrieveMessages:result];
		}
	}
	else if ([actionName isEqualToString:retriveUnreadMessagesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRetrieveUnreadMessages:)]) {
			[delegate plurk:self didRetrieveUnreadMessages:result];
		}
	}
	
}

- (void)commonAPIDidFail:(NSDictionary *)sessionInfo
{
	id delegate = [sessionInfo valueForKey:@"delegate"];
	NSError *error = [sessionInfo valueForKey:@"error"];
	NSString *actionName = [sessionInfo valueForKey:@"actionName"];
	if ([actionName isEqualToString:addMessageAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailAddingMessage:)]) {
			[delegate plurk:self didFailAddingMessage:error];
		}	
	}
	else if ([actionName isEqualToString:retriveMessageAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRetrievingMessage:)]) {
			[delegate plurk:self didFailRetrievingMessage:error];
		}
	}	
	else if ([actionName isEqualToString:retriveMessagesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRetrievingMessages:)]) {
			[delegate plurk:self didFailRetrievingMessages:error];
		}
	}
	else if ([actionName isEqualToString:retriveUnreadMessagesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRetrievingUnreadMessages:)]) {
			[delegate plurk:self didFailRetrievingUnreadMessages:error];
		}
	}
	
}

//- (void)setShouldWaitUntilDone:(BOOL)flag
//{
//	[_request setShouldWaitUntilDone:flag];
//}
//- (BOOL)shouldWaitUntilDone
//{
//	return [_request shouldWaitUntilDone];
//}

- (void)connection:(OPURLConnection *)connection didReceiveData:(NSData *)data
{
	NSString *s = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	[connection.receivedString appendString:s];
}

- (void)connectionDidFinishLoading:(OPURLConnection *)connection
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	NSString *s = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	NSString *s = connection.receivedString;
	NSDictionary *result = [NSDictionary dictionaryWithJSONString:s];
	NSDictionary *sessionInfo = [connection sessionInfo];
	NSMutableDictionary *sessionInfoWithResult = [NSMutableDictionary dictionaryWithDictionary:sessionInfo];
	[sessionInfoWithResult setValue:result forKey:@"result"];
	SEL action = NSSelectorFromString([sessionInfo valueForKey:@"successAction"]);
	[self performSelector:action withObject:sessionInfoWithResult];	
	
	self.currentConnection = nil;
	[self runQueue];
}

- (void)connection:(OPURLConnection *)connection didFailWithError:(NSError *)error
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	NSLog(@"error:%@", [error description]);
	
	NSDictionary *sessionInfo = [connection sessionInfo];
	NSMutableDictionary *sessionInfoWithError = [NSMutableDictionary dictionaryWithDictionary:sessionInfo];
	[sessionInfoWithError setValue:error forKey:@"error"];
	SEL action = NSSelectorFromString([sessionInfo valueForKey:@"failAction"]);
	[self performSelector:action withObject:sessionInfoWithError];
	
	self.currentConnection = nil;
	[self runQueue];
}


//- (void)httpRequestDidComplete:(LFHTTPRequest *)request
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	NSLog(@"requestHeader:%@", [[request requestHeader] description]);
//	NSString *s = [[[NSString alloc] initWithData:[request receivedData] encoding:NSUTF8StringEncoding] autorelease];
//	NSDictionary *result = [NSDictionary dictionaryWithJSONString:s];
//	NSDictionary *sessionInfo = [request sessionInfo];
//	NSMutableDictionary *sessionInfoWithResult = [NSMutableDictionary dictionaryWithDictionary:sessionInfo];
//	[sessionInfoWithResult setValue:result forKey:@"result"];
//	SEL action = NSSelectorFromString([sessionInfo valueForKey:@"successAction"]);
//	[self performSelector:action withObject:sessionInfoWithResult];
//}
//- (void)httpRequestDidCancel:(LFHTTPRequest *)request
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//- (void)httpRequest:(LFHTTPRequest *)request didFailWithError:(NSString *)error
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//	NSLog(@"error:%@", [error description]);
//
//	NSDictionary *sessionInfo = [request sessionInfo];
//	NSMutableDictionary *sessionInfoWithError = [NSMutableDictionary dictionaryWithDictionary:sessionInfo];
//	[sessionInfoWithError setValue:error forKey:@"error"];
//	SEL action = NSSelectorFromString([sessionInfo valueForKey:@"failAction"]);
//	[self performSelector:action withObject:sessionInfoWithError];	
//}

@end
