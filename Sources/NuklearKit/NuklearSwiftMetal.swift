import CNuklear
import MetalKit

class MetalNuklear {
  static let shared = MetalNuklear()
  var view: MTKView? = nil
  var ctx = nk_context()
}

func nk_metal_init(view: MTKView?, maxVertexBufferSize: Int, maxElementBufferSize: Int) -> UnsafeMutablePointer<nk_context> {
  print("nk_*_init, copy past not created")
  let mtl = MetalNuklear.shared
  nk_init_default(&mtl.ctx, nil)
  return withUnsafeMutablePointer(to: &mtl.ctx, { $0 })
}