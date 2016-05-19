//
//  ClientProfileViewController.h
//  EmergencyApp
//
//  Created by Mzalih on 03/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPViewController.h"

@interface ClientProfileViewController : SPViewController<UIPickerViewDelegate, UIPickerViewDataSource>{
    UIToolbar *toolBar;
    UIBarButtonItem *doneButton;
    UIBarButtonItem *cancelButton;
}
@property(nonatomic,weak) IBOutlet UITextField * nameTextField;
@property(nonatomic,weak) IBOutlet UITextField * phoneTextField;
@property(nonatomic, weak) IBOutlet UITextField * languageField;
@property (nonatomic, retain) UIPickerView * languagePickerView;
@property (nonatomic, weak)IBOutlet UIView * languageView;
@end
