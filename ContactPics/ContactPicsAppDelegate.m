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
	[(IKImageBrowserView *)imageFlowView setDataSource:self];
	[(IKImageBrowserView *)imageFlowView setDelegate:self];
	[self setActiveView:imageBrowserScrollView];
	
	NSArray *people = [[ABAddressBook sharedAddressBook] people];
	NSMutableArray *newPeople = [NSMutableArray arrayWithArray:people];
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
	[(IKImageBrowserView *)imageFlowView reloadData];
}

- (IBAction)toogleActiveView:(id)sender
{
	if ([sender selectedSegment] == 0) {
		[self setActiveView:imageBrowserScrollView];
	}
	else if ([sender selectedSegment] == 1) {
		[self setActiveView:imageFlowView];
	}

}

- (void)setActiveView:(NSView *)newContentView
{
	NSRect bounds = [containerView bounds];
	[newContentView setFrame:bounds];
	if ([[containerView subviews] count]) {
		[[[containerView subviews] objectAtIndex:0] removeFromSuperview];
	}
	[containerView addSubview:newContentView];
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
}
- (void)imageFlow:(id)aFlowLayer cellWasDoubleClickedAtIndex:(NSInteger)index
{
}


@end
