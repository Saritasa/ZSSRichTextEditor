//
//  ZSSBarButtonItem.m
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 12/3/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//

#import "ZSSBarButtonItem.h"

@interface ZSSBarButtonItem ()

@property (nonatomic) NSString *label;
@property (nonatomic) ZSSBarButtonItemType itemType;

@end

@implementation ZSSBarButtonItem

+ (ZSSBarButtonItem *)barButtonItemForItemType:(ZSSBarButtonItemType)itemType
{
    UIImage *image = [self imageForItemType:itemType];
    ZSSBarButtonItem *item = [[ZSSBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:nil action:nil];
    item.label = [self labelForItemType:itemType];
    item.itemType = itemType;
    return item;
}

+ (ZSSBarButtonItem *)barButtonItemWithImage:(UIImage *)image label:(NSString *)label
{
    ZSSBarButtonItem *item = [[ZSSBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:nil action:nil];
    item.label = label;
    item.itemType = ZSSBarButtonItemTypeCustom;
    return item;
}

+ (UIImage *)imageForItemType:(ZSSBarButtonItemType)defaultItem
{
    NSBundle* bundle = [NSBundle bundleForClass:[ZSSBarButtonItem class]];
    switch (defaultItem) {
        case ZSSBarButtonItemTypeBold:
            return [UIImage imageNamed:@"ZSSbold.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeItalic:
            return [UIImage imageNamed:@"ZSSitalic.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeSubscript:
            return [UIImage imageNamed:@"ZSSsubscript.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeSuperscript:
            return [UIImage imageNamed:@"ZSSsuperscript.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeStrikeThrough:
            return [UIImage imageNamed:@"ZSSstrikethrough.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeUnderline:
            return [UIImage imageNamed:@"ZSSunderline.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeRemoveFormat:
            return [UIImage imageNamed:@"ZSSclearstyle.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeJustifyLeft:
            return [UIImage imageNamed:@"ZSSleftjustify.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeJustifyCenter:
            return [UIImage imageNamed:@"ZSScenterjustify.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeJustifyRight:
            return [UIImage imageNamed:@"ZSSrightjustify.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeJustifyFull:
            return [UIImage imageNamed:@"ZSSforcejustify.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeH1:
            return [UIImage imageNamed:@"ZSSh1.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeH2:
            return [UIImage imageNamed:@"ZSSh2.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeH3:
            return [UIImage imageNamed:@"ZSSh3.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeH4:
            return [UIImage imageNamed:@"ZSSh4.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeH5:
            return [UIImage imageNamed:@"ZSSh5.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeH6:
            return [UIImage imageNamed:@"ZSSh6.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeTextColor:
            return [UIImage imageNamed:@"ZSStextcolor.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeUnorderedList:
            return [UIImage imageNamed:@"ZSSunorderedlist.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeOrderedList:
            return [UIImage imageNamed:@"ZSSorderedlist.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeHorizontalRule:
            return [UIImage imageNamed:@"ZSShorizontalrule.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeIndent:
            return [UIImage imageNamed:@"ZSSindent.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeOutdent:
            return [UIImage imageNamed:@"ZSSoutdent.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeInsertLink:
            return [UIImage imageNamed:@"ZSSlink.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeRemoveLink:
            return [UIImage imageNamed:@"ZSSunlink.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeQuickLink:
            return [UIImage imageNamed:@"ZSSquicklink.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeUndo:
            return [UIImage imageNamed:@"ZSSundo.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeRedo:
            return [UIImage imageNamed:@"ZSSredo.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonItemTypeParagraph:
            return [UIImage imageNamed:@"ZSSparagraph.png" inBundle:bundle compatibleWithTraitCollection:nil];
        default:
            return nil;
    }
}

+ (NSString *)labelForItemType:(ZSSBarButtonItemType)defaultItem {
    switch (defaultItem) {
        case ZSSBarButtonItemTypeBold:
            return @"bold";
        case ZSSBarButtonItemTypeItalic:
            return @"italic";
        case ZSSBarButtonItemTypeSubscript:
            return @"subscript";
        case ZSSBarButtonItemTypeSuperscript:
            return @"superscript";
        case ZSSBarButtonItemTypeStrikeThrough:
            return @"strikeThrough";
        case ZSSBarButtonItemTypeUnderline:
            return @"underline";
        case ZSSBarButtonItemTypeRemoveFormat:
            return @"removeFormat";
        case ZSSBarButtonItemTypeJustifyLeft:
            return @"justifyLeft";
        case ZSSBarButtonItemTypeJustifyCenter:
            return @"justifyCenter";
        case ZSSBarButtonItemTypeJustifyRight:
            return @"justifyRight";
        case ZSSBarButtonItemTypeJustifyFull:
            return @"justifyFull";
        case ZSSBarButtonItemTypeH1:
            return @"h1";
        case ZSSBarButtonItemTypeH2:
            return @"h2";
        case ZSSBarButtonItemTypeH3:
            return @"h3";
        case ZSSBarButtonItemTypeH4:
            return @"h4";
        case ZSSBarButtonItemTypeH5:
            return @"h5";
        case ZSSBarButtonItemTypeH6:
            return @"h6";
        case ZSSBarButtonItemTypeTextColor:
            return @"textColor";
        case ZSSBarButtonItemTypeUnorderedList:
            return @"unorderedList";
        case ZSSBarButtonItemTypeOrderedList:
            return @"orderedList";
        case ZSSBarButtonItemTypeHorizontalRule:
            return @"horizontalRule";
        case ZSSBarButtonItemTypeIndent:
            return @"indent";
        case ZSSBarButtonItemTypeOutdent:
            return @"outdent";
        case ZSSBarButtonItemTypeInsertLink:
            return @"link";
        case ZSSBarButtonItemTypeRemoveLink:
            return @"removeLink";
        case ZSSBarButtonItemTypeQuickLink:
            return @"quickLink";
        case ZSSBarButtonItemTypeUndo:
            return @"undo";
        case ZSSBarButtonItemTypeRedo:
            return @"redo";
        case ZSSBarButtonItemTypeParagraph:
            return @"p";
        default:
            return nil;
    }
}

@end
