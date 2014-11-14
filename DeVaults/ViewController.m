//
//  ViewController.m
//  DeVaults
//
//  Created by Kevin Lee on 11/7/14.
//  Copyright (c) 2014 Kevin Lee. All rights reserved.
//

#import "ViewController.h"
#import "CCHUserDefaults.h"

@interface ViewController ()

@property (nonatomic, strong) NSString *currentVersion;

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UILabel *label5;
@property (weak, nonatomic) IBOutlet UILabel *label6;
@property (weak, nonatomic) IBOutlet UIButton *upgradeButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentVersion = @"1";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDefaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
    
    [self layoutLablesWithDefaults:[NSUserDefaults standardUserDefaults]];
}

- (void)handleDefaultsChanged:(NSNotification *)notification {
    NSUserDefaults *defaults = notification.object;
    [self layoutLablesWithDefaults:defaults];
}

- (void)layoutLablesWithDefaults:(NSUserDefaults *)defaults {
    self.label1.text = [defaults valueForKey:@"key1"];
    self.label2.text = [defaults valueForKey:@"key2"];
    self.label3.text = [defaults valueForKey:@"key3"];
    self.label4.text = [defaults valueForKey:@"key4"];
    self.label5.text = [defaults valueForKey:@"key5"];
    self.label6.text = [defaults valueForKey:@"key6"];
    
    NSString *value1 = [defaults stringForKey:@"key1"];
    if ([value1 isEqualToString:@"red"]) {
        [self.view setBackgroundColor:[UIColor redColor]];
    } else if ([value1 isEqualToString:@"blue"]) {
        [self.view setBackgroundColor:[UIColor blueColor]];
    } else {
        [self.view setBackgroundColor:[UIColor whiteColor]];
    }
    
    NSString *currentVersion = [defaults valueForKey:@"current_version"];
    BOOL isCurrent =[currentVersion isEqualToString:self.currentVersion];
    [self.upgradeButton setHidden:isCurrent];
    
}

- (IBAction)upgradeTapped:(id)sender {
    NSLog(@"Upgrade Tapped");
    [self.upgradeButton setTitle:@"Upgraded" forState:UIControlStateNormal];
}

- (IBAction)sendPushTapped:(id)sender {
    [[CCHPush sharedInstance] sendNotificationToTags:@[@"davault-user"] userInfo:@{@"alert":@"Hello World!"} completionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        } else {
            NSLog(@"No Error to Tags");
        }        
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
