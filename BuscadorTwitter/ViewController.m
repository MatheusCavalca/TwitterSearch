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
    float defaultTxtQueryWidth;
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
    self.txtQuery.delegate = self;
    
    [self.tvLastResearches registerNib:[UINib nibWithNibName:@"SearchesAndTrendsTableViewCell" bundle:nil] forCellReuseIdentifier:@"SearchAndTrendCellIdentifier"];
    [self.tvLastResearches setDelegate:self];
    [self.tvLastResearches setDataSource:self];
    [self.tvTrends registerNib:[UINib nibWithNibName:@"SearchesAndTrendsTableViewCell" bundle:nil] forCellReuseIdentifier:@"SearchAndTrendCellIdentifier"];
    [self.tvTrends setDelegate:self];
    [self.tvTrends setDelegate:self];
    
    self.viewQuery.userInteractionEnabled = YES;
    UITapGestureRecognizer *vTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tappedViewTvs:)];
    [vTapGesture setDelegate:self];
    [self.viewQuery addGestureRecognizer:vTapGesture];
    
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *mvTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tappedMainView:)];
    [mvTapGesture setDelegate:self];
    [self.view addGestureRecognizer:mvTapGesture];
    
    arrayTweets = [[NSMutableArray alloc] init];
    arrayTrends = [[NSMutableArray alloc] init];
    
    self.txtQuery.placeholder = NSLocalizedString(@"SEARCH_IT", nil);
    [self.btLogin setTitle: NSLocalizedString(@"LOG_IN", nil) forState:UIControlStateNormal];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.viewTvs.frame.size.height/8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SearchesAndTrendsHeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"SearchesAndTrendsHeaderView" owner:self options:nil] objectAtIndex:0];
    if(tableView == self.tvLastResearches){
        headerView.labelTitle.text = NSLocalizedString(@"RECENT_SEARCHES",nil);
    }
    else{
        headerView.labelTitle.text = NSLocalizedString(@"TRENDING_NOW",nil);
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

#pragma mark - Auxiliar Methods
- (CGFloat)widthForText:(NSString *)text withFontSize:(CGFloat)txtSize
{
    CGSize maxSize = CGSizeMake(self.view.frame.size.width - 150, CGFLOAT_MAX);
    if (!text) {
        text = @"";
    }
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont systemFontOfSize:txtSize], NSFontAttributeName,
                                          [UIColor darkGrayColor], NSForegroundColorAttributeName,
                                          nil];
    CGRect textRect = [text boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)  attributes:attributesDictionary context:nil];
    NSInteger widthAsInt = (NSInteger) roundf(textRect.size.width) + 1;
    return widthAsInt;
}

#pragma mark - Twitter API and parser
- (void)executeSearchTweetQuery{
    NSString *strSearch = self.txtQuery.text;
    
    // convert to a data object, using a lossy conversion to ASCII
    NSData *asciiEncoded = [strSearch dataUsingEncoding:NSASCIIStringEncoding
                             allowLossyConversion:YES];
    // take the data object and recreate a string using the lossy conversion
    strSearch = [[NSString alloc] initWithData:asciiEncoded
                                            encoding:NSASCIIStringEncoding];
    
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
                 NSError *jsonError;
                 NSDictionary *json = [NSJSONSerialization
                                       JSONObjectWithData:data
                                       options:0
                                       error:&jsonError];
                 [self parseSearchTweetResponseWithData:json];
                 if(arrayTweets.count > 0){
                     [self requestProfilePicture:^(BOOL successOperation) {
                         [RecentSearches storeRecentSearch: self.txtQuery.text];
                         [self.view setUserInteractionEnabled:YES];
                         [self.btSearch hideActivityIndicator];
                         [self performSegueWithIdentifier:@"SegueResults" sender:self];
                     }];
                 }
                 else{
                     [self.view setUserInteractionEnabled:YES];
                     [self.btSearch hideActivityIndicator];
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
    //clear array before add current objects
    [arrayTweets removeAllObjects];
    
    NSArray *statuses = jsonResponse[@"statuses"];
    for(NSDictionary *dic in statuses){
        NSDictionary *dicUser = dic[@"user"];
        Tweet *newTweet = [[Tweet alloc] initWithProfileName:dicUser[@"name"] text:dic[@"text"] tweetID:[NSString stringWithFormat:@"%@",dic[@"id"]] andProfilePictureUrl:dicUser[@"profile_image_url_https"]];
        [arrayTweets addObject:newTweet];
    }
}

- (void)executeTrendsQuery:(void(^)(BOOL successOperation))completion{
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
    //clear array before add current objects
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

#pragma mark - Action methods
- (IBAction)btLoginTwitterTouched:(id)sender {
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {
            NSLog(@"signed in as %@", [session userName]);
        } else {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
}

- (IBAction)btSearchTouched:(id)sender {
    [self.btSearch presentActivityIndicator];
    [self.view setUserInteractionEnabled:NO];
    [self executeSearchTweetQuery];
    [self.txtQuery resignFirstResponder];
}

- (void)tappedViewTvs:(id)sender{
    [self.txtQuery becomeFirstResponder];
}

- (void)tappedMainView:(id)sender{
    [self.txtQuery resignFirstResponder];
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

#pragma mark - UITextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(defaultTxtQueryWidth == 0){
        defaultTxtQueryWidth = self.txtQuery.frame.size.width;
    }
    
    NSString *strReplaced = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSDictionary *attributes = @{NSFontAttributeName: self.txtQuery.font};
    CGSize newSize = [strReplaced sizeWithAttributes:attributes];
    
    //using this to give more space to text
    float correctNewWidth = newSize.width + 15;
    float correctMaxWidth = self.view.frame.size.width - self.btSearch.frame.size.width*2.5;
    // assign new size
    if(correctNewWidth > correctMaxWidth){
        self.searchTextFieldWidthConstraint.constant = correctMaxWidth;
    }
    else if(correctNewWidth < defaultTxtQueryWidth){
        self.searchTextFieldWidthConstraint.constant = defaultTxtQueryWidth;
    }
    else{
        self.searchTextFieldWidthConstraint.constant = correctNewWidth;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.btSearch presentActivityIndicator];
    [self.view setUserInteractionEnabled:NO];
    [self executeSearchTweetQuery];
    [self.txtQuery resignFirstResponder];
    return YES;
}

#pragma mark - Keyboard notifications

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
