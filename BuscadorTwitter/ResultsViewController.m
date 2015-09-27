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
    
    self.tvMain.rowHeight = UITableViewAutomaticDimension;
    self.tvMain.estimatedRowHeight = 140.0f;
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
    cell.tag = indexPath.row;
    cell.delegate = self;
    
    if(cell.showingOption){
        [cell showOption:NO];
    }
    else{
        [cell hideOption:NO];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayTweets.count;
}

#pragma mark - Action methods
- (void)tappedSearchIcon:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TweetTableViewCellDelegate

- (void)buttonTopTouched:(NSInteger)cellIndex{
    Tweet *tAux = [self.arrayTweets objectAtIndex:cellIndex];
    [self.arrayTweets removeObjectAtIndex:cellIndex];
    [self.arrayTweets insertObject:tAux atIndex:0];
    [self.tvMain moveRowAtIndexPath:[NSIndexPath indexPathForRow:cellIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}
- (void)buttonBottomTouched:(NSInteger)cellIndex{
    Tweet *tAux = [self.arrayTweets objectAtIndex:cellIndex];
    [self.arrayTweets removeObjectAtIndex:cellIndex];
    [self.arrayTweets addObject:tAux];
    [self.tvMain moveRowAtIndexPath:[NSIndexPath indexPathForRow:cellIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:self.arrayTweets.count-1 inSection:0]];
}
- (void)buttonRemoveTouched:(NSInteger)cellIndex{
    [self.arrayTweets removeObjectAtIndex:cellIndex];
    [self.tvMain deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cellIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}
- (void)beganShowOption:(NSInteger)cellIndex{
    UITableView *tableView = self.tvMain;
    NSArray *paths = [tableView indexPathsForVisibleRows];
    for (NSIndexPath *path in paths) {
        if(path.row != cellIndex){
            TweetTableViewCell *cell = [tableView cellForRowAtIndexPath:path];
            if(cell.showingOption){
                [cell hideOption:YES];
            }
        }
    }
}

@end
