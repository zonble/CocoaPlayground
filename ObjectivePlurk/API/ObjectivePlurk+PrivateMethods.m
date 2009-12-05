//
//  ObjectivePlurk+PrivateMethods.m
//  ObjectivePlurk
//
//  Created by zonble on 12/5/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import "ObjectivePlurk+PrivateMethods.h"

NSString *ObjectivePlurkErrorDomain = @"ObjectivePlurkErrorDomain";

NSString *OPLoginAction = @"OPLoginAction";

NSString *OPRetrieveMyProfileAction = @"OPRetrieveMyProfileAction";
NSString *OPRetrievePublicProfileAction = @"OPRetrievePublicProfileAction";

NSString *OPRetriveMessageAction = @"OPRetriveMessageAction";
NSString *OPRetriveMessagesAction = @"OPRetriveMessagesAction";
NSString *OPRetriveUnreadMessagesAction = @"OPRetriveUnreadMessagesAction";
NSString *OPMuteMessagesAction = @"OPMuteMessagesAction";
NSString *OPUnmuteMessagesAction = @"OPUnmuteMessagesAction";
NSString *OPMarkMessageAsReadAction = @"OPMarkMessageAsReadAction";
NSString *OPAddMessageAction = @"OPAddMessageAction";
NSString *OPDeleteMessageAction = @"OPDeleteMessageAction";
NSString *OPEditMessageAction = @"OPEditMessageAction";

@implementation ObjectivePlurk(PrivateMethods)

- (void)loginDidSuccess:(NSDictionary *)sessionInfo
{
	NSDictionary *result = [sessionInfo valueForKey:@"result"];	
	
	if ([result valueForKey:@"error_text"]) {
		NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
		[dictionary setValue:sessionInfo forKey:@"sessionInfo"];
		[dictionary setValue:[result valueForKey:@"error_text"] forKey:NSLocalizedDescriptionKey];
		NSError *error = [NSError errorWithDomain:ObjectivePlurkErrorDomain code:0 userInfo:dictionary];
		[self loginDidFail:error];		
		return;
	}	
	
	id delegate = [sessionInfo valueForKey:@"delegate"];
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

- (void)loginDidFail:(NSError *)error
{
	NSDictionary *sessionInfo = [[error userInfo] valueForKey:@"sessionInfo"];
	id delegate = [sessionInfo valueForKey:@"delegate"];
	if ([delegate respondsToSelector:@selector(plurk:didFailLoggingIn:)]) {
		[delegate plurk:self didFailLoggingIn:error];
	}	
}

- (void)commonAPIDidSuccess:(NSDictionary *)sessionInfo
{
	NSDictionary *result = [sessionInfo valueForKey:@"result"];	
	
	if ([result valueForKey:@"error_text"]) {
		NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
		[dictionary setValue:sessionInfo forKey:@"sessionInfo"];
		[dictionary setValue:[result valueForKey:@"error_text"] forKey:NSLocalizedDescriptionKey];
		NSError *error = [NSError errorWithDomain:ObjectivePlurkErrorDomain code:0 userInfo:dictionary];
		[self commonAPIDidFail:error];
		return;
	}
	
	id delegate = [sessionInfo valueForKey:@"delegate"];	
	NSString *actionName = [sessionInfo valueForKey:@"actionName"];	

	if ([actionName isEqualToString:OPRetrieveMyProfileAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRetrieveMyProfile:)]) {
			[delegate plurk:self didRetrieveMyProfile:result];
		}
	}
	else if ([actionName isEqualToString:OPRetrievePublicProfileAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRetrievePublicProfile:)]) {
			[delegate plurk:self didRetrievePublicProfile:result];
		}
	}	
	else if ([actionName isEqualToString:OPRetriveMessageAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRetrieveMessage:)]) {
			[delegate plurk:self didRetrieveMessage:result];
		}
	}	
	else if ([actionName isEqualToString:OPRetriveMessagesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRetrieveMessages:)]) {
			[delegate plurk:self didRetrieveMessages:result];
		}
	}
	else if ([actionName isEqualToString:OPRetriveUnreadMessagesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRetrieveUnreadMessages:)]) {
			[delegate plurk:self didRetrieveUnreadMessages:result];
		}
	}
	else if ([actionName isEqualToString:OPMuteMessagesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didMuteMessages:)]) {
			[delegate plurk:self didMuteMessages:result];
		}
	}
	else if ([actionName isEqualToString:OPUnmuteMessagesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didUnmuteMessages:)]) {
			[delegate plurk:self didUnmuteMessages:result];
		}
	}
	else if ([actionName isEqualToString:OPMarkMessageAsReadAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didMarkMessagesAsRead:)]) {
			[delegate plurk:self didMarkMessagesAsRead:result];
		}
	}
	else if ([actionName isEqualToString:OPAddMessageAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didLoggedIn:)]) {
			[delegate plurk:self didAddMessage:result];
		}
	}
	else if ([actionName isEqualToString:OPDeleteMessageAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didDeleteMessage:)]) {
			[delegate plurk:self didDeleteMessage:result];
		}
	}
	else if ([actionName isEqualToString:OPEditMessageAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didEditMessage:)]) {
			[delegate plurk:self didEditMessage:result];
		}
	}

}

- (void)commonAPIDidFail:(NSError *)error
{
	NSDictionary *sessionInfo = [[error userInfo] valueForKey:@"sessionInfo"];
	id delegate = [sessionInfo valueForKey:@"delegate"];

	NSString *actionName = [sessionInfo valueForKey:@"actionName"];

	if ([actionName isEqualToString:OPRetrieveMyProfileAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRetrievingMyProfile:)]) {
			[delegate plurk:self didFailRetrievingMyProfile:error];
		}
	}	
	else if ([actionName isEqualToString:OPRetrievePublicProfileAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRetrievingPublicProfile:)]) {
			[delegate plurk:self didFailRetrievingPublicProfile:error];
		}
	}	
	else if ([actionName isEqualToString:OPRetriveMessageAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRetrievingMessage:)]) {
			[delegate plurk:self didFailRetrievingMessage:error];
		}
	}	
	else if ([actionName isEqualToString:OPRetriveMessagesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRetrievingMessages:)]) {
			[delegate plurk:self didFailRetrievingMessages:error];
		}
	}
	else if ([actionName isEqualToString:OPRetriveUnreadMessagesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRetrievingUnreadMessages:)]) {
			[delegate plurk:self didFailRetrievingUnreadMessages:error];
		}
	}
	else if ([actionName isEqualToString:OPMuteMessagesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailMutingMessages:)]) {
			[delegate plurk:self didFailMutingMessages:error];
		}
	}
	else if ([actionName isEqualToString:OPUnmuteMessagesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailUnmutingMessages:)]) {
			[delegate plurk:self didFailUnmutingMessages:error];
		}
	}
	else if ([actionName isEqualToString:OPMarkMessageAsReadAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailMarkingMessagesAsRead:)]) {
			[delegate plurk:self didFailMarkingMessagesAsRead:error];
		}
	}
	else if ([actionName isEqualToString:OPAddMessageAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailAddingMessage:)]) {
			[delegate plurk:self didFailAddingMessage:error];
		}	
	}
	else if ([actionName isEqualToString:OPDeleteMessageAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailDeletingMessage:)]) {
			[delegate plurk:self didFailDeletingMessage:error];
		}	
	}
	else if ([actionName isEqualToString:OPEditMessageAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailEditingMessage:)]) {
			[delegate plurk:self didFailEditingMessage:error];
		}	
	}
	
	
}

#pragma mark NSURLConnection delegate methods

- (void)connection:(OPURLConnection *)connection didReceiveData:(NSData *)data
{
	NSString *s = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	[connection.receivedString appendString:s];
}

- (void)connectionDidFinishLoading:(OPURLConnection *)connection
{
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
	NSDictionary *sessionInfo = [connection sessionInfo];
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[error userInfo]];
	[dictionary setValue:sessionInfo forKey:@"sessionInfo"];
	NSError *newError = [NSError errorWithDomain:[error domain] code:[error code] userInfo:dictionary];
	SEL action = NSSelectorFromString([sessionInfo valueForKey:@"failAction"]);
	[self performSelector:action withObject:newError];
	
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

