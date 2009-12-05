//
//  ObjectivePlurk.h
//  ObjectivePlurk
//
//  Created by zonble on 12/5/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "LFWebAPIKit.h"
#import "OPURLConnection.h"
#import "NSArray+BSJSONAdditions.h"
#import "NSDictionary+BSJSONAdditions.h"

@class ObjectivePlurk;

@protocol ObjectivePlurkDelegate <NSObject>

#pragma mark Users

- (void)plurk:(ObjectivePlurk *)plurk didLoggedIn:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailLoggingIn:(NSError *)error;

#pragma mark Timeline

- (void)plurk:(ObjectivePlurk *)plurk didRetrieveMessage:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRetrievingMessage:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didRetrieveMessages:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRetrievingMessages:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didRetrieveUnreadMessages:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRetrievingUnreadMessages:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didAddMessage:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailAddingMessage:(NSError *)error;

@end

typedef enum {
	OPEveryOneCanComment = 0,
	OPNoOneCanComment = 1,
	OPOnlyFriendsCanComment = 1
} OPCanComment;

extern NSString *loginAction;
extern NSString *retriveMessageAction;
extern NSString *retriveMessagesAction;
extern NSString *retriveUnreadMessagesAction;
extern NSString *addMessageAction;

@interface ObjectivePlurk : NSObject
{
//	LFHTTPRequest *_request;
	OPURLConnection *_connection;
	NSMutableArray *_queue;
	NSDictionary *_currentUserInfo;
	NSArray *_qualifiers;
	NSDictionary *_langCodes;
	NSDateFormatter *_dateFormatter;
	BOOL _isLoggedIn;
}

+ (ObjectivePlurk *)sharedInstance;
- (void)cancelAllRequest;
- (void)cancelAllRequestWithDelegate:(id)delegate;
- (void)runQueue;

#pragma mark Users

- (void)loginWithUsername:(NSString *)username password:(NSString *)password delegate:(id)delegate;

#pragma mark Timeline

- (void)retrieveMessageWithIdentifier:(NSString *)identifer delegate:(id)delegate;
- (void)retrieveMessagesWithOffset:(NSDate *)offsetDate limit:(NSInteger)limit user:(NSString *)userID isResponded:(BOOL)isResponded isPrivate:(BOOL)isPrivate delegate:(id)delegate;
- (void)retrieveUnreadMessagesWithOffset:(NSDate *)offsetDate limit:(NSInteger)limit delegate:(id)delegate;

- (void)addMessageWithContent:(NSString *)content qualifier:(NSString *)qualifier canComment:(OPCanComment)canComment lang:(NSString *)lang limitToUsers:(NSArray *)users delegate:(id)delegate;

//- (void)setShouldWaitUntilDone:(BOOL)flag;
//- (BOOL)shouldWaitUntilDone;

@property (assign) BOOL isLoggedIn;
@property (readonly) NSArray *qualifiers;
@property (readonly) NSDictionary *langCodes;
@property (copy, nonatomic) NSDictionary *currentUserInfo;
@property (retain) OPURLConnection *currentConnection;

@end
