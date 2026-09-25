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

guard CommandLine.arguments.count >= 5 else {
    fputs("usage: visual-review ENDPOINT API_KEY PROMPT IMAGE...\n", stderr)
    exit(2)
}

let endpoint = CommandLine.arguments[1]
let key = CommandLine.arguments[2]
let prompt = CommandLine.arguments[3]
let images = Array(CommandLine.arguments.dropFirst(4))
var parts = [Request.Message.Part(type: "text", text: prompt, image_url: nil)]
for path in images {
    parts.append(Request.Message.Part(type: "image_url", text: nil, image_url: .init(url: try dataURL(path))))
}
let payload = Request(model: "gpt-5.6-luna", messages: [.init(role: "user", content: parts)])
var request = URLRequest(url: URL(string: endpoint + "/chat/completions")!)
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
