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
#import "ZSSBarButtonItem.h"
#import "HRColorUtil.h"

@import JavaScriptCore;


/**
 
 UIWebView modifications for hiding the inputAccessoryView
 
 **/
@interface UIWebView (HackishAccessoryHiding)
@property (nonatomic, assign) BOOL hidesInputAccessoryView;
@end

@implementation UIWebView (HackishAccessoryHiding)

static const char * const hackishFixClassName = "UIWebBrowserViewMinusAccessoryView";
static Class hackishFixClass = Nil;

- (UIView *)hackishlyFoundBrowserView {
    UIScrollView *scrollView = self.scrollView;
    
    UIView *browserView = nil;
    for (UIView *subview in scrollView.subviews) {
        if ([NSStringFromClass([subview class]) hasPrefix:@"UIWebBrowserView"]) {
            browserView = subview;
            break;
        }
    }
    return browserView;
}

- (id)methodReturningNil {
    return nil;
}

- (void)ensureHackishSubclassExistsOfBrowserViewClass:(Class)browserViewClass {
    if (!hackishFixClass) {
        Class newClass = objc_allocateClassPair(browserViewClass, hackishFixClassName, 0);
        newClass = objc_allocateClassPair(browserViewClass, hackishFixClassName, 0);
        IMP nilImp = [self methodForSelector:@selector(methodReturningNil)];
        class_addMethod(newClass, @selector(inputAccessoryView), nilImp, "@@:");
        objc_registerClassPair(newClass);
        
        hackishFixClass = newClass;
    }
}

- (BOOL) hidesInputAccessoryView {
    UIView *browserView = [self hackishlyFoundBrowserView];
    return [browserView class] == hackishFixClass;
}

- (void) setHidesInputAccessoryView:(BOOL)value {
    UIView *browserView = [self hackishlyFoundBrowserView];
    if (browserView == nil) {
        return;
    }
    [self ensureHackishSubclassExistsOfBrowserViewClass:[browserView class]];
    
    if (value) {
        object_setClass(browserView, hackishFixClass);
    }
    else {
        Class normalClass = objc_getClass("UIWebBrowserView");
        object_setClass(browserView, normalClass);
    }
    [browserView reloadInputViews];
}

@end


@interface ZSSRichTextEditor () <UIWebViewDelegate, HRColorPickerViewControllerDelegate>

/*
 *  String for the HTML
 */
@property (nonatomic, strong) NSString *htmlString;

/*
 *  UIWebView for writing/editing/displaying the content
 */
@property (nonatomic, strong) UIWebView *editorView;

/*
 *  NSString holding the selected links URL value
 */
@property (nonatomic, strong) NSString *selectedLinkURL;

/*
 *  NSString holding the selected links title value
 */
@property (nonatomic, strong) NSString *selectedLinkTitle;

/*
 *  Bar button item for the keyboard dismiss button in the toolbar
 */
@property (nonatomic, strong) UIBarButtonItem *keyboardItem;

/*
 *  Array for custom bar button items
 */
@property (nonatomic, strong) NSMutableArray *customBarButtonItems;

/*
 *  Array for custom ZSSBarButtonItems
 */
@property (nonatomic, strong) NSMutableArray *customZSSBarButtonItems;

/*
 *  NSString holding the html
 */
@property (nonatomic, strong) NSString *internalHTML;

/*
 *  NSString holding the css
 */
@property (nonatomic, strong) NSString *customCSS;

/*
 *  BOOL for if the editor is loaded or not
 */
@property (nonatomic) BOOL editorLoaded;

@end

/*
 
 ZSSRichTextEditor
 
 */
@implementation ZSSRichTextEditor

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    //Initialise variables
    self.editorLoaded = NO;
    self.receiveEditorDidChangeEvents = YES;
    self.formatHTML = YES;

    //Initalise enabled toolbar items array
    self.enabledToolbarItems = [[NSArray alloc] init];

    //Frame for the source view and editor view
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

    //Editor View
    self.editorView = [[UIWebView alloc] initWithFrame:frame];
    self.editorView.delegate = self;
    self.editorView.hidesInputAccessoryView = YES;
    self.editorView.keyboardDisplayRequiresUserAction = NO;
    self.editorView.scalesPageToFit = YES;
    self.editorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.editorView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.editorView.scrollView.bounces = NO;
    self.editorView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.editorView];

//    //Scrolling View
//    self.toolBarScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [self isIpad] ? self.frame.size.width : self.frame.size.width - 44, 44)];
//    self.toolBarScroll.backgroundColor = [UIColor clearColor];
//    self.toolBarScroll.showsHorizontalScrollIndicator = NO;
//
//    //Toolbar with icons
//    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
//    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    self.toolbar.backgroundColor = [UIColor clearColor];
//    [self.toolBarScroll addSubview:self.toolbar];
//    self.toolBarScroll.autoresizingMask = self.toolbar.autoresizingMask;
//
    //Parent holding view
//    self.toolbarHolder = [[UIView alloc] init];
//    self.toolbarHolder.autoresizingMask = self.toolbar.autoresizingMask;
//    [self.toolbarHolder addSubview:self.toolBarScroll];
//    UIToolbar *backgroundToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
//    backgroundToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [self.toolbarHolder insertSubview:backgroundToolbar atIndex:0];
//
//    //Hide Keyboard
//    if (![self isIpad]) {
//
//        // Toolbar holder used to crop and position toolbar
//        UIView *toolbarCropper = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-44, 0, 44, 44)];
//        toolbarCropper.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//        toolbarCropper.clipsToBounds = YES;
//
//        // Use a toolbar so that we can tint
//        UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(-7, -1, 44, 44)];
//        [toolbarCropper addSubview:keyboardToolbar];
//
//        self.keyboardItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSkeyboard.png"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissKeyboard)];
//        keyboardToolbar.items = @[self.keyboardItem];
//        [self.toolbarHolder addSubview:toolbarCropper];
//
//        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.6f, 44)];
//        line.backgroundColor = [UIColor lightGrayColor];
//        line.alpha = 0.7f;
//        [toolbarCropper addSubview:line];
//
//    }
//
//    [self addSubview:self.toolbarHolder];

    //Build the toolbar
    [self buildToolbar];

    //Load Resources
    [self loadResources];
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

- (void)setToolbarItemTintColor:(UIColor *)toolbarItemTintColor {
    
    _toolbarItemTintColor = toolbarItemTintColor;
    
    // Update the color
//    for (ZSSBarButtonItem *item in self.toolbar.items) {
//        item.tintColor = [self barButtonItemDefaultColor];
//    }
    self.keyboardItem.tintColor = toolbarItemTintColor;
}

- (void)setToolbarItemSelectedTintColor:(UIColor *)toolbarItemSelectedTintColor {
    
    _toolbarItemSelectedTintColor = toolbarItemSelectedTintColor;
}

- (void)buildToolbar {

    // Check to see if we have any toolbar items, if not, add them all
//    NSArray *items = [self itemsForToolbar];
//
//    if (self.customZSSBarButtonItems != nil) {
//        items = [items arrayByAddingObjectsFromArray:self.customZSSBarButtonItems];
//    }
//    
//    // get the width before we add custom buttons
//    CGFloat toolbarWidth = items.count == 0 ? 0.0f : (CGFloat)(items.count * 39) - 10;
//    
//    if(self.customBarButtonItems != nil)
//    {
//        items = [items arrayByAddingObjectsFromArray:self.customBarButtonItems];
//        for(ZSSBarButtonItem *buttonItem in self.customBarButtonItems)
//        {
//            toolbarWidth += buttonItem.customView.frame.size.width + 11.0f;
//        }
//    }
//    
//    self.toolbar.items = items;
//    for (ZSSBarButtonItem *item in items) {
//        item.tintColor = [self barButtonItemDefaultColor];
//    }
//    
//    self.toolbar.frame = CGRectMake(0, 0, toolbarWidth, 44);
//    self.toolBarScroll.contentSize = CGSizeMake(self.toolbar.frame.size.width, 44);
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
        [self.editorView stringByEvaluatingJavaScriptFromString:js];
        
    }
    
}

- (void)setPlaceholderText {
    
    //Call the setPlaceholder javascript method if a placeholder has been set
    if (self.placeholder != NULL && [self.placeholder length] != 0) {
    
        NSString *js = [NSString stringWithFormat:@"zss_editor.setPlaceholder(\"%@\");", self.placeholder];
        [self.editorView stringByEvaluatingJavaScriptFromString:js];
        
    }
    
}

#pragma mark - Editor Interaction

- (void)focusTextEditor {
    self.editorView.keyboardDisplayRequiresUserAction = NO;
    NSString *js = [NSString stringWithFormat:@"zss_editor.focusEditor();"];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
}

- (void)blurTextEditor {
    NSString *js = [NSString stringWithFormat:@"zss_editor.blurEditor();"];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
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
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    
}

- (NSString *)getHTML {
    
    NSString *html = [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.getHTML();"];
    html = [self removeQuotesFromHTML:html];
    html = [self tidyHTML:html];
    return html;
    
}


- (void)insertHTML:(NSString *)html {
    
    NSString *cleanedHTML = [self removeQuotesFromHTML:html];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertHTML(\"%@\");", cleanedHTML];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    
}

- (NSString *)getText {
    
    return [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.getText();"];
    
}

- (void)dismissKeyboard {
    [self endEditing:YES];
}

- (void)setHeading:(NSString *)heading {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.setHeading('%@');", heading];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)textColor {
    
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
    
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
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
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
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)updateLink:(NSString *)url title:(NSString *)title {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.updateLink(\"%@\", \"%@\");", url, title];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
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
    itemNames = [NSArray arrayWithArray:itemsModified];
    
    // Highlight items
//    NSArray *items = self.toolbar.items;
//    for (ZSSBarButtonItem *item in items) {
//        if ([itemNames containsObject:item.label]) {
//            item.tintColor = [self barButtonItemSelectedDefaultColor];
//        } else {
//            item.tintColor = [self barButtonItemDefaultColor];
//        }
//    }
}

#pragma mark - UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    
    NSString *urlString = [[request URL] absoluteString];
    //NSLog(@"web request");
    //NSLog(@"%@", urlString);
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        return NO;
    } else if ([urlString rangeOfString:@"callback://0/"].location != NSNotFound) {
        
        // We recieved the callback
        NSString *className = [urlString stringByReplacingOccurrencesOfString:@"callback://0/" withString:@""];
        [self updateToolBarWithButtonName:className];
        
    } else if ([urlString rangeOfString:@"debug://"].location != NSNotFound) {
        
        NSLog(@"Debug Found");
        
        // We recieved the callback
        NSString *debug = [urlString stringByReplacingOccurrencesOfString:@"debug://" withString:@""];
        debug = [debug stringByReplacingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"%@", debug);
        
    } else if ([urlString rangeOfString:@"scroll://"].location != NSNotFound) {
        NSInteger position = [[urlString stringByReplacingOccurrencesOfString:@"scroll://" withString:@""] integerValue];
        if ([self.delegate respondsToSelector:@selector(richTextEditor:didScrollToPosition:)]) {
            [self.delegate richTextEditor:self didScrollToPosition:position];
        }
    }
    
    return YES;
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.editorLoaded = YES;

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
    
    /*
     
     Callback for when text is changed, solution posted by richardortiz84 https://github.com/nnhubbard/ZSSRichTextEditor/issues/5
     
     */
    JSContext *ctx = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    ctx[@"contentUpdateCallback"] = ^(JSValue *msg) {
        
        if (_receiveEditorDidChangeEvents) {
            if ([self.delegate respondsToSelector:@selector(richTextEditor:didChangeText:html:)]) {
                [self.delegate richTextEditor:self didChangeText:[self getText] html:[self getHTML]];
            }
        }
        
        [self checkForMentionOrHashtagInText:[self getText]];
        
    };
    [ctx evaluateScript:@"document.getElementById('zss_editor_content').addEventListener('input', contentUpdateCallback, false);"];
    
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
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.setBold();"];
            break;
        case ZSSBarButtonItemTypeItalic:
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.setItalic();"];
            break;
        case ZSSBarButtonItemTypeSubscript:
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.setSubscript();"];
            break;
        case ZSSBarButtonItemTypeSuperscript:
            [self.editorView stringByEvaluatingJavaScriptFromString: @"zss_editor.setSuperscript();"];
            break;
        case ZSSBarButtonItemTypeStrikeThrough:
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.setStrikeThrough();"];
            break;
        case ZSSBarButtonItemTypeUnderline:
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.setUnderline();"];
            break;
        case ZSSBarButtonItemTypeRemoveFormat:
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.removeFormating();"];
            break;
        case ZSSBarButtonItemTypeJustifyLeft:
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.setJustifyLeft();"];
            break;
        case ZSSBarButtonItemTypeJustifyCenter:
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.setJustifyCenter();"];
            break;
        case ZSSBarButtonItemTypeJustifyRight:
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.setJustifyRight();"];
            break;
        case ZSSBarButtonItemTypeJustifyFull:
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.setJustifyFull();"];
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
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.setUnorderedList();"];
            break;
        case ZSSBarButtonItemTypeOrderedList:
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.setOrderedList();"];
            break;
        case ZSSBarButtonItemTypeHorizontalRule:
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.setHorizontalRule();"];
            break;
        case ZSSBarButtonItemTypeIndent:
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.setIndent();"];
            break;
        case ZSSBarButtonItemTypeOutdent:
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.setOutdent();"];
            break;
        case ZSSBarButtonItemTypeInsertLink: {
            // Save the selection location
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
            // Show the dialog for inserting or editing a link
            [self showInsertLinkDialogWithLink:self.selectedLinkURL title:self.selectedLinkTitle];
        }
            break;
        case ZSSBarButtonItemTypeRemoveLink:
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.unlink();"];
            break;
        case ZSSBarButtonItemTypeQuickLink:
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.quickLink();"];
            break;
        case ZSSBarButtonItemTypeUndo:
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.undo();"];
            break;
        case ZSSBarButtonItemTypeRedo:
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.redo();"];
            break;
        case ZSSBarButtonItemTypeParagraph:
            [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.setParagraph();"];
            break;
        default:
            if ([self.delegate respondsToSelector:@selector(richTextEditor:didReceiveUnrecognizedActionLabel:)]) {
                [self.delegate richTextEditor:self didReceiveUnrecognizedActionLabel:sender.label];
            }
    }
}

#pragma mark - Asset Picker

- (void)showInsertURLAlternatePicker {
    // Blank method. User should implement this in their subclass
}

#pragma mark - Utilities

- (NSString *)removeQuotesFromHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"“" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"”" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"\r"  withString:@"\\r"];
    html = [html stringByReplacingOccurrencesOfString:@"\n"  withString:@"\\n"];
    return html;
}


- (NSString *)tidyHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"<br>" withString:@"<br />"];
    html = [html stringByReplacingOccurrencesOfString:@"<hr>" withString:@"<hr />"];
    if (self.formatHTML) {
        html = [self.editorView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"style_html(\"%@\");", html]];
    }
    return html;
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


- (BOOL)isIpad {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}


- (NSString *)stringByDecodingURLFormat:(NSString *)string {
    NSString *result = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

@end
