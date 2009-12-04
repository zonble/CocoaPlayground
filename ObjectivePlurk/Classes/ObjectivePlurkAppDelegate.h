//
//  ObjectivePlurkAppDelegate.h
//  ObjectivePlurk
//
//  Created by zonble on 12/5/09.
//  Copyright Lithoglyph Inc. 2009. All rights reserved.
//

#import "ObjectivePlurk.h"
#import "PlurkAPI.h"

@interface ObjectivePlurkAppDelegate : NSObject <UIApplicationDelegate> 
{    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

- (NSString *)applicationDocumentsDirectory;

@end

