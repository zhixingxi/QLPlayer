//
//  QLPlayerView.h
//  QLPlayer
//
//  Created by MQL-IT on 2017/7/28.
//  Copyright © 2017年 MQL-IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IJKMediaFramework/IJKMediaFramework.h>

#define QLSCREEN_W [UIScreen mainScreen].bounds.size.width
#define QLSCREEN_H [UIScreen mainScreen].bounds.size.height
#ifdef DEBUG//调试状态
#define QLLog(...) NSLog(__VA_ARGS__)
#endif

@protocol QLPlayerViewDelegate <NSObject>
@optional



@end

@interface QLPlayerView : UIView
@property (nonatomic, weak) id<QLPlayerViewDelegate> delegate;
@property (nonatomic, strong) UIImage *coverPlaceholderImage;

-(instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate url:(NSString *)url;
@end
