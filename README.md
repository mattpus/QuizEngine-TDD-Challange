# QuizEngine TDD Challenge

Create a multi-platform app that can answer basic questions about a country.

## Instructions
- Follow the development processes and practices taught in the program (e.g., follow TDD, small commits, modular design, set up a CI/CD pipeline, etc.).
- Create two separate apps - a CLI app and an iOS app - reusing code as much as possible with a clean and modular design.
- The apps should have a chat-like UI, where the user asks a question, and the app replies.
- The apps should be able to reply to these four types of questions:
  - What is the capital of [Country]?
  - For example, What is the capital of Belgium?
  - Which countries start with [Letters]?
  - For example, Which countries start with CH?
  - What is the ISO alpha-2 country code for [Country]?
  - For example, What is the ISO alpha-2 country code for Greece?
  - What is the flag of [Country]?
  - For example, What is the flag of Brazil?
- The user should not need to type the question perfectly. The app should be able to respond to these type of questions in any way it can be phrased (or even misspelled!). Tip: Use an LLM or Natural Language interpreter to interpret/reply to the question.
- If needed, use https://restcountries.com as the data source (for country names, flags, etc.).
- Handle errors - if the network request fails, show an error with the option to retry.
- If you're unsure about a specific requirement, use your judgment and make a decision on your own (you should be able to justify the decision!).

## Guidelines
- Aim to commit your changes every time you add/alter the behavior of your system or refactor your code.
- Aim for descriptive commit messages that clarify the intent of your contribution, which will help other developers understand your train of thought and purpose of changes.
- The system should always be in a green state, meaning that in each commit all tests should be passing.
- The project should build without warnings.
- The code should be carefully organized and easy to read (e.g. indentation must be consistent).
- Aim to write self-documenting code by providing context and detail when naming your components, avoiding explanations in comments.

---

## Solution Overview



---<img width="1048" height="925" alt="Screenshot 2025-10-29 at 19 01 49" src="https://github.com/user-attachments/assets/f13762a6-96f3-48af-b295-0bf855db0c56" />


## Workspace Structure

The top-level `QuizEngine.xcworkspace` stitches together three Xcode projects so everything can be built and tested from one place:

| Project | Products | Notes |
| --- | --- | --- |
| `QuizEngineCore/QuizEngineCore.xcodeproj` | `QuizEngineCore.framework`, `QuizEngineiOS.framework`, `QuizEngineCLI.framework`, plus unit-test bundles for each module | Holds the domain, API integration, shared models, and cross-platform presentation logic. |
| `QuiziOSApp/QuiziOSApp.xcodeproj` | `QuiziOSApp.app`, `QuiziOSAppUITests.xctest` | SwiftUI chat client for iOS. UITests attach via launch arguments and environment to deterministic stubs. |
| `QuizCLIApp/QuizCLIApp.xcodeproj` | `QuizCLIApp` (command-line tool) | macOS CLI shell that shares `AnswerEngine` through `QuizEngineCLI`. |

### Target Map

- **Frameworks**: `QuizEngineCore`, `QuizEngineiOS`, `QuizEngineCLI`.
- **Apps**: `QuiziOSApp` (iOS), `QuizCLIApp` (macOS CLI executable).
- **Tests**:
  - `QuizEngineCoreTests`
  - `QuizEngineiOSTests`
  - `QuizEngineCLITests`
  - `QuiziOSAppUITests`

The shared `CI.xctestplan` (and derived “AllUnitTests” scheme) can execute every test bundle in one click;

---

## Module Responsibilities

| Module | Path | Responsibility | Representative Types |
| --- | --- | --- | --- |
| **Domain** | `QuizEngineCore/QuizEngineCore/Domain` | Parse natural-language questions, cache countries, produce `CountryAnswer` responses. | `AnswerEngine`, `CountryQuestionInterpreter`, `CountryQuery`, `CountryAnswer`, `Country` |
| **API** | `QuizEngineCore/QuizEngineCore/API` | Fetch and decode REST Countries data; abstract URL loading. | `RemoteCountryLoader`, `CountryLoader`, `HTTPClient`, `URLSessionHTTPClient` |
| **iOS Presentation** | `QuizEngineCore/QuizEngineiOS` | Observable chat state, message models, error handling for UI layers. | `ChatViewModel`, `ChatMessage`, `ErrorMessage` |
| **CLI Presentation** | `QuizEngineCore/QuizEngineCLI` | Terminal I/O abstraction, command parsing, ANSI styling. | `QuizEngineCLIApp`, `ChatIO`, `StandardIO`, `Command`, `TerminalOutputStyling` |

---

## Core Components & Flow

1. **User Input** enters via either the CLI prompt or the SwiftUI chat text field.
2. **ChatViewModel / QuizEngineCLIApp** forward the raw question to an `AnswerProvider`.
3. **AnswerEngine** interprets the question (`CountryQuestionInterpreter`), loads country data through `CountryLoader`, caches results, and returns a formatted `CountryAnswer`.
4. **Presentation Layers** render responses (chat bubbles, ANSI console colours) and expose retry/error funcionality.
5. **Networking** is handled with `URLSessionHTTPClient`, which powers `RemoteCountryLoader` to call `https://restcountries.com/v3.1/all?fields=…`.

Error cases (connectivity or parsing failures) surface as `.dataUnavailable`, triggering UI alerts in iOS and warning banners in the CLI. A retry button/command replays the last successful question when `ChatViewModel.canRetry` is `true`.

---

## Application Targets

### QuiziOSApp (iOS)

- **Composition**: `CompositionRoot` wires `AnswerEngine` with `RemoteCountryLoader`.
- **UI**: `ContentView` renders a scrollable chat transcript (`ChatMessageBubble`), input field, retry toolbar button, and progress state. Errors present as alerts with retry/cancel actions.
- **Deterministic UITests**: `UITestSupport` swaps the engine during UITest launches. The UITest suite (`QuiziOSAppUITests.swift`) covers:
  - Capital, flag, ISO code, and prefix questions.
  - Retry behaviour after a simulated failure.
  - Error alert presentation.
  Launch arguments: `UITesting`; environment payload: `UITEST_RESPONSES` (JSON array of stubbed answers).

### QuizCLIApp (macOS Command Line)

- **Entry Point**: `QuizCLIApp/main.swift` boots `QuizEngineCLIApp` with `StandardIO` and the shared engine.
- **Features**:
  - Greeting banner with coloured ANSI styling.
  - Command parsing (`exit`, `quit`, `retry`).
  - Graceful handling of EOF and network failures.
  - Image URLs are printed as supplemental info when available.
- **Running**:
  - From Xcode: select `QuizCLIApp` scheme and press **Run** (console displays in the debugger).
  - From terminal: run `./run-cli.sh` to build into `./build` and launch with the proper framework search path (script logs detailed output to `/tmp/quizcli-build.log`).

---

## Testing Strategy

- **Unit Tests** (`QuizEngineCoreTests`, `QuizEngineiOSTests`, `QuizEngineCLITests`) validate interpreters, loaders, view models, and CLI loop. Spies/mocks implement the protocols above to assert behaviour.
- **iOS UITests** (`QuiziOSAppUITests`) drive the chat UI end-to-end using stubbed responses and accessibility identifiers (`question-input`, `retry-button`).
- **Test Plans**:
  - `CI.xctestplan`: Aggregates every test bundle. Configure destinations inside the plan (macOS + iOS Simulator) to ensure iOS tests find `QuizEngineiOS.framework`.
  - Schemes such as `CI` reference this plan to run all suites with one command (`⌘U` or `xcodebuild … -scheme CI -testPlan CI test`).
