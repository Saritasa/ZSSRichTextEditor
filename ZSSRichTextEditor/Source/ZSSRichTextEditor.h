//
//  ZSSRichTextEditorViewController.h
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 11/30/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRColorPickerViewController.h"

@class ZSSRichTextEditor;
@class ZSSToolbarView;
@class ZSSBarButtonItem;

@protocol ZSSRichTextEditorDelegate <NSObject>

@optional

- (void)richTextEditor:(nonnull ZSSRichTextEditor *)editor didChangeText:(nullable NSString *)text html:(nullable NSString *)html;

- (void)richTextEditor:(nonnull ZSSRichTextEditor *)editor didScrollToPosition:(NSInteger)position;

- (void)richTextEditor:(nonnull ZSSRichTextEditor *)editor didRecognizeHashtag:(nullable NSString *)hashtag;

- (void)richTextEditor:(nonnull ZSSRichTextEditor *)editor didRecognizeMention:(nullable NSString *)mention;

- (void)richTextEditor:(nonnull ZSSRichTextEditor *)editor didReceiveUnrecognizedActionLabel:(nullable NSString *)label;

- (BOOL)richTextEditor:(nonnull ZSSRichTextEditor *)editor shouldInteractWithURL:(nullable NSURL *)url;

- (void)richTextEditor:(nonnull ZSSRichTextEditor *)editor didChangeContentHeight:(CGFloat)height;

- (void)richTextEditorDidFinishLoad:(nonnull ZSSRichTextEditor *)editor;

- (void)richTextEditor:(nonnull ZSSRichTextEditor *)editor
didChangeCaretYPostion:(CGFloat)caretYPosition
            lineHeight:(CGFloat)lineHeight;

@end

/**
 *  The viewController used with ZSSRichTextEditor
 */
@interface ZSSRichTextEditor : UIView

/**
 *  The base URL to use for the webView
 */
@property (nonatomic, strong, nullable) NSURL *baseURL;

/**
 *  If the HTML should be formatted to be pretty
 */
@property (nonatomic) BOOL formatHTML;

/**
 Shows whether scroll should be enabled or not.
 */
@property (nonatomic) BOOL scrollEnabled;

/*
 *  Shows whether the editor is fully loaded and ready to accept events.
 */
@property (nonatomic, readonly) BOOL editorLoaded;

/**
 Shows whether editing enabled or not.
 */
@property (nonatomic) BOOL editingEnabled;

/**
 Shows whether the editor clears formatting on paste.
 */
@property (nonatomic) BOOL clearsFormatOnPaste;

/**
 *  The placeholder text to use if there is no editor content
 */
@property (nonatomic, strong, nullable) NSString *placeholder;

/**
 *  Color to tint the toolbar items
 */
@property (nonatomic, strong, nonnull) UIColor *toolbarItemTintColor;

/**
 *  Color to tint selected items
 */
@property (nonatomic, strong, nonnull) UIColor *toolbarItemSelectedTintColor;

/**
 Content size of the inner scroll view.
 */
@property (nonatomic, readonly) CGSize contentSize;

/**
 Parent view controller to present additional controllers.
 */
@property (nonatomic, weak, nullable) UIViewController *viewController;

/**
 A delegate of the text editor.
 */
@property (nonatomic, weak, nullable) id<ZSSRichTextEditorDelegate> delegate;

/**
 *  Sets the HTML for the entire editor
 *
 *  @param html  HTML string to set for the editor
 *
 */
- (void)setHTML:(nullable NSString *)html;

/**
 *  Inserts HTML at the caret position
 *
 *  @param html  HTML string to insert
 *
 */
- (void)insertHTML:(nullable NSString *)html;

/**
 *  Manually focuses on the text editor
 */
- (void)focusTextEditor;

/**
 *  Manually dismisses on the text editor
 */
- (void)blurTextEditor;

/**
 Scrolls internal scroll view to a provided rect.
 */
- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated;

/**
 *  Shows the insert link dialog with optional inputs
 *
 *  @param url   The URL for the link
 *  @param title The tile for the link
 */
- (void)showInsertLinkDialogWithLink:(nullable NSString *)url title:(nullable NSString *)title;

/**
 *  Inserts a link
 *
 *  @param url The URL for the link
 *  @param title The title for the link
 */
- (void)insertLink:(nullable NSString *)url title:(nullable NSString *)title;

/**
 *  Set custom css
 */
- (void)setCSS:(nullable NSString *)css;

/**
 Sets new toolbar items for a toolbar view.
 */
- (void)setToolbarItems:(nonnull NSArray<ZSSBarButtonItem *> *)items animated:(BOOL)animated;

@end
