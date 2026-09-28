import Foundation

struct Request: Encodable {
    struct Message: Encodable {
        struct Part: Encodable {
            struct ImageURL: Encodable { let url: String }
            let type: String
            let text: String?
            let image_url: ImageURL?
        }
        let role: String
        let content: [Part]
    }
    let model: String
    let messages: [Message]
}

func dataURL(_ path: String) throws -> String {
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    return "data:image/png;base64,\(data.base64EncodedString())"
}

guard CommandLine.arguments.count >= 3 else {
    fputs("usage: visual-review PROMPT IMAGE...\n", stderr)
    fputs("environment: OPENAI_BASE_URL, OPENAI_API_KEY, OPENAI_MODEL\n", stderr)
    exit(2)
}

let environment = ProcessInfo.processInfo.environment
guard let endpoint = environment["OPENAI_BASE_URL"],
      let key = environment["OPENAI_API_KEY"],
      let model = environment["OPENAI_MODEL"] else {
    fputs("OPENAI_BASE_URL, OPENAI_API_KEY, and OPENAI_MODEL must be set\n", stderr)
    exit(2)
}
let prompt = CommandLine.arguments[1]
let images = Array(CommandLine.arguments.dropFirst(2))
var parts = [Request.Message.Part(type: "text", text: prompt, image_url: nil)]
for path in images {
    parts.append(Request.Message.Part(type: "image_url", text: nil, image_url: .init(url: try dataURL(path))))
}
let payload = Request(model: model, messages: [.init(role: "user", content: parts)])
var request = URLRequest(url: URL(string: endpoint.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + "/chat/completions")!)
request.httpMethod = "POST"
request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
request.setValue("application/json", forHTTPHeaderField: "Content-Type")
request.httpBody = try JSONEncoder().encode(payload)

let semaphore = DispatchSemaphore(value: 0)
var result: Result<Data, Error>!
URLSession.shared.dataTask(with: request) { data, response, error in
    if let error { result = .failure(error) }
    else if let response = response as? HTTPURLResponse, !(200..<300).contains(response.statusCode) {
        let text = String(data: data ?? Data(), encoding: .utf8) ?? ""
        result = .failure(NSError(domain: "visual-review", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: text]))
    } else { result = .success(data ?? Data()) }
    semaphore.signal()
}.resume()
semaphore.wait()
FileHandle.standardOutput.write(try result.get())
