//
//  TweetTableViewCell.h
//  BuscadorTwitter
//
//  Created by Matheus Cavalca on 9/24/15.
//  Copyright © 2015 Matheus Cavalca. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TweetTableViewCellDelegate
- (void)buttonTopTouched:(NSInteger)cellIndex;
- (void)buttonBottomTouched:(NSInteger)cellIndex;
- (void)buttonRemoveTouched:(NSInteger)cellIndex;
- (void)buttonShareTouched:(NSInteger)cellIndex;
- (void)beganShowOption:(NSInteger)cellIndex;
@end

@interface TweetTableViewCell : UITableViewCell<UIGestureRecognizerDelegate>

@property(nonatomic, weak) id<TweetTableViewCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *viewTweetContent;
@property (strong, nonatomic) IBOutlet UIImageView *imgProfilePicture;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblMessage;

@property BOOL showingOption;
@property (strong, nonatomic) IBOutlet UIButton *buttonTop;
@property (strong, nonatomic) IBOutlet UIButton *buttonBottom;
@property (strong, nonatomic) IBOutlet UIButton *buttonRemove;
@property (strong, nonatomic) IBOutlet UIButton *buttonShare;

- (void)showOption:(BOOL)animated;
- (void)hideOption:(BOOL)animated;

@end
