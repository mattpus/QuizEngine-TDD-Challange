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

## Architecture at a Glance

<img width="1243" height="789" alt="Screenshot 2025-10-28 at 16 44 46" src="https://github.com/user-attachments/assets/733ca9e9-7fa5-4399-91f8-a5b0c947d8c8" />


| Module | Responsibility | Key Types |
| --- | --- | --- |
| `CountryInfoCore` | Shared business logic. Interprets natural language questions, loads country metadata, and formats answers. | `CountryQuestionInterpreter`, `CountryAnswerEngine`, `RemoteCountryLoader`, `RemoteCountryRepository`, `URLSessionHTTPClient`, `Country` |
| `CountryInfoCLICore` | Reusable shell for terminal UX. Handles prompts, command parsing, and chat display with ANSI styling. | `CountryChatApp`, `ChatIO` |
| `CountryInfoCLI` | Wires the CLI core to the remote data source so the executable can run end-to-end. | `CountryInfoCLIApp` (entry point) |
| `CountryInfoUICore` | UI-agnostic state management for SwiftUI or UIKit layers. Manages chat transcript, loading state, and retry flow. | `CountryChatViewModel`, `CountryChatMessage` |

### Core Components

- **`CountryQuestionInterpreter`** — Converts fuzzy, free-form user input into structured `CountryQuery` intents using tokenisation and Levenshtein distance thresholds to cope with typos.
- **`CountryAnswerEngine`** — Orchestrates the flow: interprets the question, lazily loads and caches country data via `CountryDataLoader`, and produces contextual `CountryAnswer` responses (including lists, ISO codes, flags, and friendly fallbacks).
- **`RemoteCountryLoader`** — Fetches and decodes REST Countries API payloads into `Country` models, surfacing connectivity vs. data errors distinctly.
- **`RemoteCountryRepository`** — Bridges the transport-agnostic core to the loader, satisfying the `CountryDataLoader` protocol.
- **`URLSessionHTTPClient`** — Minimal `HTTPClient` implementation tailored for async/await GET requests with response validation.
- **`CountryChatApp`** — Implements a conversational loop for the terminal with commands such as `exit` and `retry`, piping answers and errors through stylised output helpers.
- **`CountryChatViewModel`** — Maintains an observable chat transcript, loading state, and error messaging for UI clients, leveraging the same `CountryAnswering` protocol for consistency across platforms.

## Development Guidelines

- Follow the program’s engineering practices (TDD, small commits, modular design, CI/CD, etc.).
- Keep the build free of warnings and ensure the system stays green (all tests passing) on every commit.
- Make frequent, descriptive commits that explain the intent of each change.
- Maintain clean, readable code: consistent formatting, expressive names, minimal reliance on comments.
- Organize modules thoughtfully so the architecture is easy to navigate.
