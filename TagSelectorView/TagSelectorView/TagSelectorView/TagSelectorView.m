//
//  TagSelectorView.m
//  DXH
//
//  Created by camoufleur on 03/03/2017.
//  Copyright © 2017 camoufleur. All rights reserved.
//

#import "TagSelectorView.h"

@implementation TagSelectorModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"items" : [self class]};
}

+ (NSDictionary *)modelCustomPropertyMapper {
    // 在此处是使用 YYModel 的数据转模型方法, 根据实际需要, 更换或者修改下方的是几键值对
    return @{@"title" : @"name",
             @"items" : @[@"rows",@"item"]};
}

@end

// item
@interface TagSelectorCell : UICollectionViewCell

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation TagSelectorCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    UIView *seView = [UIView new];
    seView.backgroundColor = [UIColor colorWithRed:0.258 green:0.701 blue:0.987 alpha:1];
    // 设置圆角的半径为 item 高度的四分之一 34.4 / 4 = 8.6
    seView.layer.cornerRadius = 8.6;
    self.selectedBackgroundView = seView;
    
    self.layer.borderColor = [UIColor colorWithRed:178 / 255.0 green:178 / 255.0 blue:178 / 255.0 alpha:1.0].CGColor;
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = 8.6;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    if (_titleLabel) {
        _titleLabel.text = title;
    } else {
        _titleLabel = [UILabel new];
        _titleLabel.bounds = self.bounds;
        _titleLabel.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
        _titleLabel.userInteractionEnabled = YES;
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = title;
        [self.contentView addSubview:_titleLabel];
    }
}

@end

// headerView
@interface TagSelectorHeaderView : UICollectionReusableView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *line;

@end

@implementation TagSelectorHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor colorWithRed:233 / 255.0 green:233 / 255.0 blue:233 / 255.0 alpha:1];
    [self addSubview:line];
    _line = line;
    
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_titleLabel];
}

// 设置 sectionHeader 的标题
- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat selfWidth = CGRectGetWidth(self.bounds);
    CGFloat margin = selfWidth / 30;
    
    _titleLabel.frame = CGRectMake(margin, 0, selfWidth - margin, CGRectGetHeight(self.bounds));
    _line.frame = CGRectMake(0, CGRectGetMaxY(self.bounds) - 1, self.frame.size.width, 1);
}

@end


// 选择视图
@interface TagSelectorView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) UICollectionView *ccView;
@property (nonatomic, copy) NSString *cellId;
@property (nonatomic, copy) NSString *headerViewId;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *shadeView;

@property (nonatomic, strong) TagSelectorModel *svModel;
@property (nonatomic, strong) TagSelectorModel *refreshModel;
@property (nonatomic, assign) NSIndexPath *selectIndexPath;
@property (nonatomic, assign) NSInteger maxLevels;
@property (nonatomic, copy) void (^completio)(NSArray<TagSelectorModel *> *);
@property (nonatomic, strong) NSMutableArray<TagSelectorModel *> *resultArray;
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *indexsArray;

@end

@implementation TagSelectorView

#pragma mark - LifeCircle

+ (instancetype)showSelectorWithSelectorModel:(TagSelectorModel *)model completion:(void (^)(NSArray<TagSelectorModel *> *modelArray))completion {
    TagSelectorView *tsView = [self new];
    tsView -> _completio = completion;
    tsView.svModel = model;
    tsView.refreshModel = model;
    // 设置最大层级数
    tsView.maxLevels = [tsView maxLevels:model index:0];
    // 设置索引数组的初始值
    tsView.indexsArray = [NSMutableArray array];
    for (NSInteger index = 0; index < tsView.maxLevels - 1; index ++) {
        NSIndexPath * idp = [NSIndexPath indexPathForItem:0 inSection:index];
        [tsView.indexsArray addObject:idp];
    }
    
    tsView.resultArray = [NSMutableArray arrayWithCapacity:tsView.maxLevels];
    [[[UIApplication sharedApplication] keyWindow] addSubview:tsView];
    [tsView showSelectorView];
    return tsView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.frame = CGRectMake(0, 64, [self screenSize].width, 0);
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    // 设置 UICollectionViewCell 的布局
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    // 整体上左下右的距离
    layout.sectionInset = UIEdgeInsetsMake(8, 30, 8, 30);
    // item上下间的间距
    layout.minimumLineSpacing = 8;
    // cell 的大小
    // self 的整体高度设置为4s 的 屏幕高度 - (导航栏高度 + 状态栏高度) = 480 - 64 = 416
    // 一个 item/headerView/cancelButton 的高为 (416 - 72) / 10 = 34.4
    CGFloat itemWidth = ([self screenSize].width - 90) / 3;
    CGFloat itemHeight = 34.4;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    // sectionHeader 的大小
    layout.headerReferenceSize = CGSizeMake(0, itemHeight);
    
    
    UICollectionView *ccView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [self screenSize].width, 0) collectionViewLayout:layout];
    ccView.backgroundColor = [UIColor whiteColor];
    ccView.allowsMultipleSelection = YES;
    ccView.delegate = self;
    ccView.dataSource = self;
    ccView.showsHorizontalScrollIndicator = NO;
    _cellId = @"UICollectionViewCellId";
    _headerViewId = @"TagSelectorHeaderView";
    [ccView registerClass:[TagSelectorCell class] forCellWithReuseIdentifier:_cellId];
    [ccView registerClass:[TagSelectorHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:_headerViewId];
    [self addSubview:ccView];
    _ccView = ccView;
    
    // 取消按钮
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.backgroundColor = [UIColor colorWithRed:0.258 green:0.701 blue:0.987 alpha:1];
    [self addSubview:cancelButton];
    [cancelButton addTarget:self action:@selector(hideSelectorView) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton = cancelButton;
    
    // 背景遮罩, 点击后隐藏菜单
    UIView *shadeView = [UIView new];
    shadeView.frame = CGRectMake(0, 64, [self screenSize].width, [self screenSize].height - 64);
    [[[UIApplication sharedApplication] keyWindow] addSubview:shadeView];
    shadeView.alpha = 0;
    shadeView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tgrCancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSelectorView)];
    [shadeView addGestureRecognizer:tgrCancel];
    _shadeView = shadeView;
}

- (CGSize)screenSize {
    return [[[UIApplication sharedApplication] keyWindow] bounds].size;
}

- (CGFloat)calculateSelfHeight {
    
    CGFloat height = 0;
    for (NSInteger index = 0; index < self.maxLevels; index ++) {
        TagSelectorModel *model = [self currentModel:_refreshModel indexArray:self.indexsArray section:index];
        NSInteger count = model.items.count;
        height += (((count - 1) / 3) + 2) * 42.4;
    }
    // 加上 button 的高度
    height += 34.4;
    return height > 416 ? 416 : height;
}

#pragma mark - FunctionMethods

- (void)showSelectorView {
    
    self.alpha = 1;
    // 设置弹出动画
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _shadeView.alpha = 0.6;
        CGFloat width = [self screenSize].width;
        CGFloat height = _maxLevels > 4 ? 416 : [self calculateSelfHeight];
        self.frame = CGRectMake(0, 64, width, height);
        self.ccView.frame = CGRectMake(0, 0, width, height - 34.4);
        self.cancelButton.frame = CGRectMake(0, CGRectGetMaxY(self.ccView.frame), width, 34.4);
        self.cancelButton.hidden = NO;
    } completion:^(BOOL finished) {
        // 设置默认选中的 item
        for (NSIndexPath *idx in _indexsArray) {
            [self.ccView selectItemAtIndexPath:idx animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
    }];
}

- (void)hideSelectorView {
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0;
        _shadeView.alpha = 0;
    } completion:^(BOOL finished) {
        CGFloat screenWidth = [self screenSize].width;
        self.frame = CGRectMake(0, 64, screenWidth, 0);
        self.ccView.frame = CGRectMake(0, 0, screenWidth, 0);
        self.cancelButton.frame = CGRectMake(0, 0, screenWidth, 0);
        self.cancelButton.hidden = YES;
        self.alpha = 1;
    }];
}

- (NSInteger)maxLevels:(TagSelectorModel *)model index:(NSInteger)index {
    
    if (model.items != nil) {
        return [self maxLevels:model.items[index] index:index];
    }
    
    return model.level;
}

- (TagSelectorModel *)currentModel:(TagSelectorModel *)model indexArray:(NSArray<NSIndexPath *> *)idxArray section:(NSInteger)section {
    
    TagSelectorModel *mod = model;
    for (NSIndexPath *idp in idxArray) {
        if (mod.level == section) {
            return mod;
        }
        mod = mod.items[idp.row];
    }
    
    return mod;
}

- (void)updateIndexsArray:(NSMutableArray<NSIndexPath *> *)array withIndexPath:(NSIndexPath *)indexPath {
    __block BOOL hasObj = NO;
    __block NSUInteger index = 0;
    [array enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.section == indexPath.section) {
            hasObj = YES;
            index = idx;
        }
    }];
    if (hasObj) {
        [array replaceObjectAtIndex:index withObject:indexPath];
    } else if (indexPath.section < _maxLevels - 1) {
        [array addObject:indexPath];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return self.maxLevels;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    TagSelectorModel *model = [self currentModel:_refreshModel indexArray:self.indexsArray section:section];
    NSInteger count = model.items.count;
    return count;
    //    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TagSelectorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellId forIndexPath:indexPath];
    TagSelectorModel *model = [self currentModel:_refreshModel indexArray:self.indexsArray section:indexPath.section];
    cell.title = model.items[indexPath.row].title;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if (kind == UICollectionElementKindSectionHeader) {
        TagSelectorHeaderView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:_headerViewId forIndexPath:indexPath];
        TagSelectorModel *model = [self currentModel:_refreshModel indexArray:self.indexsArray section:indexPath.section];
        reusableView.title = model.items.firstObject.sectionTitle;
        return reusableView;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 取消之前的选中
    for (NSIndexPath *idx in _indexsArray) {
        // 取消之前本 section 选择的标签
        if (idx.section == indexPath.section) {
            [collectionView deselectItemAtIndexPath:idx animated:YES];
        }
    }
    
    [self updateIndexsArray:_indexsArray withIndexPath:indexPath];
    
    TagSelectorModel *model = [self currentModel:_refreshModel indexArray:_indexsArray section:indexPath.section].items[indexPath.row];
    for (NSInteger index = indexPath.section + 1; index < _maxLevels - 1; index ++) {
        NSIndexPath * idp = [NSIndexPath indexPathForItem:0 inSection:index];
        [self updateIndexsArray:_indexsArray withIndexPath:idp];
    }
    
    if (model.level == self.maxLevels) {
        // 取消之前的选中
        [collectionView deselectItemAtIndexPath:self.selectIndexPath animated:YES];
        _selectIndexPath = indexPath;
        // 隐藏选择视图
        [self hideSelectorView];
        // 筛选结果
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:_maxLevels];
        for (NSInteger index = 1; index < _maxLevels; index ++) {
            TagSelectorModel *model = [self currentModel:_refreshModel indexArray:_indexsArray section:index];
            [arr addObject:model];
        }
        [arr addObject:model];
        // 输出
        _completio([arr copy]);
    } else {
        NSRange rang = NSMakeRange(indexPath.section + 1, self.maxLevels - indexPath.section - 1);
        [collectionView reloadSections:[NSIndexSet indexSetWithIndexesInRange:rang]];
        
        [self showSelectorView];
    }
    
}

@end
