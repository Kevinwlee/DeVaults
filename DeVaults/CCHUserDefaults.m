//
//  CCHUserDefaults.m
//  DeVaults
//
//  Created by Kevin Lee on 11/7/14.
//  Copyright (c) 2014 Kevin Lee. All rights reserved.
//

#import "CCHUserDefaults.h"
#define kVaultDefaultsKey @"_ch_vault_default"

@implementation CCHUserDefaults

+ (instancetype)sharedInstance {
    static CCHUserDefaults * __shared = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __shared = [[CCHUserDefaults alloc] init];
    });

    return __shared;
}

- (id)init {
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationLaunching) name:UIApplicationDidFinishLaunchingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationLaunching) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[CCHSubscriptionService sharedInstance] addSubscriptionsForTags:@[kVaultDefaultsKey] options:@[CCHOptionVault] completionHandler:^(NSError *error) {
            
        }];
        
        [self loadDefaultsFromDisk];
    }
    return self;
}

- (void)loadDefaultsFromDisk {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CCHDefaults" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];

    if (dict) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
    }
}

- (void)handleApplicationLaunching {
    [self fetchDefaultsWithCompletion:nil];
}

- (void)fetchDefaultsWithCompletion:(void(^)(NSUserDefaults *d, NSError *error))completionHandler {
    
    CCHVault *vault  = [CCHVault sharedInstance];

    [vault getItemsWithTags:@[kVaultDefaultsKey] operator:nil keyPath:nil value:nil completionHandler:^(NSArray *responses, NSError *error) {

        NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
        
        //Loop all the responses and set the keys, order is not guarenteed
        for (NSDictionary *dataDictionary in responses) {
            NSDictionary *vaultDefaults = [dataDictionary objectForKey:@"data"];
            [userDefaults setValuesForKeysWithDictionary:vaultDefaults];
        }
        
        //write to disk!
        [userDefaults synchronize];
        
        if (completionHandler) {
            completionHandler(userDefaults, error);
        }
        
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
