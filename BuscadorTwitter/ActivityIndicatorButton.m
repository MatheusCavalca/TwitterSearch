//
//  ActivityIndicatorButton.m
//  BuscadorTwitter
//
//  Created by Matheus Cavalca on 9/26/15.
//  Copyright © 2015 Matheus Cavalca. All rights reserved.
//

#import "ActivityIndicatorButton.h"

@implementation ActivityIndicatorButton
{
    DGActivityIndicatorView *activityIndicatorView;
}

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)presentActivityIndicator{
    activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeTriplePulse tintColor:[UIColor colorWithRed:94.0f/255.0f green:159.0f/255.0f blue:202.0f/255.0f alpha:.7f] size:self.frame.size.width];
    activityIndicatorView.frame = CGRectMake(20.0f, 20.0f, self.frame.size.width-40, self.frame.size.height-40);
    [self addSubview:activityIndicatorView];

    [self setImage:nil forState:UIControlStateNormal];
    [activityIndicatorView startAnimating];
}

- (void)hideActivityIndicator{
    [self setImage:[UIImage imageNamed:@"Icon_search_big"] forState:UIControlStateNormal];
    [activityIndicatorView stopAnimating];
    [activityIndicatorView removeFromSuperview];
}

@end
