//
//  TagSelectorView.h
//  DXH
//
//  Created by camoufleur on 03/03/2017.
//  Copyright © 2017 camoufleur. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagSelectorModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *sectionTitle;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, copy) NSArray<TagSelectorModel *> *items;

@end

@class GradeAndSubjectListModel;
@interface TagSelectorView : UIView

// 创建并显示 selectorView 
+ (instancetype)showSelectorWithSelectorModel:(TagSelectorModel *)model completion:(void(^)(NSArray<TagSelectorModel *> *modelArray))completion;

// 显示 selectorView
- (void)showSelectorView;

// 隐藏 selectorView
- (void)hideSelectorView;

@end
