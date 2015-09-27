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
    UIActivityIndicatorView *activityIndicator;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGFloat halfButtonHeight = self.bounds.size.height/2;
    CGFloat halfButtonWidth = self.bounds.size.width/2;
    [self addSubview:activityIndicator];
    activityIndicator.center = CGPointMake(halfButtonWidth , halfButtonHeight);
}

- (void)presentActivityIndicator{
    [self setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [activityIndicator startAnimating];
}

- (void)hideActivityIndicator{
    [self setImage:[UIImage imageNamed:@"Icon_search_big"] forState:UIControlStateNormal];
    [activityIndicator stopAnimating];
}

@end
