import Foundation
import Aqueduct
import Promises

do {
    let app = try Application<AppDelegate>(processInfo: ProcessInfo.processInfo)
    app.listen()
} catch {
    print(error.localizedDescription)
}
