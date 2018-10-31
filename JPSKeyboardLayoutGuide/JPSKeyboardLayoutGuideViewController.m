//
//  JPSKeyboardLayoutGuideViewController.m
//  JPSKeyboardLayoutGuide
//
//  Created by JP Simard on 2014-03-26.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

#import "JPSKeyboardLayoutGuideViewController.h"

#import <objc/runtime.h>

@interface UIViewController (JPSKeyboardLayoutGuideViewController_Internal)

@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;

@end

@implementation UIViewController (JPSKeyboardLayoutGuideViewController)

- (void)setBottomConstraint:(NSLayoutConstraint *)bottomConstraint {
    objc_setAssociatedObject(self, @selector(bottomConstraint), bottomConstraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSLayoutConstraint *)bottomConstraint {
    return objc_getAssociatedObject(self, @selector(bottomConstraint));
}

-(void)setKeyboardLayoutGuide:(id<UILayoutSupport>)keyboardLayoutGuide{
    objc_setAssociatedObject(self, @selector(keyboardLayoutGuide), keyboardLayoutGuide, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id<UILayoutSupport>)keyboardLayoutGuide{
    return objc_getAssociatedObject(self, @selector(keyboardLayoutGuide));
}

#pragma mark - View Lifecycle

-(void)_createKeyboardLayoutGuide
{
    self.keyboardLayoutGuide = [UILayoutGuide new];
    [self.view addLayoutGuide:self.keyboardLayoutGuide];
}

- (void)jps_viewDidLoad {
    [self _createKeyboardLayoutGuide];
    [self setupKeyboardLayoutGuide];
}

- (void)jps_viewWillAppear:(BOOL)animated {
    [self observeKeyboard];
}

- (void)jps_viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Keyboard Layout Guide

- (void)setupKeyboardLayoutGuide {
	NSAssert(self.keyboardLayoutGuide, @"keyboardLayoutGuide needs to be created by now");

    self.bottomConstraint = [self.keyboardLayoutGuide.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];

    [NSLayoutConstraint activateConstraints:@[[self.keyboardLayoutGuide.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
                                              [self.keyboardLayoutGuide.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
                                              [self.keyboardLayoutGuide.topAnchor constraintEqualToAnchor:self.view.topAnchor],
                                              self.bottomConstraint]];
}

#pragma mark - Keyboard Methods

- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jps_keyboardDidShow:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jps_keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)jps_keyboardDidShow:(NSNotification *)notification {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    NSDictionary *info = notification.userInfo;
    NSValue *kbFrame = info[UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimatingState curve = [info[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGRect keyboardFrame = kbFrame.CGRectValue;

    self.bottomConstraint.constant = -(self.view.bounds.size.height - CGRectGetMinY(keyboardFrame));

    [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:animationDuration
                                                          delay:0
                                                        options:(UIViewAnimationOptions)curve << 16 | UIViewAnimationOptionBeginFromCurrentState
                                                     animations:^{}
                                                     completion:^(UIViewAnimatingPosition finalPosition) {
                                                         [self.view layoutIfNeeded];
                                                     }];
}

- (void)jps_keyboardWillHide:(NSNotification *)notification {
    self.bottomConstraint.constant = 0;
}

@end
