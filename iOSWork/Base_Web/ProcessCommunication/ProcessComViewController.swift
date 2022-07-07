//
//  ProcessComViewController.swift
//  iOSWork
//
//  Created by Stan Hu on 2022/7/6.
//

import UIKit
import CocoaAsyncSocket
class ProcessComViewController: UIViewController {

    var serverSocket:GCDAsyncSocket?
    var arrClient:[GCDAsyncSocket]?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "APP跨进程通信"
        view.backgroundColor = UIColor.white
        arrClient = [GCDAsyncSocket]()
        serverSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        serverSocket?.autoDisconnectOnClosedReadStream = true
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
        
        // Do any additional setup after loading the view.
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

    func startListen(){
        do{
            try serverSocket?.accept(onPort: 12345)
        } catch{
            print(error)
        }
    }
}

extension ProcessComViewController:GCDAsyncSocketDelegate{
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        lbl.text = "连接成功"
        arrClient?.append(newSocket)
        newSocket.readData(withTimeout: -1, tag: 100)
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
