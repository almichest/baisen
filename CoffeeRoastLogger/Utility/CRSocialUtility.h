//
//  CRSocialUtility.h
//  CoffeeRoastLogger
//
//  Created by OhnoHiraku on 2014/02/16.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRSocialUtility : NSObject

+ (void)showTwitterPostViewWithMessage:(NSString *)message onViewController:(UIViewController *)viewController;
+ (void)showFacebookPostViewWithMessage:(NSString *)message onViewController:(UIViewController *)viewController;
@end
