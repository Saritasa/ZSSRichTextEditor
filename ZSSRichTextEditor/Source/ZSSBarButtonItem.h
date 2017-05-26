//
//  ZSSBarButtonItem.h
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 12/3/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZSSBarButtonItemType) {
    ZSSBarButtonItemTypeCustom = 0,
    ZSSBarButtonItemTypeBold,
    ZSSBarButtonItemTypeItalic,
    ZSSBarButtonItemTypeSubscript,
    ZSSBarButtonItemTypeSuperscript,
    ZSSBarButtonItemTypeStrikeThrough,
    ZSSBarButtonItemTypeUnderline,
    ZSSBarButtonItemTypeRemoveFormat,
    ZSSBarButtonItemTypeJustifyLeft,
    ZSSBarButtonItemTypeJustifyCenter,
    ZSSBarButtonItemTypeJustifyRight,
    ZSSBarButtonItemTypeJustifyFull,
    ZSSBarButtonItemTypeH1,
    ZSSBarButtonItemTypeH2,
    ZSSBarButtonItemTypeH3,
    ZSSBarButtonItemTypeH4,
    ZSSBarButtonItemTypeH5,
    ZSSBarButtonItemTypeH6,
    ZSSBarButtonItemTypeTextColor,
    ZSSBarButtonItemTypeUnorderedList,
    ZSSBarButtonItemTypeOrderedList,
    ZSSBarButtonItemTypeHorizontalRule,
    ZSSBarButtonItemTypeIndent,
    ZSSBarButtonItemTypeOutdent,
    ZSSBarButtonItemTypeInsertLink,
    ZSSBarButtonItemTypeRemoveLink,
    ZSSBarButtonItemTypeQuickLink,
    ZSSBarButtonItemTypeUndo,
    ZSSBarButtonItemTypeRedo,
    ZSSBarButtonItemTypeParagraph,
};

@interface ZSSBarButtonItem : UIBarButtonItem

/**
 A label of the bar button item. Useful for identifying the bar button item and user actions.
 */
@property (nonatomic, readonly, nullable) NSString *label;

/**
 An item type of the bar button item.
 */
@property (nonatomic, readonly) ZSSBarButtonItemType itemType;

/**
 Returns new bar button item.
 */
+ (nonnull ZSSBarButtonItem *)barButtonItemForItemType:(ZSSBarButtonItemType)itemType;

/**
 Returns custom bar button item with an image and a label.
 */
+ (nonnull ZSSBarButtonItem *)barButtonItemWithImage:(nonnull UIImage *)image label:(nonnull NSString *)label;

@end
