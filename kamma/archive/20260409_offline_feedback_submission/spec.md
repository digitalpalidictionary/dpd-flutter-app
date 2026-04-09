# Offline Feedback Submission

## Thread Type
Feature

## Overview
Replace the current browser-only feedback link with a native in-app feedback form that collects the same user-visible information inside the app, then hands off in one of two ways:
- when online, open the real Google Form in the browser with all fields prefilled
- when offline, open a prefilled email draft so the user can send it later

This thread no longer includes direct POST submission to Google Forms, local queueing, or automatic background retries. Those approaches were investigated and rejected because the Google Form rejects direct anonymous app-side submission with `401` responses.

## Current Behaviour
- `lib/widgets/feedback_footer.dart` renders the footer CTA and currently opens a browser-based Google Form link when tapped.
- `lib/utils/app_feedback_url.dart` already builds a prefilled Google Form URL containing metadata fields.
- The user currently leaves the app immediately and types the actual feedback in Google Forms.
- Device metadata is already available through `device_info_plus` and `package_info_plus` in `app_feedback_url.dart`.
- The app already uses `SharedPreferences` for local app state such as history and settings.

## What It Should Do

### In-App Form
- Tapping "Having a problem? Report it here" opens a native in-app form instead of launching the browser immediately.
- The form should collect these user-visible fields:
  - Name: required text field
  - Email address: required text field
  - What's the issue?: required choice field with these values:
    - App crash or freeze
    - Display problem
    - Feature request
    - General feedback
    - Other
  - Description: required multi-line text field for what happened or what the user wants
  - What would make the app better for you?: optional multi-line text field
- Platform, device, OS version, app version, and database version should be auto-filled silently and not shown in the form UI.
- The form must validate required fields before handoff.

### Persistence Rules
- Name should always be remembered and prefilled on future opens.
- Email address should always be remembered and prefilled on future opens.
- A partially completed unsent draft should remain filled on future opens until it is successfully handed off.
- After successful handoff to either:
  - the online Google Form flow, or
  - the offline email draft flow,
  the transient draft fields should be cleared.
- Clearing the transient draft must not erase the remembered name and email values.

### Online Handoff
- If the device is online when the user taps Send:
  - build a prefilled Google Form URL
  - include all visible fields plus the silent metadata fields
  - open the real Google Form in the browser
- The app does not submit the Google Form automatically.
- The user must still complete the final send action in the browser.
- In this thread, "launched successfully" means the browser or external app was opened successfully. It does not mean the user submitted the Google Form.
- Once the browser handoff is launched successfully, dismiss the form and clear only the transient draft.

### Offline Handoff
- If the device is offline when the user taps Send:
  - build a prefilled email draft instead of failing
  - include the same full payload as the online flow
  - format the body as headings and answers for readability
- The email recipient must be `digitalpalidictionary@gmail.com`.
- The draft should include:
  - name
  - email
  - issue type
  - description
  - improvement
  - platform
  - device
  - OS version
  - app version
  - database version
- Once the email draft is launched successfully, dismiss the form and clear only the transient draft.
- In this thread, "launched successfully" means the mail app or external app was opened successfully. It does not mean the user actually sent the email.
- The user is responsible for sending the email later.

## Google Form Field Mapping
Use these exact Google Form entry IDs:

| Field | Entry ID | Notes |
| --- | --- | --- |
| Name | `entry.485428648` | required in app |
| Email address | `entry.1607701011` | required |
| What's the issue? | `entry.1579150913` | required |
| Description | `entry.811247772` | required |
| What would make it better? | `entry.1696159737` | optional |
| Platform | `entry.405390413` | auto-filled |
| Device | `entry.671095698` | auto-filled |
| OS version | `entry.1162202610` | auto-filled |
| App version | `entry.1433863141` | auto-filled |
| Database version | `entry.100565099` | auto-filled |

Allowed values for `What's the issue?`:
- `App crash or freeze`
- `Display problem`
- `Feature request`
- `General feedback`
- `Other`

## Email Draft Format
- Recipient must be `digitalpalidictionary@gmail.com`.
- Subject should clearly indicate app feedback, for example:
  `DPD App Feedback: <issue type>`
- Body should use plain headings and answers, for example:
  - `Name:`
  - `Email:`
  - `Issue Type:`
  - `Description:`
  - `Improvement:`
  - `Platform:`
  - `Device:`
  - `OS Version:`
  - `App Version:`
  - `Database Version:`
- The issue type text in the email body should use the same verbatim values listed in this spec.

## Relevant Files And Systems
- `lib/widgets/feedback_footer.dart`: current footer CTA and tap handler
- `lib/utils/app_feedback_url.dart`: existing metadata collection helpers and current Google Form URL builder
- `lib/providers/history_provider.dart`: example `SharedPreferences` JSON persistence pattern already used in the app
- `lib/main.dart`: current app startup and `SharedPreferences` bootstrap
- `lib/providers/database_update_provider.dart`: current source of the local DB version shown in the footer flow
- `lib/screens/search_screen.dart`: includes `FeedbackFooter`
- `lib/screens/root_screen.dart`: includes `FeedbackFooter`
- `lib/screens/entry_screen.dart`: includes `FeedbackFooter`
- `lib/widgets/feedback_section.dart`: existing `mailto:` usage pattern elsewhere in the app

Likely new or modified implementation areas:
- `lib/widgets/feedback_form_sheet.dart`: in-app feedback UI
- `lib/services/feedback_draft_service.dart`: remembered contact info and transient draft persistence
- `lib/utils/app_feedback_url.dart`: shared metadata gathering and prefilled Google Form builder
- a new helper for building the email draft URI/body

## Constraints
- Do not introduce new HTTP or connectivity packages. Reuse `Connectivity().checkConnectivity()` from the existing `connectivity_plus` dependency for the one-shot online/offline decision.
- Keep this thread limited to the app-problem feedback flow only.
- Do not implement direct Google Forms POST submission in this thread.
- Do not implement local queueing, reconnect listeners, or background retries in this thread.
- Reuse the app's existing theme and UI patterns rather than introducing a new visual style.
- Do not implement offline support for the other footer links such as correction or missing-word flows.

## How We Will Know It Is Done
- Tapping the footer feedback CTA opens an in-app form instead of opening the browser immediately.
- Required-field validation prevents handoff with incomplete feedback.
- Name and email are remembered across form opens.
- Unsent drafts are restored when reopening the form.
- Online submission opens the real Google Form with the entered values and metadata prefilled.
- Offline submission opens a prefilled email draft with the same payload formatted as headings and answers.
- After successful browser or email handoff, the transient draft is cleared while remembered name and email remain.

## What Is Not Included
- Direct API submission to Google Forms
- Offline queueing and automatic retry
- Offline support for other Google Form-based flows
- A UI for viewing, editing, or deleting prior drafts beyond reopening the same form
- Changes to the Google Form itself
