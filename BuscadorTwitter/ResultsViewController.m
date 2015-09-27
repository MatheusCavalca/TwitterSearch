//
//  ResultsViewController.m
//  BuscadorTwitter
//
//  Created by Matheus Cavalca on 9/24/15.
//  Copyright © 2015 Matheus Cavalca. All rights reserved.
//

#import "ResultsViewController.h"

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

#pragma marl - Auxiliar methods
- (void)executeSearchTweetQuery:(Tweet*)tweetToShare{
    NSString *strURL = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/retweet/%@.json", tweetToShare.tweetID];
    NSDictionary *params = @{};
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                             URLRequestWithMethod:@"POST"
                             URL:strURL
                             parameters:params
                             error:&clientError];
    if (request) {
        [[[Twitter sharedInstance] APIClient]
         sendTwitterRequest:request
         completion:^(NSURLResponse *response,
                      NSData *data,
                      NSError *connectionError) {
             if (data) {
                 // handle the response data e.g.
                 NSError *jsonError;
                 NSDictionary *json = [NSJSONSerialization
                                       JSONObjectWithData:data
                                       options:0
                                       error:&jsonError];
                  NSLog(@"%@", json);
             }
             else {
                 NSLog(@"Error: %@", connectionError);
                 [self presentLoginAlertView];
             }
         }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }
}

- (void)presentLoginAlertView{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"NOT_ALLOWED", nil) message:NSLocalizedString(@"PLEASE_LOGIN_FIRST", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)hideOptionsForCellsBut:(NSInteger)cellIndex{
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

#pragma mark - UITableView DataSource/Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Tweet *currentTweet = (Tweet*)[self.arrayTweets objectAtIndex:indexPath.row];
    TweetTableViewCell *cell;
    if(currentTweet.mediaPicture){
        cell = [tableView dequeueReusableCellWithIdentifier:@"TweetWithMediaCellIdentifier"];
        ((TweetWithMediaUITableViewCell*)cell).imgMediaPicture.image = currentTweet.mediaPicture;
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCellIdentifier"];
    }
    cell.lblName.text = currentTweet.profileName;
    cell.lblMessage.text = currentTweet.text;
    if(currentTweet.profilePicture){
        cell.imgProfilePicture.image = currentTweet.profilePicture;
    }
    cell.imgProfilePicture.layer.cornerRadius = cell.imgProfilePicture.frame.size.height/2;
    cell.imgProfilePicture.clipsToBounds = YES;
    cell.tag = indexPath.row;
    cell.delegate = self;
    [cell hideOption:NO];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayTweets.count;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self hideOptionsForCellsBut:-1];
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
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.tvMain reloadData];
    }];
    [self.tvMain moveRowAtIndexPath:[NSIndexPath indexPathForRow:cellIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [CATransaction commit];
}

- (void)buttonBottomTouched:(NSInteger)cellIndex{
    Tweet *tAux = [self.arrayTweets objectAtIndex:cellIndex];
    [self.arrayTweets removeObjectAtIndex:cellIndex];
    [self.arrayTweets addObject:tAux];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.tvMain reloadData];
    }];
    [self.tvMain moveRowAtIndexPath:[NSIndexPath indexPathForRow:cellIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:self.arrayTweets.count-1 inSection:0]];
        
    [CATransaction commit];
}

- (void)buttonRemoveTouched:(NSInteger)cellIndex{
    [self.arrayTweets removeObjectAtIndex:cellIndex];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
    [self.tvMain reloadData];
    }];
    [self.tvMain deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cellIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [CATransaction commit];
}

- (void)buttonShareTouched:(NSInteger)cellIndex{
    [self executeSearchTweetQuery:self.arrayTweets[cellIndex]];
    [self hideOptionsForCellsBut:cellIndex];
}

- (void)beganShowOption:(NSInteger)cellIndex{
    [self hideOptionsForCellsBut:cellIndex];
}

@end
