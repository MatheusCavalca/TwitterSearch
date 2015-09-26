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

@interface ResultsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (strong, nonatomic) IBOutlet UITableView *tvMain;
@property (strong, nonatomic) NSMutableArray *arrayTweets;
@property (strong, nonatomic) IBOutlet UILabel *lblQuerySearched;
@property (strong, nonatomic) NSString *querySearched;
@end
