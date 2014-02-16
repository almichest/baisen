//
//  CRSocialUtility.h
//  CoffeeRoastLogger
//
//  Created by OhnoHiraku on 2014/02/16.
//  Copyright (c) 2014年 Hiraku Ohno. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, CRSocialUtilitySharingResult)
{
    CRSocialUtilitySharingResultSuccess,
    CRSocialUtilitySharingResultFailure,
};

@interface CRSocialUtility : NSObject

typedef void (^CRSocialUtilityCompletion)(CRSocialUtilitySharingResult result);

+ (void)showTwitterPostViewWithMessage:(NSString *)message image:(UIImage *)image onViewController:(UIViewController *)viewController completion:(CRSocialUtilityCompletion)completion;
+ (void)showFacebookPostViewWithMessage:(NSString *)message image:(UIImage *)image onViewController:(UIViewController *)viewController completion:(CRSocialUtilityCompletion)completion;
@end
