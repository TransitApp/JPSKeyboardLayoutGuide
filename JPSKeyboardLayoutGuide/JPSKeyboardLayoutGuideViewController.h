//
//  JPSKeyboardLayoutGuideViewController.h
//  JPSKeyboardLayoutGuide
//
//  Created by JP Simard on 2014-03-26.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (JPSKeyboardLayoutGuideViewController)

- (void)jps_viewDidLoad;
- (void)jps_viewWillAppear:(BOOL)animated;
- (void)jps_viewDidDisappear:(BOOL)animated;

- (void)jps_keyboardDidShow:(NSNotification *)notification;
- (void)jps_keyboardWillHide:(NSNotification *)notification;

@property (nonatomic, strong) UILayoutGuide *keyboardLayoutGuide;

@end
