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
	if ([requestHeader valueForKey:@"Cookie"]) {
		return YES;
	}
	return NO;
}

- (void)logout
{
	_request.requestHeader = nil;
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

#pragma mark Users

- (void)loginWithUsername:(NSString *)username password:(NSString *)password delegate:(id)delegate
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", password, @"password", nil];
	[self addRequestWithURLPath:@"/API/Users/login" arguments:args actionName:OPLoginAction delegate:delegate];
}

#pragma mark Polling

- (void)retrieveMessagesWithDateOffset:(NSDate *)offsetDate delegate:(id)delegate
{
	NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if (offsetDate) {
		NSString *dateString = [_dateFormatter stringFromDate:offsetDate];
		[args setValue:dateString forKey:@"offset"];
	}
	[self addRequestWithURLPath:@"/API/Polling/getPlurks" arguments:args actionName:OPRetrivePollingMessageAction delegate:delegate];
}

#pragma mark Timeline

- (void)retrieveMessageWithMessageIdentifier:(NSString *)identifer delegate:(id)delegate
{
	if ([identifer isKindOfClass:[NSNumber class]]) {
		identifer = [(NSNumber *)identifer stringValue];
	}
	
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:identifer, @"plurk_id", nil];
	[self addRequestWithURLPath:@"/API/Timeline/getPlurk" arguments:args actionName:OPRetriveMessageAction delegate:delegate];
}

- (void)retrieveMessagesWithDateOffset:(NSDate *)offsetDate limit:(NSInteger)limit user:(NSString *)userID isResponded:(BOOL)isResponded isPrivate:(BOOL)isPrivate delegate:(id)delegate
{
	NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if (offsetDate) {
		NSString *dateString = [_dateFormatter stringFromDate:offsetDate];
		[args setValue:dateString forKey:@"offset"];
	}
	if (limit) {
		[args setValue:[[NSNumber numberWithInt:limit] stringValue] forKey:@"limit"];
	}
	if (userID) {
		[args setValue:userID forKey:@"only_user"];
	}
	if (isResponded) {
		[args setValue:@"true" forKey:@"only_responded"];
	}
	if (isPrivate) {
		[args setValue:@"true" forKey:@"only_private"];
	}
	[self addRequestWithURLPath:@"/API/Timeline/getPlurks" arguments:args actionName:OPRetriveMessagesAction delegate:delegate];
	
}

- (void)retrieveUnreadMessagesWithDateOffset:(NSDate *)offsetDate limit:(NSInteger)limit delegate:(id)delegate
{
	NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if (offsetDate) {
		NSString *dateString = [_dateFormatter stringFromDate:offsetDate];
		[args setValue:dateString forKey:@"offset"];
	}
	if (limit) {
		[args setValue:[[NSNumber numberWithInt:limit] stringValue] forKey:@"limit"];
	}
	[self addRequestWithURLPath:@"/API/Timeline/getUnreadPlurks" arguments:args actionName:OPRetriveUnreadMessagesAction delegate:delegate];

}

- (void)muteMessagesWithMessageIdentifiers:(NSArray *)identifiers delegate:(id)delegate
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:[identifiers jsonStringValue], @"ids", nil];
	[self addRequestWithURLPath:@"/API/Timeline/mutePlurks" arguments:args actionName:OPMuteMessagesAction delegate:delegate];
}

- (void)unmuteMessagesWithMessageIdentifiers:(NSArray *)identifiers delegate:(id)delegate
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:[identifiers jsonStringValue], @"ids", nil];
	[self addRequestWithURLPath:@"/API/Timeline/unmutePlurks" arguments:args actionName:OPUnmuteMessagesAction delegate:delegate];
}

- (void)markMessagesAsReadWithMessageIdentifiers:(NSArray *)identifiers delegate:(id)delegate
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:[identifiers jsonStringValue], @"ids", nil];
	[self addRequestWithURLPath:@"/API/Timeline/markAsRead" arguments:args actionName:OPMarkMessageAsReadAction delegate:delegate];
}

- (void)addNewMessageWithContent:(NSString *)content qualifier:(NSString *)qualifier othersCanComment:(OPCanComment)canComment lang:(NSString *)lang limitToUsers:(NSArray *)users delegate:(id)delegate
{
	NSString *limitString = @"";
	if ([users count]) {
		limitString = [users jsonStringValue];
	}
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:content, @"content", qualifier, @"qualifier", [[NSNumber numberWithInt:canComment] stringValue], @"no_comments", lang, @"lang", limitString, @"limited_to", nil];
	[self addRequestWithURLPath:@"/API/Timeline/plurkAdd" arguments:args actionName:OPAddMessageAction delegate:delegate];
}

- (void)deleteMessageWithMessageIdentifier:(NSString *)identifer delegate:(id)delegate
{
	if ([identifer isKindOfClass:[NSNumber class]]) {
		identifer = [(NSNumber *)identifer stringValue];
	}
	
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:identifer, @"plurk_id", nil];
	[self addRequestWithURLPath:@"/API/Timeline/plurkDelete" arguments:args actionName:OPDeleteMessageAction delegate:delegate];	
}
- (void)editMessageWithMessageIdentifier:(NSString *)identifer content:(NSString *)content delegate:(id)delegate
{
	if ([identifer isKindOfClass:[NSNumber class]]) {
		identifer = [(NSNumber *)identifer stringValue];
	}
	
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:identifer, @"plurk_id", content, @"content", nil];
	[self addRequestWithURLPath:@"/API/Timeline/plurkEdit" arguments:args actionName:OPEditMessageAction delegate:delegate];		
}

#pragma mark Responses

- (void)retrieveResponsesWithMessageIdentifier:(NSString *)identifer delegate:(id)delegate
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:identifer, @"plurk_id", nil];
	[self addRequestWithURLPath:@"/API/Responses/get" arguments:args actionName:OPRetriveResponsesAction delegate:delegate];
}
- (void)addNewResponseWithContent:(NSString *)content qualifier:(NSString *)qualifier toMessages:(NSString *)identifer delegate:(id)delegate
{
	if ([identifer isKindOfClass:[NSNumber class]]) {
		identifer = [(NSNumber *)identifer stringValue];
	}
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:identifer, @"plurk_id", content, @"content", qualifier, @"qualifier", nil];
	[self addRequestWithURLPath:@"/API/Responses/responseAdd" arguments:args actionName:OPAddResponsesAction delegate:delegate];
}
- (void)deleteResponseWithMessageIdentifier:(NSString *)identifer delegate:(id)delegate
{
	if ([identifer isKindOfClass:[NSNumber class]]) {
		identifer = [(NSNumber *)identifer stringValue];
	}
	
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:identifer, @"plurk_id", nil];
	[self addRequestWithURLPath:@"/API/Timeline/responseDelete" arguments:args actionName:OPDeleteResponsesAction delegate:delegate];
}

#pragma mark Profiles

- (void)retrieveMyProfileWithDelegate:(id)delegate
{
	[self addRequestWithURLPath:@"/API/Profile/getOwnProfile" arguments:nil actionName:OPRetrieveMyProfileAction delegate:delegate];
}

- (void)retrievePublicProfileWithUserIdentifier:(NSString *)userIdentifier delegate:(id)delegate
{
	if ([userIdentifier isKindOfClass:[NSNumber class]]) {
		userIdentifier = [(NSNumber *)userIdentifier stringValue];
	}
	
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:userIdentifier, @"user_id", nil];
	[self addRequestWithURLPath:@"/API/Profile/getPublicProfile" arguments:args actionName:OPRetrievePublicProfileAction delegate:delegate];	
}

@synthesize APIKey;
@synthesize qualifiers = _qualifiers;
@synthesize langCodes = _langCodes;
@synthesize currentUserInfo = _currentUserInfo;

@end
