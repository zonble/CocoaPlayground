//
//  ObjectivePlurk+PrivateMethods.m
//  ObjectivePlurk
//
//  Created by zonble on 12/5/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import "ObjectivePlurk+PrivateMethods.h"

NSString *ObjectivePlurkAPIURLString = @"https://www.plurk.com";
NSString *ObjectivePlurkErrorDomain = @"ObjectivePlurkErrorDomain";

NSString *OPLoginAction = @"OPLoginAction";

NSString *OPRetrivePollingMessageAction = @"OPRetrivePollingMessageAction";

NSString *OPRetriveMessageAction = @"OPRetriveMessageAction";
NSString *OPRetriveMessagesAction = @"OPRetriveMessagesAction";
NSString *OPRetriveUnreadMessagesAction = @"OPRetriveUnreadMessagesAction";
NSString *OPMuteMessagesAction = @"OPMuteMessagesAction";
NSString *OPUnmuteMessagesAction = @"OPUnmuteMessagesAction";
NSString *OPMarkMessageAsReadAction = @"OPMarkMessageAsReadAction";
NSString *OPAddMessageAction = @"OPAddMessageAction";
NSString *OPDeleteMessageAction = @"OPDeleteMessageAction";
NSString *OPEditMessageAction = @"OPEditMessageAction";

NSString *OPRetriveResponsesAction = @"OPRetriveResponsesAction";
NSString *OPAddResponsesAction = @"OPAddResponsesAction";
NSString *OPDeleteResponsesAction = @"OPDeleteResponsesAction";

NSString *OPRetrieveMyProfileAction = @"OPRetrieveMyProfileAction";
NSString *OPRetrievePublicProfileAction = @"OPRetrievePublicProfileAction";


@implementation ObjectivePlurk(PrivateMethods)

- (NSString *)GETStringFromDictionary:(NSDictionary *)inDictionary
{
	NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:inDictionary];
	[d setValue:APIKey forKey:@"api_key"];
	
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

- (void)addRequestWithURLPath:(NSString *)URLPath arguments:(NSDictionary *)arguments actionName:(NSString *)actionName delegate:(id)delegate
{
	NSString *URLString = [ObjectivePlurkAPIURLString stringByAppendingString:URLPath];
	URLString = [URLString stringByAppendingString:[self GETStringFromDictionary:arguments]];
	NSURL *URL = [NSURL URLWithString:URLString];
	NSLog(@"URL:%@", [URL description]);
	NSDictionary *sessionInfo = [NSDictionary dictionaryWithObjectsAndKeys:actionName, @"actionName", URL, @"URL", delegate, @"delegate", nil];
	
	if (![_queue count] && ![_request isRunning]) {
		NSLog(@"_request.requestHeader:%@", [_request.requestHeader description]);
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


- (void)loginDidSuccess:(LFHTTPRequest *)request
{
//	NSDictionary *result = [sessionInfo valueForKey:@"result"];	
	NSString *s = [[[NSString alloc] initWithData:[request receivedData] encoding:NSUTF8StringEncoding] autorelease];
	NSDictionary *result = [NSDictionary dictionaryWithJSONString:s];	
	NSDictionary *sessionInfo = [request sessionInfo];
	
	if ([result valueForKey:@"error_text"]) {
		NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
		[dictionary setValue:sessionInfo forKey:@"sessionInfo"];
		[dictionary setValue:[result valueForKey:@"error_text"] forKey:NSLocalizedDescriptionKey];
		NSError *error = [NSError errorWithDomain:ObjectivePlurkErrorDomain code:0 userInfo:dictionary];
		[self loginDidFail:error];		
		return;
	}	
	
	NSDictionary *header = [request receivedHeader];
	NSString *cookie = [header valueForKey:@"Set-Cookie"];
	NSDictionary *requestHeader = [NSDictionary dictionaryWithObjectsAndKeys:cookie, @"Cookie", nil];
	_request.requestHeader = requestHeader;
	
	id delegate = [sessionInfo valueForKey:@"delegate"];
	if ([result valueForKey:@"user_info"]) {
		NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:result];
		[userInfo removeObjectForKey:@"plurks"];
		[userInfo removeObjectForKey:@"plurks_users"];
		self.currentUserInfo = userInfo;
	}
	
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

	if ([actionName isEqualToString:OPRetrivePollingMessageAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRetrievePollingMessages:)]) {
			[delegate plurk:self didRetrievePollingMessages:result];
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
	else if ([actionName isEqualToString:OPRetriveResponsesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRetrieveResponses:)]) {
			[delegate plurk:self didRetrieveResponses:result];
		}
	}
	else if ([actionName isEqualToString:OPAddResponsesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didAddResponse:)]) {
			[delegate plurk:self didAddResponse:result];
		}
	}
	else if ([actionName isEqualToString:OPDeleteResponsesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didDeleteResponse:)]) {
			[delegate plurk:self didDeleteResponse:result];
		}
	}
	
	else if ([actionName isEqualToString:OPRetrieveMyProfileAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRetrieveMyProfile:)]) {
			[delegate plurk:self didRetrieveMyProfile:result];
		}
	}
	else if ([actionName isEqualToString:OPRetrievePublicProfileAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRetrievePublicProfile:)]) {
			[delegate plurk:self didRetrievePublicProfile:result];
		}
	}	
	

}

- (void)commonAPIDidFail:(NSError *)error
{
	NSDictionary *sessionInfo = [[error userInfo] valueForKey:@"sessionInfo"];
	id delegate = [sessionInfo valueForKey:@"delegate"];

	NSString *actionName = [sessionInfo valueForKey:@"actionName"];

	if ([actionName isEqualToString:OPRetrivePollingMessageAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRetrievingPollingMessages:)]) {
			[delegate plurk:self didFailRetrievingPollingMessages:error];
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
	else if ([actionName isEqualToString:OPRetriveResponsesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRetrievingResponses:)]) {
			[delegate plurk:self didFailRetrievingResponses:error];
		}
	}
	else if ([actionName isEqualToString:OPAddResponsesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailAddingResponse:)]) {
			[delegate plurk:self didFailAddingResponse:error];
		}
	}
	else if ([actionName isEqualToString:OPDeleteResponsesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailDeletingResponse:)]) {
			[delegate plurk:self didFailDeletingResponse:error];
		}
	}
	
	
	else if ([actionName isEqualToString:OPRetrieveMyProfileAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRetrievingMyProfile:)]) {
			[delegate plurk:self didFailRetrievingMyProfile:error];
		}
	}	
	else if ([actionName isEqualToString:OPRetrievePublicProfileAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRetrievingPublicProfile:)]) {
			[delegate plurk:self didFailRetrievingPublicProfile:error];
		}
	}	
	
}

- (void)httpRequestDidComplete:(LFHTTPRequest *)request
{
	NSDictionary *sessionInfo = [request sessionInfo];
	NSString *actionName = [sessionInfo valueForKey:@"actionName"];
	if ([actionName isEqualToString:OPLoginAction]) {
		[self loginDidSuccess:request];
	}
	else {
		NSString *s = [[[NSString alloc] initWithData:[request receivedData] encoding:NSUTF8StringEncoding] autorelease];
		NSDictionary *result = [NSDictionary dictionaryWithJSONString:s];
		NSMutableDictionary *sessionInfoWithResult = [NSMutableDictionary dictionaryWithDictionary:sessionInfo];
		[sessionInfoWithResult setValue:result forKey:@"result"];		
		[self commonAPIDidSuccess:sessionInfoWithResult];
	}
	[self runQueue];
}
- (void)httpRequestDidCancel:(LFHTTPRequest *)request
{
	[self runQueue];
}
- (void)httpRequest:(LFHTTPRequest *)request didFailWithError:(NSString *)error
{
	NSDictionary *sessionInfo = [request sessionInfo];
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	[dictionary setValue:sessionInfo forKey:@"sessionInfo"];	
	NSError *theError = [NSError errorWithDomain:ObjectivePlurkErrorDomain code:0 userInfo:dictionary];
	
	NSString *actionName = [sessionInfo valueForKey:@"actionName"];
	if ([actionName isEqualToString:OPLoginAction]) {
		[self loginDidFail:theError];
	}
	else {
		[self commonAPIDidFail:theError];
	}

	[self runQueue];
}

@end

