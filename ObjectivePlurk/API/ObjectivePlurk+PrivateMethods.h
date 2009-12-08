//
//  ObjectivePlurk+PrivateMethods.h
//  ObjectivePlurk
//
//  Created by zonble on 12/5/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import "ObjectivePlurk.h"

@interface ObjectivePlurk(PrivateMethods)

- (NSString *)GETStringFromDictionary:(NSDictionary *)inDictionary;
- (void)addRequestWithURLPath:(NSString *)URLPath arguments:(NSDictionary *)arguments actionName:(NSString *)actionName delegate:(id)delegate;

- (void)loginDidSuccess:(LFHTTPRequest *)request;
- (void)loginDidFail:(NSError *)error;
- (void)commonAPIDidSuccess:(NSDictionary *)sessionInfo;
- (void)commonAPIDidFail:(NSError *)error;

@end
