//
//  ResultsViewController.h
//  BuscadorTwitter
//
//  Created by Matheus Cavalca on 9/24/15.
//  Copyright © 2015 Matheus Cavalca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetTableViewCell.h"
#import "Tweet.h"

@interface ResultsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tvMain;

@property (strong, nonatomic) NSMutableArray *arrayTweets;

@end
