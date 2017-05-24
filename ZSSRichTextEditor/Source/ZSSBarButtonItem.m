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

@end

@implementation ZSSBarButtonItem

+ (ZSSBarButtonItem *)barButtonItemForDefaultItem:(ZSSBarButtonDefaultItem)defaultItem
{
    UIImage *image = [self imageForDefaultItem:defaultItem];
    return [self barButtonItemWithImage:image label:[self labelForDefaultItem:defaultItem]];
}

+ (ZSSBarButtonItem *)barButtonItemWithImage:(UIImage *)image label:(NSString *)label
{
    ZSSBarButtonItem *item = [[ZSSBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:nil action:nil];
    item.label = label;
    return item;
}

+ (UIImage *)imageForDefaultItem:(ZSSBarButtonDefaultItem)defaultItem
{
    NSBundle* bundle = [NSBundle bundleForClass:[ZSSBarButtonItem class]];
    switch (defaultItem) {
        case ZSSBarButtonDefaultItemBold:
            return [UIImage imageNamed:@"ZSSbold.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemItalic:
            return [UIImage imageNamed:@"ZSSitalic.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemSubscript:
            return [UIImage imageNamed:@"ZSSsubscript.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemSuperscript:
            return [UIImage imageNamed:@"ZSSsuperscript.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemStrikeThrough:
            return [UIImage imageNamed:@"ZSSstrikethrough.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemUnderline:
            return [UIImage imageNamed:@"ZSSunderline.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemRemoveFormat:
            return [UIImage imageNamed:@"ZSSclearstyle.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemJustifyLeft:
            return [UIImage imageNamed:@"ZSSleftjustify.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemJustifyCenter:
            return [UIImage imageNamed:@"ZSScenterjustify.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemJustifyRight:
            return [UIImage imageNamed:@"ZSSrightjustify.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemJustifyFull:
            return [UIImage imageNamed:@"ZSSforcejustify.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemH1:
            return [UIImage imageNamed:@"ZSSh1.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemH2:
            return [UIImage imageNamed:@"ZSSh2.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemH3:
            return [UIImage imageNamed:@"ZSSh3.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemH4:
            return [UIImage imageNamed:@"ZSSh4.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemH5:
            return [UIImage imageNamed:@"ZSSh5.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemH6:
            return [UIImage imageNamed:@"ZSSh6.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemTextColor:
            return [UIImage imageNamed:@"ZSStextcolor.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemUnorderedList:
            return [UIImage imageNamed:@"ZSSunorderedlist.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemOrderedList:
            return [UIImage imageNamed:@"ZSSorderedlist.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemHorizontalRule:
            return [UIImage imageNamed:@"ZSShorizontalrule.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemIndent:
            return [UIImage imageNamed:@"ZSSindent.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemOutdent:
            return [UIImage imageNamed:@"ZSSoutdent.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemInsertLink:
            return [UIImage imageNamed:@"ZSSlink.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemRemoveLink:
            return [UIImage imageNamed:@"ZSSunlink.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemQuickLink:
            return [UIImage imageNamed:@"ZSSquicklink.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemUndo:
            return [UIImage imageNamed:@"ZSSundo.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemRedo:
            return [UIImage imageNamed:@"ZSSredo.png" inBundle:bundle compatibleWithTraitCollection:nil];
        case ZSSBarButtonDefaultItemParagraph:
            return [UIImage imageNamed:@"ZSSparagraph.png" inBundle:bundle compatibleWithTraitCollection:nil];
        default:
            return nil;
    }
}

+ (NSString *)labelForDefaultItem:(ZSSBarButtonDefaultItem)defaultItem {
    switch (defaultItem) {
        case ZSSBarButtonDefaultItemBold:
            return @"bold";
        case ZSSBarButtonDefaultItemItalic:
            return @"italic";
        case ZSSBarButtonDefaultItemSubscript:
            return @"subscript";
        case ZSSBarButtonDefaultItemSuperscript:
            return @"superscript";
        case ZSSBarButtonDefaultItemStrikeThrough:
            return @"strikeThrough";
        case ZSSBarButtonDefaultItemUnderline:
            return @"underline";
        case ZSSBarButtonDefaultItemRemoveFormat:
            return @"removeFormat";
        case ZSSBarButtonDefaultItemJustifyLeft:
            return @"justifyLeft";
        case ZSSBarButtonDefaultItemJustifyCenter:
            return @"justifyCenter";
        case ZSSBarButtonDefaultItemJustifyRight:
            return @"justifyRight";
        case ZSSBarButtonDefaultItemJustifyFull:
            return @"justifyFull";
        case ZSSBarButtonDefaultItemH1:
            return @"h1";
        case ZSSBarButtonDefaultItemH2:
            return @"h2";
        case ZSSBarButtonDefaultItemH3:
            return @"h3";
        case ZSSBarButtonDefaultItemH4:
            return @"h4";
        case ZSSBarButtonDefaultItemH5:
            return @"h5";
        case ZSSBarButtonDefaultItemH6:
            return @"h6";
        case ZSSBarButtonDefaultItemTextColor:
            return @"textColor";
        case ZSSBarButtonDefaultItemUnorderedList:
            return @"unorderedList";
        case ZSSBarButtonDefaultItemOrderedList:
            return @"orderedList";
        case ZSSBarButtonDefaultItemHorizontalRule:
            return @"horizontalRule";
        case ZSSBarButtonDefaultItemIndent:
            return @"indent";
        case ZSSBarButtonDefaultItemOutdent:
            return @"outdent";
        case ZSSBarButtonDefaultItemInsertLink:
            return @"link";
        case ZSSBarButtonDefaultItemRemoveLink:
            return @"removeLink";
        case ZSSBarButtonDefaultItemQuickLink:
            return @"quickLink";
        case ZSSBarButtonDefaultItemUndo:
            return @"undo";
        case ZSSBarButtonDefaultItemRedo:
            return @"redo";
        case ZSSBarButtonDefaultItemParagraph:
            return @"p";
        default:
            return nil;
    }
}

@end
