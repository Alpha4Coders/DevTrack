# 🚀 DevTrack

**Track your developer journey. Prove your consistency. Connect learning to real work.**

DevTrack is a full-stack application that helps developers track their learning progress, document their projects, and build a provable record of consistent growth with AI-powered insights.

---

## 🎯 What DevTrack Solves

| Problem | Solution |
|---------|----------|
| **Scattered Learning** | Centralized tracking of courses, tutorials, and skills |
| **Invisible Progress** | Visual proof of consistent daily/weekly activity |
| **Disconnected Skills** | Links what you learn → what you build |
| **No Portfolio Proof** | AI-analyzed project progress reports |

---

## ✨ Core Features

### 📚 Learning Tracker
- Log daily learning sessions with start/end times
- Track what you learned each day
- Tag skills and technologies
- Mood tracking for productivity insights
- Edit and delete log entries

### 🛠️ Project Tracker
- Document projects with GitHub repository links
- **AI-powered project analysis** using Groq (Llama 3.3)
- Automatic language detection from repos
- Progress tracking based on actual code, not just commits
- Support for **private repositories** via OAuth

### 📊 Dashboard
- **Animated pill-shaped navbar** with Framer Motion
- Quick stats overview (streaks, commits, skills)
- **Weekly activity chart** with gradient bars
- **30-day streak grid** visualization
- Recent activity timeline

### ℹ️ System Info Page
- Explains how streak counter works
- Documents progress tracking methodology
- Learning entry guidelines
- Statistics calculation reference

### 🤖 AI Chat Assistant
- Context-aware coding help
- Access to your project and learning data
- Powered by Groq API with rate limiting
- Code review and suggestions

### 🐙 GitHub Integration
- **Private repo access** via user OAuth tokens
- Fetch commits, PRs, issues, and languages
- Analyze repository structure and key files
- Commit pattern analysis (features/fixes/docs/tests)
- Auto-extract technologies from package.json, etc.

---

## 🏗️ Tech Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | React 18, Vite, React Router, Framer Motion, GSAP |
| **Backend** | Node.js, Express.js |
| **Database** | Firebase Firestore |
| **Authentication** | [Clerk](https://clerk.com) (GitHub OAuth) |
| **AI** | Groq API (Llama 3.3 70B) |
| **GitHub API** | Octokit |
| **Styling** | Tailwind CSS |

---

## 📁 Project Structure

```
DevTrack/
├── client/                     # React Frontend (Vite)
│   ├── src/
│   │   ├── components/         # Reusable UI components
│   │   │   ├── ui/             # Button, Card, Badge, etc.
│   │   │   └── layout/         # AppLayout, Navbar
│   │   ├── pages/              # Page components
│   │   │   ├── Dashboard.jsx
│   │   │   ├── Learning.jsx
│   │   │   ├── Projects.jsx
│   │   │   ├── Chat.jsx
│   │   │   ├── SystemInfo.jsx
│   │   │   └── Landing.jsx
│   │   ├── services/           # API service (Axios)
│   │   ├── App.jsx
│   │   └── main.jsx
│   └── package.json
│
├── server/                     # Node.js Backend
│   ├── src/
│   │   ├── config/             # Firebase config
│   │   ├── controllers/        # Route controllers
│   │   ├── services/           # Business logic
│   │   ├── routes/             # Express routes
│   │   ├── middleware/         # Auth, validation, errors
│   │   └── app.js
│   └── package.json
│
├── .gitignore
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites
- Node.js (v18 or higher)
- npm or yarn
- Firebase project with Firestore
- Clerk account with GitHub OAuth enabled
- Groq API key

### Installation

```bash
# Clone the repository
git clone https://github.com/Vortex-16/DevTrack.git
cd DevTrack

# Install server dependencies
cd server
npm install

# Install client dependencies
cd ../client
npm install
```

### Environment Setup

**Server `.env`:**
```env
PORT=5000
NODE_ENV=development

# Firebase
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxx@your-project.iam.gserviceaccount.com

# Clerk Authentication
CLERK_PUBLISHABLE_KEY=pk_test_xxxxx
CLERK_SECRET_KEY=sk_test_xxxxx

# GitHub API (PAT for public repos fallback)
GITHUB_PAT=ghp_xxxxxxxxxxxx

# AI - Groq
GROQ_API_KEY=gsk_xxxxxxxxxxxx
```

**Client `.env`:**
```env
VITE_API_URL=http://localhost:5000/api
VITE_CLERK_PUBLISHABLE_KEY=pk_test_xxxxx
```

### Running the Application

```bash
# Start the backend server (from server directory)
npm run dev

# Start the frontend (from client directory)
npm run dev
```

---

## 🗺️ Roadmap

- [x] Initial project setup
- [x] Clerk authentication (GitHub OAuth)
- [x] Firebase Firestore integration
- [x] Learning entry CRUD
- [x] Project tracking CRUD
- [x] GitHub API integration
- [x] Private repository support
- [x] AI-powered project analysis
- [x] AI Chat assistant
- [x] Dashboard with stats
- [x] Beautiful landing page with animations
- [x] Streak tracking & contribution heatmaps
- [x] System info documentation page
- [ ] Export/share progress reports
- [ ] Push notifications
- [ ] Mobile app

---

## 👥 Team

Built by the Vortex-16 team.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <strong>Built with ❤️ to help developers prove their growth</strong>
</p>
