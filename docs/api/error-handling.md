# PulseOps API Error Handling

The PulseOps microservice standardizes error responses using structured JSON formats across all HTTP error conditions:

## Standard Error Schema
```json
{
  "error": "Error Type",
  "message": "Human-readable description of the error",
  "status_code": 404,
  "timestamp": "2026-11-02T20:20:00Z"
}
```

## Error Codes
- `400 Bad Request`: Malformed payload or invalid query parameters.
- `404 Not Found`: The requested API route does not exist.
- `405 Method Not Allowed`: Invalid HTTP verb utilized on endpoint.
- `500 Internal Server Error`: Unhandled server exception (triggers SEV-1 alert).
- `503 Service Unavailable`: Subsystem readiness failure.
