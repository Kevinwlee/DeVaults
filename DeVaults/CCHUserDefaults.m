//
//  CCHUserDefaults.m
//  DeVaults
//
//  Created by Kevin Lee on 11/7/14.
//  Copyright (c) 2014 Kevin Lee. All rights reserved.
//

#import "CCHUserDefaults.h"
#define kVaultDefaultsKey @"_ch_vault_default"
#define kDefaultPlist @"CCHDefaults"

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
        //Listen for changes to the DeVault Data
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleVaultUpdate:) name:CCHVaultItemUpdatedNotification object:nil];

        [self loadDefaultsFromDisk];
    }

    return self;
}

- (void)loadDefaultsFromDisk {
    
    //Subscription for DeVault Tag
    [[CCHSubscriptionService sharedInstance] addSubscriptionsForTags:@[kVaultDefaultsKey] options:@[CCHOptionVault] completionHandler:^(NSError *error) {
        
    }];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:kDefaultPlist ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];

    if (dict) {
        //Register populates a "temp" in memory version of NSUserDefaults
        [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
    }

}


- (void)fetchDefaultsWithCompletion:(void(^)(NSUserDefaults *defaults, NSError *error))completionHandler {
    
    CCHVault *vault  = [CCHVault sharedInstance];

    [vault getItemsWithTags:@[kVaultDefaultsKey] keyPath:nil value:nil completionHandler:^(NSArray *responses, NSError *error) {

        NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
        
        //Loop all the responses and set the keys
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

- (void)updateDefaultsWithPush:(CCHContextHubPush *)contextHubPush completion:(void(^)())completionHandler {
    
    NSString *resource = [contextHubPush.userInfo valueForKey:@"resource"];

    if ([resource isEqualToString:@"Vault"]) {
        NSArray *tags = [contextHubPush.object valueForKeyPath:@"vault_info.tags"];
        
        if ([tags containsObject:kVaultDefaultsKey]) {
            NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
            
            NSDictionary *vaultDefaults = [contextHubPush.object objectForKey:@"data"];
            [userDefaults setValuesForKeysWithDictionary:vaultDefaults];
            
            //write to disk!
            [userDefaults synchronize];
            
            if (completionHandler) {
                completionHandler();
            }

        } else {
            //Not a default change
            if (completionHandler) {
                completionHandler();
            }
        }
    } else {
        completionHandler();
    }
}

- (void)handleVaultUpdate:(NSNotification *)notification {
    
    NSArray *tags = [notification.object valueForKeyPath:@"vault_info.tags"];
    if ([tags containsObject:kVaultDefaultsKey]) {
        NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
        
        NSDictionary *vaultDefaults = [notification.object objectForKey:@"data"];
        [userDefaults setValuesForKeysWithDictionary:vaultDefaults];
        
        //write to disk!
        [userDefaults synchronize];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
