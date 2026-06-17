# Accessible Story Chatbot

A modern, fully accessible Flutter application that generates interactive stories using Google's cutting-edge Gemini AI. Designed specifically with accessibility in mind, this app allows users to create, read, manage, and export AI-generated stories effortlessly.

## 🚀 Features

* **AI-Powered Narrative Engine:** Powered by the `gemini-2.5-flash` model, allowing users to guide and shape the story's direction interactively.
* **WCAG Accessibility Compliance:** Built from the ground up for visually impaired users. Features full TalkBack integration, custom semantic labels, a high-contrast dark theme, and large accessible tap targets.
* **Cloud Sync:** Uses Firebase Firestore to automatically save your stories in the cloud using anonymous authentication. 
* **Export Anywhere:** Seamlessly export your stories to `.txt` or `.pdf` directly to your phone's public Downloads folder.
* **Premium Dark Mode:** A sleek Material 3 design featuring deep slate and vibrant cyan accents.

## 🛠️ Tech Stack

* **Frontend:** Flutter & Dart
* **Backend:** Firebase Authentication & Cloud Firestore
* **AI:** Google Generative AI (Gemini)

## 🔑 Setup Instructions

To run this project locally, you will need to add your own Gemini API key:
1. Create a `.env` file in the root directory.
2. Add your key like this: `GEMINI_API_KEY=your_api_key_here`
*(Note: The `.env` file is excluded from git via `.gitignore` to protect your secrets).*
