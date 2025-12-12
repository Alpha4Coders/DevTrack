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
- Quick stats overview (projects, logs, streaks)
- Recent activity timeline
- Backend health status monitoring

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
│   │   │   └── layout/         # AppLayout, Sidebar
│   │   ├── pages/              # Page components
│   │   │   ├── Dashboard.jsx
│   │   │   ├── Learning.jsx
│   │   │   ├── Projects.jsx
│   │   │   ├── Chat.jsx
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
│   │   │   ├── authController.js
│   │   │   ├── geminiController.js
│   │   │   ├── githubController.js
│   │   │   ├── logsController.js
│   │   │   └── projectController.js
│   │   ├── services/           # Business logic
│   │   │   ├── githubService.js    # GitHub API integration
│   │   │   ├── groqService.js      # AI analysis
│   │   │   └── geminiService.js    # Gemini fallback
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

# Optional - Gemini fallback
GEMINI_API_KEY=your_gemini_key
```

**Client `.env`:**
```env
VITE_API_URL=http://localhost:5000/api
VITE_CLERK_PUBLISHABLE_KEY=pk_test_xxxxx
```

### Clerk Setup for Private Repos

1. Go to your Clerk Dashboard → User & Authentication → Social Connections
2. Enable GitHub and add the `repo` scope for private repository access
3. Users will need to reconnect their GitHub account to grant access

### Running the Application

```bash
# Start the backend server (from server directory)
npm run dev

# Start the frontend (from client directory)
npm run dev
```

---

## 📋 API Endpoints

### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/auth/sync` | Sync user from Clerk to Firestore |
| `GET` | `/api/auth/me` | Get current user profile |

### Learning Logs
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/logs` | Get all learning entries |
| `POST` | `/api/logs` | Create new entry |
| `PUT` | `/api/logs/:id` | Update entry |
| `DELETE` | `/api/logs/:id` | Delete entry |
| `GET` | `/api/logs/stats` | Get learning statistics |

### Projects
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/projects` | Get all projects |
| `POST` | `/api/projects` | Create project (auto-analyzes if GitHub URL) |
| `PUT` | `/api/projects/:id` | Update project |
| `DELETE` | `/api/projects/:id` | Delete project |
| `GET` | `/api/projects/stats` | Get project statistics |

### GitHub
| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/github/activity` | Get user's GitHub activity |
| `GET` | `/api/github/commits` | Get recent commits |
| `GET` | `/api/github/repos` | Get user repositories |
| `GET` | `/api/github/repo/:owner/:repo` | Analyze specific repo |

### AI Chat
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/gemini/chat` | Chat with AI assistant |
| `POST` | `/api/gemini/analyze-project` | Analyze project with AI |

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
- [ ] Streak tracking & contribution heatmaps
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
