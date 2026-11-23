#pragma once
#ifdef _WIN32
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>
#include <commctrl.h>
#include "pluginterfaces/gui/iplugviewcontentscalesupport.h"
#else
#import <AppKit/AppKit.h>
#endif
#include "pluginterfaces/gui/iplugview.h"
#include "pluginterfaces/base/funknownimpl.h"
#include "pluginterfaces/vst/ivsteditcontroller.h"
#include <algorithm>
#include <string>

class PluginEditor {
    Steinberg::IPtr<Steinberg::IPlugView> view;
    bool attached = false;
#ifdef _WIN32
    HWND window = nullptr;
    static constexpr DWORD style = WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX | WS_CLIPCHILDREN;
    static constexpr DWORD exStyle = WS_EX_TOOLWINDOW;
    void resizeClient(const Steinberg::ViewRect& size) {
        RECT rect{0,0,size.getWidth(),size.getHeight()};
        AdjustWindowRectExForDpi(&rect,style,FALSE,exStyle,GetDpiForWindow(window));
        SetWindowPos(window,nullptr,0,0,rect.right-rect.left,rect.bottom-rect.top,SWP_NOMOVE|SWP_NOZORDER|SWP_NOACTIVATE);
    }
    void setScale(UINT dpi) {
        if (auto scalable=Steinberg::U::cast<Steinberg::IPlugViewContentScaleSupport>(view))
            scalable->setContentScaleFactor(static_cast<float>(dpi)/96.0f);
    }
    static LRESULT CALLBACK handleMessage(HWND hwnd, UINT msg, WPARAM w, LPARAM l,
                                          UINT_PTR subclassId, DWORD_PTR ref) {
        auto* self=reinterpret_cast<PluginEditor*>(ref);
        if (msg==WM_DPICHANGED) {
            auto* next=reinterpret_cast<const RECT*>(l);
            SetWindowPos(hwnd,nullptr,next->left,next->top,0,0,SWP_NOSIZE|SWP_NOZORDER|SWP_NOACTIVATE);
            self->setScale(HIWORD(w));
            return 0;
        }
        if (msg==WM_CLOSE) {
            self->close();
            return 0;
        }
        if (msg==WM_DESTROY) {
            self->window=nullptr;
            self->detach();
        }
        if (msg==WM_NCDESTROY) RemoveWindowSubclass(hwnd,handleMessage,subclassId);
        return DefSubclassProc(hwnd,msg,w,l);
    }
#else
    NSWindow* window = nil;
    id closeObserver = nil;
#endif
    void detach() {
        if (!view) return;
        // Clear members before calling the plug-in, which may reenter resizeView.
        auto oldView=view;
        view=nullptr;
        if (attached) oldView->removed();
        attached=false;
        oldView->setFrame(nullptr);
    }
public:
    bool show(Steinberg::Vst::IEditController* controller, Steinberg::IPlugFrame* frame, const char* title) {
        if (!controller) return false;
#ifdef _WIN32
        if (window) {
            if (IsIconic(window)) ShowWindow(window,SW_RESTORE);
            SetForegroundWindow(window);
            return true;
        }
        auto platform=Steinberg::kPlatformTypeHWND;
#else
        if (window) { [window makeKeyAndOrderFront:nil]; return true; }
        auto platform=Steinberg::kPlatformTypeNSView;
#endif
        view=Steinberg::owned(controller->createView(Steinberg::Vst::ViewType::kEditor));
        Steinberg::ViewRect rect{};
        if (!view || view->isPlatformTypeSupported(platform)!=Steinberg::kResultOk ||
            view->getSize(&rect)!=Steinberg::kResultOk || rect.getWidth()<=0 || rect.getHeight()<=0) {
            view=nullptr;
            return false;
        }
#ifdef _WIN32
        std::wstring wideTitle(title,title+std::char_traits<char>::length(title)); // both device titles are ASCII
        HWND owner=GetAncestor(GetActiveWindow(),GA_ROOTOWNER);
        window=CreateWindowExW(exStyle,L"STATIC",wideTitle.c_str(),style,CW_USEDEFAULT,CW_USEDEFAULT,
                               rect.getWidth(),rect.getHeight(),owner,nullptr,nullptr,nullptr);
        if (!window || !SetWindowSubclass(window,handleMessage,1,reinterpret_cast<DWORD_PTR>(this))) {
            close();
            return false;
        }
        void* parent=window;
        resizeClient(rect);
#else
        NSRect bounds=NSMakeRect(0,0,std::max(100,rect.getWidth()),std::max(100,rect.getHeight()));
        window=[[NSWindow alloc] initWithContentRect:bounds styleMask:(NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable) backing:NSBackingStoreBuffered defer:NO];
        [window setReleasedWhenClosed:NO];
        window.title=[NSString stringWithUTF8String:title];
        [window center];
        void* parent=(__bridge void*)window.contentView;
#endif
        view->setFrame(frame);
#ifdef _WIN32
        setScale(GetDpiForWindow(window));
        if (view->getSize(&rect)==Steinberg::kResultOk) resizeClient(rect);
#endif
        if (view->attached(parent,platform)!=Steinberg::kResultOk) { close(); return false; }
        attached=true;
#ifdef _WIN32
        ShowWindow(window,SW_SHOW);
        SetForegroundWindow(window);
#else
        closeObserver=[[NSNotificationCenter defaultCenter] addObserverForName:NSWindowWillCloseNotification object:window queue:nil usingBlock:^(NSNotification*){
            [[NSNotificationCenter defaultCenter] removeObserver:this->closeObserver];
            this->closeObserver=nil;
            this->window=nil;
            this->detach();
        }];
        [window makeKeyAndOrderFront:nil];
#endif
        return true;
    }
    Steinberg::tresult resize(Steinberg::IPlugView* plug, Steinberg::ViewRect* rect) {
        if (!rect || !window || plug!=view.get() || rect->getWidth()<=0 || rect->getHeight()<=0) return Steinberg::kResultFalse;
#ifdef _WIN32
        resizeClient(*rect);
#else
        [window setContentSize:NSMakeSize(rect->getWidth(),rect->getHeight())];
#endif
        return plug->onSize(rect);
    }
    void close() {
        auto old=window;
        window=nullptr;
#ifndef _WIN32
        if (closeObserver) {
            [[NSNotificationCenter defaultCenter] removeObserver:closeObserver];
            closeObserver=nil;
        }
#endif
        detach();
#ifdef _WIN32
        if (old) DestroyWindow(old);
#else
        if (old) { [old orderOut:nil]; [old close]; }
#endif
    }
};
