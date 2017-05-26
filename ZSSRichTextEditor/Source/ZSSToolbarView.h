
#import <UIKit/UIKit.h>

@class ZSSBarButtonItem;

@interface ZSSToolbarView : UIView

@property (nonatomic, readonly, nonnull) NSArray<ZSSBarButtonItem *> *items;

- (void)setItems:(nonnull NSArray<ZSSBarButtonItem *> *)items animated:(BOOL)animated;

@end
