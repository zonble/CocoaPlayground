//
//  ObjectivePlurk.h
//  ObjectivePlurk
//
//  Created by zonble on 12/5/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LFWebAPIKit.h"
#import "NSDictionary+BSJSONAdditions.h"

@class ObjectivePlurk;

@protocol ObjectivePlurkDelegate <NSObject>

- (void)plurk:(ObjectivePlurk *)plurk didLoggedIn:(NSDictionary *)result;
- (void)plurk:(ObjectivePlurk *)plurk didFailLoggingIn:(NSError *)error;

@end


@interface ObjectivePlurk : NSObject
{
	LFHTTPRequest *_request;
	NSMutableArray *_queue;
	NSDictionary *_currentUserInfo;
	NSArray *_qualifiers;
	NSDictionary *_langCodes;
}

+ (ObjectivePlurk *)sharedInstance;
- (void)cancelAllRequest;
- (void)cancelAllRequestWithDelegate:(id)delegate;
- (void)runQueue;

- (void)setShouldWaitUntilDone:(BOOL)flag;
- (BOOL)shouldWaitUntilDone;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password delegate:(id)delegate;

@property (readonly) NSArray *qualifiers;
@property (readonly) NSDictionary *langCodes;
@property (copy, nonatomic) NSDictionary *currentUserInfo;

@end
