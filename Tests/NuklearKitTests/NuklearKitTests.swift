import XCTest
import Cocoa
import AppKit
import MetalKit
@testable import NuklearKit

class SharedDelegateState {
    var running = true
    static let shared = SharedDelegateState()
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let sharedState = SharedDelegateState.shared
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("start app")
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSLog("applicationWillTerminate")
        sharedState.running = false
    }
}

class WindowDelegate: NSObject, NSWindowDelegate {
    let sharedState = SharedDelegateState.shared
    func windowDidResize(_ notification: Notification) {
        NSLog("windowDidResize")
    }

    func windowWillClose(_ notification: Notification) {
        NSLog("windowWillClose")
        sharedState.running = false
    }
}

final class NuklearKitTests: XCTestCase {
    func testExample() {
        let app = NSApplication.shared
        let appDelegate = AppDelegate()
        app.delegate = appDelegate
        app.setActivationPolicy(.regular)
        app.finishLaunching()
        let baseRectFrame = NSMakeRect(0, 0, 1024, 768)
        let window = NSWindow(contentRect: baseRectFrame,
                    styleMask: [.closable, .titled, .resizable, .miniaturizable],
                    backing: .buffered,
                    defer: true)

        let windowDelegate = WindowDelegate()
        window.delegate = windowDelegate
        window.title = "NuklearKit Test Window"
        window.acceptsMouseMovedEvents = true
        window.center()
        window.orderFrontRegardless()

        // TEST
        var mtkView = MTKView(frame: baseRectFrame)
        let device = MTLCreateSystemDefaultDevice()!
        mtkView.device = device
        mtkView.colorPixelFormat = .bgra8Unorm
        guard let view = window.contentView else {
            fatalError("Cannot get window's content view")
        }
        print(view.frame)
        view.addSubview(mtkView)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[mtkView]|", options: [], metrics: nil, views: ["mtkView" : mtkView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[mtkView]|", options: [], metrics: nil, views: ["mtkView" : mtkView]))
        
        var renderer = NKTestRenderer(view: mtkView, device: device)
        mtkView.delegate = renderer
        
        // v.layer?.backgroundColor = NSColor.systemRed.cgColor
        // v.wantsLayer = true
        // window.contentView?.addSubview(v)
        // if let views = window.contentView?.subviews {
        //     for v in views {
        //         print("found frame: \(v.frame) has opac: \(v.alphaValue), needs to draw?: \(v.needsToDraw(f))")
        //     }
        // }
        // print(v.window ?? "no windy")

        while(SharedDelegateState.shared.running) {
            var ev: NSEvent?
            ev = app.nextEvent(matching: .any, until: nil, inMode: .default, dequeue: true)
            if (ev != nil) {
                app.sendEvent(ev!)
            }
        }

        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        // let delegate = AppDelegate()
        // delegate.createNewWindow()
        nk_metal_init(view: nil, maxVertexBufferSize: 0, maxElementBufferSize: 0)
        var ctx = MetalNuklear.shared.ctx
        //let maxRawMemory: UInt = 2048
        //let rawMemory = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(maxRawMemory))
        //nk_init_default(&ctx, nil);

        var atlas = nk_font_atlas();
        nk_font_atlas_init_default(&atlas);
        nk_font_atlas_begin(&atlas);
        var w: Int32 = 0
        var h: Int32 = 0
        var image = nk_font_atlas_bake(&atlas, &w, &h, NK_FONT_ATLAS_RGBA32);
        nk_style_set_font(&ctx, &(atlas.default_font).pointee.handle);

        var value: Float = 0.0
        if nk_begin(&ctx, "Show", nk_rect(50, 50, 220, 220), NK_WINDOW_BORDER.value|NK_WINDOW_MOVABLE.value|NK_WINDOW_CLOSABLE.value) != 0 {
            /* fixed widget pixel width */
            nk_layout_row_static(&ctx, 30, 80, 1);
            // if (nk_button_label(&ctx, "button")) {
            //     /* event handling */
            // }

            /* fixed widget window ratio width */
            nk_layout_row_dynamic(&ctx, 30, 2);
            nk_option_label(&ctx, "easy", 1)
            // if (nk_option_label(&ctx, "hard", op == HARD)) op = HARD;

            /* custom widget pixel width */
            nk_layout_row_begin(&ctx, NK_STATIC, 30, 2);
            nk_layout_row_push(&ctx, 50);
            nk_label(&ctx, "Volume:", NK_TEXT_LEFT.value);
            nk_layout_row_push(&ctx, 110);
            nk_slider_float(&ctx, 0, &value, 1.0, 0.1);
            nk_layout_row_end(&ctx);
        }
        nk_end(&ctx);
        print("Hello, world!")        
        app.terminate(nil)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
