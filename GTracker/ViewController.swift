//
//  ViewController.swift
//  GTracker
//
//  Created by Mikel Valle on 20/10/23.
//
import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var gastosTableView: UITableView!
    @IBOutlet weak var ingresosTableView: UITableView!
    @IBOutlet weak var nombreGastoTextField: UITextField!
    @IBOutlet weak var montoGastoTextField: UITextField!
    @IBOutlet weak var nombreIngresoTextField: UITextField!
    @IBOutlet weak var montoIngresoTextField: UITextField!
    @IBOutlet weak var viewBlue: UIImageView!
    @IBOutlet weak var textField: UITextField!

    var gastos: [Gasto] = []
    var ingresos: [Ingreso] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Gastos y Ingresos"
        gastosTableView.delegate = self
        gastosTableView.dataSource = self
        ingresosTableView.delegate = self
        ingresosTableView.dataSource = self

        gastosTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        ingresosTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        // Asigna el controlador de delegado del UITextField
        textField?.delegate = self
        
        // Agrega un gesto de toque a la vista principal para cerrar el teclado
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        
        gastosTableView.layer.cornerRadius = 10.0
        ingresosTableView.layer.cornerRadius = 10.0
        viewBlue.layer.cornerRadius = 09.0
    }

    @IBAction func agregarGasto(_ sender: UIButton) {
        if let nombre = nombreGastoTextField.text, let monto = Double(montoGastoTextField.text ?? "") {
            gastos.append(Gasto(nombre: nombre, monto: NSDecimalNumber(value: monto)))
            gastosTableView.reloadData()
            nombreGastoTextField.text = ""
            montoGastoTextField.text = ""
        }
    }

    @IBAction func agregarIngreso(_ sender: UIButton) {
        if let nombre = nombreIngresoTextField.text, let monto = Double(montoIngresoTextField.text ?? "") {
            ingresos.append(Ingreso(nombre: nombre, monto: NSDecimalNumber(value: monto)))
            ingresosTableView.reloadData()
            nombreIngresoTextField.text = ""
            montoIngresoTextField.text = ""
        }
    }
       //Lógica tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == gastosTableView {
            return gastos.count
        } else {
            return ingresos.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if tableView == gastosTableView {
            let gasto = gastos[indexPath.row]
            cell.textLabel?.text = "\(gasto.nombre): \(gasto.monto)€"
        } else {
            let ingreso = ingresos[indexPath.row]
            cell.textLabel?.text = "\(ingreso.nombre): \(ingreso.monto)€"
        }
        return cell
    }
    //Fin lógica tableView
    
    // Función para cerrar el teclado
      @objc func dismissKeyboard() {
          view.endEditing(true)
      }
      
    // Implementa el delegado del UITextField para permitir que se cierre el teclado
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
      }
}

struct Gasto {
    var nombre: String
    var monto: NSDecimalNumber
}

struct Ingreso {
    var nombre: String
    var monto: NSDecimalNumber
}
