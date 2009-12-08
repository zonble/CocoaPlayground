//
//  ObjectivePlurk.m
//  ObjectivePlurk
//
//  Created by zonble on 12/5/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import "ObjectivePlurk.h"
#import "ObjectivePlurk+PrivateMethods.h"
//#import "PlurkAPI.h"

#define API_URL @"https://www.plurk.com"
#define U8(x) [NSString stringWithUTF8String:x]

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
	_request.delegate = nil;
	[_request cancelWithoutDelegateMessage];
	[_request release];
	_request = nil;
	[_queue release];
	[_currentUserInfo release];
	[_qualifiers release];
	[_langCodes release];
	[_dateFormatter release];
	[super dealloc];
}

- (id)init
{
	self = [super init];
	if (self != nil) {
		_request = [[LFHTTPRequest alloc] init];
		[_request setDelegate:self];
		_queue = [[NSMutableArray alloc] init];
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		[_dateFormatter setDateFormat:@"yyyy-M-d'T'HH:mm:ss"];
		_currentUserInfo = nil;
		_qualifiers = [[NSArray alloc] initWithObjects:@"loves", @"likes", @"shares", @"gives", @"hates", @"wants", @"has", @"will", @"asks", @"wishes", @"was", @"feels", @"thinks", @"says", @"is", @":", @"freestyle", @"hopes", @"needs", @"wonders", nil];
		_langCodes = [[NSDictionary alloc] initWithObjectsAndKeys:U8("English"), @"en", U8("Portugu"), @"pt_BR", U8("中文 (中国)"), @"cn", U8("Català"), @"ca", U8("Ελληνικά"), @"el", U8("Dansk"), @"dk", U8("Deutsch"), @"de", U8("Español"), @"es", U8("Svenska"), @"sv", U8("Norsk bokmål"), @"nb", U8("Hindi"), @"hi", U8("Română"), @"ro", U8("Hrvatski"), @"hr", U8("Français"), @"fr", U8("Pусский"), @"ru", U8("Italiano"), @"it", U8("日本語"), @"ja", U8("עברית"), @"he", U8("Magyar"), @"hu", U8("Nederlands"), @"ne", U8("ไทย"), @"th", U8("Filipino"), @"ta_fp", U8("Bahasa Indonesia"), @"in", U8("Polski"), @"pl", U8("العربية"), @"ar", U8("Finnish"), @"fi", U8("中文 (繁體中文)"), @"tr_ch", U8("Türkçe"), @"tr", U8("Gaeilge"), @"ga", U8("Slovensk"), @"sk", U8("українська"), @"uk", U8("فارسی"), @"fa", nil];
	}
	return self;
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
		}
	}
}
- (void)runQueue
{
	if ([_queue count]) {
		id sessionInfo = [_queue objectAtIndex:0];
		NSURL *URL = [sessionInfo objectForKey:@"URL"];	
		NSLog(@"_request.requestHeader:%@", [_request.requestHeader description]);
		[_request setSessionInfo:sessionInfo];
		[_request performMethod:LFHTTPRequestGETMethod onURL:URL withData:nil];		
		[_queue removeObject:sessionInfo];		
	}
}

- (BOOL)isLoggedIn
{
	NSDictionary *requestHeader = [_request requestHeader];
	if ([requestHeader objectForKey:@"Cookie"]) {
		return YES;
	}
	return NO;
}

- (void)logout
{
	_request.requestHeader = nil;
	self.currentUserInfo = nil;
}


- (NSString *)imageURLStringForUser:(id)identifier size:(OPUserProfileImageSize)size hasProfileImage:(BOOL)hasProfileImage avatar:(NSString *)avatar
{
	if (!hasProfileImage) {
		switch (size) {
			case OPSmallUserProfileImageSize:
				return @"http://www.plurk.com/static/default_small.gif";
				break;
			case OPMediumUserProfileImageSize:
				return @"http://www.plurk.com/static/default_medium.gif";
				break;
			case OPBigUserProfileImageSize:
				return @"http://www.plurk.com/static/default_big.gif";
				break;			
			default:
				return nil;
				break;
		}
	}
	if (!avatar) {
		avatar = @"";
	}
	
	switch (size) {
		case OPSmallUserProfileImageSize:
			return [NSString stringWithFormat:@"http://avatars.plurk.com/%d-small%@.gif", [identifier intValue], avatar];
			break;
		case OPMediumUserProfileImageSize:
			return [NSString stringWithFormat:@"http://avatars.plurk.com/%d-medium%@.gif", [identifier intValue], avatar];
			break;
		case OPBigUserProfileImageSize:
			return [NSString stringWithFormat:@"http://avatars.plurk.com/%d-big%@.jpg", [identifier intValue], avatar];
			break;			
		default:
			break;
	}
	return nil;
}

#pragma mark -
#pragma mark Users

- (void)loginWithUsername:(NSString *)username password:(NSString *)password delegate:(id)delegate
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", password, @"password", nil];
	[self addRequestWithAction:OPLoginAction arguments:args delegate:delegate];
}

#pragma mark Polling

- (void)retrieveMessagesWithDateOffset:(NSDate *)offsetDate delegate:(id)delegate
{
	NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if (offsetDate) {
		NSString *dateString = [_dateFormatter stringFromDate:offsetDate];
		[args setObject:dateString forKey:@"offset"];
	}
	[self addRequestWithAction:OPRetrivePollingMessageAction arguments:args delegate:delegate];
}

#pragma mark Timeline

- (void)retrieveMessageWithMessageIdentifier:(NSString *)identifer delegate:(id)delegate
{
	if ([identifer isKindOfClass:[NSNumber class]]) {
		identifer = [(NSNumber *)identifer stringValue];
	}
	
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:identifer, @"plurk_id", nil];
	[self addRequestWithAction:OPRetriveMessageAction arguments:args delegate:delegate];
}

- (void)retrieveMessagesWithDateOffset:(NSDate *)offsetDate limit:(NSInteger)limit user:(NSString *)userID isResponded:(BOOL)isResponded isPrivate:(BOOL)isPrivate delegate:(id)delegate
{
	NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if (offsetDate) {
		NSString *dateString = [_dateFormatter stringFromDate:offsetDate];
		[args setObject:dateString forKey:@"offset"];
	}
	if (limit) {
		[args setObject:[[NSNumber numberWithInt:limit] stringValue] forKey:@"limit"];
	}
	if (userID) {
		[args setObject:userID forKey:@"only_user"];
	}
	if (isResponded) {
		[args setObject:@"true" forKey:@"only_responded"];
	}
	if (isPrivate) {
		[args setObject:@"true" forKey:@"only_private"];
	}
	[self addRequestWithAction:OPRetriveMessagesAction arguments:args delegate:delegate];
	
}

- (void)retrieveUnreadMessagesWithDateOffset:(NSDate *)offsetDate limit:(NSInteger)limit delegate:(id)delegate
{
	NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if (offsetDate) {
		NSString *dateString = [_dateFormatter stringFromDate:offsetDate];
		[args setObject:dateString forKey:@"offset"];
	}
	if (limit) {
		[args setObject:[[NSNumber numberWithInt:limit] stringValue] forKey:@"limit"];
	}
	[self addRequestWithAction:OPRetriveUnreadMessagesAction arguments:args delegate:delegate];
}

- (void)muteMessagesWithMessageIdentifiers:(NSArray *)identifiers delegate:(id)delegate
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:[identifiers jsonStringValue], @"ids", nil];
	[self addRequestWithAction:OPMuteMessagesAction arguments:args delegate:delegate];
}

- (void)unmuteMessagesWithMessageIdentifiers:(NSArray *)identifiers delegate:(id)delegate
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:[identifiers jsonStringValue], @"ids", nil];
	[self addRequestWithAction:OPUnmuteMessagesAction arguments:args delegate:delegate];
}

- (void)markMessagesAsReadWithMessageIdentifiers:(NSArray *)identifiers delegate:(id)delegate
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:[identifiers jsonStringValue], @"ids", nil];
	[self addRequestWithAction:OPMarkMessageAsReadAction arguments:args delegate:delegate];
}

- (void)addNewMessageWithContent:(NSString *)content qualifier:(NSString *)qualifier othersCanComment:(OPCanComment)canComment lang:(NSString *)lang limitToUsers:(NSArray *)users delegate:(id)delegate
{
	NSString *limitString = @"";
	if ([users count]) {
		limitString = [users jsonStringValue];
	}
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:content, @"content", qualifier, @"qualifier", [[NSNumber numberWithInt:canComment] stringValue], @"no_comments", lang, @"lang", limitString, @"limited_to", nil];
	[self addRequestWithAction:OPAddMessageAction arguments:args delegate:delegate];
}

- (void)deleteMessageWithMessageIdentifier:(NSString *)identifer delegate:(id)delegate
{
	if ([identifer isKindOfClass:[NSNumber class]]) {
		identifer = [(NSNumber *)identifer stringValue];
	}
	
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:identifer, @"plurk_id", nil];
	[self addRequestWithAction:OPDeleteMessageAction arguments:args delegate:delegate];	
}
- (void)editMessageWithMessageIdentifier:(NSString *)identifer content:(NSString *)content delegate:(id)delegate
{
	if ([identifer isKindOfClass:[NSNumber class]]) {
		identifer = [(NSNumber *)identifer stringValue];
	}
	
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:identifer, @"plurk_id", content, @"content", nil];
	[self addRequestWithAction:OPEditMessageAction arguments:args delegate:delegate];		
}

#pragma mark Responses

- (void)retrieveResponsesWithMessageIdentifier:(NSString *)identifer delegate:(id)delegate
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:identifer, @"plurk_id", nil];
	[self addRequestWithAction:OPRetriveResponsesAction arguments:args delegate:delegate];
}
- (void)addNewResponseWithContent:(NSString *)content qualifier:(NSString *)qualifier toMessages:(NSString *)identifer delegate:(id)delegate
{
	if ([identifer isKindOfClass:[NSNumber class]]) {
		identifer = [(NSNumber *)identifer stringValue];
	}
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:identifer, @"plurk_id", content, @"content", qualifier, @"qualifier", nil];
	[self addRequestWithAction:OPAddResponsesAction arguments:args delegate:delegate];
}
- (void)deleteResponseWithMessageIdentifier:(NSString *)identifer delegate:(id)delegate
{
	if ([identifer isKindOfClass:[NSNumber class]]) {
		identifer = [(NSNumber *)identifer stringValue];
	}
	
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:identifer, @"plurk_id", nil];
	[self addRequestWithAction:OPDeleteResponsesAction arguments:args delegate:delegate];
}

#pragma mark Profiles

- (void)retrieveMyProfileWithDelegate:(id)delegate
{
	[self addRequestWithAction:OPRetrieveMyProfileAction arguments:nil delegate:delegate];
}

- (void)retrievePublicProfileWithUserIdentifier:(NSString *)userIdentifier delegate:(id)delegate
{
	if ([userIdentifier isKindOfClass:[NSNumber class]]) {
		userIdentifier = [(NSNumber *)userIdentifier stringValue];
	}
	
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:userIdentifier, @"user_id", nil];
	[self addRequestWithAction:OPRetrievePublicProfileAction arguments:args delegate:delegate];	
}

#pragma mark Friends and fans

- (void)retrieveFriendsOfUser:(NSString *)userIdentifier offset:(NSUInteger)offset delegate:(id)delegate
{
	NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if ([userIdentifier isKindOfClass:[NSNumber class]]) {
		userIdentifier = [(NSNumber *)userIdentifier stringValue];
	}
	[args setObject:userIdentifier forKey:@"user_id"];
	if (offset) {
		[args setObject:[NSString stringWithFormat:@"%d", offset] forKey:@"offset"];
	}
	[self addRequestWithAction:OPRetriveFriendAction arguments:args delegate:delegate];
}

- (void)retrieveFansOfUser:(NSString *)userIdentifier offset:(NSUInteger)offset delegate:(id)delegate
{
	NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if ([userIdentifier isKindOfClass:[NSNumber class]]) {
		userIdentifier = [(NSNumber *)userIdentifier stringValue];
	}
	[args setObject:userIdentifier forKey:@"user_id"];
	if (offset) {
		[args setObject:[NSString stringWithFormat:@"%d", offset] forKey:@"offset"];
	}
	[self addRequestWithAction:OPRetriveFansAction arguments:args delegate:delegate];
}

- (void)retrieveFollowingUsersOfCurrentUserWithOffset:(NSUInteger)offset delegate:(id)delegate
{
	NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if (offset) {
		[args setObject:[NSString stringWithFormat:@"%d", offset] forKey:@"offset"];
	}
	[self addRequestWithAction:OPRetriveFollowingAction arguments:args delegate:delegate];
}

- (void)becomeFriendOfUser:(NSString *)userIdentifier delegate:(id)delegate
{
	if ([userIdentifier isKindOfClass:[NSNumber class]]) {
		userIdentifier = [(NSNumber *)userIdentifier stringValue];
	}
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:userIdentifier, @"friend_id", nil];
	[self addRequestWithAction:OPBecomeFriendAction arguments:args delegate:delegate];	
}

- (void)removeFriendshipWithUser:(NSString *)userIdentifier delegate:(id)delegate
{
	if ([userIdentifier isKindOfClass:[NSNumber class]]) {
		userIdentifier = [(NSNumber *)userIdentifier stringValue];
	}
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:userIdentifier, @"friend_id", nil];
	[self addRequestWithAction:OPRemoveFriendshipAction arguments:args delegate:delegate];	
}

- (void)becomeFanOfUser:(NSString *)userIdentifier delegate:(id)delegate
{
	if ([userIdentifier isKindOfClass:[NSNumber class]]) {
		userIdentifier = [(NSNumber *)userIdentifier stringValue];
	}
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:userIdentifier, @"fan_id", nil];
	[self addRequestWithAction:OPBecomeFanAction arguments:args delegate:delegate];
}

- (void)setFollowingUser:(NSString *)userIdentifier follow:(BOOL)follow delegate:(id)delegate
{
	if ([userIdentifier isKindOfClass:[NSNumber class]]) {
		userIdentifier = [(NSNumber *)userIdentifier stringValue];
	}
	NSString *followString = follow ? @"true": @"false";
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:userIdentifier, @"user_id", followString, @"follow", nil];
	[self addRequestWithAction:OPSetFollowingAction arguments:args delegate:delegate];
	
}

- (void)retrieveFriendsCompletionList:(id)delegate
{
	[self addRequestWithAction:OPRetrieveFriendsCompletionListAction arguments:nil delegate:delegate];
}

#pragma mark Alerts

- (void)retriveActiveAlertsWithDelegate:(id)delegate
{
	[self addRequestWithAction:OPRetriveActiveAlertsAction arguments:nil delegate:delegate];
}

- (void)retrivetHistoryWithDelegate:(id)delegate
{
	[self addRequestWithAction:OPRetriveHistoryAction arguments:nil delegate:delegate];
}

- (void)addAsFanWithUserIdentifier:(NSString *)userIdentifier delegate:(id)delegate
{
	if ([userIdentifier isKindOfClass:[NSNumber class]]) {
		userIdentifier = [(NSNumber *)userIdentifier stringValue];
	}
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:userIdentifier, @"user_id", nil];
	[self addRequestWithAction:OPAddAsFanAction arguments:args delegate:delegate];	
}

- (void)addAllAsFanWithDelegate:(id)delegate
{
	[self addRequestWithAction:OPAddAllAsFanAction arguments:nil delegate:delegate];
}

- (void)addAsFriendWithUserIdentifier:(NSString *)userIdentifier delegate:(id)delegate
{
	if ([userIdentifier isKindOfClass:[NSNumber class]]) {
		userIdentifier = [(NSNumber *)userIdentifier stringValue];
	}
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:userIdentifier, @"user_id", nil];
	[self addRequestWithAction:OPAddAsFriendAction arguments:args delegate:delegate];		
}

- (void)addAllAsFriendWithDelegate:(id)delegate
{
	[self addRequestWithAction:OPAddAllAsFriendAction arguments:nil delegate:delegate];
}

- (void)denyFriendshipWithUserIdentifier:(NSString *)userIdentifier delegate:(id)delegate
{
	if ([userIdentifier isKindOfClass:[NSNumber class]]) {
		userIdentifier = [(NSNumber *)userIdentifier stringValue];
	}
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:userIdentifier, @"user_id", nil];
	[self addRequestWithAction:OPDenyFriendshipAction arguments:args delegate:delegate];	
}

- (void)removeNotificationWithDelegate:(id)delegate
{
	[self addRequestWithAction:OPRemoveNotificationAction arguments:nil delegate:delegate];
}

#pragma mark Search

- (void)searchMessagesWithQuery:(NSString *)query offset:(NSUInteger)offset delegate:(id)delegate
{
	NSMutableDictionary *args = [NSMutableDictionary dictionary];
	[args setObject:query forKey:@"query"];
	if (offset) {
		[args setObject:[NSString stringWithFormat:@"%d", offset] forKey:@"offset"];
	}	
	[self addRequestWithAction:OPSearchMessagesAction arguments:nil delegate:delegate];
}

- (void)searchUsersWithQuery:(NSString *)query offset:(NSUInteger)offset delegate:(id)delegate
{
	NSMutableDictionary *args = [NSMutableDictionary dictionary];
	[args setObject:query forKey:@"query"];
	if (offset) {
		[args setObject:[NSString stringWithFormat:@"%d", offset] forKey:@"offset"];
	}	
	[self addRequestWithAction:OPSearchUsersAction arguments:nil delegate:delegate];	
}

#pragma mark Emoticons

- (void)retriveEmoticonsWithDelegate:(id)delegate
{
	[self addRequestWithAction:OPRetrieveEmoticonsAction arguments:nil delegate:delegate];
}

#pragma mark Blocks

- (void)retrieveBlockedUsersWithDelegate:(id)delegate
{
	[self addRequestWithAction:OPRetrieveBlockedUsersAction arguments:nil delegate:delegate];
}

- (void)blockUser:(NSString *)userIdentifier delegate:(id)delegate
{
	if ([userIdentifier isKindOfClass:[NSNumber class]]) {
		userIdentifier = [(NSNumber *)userIdentifier stringValue];
	}
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:userIdentifier, @"user_id", nil];
	[self addRequestWithAction:OPBlockuUserAction arguments:args delegate:delegate];		
}

- (void)unblockUser:(NSString *)userIdentifier delegate:(id)delegate
{
	if ([userIdentifier isKindOfClass:[NSNumber class]]) {
		userIdentifier = [(NSNumber *)userIdentifier stringValue];
	}
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:userIdentifier, @"user_id", nil];
	[self addRequestWithAction:OPUnblockuUserAction arguments:args delegate:delegate];	
}

#pragma mark Cliques

- (void)retrieveCliquesWithDelegate:(id)delegate
{
	[self addRequestWithAction:OPRetrieveCliquesAction arguments:nil delegate:delegate];
}

- (void)createNewCliqueWithName:(NSString *)cliqueName delegate:(id)delegate
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:cliqueName, @"clique_name", nil];
	[self addRequestWithAction:OPCreateNewCliqueAction arguments:args delegate:delegate];
}

- (void)retrieveCliqueWithName:(NSString *)cliqueName delegate:(id)delegate
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:cliqueName, @"clique_name", nil];
	[self addRequestWithAction:OPRetrieveCliqueAction arguments:args delegate:delegate];
}

- (void)renameCliqueWithOldName:(NSString *)oldName newName:(NSString *)newName delegate:(id)delegate
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:oldName, @"clique_name", newName, @"new_name", nil];
	[self addRequestWithAction:OPRenameCliqueAction arguments:args delegate:delegate];
}

- (void)deleteCliqueWithName:(NSString *)cliqueName delegate:(id)delegate
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:cliqueName, @"clique_name", nil];
	[self addRequestWithAction:OPDeleteCliqueAction arguments:args delegate:delegate];
}

- (void)addUser:(NSString *)userIdentifier toClique:(NSString *)cliqueName delegate:(id)delegate
{
	if ([userIdentifier isKindOfClass:[NSNumber class]]) {
		userIdentifier = [(NSNumber *)userIdentifier stringValue];
	}
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:userIdentifier, @"user_id", cliqueName, @"clique_name", nil];
	[self addRequestWithAction:OPAddUserToCliqueAction arguments:args delegate:delegate];	
}

- (void)removeUser:(NSString *)userIdentifier fromClique:(NSString *)cliqueName delegate:(id)delegate
{
	if ([userIdentifier isKindOfClass:[NSNumber class]]) {
		userIdentifier = [(NSNumber *)userIdentifier stringValue];
	}
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:userIdentifier, @"user_id", cliqueName, @"clique_name", nil];
	[self addRequestWithAction:OPRemoveUserFromCliqueAction arguments:args delegate:delegate];		
	
}


@synthesize APIKey;
@synthesize qualifiers = _qualifiers;
@synthesize langCodes = _langCodes;
@synthesize currentUserInfo = _currentUserInfo;

@end
