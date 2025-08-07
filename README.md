[![CI](https://github.com/SiamS99/nebulix/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/SiamS99/nebulix/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/SiamS99/nebulix/branch/main/graph/badge.svg?token=5BL48C9HEZ)](https://codecov.io/gh/SiamS99/nebulix)
# Nebulix

Nebulix is a next-generation, fully customizable DevOps platform designed to streamline software development, deployment, and operations. Built for flexibility, scalability, and team collaboration, Nebulix empowers organizations to automate workflows, manage projects, and accelerate delivery.

## Features

- 🚀 Modern, modular architecture
- 🛠️ Customizable pipelines and automation
- 📦 Project, issue, and sprint management
- 🔒 Role-based access control
- 📊 Real-time analytics and dashboards
- 🔗 Integrations with GitHub, GitLab, and more
- 📝 Webhook support for event-driven workflows
- 🌐 RESTful API for extensibility
- 🏗️ Containerized deployment (Docker)

## Getting Started

### Prerequisites
- Node.js (v18+ recommended)
- npm or yarn
- Docker & Docker Compose (for full stack)
- SQL Server 2022 (or compatible)

### Quick Start

1. Clone the repository:
   ```sh
   git clone https://github.com/SiamS99/nebulix.git
   cd nebulix
   ```
2. Install backend dependencies:
   ```sh
   cd backend
   npm install
   ```
3. Configure your environment:
   - Copy `.env.example` to `.env` and update values as needed.
4. Start the backend server:
   ```sh
   npm run dev
   ```
5. (Optional) Start with Docker Compose:
   ```sh
   docker-compose up --build
   ```

## Project Structure

```
nebulix/
  backend/         # Express + TypeScript API
    src/
      classes/     # Data models
      routes/      # API routes
    ...
  database/        # SQL scripts and configs
  docker-compose.yml
  README.md
```

## Contributing

Contributions are welcome! Please open issues or pull requests for features, bug fixes, or documentation improvements.

## License

This project is licensed under the CC0-1.0 License. See [LICENSE](LICENSE) for details.
