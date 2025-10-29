# QuizEngine TDD Challenge

Build a multi-platform quiz engine that can answer country-related questions while practicing a disciplined TDD workflow.

## Project Goals

- Deliver both a CLI app and an iOS app with maximum code reuse through clean modular design.
- Provide a chat-style experience where users ask questions and receive answers.
- Support fuzzy input so the app can respond even when questions are phrased differently or contain typos. Consider using an LLM or NLP component.
- Use [restcountries.com](https://restcountries.com) when you need country data (names, capitals, flags, ISO codes, etc.).
- Handle networking failures gracefully and offer an option to retry.
- Make clear, justifiable decisions when requirements are ambiguous.

## Required Question Types

- **Capital lookup:** “What is the capital of Belgium?”
- **Prefix search:** “Which countries start with CH?”
- **ISO alpha-2 code:** “What is the ISO alpha-2 country code for Greece?”
- **Flag lookup:** “What is the flag of Brazil?”

## Repository Layout

- `QuizEngineCore/QuizEngineCore/Domain` — Natural-language interpretation, answer orchestration, and shared models.
- `QuizEngineCore/QuizEngineCore/API` — Remote data integration, HTTP abstractions, and DTO-to-model mapping.
- `QuizEngineCore/QuizEngineiOS` — iOS-facing view model and UI-friendly chat models backed by the core protocols.
- `QuizEngineCore/QuizEngineCoreTests` — Unit tests covering the domain and API layers.
- `QuizEngineCore/QuizEngineiOSTests` — Tests for the chat view model’s async flows, loading, and retry behaviour.

## Architecture at a Glance

<img width="1243" height="789" alt="Screenshot 2025-10-28 at 16 44 46" src="https://github.com/user-attachments/assets/733ca9e9-7fa5-4399-91f8-a5b0c947d8c8" />


| Module | Responsibility | Key Types |
| --- | --- | --- |
| `QuizEngineCore/Domain` | Interprets natural-language questions, coordinates answer generation, and formats responses returned to clients. | `AnswerEngine`, `AnswerProvider`, `CountryQuestionInterpreter`, `CountryQuery`, `CountryAnswer`, `Country` |
| `QuizEngineCore/API` | Integrates with REST Countries while abstracting networking and decoding concerns. | `RemoteCountryLoader`, `CountryLoader`, `HTTPClient`, `URLSessionHTTPClient` |
| `QuizEngineiOS` | Provides an iOS-friendly view model layer that depends only on the core protocol surface. | `ChatViewModel`, `ChatMessage`, `ErrorMessage` |
| `QuizEngineCoreTests` | Drives the domain/API design through TDD and verifies boundary conditions. | `AnswerEngineTests`, `CountryQuestionInterpreterTests`, `RemoteCountryLoaderTests`, `URLSessionHTTPClientTests` |
| `QuizEngineiOSTests` | Confirms chat state transitions, retries, and rendering-friendly formatting. | `ChatViewModelTests` |

### Core Components

- **`AnswerProvider`** — Protocol describing the async answering contract; UI layers and tests depend on it to stay decoupled from concrete engines.
- **`AnswerEngine`** — Implements `AnswerProvider`, interpreting questions, caching remote country data, and producing contextual `CountryAnswer` responses.
- **`CountryQuestionInterpreter`** — Converts fuzzy, free-form user input into structured `CountryQuery` intents using tokenisation and Levenshtein distance thresholds to cope with typos.
- **`CountryLoader` / `RemoteCountryLoader`** — Protocol and remote implementation that fetch and decode REST Countries API payloads into `Country` models, surfacing connectivity vs. data errors distinctly.
- **`URLSessionHTTPClient`** — Minimal `HTTPClient` implementation tailored for async/await GET requests with response validation.
- **`ChatViewModel`** — Maintains an observable chat transcript, loading state, and retry affordances for iOS clients by delegating to any `AnswerProvider`.

## Development Guidelines

- Follow the program’s engineering practices (TDD, small commits, modular design).
- Keep the build free of warnings and ensure the system stays green (all tests passing) on every commit.
- Make frequent, descriptive commits that explain the intent of each change.
- Maintain clean, readable code: consistent formatting, expressive names, minimal reliance on comments.
- Organize modules thoughtfully so the architecture is easy to navigate.
