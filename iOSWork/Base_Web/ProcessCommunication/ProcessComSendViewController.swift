//
//  ProcessComSendViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2023/12/26.
//

import UIKit

import CocoaAsyncSocket
class ProcessComSendViewController: UIViewController {

    var clientSocket:GCDAsyncSocket?
    var arrClient:[GCDAsyncSocket]?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "APP跨进程通信"
        view.backgroundColor = UIColor.white
        arrClient = [GCDAsyncSocket]()
        clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        startListen()
        
        view.addSubview(vInput)
        vInput.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.top.equalTo(200)
            make.height.equalTo(25)
        }
        
        view.addSubview(lbl)
        lbl.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.top.equalTo(100)
            make.height.equalTo(25)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btnSend)
        
        // Do any additional setup after loading the view.
    }
    
    @objc func sendInfo(sender:UIButton){
        if clientSocket != nil && clientSocket!.isConnected{
            clientSocket?.write("123".data(using: .utf8), withTimeout: -1, tag: 0)
        } else {
            startListen()
        }
    }

    lazy var vInput: UITextField = {
        let v = UITextField()
        v.placeholder = "点击弹出键盘并切换到keyword work"
        v.textColor = UIColor.label
        v.layer.borderColor = UIColor.red.cgColor
        v.layer.borderWidth = 1
        return v
    }()
    
    lazy var lbl: UILabel = {
        let v = UILabel()
        return v
    }()

    lazy var btnSend: UIButton = {
        let v = UIButton()
        v.setTitle("Send", for: .normal)
        v.setTitleColor(.red, for: .normal)
        v.addTarget(self, action: #selector(sendInfo(sender:)), for: .touchUpInside)
        return v
    }()
    
    func startListen(){
        do{
            try clientSocket?.connect(toHost: "localHost", onPort: 12344)
        } catch{
            print(error)
        }
    }
}

extension ProcessComSendViewController:GCDAsyncSocketDelegate{
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        sock.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        if let receiveStr = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: ""){
            print(receiveStr)
            lbl.text = (lbl.text ?? "") + receiveStr
        }
        sock.readData(withTimeout: -1, tag: 0)
        sock.write("OK".data(using: .utf8)!, withTimeout: -1, tag: 0)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("socketDidDisconnect")
        print(err)
    }
    
}
