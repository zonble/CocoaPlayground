//
//  ObjectivePlurk+PrivateMethods.h
//  ObjectivePlurk
//
//  Created by zonble on 12/5/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import "ObjectivePlurk.h"

#if !TARGET_OS_IPHONE
#else
#import <MobileCoreServices/MobileCoreServices.h>
#endif


@interface ObjectivePlurk(PrivateMethods)

- (NSString *)GETStringFromDictionary:(NSDictionary *)inDictionary;
- (void)runQueue;
- (void)addRequestWithAction:(NSString *)actionName arguments:(NSDictionary *)arguments delegate:(id)delegate;

- (void)loginDidSuccess:(LFHTTPRequest *)request;
- (void)loginDidFail:(NSError *)error;
- (void)commonAPIDidSuccess:(NSDictionary *)sessionInfo;
- (void)commonAPIDidFail:(NSError *)error;

@end
