import UIKit

class Gasto: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!  // Reemplaza con tu propio UITextField
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

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
