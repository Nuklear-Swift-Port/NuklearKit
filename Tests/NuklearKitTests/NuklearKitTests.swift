import XCTest
@testable import NuklearKit

final class NuklearKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
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
        XCTAssertEqual(NuklearKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
