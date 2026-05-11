# **MatchBoxPY Changelog**

## **\[v1.0.0\] \- The Complete Enterprise Release**

* **Unified State:** C\# Project and PowerShell MVP have reached feature parity and architectural completion for v1.0.0.  
* **Feature \- GUI Link Overlay:** Added a dynamic, clickable LinkLabel pointing to the developer's GitHub, permanently pinned to the top right of the application header.  
* **Feature \- UI Space Optimization:** Refactored the Pip Package Manager tab to utilize horizontal TableLayoutPanel grids. "Uninstall / Update All" and "Remove / Install Checked" buttons are now perfectly symmetrical and side-by-side to guarantee visibility on smaller screens.  
* **Feature \- Right-Click Context Menus:** Injected robust ContextMenuStrip logic across all visual lists. Users can now right-click to run scripts, update/reinstall/uninstall individual Pip packages, activate/delete specific Venvs, and manage Saved Database packages directly.  
* **Feature \- UNC & Pathing:** Replaced the legacy .NET FolderBrowser with the native Windows 10/11 IFileOpenDialog COM interface for quick access to Network drives and OneDrive. Implemented a manual pathing bar to support raw \\\\Server\\Share UNC ingestion.  
* **Core Update:** The PowerShell wrapper dynamically compiles C\# 7.0+ syntax handling in real-time while strictly maintaining its single-file footprint.

## **\[v0.9.0\] \- The Enterprise Tabbed Update**

* **Added:** Robust 4-Tab interface layout separating Workspace, Environments, Pip Manager, and Build Engine.  
* **Added:** Portable "Saved Package Database" to allow developers to carry their favorite Pip loadouts between systems (\~/.matchboxpy/saved\_packages.txt).  
* **Added:** Target-specific Virtual Environment scanning. Replaced basic buttons with a dual-pane VENV list viewer.

## **\[v0.8.0\] \- Initial Prototype**

* Initial PowerShell wrapper containing the embedded WinForms interface.  
* Introduced basic Python CLI execution and PyInstaller orchestration.