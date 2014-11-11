//
//  CCHUserDefaults.h
//  DeVaults
//
//  Created by Kevin Lee on 11/7/14.
//  Copyright (c) 2014 Kevin Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ContextHub/ContextHub.h>

@interface CCHUserDefaults : NSObject

+ (instancetype)sharedInstance;

- (void)fetchDefaultsWithCompletion:(void(^)(NSUserDefaults *d, NSError *error))completionHandler;

@end
