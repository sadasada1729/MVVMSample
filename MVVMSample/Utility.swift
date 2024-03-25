//
//  Utility.swift
//  MVVMSample
//
//  Created by 長田公喜 on 2024/03/25.
//

import Foundation
import UIKit
import AudioToolbox

extension Array {
    subscript (safe index: Index) -> Element? {
        get{
            return indices.contains(index) ? self[index] : nil
        }
        set{
            if indices.contains(index) {
                if let new = newValue{
                    self[index] = new
                }
            }
        }
    }
}

extension UIImage {
    func flipHorizontal() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let imageRef = self.cgImage else{ return self }
        guard let context = UIGraphicsGetCurrentContext() else{ return self }
        context.translateBy(x: size.width, y: size.height)
        context.scaleBy(x: -1.0, y: -1.0)
        context.draw(imageRef, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let flipHorizontalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return flipHorizontalImage ?? self
    }
    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

extension UIView {
    /**
     震えるアニメーションを再生
     - parameters:
        - range: 震える振れ幅
        - speed: 震える速さ
        - isSync: 複数対象とする場合,同時にアニメーションするかどうか
     */
    func startVibrateAnimation(range: Double = 2.0, speed: Double = 0.15, isSync: Bool = false) {
        if self.layer.animation(forKey: "VibrateAnimationKey") != nil {
            return
        }
        let animation: CABasicAnimation
        animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.beginTime = isSync ? 0.0 : Double((Int(arc4random_uniform(UInt32(9))) + 1)) * 0.1
        animation.isRemovedOnCompletion = false
        animation.duration = speed
        animation.fromValue = range.toRadian
        animation.toValue = -range.toRadian
        animation.repeatCount = Float.infinity
        animation.autoreverses = true
        self.layer.add(animation, forKey: "VibrateAnimationKey")
    }
    /// 震えるアニメーションを停止
    func stopVibrateAnimation() {
        self.layer.removeAnimation(forKey: "VibrateAnimationKey")
    }
}

extension Date {
    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }
    ///同じ年か
    func isInSameYear(as date: Date) -> Bool {
        isEqual(to: date, toGranularity: .year)
    }
    ///同じ月か
    func isInSameMonth(as date: Date) -> Bool {
        isEqual(to: date, toGranularity: .month)
    }
    ///同じ週か
    func isInSameWeek(as date: Date) -> Bool {
        isEqual(to: date, toGranularity: .weekOfYear)
    }
    ///同じ日か
    func isInSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
}

extension Date {
    ///create date
    func create(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year   = year   ?? calendar.component(.year,   from: self)
        components.month  = month  ?? calendar.component(.month,  from: self)
        components.day    = day    ?? calendar.component(.day,    from: self)
        components.hour   = hour   ?? calendar.component(.hour,   from: self)
        components.minute = minute ?? calendar.component(.minute, from: self)
        components.second = second ?? calendar.component(.second, from: self)
        return calendar.date(from: components) ?? Date()
    }
}

extension UIView {

    // 点線・破線を描くメソッド

    func drawDashedLine(color: UIColor, lineWidth: CGFloat, lineSize: NSNumber, spaceSize: NSNumber, from: CGPoint, to: CGPoint) {

        let dashedLineLayer: CAShapeLayer = CAShapeLayer()
        dashedLineLayer.frame = self.bounds
        dashedLineLayer.strokeColor = color.cgColor
        dashedLineLayer.lineWidth = lineWidth
        dashedLineLayer.lineDashPattern = [lineSize, spaceSize]
        let path: CGMutablePath = CGMutablePath()
        path.move(to: from)
        path.addLine(to: to)
        dashedLineLayer.path = path

        self.layer.addSublayer(dashedLineLayer)

    }

}

extension Double {
    /// ラジアンに変換
    var toRadian: Double {
        return .pi * self / 180
    }
}

extension UIBezierPath{
    func fixPathSize(rect: CGRect){
        let pointScale = (rect.width >= rect.height) ? max(bounds.height, bounds.width) : min(bounds.height, bounds.width)
        let pointTransform = CGAffineTransform(scaleX: 1/pointScale, y: 1/pointScale)
        apply(pointTransform)
        let multiplier = min(rect.width, rect.height)
        let transform = CGAffineTransform(scaleX: multiplier, y: multiplier)
        apply(transform)
    }
}

class Utility{
    
    static func notificationCircle(radius: CGFloat, center: CGPoint, color: CGColor)->CAShapeLayer{
        let circlePath = UIBezierPath()
        circlePath.addArc(withCenter: center,
                     radius: radius,
                     startAngle: 0,
                     endAngle: .pi * 2.0,
                     clockwise: true)
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = color
        circleLayer.strokeColor = color
        circleLayer.lineWidth = 0
        return circleLayer
    }
    
    static func stringSlice(str: String, startIndex: Int, endIndex: Int)->String?{
        if str.count <= endIndex || str.count <= startIndex{ return nil }
        let zero = str.startIndex
        let start = str.index(zero, offsetBy: startIndex)
        let end = str.index(zero, offsetBy: endIndex)
        return String(str[start...end])
    }
    
    static func dateFormDetail(date: Date, locale: String)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ddMMMMyyyy", options: 0, locale: NSLocale(localeIdentifier: locale) as Locale)
        return formatter.string(from: date)
    }
    
    static func fileShare(fileName: String, target: UIViewController, completion:(()->())?=nil) {
        guard let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first else { return }
        let filePath = dir.appendingPathComponent(fileName, isDirectory: false)
        let controller = UIActivityViewController.init(activityItems: [filePath], applicationActivities: nil)
        controller.excludedActivityTypes = [
        ]
        target.present(controller, animated: true, completion: completion)
    }
    
    static func stringShare(text: String, target: UIViewController, completion: (()->())?=nil){
        let items = [text]
        let activityVc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        target.present(activityVc, animated: true, completion: nil)
    }
    
    static func setBorder(view: UIView, borderColor: CGColor, borderWidth: CGFloat, cornerRadius: CGFloat, shadowColor: CGColor?, shadowOpacity: Float?, shadowRadius: CGFloat?, shadowOffset: CGSize?){
        view.layer.borderColor = borderColor
        view.layer.borderWidth = borderWidth
        setLayerDesign(view: view, cornerRadius: cornerRadius, shadowColor: shadowColor, shadowOpacity: shadowOpacity, shadowRadius: shadowRadius, shadowOffset: shadowOffset)
    }
    
    static func gradationLayer(frame: CGRect, colors: Array<CGColor>, startPoint: CGPoint? = nil, endPoint: CGPoint? = nil, type: CAGradientLayerType = .axial)->CAGradientLayer{
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        gradientLayer.colors = colors
        gradientLayer.startPoint = startPoint ?? CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = endPoint ?? CGPoint(x: 0.0, y: 1.0)
        gradientLayer.type = type
        return gradientLayer
    }
    
    static func fixSafeAreaHeight(views: UIView){
        let safeAreaTop = views.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        for view in views.subviews{
            view.center.y += safeAreaTop
        }
        
    }
    
    static func vibrate(){
        AudioServicesPlaySystemSound(SystemSoundID(1519))
    }
    
    static func pressSound(){
        var soundIdRing:SystemSoundID = 0
        let soundUrl = NSURL(fileURLWithPath: "/System/Library/Audio/UISounds/key_press_click.caf")
        AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
        AudioServicesPlaySystemSound(soundIdRing)
    }
    
    static func removeAllSubviewsLayers(parentView: UIView){
        removeAllSubviews(parentView: parentView)
        removeAllSubLayer(parentView: parentView)
    }
    
    static func removeAllSubviews(parentView: UIView){
        for subview in parentView.subviews{
            subview.removeFromSuperview()
        }
    }
    
    static func removeAllSubLayer(parentView: UIView){
        parentView.layer.sublayers?.removeAll()
    }
    
    static func setBorder(view: UIView, frame: CGRect? = nil, borderWidth: CGFloat? = nil, borderColor: CGColor? = nil){
        let border = CALayer()
        if let frame = frame{
            border.frame = frame
        }else{
            border.frame = CGRect(x: 2, y: view.frame.height-2, width: view.frame.width-4, height: borderWidth ?? 1)
        }
        if let borderWidth = borderWidth{
            border.borderWidth = borderWidth
        }else{
            border.borderWidth = 2
        }
        if let borderColor = borderColor{
            border.borderColor = borderColor
        }else{
            border.borderColor = UIColor.gray.cgColor
        }
        view.layer.addSublayer(border)
    }
    
    static func setLayerDesign(view: UIView, cornerRadius: CGFloat, shadowColor: CGColor?, shadowOpacity: Float?, shadowRadius: CGFloat?, shadowOffset: CGSize?){
        view.layer.cornerRadius = cornerRadius
        view.layer.shadowColor = shadowColor
        view.layer.shadowOpacity = shadowOpacity ?? 0
        view.layer.shadowRadius = shadowRadius ?? 0
        view.layer.shadowOffset = shadowOffset ?? .zero
    }
    
    static func setAlert(title: String?, message: String? = nil, target: UIViewController, completion: (()->())? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            if let completion = completion{
                completion()
            }
        }
        setAlertAction(actions: [ok], alert: alert, target: target)
    }
    
    static func setAlertAction(actions: Array<UIAlertAction>, alert: UIAlertController, target: UIViewController, sourceRect: CGRect? = nil){
        for action in actions{
            alert.addAction(action)
        }
        let screenSize = UIScreen.main.bounds
        alert.popoverPresentationController?.sourceView = target.view
        alert.popoverPresentationController?.sourceRect = sourceRect ?? CGRect(x: screenSize.size.width / 2, y: screenSize.size.height, width: 0, height: 0)

        target.present(alert, animated: true, completion: nil)
    }
    
    static func isBoolNumber(number: NSNumber)->Bool{
        let boolID = CFBooleanGetTypeID()
        let numID = CFGetTypeID(number)
        return boolID == numID
    }
    
    static func createDirInDocument(dirPath: String) -> Bool{
        let fileManager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        do {
            try fileManager.createDirectory(atPath: "\(documentsPath)/\(dirPath)", withIntermediateDirectories: true, attributes: nil)
        }catch{
            return false
        }
        return true
    }
    
    static func getSaveDictionary(filePath: String)->Dictionary<String,Any>{
        let dataURL: URL = {
            let url = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask).first!
            let dataUrl = url.appendingPathComponent(filePath)
            return dataUrl
        }()
        var dict: Dictionary<String,Any> = [:]
        do{
            let data = try Data(contentsOf: dataURL)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            //print(json)
            dict = json as! Dictionary<String,Any>
        }catch{
            print("Error!:\(error)")
        }
        return dict
    }
    
    static func dictionaryJsonConvertedData(dict: Dictionary<String, Any>)->Data{
        var jsonData: Data = Data()
        do{
            jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
        } catch {
            print("Error!:\(error)")
        }
        return jsonData
    }
    
    static func saveDictionary(dirName: String, fileName: String, dict: Dictionary<String,Any>)throws{
        let data = dictionaryJsonConvertedData(dict: dict)
        if !createDirInDocument(dirPath: dirName){ return }
        let dataURL: URL = {
            let url = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask).first!
            let dataUrl = url.appendingPathComponent("\(dirName)/\(fileName)")
            return dataUrl
        }()
        try data.write(to: dataURL)
    }
    
    static func fileExist(filePath: String) -> Bool{
        return FileManager.default.fileExists(atPath: NSHomeDirectory() + "/Documents/" + filePath)
    }
    
    static func getSavedStringFile(filePath: String)->String{
        let dataURL: URL = {
            let url = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask).first!
            let dataUrl = url.appendingPathComponent(filePath)
            return dataUrl
        }()
        var text = ""
        do{
            let data = try Data(contentsOf: dataURL)
            text = String(data: data, encoding: .utf8) ?? ""
        }catch{
            print("Error!:\(error)")
        }
        return text
    }
    
    static func saveString(dirName: String, fileName: String, text: String)throws{
        if !createDirInDocument(dirPath: dirName){ return }
        let dataURL: URL = {
            let url = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask).first!
            let dataUrl = url.appendingPathComponent("\(dirName)/\(fileName)")
            return dataUrl
        }()
        if let strm = OutputStream(url:dataURL, append: false) {
            strm.open()
            defer {
                strm.close()
            }
            let BOM = "\u{feff}"
            strm.write(BOM, maxLength: 3)
            let data = text.data(using: .utf8)
            let _ = data?.withUnsafeBytes {
                       strm.write($0.baseAddress!, maxLength: Int(data?.count ?? 0))
            }
        }
    }
    
    static func viewImageConverter(_ view : UIView) -> UIImage {
        let rect = view.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        let context : CGContext = UIGraphicsGetCurrentContext()!
        view.layer.render(in: context)
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    static func superShadow(_ frame: CGRect, cornerRadius: CGFloat, shadowOffset: CGSize = CGSize(width: 2, height: 2), shadowRadius: CGFloat = 5, shadowOpacity: Float = 1)->UIView{
        let view = UIView()
        view.backgroundColor = .white
        view.frame = frame
        view.layer.borderWidth = 0
        view.layer.cornerRadius = cornerRadius
        view.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        view.layer.shadowOffset = shadowOffset
        view.layer.shadowRadius = shadowRadius
        view.layer.shadowOpacity = shadowOpacity
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        layer.frame = .zero
        layer.borderWidth = 0
        layer.cornerRadius = cornerRadius
        layer.shadowColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        layer.shadowOffset = CGSize(width: -1*shadowOffset.width, height: -1*shadowOffset.height)
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        view.layer.insertSublayer(layer, at: 0)
        return view
    }
    
    static func shadow(_ frame: CGRect, cornerRadius: CGFloat, shadowOffset: CGSize = CGSize(width: 1.2, height: 2.2), shadowRadius: CGFloat = 5, shadowOpacity: Float = 1, shadowColor: CGColor = UIColor.black.cgColor )->CALayer{
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        layer.frame = frame
        layer.borderWidth = 0
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        return layer
    }
    
    static func setSelectedCellBackground(cell: UITableViewCell){
        let backgroundView: UIView = {
            let v = UIView()
            v.backgroundColor = .clear
            return v
        }()
        cell.selectedBackgroundView = backgroundView
    }
    
    static func safeAreaTop(view: UIView)->CGFloat{
        let safeareaTop = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        return safeareaTop
    }
    
    static func safeAreaBottom(view: UIView)->CGFloat{
        return view.safeAreaInsets.bottom
    }
    
    static func getToday()->(year: Int?, month: Int?, day: Int?, hour: Int?){
        let calendar = Calendar(identifier: .gregorian)
        let date = Date()
        let compornent = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        return (year: compornent.year, month: compornent.month, day: compornent.day, hour: compornent.hour)
    }
    
    static func dateFormMonth(date: Date, locale: Locale)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMMyyyy", options: 0, locale: locale)
        return formatter.string(from: date)
    }
    
    static func dateFormDay(date: Date, locale: Locale)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ddMMMMyyyy", options: 0, locale: locale)
        return formatter.string(from: date)
    }

    static func makeDate(year: Int, month: Int, day: Int?)->Date?{
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.year = year
        components.month = month
        if let day = day{
            components.day = day
        }
        return calendar.date(from: components)
    }
    
    static func calcWeekDay(year: Int, month: Int, day: Int)->Int?{
        let s = "\(year)/\(month)/\(day)"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let d = formatter.date(from: s) else { return nil }
        guard let dc = formatter.calendar?.component(.weekday, from: d) else { return nil }
        return dc-1
    }
    
    //yyyy-mm-dd
    static func makeDateString(date: Date)->String{
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let year = components.year else { return "" }
        guard let month = components.month else { return "" }
        guard let day = components.day else { return "" }
        return "\(year)-\(month)-\(day)"
    }
    
    //uiviewの左右反転
    static func flipHorizontal(view: UIView){
        view.transform = CGAffineTransform(scaleX: -1, y: 1)
    }
    
    static func getImage(_ view : UIView) -> UIImage {
        let rect = view.bounds
        return UIGraphicsImageRenderer(size: rect.size).image { context in
            view.layer.render(in: context.cgContext)
        }
    }
    
    static func textAnimation(label: UILabel, text: String, completion:@escaping()->()){
        var index: Int = 1
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if index == text.count{
                timer.invalidate()
                completion()
            }
            label.text = String(text.prefix(index))
            index += 1
        }
    }
    
    static func neumorphismView(view: UIView, color1: CGColor, color2: CGColor, shadowRadius: CGFloat, shadowOffset: CGSize, shadowOpacity: Float, margin: (x1: CGFloat,x2: CGFloat) = (x1: 3,x2:5))->UIView{

        let shadowView: UIView = {
            let v = UIView(frame: view.frame)
            Utility.setBorder(view: v, borderColor: view.backgroundColor?.cgColor ?? UIColor.white.cgColor, borderWidth: 0, cornerRadius: view.layer.cornerRadius, shadowColor: color1, shadowOpacity: shadowOpacity, shadowRadius: shadowRadius, shadowOffset: CGSize(width: -shadowOffset.width, height: -shadowOffset.height))
            v.backgroundColor = view.backgroundColor
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: view.bounds.height-margin.x1))
            path.addLine(to: .zero)
            path.addLine(to: CGPoint(x: view.bounds.width-margin.x1, y: 0))
            v.layer.shadowPath = path.cgPath
            return v
        }()
        let shadowView1: UIView = {
            let v = UIView(frame: view.bounds)
            Utility.setBorder(view: v, borderColor: view.backgroundColor?.cgColor ?? UIColor.white.cgColor, borderWidth: 0, cornerRadius: view.layer.cornerRadius, shadowColor: color2, shadowOpacity: shadowOpacity, shadowRadius: shadowRadius, shadowOffset: CGSize(width: shadowOffset.width, height: shadowOffset.height))
            v.backgroundColor = view.backgroundColor
            let path = UIBezierPath()
            path.move(to: CGPoint(x: margin.x1, y: view.bounds.height))
            path.addLine(to: CGPoint(x: view.bounds.width, y: view.bounds.height))
            path.addLine(to: CGPoint(x: view.bounds.width, y: margin.x2))
            v.layer.shadowPath = path.cgPath
            return v
        }()
        shadowView.addSubview(shadowView1)
        return shadowView
    }
    
    static func rotate(view: UIView, duration: Double, repeatCount: Float = .greatestFiniteMagnitude){
        let rotationAnimation = CABasicAnimation(keyPath:"transform.rotation.z")
        rotationAnimation.toValue = CGFloat(Double.pi / 180) * 360
        rotationAnimation.duration = duration
        rotationAnimation.repeatCount = repeatCount
        view.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    static func rotate3D(view: UIView, duration: Double){
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.repeat]) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25) {
                view.transform = CGAffineTransform(scaleX: 0.01, y: 1)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                view.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25) {
                view.transform = CGAffineTransform(scaleX: 0.01, y: 1)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                view.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }
    
    static func stringMaker(value: Int?)->String{
        if let value = value{
            return String(value)
        }else{
            return ""
        }
    }
    static func stringMaker(value: Double?)->String{
        if let value = value{
            return String(value)
        }else{
            return ""
        }
    }
    
    static func intMaker(value: String?)->Int?{
        if let value = value{
            return Int(value)
        }else{
            return nil
        }
    }
    
    static func doubleMaker(value: String?)->Double?{
        if let value = value{
            return Double(value)
        }else{
            return nil
        }
    }
    
    static func getNextDate(date: Date)->Date?{
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(byAdding: .day, value: 1, to: date)
    }
    
    static func dismissAllPresentedViewcontroller(target: UIViewController?, animated: Bool){
        var preVC = UIViewController()
        while let presentedVC = target?.presentedViewController {
            presentedVC.dismiss(animated: animated)
            if ObjectIdentifier(preVC) == ObjectIdentifier(presentedVC){ break }
            preVC = presentedVC
        }
    }
    
    //columns は消している
    static func getCSV(fileName: String)->[[String]]{
        var csv: [[String]] = []
        guard let path = Bundle.main.path(forResource:fileName, ofType:"csv") else { return csv }
        guard let csvString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else { return csv }
        let csvLines = csvString.components(separatedBy: .newlines)
        for i in 1..<csvLines.count{
            let line = csvLines[i].components(separatedBy: ",")
            if line != [""]{
                csv.append(line)
            }
        }
        return csv
    }
    
    static func makeCSVString(csvArr: [[String]])->String{
        var csv: String = ""
        for line in csvArr{
            for  value in line{
                csv += "\"" + value + "\","
            }
            if !csv.isEmpty{
                csv.removeLast()
            }
            csv += "\n"
        }
        return csv
    }
    
    static func setDark(){
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.overrideUserInterfaceStyle = .dark
    }
    
    static func setLight(){
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            window?.overrideUserInterfaceStyle = .light
    }
    
    static func insertCharacter(text: String, element: Character, index: Int)->String{
        var text_ = text
        if index > text.count || index < 0{ return text_ }
        text_.insert(element, at: text_.index(text_.startIndex, offsetBy: index))
        return text_
    }
    
    static func removeCharacter(text: String, index: Int)->String{
        var text_ = text
        if index < 0 || index >= text.count{ return text_ }
        text_.remove(at: text_.index(text_.startIndex, offsetBy: index))
        return text_
    }
    
    //for 文で回すとIDが一意にならない事がある
    static func createID()->String{
        let df = DateFormatter()
        let locale = Locale(identifier: "en_US_POSIX")
        let timeZone = TimeZone(identifier: "Asia/Tokyo")
        df.dateFormat = "yyyyMMddHHmmssSSS"
        df.locale = locale
        df.timeZone = timeZone
        return df.string(from: Date())
    }
    
    static func createID(length: Int)->String{
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString = ""
        for _ in 0 ..< length {
            randomString += String(letters.randomElement()!)
        }
        return randomString
    }
    
    static func getTimeStringFromSeconds(sec: Double, displayInSeconds: Bool = false)->String{
        if displayInSeconds{ return Utility.getTimeStringFromSecondsDisplayInSeconds(sec: sec) }
        if sec > 3600000{ return "999:59:59" }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.second, .minute, .hour]
        if let data = formatter.string(from: sec){
            let arr = data.components(separatedBy: ":").map{String(format: "%02d", Int($0) ?? 0)}
            let mmsec = Int(floor(sec.truncatingRemainder(dividingBy: 1)*100))
            if arr.count == 3{
                return arr.joined(separator: ":")//"\(arr[0]):\(arr[1]).\(arr[2])"
            }else if arr.count == 2{
                return "\(arr.joined(separator: ":")).\(String(format: "%02d", mmsec))"
            }else if arr.count == 1{
                return "00:\(arr[0]).\(String(format: "%02d", mmsec))"
            }
        }
        return "00:00:00"
    }
    
    static func getTimeStringFromSecondsDisplayInSeconds(sec: Double)->String{
        if sec > 999999{ return "999999.99" }
        let mmsec = Int(floor(sec.truncatingRemainder(dividingBy: 1)*100))
        return "\(Int(sec)).\(String(format: "%02d", mmsec))"
    }
    
    static func reformDate(date: Date)->(year: Int?, month: Int?, day: Int?, hour: Int?){
        let calendar = Calendar(identifier: .gregorian)
        let compornent = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        return (year: compornent.year, month: compornent.month, day: compornent.day, hour: compornent.hour)
    }
    
    static func setAlertAction(title: String, style: UIAlertAction.Style, imageName: String?, size: CGSize?, imageTintColor: UIColor?, titleTextColor: UIColor?, handler: ((UIAlertAction) -> Void)?)->UIAlertAction{
        let action = UIAlertAction(title: title, style: style, handler: handler)
        action.setValue(UIImage(named:imageName ?? "")?.withRenderingMode(.alwaysTemplate).resize(targetSize: size ?? .zero), forKey: "image")
        action.setValue(imageTintColor, forKey: "imageTintColor")
        action.setValue(titleTextColor, forKey: "titleTextColor")
        return action
    }
    
    static func weekdaySymbols()->[String]{
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = .current
        return calendar.weekdaySymbols
    }
    
    static func setBtnConfiguration(btn: UIButton, text: String, imgName: String, tintColor: UIColor, titleColor: UIColor, insets: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 10, trailing: 0), imagePadding: CGFloat = 0, titlePadding: CGFloat = 0, fontSize: Double? = nil){
        var configuration = UIButton.Configuration.filled()
        if let fontSize = fontSize{
            let container = AttributeContainer([
                .font: UIFont.systemFont(ofSize: fontSize)
            ])
            configuration.attributedTitle = AttributedString(text, attributes: container)
        }else{
            configuration.title = text
        }
        configuration.image = UIImage(named: imgName)?.withRenderingMode(.alwaysTemplate).resize(targetSize: CGSize(width: btn.bounds.height*2/3-imagePadding-insets.top, height: btn.bounds.height*2/3-imagePadding-insets.top)).withTintColor(tintColor)
        configuration.imagePlacement = .top
        configuration.titlePadding = titlePadding
        configuration.imagePadding = imagePadding
        configuration.contentInsets = insets
        btn.configuration = configuration
        btn.tintColor = .clear
        btn.setTitleColor(titleColor, for: .normal)
    }
    
    static func setLabel(label: UILabel, text: String, textColor: UIColor, backgroundColor: UIColor, textAlignment: NSTextAlignment, font: UIFont, numberOfLines: Int){
        label.text = text
        label.textColor = textColor
        label.backgroundColor = backgroundColor
        label.textAlignment = textAlignment
        label.font = font
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = numberOfLines
    }
    
    ///polorPosition(theta: 90, r: 1)->CGPoint(x:0, y:1)
    static func polorPosition(theta: Double, r: Double)->CGPoint{
        CGPoint(x: r*cos(theta.toRadian), y: r*sin(theta.toRadian))
    }
    
    static func setRotateAnimation1(parent: UIView, width: CGFloat, duration: Double){
        let color1: UIColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        let color2: UIColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        let color3: UIColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        setChildView(r: parent.bounds.width/2, theta: 0, color: color1, width: width, parent: parent)
        setChildView(r: parent.bounds.width/2, theta: 120, color: color2, width: width, parent: parent)
        setChildView(r: parent.bounds.width/2, theta: 240, color: color3, width: width, parent: parent)
        Utility.rotate(view: parent, duration: duration)
    }
    
    static func setRotateAnimation2(parent: UIView, width: CGFloat, duration: Double){
        let color1: UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        let color2: UIColor = #colorLiteral(red: 0.3430855572, green: 0.3430855572, blue: 0.3430855572, alpha: 1)
        let color3: UIColor = #colorLiteral(red: 0.4566487074, green: 0.4566487074, blue: 0.4566487074, alpha: 1)
        let color4: UIColor = #colorLiteral(red: 0.5426063538, green: 0.5426063538, blue: 0.5426063538, alpha: 1)
        let color5: UIColor = #colorLiteral(red: 0.7213475108, green: 0.7213474512, blue: 0.7213475108, alpha: 1)
        let color6: UIColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        setChildView(r: parent.bounds.width/2, theta: 0, color: color1, width: width, parent: parent)
        setChildView(r: parent.bounds.width/2, theta: 60, color: color2, width: width, parent: parent)
        setChildView(r: parent.bounds.width/2, theta: 120, color: color3, width: width, parent: parent)
        setChildView(r: parent.bounds.width/2, theta: 180, color: color4, width: width, parent: parent)
        setChildView(r: parent.bounds.width/2, theta: 240, color: color5, width: width, parent: parent)
        setChildView(r: parent.bounds.width/2, theta: 300, color: color6, width: width, parent: parent)
        Utility.rotate(view: parent, duration: duration)
    }
    
    static func setChildView(r: Double, theta: Double, color: UIColor, width: CGFloat, parent: UIView){
        let child = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width))
        child.layer.cornerRadius = width/2
        child.backgroundColor = color
        child.center = Utility.polorPosition(theta: theta, r: r)
        child.center.x += parent.bounds.width/2
        child.center.y += parent.bounds.width/2
        parent.addSubview(child)
    }
    
    static func getTopViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        if let rootViewController = windowScene?.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            return rootViewController
        }else{
            return nil
        }
    }
    
    static func isPad()->Bool{
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static func screenSize()->CGSize{
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else{ return .zero }
        return window.screen.bounds.size
    }
    
    static func setBackBtn(target: UIViewController, tintColor: UIColor){
        let backBtn: UIButton = {
            let b = UIButton(frame: CGRect(x: 8, y: Utility.safeAreaTop(view: target.view)+10, width: 45, height: 45))
            b.setImage(UIImage(named: "backImg")?.withRenderingMode(.alwaysTemplate), for: .normal)
            b.tintColor = tintColor
            b.addAction(UIAction(handler: {_ in
                target.dismiss(animated: true, completion: nil)
            }), for: .touchUpInside)
            return b
        }()
        target.view.addSubview(backBtn)
    }

    static func secToTime(duration: Int)->(hour: Int?, min: Int?, sec: Int){
        var duration: Int = duration
        let hour = ((duration/(60*60)) == 0) ? nil : duration/(60*60)
        duration -= (hour ?? 0)*60*60
        let min = ((duration/60) == 0) ? nil : duration/60
        duration -= (min ?? 0)*60
        let sec = duration
        return (hour: hour, min: min, sec: sec)
    }
    
    static func maskImage(image: UIImage, maskImage: UIImage) -> UIImage {
        guard let maskRef: CGImage = maskImage.cgImage else { return UIImage() }
        guard let provider = maskRef.dataProvider else { return UIImage() }
        guard let mask: CGImage = CGImage(
            maskWidth: maskRef.width,
            height: maskRef.height,
            bitsPerComponent: maskRef.bitsPerComponent,
            bitsPerPixel: maskRef.bitsPerPixel,
            bytesPerRow: maskRef.bytesPerRow,
            provider: provider,
            decode: nil,
            shouldInterpolate: false) else{ return UIImage() }
        guard let original = image.cgImage else{ return UIImage() }
        let maskedImageRef: CGImage = original.masking(mask)!
        let maskedImage: UIImage = UIImage(cgImage: maskedImageRef)
        return maskedImage
    }
    
    static func calculateBezierPathBounds(paths: [UIBezierPath]) -> CGRect {
        let myPaths = UIBezierPath()
        for path in paths {
            myPaths.append(path)
        }
        return myPaths.bounds
    }
}
