# Rate-Limiting Project

> Production-ready Node.js & Express rate limiter featuring IP+username brute-force protection, custom security auditing, and an automated PowerShell load-testing suite.

---

## ✨ Features

* **Multi-Tier Protection**: Global API protection combined with strict, granular route-level limits.
* **Smart Key Generation**: Tracks requests combining both `IP` and `username` to prevent a single bad actor from locking out shared network users.
* **Security Auditing & Alerts**: Custom handlers capturing brute-force attempts with real-time console logging.
* **Internal Whitelisting**: Built-in bypass tokens for internal tools, monitoring, or automated testing suites.
* **Automated Load Testing**: Includes a ready-to-run PowerShell script to verify status codes, execution latency, and rate-limit headers (`RateLimit-*`).

---

## 🛠️ Tech Stack

* **Backend**: Node.js, Express.js
* **Security**: `express-rate-limit`
* **Testing / Automation**: PowerShell (Load Testing)

---

## 📦 Getting Started

### 1. Installation

Clone the repository and install the required dependencies:

```bash
git clone https://github.com/Youssef-Abdelhakim-Web-2025//Rate-limiting-project.git
cd Rate-limiting-project
npm install express express-rate-limit

```

### 2. Running the Server

Start the Express server locally:

```bash
node server.js

```

> The server will start running at `http://localhost:3000`.

### 3. Running the Load Test

Open **PowerShell**, update your script parameters if needed, and execute the test file to verify rate-limiting behavior (`401 Unauthorized` leading to `429 Too Many Requests`):

```powershell
.\test-ratelimit.ps1

```

---

## 🛡️ Rate Limit Configurations

| Limiter Type | Scope | Window / Max | Key Behavior |
| --- | --- | --- | --- |
| **Global Limiter** | `/api/` | 15 Mins / 100 reqs | Tracks client IP address |
| **Login Limiter** | `/api/login` | 1 Min / 3 failures | Tracks `IP + Username` combo with custom security logging |

---

## 📄 License

Distributed under the [MIT License](https://www.google.com/search?q=LICENSE). Feel free to use, modify, and scale for your own projects.
