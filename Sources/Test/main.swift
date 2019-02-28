import Foundation
import Aqueduct

do {
    // TODO: Argument parsing code might make more sense here instead of inside the Application
    let app = try Application<AppDelegate>(processInfo: ProcessInfo.processInfo)
    app.listen()
} catch {
    print(error.localizedDescription)
}
