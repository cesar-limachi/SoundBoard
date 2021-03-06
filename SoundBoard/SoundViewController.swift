//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by Cesar Limachi on 5/24/22.
//  Copyright © 2022 empresa. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    //MARK: - Variables.
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var tiempo:Timer = Timer()
    
    //MARK: - Outlets.
    
    @IBOutlet weak var grabarButton: UIButton!
    
    @IBOutlet weak var reproducitButton: UIButton!
    
    @IBOutlet weak var nombreTextField: UITextField!
    
    @IBOutlet weak var agregarButton: UIButton!
    
    @IBOutlet weak var TimeTranscurred: UILabel!
    
    //MARK: - Actions
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            //detener la grabacion
            grabarAudio?.stop()
            //detiene el tiempo
            tiempo.invalidate()
            //cambiar texto del boton grabar
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducitButton.isEnabled = true
            agregarButton.isEnabled = true
        } else{
            //empezar a grabar
            grabarAudio?.record()
            //tiempo en ejecucion
            tiempo = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(duracion), userInfo: nil, repeats: true)
            //cambiar el texto del boton grabar a detener
            grabarButton.setTitle("DETENER", for: .normal)
            reproducitButton.isEnabled = false
            
        }
        
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        }catch{}
    }
    
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        //nuevo atributo duracion
        grabacion.duracionAudio = TimeTranscurred.text
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
        
    }
    
    
    @IBAction func low(_ sender: Any) {
        reproducirAudio?.stop()
        reproducirAudio?.volume += 1
        reproducirAudio?.prepareToPlay()
        reproducirAudio?.play()
    }
    
    
    @IBAction func up(_ sender: Any) {
        reproducirAudio?.stop()
        reproducirAudio?.volume -= 1
        reproducirAudio?.prepareToPlay()
        reproducirAudio?.play()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducitButton.isEnabled = false
        agregarButton.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    func configurarGrabacion(){
        do {
            //creando sesion de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            //creando direccion para el archivo de audio
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            //impresion de ruta donde se guardan los archivos
            print("*****************")
            print(audioURL!)
            print("*****************")
            
            //crear opciones para el grabador de audio
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            //crear el objeto de grabacion de audio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
            
             
        } catch let error as NSError {
            print(error)
        }
    }
    
    //MARK: - Funcion Tiempo
    
    @objc func duracion() -> Void{
        let tiempoDuracion = Int(grabarAudio!.currentTime)
        let horas = tiempoDuracion / 3600
        let minutos = (tiempoDuracion % 3600) / 60
        let segundos = (tiempoDuracion % 3600) % 60
        var tiempo = ""
        tiempo += String(format: "%02d", horas)
        tiempo += ":"
        tiempo += String(format: "%02d", minutos)
        tiempo += ":"
        tiempo += String(format: "%02d", segundos)
        print(tiempo)
        TimeTranscurred.text = tiempo
    }
    
}
