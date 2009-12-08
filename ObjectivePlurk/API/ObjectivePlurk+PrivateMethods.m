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

NSString *OPAlertFriendshipRequestType = @"friendship_request";
NSString *OPAlertFriendshipPendingType = @"friendship_pending";
NSString *OPAlertNewFanType = @"new_fan";
NSString *OPAlertFriendshipAcceptedType = @"friendship_accepted";
NSString *OPAlertNewFriendType = @"new_friend";

NSString *OPLoginAction = @"/API/Users/login";

NSString *OPRetrivePollingMessageAction = @"/API/Polling/getPlurks";

NSString *OPRetriveMessageAction = @"/API/Timeline/getPlurk";
NSString *OPRetriveMessagesAction = @"/API/Timeline/getPlurks";
NSString *OPRetriveUnreadMessagesAction = @"/API/Timeline/getUnreadPlurks";
NSString *OPMuteMessagesAction = @"/API/Timeline/mutePlurks";
NSString *OPUnmuteMessagesAction = @"/API/Timeline/unmutePlurks";
NSString *OPMarkMessageAsReadAction = @"/API/Timeline/markAsRead";
NSString *OPAddMessageAction = @"/API/Timeline/plurkAdd";
NSString *OPDeleteMessageAction = @"/API/Timeline/plurkDelete";
NSString *OPEditMessageAction = @"/API/Timeline/plurkEdit";

NSString *OPRetriveResponsesAction = @"/API/Responses/get";
NSString *OPAddResponsesAction = @"/API/Responses/responseAdd";
NSString *OPDeleteResponsesAction = @"/API/Timeline/responseDelete";

NSString *OPRetrieveMyProfileAction = @"/API/Profile/getOwnProfile";
NSString *OPRetrievePublicProfileAction = @"/API/Profile/getPublicProfile";

NSString *OPRetriveFriendAction = @"/API/FriendsFans/getFriendsByOffset";
NSString *OPRetriveFansAction = @"/API/FriendsFans/getFansByOffset";
NSString *OPRetriveFollowingAction = @"/API/FriendsFans/getFollowingByOffset";
NSString *OPBecomeFriendAction = @"/API/FriendsFans/becomeFriend";
NSString *OPRemoveFriendshipAction = @"/API/FriendsFans/becomeFriend";
NSString *OPBecomeFanAction = @"/API/FriendsFans/becomeFan";
NSString *OPSetFollowingAction = @"/API/FriendsFans/setFollowing";
NSString *OPRetrieveFriendsCompletionListAction = @"/API/FriendsFans/getCompletion";

NSString *OPRetriveActiveAlertsAction = @"/API/Alerts/getActive";
NSString *OPRetriveHistoryAction = @"/API/Alerts/getHistory";
NSString *OPAddAsFanAction = @"/API/Alerts/addAsFan";
NSString *OPAddAllAsFanAction = @"/API/Alerts/addAllAsFan";
NSString *OPAddAsFriendAction = @"/API/Alerts/addAsFriend";
NSString *OPAddAllAsFriendAction = @"/API/Alerts/addAllAsFriends";
NSString *OPDenyFriendshipAction = @"/API/Alerts/denyFriendship";
NSString *OPRemoveNotificationAction = @"/API/Alerts/removeNotification";

NSString *OPSearchMessagesAction = @"/API/PlurkSearch/search";
NSString *OPSearchUsersAction = @"/API/UserSearch/search";


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

- (void)addRequestWithAction:(NSString *)actionName arguments:(NSDictionary *)arguments delegate:(id)delegate
{
	NSString *URLString = [ObjectivePlurkAPIURLString stringByAppendingString:actionName];
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
	else if ([actionName isEqualToString:OPRetriveFriendAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRetrieveFriends:)]) {
			[delegate plurk:self didRetrieveFriends:result];
		}
	}	
	else if ([actionName isEqualToString:OPRetriveFansAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRetrieveFans:)]) {
			[delegate plurk:self didRetrieveFans:result];
		}
	}	
	else if ([actionName isEqualToString:OPRetriveFollowingAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRetrieveFollowingUsers:)]) {
			[delegate plurk:self didRetrieveFollowingUsers:result];
		}
	}	
	else if ([actionName isEqualToString:OPBecomeFriendAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didBecomeFriend:)]) {
			[delegate plurk:self didBecomeFriend:result];
		}
	}	
	else if ([actionName isEqualToString:OPRemoveFriendshipAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRemoveFriendship:)]) {
			[delegate plurk:self didRemoveFriendship:result];
		}
	}	
	else if ([actionName isEqualToString:OPBecomeFanAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didBecomeFan:)]) {
			[delegate plurk:self didBecomeFan:result];
		}
	}	
	else if ([actionName isEqualToString:OPSetFollowingAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didSetFollowingUser:)]) {
			[delegate plurk:self didSetFollowingUser:result];
		}
	}	
	else if ([actionName isEqualToString:OPRetrieveFriendsCompletionListAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRetrieveFriendsCompletionList:)]) {
			[delegate plurk:self didRetrieveFriendsCompletionList:result];
		}
	}
	else if ([actionName isEqualToString:OPRetriveActiveAlertsAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRetriveActiveAlerts:)]) {
			[delegate plurk:self didRetriveActiveAlerts:result];
		}
	}	
	else if ([actionName isEqualToString:OPRetriveHistoryAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRetriveHistory:)]) {
			[delegate plurk:self didRetriveHistory:result];
		}
	}	
	else if ([actionName isEqualToString:OPAddAsFanAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didAddAsFan:)]) {
			[delegate plurk:self didAddAsFan:result];
		}
	}	
	else if ([actionName isEqualToString:OPAddAllAsFanAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didAddAllAsFan:)]) {
			[delegate plurk:self didAddAllAsFan:result];
		}
	}
	else if ([actionName isEqualToString:OPAddAsFriendAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didAddAsFriend:)]) {
			[delegate plurk:self didAddAsFriend:result];
		}
	}	
	else if ([actionName isEqualToString:OPAddAllAsFriendAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didAddAllAsFriend:)]) {
			[delegate plurk:self didAddAllAsFriend:result];
		}
	}	
	else if ([actionName isEqualToString:OPDenyFriendshipAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didDenyFriendship:)]) {
			[delegate plurk:self didDenyFriendship:result];
		}
	}	
	else if ([actionName isEqualToString:OPRemoveNotificationAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didRemoveNotification:)]) {
			[delegate plurk:self didRemoveNotification:result];
		}
	}
	else if ([actionName isEqualToString:OPSearchMessagesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didSearchMessages:)]) {
			[delegate plurk:self didSearchMessages:result];
		}
	}
	else if ([actionName isEqualToString:OPSearchUsersAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didSearchUsers:)]) {
			[delegate plurk:self didSearchUsers:result];
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
	
	else if ([actionName isEqualToString:OPRetriveFriendAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRetrievingFriends:)]) {
			[delegate plurk:self didFailRetrievingFriends:error];
		}
	}	
	else if ([actionName isEqualToString:OPRetriveFansAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRetrievingFans:)]) {
			[delegate plurk:self didFailRetrievingFans:error];
		}
	}	
	else if ([actionName isEqualToString:OPRetriveFollowingAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRetrievingFollowingUsers:)]) {
			[delegate plurk:self didFailRetrievingFollowingUsers:error];
		}
	}	
	else if ([actionName isEqualToString:OPBecomeFriendAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailBecomingFriend:)]) {
			[delegate plurk:self didFailBecomingFriend:error];
		}
	}	
	else if ([actionName isEqualToString:OPRemoveFriendshipAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRemovingFriendship:)]) {
			[delegate plurk:self didFailRemovingFriendship:error];
		}
	}	
	else if ([actionName isEqualToString:OPBecomeFanAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailBecomingFan:)]) {
			[delegate plurk:self didFailBecomingFan:error];
		}
	}	
	else if ([actionName isEqualToString:OPSetFollowingAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailSettingFollowingUser:)]) {
			[delegate plurk:self didFailSettingFollowingUser:error];
		}
	}	
	else if ([actionName isEqualToString:OPRetrieveFriendsCompletionListAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRetrievingFriendsCompletionList:)]) {
			[delegate plurk:self didFailRetrievingFriendsCompletionList:error];
		}
	}
	else if ([actionName isEqualToString:OPRetriveActiveAlertsAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRetrivingActiveAlerts:)]) {
			[delegate plurk:self didFailRetrivingActiveAlerts:error];
		}
	}	
	else if ([actionName isEqualToString:OPRetriveHistoryAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRetrivingHistory:)]) {
			[delegate plurk:self didFailRetrivingHistory:error];
		}
	}	
	else if ([actionName isEqualToString:OPAddAsFanAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailAddingAsFan:)]) {
			[delegate plurk:self didFailAddingAsFan:error];
		}
	}	
	else if ([actionName isEqualToString:OPAddAllAsFanAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailAddingAllAsFan:)]) {
			[delegate plurk:self didFailAddingAllAsFan:error];
		}
	}
	else if ([actionName isEqualToString:OPAddAsFriendAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailAddingAsFriend:)]) {
			[delegate plurk:self didFailAddingAsFriend:error];
		}
	}	
	else if ([actionName isEqualToString:OPAddAllAsFriendAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailAddingAllAsFriend:)]) {
			[delegate plurk:self didFailAddingAllAsFriend:error];
		}
	}	
	else if ([actionName isEqualToString:OPDenyFriendshipAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailDenyingFriendship:)]) {
			[delegate plurk:self didFailDenyingFriendship:error];
		}
	}	
	else if ([actionName isEqualToString:OPRemoveNotificationAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailRemovingNotification:)]) {
			[delegate plurk:self didFailRemovingNotification:error];
		}
	}
	else if ([actionName isEqualToString:OPSearchMessagesAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailSearchingMessages:)]) {
			[delegate plurk:self didFailSearchingMessages:error];
		}
	}
	else if ([actionName isEqualToString:OPSearchUsersAction]) {
		if ([delegate respondsToSelector:@selector(plurk:didFailSearchingUsers:)]) {
			[delegate plurk:self didFailSearchingUsers:error];
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

