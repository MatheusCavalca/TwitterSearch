//
//  Tweet.h
//  BuscadorTwitter
//
//  Created by Matheus Cavalca on 9/24/15.
//  Copyright © 2015 Matheus Cavalca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Tweet : NSObject

@property (strong, nonatomic)NSString *profileName;
@property (strong, nonatomic)NSString *text;
@property (strong, nonatomic)NSString *pictureURL;
@property (strong, nonatomic)UIImage *profilePicture;
@property (strong, nonatomic)NSString *tweetID;

-(id)initWithProfileName:(NSString*)name text:(NSString*)text tweetID:(NSString*)tweetID andProfilePictureUrl: (NSString*)profilePictureURL;

@end
