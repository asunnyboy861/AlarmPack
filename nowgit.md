# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | AlarmPack |
| **Git URL** | git@github.com:asunnyboy861/AlarmPack.git |
| **Repo URL** | https://github.com/asunnyboy861/AlarmPack |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/AlarmPack/ | ✅ Active |
| Support | https://asunnyboy861.github.io/AlarmPack/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/AlarmPack/privacy.html | ✅ Active |
| Terms of Use | https://asunnyboy861.github.io/AlarmPack/terms.html | ✅ Active |

## Repository Structure

```
AlarmPack/
├── AlarmPack/                    # iOS App Source Code
│   ├── AlarmPack.xcodeproj/      # Xcode Project
│   ├── AlarmPack/                # Swift Source Files
│   │   ├── Views/
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── ViewModels/
│   │   └── Extensions/
│   └── ...
├── docs/                          # Policy Pages (GitHub Pages source)
│   ├── index.html
│   ├── support.html
│   ├── privacy.html
│   └── terms.html
├── .github/workflows/
│   └── deploy.yml
├── us.md
├── keytext.md
├── capabilities.md
├── icon.md
├── price.md
└── nowgit.md
```
