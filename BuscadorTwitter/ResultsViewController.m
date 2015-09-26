//
//  ResultsViewController.m
//  BuscadorTwitter
//
//  Created by Matheus Cavalca on 9/24/15.
//  Copyright © 2015 Matheus Cavalca. All rights reserved.
//

#import "ResultsViewController.h"

@interface ResultsViewController ()

@end

@implementation ResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tappedSearchIcon:)];
    [tapGesture setDelegate:self];
    [self.searchView addGestureRecognizer:tapGesture];
    self.lblQuerySearched.text = self.querySearched;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource/Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCellIdentifier"];
    cell.lblName.text = ((Tweet*)[self.arrayTweets objectAtIndex:indexPath.row]).profileName;
    cell.lblMessage.text = ((Tweet*)[self.arrayTweets objectAtIndex:indexPath.row]).text;
    if(((Tweet*)[self.arrayTweets objectAtIndex:indexPath.row]).profilePicture){
        cell.imgProfilePicture.image = ((Tweet*)[self.arrayTweets objectAtIndex:indexPath.row]).profilePicture;
    }
    cell.imgProfilePicture.layer.cornerRadius = cell.imgProfilePicture.frame.size.height/2;
    cell.imgProfilePicture.clipsToBounds = YES;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayTweets.count;
}

- (void)tappedSearchIcon:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
