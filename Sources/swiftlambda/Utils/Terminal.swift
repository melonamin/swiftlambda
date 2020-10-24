import Foundation

func outputReplaceLastLine(with text: String) {
    print("\u{1B}[1A\u{1B}[K\(text)")
}
