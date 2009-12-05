//
//  ObjectivePlurk.m
//  ObjectivePlurk
//
//  Created by zonble on 12/5/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import "ObjectivePlurk.h"
#import "PlurkAPI.h"

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
//	[_request release];
//	_request = nil;
	if (_connection) {
		[_connection release];
		_connection = nil;
	}
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
//		_request = [[LFHTTPRequest alloc] init];
//		[_request setDelegate:self];
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
//	[_request cancelWithoutDelegateMessage];
	if (self.currentConnection) {
		[self.currentConnection cancel];
		self.currentConnection = nil;
	}
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
//	if ([_request isRunning]) {
	if (_connection) {
//		id sessionInfo = [_request sessionInfo];
		id sessionInfo = [_connection sessionInfo];
		id theDelegate = [sessionInfo objectForKey:@"delegate"];
		if (theDelegate == delegate) {
//			[_request cancelWithoutDelegateMessage];
			[_connection cancel];
			self.currentConnection = nil;
			[self runQueue];
		}
	}
}
- (void)runQueue
{
	if ([_queue count]) {
		id sessionInfo = [_queue objectAtIndex:0];
		NSURL *URL = [sessionInfo objectForKey:@"URL"];
				
//		[_request setSessionInfo:sessionInfo];
//		[_request performMethod:LFHTTPRequestGETMethod onURL:URL withData:nil];
		
		NSURLRequest *request =  [NSURLRequest requestWithURL:URL];
		OPURLConnection *connection = [[[OPURLConnection alloc] initWithRequest:request delegate:self] autorelease];
		self.currentConnection = connection;
		connection.sessionInfo = sessionInfo;
		[connection start];
		
		[_queue removeObject:sessionInfo];		
	}
}


- (void)addRequestWithURLPath:(NSString *)URLPath arguments:(NSDictionary *)arguments actionName:(NSString *)actionName successAction:(SEL)successAction failAction:(SEL)failAction delegate:(id)delegate
{
	NSString *URLString = [API_URL stringByAppendingString:URLPath];
	URLString = [URLString stringByAppendingString:[self GETStringFromDictionary:arguments]];
	NSURL *URL = [NSURL URLWithString:URLString];
	NSLog(@"URL:%@", [URL description]);
	NSDictionary *sessionInfo = [NSDictionary dictionaryWithObjectsAndKeys:actionName, @"actionName", NSStringFromSelector(successAction), @"successAction", NSStringFromSelector(failAction), @"failAction", URL, @"URL", delegate, @"delegate", nil];
	
//	if (![_queue count] && ![_request isRunning]) {
//		[_request setSessionInfo:sessionInfo];
//		[_request performMethod:LFHTTPRequestGETMethod onURL:URL withData:nil];
//	}
	if (![_queue count] && !self.currentConnection) {
		NSURLRequest *request =  [NSURLRequest requestWithURL:URL];
		OPURLConnection *connection = [[[OPURLConnection alloc] initWithRequest:request delegate:self] autorelease];
		self.currentConnection = connection;
		connection.sessionInfo = sessionInfo;
		[connection start];
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

#pragma mark Users

- (void)loginWithUsername:(NSString *)username password:(NSString *)password delegate:(id)delegate
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", password, @"password", nil];
	[self addRequestWithURLPath:@"/API/Users/login" arguments:args actionName:loginAction successAction:@selector(loginDidSuccess:) failAction:@selector(loginDidFail:) delegate:delegate];
}

#pragma mark Timeline

- (void)retrieveMessageWithIdentifier:(NSString *)identifer delegate:(id)delegate
{
	if ([identifer isKindOfClass:[NSNumber class]]) {
		identifer = [(NSNumber *)identifer stringValue];
	}
	
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:identifer, @"plurk_id", nil];
	[self addRequestWithURLPath:@"/API/Timeline/getPlurk" arguments:args actionName:retriveMessageAction successAction:@selector(commonAPIDidSuccess:) failAction:@selector(commonAPIDidFail:) delegate:delegate];
}

- (void)retrieveMessagesWithOffset:(NSDate *)offsetDate limit:(NSInteger)limit user:(NSString *)userID isResponded:(BOOL)isResponded isPrivate:(BOOL)isPrivate delegate:(id)delegate
{
	NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if (offsetDate) {
		NSString *dateString = [_dateFormatter stringFromDate:offsetDate];
		NSLog(@"dateString:%@", [dateString description]);
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
	[self addRequestWithURLPath:@"/API/Timeline/getPlurks" arguments:args actionName:retriveMessagesAction successAction:@selector(commonAPIDidSuccess:) failAction:@selector(commonAPIDidFail:) delegate:delegate];
	
}

- (void)retrieveUnreadMessagesWithOffset:(NSDate *)offsetDate limit:(NSInteger)limit delegate:(id)delegate
{
	NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if (offsetDate) {
		NSString *dateString = [_dateFormatter stringFromDate:offsetDate];
		[args setValue:dateString forKey:@"offset"];
	}
	if (limit) {
		[args setValue:[[NSNumber numberWithInt:limit] stringValue] forKey:@"limit"];
	}
	[self addRequestWithURLPath:@"/API/Timeline/getUnreadPlurks" arguments:args actionName:retriveUnreadMessagesAction successAction:@selector(commonAPIDidSuccess:) failAction:@selector(commonAPIDidFail:) delegate:delegate];

}

- (void)muteMessagesWithIdentifiers:(NSArray *)identifiers delegate:(id)delegate
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:[identifiers jsonStringValue], @"ids", nil];
	[self addRequestWithURLPath:@"/API/Timeline/mutePlurks" arguments:args actionName:muteMessagesAction successAction:@selector(loginDidSuccess:) failAction:@selector(loginDidFail:) delegate:delegate];
}

- (void)unmuteMessagesWithIdentifiers:(NSArray *)identifiers delegate:(id)delegate
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:[identifiers jsonStringValue], @"ids", nil];
	[self addRequestWithURLPath:@"/API/Timeline/unmutePlurks" arguments:args actionName:unmuteMessagesAction successAction:@selector(loginDidSuccess:) failAction:@selector(loginDidFail:) delegate:delegate];
}

- (void)markMessagesAsReadWithIdentifiers:(NSArray *)identifiers delegate:(id)delegate
{
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:[identifiers jsonStringValue], @"ids", nil];
	[self addRequestWithURLPath:@"/API/Timeline/markAsRead" arguments:args actionName:markMessageAsReadAction successAction:@selector(loginDidSuccess:) failAction:@selector(loginDidFail:) delegate:delegate];
}


- (void)addMessageWithContent:(NSString *)content qualifier:(NSString *)qualifier canComment:(OPCanComment)canComment lang:(NSString *)lang limitToUsers:(NSArray *)users delegate:(id)delegate
{
	NSString *limitString = @"";
	if ([users count]) {
		limitString = [users jsonStringValue];
	}
	NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:content, @"content", qualifier, @"qualifier", [[NSNumber numberWithInt:canComment] stringValue], @"no_comments", lang, @"lang", limitString, @"limited_to", nil];
	[self addRequestWithURLPath:@"/API/Timeline/plurkAdd" arguments:args actionName:addMessageAction successAction:@selector(commonAPIDidSuccess:) failAction:@selector(commonAPIDidFail:) delegate:delegate];
}


@synthesize isLoggedIn = _isLoggedIn;
@synthesize qualifiers = _qualifiers;
@synthesize langCodes = _langCodes;
@synthesize currentUserInfo = _currentUserInfo;
@synthesize currentConnection = _connection;

@end
