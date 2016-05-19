//
//  SPMainViewController.m
//  EmergencyApp
//
//  Created by Mzalih on 02/12/14.
//  Copyright (c) 2014 toobler. All rights reserved.
//

#import "SPMainViewController.h"
#import "QAConstants.h"

@interface SPMainViewController ()

@end

@implementation SPMainViewController

static SPMainViewController* _sharedMyInstance = nil;

+(SPMainViewController*)getActiveInstance
{
    if (_sharedMyInstance){
        return _sharedMyInstance;
    }
    return nil;
}

-(instancetype)init{
  _sharedMyInstance =  [super init];
    return _sharedMyInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _sharedMyInstance =self;
   // _isOperrator =false;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)segueIdentifierForIndexPathInLeftMenu:(NSIndexPath *)indexPath
{
    NSString *identifier = @"";
    switch (indexPath.row) {
            
        case 0:
            if([SPMainViewController getActiveInstance].loginStatus == LOGGED_OPERATOR){
            identifier = @"secondRow";
            }
            else{
             identifier = @"firstRow";
            }
            break;
        case 1:
            
            //CODE FOR CLIENT & GUARDIAN SIDE PUSH NOTIFICATION MESSAGE
 
            if([SPMainViewController getActiveInstance].loginStatus != LOGGED_NONE){
                //MOVE TO PUSHLIST VC
                if (indexPath.section == 0) {
                    identifier = opPUSHPAGE;
                }
                else {
                    //MOVE TO REGIONLIST VC
                    identifier = opREGIONLIST;
                }
            }else {
                //IF NOT LOGGED IN MOVE TO REGIONLIST VC
                identifier = opREGIONLIST;
            }
            break;
    }
    return identifier;
}

- (void) setNavigationColor:(UIViewController *)view{
    view.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    view.navigationController.navigationBar.barTintColor = [QAConstants QARedColor];
    [view.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor whiteColor]}];
}

- (CGFloat)leftMenuWidth
{
    return 250;
}

-(void)openHomePage{
    if(self){
        // GET SEGUE FOR HOME PAGE
        NSString *segueIdentifierForIndexPathInLeftMenu =
        [self segueIdentifierForIndexPathInLeftMenu:[NSIndexPath indexPathForRow:0 inSection:1]];
        // MOVE TO THE HOME PAGE
        [self.leftMenu performSegueWithIdentifier:segueIdentifierForIndexPathInLeftMenu sender:self.leftMenu];
        // TO RELOAD THE NAME MENTIONED IN THE MENU BAR
        //[mainView.leftMenu viewWillAppear:false];
    }
}

- (void)configureLeftMenuButton:(UIButton *)button
{
    _leftIconImage =[[UIImageView alloc] initWithFrame:CGRectMake(10, -10, 20, 20)];
    _leftIconImage.image =[UIImage imageNamed:@"menuWhite"];
    [button addSubview:_leftIconImage];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(BOOL)deepnessForLeftMenu{
    return NO;
}

@end
