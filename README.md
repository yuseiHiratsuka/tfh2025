# tfh2025

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Cloud Functions

This project uses Firebase Cloud Functions to process submitted images using the Gemini Vision API.

### Features

- **processSubmissionImage**: Triggered when a new submission is created in Firestore (`rooms/{roomId}/submissions/{submissionId}`). It analyzes the image using Gemini Pro Vision to identify the drawn object (as a Hiragana word) and updates the submission document with the result.

### Setup

1.  **Navigate to the functions directory:**
    ```bash
    cd functions
    ```

2.  **Install dependencies:**
    ```bash
    npm install
    ```

3.  **Set the Gemini API Key:**
    You must set the `GEMINI_API_KEY` environment variable in Firebase Functions configuration.
    ```bash
    firebase functions:secrets:set GEMINI_API_KEY
    ```
    *Note: You will be prompted to enter the key.*

### Deployment

To deploy the functions to Firebase:

```bash
firebase deploy --only functions
```
