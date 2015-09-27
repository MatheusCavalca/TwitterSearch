//
//  TweetWithMediaUITableViewCell.h
//  BuscadorTwitter
//
//  Created by Matheus Cavalca on 9/27/15.
//  Copyright © 2015 Matheus Cavalca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetTableViewCell.h"

@interface TweetWithMediaUITableViewCell : TweetTableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgMediaPicture;

@end
