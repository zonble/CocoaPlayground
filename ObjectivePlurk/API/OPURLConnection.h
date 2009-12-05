//
//  OPURLConnection.h
//  ObjectivePlurk
//
//  Created by zonble on 12/5/09.
//  Copyright 2009 Lithoglyph Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPURLConnection : NSURLConnection
{
	id sessionInfo;
}

@property (retain, nonatomic) id sessionInfo;

@end
