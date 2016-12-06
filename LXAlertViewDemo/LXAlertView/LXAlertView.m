//
//  LXAlertView.m
//  LXAlertViewDemo
//
//  Created by 刘鑫 on 16/4/15.
//  Copyright © 2016年 liuxin. All rights reserved.
//
#define MainScreenRect [UIScreen mainScreen].bounds
#define AlertView_W     270.0f
#define MessageMin_H    60.0f       //messagelab的最小高度
#define MessageMAX_H    120.0f      //messagelab的最大高度，当超过时，文本会以...结尾
#define LXATitle_H      20.0f
#define LXABtn_H        26.0f

#define SFQBlueColor        [UIColor colorWithRed:9/255.0 green:170/255.0 blue:238/255.0 alpha:1]
#define SFQRedColor         [UIColor colorWithRed:255/255.0 green:92/255.0 blue:79/255.0 alpha:1]
#define NAV_COLOR           0xfcc90a
#define PING_FANG_SC @"PingFang SC Bold"


#define LXADTitleFont       [UIFont boldSystemFontOfSize:17];
#define LXADMessageFont     [UIFont fontWithName:PING_FANG_SC size:15]

#define LXADBtnTitleFont    [UIFont fontWithName:PING_FANG_SC size:15]


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#import "LXAlertView.h"
#import "UILabel+LXAdd.h"

@interface LXAlertView()
@property (nonatomic,strong)UIWindow *alertWindow;
@property (nonatomic,strong)UIView *alertView;

@property (nonatomic,strong)UILabel *titleLab;
@property (nonatomic,strong)UILabel *messageLab;
@property (nonatomic,strong)UIButton *cancelBtn;
@property (nonatomic,strong)UIButton *otherBtn;
@property (nonatomic,strong)UIImageView * headImageView;

@end

@implementation LXAlertView

-(instancetype)initWithTitle:(NSString *)title andHeadImage:(NSString *)imageName message:(NSString *)message cancelBtnTitle:(NSString *)cancelTitle otherBtnTitle:(NSString *)otherBtnTitle clickIndexBlock:(LXAlertClickIndexBlock)block{
    if(self=[super init]){
        self.frame=MainScreenRect;
        self.backgroundColor=[UIColor colorWithWhite:.3 alpha:.7];
        
        _alertView=[[UIView alloc] init];
        _alertView.backgroundColor=[UIColor whiteColor];
        _alertView.layer.cornerRadius=6.0;
        _alertView.layer.masksToBounds=YES;
        _alertView.userInteractionEnabled=YES;
        
        
        _headImageView = [[UIImageView alloc] init];
        _headImageView.image = [UIImage imageNamed:imageName];
        _headImageView.frame = CGRectMake(0, 0, 0, 0);
        [_headImageView sizeToFit];

        
        
        if (title) {
            _titleLab=[[UILabel alloc] initWithFrame:CGRectMake(0, 10, AlertView_W, LXATitle_H)];
            _titleLab.text=title;
            _titleLab.textAlignment=NSTextAlignmentCenter;
            _titleLab.textColor=[UIColor blackColor];
            _titleLab.font=LXADTitleFont;
            
        }
        
        //设置弹窗的信息风格
        CGFloat messageLabSpace = 20;
        _messageLab=[[UILabel alloc] init];
        _messageLab.backgroundColor=[UIColor whiteColor];
        _messageLab.text=message;
        _messageLab.textColor=UIColorFromRGB(0x242424);
        _messageLab.font=LXADMessageFont;
        _messageLab.numberOfLines=0;
        _messageLab.textAlignment=NSTextAlignmentCenter;
        _messageLab.lineBreakMode=NSLineBreakByTruncatingTail;
        _messageLab.characterSpace=2;
        _messageLab.lineSpace=3;
        CGSize labSize = [_messageLab getLableRectWithMaxWidth:AlertView_W-messageLabSpace*2];
        CGFloat messageLabAotuH = labSize.height < MessageMin_H?MessageMin_H:labSize.height;
        CGFloat endMessageLabH = messageLabAotuH > MessageMAX_H?MessageMAX_H:messageLabAotuH;
        _messageLab.frame=CGRectMake(messageLabSpace, CGRectGetMaxY(_headImageView.frame)+10, AlertView_W-messageLabSpace*2, endMessageLabH);
        
        
        
        //计算_alertView的高度
        _alertView.frame=CGRectMake(0, 0, _headImageView.frame.size.width, _messageLab.frame.size.height+ 60 + _headImageView.frame.size.height);
        _alertView.center=self.center;
        [self addSubview:_alertView];
        [_alertView addSubview:_headImageView];
        [_alertView addSubview:_messageLab];
        
        if (cancelTitle) {
            _cancelBtn=[UIButton buttonWithType:UIButtonTypeCustom];
            [_cancelBtn setTitle:cancelTitle forState:UIControlStateNormal];
            [_cancelBtn setTitleColor:UIColorFromRGB(0x242424) forState:UIControlStateNormal];
            [_cancelBtn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(NAV_COLOR)] forState:UIControlStateNormal];
            _cancelBtn.titleLabel.font=LXADBtnTitleFont;
            _cancelBtn.layer.cornerRadius= 13.0f;
            _cancelBtn.layer.masksToBounds=YES;
            [_cancelBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [_alertView addSubview:_cancelBtn];
        }
        
        if (otherBtnTitle) {
            _otherBtn=[UIButton buttonWithType:UIButtonTypeCustom];
            [_otherBtn setTitle:otherBtnTitle forState:UIControlStateNormal];
            [_otherBtn setTitleColor:UIColorFromRGB(0x242424) forState:UIControlStateNormal];
            _otherBtn.titleLabel.font=LXADBtnTitleFont;
            _otherBtn.layer.cornerRadius=13.0f;
            _otherBtn.layer.masksToBounds=YES;
            [_otherBtn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(NAV_COLOR)] forState:UIControlStateNormal];
            [_otherBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [_alertView addSubview:_otherBtn];
        }
        
        CGFloat btnLeftSpace = 26;//btn到左边距
        CGFloat btn_y = CGRectGetMaxY(_messageLab.frame) + 10;
        if (cancelTitle && !otherBtnTitle) {
            _cancelBtn.tag=0;
            _cancelBtn.frame=CGRectMake(btnLeftSpace, btn_y, AlertView_W-btnLeftSpace*2, LXABtn_H);
        }else if (!cancelTitle && otherBtnTitle){
            _otherBtn.tag=0;
            _otherBtn.frame=CGRectMake(btnLeftSpace, btn_y,  AlertView_W-btnLeftSpace*2, LXABtn_H);
        }else if (cancelTitle && otherBtnTitle){
            _cancelBtn.tag=0;
            _otherBtn.tag=1;
            //CGFloat btnSpace = 20;//两个btn之间的间距
            CGFloat btn_w = (AlertView_W-btnLeftSpace*2 - 27)/2;
            
            _cancelBtn.frame=CGRectMake(btnLeftSpace, btn_y, btn_w, LXABtn_H);
            _otherBtn.frame=CGRectMake(_alertView.frame.size.width-btn_w-btnLeftSpace, btn_y, btn_w, LXABtn_H);
        }
        
        self.clickBlock=block;
        
    }
    return self;
}


-(void)btnClick:(UIButton *)btn{
    
    if (self.clickBlock) {
        self.clickBlock(btn.tag);
    }
    
    if (!_dontDissmiss) {
        [self dismissAlertView];
    }
    
}

-(void)setDontDissmiss:(BOOL)dontDissmiss{
    _dontDissmiss=dontDissmiss;
}

-(void)showLXAlertView{
    
    
    
    _alertWindow=[[UIWindow alloc] initWithFrame:MainScreenRect];
    _alertWindow.windowLevel=UIWindowLevelAlert;
    [_alertWindow becomeKeyWindow];
    [_alertWindow makeKeyAndVisible];
    
    [_alertWindow addSubview:self];
    
    [self setShowAnimation];
    
}

-(void)dismissAlertView{
    [self removeFromSuperview];
    [_alertWindow resignKeyWindow];
}

-(void)setShowAnimation{
    
    switch (_animationStyle) {
            
        case LXASAnimationDefault:
        {
            [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [_alertView.layer setValue:@(0) forKeyPath:@"transform.scale"];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.23 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [_alertView.layer setValue:@(1.2) forKeyPath:@"transform.scale"];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.09 delay:0.02 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        [_alertView.layer setValue:@(.9) forKeyPath:@"transform.scale"];
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.05 delay:0.02 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            [_alertView.layer setValue:@(1.0) forKeyPath:@"transform.scale"];
                        } completion:^(BOOL finished) {
                            
                        }];
                    }];
                }];
            }];
        }
            break;
            
        case LXASAnimationLeftShake:{
    
            CGPoint startPoint = CGPointMake(-AlertView_W, self.center.y);
            _alertView.layer.position=startPoint;
            
            //damping:阻尼，范围0-1，阻尼越接近于0，弹性效果越明显
            //velocity:弹性复位的速度
            [UIView animateWithDuration:.8 delay:0 usingSpringWithDamping:.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                _alertView.layer.position=self.center;
                
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
            
        case LXASAnimationTopShake:{
            
            CGPoint startPoint = CGPointMake(self.center.x, -_alertView.frame.size.height);
            _alertView.layer.position=startPoint;
            
            //damping:阻尼，范围0-1，阻尼越接近于0，弹性效果越明显
            //velocity:弹性复位的速度
            [UIView animateWithDuration:.8 delay:0 usingSpringWithDamping:.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                _alertView.layer.position=self.center;
                
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
            
        case LXASAnimationNO:{
            
        }
            
            break;
            
        default:
            break;
    }
    
}


-(void)setAnimationStyle:(LXAShowAnimationStyle)animationStyle{
    _animationStyle=animationStyle;
}

@end


@implementation UIImage (Colorful)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
