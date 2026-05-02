# <a href="https://www.linkedin.com/in/rokkside/">Orok Ironbar</a>'s IT and Cybersecurity Project Portfolio 🔐

I'm passionate about cybersecurity and love tackling complex challenges through hands-on projects. From vulnerability management to threat detection, these projects allow me to dive deep into the ever-evolving landscape of cybersecurity. Please feel free to check them out and see the work I’ve put into enhancing security operations and processes!


## ⚠️ Vulnerability Management Projects

- **[Vulnerability Management Program Implementation](https://github.com/Rokkside/Vulnerability-Management-Program-Implementation)**
- **[Programmatic Vulnerability Remediations (PowerShell and BASH)](https://github.com/Rokkside/programmatic-vulnerability-remediations/tree/main)**

## 🚨 Threat Hunting and Security Operations

- **[Threat Hunting Scenario (Tor Browser Usage)](https://github.com/Rokkside/threat-hunting-scenario-tor)**

## 🔐 Windows 11 STIG Automation Lab

This project demonstrates the implementation, troubleshooting, and validation of Windows 11 STIG controls using PowerShell in a hands-on lab environment.

### 🎯 Objective
- Automate STIG compliance using PowerShell
- Identify failed controls using Tenable vulnerability scans
- Remediate and validate security configurations
- Understand real-world policy conflicts (GPO vs Local vs Legacy)

---

## 🧪 Lab Workflow

1. Run Tenable scan → Identify FAILED STIG control  
2. Implement remediation via PowerShell  
3. Validate locally (`auditpol`, registry, etc.)  
4. Re-run scan → Confirm PASS  

---

## 📌 Implemented Controls

### 🔹 WN11-AU-000050 – Audit Process Creation

- Enables Detailed Tracking → Process Creation (Success)
- Uses `auditpol` for configuration
- Generates Event ID 4688 for process execution visibility

⚠️ **Troubleshooting Insight:**
- Initial configuration failed due to legacy audit policy overriding advanced audit settings
- Resolved by enabling:
  ```text
  SCENoApplyLegacyAuditPolicy = 1

<hr/>

## 🤳 Connect With Me

<p align="left">
  <a href="https://www.youtube.com/c/YOUR_CHANNEL" target="_blank">
    <img src="https://cdn.jsdelivr.net/npm/simple-icons@v3/icons/youtube.svg" width="30px" />
  </a>
  <a href="https://twitter.com/YOUR_HANDLE" target="_blank">
    <img src="https://cdn.jsdelivr.net/npm/simple-icons@v3/icons/twitter.svg" width="30px" />
  </a>
  <a href="https://www.linkedin.com/in/rokkside/" target="_blank">
    <img src="https://cdn.jsdelivr.net/npm/simple-icons@v3/icons/linkedin.svg" width="30px" />
  </a>
  <a href="https://www.instagram.com/YOUR_HANDLE" target="_blank">
    <img src="https://cdn.jsdelivr.net/npm/simple-icons@v3/icons/instagram.svg" width="30px" />
  </a>
</p>

## 🛠️ Technical Skills & Tools

### ☁️ Cloud & DevOps
![AWS](https://img.shields.io/badge/Amazon%20AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-5835CC?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-0db7ed?style=for-the-badge&logo=docker&logoColor=white)

### 💻 Programming & Systems
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

### 🔐 Cybersecurity & Detection Engineering
![Microsoft Defender](https://img.shields.io/badge/Microsoft%20Defender-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![Microsoft Sentinel](https://img.shields.io/badge/Microsoft%20Sentinel-5E5E5E?style=for-the-badge&logo=microsoft-azure&logoColor=white)
![SIEM](https://img.shields.io/badge/SIEM-4B0082?style=for-the-badge)
![MITRE ATT&CK](https://img.shields.io/badge/MITRE%20ATT%26CK-FF0000?style=for-the-badge)
![KQL](https://img.shields.io/badge/KQL-005571?style=for-the-badge)

### 🧰 Tools & Platforms
![Git](https://img.shields.io/badge/Git-181717?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)
![Wireshark](https://img.shields.io/badge/Wireshark-1679A7?style=for-the-badge&logo=wireshark&logoColor=white)
![Trello](https://img.shields.io/badge/Trello-026AA7?style=for-the-badge&logo=Trello&logoColor=white)
