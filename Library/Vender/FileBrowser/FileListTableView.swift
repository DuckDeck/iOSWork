//
//  FlieListTableView.swift
//  FileBrowser
//
//  Created by Roy Marmelstein on 14/02/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation
import UIKit
extension FileListViewController: UITableViewDataSource, UITableViewDelegate {
    
    //MARK: UITableViewDataSource, UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive {
            return 1
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredFiles.count
        }
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FileCell"
        var cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = reuseCell
        }
        cell.selectionStyle = .blue
        let selectedFile = fileForIndexPath(indexPath)
        cell.textLabel?.text = selectedFile.displayName
        cell.imageView?.image = selectedFile.type.image()
        
        if let size = FileCalManager.caledDirSize.object(forKey: selectedFile.filePath.path as NSString){
            cell.detailTextLabel?.text = size as String
        } else {
            let progress = UIActivityIndicatorView()
            progress.startAnimating()
            cell.contentView.addSubview(progress)
            progress.snp.makeConstraints { make in
                make.right.equalTo(-20)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(16)
            }
            progress.tag = 88
            
            FileCalManager.calSizeQuene.addOperation(CalFileSizeTask(filePah: selectedFile.filePath, completed: { fileSize, err in
                cell.contentView.viewWithTag(88)?.removeFromSuperview()
                cell.detailTextLabel?.text = fileSize
            }))
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFile = fileForIndexPath(indexPath)
        searchController.isActive = false
        if selectedFile.isDirectory {
            FileCalManager.calSizeQuene.cancelAllOperations()
            tableView.visibleCells.forEach { c in
                c.contentView.viewWithTag(88)?.removeFromSuperview()
            }
            let fileListViewController = FileListViewController(initialPath: selectedFile.filePath)
            fileListViewController.didSelectFile = didSelectFile
            self.navigationController?.pushViewController(fileListViewController, animated: true)
        }
        else {
            if let didSelectFile = didSelectFile {
                self.dismiss()
                didSelectFile(selectedFile)
            }
            else {
                let filePreview = previewManager.previewViewControllerForFile(selectedFile, fromNavigation: true)
                self.navigationController?.pushViewController(filePreview, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive {
            return nil
        }
        if sections[section].count > 0 {
            return collation.sectionTitles[section]
        }
        else {
            return nil
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive {
            return nil
        }
        return collation.sectionIndexTitles
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if searchController.isActive {
            return 0
        }
        return collation.section(forSectionIndexTitle: index)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            let selectedFile = fileForIndexPath(indexPath)
            selectedFile.delete()
            
            prepareData()
            tableView.reloadSections([indexPath.section], with: UITableView.RowAnimation.automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return allowEditing
    }
    
    
}
