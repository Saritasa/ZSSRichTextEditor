//
//  ZSSRichTextEditorViewController.m
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 11/30/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "ZSSRichTextEditor.h"
#import "ZSSToolbarView.h"
#import "ZSSBarButtonItem.h"
#import "HRColorUtil.h"
#import "CJWWebView+HackishAccessoryHiding.h"
#import <WebKit/WebKit.h>

@import JavaScriptCore;

@interface ZSSRichTextEditor () <WKNavigationDelegate, UIScrollViewDelegate, HRColorPickerViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) ZSSToolbarView *toolbarView;

/*
 *  UIWebView for writing/editing/displaying the content
 */
@property (nonatomic, strong) WKWebView *editorView;

/*
 *  NSString holding the selected links URL value
 */
@property (nonatomic, strong) NSString *selectedLinkURL;

/*
 *  NSString holding the selected links title value
 */
@property (nonatomic, strong) NSString *selectedLinkTitle;

/*
 *  NSString holding the html
 */
@property (nonatomic, strong) NSString *internalHTML;

/*
 *  NSString holding the css
 */
@property (nonatomic, strong) NSString *customCSS;

@property (nonatomic) BOOL editorLoaded;

@property (nonatomic) NSArray *highlightedBarButtonLabels;

@end

@implementation ZSSRichTextEditor

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.toolbarView = [[ZSSToolbarView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 44.0)];

    self.editorLoaded = NO;
    self.formatHTML = NO;
    self.editingEnabled = YES;

    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.dataDetectorTypes = WKDataDetectorTypeNone;
    self.editorView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    self.editorView.navigationDelegate = self;
    self.editorView.scrollView.delegate = self;
    self.editorView.opaque = NO;

    self.editorView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.editorView];

    UIView *view = [self.editorView cjw_hackishlyFoundBrowserView];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    recognizer.delegate = self;
    [view addGestureRecognizer:recognizer];

    [self loadResources];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.editorView.frame = self.bounds;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.editorView.backgroundColor = backgroundColor;
}

- (UIColor *)backgroundColor
{
    return [super backgroundColor];
}

- (void)evaluateJavaScript:(NSString *)js
{
    [self.editorView evaluateJavaScript:js completionHandler:^(id _Nullable object, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"ZSSRichTextEditor Error: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - Resources Section

- (void)loadResources {

    //Define correct bundle for loading resources
    NSBundle* bundle = [NSBundle bundleForClass:[ZSSRichTextEditor class]];

    //Create a string with the contents of editor.html
    NSString *filePath = [bundle pathForResource:@"editor" ofType:@"html"];
    NSData *htmlData = [NSData dataWithContentsOfFile:filePath];
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];

    //Add jQuery.js to the html file
    NSString *jquery = [bundle pathForResource:@"jQuery" ofType:@"js"];
    NSString *jqueryString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:jquery] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!-- jQuery -->" withString:jqueryString];

    //Add JSBeautifier.js to the html file
    NSString *beautifier = [bundle pathForResource:@"JSBeautifier" ofType:@"js"];
    NSString *beautifierString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:beautifier] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!-- jsbeautifier -->" withString:beautifierString];

    //Add ZSSRichTextEditor.js to the html file
    NSString *source = [bundle pathForResource:@"ZSSRichTextEditor" ofType:@"js"];
    NSString *jsString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:source] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!--editor-->" withString:jsString];

    [self.editorView loadHTMLString:htmlString baseURL:self.baseURL];
}

#pragma mark - Toolbar Section

- (void)setToolbarItemTintColor:(UIColor *)toolbarItemTintColor
{
    _toolbarItemTintColor = toolbarItemTintColor;
    [self updateHighlightForBarButtonItems];
}

- (void)setToolbarItemSelectedTintColor:(UIColor *)toolbarItemSelectedTintColor
{
    _toolbarItemSelectedTintColor = toolbarItemSelectedTintColor;
    [self updateHighlightForBarButtonItems];
}

#pragma mark - Editor Modification Section

- (void)setCSS:(NSString *)css {

    self.customCSS = css;

    if (self.editorLoaded) {
        [self updateCSS];
    }
}

- (void)updateCSS {

    if (self.customCSS != NULL && [self.customCSS length] != 0) {

        NSString *js = [NSString stringWithFormat:@"zss_editor.setCustomCSS(\"%@\");", self.customCSS];
        [self evaluateJavaScript:js];
    }
}

- (void)setPlaceholderText {

    //Call the setPlaceholder javascript method if a placeholder has been set
    if (self.placeholder != NULL && [self.placeholder length] != 0) {

        NSString *js = [NSString stringWithFormat:@"zss_editor.setPlaceholder(\"%@\");", self.placeholder];
        [self evaluateJavaScript:js];
    }
}

#pragma mark - Editor Interaction

- (void)tapGestureAction:(UITapGestureRecognizer *)recognizer
{
    if (!self.isFocused) {
        [self focusTextEditor];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    self.editorView.scrollView.scrollEnabled = scrollEnabled;
}

- (BOOL)scrollEnabled
{
    return self.editorView.scrollView.isScrollEnabled;
}

- (CGSize)contentSize
{
    return self.editorView.scrollView.contentSize;
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    [self.editorView.scrollView scrollRectToVisible:rect animated:animated];
}

- (void)setEditingEnabled:(BOOL)editingEnabled
{
    _editingEnabled = editingEnabled;
    self.editorView.cjw_inputAccessoryView = editingEnabled ? self.toolbarView : nil;
    if (self.editorLoaded) {
        NSString *js = [NSString stringWithFormat:@"zss_editor.setContentEditable(%@);", editingEnabled ? @"true" : @"false"];
        [self evaluateJavaScript:js];
    }
}

- (void)setClearsFormatOnPaste:(BOOL)clearsFormatOnPaste
{
    _clearsFormatOnPaste = clearsFormatOnPaste;
    if (self.editorLoaded) {
        NSString *js = [NSString stringWithFormat:@"zss_editor.clearsFormatOnPaste = %@;", clearsFormatOnPaste ? @"true" : @"false"];
        [self evaluateJavaScript:js];
    }
}

- (BOOL)isFocused
{
    return [ZSSRichTextEditor viewContainsFirstResponder:self.editorView];
}

- (void)focusTextEditor
{
    if (self.editingEnabled) {
        NSString *js = [NSString stringWithFormat:@"zss_editor.focusEditor();"];
        [self evaluateJavaScript:js];
    }
}

- (void)blurTextEditor {
    NSString *js = [NSString stringWithFormat:@"zss_editor.blurEditor();"];
    [self evaluateJavaScript:js];
}

- (void)setHTML:(NSString *)html {

    self.internalHTML = html;

    if (self.editorLoaded) {
        [self updateHTML];
    }
}

- (void)updateHTML {

    NSString *html = self.internalHTML;
    NSString *cleanedHTML = [self removeQuotesFromHTML:html];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.setHTML(\"%@\");", cleanedHTML];
    [self evaluateJavaScript:trigger];
}

- (void)insertHTML:(NSString *)html {

    NSString *cleanedHTML = [self removeQuotesFromHTML:html];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertHTML(\"%@\");", cleanedHTML];
    [self evaluateJavaScript:trigger];

}

- (void)getHTMLAndTextWithCompletionHandler:(void (^)(NSString *html, NSString *text))completion
{
    [self.editorView evaluateJavaScript:@"zss_editor.getHTML();" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
        NSString *html = object;
        html = [self removeQuotesFromHTML:html];
        [self tidyHTML:html completionHandler:^(NSString *html) {
            [self.editorView evaluateJavaScript:@"zss_editor.getText();" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
                NSString *text = object;
                completion(html, text);
            }];
        }];
    }];
}

- (void)dismissKeyboard {
    [self endEditing:YES];
}

- (void)setHeading:(NSString *)heading {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.setHeading('%@');", heading];
    [self evaluateJavaScript:trigger];
}

- (void)textColor {

    // Save the selection location
    [self evaluateJavaScript:@"zss_editor.prepareInsert();"];

    // Call the picker
    HRColorPickerViewController *colorPicker = [HRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:[UIColor whiteColor]];
    colorPicker.delegate = self;
    colorPicker.tag = 1;
    colorPicker.title = NSLocalizedString(@"Text Color", nil);
    [self.viewController.navigationController pushViewController:colorPicker animated:YES];
}

- (void)setSelectedColor:(UIColor*)color tag:(int)tag {

    NSString *hex = [NSString stringWithFormat:@"#%06x",HexColorFromUIColor(color)];
    NSString *trigger;
    if (tag == 1) {
        trigger = [NSString stringWithFormat:@"zss_editor.setTextColor(\"%@\");", hex];
    } else if (tag == 2) {
        trigger = [NSString stringWithFormat:@"zss_editor.setBackgroundColor(\"%@\");", hex];
    }
    [self evaluateJavaScript:trigger];
}

- (void)showInsertLinkDialogWithLink:(NSString *)url title:(NSString *)title {

    // Insert Button Title
    NSString *insertButtonTitle = !self.selectedLinkURL ? NSLocalizedString(@"Insert", nil) : NSLocalizedString(@"Update", nil);

    // Picker Button
    UIButton *am = [UIButton buttonWithType:UIButtonTypeCustom];
    am.frame = CGRectMake(0, 0, 25, 25);
    [am setImage:[UIImage imageNamed:@"ZSSpicker.png" inBundle:[NSBundle bundleForClass:[ZSSRichTextEditor class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [am addTarget:self action:@selector(showInsertURLAlternatePicker) forControlEvents:UIControlEventTouchUpInside];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Insert Link", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"URL (required)", nil);
        if (url) {
            textField.text = url;
        }
        textField.rightView = am;
        textField.rightViewMode = UITextFieldViewModeAlways;
        textField.clearButtonMode = UITextFieldViewModeAlways;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Title", nil);
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.secureTextEntry = NO;
        if (title) {
            textField.text = title;
        }
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self focusTextEditor];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:insertButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        UITextField *linkURL = [alertController.textFields objectAtIndex:0];
        UITextField *title = [alertController.textFields objectAtIndex:1];
        if (!self.selectedLinkURL) {
            [self insertLink:linkURL.text title:title.text];
            //NSLog(@"insert link");
        } else {
            [self updateLink:linkURL.text title:title.text];
        }
        [self focusTextEditor];
    }]];
    [self.viewController presentViewController:alertController animated:YES completion:NULL];
}

- (void)insertLink:(NSString *)url title:(NSString *)title {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertLink(\"%@\", \"%@\");", url, title];
    [self evaluateJavaScript:trigger];
}

- (void)updateLink:(NSString *)url title:(NSString *)title {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.updateLink(\"%@\", \"%@\");", url, title];
    [self evaluateJavaScript:trigger];
}

- (void)updateToolBarWithButtonName:(NSString *)name {

    // Items that are enabled
    NSArray *itemNames = [name componentsSeparatedByString:@","];

    // Special case for link
    NSMutableArray *itemsModified = [[NSMutableArray alloc] init];
    for (NSString *linkItem in itemNames) {
        NSString *updatedItem = linkItem;
        if ([linkItem hasPrefix:@"link:"]) {
            updatedItem = @"link";
            self.selectedLinkURL = [linkItem stringByReplacingOccurrencesOfString:@"link:" withString:@""];
        } else if ([linkItem hasPrefix:@"link-title:"]) {
            self.selectedLinkTitle = [self stringByDecodingURLFormat:[linkItem stringByReplacingOccurrencesOfString:@"link-title:" withString:@""]];
        } else {
            self.selectedLinkURL = nil;
            self.selectedLinkTitle = nil;
        }
        [itemsModified addObject:updatedItem];
    }

    self.highlightedBarButtonLabels = [itemsModified copy];
    [self updateHighlightForBarButtonItems];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // Allow other recognizers to work simultaneously with our.
    return YES;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        BOOL shouldInteract = NO;
        if ([self.delegate respondsToSelector:@selector(richTextEditor:shouldInteractWithURL:)]) {
            shouldInteract = [self.delegate richTextEditor:self shouldInteractWithURL:navigationAction.request.URL];
        }
        if (shouldInteract) {
            decisionHandler(WKNavigationActionPolicyCancel);
        } else {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
        return;
    }

    NSString *urlString = navigationAction.request.URL.absoluteString;
    if ([urlString rangeOfString:@"callback://0/"].location != NSNotFound) {

        // We recieved the callback
        NSString *className = [urlString stringByReplacingOccurrencesOfString:@"callback://0/" withString:@""];
        [self updateToolBarWithButtonName:className];

        // There could be some changes after this callback and we need to make sure that
        // we notify about them our delegate.
        if ([self.delegate respondsToSelector:@selector(richTextEditor:didChangeText:html:)]) {
            [self getHTMLAndTextWithCompletionHandler:^(NSString *html, NSString *text) {
                [self.delegate richTextEditor:self didChangeText:text html:html];
            }];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }

    if ([urlString rangeOfString:@"scroll://"].location != NSNotFound) {
        NSInteger position = [[urlString stringByReplacingOccurrencesOfString:@"scroll://" withString:@""] integerValue];
        if ([self.delegate respondsToSelector:@selector(richTextEditor:didScrollToPosition:)]) {
            [self.delegate richTextEditor:self didScrollToPosition:position];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }

    if ([urlString rangeOfString:@"zss-callback/"].location != NSNotFound) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    self.editorLoaded = YES;

    __weak typeof(self) weakSelf = self;
    JSContext *ctx = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    ctx[@"onInput"] = ^(JSValue *msg) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (weakSelf) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [self getHTMLAndTextWithCompletionHandler:^(NSString *html, NSString *text) {
                    if ([strongSelf.delegate respondsToSelector:@selector(richTextEditor:didChangeText:html:)]) {
                        [strongSelf.delegate richTextEditor:strongSelf didChangeText:text html:html];
                    }
                    [strongSelf checkForMentionOrHashtagInText:text];
                }];
            }
        }];
    };

    ctx[@"onFocus"] = ^(JSValue *msg) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (weakSelf) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf performSelector:@selector(relayoutHack) withObject:nil afterDelay:0.1];
            }
        }];
    };

    ctx[@"onContentHeightChange"] = ^(JSValue *msg) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (weakSelf) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if ([strongSelf.delegate respondsToSelector:@selector(richTextEditor:didChangeContentHeight:)]) {
                    CGFloat h = ceil([[msg toObject] floatValue]);
                    [strongSelf.delegate richTextEditor:strongSelf didChangeContentHeight:h];
                }
            }
        }];
    };

    ctx[@"onCaretYPositionChange"] = ^(JSValue *msg1, JSValue *msg2) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (weakSelf) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if ([strongSelf.delegate respondsToSelector:@selector(richTextEditor:didChangeCaretYPostion:lineHeight:)]) {
                    CGFloat y = ceil([[msg1 toObject] floatValue]);
                    CGFloat h = ceil([[msg2 toObject] floatValue] * 1.2); // Increase the height of the cursor.
                    [strongSelf.delegate richTextEditor:self didChangeCaretYPostion:y lineHeight:h];
                }
            }
        }];
    };

    ctx[@"editorLog"] = ^(JSValue *message) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (weakSelf) {
                NSLog(@"Editor: %@", [message toObject]);
            }
        }];
    };

    if (!self.internalHTML) {
        self.internalHTML = @"";
    }
    [self updateHTML];

    if(self.placeholder) {
        [self setPlaceholderText];
    }

    if (self.customCSS) {
        [self updateCSS];
    }

    self.editingEnabled = self.editingEnabled;
    self.clearsFormatOnPaste = self.clearsFormatOnPaste;

    if ([self.delegate respondsToSelector:@selector(richTextEditorDidFinishLoad:)]) {
        [self.delegate richTextEditorDidFinishLoad:self];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.scrollEnabled) {
        scrollView.bounds = self.editorView.bounds;
    }
}

#pragma mark - Mention & Hashtag Support Section

- (void)checkForMentionOrHashtagInText:(NSString *)text {

    if ([text containsString:@" "] && [text length] > 0) {

        NSString *lastWord = nil;
        NSString *matchedWord = nil;
        BOOL containsHashtag = NO;
        BOOL containsMention = NO;

        NSRange range = [text rangeOfString:@" " options:NSBackwardsSearch];
        lastWord = [text substringFromIndex:range.location];

        if (lastWord != nil) {

            //Check if last word typed starts with a #
            NSRegularExpression *hashtagRegex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:nil];
            NSArray *hashtagMatches = [hashtagRegex matchesInString:lastWord options:0 range:NSMakeRange(0, lastWord.length)];

            for (NSTextCheckingResult *match in hashtagMatches) {

                NSRange wordRange = [match rangeAtIndex:1];
                NSString *word = [lastWord substringWithRange:wordRange];
                matchedWord = word;
                containsHashtag = YES;

            }

            if (!containsHashtag) {

                //Check if last word typed starts with a @
                NSRegularExpression *mentionRegex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:nil];
                NSArray *mentionMatches = [mentionRegex matchesInString:lastWord options:0 range:NSMakeRange(0, lastWord.length)];

                for (NSTextCheckingResult *match in mentionMatches) {
                    NSRange wordRange = [match rangeAtIndex:1];
                    NSString *word = [lastWord substringWithRange:wordRange];
                    matchedWord = word;
                    containsMention = YES;
                }
            }
        }

        if (containsHashtag) {
            if ([self.delegate respondsToSelector:@selector(richTextEditor:didRecognizeHashtag:)]) {
                [self.delegate richTextEditor:self didRecognizeHashtag:matchedWord];
            }
        }

        if (containsMention) {
            if ([self.delegate respondsToSelector:@selector(richTextEditor:didRecognizeMention:)]) {
                [self.delegate richTextEditor:self didRecognizeMention:matchedWord];
            }
        }
    }
}

- (void)barButtonItemAction:(ZSSBarButtonItem *)sender
{
    switch (sender.itemType) {
        case ZSSBarButtonItemTypeBold:
            [self evaluateJavaScript:@"zss_editor.setBold();"];
            break;
        case ZSSBarButtonItemTypeItalic:
            [self evaluateJavaScript:@"zss_editor.setItalic();"];
            break;
        case ZSSBarButtonItemTypeSubscript:
            [self evaluateJavaScript:@"zss_editor.setSubscript();"];
            break;
        case ZSSBarButtonItemTypeSuperscript:
            [self evaluateJavaScript: @"zss_editor.setSuperscript();"];
            break;
        case ZSSBarButtonItemTypeStrikeThrough:
            [self evaluateJavaScript:@"zss_editor.setStrikeThrough();"];
            break;
        case ZSSBarButtonItemTypeUnderline:
            [self evaluateJavaScript:@"zss_editor.setUnderline();"];
            break;
        case ZSSBarButtonItemTypeRemoveFormat:
            [self evaluateJavaScript:@"zss_editor.removeFormating();"];
            break;
        case ZSSBarButtonItemTypeJustifyLeft:
            [self evaluateJavaScript:@"zss_editor.setJustifyLeft();"];
            break;
        case ZSSBarButtonItemTypeJustifyCenter:
            [self evaluateJavaScript:@"zss_editor.setJustifyCenter();"];
            break;
        case ZSSBarButtonItemTypeJustifyRight:
            [self evaluateJavaScript:@"zss_editor.setJustifyRight();"];
            break;
        case ZSSBarButtonItemTypeJustifyFull:
            [self evaluateJavaScript:@"zss_editor.setJustifyFull();"];
            break;
        case ZSSBarButtonItemTypeH1:
        case ZSSBarButtonItemTypeH2:
        case ZSSBarButtonItemTypeH3:
        case ZSSBarButtonItemTypeH4:
        case ZSSBarButtonItemTypeH5:
        case ZSSBarButtonItemTypeH6:
            [self setHeading:sender.label];
            break;
        case ZSSBarButtonItemTypeTextColor:
            [self textColor];
            break;
        case ZSSBarButtonItemTypeUnorderedList:
            [self evaluateJavaScript:@"zss_editor.setUnorderedList();"];
            break;
        case ZSSBarButtonItemTypeOrderedList:
            [self evaluateJavaScript:@"zss_editor.setOrderedList();"];
            break;
        case ZSSBarButtonItemTypeHorizontalRule:
            [self evaluateJavaScript:@"zss_editor.setHorizontalRule();"];
            break;
        case ZSSBarButtonItemTypeIndent:
            [self evaluateJavaScript:@"zss_editor.setIndent();"];
            break;
        case ZSSBarButtonItemTypeOutdent:
            [self evaluateJavaScript:@"zss_editor.setOutdent();"];
            break;
        case ZSSBarButtonItemTypeInsertLink: {
            // Save the selection location
            [self evaluateJavaScript:@"zss_editor.prepareInsert();"];
            // Show the dialog for inserting or editing a link
            [self showInsertLinkDialogWithLink:self.selectedLinkURL title:self.selectedLinkTitle];
        }
            break;
        case ZSSBarButtonItemTypeRemoveLink:
            [self evaluateJavaScript:@"zss_editor.unlink();"];
            break;
        case ZSSBarButtonItemTypeQuickLink:
            [self evaluateJavaScript:@"zss_editor.quickLink();"];
            break;
        case ZSSBarButtonItemTypeUndo:
            [self evaluateJavaScript:@"zss_editor.undo();"];
            break;
        case ZSSBarButtonItemTypeRedo:
            [self evaluateJavaScript:@"zss_editor.redo();"];
            break;
        case ZSSBarButtonItemTypeParagraph:
            [self evaluateJavaScript:@"zss_editor.setParagraph();"];
            break;
        default:
            if ([self.delegate respondsToSelector:@selector(richTextEditor:didReceiveUnrecognizedActionLabel:)]) {
                [self.delegate richTextEditor:self didReceiveUnrecognizedActionLabel:sender.label];
            }
    }
}

- (void)setToolbarItems:(nonnull NSArray<ZSSBarButtonItem *> *)items animated:(BOOL)animated
{
    [self.toolbarView setItems:items animated:animated];
    for (ZSSBarButtonItem *item in items) {
        item.target = self;
        item.action = @selector(barButtonItemAction:);
    }
    [self updateHighlightForBarButtonItems];
}

#pragma mark - Asset Picker

- (void)showInsertURLAlternatePicker {
    // Blank method. User should implement this in their subclass
}

#pragma mark - Utilities

- (void)updateHighlightForBarButtonItems
{
    for (ZSSBarButtonItem *item in self.toolbarView.items) {
        if ([self.highlightedBarButtonLabels containsObject:item.label]) {
            item.tintColor = [self barButtonItemSelectedDefaultColor];
        } else {
            item.tintColor = [self barButtonItemDefaultColor];
        }
    }
}

- (NSString *)removeQuotesFromHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"“" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"”" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"\r"  withString:@"\\r"];
    html = [html stringByReplacingOccurrencesOfString:@"\n"  withString:@"\\n"];
    return html;
}


- (NSString *)tidyHTML:(NSString *)html completionHandler:(void (^)(NSString *))completion {
    // When user stats typing "Foo" then hits enter the html will be "Foo<div><br></div>".
    // We solve it by replacing div and 2 br tags.
    html = [html stringByReplacingOccurrencesOfString:@"<div>" withString:@"<br>"];
    html = [html stringByReplacingOccurrencesOfString:@"<\/div>" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"<br><br>" withString:@"<br>"];
    if (self.formatHTML) {
        NSString *js = [NSString stringWithFormat:@"style_html(\"%@\");", html];
        [self.editorView evaluateJavaScript:js completionHandler:^(id _Nullable object, NSError * _Nullable error) {
            if ([object isKindOfClass:[NSString class]]) {
                completion(object);
            } else {
                completion(nil);
            }
        }];
    } else {
        completion(html);
    }
}

- (UIColor *)barButtonItemDefaultColor {

    if (self.toolbarItemTintColor) {
        return self.toolbarItemTintColor;
    }

    return [UIColor colorWithRed:0.0f/255.0f green:122.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
}


- (UIColor *)barButtonItemSelectedDefaultColor {

    if (self.toolbarItemSelectedTintColor) {
        return self.toolbarItemSelectedTintColor;
    }

    return [UIColor blackColor];
}


- (NSString *)stringByDecodingURLFormat:(NSString *)string {
    NSString *result = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

/**
 Fixes strange issue when rich text editor is in bottom part of the screen.
 Without this hack you will be able to reproduce it:
 - editor should be on scroll view (TPKeyboardAvoidingScrollView in our case) in bottom part of the screen.
 - user taps on editor
 - iOS shows keyboard
 - when you try to scroll the editor, scrolling goes past the content and scroll indicators aren't visible.
 */
- (void)relayoutHack
{
    self.editorView.frame = CGRectMake(0.0, 0.0, self.bounds.size.width + 1.0, self.bounds.size.height + 1.0);
    // We don't bother to change it back because `layoutSubviews` will be called after.
}

/**
 Recursively checks the view hierarchy whether the view is first responder or not.
 */
+ (BOOL)viewContainsFirstResponder:(UIView *)view
{
    if (view.isFirstResponder) {
        return YES;
    }

    for (UIView *childView in view.subviews) {
        if ([ZSSRichTextEditor viewContainsFirstResponder:childView]) {
            return YES;
        }
    }
    return NO;
}

@end
