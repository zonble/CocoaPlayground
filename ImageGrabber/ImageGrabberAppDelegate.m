//
//  ImageGrabberAppDelegate.m
//  ImageGrabber
//
//  Created by zonble on 12/2/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import "ImageGrabberAppDelegate.h"

@implementation ImageGrabberAppDelegate

- (IBAction)grabFromFilePathAction:(id)sender
{	
	NSImage *image = [[NSWorkspace sharedWorkspace] iconForFile:[filePathField stringValue]];
	if (image) {
		[imageView setImage:image];
	}
}
- (IBAction)grabFromFileExtensionAction:(id)sender
{
	NSImage *image = [[NSWorkspace sharedWorkspace] iconForFileType:[fileExtensionField stringValue]];
	if (image) {
		[imageView setImage:image];
	}
	
}
- (IBAction)save:(id)sender
{
	if (![imageView image]) {
		return;
	}
	
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	NSInteger result = [savePanel runModal];
	if (result == NSOKButton) {
//		NSString *path = [savePanel filename];
		NSURL *URL = [savePanel URL];
		[[[imageView image] TIFFRepresentation] writeToURL:URL atomically:YES];
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application 
}

@synthesize window;
@end
