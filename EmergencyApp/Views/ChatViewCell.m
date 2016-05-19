//
//  ChatViewCell.m
//  Student SOS
//
//  Created by Jarda Kotesovec on 21/03/2014.
//  Copyright (c) 2014 Radiology Technology Inc. All rights reserved.
//

#import "ChatViewCell.h"

// header (user name and message time) can have fixed height
// body (message text) have dynamic height, based on text

// header
static const double kHeaderHeight = 40;
static const double kTopPadding =7;
static const double kLeftPadding =15;

@interface ChatViewCell ()


@end

@implementation ChatViewCell

-(void)layoutSubviews
{
// chatTextLabel;
// timeLabel;
// nameLabel;
// sideBar;
// chatTextMarginBackground;
// arrowImage;
    
//  attributedMessageText;
//  messageText;
//  timeText;
//  nameText;
//  nameAndSideBarColor;
//  sideBarLeft;
   
    if(_timeText){
        _timeLabel.text =_timeText;
    }
    if(_nameText){
        _nameLabel.text = _nameText;
    }
    if(_attributedMessageText){
        _chatTextLabel.attributedText = _attributedMessageText;
        _messageText= [_attributedMessageText string];
    }else{
        _chatTextLabel.text = _messageText;
    }
    _sideBar.backgroundColor = _nameAndSideBarColor;
  //  _nameLabel.textColor =_nameAndSideBarColor;
    if(_sideBarLeft)
     [self layoutLeft];
    else
        [self layoutRight];
    
}
-(void)initiateSubView{
    UILabel *label;
    if(!_chatLabelHoder){
        UIView *sideView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        _chatLabelHoder =sideView;
        _chatLabelHoder.backgroundColor =[UIColor whiteColor];
        [self addSubview:sideView];
    }
    if(!_timeLabel){
        label =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        _timeLabel =label;
        _timeLabel.font= [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
        [self addSubview:label];
    }
    if(!_nameLabel){
        label =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        _nameLabel =label;
        _nameLabel.textColor =[UIColor lightGrayColor];
        _nameLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
         [self addSubview:label];
    }
    if(!_chatTextLabel){
        label =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        _chatTextLabel =label;
        _chatTextLabel.numberOfLines =0;
        _chatTextLabel.backgroundColor =[UIColor clearColor];
        _chatTextLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
         [self addSubview:label];
    }
    if(!_sideBar){
        UIView *sideView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        _sideBar =sideView;
         [self addSubview:sideView];
    }
    if(!_underLineView){
        UIView *sideView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        _underLineView =sideView;
        [sideView setBackgroundColor :[UIColor lightGrayColor] ];
        [self addSubview:sideView];
    }
    if(!_arrowImage){
        UIImageView *sideView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chatarrowdown"]];
        _arrowImage =sideView;
        [self addSubview:sideView];
    }
    
    
}
-(void)layoutLeft{
    [self initiateSubView];
    CGRect labelSixe = [ChatViewCell labelSize: _messageText forWidth:self.window.frame.size.width];
    _chatLabelHoder.frame =CGRectMake(15, 0, labelSixe.size.width+15+15, labelSixe.size.height+7+7);
    _chatTextLabel.frame =CGRectMake(_chatLabelHoder.frame.origin.x+15, 7, labelSixe.size.width, labelSixe.size.height);
    _sideBar.frame =CGRectMake (kLeftPadding+_chatLabelHoder.frame.size.width, 0, 2, _chatLabelHoder.frame.size.height);
    
    _underLineView.frame =CGRectMake(15, labelSixe.size.height+7+7, labelSixe.size.width+15+15+2, 0.6);
    
    _arrowImage.frame=CGRectMake (25, _chatLabelHoder.frame.size.height, _arrowImage.frame.size.width,_arrowImage.frame.size.height);
    _nameLabel.frame =CGRectMake (15, _chatLabelHoder.frame.size.height,200,30);
    _nameLabel.textAlignment =NSTextAlignmentLeft;
}
-(void)layoutRight{
    [self initiateSubView];
    CGRect labelSixe = [ChatViewCell labelSize: _messageText forWidth:self.window.frame.size.width];
    _chatLabelHoder.frame =CGRectMake((self.frame.size.width -labelSixe.size.width-15-15-15), 0, labelSixe.size.width+15+15, labelSixe.size.height+7+7);
    
    _chatTextLabel.frame =CGRectMake(_chatLabelHoder.frame.origin.x+15, 7, labelSixe.size.width, labelSixe.size.height);
    
    _sideBar.frame =CGRectMake (_chatLabelHoder.frame.origin.x-2, 0, 2, _chatLabelHoder.frame.size.height);
    
    _underLineView.frame =CGRectMake((self.frame.size.width -labelSixe.size.width-15-15-15-2), labelSixe.size.height+7+7, labelSixe.size.width+15+15+2, 0.6);
    
    
    _arrowImage.frame=CGRectMake (self.frame.size.width-_arrowImage.frame.size.width-25, _chatLabelHoder.frame.size.height, _arrowImage.frame.size.width,_arrowImage.frame.size.height);
    _nameLabel.frame =CGRectMake (self.frame.size.width-200-15, _chatLabelHoder.frame.size.height,200,30);
    _nameLabel.textAlignment =NSTextAlignmentRight;
    
}

+ (CGFloat) height :(NSString *)string forWidth:(double)width{

    CGRect expectedSize =[ChatViewCell labelSize:string forWidth:width];
    CGFloat height =ceil(expectedSize.size.height+2*kTopPadding+kHeaderHeight);
    return height;
}
+ (CGRect) labelSize :(NSString *)string forWidth:(double)width{
 return   [string boundingRectWithSize:CGSizeMake(width-(4*kLeftPadding+40), 0)
                         options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f]}
                         context:nil];
}


- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
