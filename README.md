# Pixelka Watch ⌚️

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Wear OS](https://img.shields.io/badge/Platform-Wear_OS-4285F4?logo=google-play&logoColor=white)
![N8N](https://img.shields.io/badge/Backend-N8N-FF6B6B)

[ 🇬🇧 English ](#-english) | [ 🇷🇺 Русский ](#-russian)

---

<a name="english"></a>
## 🇬🇧 English

**Pixelka Watch** is a lightweight, standalone version of the [Pixelka AI](https://github.com/ultraswaglol/pixelka-ai) ecosystem, specifically designed for **Wear OS** smartwatches. It focuses on speed and voice interaction to provide AI assistance directly from your wrist.

### ✨ Key Features

*   **⌚️ Wear OS Optimized:** UI adapted for round screens using `wear` package.
*   **🗣️ Voice-First:** Instant voice input (STT) and concise text responses.
*   **⚡️ Lightweight:** Stripped of heavy features (payments, referral system) for maximum performance on low-power devices.
*   **☁️ Unified Backend:** Uses the same powerful N8N workflows as the main mobile app.
*   **💾 Local History:** Saves your watch conversations locally using Hive.

### 🛠️ Tech Stack

*   **Framework:** Flutter (Wear OS).
*   **State Management:** Provider.
*   **Database:** Hive (NoSQL).
*   **Audio:** `flutter_sound` for recording.

### 🚀 Getting Started

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/ultraswaglol/pixelka-watch.git
    ```
2.  **Setup Environment:**
    Create a `.env` file based on `.env.example` with your N8N webhook URLs.
3.  **Run:**
    Connect your watch via ADB or use an emulator.
    ```bash
    flutter run
    ```

---

<a name="russian"></a>
## 🇷🇺 Русский

**Pixelka Watch** — это облегченная версия экосистемы [Pixelka AI](https://github.com/ultraswaglol/pixelka-ai), специально разработанная для умных часов на **Wear OS**. Приложение сфокусировано на скорости и голосовом управлении.

### ✨ Возможности

*   **⌚️ Оптимизация под часы:** Интерфейс адаптирован под круглые экраны (используется пакет `wear`).
*   **🗣️ Голосовой интерфейс:** Мгновенная отправка голосовых и получение текстовых ответов.
*   **⚡️ Легковесность:** Из приложения вырезаны "тяжелые" функции (оплата, настройки, рефералка) для экономии заряда и памяти часов.
*   **☁️ Единый бэкенд:** Использует те же мощные сценарии N8N, что и основное приложение.
*   **💾 Локальная история:** История диалогов сохраняется прямо на часах (Hive).

### 🛠️ Стек технологий

*   **Фреймворк:** Flutter (адаптация под Wear OS).
*   **Управление состоянием:** Provider.
*   **База данных:** Hive.
*   **Аудио:** `flutter_sound` для записи голоса.

### 🚀 Запуск

1.  **Клонируйте репозиторий.**
2.  **Настройте `.env`:** Укажите вебхуки N8N (см. `.env.example`).
3.  **Запуск:**
    Подключите часы по ADB или запустите эмулятор Wear OS.
    ```bash
    flutter run
    ```
