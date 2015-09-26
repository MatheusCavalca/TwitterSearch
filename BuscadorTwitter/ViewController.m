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
    float offsetTwitterHeigth;
    
    BOOL alreadyAppearedOnce;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Keyboard segment
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self.tvLastResearches registerNib:[UINib nibWithNibName:@"SearchesAndTrendsTableViewCell" bundle:nil] forCellReuseIdentifier:@"SearchAndTrendCellIdentifier"];
    [self.tvLastResearches setDelegate:self];
    [self.tvLastResearches setDataSource:self];
    [self.tvTrends registerNib:[UINib nibWithNibName:@"SearchesAndTrendsTableViewCell" bundle:nil] forCellReuseIdentifier:@"SearchAndTrendCellIdentifier"];
    [self.tvTrends setDelegate:self];
    [self.tvTrends setDelegate:self];
    
    self.viewTvs.userInteractionEnabled = YES;
    UITapGestureRecognizer *vTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tappedViewTvs:)];
    [vTapGesture setDelegate:self];
    [self.viewTvs addGestureRecognizer:vTapGesture];
    
    arrayTweets = [[NSMutableArray alloc] init];
    arrayTrends = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if(alreadyAppearedOnce){
        [self.txtQuery becomeFirstResponder];
    }
    alreadyAppearedOnce = true;
    
    arrayLastSearches = [RecentSearches loadFiveRecentSearches];
    [self.tvLastResearches reloadData];
    
    [self executeTrendsQuery:^(BOOL successOperation) {
        [self.tvTrends reloadData];
    }];
    
}

#pragma mark - UITableView DataSource/Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SearchesAndTrendsHeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"SearchesAndTrendsHeaderView" owner:self options:nil] objectAtIndex:0];
    if(tableView == self.tvLastResearches){
        headerView.labelTitle.text = @"Recent Searches";
    }
    else{
        headerView.labelTitle.text = @"Trending Now";
    }

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
    strSearch = [strSearch stringByReplacingOccurrencesOfString:@"#"
                                                     withString:@"%23"];
    
    NSString *strURL = [NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.json?q=%@", strSearch];
    
    NSDictionary *params = @{};
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                             URLRequestWithMethod:@"GET"
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
//                 NSLog(@"%@", json);
                 [self parseSearchTweetResponseWithData:json];
                 if(arrayTweets.count > 0){
                     [self requestProfilePicture:^(BOOL successOperation) {
                         [RecentSearches storeRecentSearch: self.txtQuery.text];
                         [self.view setUserInteractionEnabled:YES];
                         [self.btSearch hideActivityIndicator];
                         [self performSegueWithIdentifier:@"SegueResults" sender:self];
                     }];
                 }
             }
             else {
                 NSLog(@"Error: %@", connectionError);
                 [self.view setUserInteractionEnabled:YES];
                 [self.btSearch hideActivityIndicator];
             }
         }];
    }
    else {
        NSLog(@"Error: %@", clientError);
        [self.view setUserInteractionEnabled:YES];
        [self.view setUserInteractionEnabled:YES];
        [self.btSearch hideActivityIndicator];
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
        NSString *strHighQualityPicture = [tweet.pictureURL stringByReplacingOccurrencesOfString: @"_normal" withString: @""];
        NSURL *pictureURL = [NSURL URLWithString:strHighQualityPicture];
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

- (IBAction)btSearchTouched:(id)sender {
    [self.btSearch presentActivityIndicator];
    [self.view setUserInteractionEnabled:NO];
    [self executeSearchTweetQuery];
    [self.txtQuery resignFirstResponder];
}

- (void)tappedViewTvs:(id)sender{
    [self.txtQuery becomeFirstResponder];
}

#pragma mark - Navigation Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SegueResults"]) {
        ResultsViewController *destination = segue.destinationViewController;
        destination.arrayTweets = arrayTweets;
        destination.querySearched = self.txtQuery.text;
    }
}

#pragma mark - keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameBegin CGRectValue];
    CGSize keyboardSize = keyboardFrame.size;
    
    if(offsetTwitterHeigth==0.0){
        offsetTwitterHeigth = self.twitterLogoBottomConstraint.constant;
    }
    
    self.twitterLogoBottomConstraint.constant = -keyboardSize.height/1.3 + offsetTwitterHeigth;
    self.SearchViewConstraintCenterY.constant = -keyboardSize.height/1.3;
    self.viewTvs.alpha = 0.0f;
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.viewTvs.alpha = 1.0f;
    self.SearchViewConstraintCenterY.constant = 0;
    self.twitterLogoBottomConstraint.constant = offsetTwitterHeigth;
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
