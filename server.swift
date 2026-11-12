import Vapor

let app = Application()
defer {
    app.shutdown()
}

app.get("/payload", { req -> EventLoopFuture<Void> in
    let filePath = "Payload.swift"
    return req.file(filePath).map { file in
        return file.makeOutputStream()
    }.map { outputStream in
        // Set the appropriate content type for the payload file
        req.response.headers[HTTP.HeaderField.contentDisposition.rawValue] = "attachment; filename=Payload.swift"
        req.response.headers[HTTP.HeaderField.contentType.rawValue] = "application/octet-stream"

        // Write the payload file to the output stream
        let error = try? file.makeOutputStream().write(to: outputStream)
        if let error = error {
            print("Error writing payload file: \(error)")
            return req.eventLoop.newSucceededFuture(result: ())
        }
        return req.eventLoop.newSucceededFuture(result: ())
    }
}).listen(on: port)