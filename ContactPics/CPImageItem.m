//
//  CPImageItem.m
//  ContactPics
//
//  Created by zonble on 11/24/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import "CPImageItem.h"

@implementation CPImageItem

- (NSString *)imageRepresentationType
{
	return IKImageBrowserNSImageRepresentationType;
}
- (id)imageRepresentation
{
	return image;
}

@synthesize imageUID;
@synthesize image;
@synthesize imageTitle;
@synthesize imageSubtitle;

@end
