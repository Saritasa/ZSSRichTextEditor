
#import "ZSSToolbarView.h"
#import "ZSSBarButtonItem.h"

@interface ZSSToolbarView ()

@property (nonatomic) UIToolbar *backgroundToolbar;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIToolbar *toolbar;
@property (nonatomic) NSArray<ZSSBarButtonItem *> *items;

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
        [_toolbar setBackgroundImage:[ZSSToolbarView transparentPixel]
                  forToolbarPosition:UIBarPositionBottom
                          barMetrics:UIBarMetricsDefault];
        [_scrollView addSubview:_toolbar];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutWithToolbarWidth:self.toolbar.frame.size.width];

    // Make sure that scroll view is always on top.
    // Otherwise in iOS11 it's under _UIToolbarContentView.
    [self.scrollView.superview bringSubviewToFront:self.scrollView];
}

- (void)layoutWithToolbarWidth:(CGFloat)toolbarWidth
{
    self.backgroundToolbar.frame = self.bounds;
    self.scrollView.frame = self.bounds;
    self.toolbar.frame = CGRectMake(0.0, 0.0, toolbarWidth, self.bounds.size.height);
    self.scrollView.contentSize = CGSizeMake(toolbarWidth, self.bounds.size.height);
}

- (void)setItems:(nonnull NSArray<ZSSBarButtonItem *> *)items animated:(BOOL)animated
{
    // TODO: find a way to calculate width based on actual width of toolbar buttons.
    [self layoutWithToolbarWidth:[items count] * 40.0];

    self.items = items;
    [self.toolbar setItems:items animated:animated];
}

+ (UIImage *)transparentPixel
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(nil, 1, 1, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGContextRelease(context);
    return image;
}

@end
