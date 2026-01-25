# BudgetBuddy

Personal finance app for students with local SQLite storage and an AI chat coach powered by Groq.

## Run

- Install deps: `flutter pub get`
- Provide your API key at runtime (not committed):
	- Example: `flutter run --dart-define=GROQ_API_KEY=your_key_here`
	- For builds: `flutter build apk --dart-define=GROQ_API_KEY=your_key_here`

## Structure

- `lib/models`: data models (transactions, etc.)
- `lib/services`: SQLite helper, Groq coach client
- `lib/providers`: state (transactions, chat coach)
- `lib/screens`: UI pages (home, chat)
- `lib/widgets`: shared UI components

## Notes

- All financial data stays on-device in SQLite.
- Chat coach sends recent transaction summaries to Groq; keep your key out of source control.
