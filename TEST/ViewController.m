//
//  ViewController.m
//  TEST
//
//  Created by IF on 2017/3/2.
//  Copyright © 2017年 zhilifang. All rights reserved.
//
#define TScreen_Width [UIScreen mainScreen].bounds.size.width
#define TScreen_Height [UIScreen mainScreen].bounds.size.height
#import "ViewController.h"
#import "UIView+LYMExtension.h"
#import "OneViewController.h"
#import "TwoViewController.h"
#import "ThreeViewController.h"
#define DefaultMargin       10
CGFloat const titlesViewH = 44;
static CGFloat const maxTitleScale = 1.3;
@interface ViewController ()<UIScrollViewDelegate>

@property (nonatomic,strong) UIView * navView;
@property (nonatomic,strong) UIView * underLineView;//下划线视图..
@property (nonatomic,strong) UIScrollView *  contentScrollView;

@property (nonatomic,strong) NSMutableArray * titleButtons;

/** 选中按钮 */
@property (nonatomic,weak) UIButton *seltitleButton;

@end

@implementation ViewController

-(void)loadView{
    UIScrollView *contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    contentScrollView.width  = TScreen_Width;
    contentScrollView.height = TScreen_Height - contentScrollView.y;
    contentScrollView.backgroundColor = [UIColor whiteColor];
    self.contentScrollView = contentScrollView ;
    self.view = contentScrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupTitleView];
    
    [self setupContentlscrollView];
    
    [self setupAllChildViewController];
    
    [self setupAllTitleButton];
    
    [self setupNavItem];
    
}


-(void)setupTitleView{
    UIView *titlesView = [[UIView alloc] initWithFrame:self.navigationController.navigationBar.bounds];
    titlesView.x = 45;
    titlesView.width = TScreen_Width - 45 * 2;
    self.navigationItem.titleView = titlesView;
    self.navView = titlesView;
  
}


- (void)setupContentlscrollView{
    // 开启分页功能
    self.contentScrollView.pagingEnabled = YES;
    // 隐藏水平条
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    // 设置代理
    self.contentScrollView.delegate = self;
}

// 添加所有标题按钮
- (void)setupAllTitleButton{
    CGFloat buttonW = self.navView.width/self.childViewControllers.count;
 
    for (int i = 0; i < self.childViewControllers.count; i++) {
        UIButton *titleBtn = [[UIButton alloc] init];
        titleBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        // 绑定tag
        titleBtn.tag = i;
        // 设置尺寸
        CGFloat buttonX = i * buttonW;
        titleBtn.frame = CGRectMake( buttonX, 0, buttonW, titlesViewH);
        // 设置文字
        [titleBtn setTitle:self.childViewControllers[i].title forState:UIControlStateNormal];
        
        [titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        // 监听
        [titleBtn addTarget:self action:@selector(titleBtnClick:) forControlEvents:UIControlEventTouchDown];
        [self.navView addSubview:titleBtn];
        [self.titleButtons addObject:titleBtn];
        // 默认第一个为选中按钮
        if (i == 0) {
            [self btnClick:titleBtn];
        }
    }
    
    // 添加 下划线
    [self setUpUnderLineView];

    // 设置contentScrollView的滚动范围
    self.contentScrollView.contentSize = CGSizeMake(self.childViewControllers.count * TScreen_Width, 0);
}


// 3.初始化所有的子控制器
- (void)setupAllChildViewController{
    // 头条
    OneViewController *toptVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OneViewController"];
    toptVC.title = @"头条";
    [self addChildViewController:toptVC];
    
    // 热点
    TwoViewController *hotVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TwoViewController"];
    hotVC.title = @"热点";
    [self addChildViewController:hotVC];
    
    // 关注
    ThreeViewController *videoVC =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ThreeViewController"];
    videoVC.title = @"关注";
    [self addChildViewController:videoVC];
}

/**
 *  创建 underLineView(下划线)
 */
- (void)setUpUnderLineView{
    // 取得第一个按钮
    UIButton *firstButton = self.navView.subviews.firstObject;
    
    // 标题栏
    UIView *underLineView = [[UIView alloc] init];
    underLineView.backgroundColor = [firstButton titleColorForState:UIControlStateSelected];
    underLineView.height = 2;
    underLineView.y = self.navView.height - underLineView.height - 1;
    
    // 让第一个按钮为选中状态
    [self titleBtnClick:firstButton];
 
    // 先计算宽度后计算中心点
    [firstButton.titleLabel sizeToFit];
    underLineView.width = firstButton.titleLabel.width + DefaultMargin;
    underLineView.centerX = firstButton.centerX;
    
    _underLineView = underLineView;
    [self.navView addSubview:underLineView];
}

// 监听按钮点击 切换文字颜色
- (void)titleBtnClick:(UIButton *)btn{
    [self btnClick:btn];
    // 点击按钮，加载对应的View
    NSInteger j = btn.tag;
    
    [UIView animateWithDuration:0.25 animations:^{
        // 1.标题栏选中状态
        [btn.titleLabel sizeToFit];
        _underLineView.width = btn.titleLabel.width + DefaultMargin;
        _underLineView.centerX = btn.centerX;
        
        CGPoint offset = self.contentScrollView.contentOffset;
        offset.x = j * self.contentScrollView.width;
        self.contentScrollView.contentOffset = offset;
    }completion:^(BOOL finished) {
        // 计算每一个View的位置
        [self setupOneChildViewController:j];
    }];
}


- (void)setupOneChildViewController:(NSInteger)j{
    // 获取对应控制器
    UIViewController *vc = self.childViewControllers[j];
    
    CGFloat x = j * TScreen_Width;
    CGFloat y = 0;
    CGFloat width = TScreen_Width;
    CGFloat height = self.contentScrollView.frame.size.height;
    
    vc.view.frame = CGRectMake(x, y, width, height);
    [self.contentScrollView addSubview:vc.view];
    
    // 点击按钮就跳转到当前的控制器
    self.contentScrollView.contentOffset = CGPointMake(j * TScreen_Width, 0);
}

- (void)btnClick:(UIButton *)btn{
    // 三部曲
    [self.seltitleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    // 之前选中的恢复原样
    self.seltitleButton.transform = CGAffineTransformIdentity;
    
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    // 当前选中的放大
    btn.transform = CGAffineTransformMakeScale(maxTitleScale, maxTitleScale);
    self.seltitleButton = btn;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *   监听滑动，切换界面。还有切换按钮
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    // 1.取得角标
    int index = (int)scrollView.contentOffset.x/TScreen_Width;
    // 2.切换到选中的按钮
    [self titleBtnClick:self.titleButtons[index]];
}

/**
 *  监听滑动，来个渐变过程
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat offsetX = scrollView.contentOffset.x;
    // 1.取得角标
    int indexL = (int)offsetX/TScreen_Width;
    int indexR = indexL + 1;
    
    // 2.取得左边的按钮
    UIButton *leftButton = self.titleButtons[indexL];
    
    UIButton *rightButton = nil;
    if (indexR < self.titleButtons.count) {
        // 取得左边的按钮
        rightButton = self.titleButtons[indexR];
    }
    
    
    // 2.让按钮缩放,计算缩放比例
    CGFloat scaleR = (offsetX/TScreen_Width - indexL);
    CGFloat scaleL = 1 - scaleR;
    CGFloat transformScale = maxTitleScale - 1;
    
    // 2.1 让左边按钮缩放
    leftButton.transform = CGAffineTransformMakeScale(transformScale * scaleL + 1, transformScale * scaleL + 1);
    
    // 2.2 让右边按钮缩放
    rightButton.transform = CGAffineTransformMakeScale(transformScale * scaleR + 1, transformScale * scaleR + 1);
    
    // 3.让按钮颜色渐变
    UIColor *leftColor = [UIColor colorWithRed:scaleL green:0 blue:0 alpha:1];
    UIColor *rightColor = [UIColor colorWithRed:0 green:scaleR blue:0 alpha:1];
    // 3.1 让左边按钮的颜色
    [leftButton setTitleColor:leftColor forState:UIControlStateNormal];
    // 3.2 让左边按钮的颜色
    [rightButton setTitleColor:rightColor forState:UIControlStateNormal];
}


- (void)setupNavItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_15x14"] style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_15x14"] style:UIBarButtonItemStyleDone target:self action:nil];
}


-(NSMutableArray *)titleButtons{
    if (!_titleButtons) {
        _titleButtons = @[].mutableCopy ;
    }
    return _titleButtons ;
}

@end
