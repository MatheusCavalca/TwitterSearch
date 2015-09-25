//
//  RecentSearches.m
//  BuscadorTwitter
//
//  Created by Matheus Cavalca on 9/24/15.
//  Copyright © 2015 Matheus Cavalca. All rights reserved.
//

#import "RecentSearches.h"

@implementation RecentSearches

+ (NSArray*)loadFiveRecentSearches{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSArray *recenteSearches = [pref objectForKey:@"recent_searches"];
    NSArray *fiveRecentSearches = [recenteSearches subarrayWithRange:NSMakeRange(0, MIN(recenteSearches.count, 5))];
    return fiveRecentSearches;
}

+ (void)storeRecentSearch:(NSString*)recentSearch{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recenteSearches = [[NSMutableArray alloc] initWithArray:[pref objectForKey:@"recent_searches"]];
    [recenteSearches insertObject:recentSearch atIndex:0];
    [pref setObject:recenteSearches forKey:@"recent_searches"];
    [pref synchronize];
}

@end
