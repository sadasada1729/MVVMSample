//
//  ViewController.swift
//  MVVMSample
//
//  Created by 長田公喜 on 2024/03/25.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    ///Combiine
    private let viewModel = ViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    private var startTimes: [Date] = []
    private var stopTimes: [Date] = []
    
    private let content = UIView()
    private let nameLabel = UILabel()
    private let splitLabel = UILabel()
    private let lapLabel = UILabel()
    private let lapNumberLabel = UILabel()
    private let rightBtn = UIButton()
    private let leftBtn = UIButton()
    
    private lazy var initViewLayout: Void = {
        setView()
        bind()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        _ = initViewLayout
    }
}

private extension ViewController {
    func bind() {
        viewModel.$splitTime
            .sink { completion in
                
            } receiveValue: { item in
                self.splitLabel.text = item
            }
            .store(in: &subscriptions)
        viewModel.$lapTime
            .sink { completion in

            } receiveValue: { item in
                self.lapLabel.text = item
            }
            .store(in: &subscriptions)
        viewModel.$lapNumber
            .sink { completion in

            } receiveValue: { item in
                self.lapNumberLabel.text = item
            }
            .store(in: &subscriptions)
        viewModel.$name
            .sink { completion in

            } receiveValue: { item in
                self.nameLabel.text = item
            }
            .store(in: &subscriptions)
        viewModel.$leftBtnTitle
            .sink { completion in

            } receiveValue: { item in
                self.leftBtn.setTitle(item, for: .normal)
            }
            .store(in: &subscriptions)
        viewModel.$rightBtnTitle
            .sink { completion in

            } receiveValue: { item in
                self.rightBtn.setTitle(item, for: .normal)
            }
            .store(in: &subscriptions)
    }
}

private extension ViewController {
    func setView() {
        setBackground()
        setMainContent()
        setNameLabel()
        setSplitLabel()
        setLapLabel()
        setLapNumberLabel()
        setLeftBtn()
        setRightBtn()
        
    }
    
    func setBackground() {
        view.layer.addSublayer(Utility.gradationLayer(frame: view.bounds, colors: [#colorLiteral(red: 0.4373720288, green: 0.7444792986, blue: 0.6293398142, alpha: 1), #colorLiteral(red: 0.2531401515, green: 0.4377195239, blue: 0.3706095815, alpha: 1)]))
    }
    
    func setMainContent() {
        let width: CGFloat = 320
        let height: CGFloat = 170
        content.frame = CGRect(x: (view.bounds.width-width)/2, y: (view.bounds.height-height)/2, width: width, height: height)
        content.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3765780215)
        content.layer.cornerRadius = 12
        content.layer.borderWidth = 0.8
        content.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        view.addSubview(content)
    }
    
    func setNameLabel() {
        let textColor = #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1)
        nameLabel.frame = CGRect(x: 0, y: 0, width: content.bounds.width, height: 30)
        Utility.setLabel(label: nameLabel, text: "", textColor: textColor, backgroundColor: .clear, textAlignment: .center, font: .systemFont(ofSize: 17), numberOfLines: 1)
        content.addSubview(nameLabel)
    }
    
    func setSplitLabel() {
        let textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        splitLabel.frame = CGRect(x: 0, y: nameLabel.frame.maxY, width: content.bounds.width, height: 50)
        Utility.setLabel(label: splitLabel, text: "", textColor: textColor, backgroundColor: .clear, textAlignment: .center, font: .monospacedSystemFont(ofSize: 22, weight: .regular), numberOfLines: 1)
        content.addSubview(splitLabel)
    }
    
    func setLapLabel() {
        let textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        lapLabel.frame = CGRect(x: 0, y: splitLabel.frame.maxY, width: content.bounds.width, height: 50)
        Utility.setLabel(label: lapLabel, text: "", textColor: textColor, backgroundColor: .clear, textAlignment: .center, font: .monospacedSystemFont(ofSize: 18, weight: .regular), numberOfLines: 1)
        content.addSubview(lapLabel)
    }
    
    
    func setLapNumberLabel() {
        let textColor: UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        lapNumberLabel.frame = CGRect(x: content.bounds.width-70-30, y: content.bounds.height-10-40, width: 30, height: 30)
        Utility.setLabel(label: lapNumberLabel, text: "", textColor: textColor, backgroundColor: .clear, textAlignment: .center, font: .systemFont(ofSize: 12), numberOfLines: 1)
        content.addSubview(lapNumberLabel)
    }
    
    func setLeftBtn() {
        let width: CGFloat = 60
        let borderColor: CGColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        let titleColor: UIColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        leftBtn.frame = CGRect(x: 5, y: content.bounds.height-width-5, width: width, height: width)
        Utility.setBorder(view: leftBtn, borderColor: borderColor, borderWidth: 0.6, cornerRadius: 17, shadowColor: nil, shadowOpacity: nil, shadowRadius: nil, shadowOffset: nil)
        leftBtn.setTitleColor(titleColor, for: .normal)
        leftBtn.addAction(UIAction(handler: { _ in
            self.viewModel.leftBtnTapped()
        }), for: .touchUpInside)
        content.addSubview(leftBtn)
    }
    
    func setRightBtn() {
        let width: CGFloat = 60
        let borderColor: CGColor = #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)
        let titleColor: UIColor = #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)
        rightBtn.frame = CGRect(x: content.bounds.width-width-5, y: content.bounds.height-width-5, width: width, height: width)
        Utility.setBorder(view: rightBtn, borderColor: borderColor, borderWidth: 0.6, cornerRadius: 17, shadowColor: nil, shadowOpacity: nil, shadowRadius: nil, shadowOffset: nil)
        rightBtn.setTitleColor(titleColor, for: .normal)
        rightBtn.addAction(UIAction(handler: { _ in
            self.viewModel.rightBtnTapped()
        }), for: .touchUpInside)
        content.addSubview(rightBtn)
    }
}

