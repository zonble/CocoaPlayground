//
//  ImageGrabberAppDelegate.h
//  ImageGrabber
//
//  Created by zonble on 12/2/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ImageGrabberAppDelegate : NSObject <NSApplicationDelegate>
{
    NSWindow *window;
	IBOutlet NSImageView *imageView;
	IBOutlet NSTextField *filePathField;
	IBOutlet NSTextField *fileExtensionField;
}

- (IBAction)grabFromFilePathAction:(id)sender;
- (IBAction)grabFromFileExtensionAction:(id)sender;
- (IBAction)save:(id)sender;

@property (assign) IBOutlet NSWindow *window;

@end
