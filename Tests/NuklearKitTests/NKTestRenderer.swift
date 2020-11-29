import MetalKit

class NKTestRenderer: NSObject, MTKViewDelegate {
  let mtkView: MTKView
  let device: MTLDevice
  let commandQueue: MTLCommandQueue
  
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
  }
  
  func draw(in view: MTKView){
    // Get an available command buffer
    guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
    
    // Get the default MTLRenderPassDescriptor from the MTKView argument
    guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
    
    // Change default settings. For example, we change the clear color from black to red.
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.05, 0.08, 0.95, 1)
    
    // We compile renderPassDescriptor to a MTLRenderCommandEncoder.
    guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
    
    // TODO: Here is where we need to encode drawing commands!
    
    // This finalizes the encoding of drawing commands.
    renderEncoder.endEncoding()
    
    // Tell Metal to send the rendering result to the MTKView when rendering completes
    commandBuffer.present(view.currentDrawable!)
    
    // Finally, send the encoded command buffer to the GPU.
    commandBuffer.commit()
  }
  
  init(view: MTKView, device: MTLDevice) {
    self.mtkView = view
    self.device = device
    self.commandQueue = device.makeCommandQueue()!
    super.init()
  }
}
