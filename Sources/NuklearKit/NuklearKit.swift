@_exported import CNuklear
import MetalKit

let nk_metal = NKMetal.shared
let nk_dvc = NKMetalDevice.shared

class NKMetalDevice {
  static let shared = NKMetalDevice()
  static let maxTextures = 256
  var null = nk_draw_null_texture()
  var fontTexIndex = 0
  var maxElementBufferSize = 0
  var maxVertexBufferSize = 0
  var vertexFunction: MTLFunction? = nil
  var fragmentFunction: MTLFunction? = nil
  var pipelineDescriptor = MTLRenderPipelineDescriptor()
  var cmds = nk_buffer()
  var vertexDescriptor = MTLVertexDescriptor()
  var vertexBuffer: MTLBuffer? = nil
  var elementBuffer: MTLBuffer? = nil
  var tex_ids = [Int](repeating: 0, count: maxTextures)
  var tex_handles = [Int](repeating: 0, count: maxTextures)
}

class NKMetal {
  static let shared = NKMetal()
  static let textMax = 256
  static let doubleClickLo = 0.02
  static let doubleClickHi = 0.20
  var view: MTKView? = nil
  var ctx = nk_context()
  var nkdvc = nk_dvc
  var atlas = nk_font_atlas()
  var fbScale = nk_vec2()
  var scroll = nk_vec2()
  var doubleClickPosition = nk_vec2()
  var width = 0
  var height = 0
  var deviceWidth = 0
  var deviceHeight = 0
  var isDoubleClickDown = 0
  var lastButtonClick = 0.0
  var text = [UInt](repeating: 0, count: textMax)
}

@discardableResult
func nk_metal_init(view: MTKView?, maxVertexBufferSize: Int, maxElementBufferSize: Int) -> UnsafeMutablePointer<nk_context> {
  print("nk_*_init, copy paste not created")
  nk_init_default(&nk_metal.ctx, nil)
  nk_metal.view = view
  nk_dvc.maxVertexBufferSize = maxVertexBufferSize
  nk_dvc.maxElementBufferSize = maxElementBufferSize
  nk_metal.isDoubleClickDown = nk_false;
  nk_metal.doubleClickPosition = nk_vec2(0, 0)
  nk_metal.lastButtonClick = 0
  nk_metal_device_init()
  return withUnsafeMutablePointer(to: &nk_metal.ctx, { $0 })
}

func nk_metal_device_init(){
  print("nk_glfw3_device_create NOT YET IMPLEMENTED")
  guard let device = nk_metal.view!.device else {
    fatalError("Passed view has no device!")
  }
  do {
    let shaderSource = """
            #include <metal_stdlib>
            using namespace metal;
            #import <simd/simd.h>

            typedef struct {
                matrix_float4x4 projectionMatrix;
            } Uniforms;

            struct NKVertexIn {
                float2 position [[attribute(0)]];
                float2 uv [[attribute(1)]];
                uchar4 color [[attribute(2)]];
            };

            struct NKVertexOut {
                float4 position [[position]];
                float4 fragColor;
                float2 fragUV;
            };

            vertex NKVertexOut nk_vertex_main(const NKVertexIn nkVertexIn [[stage_in]],
                                        constant Uniforms &uniforms [[buffer(1)]]) {
                NKVertexOut out {
                    .position = uniforms.projectionMatrix * float4(nkVertexIn.position, 0, 1),
                    .fragColor = float4(nkVertexIn.color) / 255.0,
                    .fragUV = nkVertexIn.uv
                };
                return out;
            }

            fragment float4 nk_fragment_main(const NKVertexOut vertexInput [[stage_in]],
                                            texture2d<float> baseColor [[texture(0)]],
                                            sampler textureSampler [[sampler(0)]]) {
                float3 sampledColor = baseColor.sample(textureSampler, vertexInput.fragUV).rgb;
                return vertexInput.fragColor * float4(sampledColor, 1.0);
            }
        """
    let library = try device.makeLibrary(source: shaderSource, options: nil)
    nk_dvc.vertexFunction = library.makeFunction(name: "nk_vertex_main")
    nk_dvc.fragmentFunction = library.makeFunction(name: "nk_fragment_main")
  } catch {
    fatalError("encountered in nk_metal_device_init(): \n\(error)")
  }
  nk_buffer_init_default(&nk_dvc.cmds)
  nk_dvc.pipelineDescriptor.colorAttachments[0].pixelFormat = .rgba8Unorm
  nk_dvc.pipelineDescriptor.fragmentFunction = nk_dvc.fragmentFunction
  nk_dvc.pipelineDescriptor.vertexFunction = nk_dvc.vertexFunction
  // VertexIn Position
  var offset = 0
  nk_dvc.vertexDescriptor.attributes[0].format = .float2
  nk_dvc.vertexDescriptor.attributes[0].offset = offset
  nk_dvc.vertexDescriptor.attributes[0].bufferIndex = 0
  offset += MemoryLayout<SIMD2<Float>>.stride
  // VertexIn UV
  nk_dvc.vertexDescriptor.attributes[1].format = .float2
  nk_dvc.vertexDescriptor.attributes[1].offset = offset
  nk_dvc.vertexDescriptor.attributes[1].bufferIndex = 0
  offset += MemoryLayout<SIMD2<Float>>.stride
  // VertexIn Color
  nk_dvc.vertexDescriptor.attributes[2].format = .uchar4
  nk_dvc.vertexDescriptor.attributes[2].offset = offset
  nk_dvc.vertexDescriptor.attributes[2].bufferIndex = 0
  offset += MemoryLayout<SIMD4<UTF8Char>>.stride
  // Describe Entire Buffer Layout 2xFloat|2xFloat|4xChar = 20 Byte
  nk_dvc.vertexDescriptor.layouts[0].stride = offset
  if let view = nk_metal.view {
    guard let device = view.device else {
      fatalError("Could not get device from view")
    }
    let shareEnabled = MTLResourceOptions.storageModeShared
    nk_dvc.vertexBuffer = device.makeBuffer(length: nk_dvc.maxVertexBufferSize, options: shareEnabled)
    nk_dvc.elementBuffer = device.makeBuffer(length: nk_dvc.maxElementBufferSize, options: shareEnabled)
  }
  print("Need to set text ids and handles here, working on upload texture")
}

func nk_metal_font_stash_begin() -> Void {
  nk_font_atlas_init_default(&nk_metal.atlas);
  nk_font_atlas_begin(&nk_metal.atlas);
}

func nk_metal_device_upload_atlas(_ image: inout UnsafeMutableRawPointer, width: Int32, height: Int32) -> Void {
  //nk_dvc.fontTexIndex = nk_metal_create_texture(&image, width: width, height: height)
  print("nk_metal_create_texture Not implemented")
  let size = MemoryLayout<Int32>.size
  let data = Data(bytesNoCopy: image, count: Int(width * height) * size, deallocator: .none)
  //let data = NSData(bytesNoCopy: image, length: Int(width * height) * size)
  let img = NSImage(data: data)
  /// TODO: This needs to be changed. The Texture is not being loaded from in memory
  guard let view = nk_metal.view, let device = view.device else {
    fatalError("Could not get view from nk metal!")
  }
  let loader = MTKTextureLoader(device: device)
  do {
    let texture = try loader.newTexture(data: data, options: nil)
  } catch {
    fatalError("Loading texture from create_texture: \(error)")
  }
  nk_dvc.fontTexIndex = 0
}

func nk_metal_create_texture(_ image: inout UnsafeMutableRawPointer, width: Int32, height: Int32) -> Int {
  print("nk_metal_create_texture Not implemented")
  let size = MemoryLayout<Int32>.size
  let data = NSData(bytesNoCopy: image, length: Int(width * height) * size)
  let img = NSImage(data: data as Data)
  guard let view = nk_metal.view, let device = view.device else {
    fatalError("Could not get view from nk metal!")
  }
  let loader = MTKTextureLoader(device: device)
  do {
    let texture = try loader.newTexture(data: data as Data, options: nil)
  } catch {
    fatalError("Loading texture from create_texture: \(error)")
  }
  return 0
}

func nk_metal_font_stash_end() -> Void {
  var w: Int32 = 0
  var h: Int32 = 0
  guard var _ = nk_font_atlas_bake(&nk_metal.atlas, &w, &h, NK_FONT_ATLAS_RGBA32) else {
    fatalError("Nuklear font baking failed!")
  }
  nk_metal_device_upload_atlas(&nk_metal.atlas.pixel, width: w, height: h)
  nk_font_atlas_end(&nk_metal.atlas, nk_handle_id(Int32(nk_metal.nkdvc.fontTexIndex)), &nk_metal.nkdvc.null);
  if nk_metal.atlas.default_font != nil {
    nk_style_set_font(&nk_metal.ctx, &(nk_metal.atlas.default_font).pointee.handle)
  }
}
