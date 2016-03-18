//
//  DKPickerView.h
//  DKPickView
//
//  Created by 李登科 on 16/3/18.
//  Copyright © 2016年 DK-Li. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ResultBlock)(NSString *result);

@interface DKPickerView : UIView

@property(nonatomic, copy) ResultBlock result;
@property(nonatomic, assign) BOOL isUseDefault;

/**
 *  显示省市县选择器
 *
 *  @param frame  选择器位置、大小
 *  @param result 选择结果如：河南省-郑州市-二七区
 */
+ (void)showDKPickerViewWith:(CGRect)frame result:(ResultBlock)result;

/**
 *  显示省市县选择器
 *
 *  @param frame  选择器位置、大小
 *  @param isUse  是否使用地位
 *  @param result 选择结果如：河南省-郑州市-二七区
 */
+ (void)showDKPickerViewWith:(CGRect)frame isUseDefault:(BOOL)isUse result:(ResultBlock)result;

@end
