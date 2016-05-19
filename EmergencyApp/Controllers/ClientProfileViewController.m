//
//  ClientProfileViewController.m
//  EmergencyApp
//
//  Created by Mzalih on 03/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "ClientProfileViewController.h"
#import "QAConstants.h"
#import "SPMainViewController.h"

@interface ClientProfileViewController (){
    
    NSMutableArray *Languages;

}

@end

@implementation ClientProfileViewController

@synthesize languagePickerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //SHOW AND HIDE FOR LOGGED MODE == GUARDIAN
    self.languageView.hidden = YES;
    
    if ([SPMainViewController getActiveInstance].loginStatus == LOGGED_GUARDIAN) {
        self.languageView.hidden = NO;
    }

    //FETCHING VALUES FROM LANGUAGES.PLIST TO PICKERVIEW
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Language" ofType:@"plist"]];
    NSLog(@"dictionary = %@", dictionary);
    
    Languages = [dictionary objectForKey:@"Languages"];
    NSLog(@"array = %@", Languages);
    
    
    //UIPICKER VIEW FOR SHOWING LANGUAGES ON CLICK UITEXTFIELD
    //TOOLBAR FOR PICKERVIEW
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 35)];
    
    // add a TOOLBAR with CANCEL & DONE button
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
    cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTouched:)];
    [[UIBarButtonItem appearance] setTintColor:[UIColor  whiteColor]];
    
    // the middle button is to make the Done button align to right
    [toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];
     self.languageField.inputAccessoryView = toolBar;
    
    //PICKERVIEW
    languagePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 60, 320, 200)];
    [languagePickerView setDataSource: self];
    [languagePickerView setDelegate: self];
    languagePickerView.showsSelectionIndicator = YES;
    self.languageField.inputView = languagePickerView;
    
    
    // Do any additional setup after loading the view.
    [self.navigationItem setHidesBackButton:YES];
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSString * clientName =  [prefs valueForKey:kClientName];
    NSString * clientPhone =  [prefs valueForKey:kClientPhone];
    if(clientName != nil && ![clientName isEqualToString:@""]){
        [self.nameTextField  setText :clientName ];
    }
    if(clientPhone != nil && ![clientPhone isEqualToString:@""]){
        [self.phoneTextField  setText :clientPhone ];
    }

}

//CANCEL button acton.
- (void)cancelTouched:(UIBarButtonItem *)sender
{
    // hide the picker view
    _languageField.text=@"";
    [_languageField resignFirstResponder];
}

//DONE button acion.
- (void)doneTouched:(UIBarButtonItem *)sender
{
    // hide the PICKER VIEW
    [_languageField resignFirstResponder];
    
   // _languageField.text=result ;
}


#pragma mark -
#pragma mark ALPickerView delegate methods
// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return Languages.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return Languages[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.languageField.text = Languages[row];
}




-(void)viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(IBAction) saveProfile:(id) sender{
    // todo check proper values
    
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    if([self.nameTextField.text length] && [self.phoneTextField.text length]){
        [prefs setValue:self.nameTextField.text forKeyPath:kClientName];
        [prefs setValue:self.phoneTextField.text forKeyPath:kClientPhone];
        [self.navigationController popViewControllerAnimated:YES];
        
        SPMainViewController *mainView =[SPMainViewController getActiveInstance];
        if(mainView){
           // GET SEGUE FOR HOME PAGE
       NSString *segueIdentifierForIndexPathInLeftMenu =
[mainView segueIdentifierForIndexPathInLeftMenu:[NSIndexPath indexPathForRow:0 inSection:1]];
             // MOVE TO THE HOME PAGE
[mainView.leftMenu performSegueWithIdentifier:segueIdentifierForIndexPathInLeftMenu sender:mainView.leftMenu];
            // TO RELOAD THE NAME MENTIONED IN THE MENU BAR
            [mainView.leftMenu viewWillAppear:false];
        }
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please complete required fields."
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil] ;
        [alert show];
        
    }
    
}
@end
