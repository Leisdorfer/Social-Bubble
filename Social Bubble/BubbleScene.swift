import SpriteKit

class BubbleScene: SKScene {
    
    override init(size: CGSize) {
        super.init(size: size)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        backgroundColor = .black
        physicsWorld.speed = 0.2
        shouldRasterize = true
        addCircles()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addCircles() {
        (0...8).forEach { _ in
            let bubble = SKShapeNode(circleOfRadius: CGFloat(arc4random_uniform(4) + 3))
            addChild(bubble)
            layoutRandomBubble(bubble: bubble)
            styleBubble(bubble: bubble)
            physics(forBubble: bubble)
        }
    }
    
    private func styleBubble(bubble: SKShapeNode) {
        let color = UIColor(hue: CGFloat(arc4random_uniform(100))/100.0, saturation: 1.0, brightness: 0.75, alpha: 1.0)
        bubble.fillColor = color
        bubble.strokeColor = color
    }
    
    private func layoutRandomBubble(bubble: SKShapeNode) {
        let multiplier = CGFloat(arc4random()) / CGFloat(UInt32.max)
        bubble.position = CGPoint(x: floor(size.width * multiplier), y: floor(size.height * multiplier))
    }
    
    private func physics(forBubble bubble: SKNode) {
        let physics = SKPhysicsBody(rectangleOf: CGSize(width: bubble.frame.width, height: bubble.frame.height))
        physics.affectedByGravity = false
        physics.allowsRotation = false
        physics.friction = 0
        physics.restitution = 1.0
        physics.linearDamping = 0
        physics.mass = 0.4
        physics.categoryBitMask = 2
        physics.contactTestBitMask = 1
        physics.usesPreciseCollisionDetection = true
        bubble.physicsBody = physics
        physics.applyImpulse(CGVector(dx: randomNumber(), dy: randomNumber()))
    }
    
    private func randomNumber() -> CGFloat {
        let lowerLimit = -8
        let upperLimit = 8
        let number = CGFloat(Int(arc4random_uniform(UInt32(upperLimit - lowerLimit + 1))) + lowerLimit)
        return abs(number) > 6 ? number : randomNumber()
    }
}
