//
//  ViewController.m
//  AppleDocTest
//
//  Created by Igor Ferreira on 19/08/2019.
//  Copyright © 2019 Future Workshops. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


/**
 This is an example of documented private method
 */
- (void) _privateMethod {}

- (void)testMethod {}

- (BOOL)validString:(NSString *)input {
    return YES;
}

@end
