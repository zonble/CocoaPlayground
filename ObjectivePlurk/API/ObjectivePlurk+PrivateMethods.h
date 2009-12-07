//
//  ObjectivePlurk+PrivateMethods.h
//  ObjectivePlurk
//
//  Created by zonble on 12/5/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import "ObjectivePlurk.h"

@interface ObjectivePlurk(PrivateMethods)

- (void)loginDidSuccess:(LFHTTPRequest *)request;
- (void)loginDidFail:(NSError *)error;
- (void)commonAPIDidSuccess:(NSDictionary *)sessionInfo;
- (void)commonAPIDidFail:(NSError *)error;

@end
