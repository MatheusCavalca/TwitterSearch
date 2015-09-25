//
//  ViewController.h
//  BuscadorTwitter
//
//  Created by Matheus Cavalca on 9/23/15.
//  Copyright © 2015 Matheus Cavalca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import "RecentSearches.h"
#import "SearchesAndTrendsTableViewCell.h"
#import "ResultsViewController.h"
#import "Tweet.h"

@interface ViewController : UIViewController<UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tvLastResearches;
@property (strong, nonatomic) IBOutlet UITableView *tvTrends;
@property (strong, nonatomic) IBOutlet UIImageView *imgSearchIcon;
@property (strong, nonatomic) IBOutlet UITextField *txtQuery;

@end