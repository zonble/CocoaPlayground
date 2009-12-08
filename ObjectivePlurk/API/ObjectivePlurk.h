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

#pragma mark Responses

- (void)plurk:(ObjectivePlurk *)plurk didRetrieveResponses:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRetrievingResponses:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didAddResponse:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailAddingResponse:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didDeleteResponse:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailDeletingResponse:(NSError *)error;

#pragma mark Profiles

- (void)plurk:(ObjectivePlurk *)plurk didRetrieveMyProfile:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRetrievingMyProfile:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didRetrievePublicProfile:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRetrievingPublicProfile:(NSError *)error;

#pragma mark Friends and fans

- (void)plurk:(ObjectivePlurk *)plurk didRetrieveFriends:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRetrievingFriends:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didRetrieveFans:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRetrievingFans:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didRetrieveFollowingUsers:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRetrievingFollowingUsers:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didBecomeFriend:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailBecomingFriend:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didRemoveFriendship:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRemovingFriendship:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didBecomeFan:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailBecomingFan:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didSetFollowingUser:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailSettingFollowingUser:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didRetrieveFriendsCompletionList:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRetrievingFriendsCompletionList:(NSError *)error;


#pragma mark Alerts

- (void)plurk:(ObjectivePlurk *)plurk didRetriveActiveAlerts:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRetrivingActiveAlerts:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didRetriveHistory:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRetrivingHistory:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didAddAsFan:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailAddingAsFan:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didAddAllAsFan:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailAddingAllAsFan:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didAddAsFriend:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailAddingAsFriend:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didAddAllAsFriend:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailAddingAllAsFriend:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didDenyFriendship:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailDenyingFriendship:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didRemoveNotification:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailRemovingNotification:(NSError *)error;

#pragma mark Search

- (void)plurk:(ObjectivePlurk *)plurk didSearchMessages:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailSearchingMessages:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didSearchUsers:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailSearchingUsers:(NSError *)error;


@end

#pragma mark -

typedef enum {
	OPGenderMale = 0,
	OPGenderFemale = 1
} OPGender;


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

extern NSString *OPAlertFriendshipRequestType;
extern NSString *OPAlertFriendshipPendingType;
extern NSString *OPAlertNewFanType;
extern NSString *OPAlertFriendshipAcceptedType;
extern NSString *OPAlertNewFriendType;

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

extern NSString *OPRetriveResponsesAction;
extern NSString *OPAddResponsesAction;
extern NSString *OPDeleteResponsesAction;

extern NSString *OPRetrieveMyProfileAction;
extern NSString *OPRetrievePublicProfileAction;

extern NSString *OPRetriveFriendAction;
extern NSString *OPRetriveFansAction;
extern NSString *OPRetriveFollowingAction;
extern NSString *OPBecomeFriendAction;
extern NSString *OPRemoveFriendshipAction;
extern NSString *OPBecomeFanAction;
extern NSString *OPSetFollowingAction;
extern NSString *OPRetrieveFriendsCompletionListAction;

extern NSString *OPRetriveActiveAlertsAction;
extern NSString *OPRetriveHistoryAction;
extern NSString *OPAddAsFanAction;
extern NSString *OPAddAllAsFanAction;
extern NSString *OPAddAsFriendAction;
extern NSString *OPAddAllAsFriendAction;
extern NSString *OPDenyFriendshipAction;
extern NSString *OPRemoveNotificationAction;

extern NSString *OPSearchMessagesAction;
extern NSString *OPSearchUsersAction;


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

#pragma mark Responses

- (void)retrieveResponsesWithMessageIdentifier:(NSString *)identifer delegate:(id)delegate;
- (void)addNewResponseWithContent:(NSString *)content qualifier:(NSString *)qualifier toMessages:(NSString *)identifer delegate:(id)delegate;
- (void)deleteResponseWithMessageIdentifier:(NSString *)identifer delegate:(id)delegate;

#pragma mark Profiles

- (void)retrieveMyProfileWithDelegate:(id)delegate;
- (void)retrievePublicProfileWithUserIdentifier:(NSString *)userIdentifier delegate:(id)delegate;

#pragma mark Friends and fans

- (void)retrieveFriendsOfUser:(NSString *)userIdentifier offset:(NSUInteger)offset delegate:(id)delegate;
- (void)retrieveFansOfUser:(NSString *)userIdentifier offset:(NSUInteger)offset delegate:(id)delegate;
- (void)retrieveFollowingUsersOfCurrentUserWithOffset:(NSUInteger)offset delegate:(id)delegate;
- (void)becomeFriendOfUser:(NSString *)userIdentifier delegate:(id)delegate;
- (void)removeFriendshipWithUser:(NSString *)userIdentifier delegate:(id)delegate;
- (void)becomeFanOfUser:(NSString *)userIdentifier delegate:(id)delegate;
- (void)setFollowingUser:(NSString *)userIdentifier follow:(BOOL)follow delegate:(id)delegate;
- (void)retrieveFriendsCompletionList:(id)delegate;

#pragma mark Alerts

- (void)retriveActiveAlertsWithDelegate:(id)delegate;
- (void)retrivetHistoryWithDelegate:(id)delegate;
- (void)addAsFanWithUserIdentifier:(NSString *)userIdentifier delegate:(id)delegate;
- (void)addAllAsFanWithDelegate:(id)delegate;
- (void)addAsFriendWithUserIdentifier:(NSString *)userIdentifier delegate:(id)delegate;
- (void)addAllAsFriendWithDelegate:(id)delegate;
- (void)denyFriendshipWithUserIdentifier:(NSString *)userIdentifier delegate:(id)delegate;
- (void)removeNotificationWithDelegate:(id)delegate;

#pragma mark Search

- (void)searchMessagesWithQuery:(NSString *)query offset:(NSUInteger)offset delegate:(id)delegate;
- (void)searchUsersWithQuery:(NSString *)query offset:(NSUInteger)offset delegate:(id)delegate;


@property (retain, nonatomic) NSString *APIKey;
@property (readonly) NSArray *qualifiers;
@property (readonly) NSDictionary *langCodes;
@property (readonly, getter=isLoggedIn) BOOL loggedIn;
@property (copy, nonatomic) NSDictionary *currentUserInfo;

@end
