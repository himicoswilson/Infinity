import Foundation

extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    func truncate(to length: Int, addEllipsis: Bool = true) -> String {
        if self.count > length {
            let truncated = self.prefix(length)
            return addEllipsis ? truncated + "..." : String(truncated)
        }
        return self
    }
}