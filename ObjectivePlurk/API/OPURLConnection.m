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
	[super dealloc];
}

@synthesize sessionInfo;

@end