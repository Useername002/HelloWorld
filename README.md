#HelloWorld

HelloWorld is a **multilingual chat application** built with Flutter, Firebase, and translation APIs.  
It enables users to communicate seamlessly across different languages by automatically translating messages into each user’s preferred language.

---

 Features
-  **Authentication** using Firebase Auth  
-  **Language preference settings** stored in Firestore  
-  **Real-time chat** with automatic translation  
-  **Error handling & fallback strategies** for API failures  
-  **Cross-platform support** (Android, iOS, Web)

---

Technology Stack
- **Frontend:** Flutter  
- **Backend:** Firebase Auth + Firestore  
- **Translation APIs:** MyMemory / LibreTranslate / Google unofficial API  
- **Testing Tools:** PowerShell, CMD  

---

 System Architecture
1. User signs in via Firebase Auth  
2. Preferred language stored in Firestore  
3. Sender writes a message → Translation API converts it to recipient’s language  
4. Recipient sees translated message in their chosen language  
5. Fallback: If source = target language, translation is skipped  

---

Getting Started

 Prerequisites
- Install [Flutter](https://docs.flutter.dev/get-started/install)  
- Set up a Firebase project and enable Authentication + Firestore  
- Obtain API endpoint for translation service (MyMemory / LibreTranslate / Google unofficial)

### Installation
Clone the repository:
```bash
git clone https://github.com/Useername002/HelloWorld.git
cd HelloWorld
