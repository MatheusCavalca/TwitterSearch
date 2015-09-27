//
//  TweetTableViewCell.m
//  BuscadorTwitter
//
//  Created by Matheus Cavalca on 9/24/15.
//  Copyright © 2015 Matheus Cavalca. All rights reserved.
//

#import "TweetTableViewCell.h"

@implementation TweetTableViewCell
{
    CGRect lastLocation;
}

- (void)awakeFromNib {
    [self.buttonTop setImage:[UIImage imageNamed:@"icon_bt_up_on"] forState:UIControlStateHighlighted];
    [self.buttonBottom setImage:[UIImage imageNamed:@"icon_bt_down_on"] forState:UIControlStateHighlighted];
    [self.buttonRemove setImage:[UIImage imageNamed:@"icon_bt_remove_on"] forState:UIControlStateHighlighted];
    [self.buttonShare setImage:[UIImage imageNamed:@"icon_bt_share_on"] forState:UIControlStateHighlighted];
    
    UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanOnContentView:)];
    recognizer.delegate = self;
    [self.viewTweetContent setUserInteractionEnabled:YES];
    [self.viewTweetContent addGestureRecognizer:recognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - UIPanGestureRecognizer
- (void)handlePanOnContentView:(UIPanGestureRecognizer *)recognizer{
    CGPoint translation = [recognizer translationInView:self.contentView];
    
    if(recognizer.state == UIGestureRecognizerStateBegan){
        [self.delegate beganShowOption:self.tag];
        lastLocation = self.viewTweetContent.frame;
    }
    if(recognizer.state == UIGestureRecognizerStateEnded){
        [UIView animateWithDuration:0.3f animations:^{
            if(lastLocation.origin.x + translation.x > self.frame.size.width*0.3){
                [self showOption:YES];
            }
            else{
                [self hideOption:YES];
            }
        }];
        return;
    }
    
    if(lastLocation.origin.x + translation.x > self.frame.size.width*0.8){
        CGRect currentFrame = lastLocation;
        currentFrame.origin.x = self.frame.size.width*0.8;
        self.viewTweetContent.frame = currentFrame;
    }
    else if(lastLocation.origin.x + translation.x <= 0){
        CGRect currentFrame = lastLocation;
        currentFrame.origin.x = 0;
        self.viewTweetContent.frame = currentFrame;
    }
    else{
        CGRect currentFrame = lastLocation;
        currentFrame.origin.x = lastLocation.origin.x + translation.x;
        self.viewTweetContent.frame = currentFrame;
    }
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:[self superview]];
        // Check for horizontal gesture
        if (fabs(translation.x) > fabs(translation.y)) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Auxiliar methods
- (void)showOption:(BOOL)animated{
    self.showingOption = YES;
    float animationDuration = 0.0f;
    if(animated) animationDuration = 0.3f;
    [UIView animateWithDuration:animationDuration animations:^{
        CGRect currentFrame = lastLocation;
        currentFrame.origin.x = self.frame.size.width*0.8;
        self.viewTweetContent.frame = currentFrame;
    }];
}

- (void)hideOption:(BOOL)animated{
    self.showingOption = NO;
    float animationDuration = 0.0f;
    if(animated) animationDuration = 0.3f;
    [UIView animateWithDuration:animationDuration animations:^{
        CGRect currentFrame = lastLocation;
        currentFrame.origin.x = 0;
        self.viewTweetContent.frame = currentFrame;
    }];
}

#pragma mark - Action methods
- (IBAction)buttonTopTouched:(id)sender {
    [self.delegate buttonTopTouched:[self tag]];
}

- (IBAction)buttonBottomTouched:(id)sender {
    [self.delegate buttonBottomTouched:[self tag]];
}

- (IBAction)buttonRemoveTouched:(id)sender {
    [self.delegate buttonRemoveTouched:[self tag]];
}
- (IBAction)buttonShareTouched:(id)sender {
    [self.delegate buttonShareTouched:[self tag]];
}
@end
