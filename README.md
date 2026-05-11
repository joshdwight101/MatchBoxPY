# **MatchBoxPY v1.0.0**

"From zero to native-speed Python production — instantly."

**Lead Architect:** Joshua Dwight

**Platform:** Native C\# (.NET 8\) & PowerShell 5.1 Hybrid Options

**GitHub:** [joshdwight101](https://github.com/joshdwight101)

## **📌 Executive Summary**

**MatchBoxPY** is an enterprise-grade orchestration suite designed to eliminate Python environment chaos.

Rather than wrestling with IDE configurations, PATH variables, and command-line packaging arguments, MatchBoxPY provides a single-pane-of-glass interface to completely manage Python environments, virtual spaces, pip dependencies, and native execution compilers.

## **🚀 Core Features & Capabilities**

### **1\. Advanced Workspace & Execution Engine**

* **UNC Pathing Support:** Native support for mapping drives or direct network shares (\\\\Server\\Share\\Project).  
* **Modern Windows Explorer:** Utilizes the native Windows 10/11 File Picker API for fast access to Quick Links and OneDrive, replacing outdated folder pickers.  
* **Rapid Prototyping Matrix:** Compare standard CPython execution times directly against PyPy JIT compilation without modifying source code.  
* **Right-Click Automation:** Context menus on the project tree allow instant script execution and executable generation.

### **2\. Complete Virtual Environment (Venv) Control**

* **Auto-Discovery:** Automatically scans loaded projects for existing .venv or custom-named virtual environments.  
* **1-Click Initialization:** Bind the internal console and script execution strictly to isolated workspaces to prevent system dependency pollution.  
* **Create & Nuke:** Safely generate new environments or permanently delete corrupted ones directly from the UI.  
* **Right-Click Context Menu:** Right-click any environment in the list to instantly Activate or Delete it.

### **3\. The Visual Pip Database Manager**

* **Optimized Layout:** Compact, side-by-side action buttons guarantee visibility across the entire dependency matrix regardless of window size.  
* **Live Dependency Tracking:** View all packages mapped to the currently active virtual environment.  
* **Single & Bulk Operations:** Uninstall, Force-Reinstall, or Update packages individually via robust right-click context menus.  
* **Persistent Package Database:** Save your favorite libraries (e.g., numpy, pandas, requests) to a portable database (\~/.matchboxpy/saved\_packages.txt) to bulk-install across different computers in one click.  
* **Requirements.txt Sync:** 1-click Freeze or Install directly from project requirement files.

### **4\. Multi-Compiler Orchestration Engine**

* **Visual PyInstaller Targeting:** Generates native .exe files without touching the CLI. Easily toggle \--onefile, \--noconsole, and \--debug modes.  
* **AOT Compiler Ready:** Built-in hooks to pass Python code through AOT (Ahead-of-Time) engines like Nuitka and Cython.  
* **Hidden Imports Management:** Visual text box to inject complex dependency chains dynamically into the build process.

## **🛠️ Administrator Interface Guide**

### **Tab 1: Workspace & Prototyping**

**Primary Use:** Navigating code and testing execution.

* Use the **Path Bar** to manually type UNC network paths or click **Browse** to launch the Modern Folder Picker.  
* **Right-click** any .py file to instantly run it or send it to the Build Engine.

### **Tab 2: Environment Manager**

**Primary Use:** Isolating project dependencies.

* To create a venv: Type the desired name in the box (defaults to .venv) and click **Create**. The system will automatically build, select, and activate it.  
* **Right-click** any environment in the list to quickly activate or delete it.

### **Tab 3: Pip Package Manager**

**Primary Use:** Dependency resolution and automation.

* **Left Panel:** Shows what is *currently* installed in the active environment. Select packages and use the side-by-side buttons or Right-Click Context Menus to manage them.  
* **Right Panel (Top):** Standard installation and Requirements.txt freezing.  
* **Right Panel (Bottom):** The "Saved Package Database". Type a package name and click "Add to DB". Check the boxes next to packages and click "Install Checked" to bulk-install your personal toolset.

### **Tab 4: Build & Package Engine**

**Primary Use:** Generating deployment artifacts (EXE).

* Ensure your entry script is selected in Tab 1\.  
* Check **Single Executable** and **Windowed App** for a silent background application.  
* Click **COMMENCE BUILD PROCESS**. Artifacts will be generated in the dist folder of your project root.

*Developed as a high-performance orchestration solution for rapid enterprise deployment.*