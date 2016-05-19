//
//  RegionListViewController.h
//  EmergencyApp
//
//  Created by Jithu on 3/16/15.
//  Copyright (c) 2015 toobler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegionListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate, UISearchDisplayDelegate ,UIAlertViewDelegate>

{
    UITableView *clientRegionListtableView;
    NSMutableArray *clientRegionListArray;
    NSMutableArray *searchResults;

}

@property(nonatomic,retain)IBOutlet UITableView *clientRegionListTableView;
@property (nonatomic, strong) NSMutableArray *clientRegionListArray;
@property(nonatomic) UIAlertView * clientRegionPasswordView;

-(void) becomeClientForRegionID:(NSNumber *) regionID withPassword:(NSString *) password ;


@end
