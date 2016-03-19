//
//  DKDatePicker.h
//  DKDatePicker
//
//  Created by 李登科 on 16/2/24.
//  Copyright © 2016年 李登科. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DateType) {
    DateTypeTime = 0,        // 时间
    DateTypeDate,            // 日期
    DateTypeDateAndTime,     // 时间和日期
};

typedef void(^ChoseDateBlock)(NSString *dateStr);

@interface DKDatePicker : NSObject

@property(nonatomic, copy) ChoseDateBlock block;

/**
 *  创建一个时间选择器
 *
 *  @param type  时间选择器类型
 *  @param block 选择结果回调
 */
+ (void)dateWithType:(DateType)type block:(ChoseDateBlock)block;

/**
 *  创建一个时间选择器
 *
 *  @param type  时间选择器类型
 *  @param date  限制时间(限制date之前时间不可选)
 *  @param block 选择结果回调
 */
+ (void)dateWithType:(DateType)type limit:(NSDate *)date block:(ChoseDateBlock)block;

/**
 *  创建一个时间选择器
 *
 *  @param type    时间选择器类型
 *  @param dateStr 限制时间，字符串例如，日期：2016-2-26，时间:14:45(只限制当天几点之前),日期和时间：2016-2-26 14:45
 *  @param block   选择结果回调
 */
+ (void)dateWithType:(DateType)type limitStr:(NSString *)dateStr block:(ChoseDateBlock)block;


@end









