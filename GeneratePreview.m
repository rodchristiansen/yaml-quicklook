#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#import <Foundation/Foundation.h>

// Forward declarations
#pragma GCC visibility push(default)
OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);
OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);
#pragma GCC visibility pop

// Plugin factory - must match the UUID in Info.plist
#pragma GCC visibility push(default)
void *QuickLookGeneratorPluginFactory(CFAllocatorRef allocator, CFUUIDRef typeUUID);
#pragma GCC visibility pop

// Plugin factory implementation
void *QuickLookGeneratorPluginFactory(CFAllocatorRef allocator, CFUUIDRef typeUUID) {
    // The plugin factory doesn't need to allocate anything
    // Quick Look will call our functions directly
    return NULL;
}

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options) {
    @autoreleasepool {
        // Check if preview was cancelled
        if (QLPreviewRequestIsCancelled(preview))
            return noErr;
        
        // Read the YAML file
        CFStringRef path = CFURLCopyPath(url);
        NSString *nsPath = (__bridge NSString *)path;
        NSString *fileContent = [NSString stringWithContentsOfURL:(__bridge NSURL *)url encoding:NSUTF8StringEncoding error:nil];
        CFRelease(path);
        
        if (!fileContent) {
            fileContent = @"Error: Could not read YAML file";
        }
        
        // Create simple HTML preview
        NSString *htmlContent = [NSString stringWithFormat:@
            "<!DOCTYPE html>"
            "<html>"
            "<head>"
            "<meta charset='utf-8'>"
            "<style>"
            "body { font-family: -apple-system, monospace; margin: 20px; background-color: #ffffff; }"
            "pre { white-space: pre-wrap; word-wrap: break-word; }"
            "</style>"
            "</head>"
            "<body>"
            "<h2>YAML Preview</h2>"
            "<pre>%@</pre>"
            "</body>"
            "</html>", fileContent];
        
        CFDataRef htmlData = (__bridge CFDataRef)[htmlContent dataUsingEncoding:NSUTF8StringEncoding];
        
        CFDictionaryRef properties = (__bridge CFDictionaryRef)@{
            (__bridge NSString *)kQLPreviewPropertyTextEncodingNameKey: @"UTF-8",
            (__bridge NSString *)kQLPreviewPropertyMIMETypeKey: @"text/html"
        };
        
        QLPreviewRequestSetDataRepresentation(preview, htmlData, kUTTypeHTML, properties);
        
        return noErr;
    }
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview) {
    // Nothing to cancel
}

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize) {
    return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail) {
    // Nothing to cancel
}
