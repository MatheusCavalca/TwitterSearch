//
//  Tweet.m
//  BuscadorTwitter
//
//  Created by Matheus Cavalca on 9/24/15.
//  Copyright © 2015 Matheus Cavalca. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

-(id)initWithProfileName:(NSString*)name text:(NSString*)text tweetID:(NSString*)tweetID andProfilePictureUrl: (NSString*)profilePictureURL
{
    self = [super init];
    
    if(self)
    {
        self.profileName = name;
        self.text = text;
        self.pictureURL = profilePictureURL;
        self.tweetID = tweetID;
    }
    return self;
}

@end
