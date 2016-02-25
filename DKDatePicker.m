//
//  DKDatePicker.m
//  DKDatePicker
//
//  Created by 李登科 on 16/2/24.
//  Copyright © 2016年 李登科. All rights reserved.
//

#import "DKDatePicker.h"

@interface DKDatePicker ()

@property(nonatomic, assign) DateType type;
@property(nonatomic, strong) NSDate *date;
@property(nonatomic, strong) NSString *dateStr;

@end

@implementation DKDatePicker

static DKDatePicker *dkPick = nil;

+ (DKDatePicker *)shareDatePick
{
    if(dkPick == nil)
    {
        dkPick = [[DKDatePicker alloc] init];
    }
    
    return dkPick;
}

/**
 *  创建一个时间选择器
 *
 *  @param type  时间选择器类型
 *  @param block 选择结果回调
 */
+ (void)dateWithType:(DateType)type block:(ChoseDateBlock)block
{
    DKDatePicker *DKSelf = [DKDatePicker shareDatePick];
    DKSelf.type = type;
    DKSelf.block = block;
    [DKSelf configDatePick];
}
/**
 *  创建一个时间选择器
 *
 *  @param type  时间选择器类型
 *  @param date  限制时间(限制date之前时间不可选)
 *  @param block 选择结果回调
 */
+ (void)dateWithType:(DateType)type limit:(NSDate *)date block:(ChoseDateBlock)block
{
    DKDatePicker *DKSelf = [DKDatePicker shareDatePick];
    DKSelf.type = type;
    DKSelf.block = block;
    DKSelf.date = date;
    [DKSelf configDatePick];
}

/**
 *  创建一个时间选择器
 *
 *  @param type    时间选择器类型
 *  @param dateStr 限制时间(字符串例如，日期：2016-2-26，时间:14:45,日期和时间：2016-2-26 14:45)
 *  @param block   选择结果回调
 */
+ (void)dateWithType:(DateType)type limitStr:(NSString *)dateStr block:(ChoseDateBlock)block
{
    DKDatePicker *DKSelf = [DKDatePicker shareDatePick];
    DKSelf.type = type;
    DKSelf.block = block;
    DKSelf.dateStr = dateStr;
    [DKSelf configDatePick];
}

// 字符串转时间
- (NSDate *)stringToDate
{
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    switch (self.type) {
        case DateTypeDate:
            [form setDateFormat:@"yyyy-MM-dd"];
            break;
        case DateTypeTime:
        {
            [form setDateFormat:@"yyyy-MM-dd"];
            NSString *now = [form stringFromDate:[NSDate date]];
            [form setDateFormat:@"HH:mm"];
            self.dateStr = [NSString stringWithFormat:@"%@ %@",now,self.dateStr];
            [form setDateFormat:@"yyyy-MM-dd HH:mm"];
            break;
        }
        case DateTypeDateAndTime:
            [form setDateFormat:@"yyyy-MM-dd HH:mm"];
            break;
    }
    return [form dateFromString:self.dateStr];
    
}

// 设置UI界面
- (void)configDatePick
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    CGFloat screen_w = [UIScreen mainScreen].bounds.size.width;
    CGFloat screen_h = [UIScreen mainScreen].bounds.size.height;
    CGFloat datePick_h = 200;
    
    UIView *super_view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    super_view.backgroundColor = [UIColor clearColor];
    super_view.tag = 1000;
    [window addSubview:super_view];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, screen_h, screen_w, 240)];
    backView.backgroundColor = [UIColor whiteColor];
    [super_view addSubview:backView];
    
    [UIView animateWithDuration:0.4 animations:^{
        backView.frame = CGRectMake(0, screen_h - 240, screen_w, 240);
    }];
    
    UIView *btn_View = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_w, 40)];
    btn_View.backgroundColor = [UIColor blackColor];
    [backView addSubview:btn_View];
    
    UIButton *sure_btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 80, 40)];
    [sure_btn setTitle:@"确定" forState:UIControlStateNormal];
    [sure_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_View addSubview:sure_btn];
    [sure_btn addTarget:dkPick action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancel_btn = [[UIButton alloc] initWithFrame:CGRectMake(screen_w - 10 - 80, 0, 80, 40)];
    [cancel_btn setTitle:@"取消" forState:UIControlStateNormal];
    [cancel_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_View addSubview:cancel_btn];
    [cancel_btn addTarget:dkPick action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIDatePicker *datePcik = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btn_View.frame), screen_w, datePick_h)];
    datePcik.tag = 1001;
    [backView addSubview:datePcik];
    
    if (self.date) {
        [datePcik setMinimumDate:self.date];
    }
    else if(self.dateStr)
    {
        [datePcik setMinimumDate:[self stringToDate]];
    }
    
    switch (self.type) {
        case DateTypeDate:
            datePcik.datePickerMode = UIDatePickerModeDate;
            break;
        case DateTypeTime:
            datePcik.datePickerMode = UIDatePickerModeTime;
            break;
        case DateTypeDateAndTime:
            datePcik.datePickerMode = UIDatePickerModeDateAndTime;
            break;
    }

}

// 确定按钮事件
- (void)sureClick:(UIButton *)btn
{
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
  
    NSString *dateStr ;
    switch (self.type) {
        case DateTypeDate:
            [form setDateFormat:@"yyyy-MM-dd"];
            break;
        case DateTypeTime:
            [form setDateFormat:@"HH:mm"];
            break;
        case DateTypeDateAndTime:
            [form setDateFormat:@"yyyy-MM-dd HH:mm"];
            break;
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIDatePicker *pick = (UIDatePicker *)[[window viewWithTag:1000] viewWithTag:1001];
    
    dateStr = [form stringFromDate:pick.date];
    dkPick.block(dateStr);
    [self cancelClick];
}

// 取消按钮事件
- (void)cancelClick
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *view = [window viewWithTag:1000];
    [view removeFromSuperview];
    dkPick = nil;
}

@end








