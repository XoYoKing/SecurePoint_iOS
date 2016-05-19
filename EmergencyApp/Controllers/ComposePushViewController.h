//
//  ComposePushViewController.h
//  EmergencyApp
//
//  Created by Muhammed Salih on 09/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "SPViewController.h"
#import "PushListViewController.h"
#import "Constants.h"
#import "ConnectionRegionListController.h"
#import "ALPickerView.h"
@interface ComposePushViewController : SPViewController <ALPickerViewDelegate, UITextFieldDelegate>
{
    NSMutableArray *selectionStates;
    NSMutableArray *availableRegions;
    ALPickerView *pickerView;
    UIToolbar *toolBar;
    UIBarButtonItem *doneButton;
    UIBarButtonItem *cancelButton;
    
}

@property (nonatomic)PushListViewController * pushListController;

-(IBAction)sendPush:(id)sender event:(UIEvent *)event;

@property (weak, nonatomic) IBOutlet UITextField *users;

@property (weak, nonatomic) IBOutlet UITextView *message;

- (IBAction)cancelPush:(id)sender;

@end
