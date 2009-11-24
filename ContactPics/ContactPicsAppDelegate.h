//
//  ContactPicsAppDelegate.h
//  ContactPics
//
//  Created by zonble on 11/24/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AddressBook/AddressBook.h>

@interface ContactPicsAppDelegate : NSObject <NSApplicationDelegate> 
{
    NSWindow *window;
	CGFloat zoom;
	
	IBOutlet NSArrayController *arrayController;
	IBOutlet NSScrollView *imageBrowserScrollView;
	IBOutlet NSView *imageFlowView;
	IBOutlet NSScrollView *tableScrollView;
	IBOutlet NSView *containerView;
	IBOutlet NSView *fullscreenBackgroundView;
	IBOutlet NSView *fullscreenContainerView;
	IBOutlet NSSegmentedControl *segmentedControl;
	
	id fullscreenView;
}

- (IBAction)fullscreen:(id)sender;
- (IBAction)exitFullscreen:(id)sender;
- (IBAction)search:(id)sender;
- (IBAction)toogleActiveView:(id)sender;
- (void)presentContentWithArray:(NSArray *)array;
- (void)presentDefaultContent;
- (void)setActiveView:(NSView *)newContentView;

@property (assign) IBOutlet NSWindow *window;

@end
