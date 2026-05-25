# Dynamic Form Renderer for iOS (SwiftUI)

A production‑ready SwiftUI app that renders fully dynamic forms from JSON. Supports **TEXT** (plain/number, max length, regex), **DROPDOWN** (single/multi‑select), and **CHECKBOX** fields with theming, inline validation, rich clickable links, and keyboard navigation.

---

## Overall Approach & Architecture

The app follows **MVVM** with a clear separation of concerns:

- **Models**: `FormDefinition`, `FormField` (polymorphic enum), and field‑specific configs (`TextFormField`, `DropdownFormField`, `CheckboxFormField`).  
  Custom `Decodable` conformance on `FormField` uses a `type` discriminator to decode different field types into a single array.
- **ViewModel**: `FormViewModel` holds field values (`[String: Any]`), validation errors, submit state, and focus tracking. It validates on every value change and on submit.
- **Views**: `FormView` assembles field‑specific views (`TextFieldView`, `DropdownFieldView`, `CheckboxFieldView`) with the applied theme.  
  A custom `MultiSelectSheet` handles multiple selections.
- **Validation**: `FieldValidator` static methods centralise all rules (required, max length, number parsing, regex).
- **Theming**: Theme colors are decoded from JSON and converted to SwiftUI `Color` via a hex initialiser. A default theme provides resilience.
- **Focus Management**: The `FormViewModel` collects IDs of all text fields. A keyboard toolbar with “Next” / “Done” buttons cycles through them using SwiftUI’s `@FocusState`, bridged via a custom `bindFocus` modifier.

The form is rendered dynamically by iterating over the sorted `fields` array and switching on the `FormField` enum.

---

## Product Decisions (Edge Cases & Trade‑offs)

### 1. Handling Missing or Malformed JSON Data
**Decision**: Every optional field in the JSON (e.g., `theme`, `placeholder`, `regex`, `metadata`) is decoded with `decodeIfPresent` and falls back to a safe default (`Theme.default`, empty string, `nil`, etc.). If a field’s `type` discriminator is missing or invalid, the entire form fails to decode (with a clear error) rather than silently dropping the field.

**Why**: Missing design tokens should not crash the app, but a malformed field definition likely indicates a server error that should be surfaced to the developer. Dropping fields silently could lead to confusing behaviour for end users.

### 2. Conflict Between `max_length` and `regex`
**Decision**: Both constraints are applied sequentially. First `max_length` is checked; if it passes, then `regex` is evaluated. If a regex requires at least 10 characters but `max_length = 5`, the user will always see the regex error (since the value can never satisfy the regex). No attempt is made to “merge” or resolve the contradiction.

**Why**: It is the JSON provider’s responsibility to supply consistent constraints. Attempting to automatically adjust one rule would introduce hidden complexity and could break business logic. Displaying the regex error (or the custom `error_message`) makes the inconsistency visible to the user, prompting a fix in the backend definition.

### 3. Validation Timing – Real‑time vs. On‑Submit
**Decision**: Validation runs **on every change** to any field value (via a `sink` on `$fieldValues`). Error messages appear instantly below each field. The submit button re‑validates all fields and prevents submission if any error exists.

**Why**: Real‑time validation gives immediate feedback, improving UX. Because validation is cheap (no network calls), it does not impact performance. Showing errors only on submit (a common alternative) can frustrate users who have to guess what went wrong.

---

## What Would I Improve With More Time?

- **Support for more field types**: Date pickers, radio groups, file attachments, sliders, etc.
- **Conditional / dependent fields**: Show/hide fields based on previous answers (e.g., show “Other” text input when a dropdown option “Other” is selected). This would require extending the JSON schema with `depends_on` rules.
- **Persistent drafts**: Automatically save partial form data to `UserDefaults` or Core Data and restore when the app reopens.
- **Better error recovery**: When `regex` and `max_length` conflict, show a friendly message like “The server configuration is inconsistent – please contact support.”
- **Accessibility**: Add dynamic type support, VoiceOver labels, and proper focus order.
- **Unit tests for focus navigation and sheet presentation**: The current tests cover decoding and validation; more time would allow mocking of UI interactions.

---

## What I Got Stuck On & How I Worked Through It

### Problem 1: Initialising `textFieldIds` Before Capturing `self`
**Stuck**: The `FormViewModel` init compiled with an error: *“Variable 'self.textFieldIds' used before being initialized”*.  
**Cause**: The `sink` closure captured `self` (weakly) before the stored property `textFieldIds` was assigned. Even though the closure didn’t use `textFieldIds`, the compiler required all stored properties to be fully initialised before any `self` capture.

**Solution**: Moved the assignment of `textFieldIds` **above** the `sink` subscription. All stored properties are now initialised before the closure is created, satisfying the compiler.

### Problem 2: Making Checkbox Links Tappable
**Stuck**: Using a standard `Toggle` with `AttributedString` containing `.link` attributes did not make the links interactive. The `Toggle`’s tap gesture consumed all touches.  
**Solution**: Replaced `Toggle` with a custom button that acts as a checkbox (`iOSCheckboxToggleStyle`). The button’s label is an `AttributedText` view that supports link interaction. This required manually managing the `isChecked` state but gave full control over tap areas.

### Problem 3: Synchronising `@FocusState` with ViewModel
**Stuck**: `@FocusState` is a view‑only property; it cannot be stored in a `ViewModel`. However, the keyboard toolbar needed to know the current focus to enable “Next”.  
**Solution**: Created a `bindFocus` view extension that observes both the `@FocusState` binding and a published `String?` in the `ViewModel`, keeping them in sync via `onChange` modifiers. The toolbar buttons update the published value, which then updates the focus binding.
