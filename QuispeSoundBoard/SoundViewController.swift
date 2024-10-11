//
//  SoundViewController.swift
//  QuispeSoundBoard
//
//  Created by Ribeyro Guzman on 9/10/24.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {
    
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var timeSound: UILabel!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var lineTimeSound: UIProgressView!
    
    
    var  grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL: URL?
    var timer: Timer?
    var recordingTime: TimeInterval = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
    }
    
    func configurarGrabacion(){
        do {
                    let session = AVAudioSession.sharedInstance()
                    try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
                    try session.overrideOutputAudioPort(.speaker)
                    try session.setActive(true)

                    let basePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    let pathComponents = [basePath, "audio.m4a"]
                    audioURL = NSURL.fileURL(withPathComponents: pathComponents)

                    var settings: [String: AnyObject] = [:]
                    settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
                    settings[AVSampleRateKey] = 44100.0 as AnyObject?
                    settings[AVNumberOfChannelsKey] = 2 as AnyObject?

                    grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
                    grabarAudio!.prepareToRecord()

                } catch let error as NSError {
                    print(error)
                }
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
                    grabarAudio?.stop()
                    grabarButton.setTitle("Grabar", for: .normal)
                    reproducirButton.isEnabled = true
                    agregarButton.isEnabled = true
                    timer?.invalidate()  // Detener el timer
                } else {
                    grabarAudio?.record()
                    grabarButton.setTitle("DETENER", for: .normal)
                    reproducirButton.isEnabled = false
                    agregarButton.isEnabled = false
                    recordingTime = 0
                    lineTimeSound.progress = 0

                    // Iniciar el timer para actualizar el tiempo de grabación
                    timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(actualizarTiempoGrabacion), userInfo: nil, repeats: true)
                }
        
        }
    
    @objc func actualizarTiempoGrabacion() {
            if let currentTime = grabarAudio?.currentTime {
                timeSound.text = String(format: "%.1f segundos", currentTime)
                recordingTime = currentTime

                // Actualizar la barra de progreso
                let maxDuration: TimeInterval = 60  // Suponiendo que la grabación no exceda los 60 segundos
                lineTimeSound.progress = Float(currentTime / maxDuration)
            }
        }
        

    
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
                    try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
                    reproducirAudio!.play()
                } catch {
                    print("Error al reproducir el audio.")
                }
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let contex = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let grabacion = Grabacion(context: contex)
                grabacion.nombre = nombreTextField.text
                grabacion.audio = NSData(contentsOf: audioURL!)! as Data
                grabacion.duracion = recordingTime  // Guardar la duración de la grabación
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                navigationController!.popViewController(animated: true)
    }
}
