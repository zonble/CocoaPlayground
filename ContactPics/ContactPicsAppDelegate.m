//
//  ContactPicsAppDelegate.m
//  ContactPics
//
//  Created by zonble on 11/24/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import "ContactPicsAppDelegate.h"
#import "CPImageItem.h"

@implementation ContactPicsAppDelegate

@synthesize window;

- (id) init
{
	self = [super init];
	if (self != nil) {
		zoom = 0.3;
	}
	return self;
}


- (void)awakeFromNib
{
	[arrayController addObserver:self forKeyPath:@"sortDescriptors" options:NSKeyValueObservingOptionNew context:NULL];
	[arrayController addObserver:self forKeyPath:@"arrangedObjects" options:NSKeyValueObservingOptionNew context:NULL];
	[arrayController addObserver:self forKeyPath:@"selectionIndex" options:NSKeyValueObservingOptionNew context:NULL];
	[(IKImageBrowserView *)imageFlowView setDataSource:self];
	[(IKImageBrowserView *)imageFlowView setDelegate:self];
	[self setActiveView:imageBrowserScrollView];
	
	[self presentDefaultContent];
}

- (IBAction)fullscreen:(id)sender
{
	if (![fullscreenBackgroundView isInFullScreenMode]) {
		NSView *view = [[containerView subviews] objectAtIndex:0];
		[view setFrame:[fullscreenContainerView bounds]];
		[fullscreenContainerView addSubview:view];
		[fullscreenBackgroundView enterFullScreenMode:[NSScreen mainScreen] withOptions:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSFullScreenModeAllScreens, [NSNumber numberWithInt:CGShieldingWindowLevel()], NSFullScreenModeWindowLevel, nil]];
		[window makeFirstResponder:view];
		fullscreenView = view;
	}
	else {
		[self exitFullscreen:sender];
	}
}

- (IBAction)search:(id)sender
{
	NSString *keyword = [[sender stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if (![keyword length]) {
		[self presentDefaultContent];
		return;
	}
	
	ABSearchElement *search = [ABPerson searchElementForProperty:kABEmailProperty label:nil key:nil value:keyword comparison:kABPrefixMatchCaseInsensitive];
	NSArray *a = [[ABAddressBook sharedAddressBook] recordsMatchingSearchElement:search];
	[self presentContentWithArray:a];
}

- (IBAction)exitFullscreen:(id)sender
{
	[fullscreenBackgroundView exitFullScreenModeWithOptions:nil];
	if (fullscreenView) {
		[self setActiveView:fullscreenView];
		[window makeFirstResponder:fullscreenView];
		fullscreenView = nil;
	}
}

- (IBAction)toogleActiveView:(id)sender
{
	NSUInteger tag = 0;
	if ([sender isKindOfClass:[NSMenuItem class]]) {
		tag = [sender tag];
	}
	else if ([sender isKindOfClass:[NSSegmentedControl class]]) {
		tag = [sender selectedSegment];
	}
	
	if (tag == 0) {
		[self setActiveView:imageBrowserScrollView];
	}
	else if (tag == 1) {
		[self setActiveView:imageFlowView];
	}
	else if (tag == 2) {
		[self setActiveView:tableScrollView];
	}
	[segmentedControl setSelectedSegment:tag];
}

- (void)setActiveView:(NSView *)newContentView
{
	NSRect bounds = [containerView bounds];
	[newContentView setFrame:bounds];
	if ([[containerView subviews] count]) {
		[[[containerView subviews] objectAtIndex:0] removeFromSuperview];
	}
	[containerView addSubview:newContentView];
	[window makeFirstResponder:newContentView];
}

- (void)presentDefaultContent
{
	NSArray *people = [[ABAddressBook sharedAddressBook] people];
	[self presentContentWithArray:people];
}
- (void)presentContentWithArray:(NSArray *)array
{	
	NSMutableArray *newPeople = [NSMutableArray arrayWithArray:array];
	[newPeople sortUsingComparator:^(id a, id b) {
		NSString *lastNameA = [(ABRecord *)a valueForProperty:kABLastNameProperty];
		NSString *lastNameB = [(ABRecord *)b  valueForProperty:kABLastNameProperty];
		NSComparisonResult result = [lastNameA localizedStandardCompare:lastNameB];
		if (result != NSOrderedSame) {
			return result;
		}
		NSString *firstNameA = [(ABRecord *)a valueForProperty:kABFirstNameProperty];
		NSString *firstNameB = [(ABRecord *)b  valueForProperty:kABFirstNameProperty];
		return [firstNameA localizedStandardCompare:firstNameB];		
	}];
	NSMutableArray *a = [NSMutableArray array];
	for (ABRecord *record in newPeople) {
		if ([record isKindOfClass:[ABPerson class]]) {
			if (![(ABPerson *)record imageData]) {
				continue;
			}
			NSString *firstName = [(ABPerson *)record  valueForProperty:kABFirstNameProperty];
			NSString *lastName = [(ABPerson *)record  valueForProperty:kABLastNameProperty];
			NSMutableString *name = [NSMutableString string];
			if (lastName) {
				[name setString:lastName];
			}
			if ([name length] && [firstName length]) {
				[name appendFormat:@" %@", firstName];
			}
			else if (firstName) {
				[name setString:firstName];
			}
			
			if (![name length]) {
				NSString *company = [(ABPerson *)record  valueForProperty:kABOrganizationProperty];
				[name setString:company];
			}
			
			CPImageItem *item = [[[CPImageItem alloc] init] autorelease];
			item.image = [[[NSImage alloc] initWithData:[(ABPerson *)record imageData]] autorelease];
			item.imageUID = [record uniqueId];
			item.imageTitle = name;
			[a addObject:item];
		}
	}
	[arrayController setContent:a];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"selectionIndex"]) {
		[imageFlowView setSelectedIndex:[arrayController selectionIndex]];
	}
	[(IKImageBrowserView *)imageFlowView reloadData];
}

#pragma mark -

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application 
}

- (void)windowWillClose:(NSNotification *)notification
{
	[NSApp terminate:self];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if ([menuItem action] == @selector(toogleActiveView:)) {
		if ([menuItem tag] == [segmentedControl selectedSegment]) {
			[menuItem setState:NSOnState];
		}
		else {
			[menuItem setState:NSOffState];
		}
	}
	return YES;
}

#pragma mark -

- (NSUInteger)numberOfItemsInImageFlow:(id)aFlowLayer
{
	return [[arrayController arrangedObjects] count];
}
- (id)imageFlow:(id)aFlowLayer itemAtIndex:(NSInteger)index
{
	return [[arrayController arrangedObjects] objectAtIndex:index];
}
- (void)imageFlow:(id)aFlowLayer didSelectItemAtIndex:(NSInteger)index
{
	[arrayController setSelectionIndex:index];
}
- (void)imageFlow:(id)aFlowLayer cellWasDoubleClickedAtIndex:(NSInteger)index
{
}


@end
