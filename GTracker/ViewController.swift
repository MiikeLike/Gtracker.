//
//  ViewController.swift
//  GTracker
//
//  Created by Mikel Valle on 20/10/23.
//
import UIKit
import Charts
import Foundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var montoTextField: UITextField!
    @IBOutlet weak var viewBlue: UIImageView!
    @IBOutlet weak var pieChartView: PieChartView!
    var registrosFinancieros: [registroFinanciero] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Asigna el controlador de delegado del UITextField
        nombreTextField.delegate = self
        montoTextField.delegate = self
        
        // Agrega un gesto de toque a la vista principal para cerrar el teclado
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        tableView.layer.cornerRadius = 10.0
        viewBlue.layer.cornerRadius = 10.0
        
        setupPieChart()
        
        //Carga de registros financieros almacenados
        if let savedRegistros = loadRegistrosFinancieros() {
                    registrosFinancieros = savedRegistros
                }
    }
    
    
    
    // Creación de gráfico para mostrar el total de ingresos y gastos
    
    func setupPieChart() {
        // Calcular el total de ingresos y gastos
        let totalIngresos = registrosFinancieros.filter { $0.tipo == .ingreso }.reduce(0) { $0 + $1.monto.doubleValue }
        let totalGastos = registrosFinancieros.filter { $0.tipo == .gasto }.reduce(0) { $0 + $1.monto.doubleValue }
        
        // Crear los datos para el gráfico de pastel
        let ingreso = PieChartDataEntry(value: totalIngresos, label: "Ingresos")
        let gasto = PieChartDataEntry(value: totalGastos, label: "Gastos")
        let dataSet = PieChartDataSet(entries: [ingreso, gasto], label: "Resumen Financiero")
        dataSet.colors = [NSUIColor.green, NSUIColor.red] // Colores para ingresos y gastos

        let data = PieChartData(dataSet: dataSet)
        
        // Configurar el gráfico de pastel
        pieChartView.data = data
        pieChartView.drawEntryLabelsEnabled = false // No mostrar etiquetas en las secciones
        pieChartView.centerText = "Resumen"
        pieChartView.holeRadiusPercent = 0.4 // Tamaño del agujero en el centro (opcional)
        pieChartView.transparentCircleRadiusPercent = 0.4 // Tamaño del círculo transparente alrededor del gráfico (opcional)
    }
    
    // Creación de función para que el textField de Dinero solo entren datos tipo String
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == montoTextField {
            // Crear un conjunto de caracteres permitidos que incluya números y el signo negativo
            var allowedCharacters = CharacterSet.decimalDigits
            allowedCharacters.insert(charactersIn: "-")
            
            // Verificar si los caracteres introducidos están en el conjunto permitido
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    
    @IBAction func agregarRegistroFinanciero(_ sender: UIButton) {
        if let nombre = nombreTextField.text, let monto = Double(montoTextField.text ?? "") {
                let tipo: tipoRegistro = monto >= 0 ? .ingreso : .gasto
                let nuevoRegistro = registroFinanciero(monto: monto, nombre: nombre, tipo: tipo)
                registrosFinancieros.append(nuevoRegistro)
            // Actualiza el gráfico después de agregar un nuevo registro
            setupPieChart()
            tableView.reloadData()
            nombreTextField.text = ""
            montoTextField.text = ""
            // Guardar los registros financieros actualizados
            saveRegistrosFinancieros()
        }
    }
    // Función para guardar registros financieros en UserDefaults
    func saveRegistrosFinancieros() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(registrosFinancieros) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "registrosFinancieros")
        }
    }

    // Función para cargar registros financieros desde UserDefaults
    func loadRegistrosFinancieros() -> [registroFinanciero]? {
        if let registrosData = UserDefaults.standard.data(forKey: "registrosFinancieros") {
            let decoder = JSONDecoder()
            if let registros = try? decoder.decode([registroFinanciero].self, from: registrosData) {
                return registros
            }
        }
        return nil
    }


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registrosFinancieros.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let registro = registrosFinancieros[indexPath.row]
        
        cell.textLabel?.text = "\(registro.nombre): \(registro.tipo == .ingreso ? "+" : "-")\(registro.monto)€"
        cell.textLabel?.textColor = registro.tipo == .ingreso ? .green : .red
        
        return cell
    }
    
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


struct registroFinanciero: Codable {
    var nombre: String
    var monto: NSDecimalNumber
    var tipo: tipoRegistro

    enum CodingKeys: String, CodingKey {
        case nombre
        case monto
        case tipo
    }
    init(monto: Double, nombre: String, tipo: tipoRegistro) {
        self.nombre = nombre
        self.monto = NSDecimalNumber(decimal: Decimal(monto))
        self.tipo = tipo
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nombre = try container.decode(String.self, forKey: .nombre)
        monto = try NSDecimalNumber(decimal:  container.decode(Decimal.self, forKey: .monto))
        tipo = try container.decode(tipoRegistro.self, forKey: .tipo)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nombre, forKey: .nombre)
        try container.encode(monto.decimalValue, forKey: .monto)
        try container.encode(tipo, forKey: .tipo)
    }
}

enum tipoRegistro: String, Codable {
    case ingreso
    case gasto

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        switch rawValue {
        case "ingreso":
            self = .ingreso
        case "gasto":
            self = .gasto
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid tipoRegistro value: \(rawValue)"
            )
        }
    }
}








