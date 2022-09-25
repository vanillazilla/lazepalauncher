[Setup]
AppName=Lazepa Launcher
AppPublisher=Lazepa
UninstallDisplayName=Lazepa
AppVersion=${project.version}
AppSupportURL=https://lazepa.com/
DefaultDirName={localappdata}\Lazepa

; ~30 mb for the repo the launcher downloads
ExtraDiskSpaceRequired=30000000
ArchitecturesAllowed=x86 x64
PrivilegesRequired=lowest

WizardSmallImageFile=${basedir}/app_small.bmp
WizardImageFile=${basedir}/left.bmp
SetupIconFile=${basedir}/app.ico
UninstallDisplayIcon={app}\Lazepa.exe

Compression=lzma2
SolidCompression=yes

OutputDir=${basedir}
OutputBaseFilename=LazepaSetup32

[Tasks]
Name: DesktopIcon; Description: "Create a &desktop icon";

[Files]
Source: "${basedir}\app.ico"; DestDir: "{app}"
Source: "${basedir}\left.bmp"; DestDir: "{app}"
Source: "${basedir}\app_small.bmp"; DestDir: "{app}"
Source: "${basedir}\native-win32\Lazepa.exe"; DestDir: "{app}"
Source: "${basedir}\native-win32\Lazepa.jar"; DestDir: "{app}"
Source: "${basedir}\native\launcher_x86.dll"; DestDir: "{app}"
Source: "${basedir}\native-win32\config.json"; DestDir: "{app}"
Source: "${basedir}\native-win32\jre\*"; DestDir: "{app}\jre"; Flags: recursesubdirs

[Icons]
; start menu
Name: "{userprograms}\Lazepa"; Filename: "{app}\Lazepa.exe"
Name: "{userdesktop}\Lazepa"; Filename: "{app}\Lazepa.exe"; Tasks: DesktopIcon

[Run]
Filename: "{app}\Lazepa.exe"; Parameters: "--postinstall"; Flags: nowait
Filename: "{app}\Lazepa.exe"; Description: "&Open Lazepa"; Flags: postinstall skipifsilent nowait

[InstallDelete]
; Delete the old jvm so it doesn't try to load old stuff with the new vm and crash
Type: filesandordirs; Name: "{app}"

[UninstallDelete]
Type: filesandordirs; Name: "{%USERPROFILE}\.lazepa\repository2"