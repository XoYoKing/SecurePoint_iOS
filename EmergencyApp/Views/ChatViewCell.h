//
//  ChatViewCell.h
//  Student SOS
//
//  Created by Jarda Kotesovec on 21/03/2014.
//  Copyright (c) 2014 Radiology Technology Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewCell : UITableViewCell
@property (nonatomic) NSAttributedString * attributedMessageText;
@property (nonatomic) NSString * messageText;
@property (nonatomic) NSString * timeText;
@property (nonatomic) NSString * nameText;
@property (nonatomic) UIColor * nameAndSideBarColor;
@property (nonatomic) BOOL sideBarLeft;

@property (weak, nonatomic) IBOutlet UIView * chatLabelHoder;
@property (weak, nonatomic) IBOutlet UILabel * chatTextLabel;
@property (weak, nonatomic) IBOutlet UILabel * timeLabel;
@property (weak, nonatomic) IBOutlet UILabel * nameLabel;
@property (weak, nonatomic) IBOutlet UIView * sideBar;
@property (weak, nonatomic) IBOutlet UIView * chatTextMarginBackground;
@property (weak, nonatomic) IBOutlet UIView * underLineView;
@property (weak, nonatomic) IBOutlet UIImageView * arrowImage;

+ (CGFloat) height:(NSString *)string forWidth:(double)width;


@end
