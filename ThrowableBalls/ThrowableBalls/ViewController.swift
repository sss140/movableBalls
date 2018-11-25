
//

import UIKit
import AudioToolbox
class MakeBall{
    let gravity:CGFloat = 0.1//重力加速度
    let adjustRate:CGFloat = 0.05//調整のための係数
    let bounceRate:CGFloat = 0.8//反発係数
    let radius:CGFloat = 60.0//ボールの半径
    
    var velX:CGFloat = 0.0, velY:CGFloat = 0.0//ボールの速度
    var culX:CGFloat = 0.0, culY:CGFloat = 0.0//ボールの計算用変数
    var posX:CGFloat = 0.0, posY:CGFloat = 0.0//ボールの位置
    var floorX:CGFloat = 0.0, floorY:CGFloat = 0.0//画面の大きさ
    
    var isDragged:Bool = false//ドラッグしてるかどうかのフラグ
    
    var parentView = UIView()
    var circleView = UIImageView()//ボールのビュー
    deinit{
        print("DEINIT")
    }
    init(ballColor:UIColor,myPos:CGPoint,velX:CGFloat,velY:CGFloat,myView:UIView){
        self.parentView = myView
        self.velX = velX * adjustRate
        self.velY = velY * adjustRate
        self.floorY = myView.bounds.maxY - radius
        self.floorX = myView.bounds.maxX - radius
        posX = myPos.x
        posY = myPos.y
        let size = CGSize(width: 2 * radius, height: 2 * radius)//図形のサイズ。要するに円の直径
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)//描画のコンテキストを作成
        let context = UIGraphicsGetCurrentContext()//コンテキストを定数に代入
        let drawCircle = CGRect(x: 0.0, y: 0.0, width: radius * 2, height: radius * 2)//描画開始
        let drawPath = UIBezierPath(ovalIn: drawCircle)//パス作成
        context?.setFillColor(UIColor.white.cgColor)//中の色
        drawPath.fill()//中を塗る
        context?.setStrokeColor(ballColor.cgColor)//外枠の色
        drawPath.stroke()//外枠を塗る
        let circleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        circleView = UIImageView(image:circleImage)
        circleView.center = myPos//表示位置の決定
        circleView.isUserInteractionEnabled = true//これでイベントをキャプチャできる！
        
        let myTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.step),userInfo: nil, repeats: true)//0.01秒ごとに物理計算を繰り返します。
        
        let myLongPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed(_:)))
        myLongPress.minimumPressDuration = 0
        self.circleView.addGestureRecognizer(myLongPress)
        myView.addSubview(circleView)
    }
    
    @objc func longPressed(_ sender:UILongPressGestureRecognizer){
        switch sender.state {
        case .began:
            parentView.bringSubviewToFront(circleView)//タップしたボールを最前面に表示でする。
            culX = sender.location(in: self.parentView).x
            culY = sender.location(in: self.parentView).y
            isDragged = true
        break
        case .ended:
            
            posX = sender.location(in: self.parentView).x
            posY = sender.location(in: self.parentView).y
            velX = sender.location(in: self.parentView).x - culX
            if abs(velX)>15.0{
                velX = 15.0 * (abs(velX)/velX)
            }
            velY = sender.location(in: self.parentView).y - culY
            if abs(velY)>15.0{
                velY = 15.0 * (abs(velY)/velY)
            }
            isDragged = false
        break
        default:
            //ドラッグに合わせてボールを表示
            circleView.center = sender.location(in: self.parentView)
            culX += (sender.location(in: self.parentView).x - culX) * 0.9
            culY += (sender.location(in: self.parentView).y - culY) * 0.9
        break
        }
    }
    
    @objc func step(){
        if isDragged == false{
        velY += gravity
        posY += velY
        //ボールが床に着地したら跳ね返る
        if(posY > floorY ){
            posY = floorY-(posY - floorY)
            velY = collide(targetVel: velY)
        }
        circleView.center.y = posY
        
        //壁にあたったら跳ね返る
        posX += velX
        if(posX>floorX){
            posX = floorX - (posX - floorX)
            velX = collide(targetVel: velX)
        }
        if(posX<radius){
            posX = radius - (posX - radius)
            velX = collide(targetVel: velX)
        }
        circleView.center.x = posX
        }
    }
    func collide(targetVel:CGFloat)->CGFloat{
        let vel:CGFloat = targetVel * -1 * bounceRate
        /*if abs(vel) > 0.8{
        AudioServicesPlaySystemSound(1003)
        AudioServicesDisposeSystemSoundID(1003)
        }*/
        return vel
    }
}

class ViewController: UIViewController {
    let ballColorsArray:[UIColor] = [UIColor.black,UIColor.blue,UIColor.brown,UIColor.red]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        for i in 0..<ballColorsArray.count{
            let startX = CGFloat(i+1) * self.view.bounds.maxX/CGFloat(ballColorsArray.count + 1)
            let startY = self.view.bounds.maxY/CGFloat(4.0)
            let myBallColor = ballColorsArray[i]
            var _ = MakeBall(ballColor: myBallColor,myPos: CGPoint(x: startX, y: startY),velX: CGFloat(0.0),velY: CGFloat(0.0),myView: self.view)//ボールの生成
        }
    }
}
