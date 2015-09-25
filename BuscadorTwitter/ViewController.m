//
//  ViewController.m
//  BuscadorTwitter
//
//  Created by Matheus Cavalca on 9/23/15.
//  Copyright © 2015 Matheus Cavalca. All rights reserved.
//

#import "ViewController.h"

#define MAIN_ROW_HEIGHT 40
@interface ViewController ()

@end

@implementation ViewController
{
    NSMutableArray *arrayTrends;
    NSArray *arrayLastSearches;
    
    NSMutableArray *arrayTweets;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tvLastResearches registerNib:[UINib nibWithNibName:@"SearchesAndTrendsTableViewCell" bundle:nil] forCellReuseIdentifier:@"SearchAndTrendCellIdentifier"];
    [self.tvLastResearches setDelegate:self];
    [self.tvLastResearches setDataSource:self];
    [self.tvTrends registerNib:[UINib nibWithNibName:@"SearchesAndTrendsTableViewCell" bundle:nil] forCellReuseIdentifier:@"SearchAndTrendCellIdentifier"];
    [self.tvTrends setDelegate:self];
    [self.tvTrends setDelegate:self];
    
    self.imgSearchIcon.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tappedSearchIcon:)];
    [tapGesture1 setDelegate:self];
    [self.imgSearchIcon addGestureRecognizer:tapGesture1];
    
    arrayTweets = [[NSMutableArray alloc] init];
    arrayTrends = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    arrayLastSearches = [RecentSearches loadFiveRecentSearches];
    [self.tvLastResearches reloadData];
    
    //TODO: get trends
    [self executeTrendsQuery:^(BOOL successOperation) {
        [self.tvTrends reloadData];
    }];
    
}

#pragma mark - UITableView DataSource/Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tvLastResearches.frame.size.width, MAIN_ROW_HEIGHT)];
    
    UIView *blueSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tvLastResearches.frame.size.width, 4)];
    blueSeparator.backgroundColor = [UIColor colorWithRed:94.0f/255.0f green:159.0f/255.0f blue:202.0f/255.0f alpha:1.0f];
    [headerView addSubview:blueSeparator];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.tvLastResearches.frame.size.width, MAIN_ROW_HEIGHT)];
    if(tableView == self.tvLastResearches){
        lblTitle.text = @"Recent Searches";
    }
    else{
        lblTitle.text = @"Trending Now";
    }
    lblTitle.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
    lblTitle.textColor = [UIColor colorWithRed:94.0f/255.0f green:159.0f/255.0f blue:202.0f/255.0f alpha:1.0f];
    [headerView addSubview:lblTitle];

    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchesAndTrendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchAndTrendCellIdentifier"];
    if(tableView == self.tvLastResearches){
        cell.lblTitle.text = [arrayLastSearches objectAtIndex:indexPath.row];
    }
    else{
        cell.lblTitle.text = [arrayTrends objectAtIndex:indexPath.row];
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == self.tvLastResearches){
        return arrayLastSearches.count;
    }
    else{
        return arrayTrends.count;
    }
}

#pragma mark - Twitter API and parser
- (void)executeSearchTweetQuery{
    NSString *strSearch = self.txtQuery.text;
    strSearch = [strSearch stringByReplacingOccurrencesOfString:@" "
                                                     withString:@"%20"];
    strSearch = [strSearch stringByReplacingOccurrencesOfString:@"@"
                                                     withString:@"%40"];
    strSearch = [strSearch stringByReplacingOccurrencesOfString:@"\""
                                                     withString:@"%22"];
    
    NSString *statusesShowEndpoint = [NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.json?q=%@", strSearch];
    
    NSDictionary *params = @{};
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                             URLRequestWithMethod:@"GET"
                             URL:statusesShowEndpoint
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
//                 NSLog(@"%@", json);
                 [self parseSearchTweetResponseWithData:json];
                 [self requestProfilePicture:^(BOOL successOperation) {
                     [RecentSearches storeRecentSearch: self.txtQuery.text];
                     [self performSegueWithIdentifier:@"SegueResults" sender:self];
                     [self.view setUserInteractionEnabled:YES];
                 }];
             }
             else {
                 NSLog(@"Error: %@", connectionError);
             }
         }];
    }
    else {
        NSLog(@"Error: %@", clientError);
    }
}

- (void)parseSearchTweetResponseWithData:(NSDictionary*)jsonResponse{
    //clean array before add current objects
    [arrayTweets removeAllObjects];
    
    NSArray *statuses = jsonResponse[@"statuses"];
    for(NSDictionary *dic in statuses){
        NSDictionary *dicUser = dic[@"user"];
        Tweet *newTweet = [[Tweet alloc] initWithProfileName:dicUser[@"name"] text:dic[@"text"] andProfilePictureUrl:dicUser[@"profile_image_url_https"]];
        [arrayTweets addObject:newTweet];
    }
}

- (void)executeTrendsQuery:(void(^)(BOOL successOperation))completion{
    NSString *strSearch = self.txtQuery.text;
    strSearch = [strSearch stringByReplacingOccurrencesOfString:@" "
                                                     withString:@"%20"];
    strSearch = [strSearch stringByReplacingOccurrencesOfString:@"@"
                                                     withString:@"%40"];
    strSearch = [strSearch stringByReplacingOccurrencesOfString:@"\""
                                                     withString:@"%22"];
    
    NSString *statusesShowEndpoint = [NSString stringWithFormat:@"https://api.twitter.com/1.1/trends/place.json?id=1"];
    
    NSDictionary *params = @{};
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                             URLRequestWithMethod:@"GET"
                             URL:statusesShowEndpoint
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
                 [self parseTrendsWithData:json];
                 completion(YES);
             }
             else {
                 NSLog(@"Error: %@", connectionError);
             }
         }];
    }
    else {
        NSLog(@"Error: %@", clientError);
        completion(NO);
    }
}

- (void)parseTrendsWithData:(NSDictionary*)jsonResponse{
    //clean array before add current objects
    [arrayTrends removeAllObjects];
    
    NSDictionary *arrayJson = [((NSArray*)jsonResponse) objectAtIndex:0];
    NSArray *trends = arrayJson[@"trends"];
    for(int i=0; i<5; i++){
        if(trends.count > i){
            NSDictionary *dic = [trends objectAtIndex: i];
            [arrayTrends addObject:dic[@"name"]];
        }
    }
}


- (void)requestProfilePicture:(void(^)(BOOL successOperation))completion{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    for(Tweet *tweet in arrayTweets){
        NSURL *pictureURL = [NSURL URLWithString:tweet.pictureURL];
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:pictureURL completionHandler:^(NSData *data, NSURLResponse *response,NSError *error) {
            if (!error) {
                tweet.profilePicture = [UIImage imageWithData:data];
                dispatch_semaphore_signal(semaphore);
            }
            else{
                dispatch_semaphore_signal(semaphore);
            }
        }] resume];
    }

    for(int i=0; i<arrayTweets.count; i++){
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    completion(true);
}

- (void)twitterLoginButton{
    //    TWTRLogInButton *logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession *session, NSError *error) {
    // play with Twitter session
    
    //    }];
    //    logInButton.center = self.view.center;
    //    [self.view addSubview:logInButton];
}

#pragma mark - Action methods
- (void)tappedSearchIcon:(id)sender{
    [self.view setUserInteractionEnabled:NO];
    [self executeSearchTweetQuery];
}

#pragma mark - Navigation Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SegueResults"]) {
        ResultsViewController *destination = segue.destinationViewController;
        destination.arrayTweets = arrayTweets;
    }
}

@end
