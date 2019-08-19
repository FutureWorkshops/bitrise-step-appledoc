//
//  ViewController.h
//  AppleDocTest
//
//  Created by Igor Ferreira on 19/08/2019.
//  Copyright © 2019 Future Workshops. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 Basic View Controller created by Xcode's template
 */
@interface ViewController : UIViewController


/**
 This is a sample of method without parameter
 */
- (void) testMethod;


/**
 This is a sample of method with parameter

 @param input Any string
 @return Always true
 */
- (BOOL) validString:(NSString *)input;

@end

