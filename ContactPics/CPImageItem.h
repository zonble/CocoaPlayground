//
//  CPImageItem.h
//  ContactPics
//
//  Created by zonble on 11/24/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface CPImageItem : NSObject
{
	NSString *imageUID;
	NSImage *image;
	NSString *imageTitle;
	NSString *imageSubtitle;
}

@property (retain) NSString *imageUID;
@property (retain) NSImage *image;
@property (retain) NSString *imageTitle;
@property (retain) NSString *imageSubtitle;

@end
