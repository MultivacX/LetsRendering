import Cocoa

let width = 800
let height = 400
let t0 = CFAbsoluteTimeGetCurrent()
var image = imageFromPixels(width, height)
let t1 = CFAbsoluteTimeGetCurrent()
t1-t0
image
