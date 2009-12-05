//
//  OPURLConnection.m
//  ObjectivePlurk
//
//  Created by zonble on 12/5/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import "OPURLConnection.h"

@implementation OPURLConnection

- (void)dealloc
{
	[sessionInfo release];
	[receivedString release];
	[super dealloc];
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate
{
	self = [super initWithRequest:request delegate:delegate];
	if (self != nil) {
		sessionInfo = nil;
		receivedString = [[NSMutableString alloc] init];
	}
	return self;
}


@synthesize sessionInfo;
@synthesize receivedString;

@end
