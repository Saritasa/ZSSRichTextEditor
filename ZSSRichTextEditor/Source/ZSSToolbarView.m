
#import "ZSSToolbarView.h"

@interface ZSSToolbarView ()

@property (nonatomic) UIToolbar *backgroundToolbar;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIToolbar *toolbar;

@end

@implementation ZSSToolbarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundToolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        [self addSubview:_backgroundToolbar];

        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        [_backgroundToolbar addSubview:_scrollView];

        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        _toolbar.backgroundColor = [UIColor clearColor];
        [_scrollView addSubview:_toolbar];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _backgroundToolbar.frame = self.bounds;
    _scrollView.frame = self.bounds;
}

@end
