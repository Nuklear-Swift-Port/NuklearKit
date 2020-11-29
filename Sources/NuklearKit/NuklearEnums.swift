import CNuklear

extension nk_panel_flags {
  public var value: UInt32 {
    switch self {
    case NK_WINDOW_BORDER            : return 0
    case NK_WINDOW_MOVABLE           : return 1 << 1
    case NK_WINDOW_SCALABLE          : return 1 << 2
    case NK_WINDOW_CLOSABLE          : return 1 << 3
    case NK_WINDOW_MINIMIZABLE       : return 1 << 4
    case NK_WINDOW_NO_SCROLLBAR      : return 1 << 5
    case NK_WINDOW_TITLE             : return 1 << 6
    case NK_WINDOW_SCROLL_AUTO_HIDE  : return 1 << 7
    case NK_WINDOW_BACKGROUND        : return 1 << 8
    case NK_WINDOW_SCALE_LEFT        : return 1 << 9
    case NK_WINDOW_NO_INPUT          : return 1 << 10
    default                          : return 1 << 10
    }
  }
}

extension nk_text_align {
  public var value: UInt32 {
    switch self {
    case NK_TEXT_ALIGN_LEFT       : return 0x01
    case NK_TEXT_ALIGN_CENTERED   : return 0x02
    case NK_TEXT_ALIGN_RIGHT      : return 0x04
    case NK_TEXT_ALIGN_TOP        : return 0x08
    case NK_TEXT_ALIGN_MIDDLE     : return 0x10
    case NK_TEXT_ALIGN_BOTTOM     : return 0x20
    default                       : return 0x01
    }
  }
}

extension nk_text_alignment {
  public var value: UInt32 {
    switch self {
    case NK_TEXT_LEFT    : return NK_TEXT_ALIGN_MIDDLE.value|NK_TEXT_ALIGN_LEFT.value
    case NK_TEXT_CENTERED: return NK_TEXT_ALIGN_MIDDLE.value|NK_TEXT_ALIGN_CENTERED.value
    case NK_TEXT_RIGHT   : return NK_TEXT_ALIGN_MIDDLE.value|NK_TEXT_ALIGN_RIGHT.value
    default              : return NK_TEXT_ALIGN_MIDDLE.value|NK_TEXT_ALIGN_LEFT.value
    }
  }
}

extension nk_font_atlas_format {
  public var value: UInt32 {
    switch self {
    case NK_FONT_ATLAS_ALPHA8: return 0
    case NK_FONT_ATLAS_RGBA32: return 1
    default                  : return 0
    }
  }
};
