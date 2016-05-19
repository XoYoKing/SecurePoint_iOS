//
//  ChatRoomsCell.h
//  Student SOS
//
//  Created by Jarda Kotesovec on 27/03/2014.
//  Copyright (c) 2014 Radiology Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface ChatRoomsViewCell : SWTableViewCell

@property(nonatomic,weak) IBOutlet UILabel * name;
@property(nonatomic,weak) IBOutlet UILabel * distance;
@property(nonatomic,weak) IBOutlet UIImageView *icon;
@end
