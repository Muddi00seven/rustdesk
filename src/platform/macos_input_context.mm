#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>

using InputCallback = void (*)(void *, bool, bool);
using ReleaseCallback = void (*)(void *);

// All AX objects and callback lifetimes are confined to the main run loop.
class MacPilotInputContext {
    InputCallback callback;
    ReleaseCallback release;
    void *context;
    id activation = nil;
    AXObserverRef observer = nullptr;
    AXUIElementRef application = nullptr;

    static void changed(AXObserverRef, AXUIElementRef, CFStringRef, void *context) {
        static_cast<MacPilotInputContext *>(context)->publish();
    }

    void detach() {
        if (observer) {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(observer),
                                  kCFRunLoopCommonModes);
            CFRelease(observer);
            observer = nullptr;
        }
        if (application) {
            CFRelease(application);
            application = nullptr;
        }
    }

    static CFTypeRef attribute(AXUIElementRef element, CFStringRef name) {
        CFTypeRef value = nullptr;
        if (AXUIElementCopyAttributeValue(element, name, &value) != kAXErrorSuccess) {
            return nullptr;
        }
        return value;
    }

    void publish() {
        bool editable = false;
        bool secure = false;
        CFTypeRef focused = application ? attribute(application, kAXFocusedUIElementAttribute) : nullptr;
        if (focused && CFGetTypeID(focused) == AXUIElementGetTypeID()) {
            auto element = static_cast<AXUIElementRef>(focused);
            CFTypeRef role = attribute(element, kAXRoleAttribute);
            CFTypeRef subrole = attribute(element, kAXSubroleAttribute);
            secure = subrole && CFEqual(subrole, kAXSecureTextFieldSubrole);
            editable = secure || (role && (CFEqual(role, kAXTextFieldRole) ||
                                           CFEqual(role, kAXTextAreaRole) ||
                                           CFEqual(role, kAXComboBoxRole)));
            // Read-only text areas must not summon the keyboard. Never read AXValue.
            Boolean settable = false;
            if (editable && !secure) {
                editable = AXUIElementIsAttributeSettable(element, kAXValueAttribute, &settable)
                               == kAXErrorSuccess && settable;
            }
            if (role) CFRelease(role);
            if (subrole) CFRelease(subrole);
        }
        if (focused) CFRelease(focused);
        callback(context, editable, secure);
    }

    void attach() {
        detach();
        NSRunningApplication *frontmost = NSWorkspace.sharedWorkspace.frontmostApplication;
        if (frontmost && AXIsProcessTrusted()) {
            application = AXUIElementCreateApplication(frontmost.processIdentifier);
            AXUIElementSetMessagingTimeout(application, 0.15);
            if (AXObserverCreate(frontmost.processIdentifier, changed, &observer) == kAXErrorSuccess) {
                auto focus = AXObserverAddNotification(observer, application,
                                                       kAXFocusedUIElementChangedNotification, this);
                auto window = AXObserverAddNotification(observer, application,
                                                        kAXFocusedWindowChangedNotification, this);
                if (focus == kAXErrorSuccess || window == kAXErrorSuccess) {
                    CFRunLoopAddSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(observer),
                                       kCFRunLoopCommonModes);
                } else {
                    detach();
                }
            } else {
                detach();
            }
        }
        publish();
    }

public:
    MacPilotInputContext(InputCallback callback, ReleaseCallback release, void *context)
        : callback(callback), release(release), context(context) {}

    void start() {
        activation = [NSWorkspace.sharedWorkspace.notificationCenter
            addObserverForName:NSWorkspaceDidActivateApplicationNotification object:nil
            queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *) { attach(); }];
        attach();
    }

    ~MacPilotInputContext() {
        if (activation) {
            [NSWorkspace.sharedWorkspace.notificationCenter removeObserver:activation];
        }
        detach();
        release(context);
    }
};

extern "C" void *MacPilotStartInputContext(InputCallback callback, ReleaseCallback release, void *context) {
    auto watcher = new MacPilotInputContext(callback, release, context);
    dispatch_async(dispatch_get_main_queue(), ^{ watcher->start(); });
    return watcher;
}

extern "C" void MacPilotStopInputContext(void *context) {
    auto watcher = static_cast<MacPilotInputContext *>(context);
    dispatch_async(dispatch_get_main_queue(), ^{ delete watcher; });
}
