# Project Context — FILMICA

## Current State

- **Phase**: Pre-development (workflow finalized)
- **Last Updated**: 2026-05-15

## Key Decisions Made

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Framework | Flutter 3.29+ | Cross-platform, single codebase |
| State Management | Riverpod 2.5+ with Hooks | Clean, testable, no boilerplate |
| Backend | Supabase | Auth, DB, Storage — one platform |
| Payments | RevenueCat | Handles subscription complexity |
| CI/CD | Codemagic | Best Flutter CI for iOS (no Mac available) |
| Dev Environment | Windows PC | Primary machine, no Mac |
| Test Device | Physical iPhone | Real-device testing via TestFlight |
| Methodology | /caveman | Incremental, correctness-first development |

## Development Constraints

- No Mac available — all iOS builds via Codemagic
- Windows PC for coding + Android emulator testing
- Physical iPhone for real-device testing

## Active Agents

| Agent | Status | Current Task |
|-------|--------|--------------|
| Claude | Ready | Awaiting M1 kickoff |
| Gemini | Ready | Awaiting theme + UI tasks |
| Codex | Ready | Awaiting Supabase setup |

## Blockers

_None currently._

## Notes

- Update this file at the start of each development session.
- Reference this before starting any new milestone.
