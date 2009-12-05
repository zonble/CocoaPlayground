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

- (void)plurk:(ObjectivePlurk *)plurk didLoggedIn:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailLoggingIn:(NSError *)error;

- (void)plurk:(ObjectivePlurk *)plurk didAddMessage:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailAddingMessage:(NSError *)error;

@end

typedef enum {
	OPEveryOneCanComment = 0,
	OPNoOneCanComment = 1,
	OPOnlyFriendsCanComment = 1
} OPCanComment;

@interface ObjectivePlurk : NSObject
{
//	LFHTTPRequest *_request;
	OPURLConnection *_connection;
	NSMutableArray *_queue;
	NSDictionary *_currentUserInfo;
	NSArray *_qualifiers;
	NSDictionary *_langCodes;
}

+ (ObjectivePlurk *)sharedInstance;
- (void)cancelAllRequest;
- (void)cancelAllRequestWithDelegate:(id)delegate;
- (void)runQueue;

//- (void)setShouldWaitUntilDone:(BOOL)flag;
//- (BOOL)shouldWaitUntilDone;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password delegate:(id)delegate;
- (void)addMessageWithContent:(NSString *)content qualifier:(NSString *)qualifier canComment:(OPCanComment)canComment lang:(NSString *)lang limitToUsers:(NSArray *)users delegate:(id)delegate;

@property (readonly) NSArray *qualifiers;
@property (readonly) NSDictionary *langCodes;
@property (copy, nonatomic) NSDictionary *currentUserInfo;
@property (retain) OPURLConnection *currentConnection;

@end
