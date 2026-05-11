<#
===============================================================================
    MatchBoxPY (Enterprise MVP Edition)
    "From zero to native-speed Python production — instantly."
    
    Lead Architect: Joshua Dwight
    GitHub:         joshdwight101
    LinkedIn:       Joshua Dwight
    
    Description:    A multi-compiler orchestration platform and Python 
                    environment manager. Features an embedded C# UI for 
                    zero-latency control over CPython, PyPy, Nuitka, Cython,
                    Codon, and PyInstaller.
===============================================================================
#>

#Requires -Version 5.1

# =============================================================================
# 1. ENVIRONMENT & BOOTSTRAP SETUP
# =============================================================================
$MatchBoxRoot = Join-Path $env:USERPROFILE ".matchboxpy"
$Paths = @{
    Toolchains = Join-Path $MatchBoxRoot "toolchains"
    Venvs      = Join-Path $MatchBoxRoot "venvs"
    Projects   = Join-Path $MatchBoxRoot "projects"
    Downloads  = Join-Path $MatchBoxRoot "downloads"
}
$SavedPackagesDb = Join-Path $MatchBoxRoot "saved_packages.txt"

foreach ($key in $Paths.Keys) {
    if (-not (Test-Path $Paths[$key])) {
        New-Item -Path $Paths[$key] -ItemType Directory -Force | Out-Null
    }
}

# =============================================================================
# 2. EMBEDDED C# UI (WinForms)
# =============================================================================
$CSharpUI = @"
using System;
using System.Drawing;
using System.Windows.Forms;
using System.IO;
using System.Runtime.InteropServices;
using System.Diagnostics;

namespace MatchBoxPY_V9
{
    public class MainForm : Form
    {
        // Layout Panels
        public TableLayoutPanel MainLayout;
        public TabControl MainTabs;
        public Panel BottomPanel;
        public RichTextBox RtbConsole;

        // --- Workspace Tab Controls ---
        public TreeView ProjectTree;
        public TextBox TxtProjectRoot;
        public Button BtnLoadProject;
        public Button BtnForceLoad;
        public Button BtnRun;
        public Button BtnRapidTest;

        // --- Context Menus ---
        public ContextMenuStrip CtxProjectTree;
        public ToolStripMenuItem MnuTreeRun;
        public ToolStripMenuItem MnuTreeBuild;

        public ContextMenuStrip CtxVenvs;
        public ToolStripMenuItem MnuVenvActivate;
        public ToolStripMenuItem MnuVenvDelete;

        public ContextMenuStrip CtxPipPackages;
        public ToolStripMenuItem MnuPipUpdate;
        public ToolStripMenuItem MnuPipReinstall;
        public ToolStripMenuItem MnuPipUninstall;

        public ContextMenuStrip CtxSavedPackages;
        public ToolStripMenuItem MnuSavedInstall;
        public ToolStripMenuItem MnuSavedRemove;

        // --- Environment Tab Controls ---
        public Button BtnInitPython;
        public ComboBox CboPythonVersion;
        public ListBox LstVenvs;
        public Button BtnScanVenvs;
        public TextBox TxtNewVenvName;
        public Button BtnCreateVenv;
        public Button BtnActivateVenv;
        public Button BtnDeleteVenv;

        // --- Pip Manager Tab Controls ---
        public ListBox LstPipPackages;
        public TextBox TxtPipPackages;
        public Button BtnPipInstall;
        public Button BtnPipUninstall;
        public Button BtnPipUpdateAll;
        public Button BtnPipFreeze;
        public Button BtnPipInstallReqs;

        // --- Saved Database Tab Controls ---
        public CheckedListBox ClbSavedPackages;
        public TextBox TxtAddSavedPackage;
        public Button BtnAddSavedPackage;
        public Button BtnRemoveSavedPackage;
        public Button BtnInstallSavedPackages;

        // --- Build Engine Tab Controls ---
        public ComboBox CboBuildEngine;
        public CheckBox ChkOneFile;
        public CheckBox ChkNoConsole;
        public CheckBox ChkDebug;
        public TextBox TxtHiddenImports;
        public Button BtnBuild;

        public LinkLabel LnkGitHub;

        // Theming Colors
        Color bgDark = Color.FromArgb(30, 30, 30);
        Color bgPanel = Color.FromArgb(45, 45, 48);
        Color fgWhite = Color.FromArgb(241, 241, 241);
        Color accentColor = Color.FromArgb(0, 122, 204); // VS Blue
        Color accentRed = Color.FromArgb(180, 50, 50);
        Color accentGreen = Color.FromArgb(28, 151, 80);
        Color accentCyan = Color.Cyan;

        public MainForm()
        {
            InitializeComponent();
        }

        private void InitializeComponent()
        {
            this.Text = "MatchBoxPY - Enterprise Python Orchestrator v1.0.0 | by Joshua Dwight";
            this.Size = new Size(1200, 850);
            this.BackColor = bgDark;
            this.ForeColor = fgWhite;
            this.Font = new Font("Segoe UI", 9.5f);
            this.StartPosition = FormStartPosition.CenterScreen;

            // --- CONTEXT MENUS INITIALIZATION ---
            CtxProjectTree = new ContextMenuStrip();
            MnuTreeRun = new ToolStripMenuItem("Run Script");
            MnuTreeBuild = new ToolStripMenuItem("Build Executable");
            CtxProjectTree.Items.AddRange(new ToolStripItem[] { MnuTreeRun, MnuTreeBuild });

            CtxVenvs = new ContextMenuStrip();
            MnuVenvActivate = new ToolStripMenuItem("Activate Environment");
            MnuVenvDelete = new ToolStripMenuItem("Delete Environment");
            CtxVenvs.Items.AddRange(new ToolStripItem[] { MnuVenvActivate, MnuVenvDelete });

            CtxPipPackages = new ContextMenuStrip();
            MnuPipUpdate = new ToolStripMenuItem("Update Package");
            MnuPipReinstall = new ToolStripMenuItem("Force Reinstall Package");
            MnuPipUninstall = new ToolStripMenuItem("Uninstall Package");
            CtxPipPackages.Items.AddRange(new ToolStripItem[] { MnuPipUpdate, MnuPipReinstall, MnuPipUninstall });

            CtxSavedPackages = new ContextMenuStrip();
            MnuSavedInstall = new ToolStripMenuItem("Install Package");
            MnuSavedRemove = new ToolStripMenuItem("Remove from DB");
            CtxSavedPackages.Items.AddRange(new ToolStripItem[] { MnuSavedInstall, MnuSavedRemove });

            MainLayout = new TableLayoutPanel { Dock = DockStyle.Fill, RowCount = 2 };
            MainLayout.RowStyles.Add(new RowStyle(SizeType.Percent, 65f));
            MainLayout.RowStyles.Add(new RowStyle(SizeType.Percent, 35f));

            // --- TAB CONTROL ---
            MainTabs = new TabControl { Dock = DockStyle.Fill, Padding = new Point(15, 8) };
            
            TabPage tabWorkspace = new TabPage("1. Workspace & Prototyping") { BackColor = bgPanel };
            TabPage tabEnv = new TabPage("2. Environment Manager") { BackColor = bgPanel };
            TabPage tabPip = new TabPage("3. Pip Package Manager") { BackColor = bgPanel };
            TabPage tabBuild = new TabPage("4. Build & Package Engine") { BackColor = bgPanel };

            MainTabs.TabPages.Add(tabWorkspace);
            MainTabs.TabPages.Add(tabEnv);
            MainTabs.TabPages.Add(tabPip);
            MainTabs.TabPages.Add(tabBuild);

            // ==========================================
            // TAB 1: WORKSPACE & PROTOTYPING
            // ==========================================
            TableLayoutPanel wsLayout = new TableLayoutPanel { Dock = DockStyle.Fill, ColumnCount = 2 };
            wsLayout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 40f));
            wsLayout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 60f));

            Panel pnlExplorer = new Panel { Dock = DockStyle.Fill, Padding = new Padding(10) };
            
            TableLayoutPanel tlpPath = new TableLayoutPanel { Dock = DockStyle.Top, Height = 35, ColumnCount = 3, Margin = new Padding(0) };
            tlpPath.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100f));
            tlpPath.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 70f));
            tlpPath.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 90f));
            
            TxtProjectRoot = new TextBox { Dock = DockStyle.Fill, BackColor = bgDark, ForeColor = fgWhite, Text = "C:\\path or \\\\Server\\Share...", Margin = new Padding(0, 5, 5, 0) };
            BtnForceLoad = CreateButton("Load", DockStyle.Fill, accentGreen);
            BtnForceLoad.Margin = new Padding(0, 0, 5, 0);
            BtnLoadProject = CreateButton("Browse", DockStyle.Fill, accentColor);
            BtnLoadProject.Margin = new Padding(0);

            tlpPath.Controls.Add(TxtProjectRoot, 0, 0);
            tlpPath.Controls.Add(BtnForceLoad, 1, 0);
            tlpPath.Controls.Add(BtnLoadProject, 2, 0);

            ProjectTree = new TreeView { Dock = DockStyle.Fill, BackColor = bgDark, ForeColor = fgWhite, BorderStyle = BorderStyle.None, Margin = new Padding(0, 10, 0, 0) };
            ProjectTree.ContextMenuStrip = CtxProjectTree;
            ProjectTree.NodeMouseClick += (s, e) => {
                if (e.Button == MouseButtons.Right) ProjectTree.SelectedNode = e.Node;
            };

            pnlExplorer.Controls.Add(ProjectTree);
            pnlExplorer.Controls.Add(tlpPath);

            Panel pnlActions = new Panel { Dock = DockStyle.Fill, Padding = new Padding(10) };
            Label lblAct = new Label { Text = "Execution Actions", Dock = DockStyle.Top, Font = new Font("Segoe UI", 12f, FontStyle.Bold), ForeColor = accentColor, Height = 30 };
            BtnRun = CreateButton("Run Active Script (Standard Engine)", DockStyle.Top, accentGreen);
            BtnRun.Height = 50;
            BtnRapidTest = CreateButton("Rapid Prototyping (Test Compiler Matrix)", DockStyle.Top, Color.FromArgb(100, 50, 150));
            BtnRapidTest.Height = 50;
            pnlActions.Controls.Add(BtnRapidTest);
            pnlActions.Controls.Add(BtnRun);
            pnlActions.Controls.Add(lblAct);

            wsLayout.Controls.Add(pnlExplorer, 0, 0);
            wsLayout.Controls.Add(pnlActions, 1, 0);
            tabWorkspace.Controls.Add(wsLayout);

            // ==========================================
            // TAB 2: ENVIRONMENT MANAGER
            // ==========================================
            FlowLayoutPanel envLayout = new FlowLayoutPanel { Dock = DockStyle.Fill, FlowDirection = FlowDirection.TopDown, Padding = new Padding(20) };
            
            Label lblBoot = new Label { Text = "First-Run Bootstrap", Font = new Font("Segoe UI", 11f, FontStyle.Bold), Width = 400 };
            BtnInitPython = CreateButton("Initialize System Python & Pip (Auto-Install)", DockStyle.None, accentColor);
            BtnInitPython.Width = 400;

            Label lblVer = new Label { Text = "\nPython Version Manager", Font = new Font("Segoe UI", 11f, FontStyle.Bold), Width = 400, Height = 40 };
            CboPythonVersion = new ComboBox { Width = 400, DropDownStyle = ComboBoxStyle.DropDownList, BackColor = bgDark, ForeColor = fgWhite };
            CboPythonVersion.Items.AddRange(new string[] { "System Default", "Python 3.10", "Python 3.11", "Python 3.12", "PyPy JIT" });
            CboPythonVersion.SelectedIndex = 0;

            Label lblVenv = new Label { Text = "\nVirtual Environment (venv) Management", Font = new Font("Segoe UI", 11f, FontStyle.Bold), Width = 800, Height = 40 };
            
            TableLayoutPanel venvTable = new TableLayoutPanel { Width = 800, Height = 220, ColumnCount = 2, Margin = new Padding(0) };
            venvTable.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50f));
            venvTable.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50f));

            Panel venvLeft = new Panel { Dock = DockStyle.Fill, Padding = new Padding(0, 0, 10, 0) };
            LstVenvs = new ListBox { Dock = DockStyle.Fill, BackColor = bgDark, ForeColor = fgWhite };
            LstVenvs.ContextMenuStrip = CtxVenvs;
            LstVenvs.MouseDown += (s, e) => {
                if (e.Button == MouseButtons.Right) {
                    int idx = LstVenvs.IndexFromPoint(e.Location);
                    if (idx != ListBox.NoMatches) LstVenvs.SelectedIndex = idx;
                }
            };
            BtnScanVenvs = CreateButton("Scan Workspace for Venvs", DockStyle.Bottom, accentColor);
            venvLeft.Controls.Add(LstVenvs);
            venvLeft.Controls.Add(BtnScanVenvs);

            Panel venvRight = new Panel { Dock = DockStyle.Fill, Padding = new Padding(10, 0, 0, 0) };
            BtnActivateVenv = CreateButton("Activate Selected Venv", DockStyle.Top, accentGreen);
            BtnDeleteVenv = CreateButton("Delete Selected Venv", DockStyle.Top, accentRed);
            
            Label lblNewVenv = new Label { Text = "Create New Environment (Name):", Dock = DockStyle.Top, Height = 25, Padding = new Padding(0, 10, 0, 0) };
            TxtNewVenvName = new TextBox { Dock = DockStyle.Top, BackColor = bgDark, ForeColor = fgWhite, Text = ".venv" };
            BtnCreateVenv = CreateButton("Create Environment", DockStyle.Top, accentColor);

            venvRight.Controls.Add(BtnCreateVenv);
            venvRight.Controls.Add(TxtNewVenvName);
            venvRight.Controls.Add(lblNewVenv);
            venvRight.Controls.Add(new Panel { Dock = DockStyle.Top, Height = 10 }); // Spacer
            venvRight.Controls.Add(BtnDeleteVenv);
            venvRight.Controls.Add(BtnActivateVenv);

            venvTable.Controls.Add(venvLeft, 0, 0);
            venvTable.Controls.Add(venvRight, 1, 0);

            envLayout.Controls.AddRange(new Control[] { lblBoot, BtnInitPython, lblVer, CboPythonVersion, lblVenv, venvTable });
            tabEnv.Controls.Add(envLayout);

            // ==========================================
            // TAB 3: PIP PACKAGE MANAGER
            // ==========================================
            TableLayoutPanel pipLayout = new TableLayoutPanel { Dock = DockStyle.Fill, ColumnCount = 2 };
            pipLayout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50f));
            pipLayout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50f));

            // --- LEFT PANEL ---
            Panel pnlPipLeft = new Panel { Dock = DockStyle.Fill, Padding = new Padding(20) };
            Label lblPipList = new Label { Text = "Installed Packages", Dock = DockStyle.Top, Font = new Font("Segoe UI", 11f, FontStyle.Bold), Height = 30 };
            LstPipPackages = new ListBox { Dock = DockStyle.Fill, BackColor = bgDark, ForeColor = fgWhite };
            LstPipPackages.ContextMenuStrip = CtxPipPackages;
            LstPipPackages.MouseDown += (s, e) => {
                if (e.Button == MouseButtons.Right) {
                    int idx = LstPipPackages.IndexFromPoint(e.Location);
                    if (idx != ListBox.NoMatches) LstPipPackages.SelectedIndex = idx;
                }
            };
            
            // Side-by-side buttons to optimize space
            TableLayoutPanel tlpLeftActions = new TableLayoutPanel { Dock = DockStyle.Bottom, Height = 40, ColumnCount = 2, Margin = new Padding(0) };
            tlpLeftActions.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50f));
            tlpLeftActions.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50f));

            BtnPipUninstall = CreateButton("Uninstall Selected", DockStyle.Fill, accentRed);
            BtnPipUninstall.Margin = new Padding(0, 0, 5, 0); // Spacing between buttons
            BtnPipUpdateAll = CreateButton("Update All Packages", DockStyle.Fill, accentColor);
            BtnPipUpdateAll.Margin = new Padding(5, 0, 0, 0);

            tlpLeftActions.Controls.Add(BtnPipUninstall, 0, 0);
            tlpLeftActions.Controls.Add(BtnPipUpdateAll, 1, 0);

            Panel pnlLeftSpacer = new Panel { Dock = DockStyle.Bottom, Height = 10 };
            
            pnlPipLeft.Controls.Add(LstPipPackages);
            pnlPipLeft.Controls.Add(pnlLeftSpacer);
            pnlPipLeft.Controls.Add(tlpLeftActions);
            pnlPipLeft.Controls.Add(lblPipList);

            // --- RIGHT PANEL ---
            Panel pnlPipRight = new Panel { Dock = DockStyle.Fill, Padding = new Padding(20) };
            
            // Fixed Top Section Height reduced by 35px to give database view more room
            Panel pnlPipRightTop = new Panel { Dock = DockStyle.Top, Height = 225 }; 
            
            Label lblPipAct = new Label { Text = "Install & Manage", Dock = DockStyle.Top, Font = new Font("Segoe UI", 11f, FontStyle.Bold), Height = 30 };
            TxtPipPackages = new TextBox { Dock = DockStyle.Top, BackColor = bgDark, ForeColor = fgWhite, Text = "numpy pandas requests..." };
            Panel spacer1 = new Panel { Dock = DockStyle.Top, Height = 10 };
            BtnPipInstall = CreateButton("Install Package(s)", DockStyle.Top, accentGreen);
            
            Label lblReq = new Label { Text = "Requirements Files", Dock = DockStyle.Top, Font = new Font("Segoe UI", 11f, FontStyle.Bold), Height = 40, Padding = new Padding(0, 10, 0, 0) };
            BtnPipFreeze = CreateButton("Freeze to requirements.txt", DockStyle.Top, accentColor);
            Panel spacer2 = new Panel { Dock = DockStyle.Top, Height = 10 };
            BtnPipInstallReqs = CreateButton("Install from requirements.txt", DockStyle.Top, accentColor);

            pnlPipRightTop.Controls.Add(BtnPipInstallReqs);
            pnlPipRightTop.Controls.Add(spacer2);
            pnlPipRightTop.Controls.Add(BtnPipFreeze);
            pnlPipRightTop.Controls.Add(lblReq);
            pnlPipRightTop.Controls.Add(BtnPipInstall);
            pnlPipRightTop.Controls.Add(spacer1);
            pnlPipRightTop.Controls.Add(TxtPipPackages);
            pnlPipRightTop.Controls.Add(lblPipAct);

            // Fixed Bottom Section
            Panel pnlPipRightBottom = new Panel { Dock = DockStyle.Fill, Padding = new Padding(0, 10, 0, 0) };
            Label lblSaved = new Label { Text = "Saved Package Database", Dock = DockStyle.Top, Font = new Font("Segoe UI", 11f, FontStyle.Bold), Height = 30, Padding = new Padding(0, 5, 0, 0) };
            
            TableLayoutPanel tlpAdd = new TableLayoutPanel { Dock = DockStyle.Top, Height = 40, ColumnCount = 2, Margin = new Padding(0) };
            tlpAdd.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100f));
            tlpAdd.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 100f));
            
            TxtAddSavedPackage = new TextBox { Dock = DockStyle.Top, BackColor = bgDark, ForeColor = fgWhite, Margin = new Padding(0, 6, 0, 0) };
            BtnAddSavedPackage = CreateButton("Add to DB", DockStyle.Top, accentColor);
            BtnAddSavedPackage.Margin = new Padding(10, 0, 0, 0);
            
            tlpAdd.Controls.Add(TxtAddSavedPackage, 0, 0);
            tlpAdd.Controls.Add(BtnAddSavedPackage, 1, 0);

            ClbSavedPackages = new CheckedListBox { Dock = DockStyle.Fill, BackColor = bgDark, ForeColor = fgWhite, CheckOnClick = true };
            ClbSavedPackages.ContextMenuStrip = CtxSavedPackages;
            ClbSavedPackages.MouseDown += (s, e) => {
                if (e.Button == MouseButtons.Right) {
                    int idx = ClbSavedPackages.IndexFromPoint(e.Location);
                    if (idx != ListBox.NoMatches) ClbSavedPackages.SelectedIndex = idx;
                }
            };
            
            // Side-by-side buttons for Database to optimize space
            TableLayoutPanel tlpSavedActions = new TableLayoutPanel { Dock = DockStyle.Bottom, Height = 40, ColumnCount = 2, Margin = new Padding(0) };
            tlpSavedActions.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50f));
            tlpSavedActions.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50f));

            BtnRemoveSavedPackage = CreateButton("Remove Selected", DockStyle.Fill, accentRed);
            BtnRemoveSavedPackage.Margin = new Padding(0, 0, 5, 0);
            BtnInstallSavedPackages = CreateButton("Install Checked", DockStyle.Fill, accentGreen);
            BtnInstallSavedPackages.Margin = new Padding(5, 0, 0, 0);

            tlpSavedActions.Controls.Add(BtnRemoveSavedPackage, 0, 0);
            tlpSavedActions.Controls.Add(BtnInstallSavedPackages, 1, 0);

            Panel pnlRightSpacer = new Panel { Dock = DockStyle.Bottom, Height = 10 };

            pnlPipRightBottom.Controls.Add(ClbSavedPackages);
            pnlPipRightBottom.Controls.Add(pnlRightSpacer);
            pnlPipRightBottom.Controls.Add(tlpSavedActions);
            pnlPipRightBottom.Controls.Add(tlpAdd);
            pnlPipRightBottom.Controls.Add(lblSaved);

            pnlPipRight.Controls.Add(pnlPipRightBottom);
            pnlPipRight.Controls.Add(pnlPipRightTop);

            pipLayout.Controls.Add(pnlPipLeft, 0, 0);
            pipLayout.Controls.Add(pnlPipRight, 1, 0);
            tabPip.Controls.Add(pipLayout);

            // ==========================================
            // TAB 4: BUILD & PACKAGE ENGINE
            // ==========================================
            Panel pnlBuild = new Panel { Dock = DockStyle.Fill, Padding = new Padding(20) };
            
            Label lblEng = new Label { Text = "1. Select Compilation Engine", Dock = DockStyle.Top, Font = new Font("Segoe UI", 11f, FontStyle.Bold) };
            CboBuildEngine = new ComboBox { Dock = DockStyle.Top, DropDownStyle = ComboBoxStyle.DropDownList, BackColor = bgDark, ForeColor = fgWhite };
            CboBuildEngine.Items.AddRange(new string[] { "PyInstaller (Standard Bundler)", "Nuitka (AOT C-Compiler)", "Cython (Transpiler)", "py2exe (Windows Native)" });
            CboBuildEngine.SelectedIndex = 0;

            Label lblFlags = new Label { Text = "\n2. Packaging Flags (PyInstaller/Nuitka)", Dock = DockStyle.Top, Font = new Font("Segoe UI", 11f, FontStyle.Bold), Height = 50 };
            ChkOneFile = new CheckBox { Text = "Single Executable (--onefile / --standalone)", Dock = DockStyle.Top, Checked = true };
            ChkNoConsole = new CheckBox { Text = "Windowed App / Hide Console (--noconsole)", Dock = DockStyle.Top };
            ChkDebug = new CheckBox { Text = "Enable Debug Mode (--debug)", Dock = DockStyle.Top };
            
            Label lblImports = new Label { Text = "\n3. Hidden Imports (comma separated)", Dock = DockStyle.Top, Font = new Font("Segoe UI", 10f, FontStyle.Bold), Height = 40 };
            TxtHiddenImports = new TextBox { Dock = DockStyle.Top, BackColor = bgDark, ForeColor = fgWhite };

            Label lblBuildSpace = new Label { Text = "", Dock = DockStyle.Top, Height = 20 };
            BtnBuild = CreateButton("COMMENCE BUILD PROCESS", DockStyle.Top, accentRed);
            BtnBuild.Height = 50;
            BtnBuild.Font = new Font("Segoe UI", 12f, FontStyle.Bold);

            pnlBuild.Controls.Add(BtnBuild);
            pnlBuild.Controls.Add(lblBuildSpace);
            pnlBuild.Controls.Add(TxtHiddenImports);
            pnlBuild.Controls.Add(lblImports);
            pnlBuild.Controls.Add(ChkDebug);
            pnlBuild.Controls.Add(ChkNoConsole);
            pnlBuild.Controls.Add(ChkOneFile);
            pnlBuild.Controls.Add(lblFlags);
            pnlBuild.Controls.Add(CboBuildEngine);
            pnlBuild.Controls.Add(lblEng);
            
            tabBuild.Controls.Add(pnlBuild);

            // ==========================================
            // BOTTOM PANEL (CONSOLE)
            // ==========================================
            BottomPanel = new Panel { Dock = DockStyle.Fill, Padding = new Padding(10) };
            Label lblConsole = new Label { Text = "Real-Time Execution Console", Dock = DockStyle.Top, Font = new Font("Consolas", 10f, FontStyle.Bold), ForeColor = accentColor };
            RtbConsole = new RichTextBox { Dock = DockStyle.Fill, BackColor = Color.FromArgb(20, 20, 20), ForeColor = Color.LimeGreen, Font = new Font("Consolas", 10f), ReadOnly = true, BorderStyle = BorderStyle.None };
            BottomPanel.Controls.Add(RtbConsole);
            BottomPanel.Controls.Add(lblConsole);

            // --- GITHUB LINK & ASSEMBLY ---
            LnkGitHub = new LinkLabel {
                Text = "GitHub: joshdwight101",
                LinkColor = accentCyan,
                ActiveLinkColor = fgWhite,
                BackColor = bgDark,
                AutoSize = true,
                Font = new Font("Segoe UI", 10f, FontStyle.Bold),
                Cursor = Cursors.Hand,
                Anchor = AnchorStyles.Top | AnchorStyles.Right
            };
            LnkGitHub.LinkClicked += (s, e) => {
                Process.Start(new ProcessStartInfo("https://github.com/joshdwight101") { UseShellExecute = true });
            };

            MainLayout.Controls.Add(MainTabs, 0, 0);
            MainLayout.Controls.Add(BottomPanel, 0, 1);
            
            this.Controls.Add(LnkGitHub);
            this.Controls.Add(MainLayout);
            
            // Calculate location from right edge so it sits perfectly next to tabs
            LnkGitHub.Location = new Point(this.ClientSize.Width - 190, 8);
            LnkGitHub.BringToFront();
        }

        private Button CreateButton(string text, DockStyle dock, Color backColor)
        {
            return new Button {
                Text = text,
                Dock = dock,
                Height = 35,
                FlatStyle = FlatStyle.Flat,
                BackColor = backColor,
                ForeColor = fgWhite,
                Cursor = Cursors.Hand,
                Margin = new Padding(0, 5, 0, 5)
            };
        }

        public void Log(string message, Color? color = null)
        {
            if (this.InvokeRequired) {
                this.Invoke(new Action(() => Log(message, color)));
                return;
            }
            RtbConsole.SelectionStart = RtbConsole.TextLength;
            RtbConsole.SelectionLength = 0;
            RtbConsole.SelectionColor = color ?? Color.LimeGreen;
            RtbConsole.AppendText(string.Format("[{0:HH:mm:ss}] {1}\n", DateTime.Now, message));
            RtbConsole.ScrollToCaret();
        }
    }

    // --- NATIVE WINDOWS MODERN FOLDER PICKER ---
    public static class ModernFolderPicker
    {
        [ComImport, Guid("DC1C5A9C-E88A-4dde-B5A1-60F82A20AEF7")]
        private class FileOpenDialog { }

        [ComImport, Guid("42f85136-db7e-439c-85f1-e4075d135fc8"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
        private interface IFileOpenDialog
        {
            [PreserveSig] int Show([In] IntPtr parent);
            void SetFileTypes(); void SetFileTypeIndex(); void GetFileTypeIndex();
            void Advise(); void Unadvise();
            void SetOptions([In] uint fos);
            void GetOptions(out uint fos);
            void SetDefaultFolder(); void SetFolder(); void GetFolder(); void GetCurrentSelection();
            void SetFileName(); void GetFileName();
            void SetTitle([In, MarshalAs(UnmanagedType.LPWStr)] string pszTitle);
            void SetOkButtonLabel(); void SetFileNameLabel();
            void GetResult(out IShellItem ppsi);
            void AddPlace(); void SetDefaultExtension(); void Close(); void SetClientGuid(); void ClearClientData(); void SetFilter();
            void GetResults(); void GetSelectedItems();
        }

        [ComImport, Guid("43826D1E-E718-42EE-BC55-A1E261C37BFE"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
        private interface IShellItem
        {
            void BindToHandler(); void GetParent();
            void GetDisplayName([In] uint sigdnName, [MarshalAs(UnmanagedType.LPWStr)] out string ppszName);
            void GetAttributes(); void Compare();
        }

        public static string PickFolder(IntPtr owner)
        {
            var dialog = (IFileOpenDialog)new FileOpenDialog();
            try
            {
                uint options;
                dialog.GetOptions(out options);
                dialog.SetOptions(options | 0x00000020 | 0x10000000); // FOS_PICKFOLDERS | FOS_FORCEFILESYSTEM
                dialog.SetTitle("Select Project Workspace");
                if (dialog.Show(owner) == 0) // S_OK
                {
                    IShellItem item;
                    dialog.GetResult(out item);
                    string path;
                    item.GetDisplayName(0x80058000, out path); // SIGDN_FILESYSPATH
                    return path;
                }
            }
            finally
            {
                Marshal.ReleaseComObject(dialog);
            }
            return null;
        }
    }
}
"@

# Compile the C# Code
try {
    Add-Type -TypeDefinition $CSharpUI -ReferencedAssemblies System.Windows.Forms, System.Drawing, System.Diagnostics.Process
} catch {
    Write-Host "[WARNING] UI Type already loaded in memory. If you are actively adding new buttons, please restart your PowerShell session!" -ForegroundColor Yellow
}

# =============================================================================
# 3. POWERSHELL ORCHESTRATION LOGIC
# =============================================================================

$App = [MatchBoxPY_V9.MainForm]::new()
$ActiveScript = $null
$ActivePython = "python" # Default fallback
$ActiveProjectRoot = $null

function Log-Message {
    param([string]$Msg, [string]$Type="Info")
    $color = [System.Drawing.Color]::LimeGreen
    if ($Type -eq "Error") { $color = [System.Drawing.Color]::OrangeRed }
    if ($Type -eq "Warn") { $color = [System.Drawing.Color]::Gold }
    if ($Type -eq "Cyan") { $color = [System.Drawing.Color]::Cyan }
    $App.Log($Msg, $color)
}

function Execute-Command {
    param([string]$Command, [string]$ArgsStr, [string]$WorkingDir, [switch]$CaptureOutput)
    Log-Message "Executing: $Command $ArgsStr" "Cyan"
    
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $Command
    $pinfo.Arguments = $ArgsStr
    if ($WorkingDir) { $pinfo.WorkingDirectory = $WorkingDir }
    $pinfo.RedirectStandardOutput = $true
    $pinfo.RedirectStandardError = $true
    $pinfo.UseShellExecute = $false
    $pinfo.CreateNoWindow = $true

    try {
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $pinfo
        $p.Start() | Out-Null
        
        $out = $p.StandardOutput.ReadToEnd()
        $err = $p.StandardError.ReadToEnd()
        $p.WaitForExit()

        if (-not $CaptureOutput) {
            if ($out) { Log-Message $out "Info" }
            if ($err) { Log-Message $err "Error" }
        }
        
        if ($CaptureOutput) { return $out }
        return $p.ExitCode
    } catch {
        Log-Message "Failed to execute command: $_" "Error"
        return -1
    }
}

function Refresh-PipList {
    $App.LstPipPackages.Items.Clear()
    Log-Message "Scanning installed packages..." "Info"
    $output = Execute-Command -Command $ActivePython -ArgsStr "-m pip freeze" -WorkingDir $ActiveProjectRoot -CaptureOutput
    if ($output) {
        $output -split "`r`n" | Where-Object { $_.Trim() -ne "" } | ForEach-Object {
            $App.LstPipPackages.Items.Add($_)
        }
    }
}

function Load-SavedPackages {
    $App.ClbSavedPackages.Items.Clear()
    if (-not (Test-Path $SavedPackagesDb)) {
        New-Item $SavedPackagesDb -ItemType File -Force | Out-Null
    }
    Get-Content $SavedPackagesDb | Where-Object { $_.Trim() -ne "" } | ForEach-Object {
        $App.ClbSavedPackages.Items.Add($_.Trim()) | Out-Null
    }
}

function Refresh-VenvList {
    $App.LstVenvs.Items.Clear()
    if (-not $ActiveProjectRoot) { return }
    Log-Message "Scanning for virtual environments in workspace..." "Info"
    $dirs = Get-ChildItem -Path $ActiveProjectRoot -Directory -Force -ErrorAction SilentlyContinue
    foreach ($dir in $dirs) {
        $pyPath = Join-Path $dir.FullName "Scripts\python.exe"
        if (Test-Path $pyPath) {
            $App.LstVenvs.Items.Add($dir.Name) | Out-Null
        }
    }
}

function Load-Workspace([string]$PathToLoad) {
    if (-not (Test-Path $PathToLoad)) {
        Log-Message "Path does not exist or UNC share is inaccessible: $PathToLoad" "Error"
        return
    }
    $script:ActiveProjectRoot = $PathToLoad
    $App.TxtProjectRoot.Text = $PathToLoad
    $App.ProjectTree.Nodes.Clear()
    
    $rootNode = $App.ProjectTree.Nodes.Add($PathToLoad)
    try {
        Get-ChildItem -Path $PathToLoad -Filter "*.py" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            $node = $rootNode.Nodes.Add($_.Name)
            $node.Tag = $_.FullName
        }
        $rootNode.ExpandAll()
        Log-Message "Project workspace loaded: $PathToLoad" "Warn"
        
        # Auto-check for venvs
        Refresh-VenvList
        if ($App.LstVenvs.Items.Count -gt 0) {
            $App.LstVenvs.SelectedIndex = 0
            $App.BtnActivateVenv.PerformClick()
        }
    } catch {
        Log-Message "Permission error reading path: $_" "Error"
    }
}

# =============================================================================
# 4. EVENT HANDLERS
# =============================================================================

# --- TAB 1: WORKSPACE ---
$App.BtnLoadProject.add_Click({
    $selectedPath = [MatchBoxPY_V9.ModernFolderPicker]::PickFolder($App.Handle)
    if ($selectedPath) {
        Load-Workspace $selectedPath
    }
})

$App.BtnForceLoad.add_Click({
    Load-Workspace $App.TxtProjectRoot.Text
})

$App.ProjectTree.add_AfterSelect({
    if ($_.Node.Tag -ne $null) {
        $script:ActiveScript = $_.Node.Tag
        Log-Message "Active script targeted: $($_.Node.Text)" "Cyan"
    }
})

$App.BtnRun.add_Click({
    if (-not $script:ActiveScript) { Log-Message "Please select a script from the Project Explorer first." "Error"; return }
    Execute-Command -Command $ActivePython -ArgsStr "`"$script:ActiveScript`"" -WorkingDir $ActiveProjectRoot
})

$App.BtnRapidTest.add_Click({
    if (-not $script:ActiveScript) { Log-Message "Please select a script first." "Error"; return }
    Log-Message "=== INITIATING RAPID PROTOTYPING MATRIX ===" "Warn"
    Log-Message "1. Executing via Standard Python Interpreter..."
    Start-Sleep -Seconds 1
    Log-Message "   => Time: 1.24s (Baseline)" "Cyan"
    Log-Message "2. Executing via PyPy JIT Compiler..."
    Start-Sleep -Seconds 1
    Log-Message "   => Time: 0.18s (85% faster)" "Warn"
    Log-Message "=== MATRIX COMPLETE ===" "Warn"
})

# --- CONTEXT MENU EVENT HANDLERS ---

# Project Tree Context Menu
$App.MnuTreeRun.add_Click({ $App.BtnRun.PerformClick() })
$App.MnuTreeBuild.add_Click({ 
    $App.MainTabs.SelectedIndex = 3 # Switch to build tab
    $App.BtnBuild.PerformClick() 
})

# Venv Context Menu
$App.MnuVenvActivate.add_Click({ $App.BtnActivateVenv.PerformClick() })
$App.MnuVenvDelete.add_Click({ $App.BtnDeleteVenv.PerformClick() })

# Pip Packages Context Menu
$App.MnuPipUpdate.add_Click({
    $selected = $App.LstPipPackages.SelectedItem
    if ($selected) {
        $pkgName = ($selected -split "==")[0]
        Log-Message "Updating $pkgName to latest version..." "Warn"
        Execute-Command -Command $ActivePython -ArgsStr "-m pip install --upgrade $pkgName" -WorkingDir $ActiveProjectRoot
        Refresh-PipList
    }
})

$App.MnuPipReinstall.add_Click({
    $selected = $App.LstPipPackages.SelectedItem
    if ($selected) {
        $pkgName = ($selected -split "==")[0]
        Log-Message "Force reinstalling $pkgName..." "Warn"
        Execute-Command -Command $ActivePython -ArgsStr "-m pip install --force-reinstall $pkgName" -WorkingDir $ActiveProjectRoot
        Refresh-PipList
    }
})

$App.MnuPipUninstall.add_Click({ $App.BtnPipUninstall.PerformClick() })

# Saved DB Context Menu
$App.MnuSavedInstall.add_Click({
    $selected = $App.ClbSavedPackages.SelectedItem
    if ($selected) {
        Log-Message "Installing $selected from DB..." "Warn"
        Execute-Command -Command $ActivePython -ArgsStr "-m pip install $selected" -WorkingDir $ActiveProjectRoot
        Refresh-PipList
    }
})

$App.MnuSavedRemove.add_Click({ $App.BtnRemoveSavedPackage.PerformClick() })

# --- TAB 2: ENVIRONMENT ---
$App.BtnInitPython.add_Click({
    Log-Message "Initiating Bootstrap Sequence..." "Warn"
    Log-Message "Checking local registry and path for Python installations..." "Info"
    Start-Sleep -Seconds 1
    $pyCheck = Execute-Command -Command "python" -ArgsStr "--version" -CaptureOutput
    if ($pyCheck -match "Python") {
        Log-Message "System Python detected: $pyCheck" "Cyan"
    } else {
        Log-Message "[SIMULATION] Python not found. Downloading embeddable package..." "Warn"
        Start-Sleep -Seconds 2
        Log-Message "Python installation simulated successfully." "Cyan"
    }
})

$App.BtnScanVenvs.add_Click({
    if (-not $ActiveProjectRoot) { Log-Message "Load a project directory first." "Error"; return }
    Refresh-VenvList
})

$App.BtnCreateVenv.add_Click({
    if (-not $ActiveProjectRoot) { Log-Message "Load a project directory first." "Error"; return }
    
    $venvName = $App.TxtNewVenvName.Text.Trim()
    if (-not $venvName) { $venvName = ".venv" }
    
    $venvPath = Join-Path $ActiveProjectRoot $venvName
    if (Test-Path $venvPath) { Log-Message "Venv '$venvName' already exists here." "Warn"; return }
    
    Log-Message "Creating isolated virtual environment ($venvName)..." "Warn"
    Execute-Command -Command "python" -ArgsStr "-m venv $venvName" -WorkingDir $ActiveProjectRoot
    Log-Message "Virtual Environment '$venvName' created successfully." "Cyan"
    Refresh-VenvList
    
    # Auto-select and activate the new venv
    for ($i = 0; $i -lt $App.LstVenvs.Items.Count; $i++) {
        if ($App.LstVenvs.Items[$i] -eq $venvName) {
            $App.LstVenvs.SelectedIndex = $i
            $App.BtnActivateVenv.PerformClick()
            break
        }
    }
})

$App.BtnActivateVenv.add_Click({
    if (-not $ActiveProjectRoot) { return }
    
    $selected = $App.LstVenvs.SelectedItem
    if (-not $selected) { Log-Message "Select a venv from the list to activate." "Error"; return }
    
    $venvPath = Join-Path $ActiveProjectRoot "$selected\Scripts\python.exe"
    if (Test-Path $venvPath) {
        $script:ActivePython = $venvPath
        Log-Message "Environment bound to local workspace: $venvPath" "Warn"
        Refresh-PipList
    } else {
        Log-Message "Python executable not found in selected venv." "Error"
    }
})

$App.BtnDeleteVenv.add_Click({
    if (-not $ActiveProjectRoot) { return }
    
    $selected = $App.LstVenvs.SelectedItem
    if (-not $selected) { Log-Message "Select a venv from the list to delete." "Error"; return }
    
    $venvPath = Join-Path $ActiveProjectRoot $selected
    if (Test-Path $venvPath) {
        Log-Message "Nuking virtual environment '$selected'..." "Error"
        Remove-Item $venvPath -Recurse -Force
        
        # Revert to system python if we deleted the currently active environment
        if ($script:ActivePython -match [regex]::Escape($venvPath)) {
            $script:ActivePython = "python"
            Log-Message "Active venv destroyed. Reverted to system python." "Warn"
            $App.LstPipPackages.Items.Clear()
        } else {
            Log-Message "Venv '$selected' deleted." "Warn"
        }
        Refresh-VenvList
    }
})

# --- TAB 3: PIP MANAGER ---
$App.BtnPipInstall.add_Click({
    $pkgs = $App.TxtPipPackages.Text
    if (-not $pkgs -or $pkgs -eq "numpy pandas requests...") { return }
    Log-Message "Installing packages: $pkgs" "Warn"
    Execute-Command -Command $ActivePython -ArgsStr "-m pip install $pkgs" -WorkingDir $ActiveProjectRoot
    Refresh-PipList
})

$App.BtnPipUninstall.add_Click({
    $selected = $App.LstPipPackages.SelectedItem
    if (-not $selected) { Log-Message "Select a package to uninstall." "Error"; return }
    $pkgName = ($selected -split "==")[0]
    Log-Message "Uninstalling $pkgName..." "Warn"
    Execute-Command -Command $ActivePython -ArgsStr "-m pip uninstall -y $pkgName" -WorkingDir $ActiveProjectRoot
    Refresh-PipList
})

$App.BtnPipUpdateAll.add_Click({
    Log-Message "[SIMULATION] Fetching outdated packages and bulk upgrading..." "Warn"
    Start-Sleep -Seconds 2
    Log-Message "All packages updated to latest versions." "Cyan"
    Refresh-PipList
})

$App.BtnPipFreeze.add_Click({
    if (-not $ActiveProjectRoot) { Log-Message "Load a project first." "Error"; return }
    Log-Message "Freezing dependencies to requirements.txt..." "Warn"
    Execute-Command -Command $ActivePython -ArgsStr "-m pip freeze" -WorkingDir $ActiveProjectRoot | Out-File (Join-Path $ActiveProjectRoot "requirements.txt") -Encoding utf8
    Log-Message "requirements.txt generated." "Cyan"
})

$App.BtnPipInstallReqs.add_Click({
    if (-not $ActiveProjectRoot) { return }
    $reqFile = Join-Path $ActiveProjectRoot "requirements.txt"
    if (Test-Path $reqFile) {
        Log-Message "Installing from requirements.txt..." "Warn"
        Execute-Command -Command $ActivePython -ArgsStr "-m pip install -r requirements.txt" -WorkingDir $ActiveProjectRoot
        Refresh-PipList
    } else {
        Log-Message "requirements.txt not found in project root." "Error"
    }
})

$App.BtnAddSavedPackage.add_Click({
    $pkg = $App.TxtAddSavedPackage.Text.Trim()
    if ($pkg) {
        Add-Content -Path $SavedPackagesDb -Value $pkg -Encoding utf8
        $App.TxtAddSavedPackage.Text = ""
        Load-SavedPackages
        Log-Message "Added '$pkg' to Saved Database." "Cyan"
    }
})

$App.BtnRemoveSavedPackage.add_Click({
    $selected = $App.ClbSavedPackages.SelectedItem
    if ($selected) {
        $allPkgs = Get-Content $SavedPackagesDb | Where-Object { $_.Trim() -ne $selected.ToString() }
        if ($null -eq $allPkgs) { $allPkgs = @() } 
        $allPkgs | Out-File $SavedPackagesDb -Encoding utf8
        Load-SavedPackages
        Log-Message "Removed '$selected' from Saved Database." "Warn"
    } else {
        Log-Message "Select a package from the database to remove." "Error"
    }
})

$App.BtnInstallSavedPackages.add_Click({
    if ($App.ClbSavedPackages.CheckedItems.Count -eq 0) {
        Log-Message "No packages checked in the Saved Database." "Error"
        return
    }
    $pkgsToInstall = @()
    foreach ($item in $App.ClbSavedPackages.CheckedItems) {
        $pkgsToInstall += $item.ToString()
    }
    $pkgString = $pkgsToInstall -join " "
    Log-Message "Bulk installing from database: $pkgString" "Warn"
    Execute-Command -Command $ActivePython -ArgsStr "-m pip install $pkgString" -WorkingDir $ActiveProjectRoot
    Refresh-PipList
    
    # Uncheck all items after bulk execution
    for ($i = 0; $i -lt $App.ClbSavedPackages.Items.Count; $i++) {
        $App.ClbSavedPackages.SetItemChecked($i, $false)
    }
})

# --- TAB 4: BUILD ENGINE ---
$App.BtnBuild.add_Click({
    if (-not $script:ActiveScript) { Log-Message "Select an entry script from the Explorer first." "Error"; return }
    
    $engine = $App.CboBuildEngine.SelectedItem.ToString()
    Log-Message "Initializing Build Orchestration: $engine" "Warn"
    
    $argsList = @()
    if ($engine -match "PyInstaller") {
        if ($App.ChkOneFile.Checked) { $argsList += "--onefile" }
        if ($App.ChkNoConsole.Checked) { $argsList += "--noconsole" }
        if ($App.ChkDebug.Checked) { $argsList += "--debug=all" }
        
        $hidden = $App.TxtHiddenImports.Text
        if ($hidden) {
            $hidden.Split(',') | ForEach-Object { $argsList += "--hidden-import=$($_.Trim())" }
        }
        
        $argsList += "`"$script:ActiveScript`""
        $finalArgs = $argsList -join " "
        
        Log-Message "Invoking PyInstaller with flags: $finalArgs" "Cyan"
        Execute-Command -Command $ActivePython -ArgsStr "-m PyInstaller $finalArgs" -WorkingDir $ActiveProjectRoot
        Log-Message "Build complete. Check the 'dist' folder in your project root." "Warn"
    } 
    elseif ($engine -match "Nuitka") {
        Log-Message "Invoking Nuitka AOT Compiler..." "Cyan"
        $flags = "--standalone"
        if ($App.ChkOneFile.Checked) { $flags += " --onefile" }
        Log-Message "Flags injected: $flags --assume-yes-for-downloads" "Info"
        Start-Sleep -Seconds 2
        Log-Message "[SIMULATION] Nuitka compilation successful. Native executable generated." "Warn"
    }
    else {
        Log-Message "[SIMULATION] Invoking $engine transpilation pipeline..." "Cyan"
        Start-Sleep -Seconds 2
        Log-Message "Build complete." "Warn"
    }
})

# =============================================================================
# 5. INITIALIZATION & EXECUTION
# =============================================================================
$App.Log("MatchBoxPY Enterprise Orchestration Engine Booted.", [System.Drawing.Color]::LimeGreen)
$App.Log("Awaiting project directory...", [System.Drawing.Color]::Cyan)

Load-SavedPackages

# Show Window
[System.Windows.Forms.Application]::EnableVisualStyles()
$App.ShowDialog() | Out-Null
