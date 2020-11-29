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
    let mtkView = MTKView(frame: baseRectFrame)
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
    
    let renderer = NKTestRenderer(view: mtkView, device: device)
    mtkView.delegate = renderer
    
    nk_metal_init(view: mtkView, maxVertexBufferSize: 512 * 1024, maxElementBufferSize: 128 * 1024)
    
    nk_metal_font_stash_begin()
    nk_metal_font_stash_end()
    
    var value: Float = 0.0
    if nk_begin(&nk_metal.ctx, "Show", nk_rect(50, 50, 220, 220), NK_WINDOW_BORDER.value|NK_WINDOW_MOVABLE.value|NK_WINDOW_CLOSABLE.value) != 0 {
      /* fixed widget pixel width */
      nk_layout_row_static(&nk_metal.ctx, 30, 80, 1);
      // if (nk_button_label(&ctx, "button")) {
      //     /* event handling */
      // }
      
      /* fixed widget window ratio width */
      nk_layout_row_dynamic(&nk_metal.ctx, 30, 2);
      nk_option_label(&nk_metal.ctx, "easy", 1)
      // if (nk_option_label(&ctx, "hard", op == HARD)) op = HARD;
      
      /* custom widget pixel width */
      nk_layout_row_begin(&nk_metal.ctx, NK_STATIC, 30, 2);
      nk_layout_row_push(&nk_metal.ctx, 50);
      nk_label(&nk_metal.ctx, "Volume:", NK_TEXT_LEFT.value);
      nk_layout_row_push(&nk_metal.ctx, 110);
      nk_slider_float(&nk_metal.ctx, 0, &value, 1.0, 0.1);
      nk_layout_row_end(&nk_metal.ctx);
    }
    nk_end(&nk_metal.ctx);
    print("Hello, world!")
    
    while(SharedDelegateState.shared.running) {
      var ev: NSEvent?
      ev = app.nextEvent(matching: .any, until: nil, inMode: .default, dequeue: true)
      if (ev != nil) {
        app.sendEvent(ev!)
      }
    }
    app.terminate(nil)
  }
  
  static var allTests = [
    ("testExample", testExample),
  ]
}
