//
//  ObjectivePlurk.h
//  ObjectivePlurk
//
//  Created by zonble on 12/5/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LFWebAPIKit.h"
#import "NSArray+BSJSONAdditions.h"
#import "NSDictionary+BSJSONAdditions.h"

@class ObjectivePlurk;

@protocol ObjectivePlurkDelegate <NSObject>

#pragma mark Users

- (void)plurk:(ObjectivePlurk *)plurk didLoggedIn:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailLoggingIn:(NSError *)error;

#pragma mark Polling

- (void)plurk:(ObjectivePlurk *)plurk didRetrievePollingMessages:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRetrievingPollingMessages:(NSError *)error;

#pragma mark Timeline

- (void)plurk:(ObjectivePlurk *)plurk didRetrieveMessage:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRetrievingMessage:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didRetrieveMessages:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRetrievingMessages:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didRetrieveUnreadMessages:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRetrievingUnreadMessages:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didMuteMessages:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailMutingMessages:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didUnmuteMessages:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailUnmutingMessages:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didMarkMessagesAsRead:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailMarkingMessagesAsRead:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didAddMessage:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailAddingMessage:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didDeleteMessage:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailDeletingMessage:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didEditMessage:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailEditingMessage:(NSError *)error;

#pragma mark Profiles

- (void)plurk:(ObjectivePlurk *)plurk didRetrieveMyProfile:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRetrievingMyProfile:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didRetrievePublicProfile:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRetrievingPublicProfile:(NSError *)error;

@end

#pragma mark -

typedef enum {
	OPSmallUserProfileImageSize = 0,
	OPMediumUserProfileImageSize = 1,
	OPBigUserProfileImageSize = 2
} OPUserProfileImageSize;


typedef enum {
	OPEveryOneCanComment = 0,
	OPNoOneCanComment = 1,
	OPOnlyFriendsCanComment = 2
} OPCanComment;

extern NSString *ObjectivePlurkAPIURLString;
extern NSString *ObjectivePlurkErrorDomain;

extern NSString *OPLoginAction;

extern NSString *OPRetrivePollingMessageAction;

extern NSString *OPRetriveMessageAction;
extern NSString *OPRetriveMessagesAction;
extern NSString *OPRetriveUnreadMessagesAction;
extern NSString *OPMuteMessagesAction;
extern NSString *OPUnmuteMessagesAction;
extern NSString *OPMarkMessageAsReadAction;
extern NSString *OPAddMessageAction;
extern NSString *OPDeleteMessageAction;
extern NSString *OPEditMessageAction;

extern NSString *OPRetrieveMyProfileAction;
extern NSString *OPRetrievePublicProfileAction;


@interface ObjectivePlurk : NSObject
{
	NSString *APIKey;
	LFHTTPRequest *_request;
	NSMutableArray *_queue;
	NSArray *_qualifiers;
	NSDictionary *_langCodes;
	NSDictionary *_currentUserInfo;
	NSDateFormatter *_dateFormatter;
}

+ (ObjectivePlurk *)sharedInstance;
- (void)cancelAllRequest;
- (void)cancelAllRequestWithDelegate:(id)delegate;
- (void)runQueue;
- (void)logout;

- (NSString *)imageURLStringForUser:(id)identifier size:(OPUserProfileImageSize)size hasProfileImage:(BOOL)hasProfileImage avatar:(NSString *)avatar;

#pragma mark Users

- (void)loginWithUsername:(NSString *)username password:(NSString *)password delegate:(id)delegate;

#pragma mark Polling

- (void)retrieveMessagesWithDateOffset:(NSDate *)offsetDate delegate:(id)delegate;

#pragma mark Timeline

- (void)retrieveMessageWithMessageIdentifier:(NSString *)identifer delegate:(id)delegate;
- (void)retrieveMessagesWithDateOffset:(NSDate *)offsetDate limit:(NSInteger)limit user:(NSString *)userID isResponded:(BOOL)isResponded isPrivate:(BOOL)isPrivate delegate:(id)delegate;
- (void)retrieveUnreadMessagesWithDateOffset:(NSDate *)offsetDate limit:(NSInteger)limit delegate:(id)delegate;
- (void)muteMessagesWithMessageIdentifiers:(NSArray *)identifiers delegate:(id)delegate;
- (void)unmuteMessagesWithMessageIdentifiers:(NSArray *)identifiers delegate:(id)delegate;
- (void)markMessagesAsReadWithMessageIdentifiers:(NSArray *)identifiers delegate:(id)delegate;
- (void)addNewMessageWithContent:(NSString *)content qualifier:(NSString *)qualifier othersCanComment:(OPCanComment)canComment lang:(NSString *)lang limitToUsers:(NSArray *)users delegate:(id)delegate;

- (void)deleteMessageWithMessageIdentifier:(NSString *)identifer delegate:(id)delegate;
- (void)editMessageWithMessageIdentifier:(NSString *)identifer content:(NSString *)content delegate:(id)delegate;

#pragma mark Profiles

- (void)retrieveMyProfileWithDelegate:(id)delegate;
- (void)retrievePublicProfileWithUserIdentifier:(NSString *)userIdentifier delegate:(id)delegate;

@property (retain, nonatomic) NSString *APIKey;
@property (readonly) NSArray *qualifiers;
@property (readonly) NSDictionary *langCodes;
@property (readonly, getter=isLoggedIn) BOOL loggedIn;
@property (copy, nonatomic) NSDictionary *currentUserInfo;

@end
