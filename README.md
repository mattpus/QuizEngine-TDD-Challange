# QuizEngine-TDD-Challange

Create a multi-platform app that can answer basic questions about a country.

Instructions
Follow the development processes and practices taught in the program (e.g., follow TDD, small commits, modular design, set up a CI/CD pipeline, etc.).
Create two separate apps - a CLI app and an iOS app - reusing code as much as possible with a clean and modular design.
The apps should have a chat-like UI, where the user asks a question, and the app replies.
The apps should be able to reply to these four types of questions:
What is the capital of [Country]?
For example, What is the capital of Belgium?
Which countries start with [Letters]?
For example, Which countries start with CH?
What is the ISO alpha-2 country code for [Country]?
For example, What is the ISO alpha-2 country code for Greece?
What is the flag of [Country]?
For example, What is the flag of Brazil?
The user should not need to type the question perfectly. The app should be able to respond to these type of questions in any way it can be phrased (or even misspelled!). Tip: Use an LLM or Natural Language interpreter to interpret/reply to the question.
If needed, use https://restcountries.com as the data source (for country names, flags, etc.).
Handle errors - if the network request fails, show an error with the option to retry.
If you're unsure about a specific requirement, use your judgment and make a decision on your own (you should be able to justify the decision!).
Guidelines
Aim to commit your changes every time you add/alter the behavior of your system or refactor your code.
Aim for descriptive commit messages that clarify the intent of your contribution, which will help other developers understand your train of thought and purpose of changes.
The system should always be in a green state, meaning that in each commit all tests should be passing.
The project should build without warnings.
The code should be carefully organized and easy to read (e.g. indentation must be consistent).
Aim to write self-documenting code by providing context and detail when naming your components, avoiding explanations in comments.
