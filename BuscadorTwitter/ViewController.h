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
#import "SearchesAndTrendsHeaderView.h"
#import "ResultsViewController.h"
#import "Tweet.h"
#import "ActivityIndicatorButton.h"

@interface ViewController : UIViewController<UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *viewTvs;
@property (strong, nonatomic) IBOutlet UITableView *tvLastResearches;
@property (strong, nonatomic) IBOutlet UITableView *tvTrends;
@property (strong, nonatomic) IBOutlet ActivityIndicatorButton *btSearch;
@property (strong, nonatomic) IBOutlet UIView *viewQuery;
@property (strong, nonatomic) IBOutlet UITextField *txtQuery;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *SearchViewConstraintCenterY;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *twitterLogoBottomConstraint;

@end