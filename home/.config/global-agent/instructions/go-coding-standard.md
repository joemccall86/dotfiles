## 🐹 Go Coding & Commenting Standards for AI Agents

AI agents must adhere to the following conventions to ensure code is idiomatic, maintainable, and easily reviewable by humans.

### 1. The Go Doc Standard

All exported identifiers (functions, types, structs, constants, variables) must have a doc comment.

* **Format:** Comments must be complete sentences starting with the name of the identifier.
* **No Redundancy:** Do not explain the obvious (e.g., `// NewUser creates a new user`). Instead, explain requirements or side effects.
* **Prose style:** Use plain English sentences rather than `@param` or `@return` tags.

### 2. Structs, Fields, and Types

* **Structs:** Document the overall purpose of the struct.
* **Fields:** Document fields that represent units (e.g., `ms`, `bytes`), specific formats (e.g., `JSON`, `base64`), or non-obvious constraints.
* **Types:** For custom types based on primitives, explain the domain-specific reason for the type.

### 3. Branching & Contextual Logic

Documentation is most critical inside logic branches to provide "Big Picture" context.

* **Non-Obvious Branches:** If an `if/else` or `switch` branch handles a rare edge case, race condition, or specific business rule, include an internal comment.
* **The Happy Path:** Keep the "Happy Path" left-aligned. Use comments inside indented blocks to explain **why** an error or alternative path is being taken.
* **Complex Conditionals:** Any `if` statement with more than two logical operands must have a preceding comment translating the logic into a business requirement.

### 4. Concurrency & Constants

* **Select Blocks:** Every `case` in a `select` statement must document its exit strategy (e.g., context cancellation vs. data processing).
* **Constant Groups:** Use a block-level comment for `const (...)` groups to explain the category of values.

---

### 📝 Comprehensive Example

```go
// RateLimitConfig defines the throttling behavior for the gateway.
// It is used by the middleware to reject excessive traffic.
type RateLimitConfig struct {
	// RequestLimit is the maximum requests allowed per window.
	RequestLimit int
	// WindowSize defines the duration of the rate limit bucket.
	WindowSize time.Duration
}

// CheckLimit evaluates if a request should be throttled.
// It returns true if the request is allowed, false otherwise.
func (rl *RateLimitConfig) CheckLimit(currentCount int) bool {
	// We allow a 10% "grace burst" for legacy clients identified by 
	// specific metadata, to prevent breaking v1 integrations.
	if currentCount > rl.RequestLimit && isLegacyClient() {
		return currentCount <= int(float64(rl.RequestLimit)*1.1)
	}

	return currentCount <= rl.RequestLimit
}

// ProcessStream handles incoming data packets from the buffer.
func ProcessStream(ctx context.Context, data <-chan []byte) error {
	for {
		select {
		case <-ctx.Done():
			// Prioritize context cancellation to ensure clean 
			// shutdown of long-running worker goroutines.
			return ctx.Err()
		case buf := <-data:
			if len(buf) == 0 {
				// Empty buffers signify a heartbeat or keep-alive signal;
				// we skip processing but continue the loop.
				continue
			}
			process(buf)
		}
	}
}

```

---

### 🤖 Agent Guardrails

* **No Dead Code:** Never commit commented-out code.
* **Minimalist internal docs:** Only document unexported (private) functions if the logic is complex; prioritize making the code self-documenting.
* **Traceability:** If a branch handles a specific bug fix, include the ticket ID (e.g., `// Fixes #102: prevent nil pointer on empty payload`).

