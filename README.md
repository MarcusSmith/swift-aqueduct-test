# swift-aqueduct-test
An experiment with Swift NIO & Codable, to try to replicate [Aqueduct](https://github.com/stablekernel/aqueduct) in Swift, not intended for actual production use

Build from Xcode & Test with curl command:

```
curl http://localhost:8080 -H "Content-Type: application/json" -d '{"name": "test", "id": 1}'
```
