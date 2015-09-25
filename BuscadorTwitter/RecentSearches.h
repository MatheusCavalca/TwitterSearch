//
//  RecentSearches.h
//  BuscadorTwitter
//
//  Created by Matheus Cavalca on 9/24/15.
//  Copyright © 2015 Matheus Cavalca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentSearches : NSObject

+ (NSArray*)loadFiveRecentSearches;
+ (void)storeRecentSearch:(NSString*)recentSearch;

@end
