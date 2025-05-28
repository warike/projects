//
//  CameraViewController.swift
//  scoodit
//
//  Created by Sergio Cardenas on 2/12/16.
//  Copyright © 2016 Sergio Cardenas. All rights reserved.
//

import UIKit
import AVFoundation
import Speech


class ManualViewController: UIViewController, SFSpeechRecognizerDelegate, ScooditHelper,SortHelper
{
    
    
    @IBOutlet weak var voiceRecognitionBtn: UIButton!
    @IBOutlet weak var VisualRecognitionBtn: UIButton!
    @IBOutlet var searchInput : UITextField!
    
    var isSuggestionsDisplayed = false
    var isButtonEnabled = false
    var receivedCloudVisionRequest = false
    var receivedClarifaiRequest = false
    
    
    var userIngredientList: Array<String> = []
    var _isSearching = false
    var IngredientList : [Ingredient]  = LibraryAPI.sharedInstance.getAPIIngredients()
    var searchList : [Ingredient] = [Ingredient]()
    var voiceRecognitionView : UIVoiceRecognitionView?
    var suggestionView : SuggestionView?
    
    var tapGRecogVisual: UITapGestureRecognizer?
    var tapGRecogStart: UITapGestureRecognizer?
    var tapGRecogStop: UITapGestureRecognizer?
    var tapGRecogDissmiss: UITapGestureRecognizer?
    
    var tapDismissKeyboard: UITapGestureRecognizer?
    
    let systemSoundIDStart: SystemSoundID = 1113
    let systemSoundIDStop: SystemSoundID = 1114
    
    var session: AVCaptureSession!
    var input: AVCaptureDeviceInput!
    var output: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var collectionView: UICollectionView!
    var dataSet = [[Ingredient]]()
    var cateroriesDataSet : [String] = []
    var dataProvider : MainCollectionViewDataSource!
    var storedOffsets = [Int: CGFloat]()
    
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    var ingredientSuggestions : [Ingredient] = []
    
    var tableView = UITableView()
    
    let buttonAddIngredients = UIButton()
    let snapButton = UIButton()
    let _activity : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    var _loadingText: UILabel?
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.titleView = self.getScooditTitleView(from: ScooditTitle.addIt)
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad()
    {
        
        
        super.viewDidLoad()
        

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.isScrollEnabled = true
        
        self.tableView.allowsSelection = true
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "selectCell", bundle: Bundle.main), forCellReuseIdentifier: "ElementCell")
        
        let y = (self.collectionView.frame.size.height)
        
        
        let frame = CGRect(x: 0, y: 0, width: 250 , height: (y/2))
        self.suggestionView = SuggestionView(frame: frame)
        self.suggestionView?.okBtn.addTarget(self, action: #selector(ManualViewController.closeOrCancelSuggestions), for: UIControlEvents.touchUpInside)
        
        
        
        
        self.view.backgroundColor = addItBackground
        self.tapDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(ManualViewController.hideKeyboard))
        self.tapDismissKeyboard?.cancelsTouchesInView = false
        self.collectionView.addGestureRecognizer(self.tapDismissKeyboard!)

        self.searchList = self.IngredientList

        self.searchInput.delegate = self
        self.setSearchInputPresentation()

        self.voiceRecognitionBtn.addTarget(self, action: #selector(ManualViewController.OpenVoiceRecognitionModal(sender:)), for: UIControlEvents.touchUpInside)
        
        self.getUpdatedData(data: self.IngredientList)
        self.collectionView.backgroundColor = UIColor.clear
        self.addMenuButton()
        self.addUserProfileButton()
        
        
        self.authRequest()
        self.speechRecognizer?.delegate = self
        self._activity.stopAnimating()
        
    }
    
    func getUpdatedData(data : [Ingredient])
    {
        let iBC = self.getSortedIngredientsByCategories(data)
        self.dataSet = iBC.0
        self.cateroriesDataSet = iBC.1
        self.dataProvider = MainCollectionViewDataSource()
        self.dataProvider.dataSet = self.dataSet as NSArray
        self.dataProvider.sectionDataSet = self.cateroriesDataSet as NSArray
        
        self.collectionView.dataSource = dataProvider
    
    
    }
    
    func setSearchInputPresentation()
    {
        self.searchInput.clearButtonMode = UITextFieldViewMode.always
        self.searchInput.layer.shadowColor = UIColor.lightGray.cgColor
        self.searchInput.layer.shadowOpacity = 1
        self.searchInput.layer.shadowOffset = CGSize.zero
        self.searchInput.layer.shadowRadius = 3
        self.searchInput.addTarget(self, action: #selector(ManualViewController.texthasChanged(textField:)), for: UIControlEvents.editingChanged)
        self.searchInput.layer.borderWidth = 0.4
        self.searchInput.layer.borderColor = UIColor.lightGray.cgColor
    
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool){
        self.removeVoiceRecognitionModal()
        self.closeSuggestionModal()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    
    
}





