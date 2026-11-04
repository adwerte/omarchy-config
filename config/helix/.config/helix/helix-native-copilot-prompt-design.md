# Native Copilot Prompt for Helix

## Goal

Fork Helix and add a native command that:

1. Captures the current selections without changing the buffer.
2. Opens a Helix-owned prompt window for free-form Copilot instructions.
3. On confirmation, prefixes those instructions to the selected text and pipes
   the result to the existing PowerShell integration.
4. On cancellation, returns to editing with no side effects.

The intended user flow is:

1. Select code or text.
2. Press `Ctrl-P`.
3. Type an instruction in a Helix UI, such as `Explain this error and propose a
   minimal fix`.
4. Press `Enter` to send the instruction and selection to Copilot, or `Esc` to
   cancel.

This replaces the current keymap macro, which pre-fills Helix command mode:

```toml
[keys.normal]
C-p = "@:pipe-to<space>powershell.exe<space>-NoProfile<space>-ExecutionPolicy<space>Bypass<space>-File<space>%%AppData%%\\helix\\send-selection-to-copilot.ps1<space>-AdditionalPrompt<space>"
```

## Current Integration Contract

The local helper is `send-selection-to-copilot.ps1`.

- Helix supplies selected text on standard input through `:pipe-to`.
- The helper combines optional instructions and the selection as:

  ```text
  <instructions>

  <selection>
  ```

- It invokes `psmux send-keys -t copilot -l -- <message>`, then sends `Enter`.
- `-l` is required: it prevents selected text that resembles key names, such as
  `Enter` or `C-c`, from being interpreted as psmux key events.
- The helper reports a nonzero `psmux` exit code as an error.

The Helix feature should preserve this contract. It should not embed psmux,
Copilot CLI, PowerShell, or Windows-specific logic in Helix. It only needs to
produce one string and execute a configurable shell command with that string on
stdin.

## UX and Scope

### Required behavior

- The command is available in normal and select mode.
- Multiple selections are supported and retain the same byte/text ordering as
  `:pipe-to`.
- The prompt has an explicit label, for example `Copilot prompt: `.
- Prompt text supports spaces, punctuation, paste, and Unicode.
- `Enter` sends; `Esc` and `Ctrl-C` cancel.
- Empty instructions are valid and send only the selection.
- The editor buffer, selection, registers, undo history, and clipboard remain
  unchanged.
- Shell launch failures appear through Helix's normal error/status mechanism.

### Non-goals for the first iteration

- A built-in Copilot client.
- Capturing or rendering Copilot's response inside Helix.
- Per-project authentication/session management.
- Prompt history, templates, completion, or multiline editing.
- A general-purpose user-defined command palette.

### “Window” interpretation

Implement a modal Helix compositor layer, not an OS window and not a terminal
popup. It should visually resemble Helix's picker/prompt UI. A single-line
modal is sufficient for version one; add multiline text editing only if
real-world prompts prove it necessary.

## Proposed Public Configuration

Add an editor command named `copilot_prompt`. Bind it directly:

```toml
[keys.normal]
C-p = "copilot_prompt"

[keys.select]
C-p = "copilot_prompt"
```

Add a dedicated configuration section. Keep it generic so the upstream feature
is useful without any Copilot or psmux dependency:

```toml
[editor.selection-prompt.copilot]
command = [
  "powershell.exe",
  "-NoProfile",
  "-ExecutionPolicy", "Bypass",
  "-File", "C:\\Users\\example\\AppData\\Roaming\\helix\\send-selection-to-copilot.ps1",
  "-AdditionalPrompt",
  "{prompt}",
]
prompt = "Copilot prompt: "
```

The final API name should be discussed upstream. A more neutral
`[editor.selection-prompt]` configuration with a named action may be preferable
to a Copilot-specific upstream setting.

### Recommended command execution model

Do **not** invoke a platform shell with interpolated text. Store command and
arguments separately, replace the `{prompt}` placeholder in the argument list,
and execute the program directly. Pipe the combined message to the child
process's stdin.

This avoids quoting differences across PowerShell, cmd.exe, POSIX shells, and
user-entered punctuation.

## Helix Implementation Plan

The relevant upstream areas are:

| Area | Likely location | Responsibility |
| --- | --- | --- |
| Mappable command registration | `helix-term/src/commands.rs` | Add `copilot_prompt` or a generic selection-prompt command to `static_commands!`. |
| Prompt UI component | `helix-term/src/ui/prompt.rs` | Reuse or extend `Prompt` for label, editing, confirm, and abort handling. |
| Picker/menu behavior reference | `helix-term/src/ui/menu.rs` and picker code | Match compositor lifecycle, modal input consumption, sizing, and theme behavior used by `<space>-f`. |
| Typable command execution | `helix-term/src/commands/typed.rs` | Reuse the existing external command/pipe-to machinery where practical. |
| Configuration schema | `helix-view` configuration types and `helix-term` config loading | Add validated command/argument/prompt settings. |
| Tests | Existing tests adjacent to each changed component | Unit-test message construction, command expansion, and cancellation. |

### Command flow

1. `copilot_prompt(cx: &mut Context)` snapshots the current document selections
   and the configured action. Do this before displaying UI so changing focus or
   state cannot make the callback operate on unrelated selections.
2. It creates a `Prompt` with:
   - prompt label from configuration;
   - no completion provider for v1;
   - `PromptEvent::Abort` callback that only closes the layer;
   - `PromptEvent::Validate` callback that builds the final message.
3. The confirm callback:
   - extracts selected text using the same helper/semantics as `:pipe-to`;
   - creates `<prompt>\n\n<selection>` when prompt text is nonblank, otherwise
     just `<selection>`;
   - starts the configured executable with expanded argument values;
   - writes the final message to stdin;
   - waits asynchronously and surfaces launch/write/exit failures in the
     editor status area.
4. The compositor removes the prompt layer after validation or abortion.

### UI presentation

Start with `Prompt` because it already implements text insertion, paste,
Unicode-aware cursor movement, history support, `Enter`, `Esc`, and `Ctrl-C`.
The normal command line is rendered at the bottom of the editor. To make the
feature feel closer to `<space>-f`, wrap the prompt in a centered `Popup` or a
new small modal component that delegates editing to `Prompt`.

The first implementation should avoid duplicating line-editing behavior. If
`Prompt` cannot be positioned in a popup cleanly, factor its editor/input
handling into a reusable component rather than copying it.

## Design Decisions

### Preserve `:pipe-to` semantics

Use exactly the same selection serialization as `:pipe-to`, including multiple
selection behavior. Do not implement a second selection-to-string conversion;
drift would create confusing differences between the native command and shell
commands.

### Keep transport external

The fork should execute a configured external program only. The existing
PowerShell script remains responsible for the user-specific `psmux` target and
for sending `Enter`. This keeps upstream changes portable and makes the
feature usable with other tools, such as a REPL or formatter service.

### Send one stdin payload

The native command must combine prompt and selections before launching the
external command. Do not pass selection text on the argument list: it risks
command-line size limits, quoting bugs, and exposing contents in process
listings.

### Error handling

- Missing configuration: show an actionable error, for example
  `selection prompt command is not configured`.
- Empty selection: show an error and do not launch a process.
- Process start failure: surface the OS error in Helix.
- stdin write failure or nonzero exit: surface command stderr/exit status using
  the same presentation pattern as existing external commands.
- Cancellation: no error, no process launch.

## Test Plan

### Unit tests

- Selection plus nonblank prompt yields `<prompt>\n\n<selection>`.
- Whitespace-only prompt yields only `<selection>`.
- Unicode prompt and selection preserve their text.
- Multiple selections match `:pipe-to` output.
- `{prompt}` expansion changes only a full placeholder argument.
- No shell parsing occurs for spaces, quotes, or shell metacharacters.
- Missing configuration and empty selection return errors before a child process
  starts.

### Integration tests

Use a helper executable that records stdin and its argument vector.

- Invoke the command, enter a prompt containing spaces and quotes, then confirm.
  Assert exact arguments and stdin.
- Invoke the command and cancel. Assert the helper does not run.
- Invoke with an empty prompt. Assert only selection text reaches stdin.
- Make the helper return nonzero. Assert Helix displays an error.
- Confirm normal/select-mode keybindings both work.

### Manual verification

1. Build the fork on Windows.
2. Configure the command to call `send-selection-to-copilot.ps1`.
3. In a psmux session containing a Copilot CLI target named `copilot`, select
   multi-line text in Helix.
4. Press `Ctrl-P`, enter an instruction with spaces, and submit.
5. Verify the Copilot input contains instructions, a blank line, then the
   exact selected text.
6. Verify `Esc` leaves both the document and Copilot input unchanged.

## Incremental Delivery

1. **Prototype:** add a hard-coded static command that shows a `Prompt` and
   writes its result to a test status message. No process execution.
2. **Selection wiring:** capture selection and verify formatted output with
   tests.
3. **Generic external command:** add configuration and asynchronous stdin
   piping; use a test helper instead of psmux.
4. **Popup polish:** render as a centered modal matching picker styles and
   theme colors.
5. **Local integration:** point configuration at
   `send-selection-to-copilot.ps1`, replace the macro keybind with
   `copilot_prompt`, and validate the live psmux/Copilot flow.
6. **Upstream preparation:** generalize names, document a non-Copilot example,
   split into reviewable commits, and open the fork PR.

## Open Questions

- Should upstream accept a Copilot-named command, or only a generic
  configurable selection prompt?
- Should commands be static-only, or should a typable `:selection-prompt`
  command accept an action name?
- Is a single-line prompt enough for the initial PR, or should the popup use a
  small multiline scratch editor from the start?
- Should prompt history use a dedicated register, and should it be opt-in?
- Which existing `:pipe-to` helper is the best extraction point for selection
  serialization and process execution?
