//
//  ActivityIndicatorButton.h
//  BuscadorTwitter
//
//  Created by Matheus Cavalca on 9/26/15.
//  Copyright © 2015 Matheus Cavalca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGActivityIndicatorView.h"

@interface ActivityIndicatorButton : UIButton

- (void)presentActivityIndicator;
- (void)hideActivityIndicator;

@end
