#define MyAppName "FE Player - Multimedia Organizer"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "FE Player"
#define MyAppURL "https://github.com/pabeledp/FEPlayer"
#define MyAppExeName "fe_player.exe"

[Setup]
AppId={{D944FFBC-4E0B-442A-8F66-CCDD95D5A57D}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
OutputDir=windows_installer_output
OutputBaseFilename=FEPlayer-Windows-Setup
SetupIconFile=windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
ChangesAssociations=yes
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "associatefiles"; Description: "Register FE Player as default video & audio handler (Open With)"; GroupDescription: "File Associations:"

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Registry]
; Open With Applications registration for Windows File Explorer
Root: HKA; Subkey: "Software\Classes\Applications\fe_player.exe"; ValueType: string; ValueName: ""; ValueData: "FE Player - Multimedia Organizer"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\fe_player.exe\SupportedTypes"; ValueType: string; ValueName: ".mp4"; ValueData: ""
Root: HKA; Subkey: "Software\Classes\Applications\fe_player.exe\SupportedTypes"; ValueType: string; ValueName: ".mkv"; ValueData: ""
Root: HKA; Subkey: "Software\Classes\Applications\fe_player.exe\SupportedTypes"; ValueType: string; ValueName: ".avi"; ValueData: ""
Root: HKA; Subkey: "Software\Classes\Applications\fe_player.exe\SupportedTypes"; ValueType: string; ValueName: ".mov"; ValueData: ""
Root: HKA; Subkey: "Software\Classes\Applications\fe_player.exe\SupportedTypes"; ValueType: string; ValueName: ".webm"; ValueData: ""
Root: HKA; Subkey: "Software\Classes\Applications\fe_player.exe\SupportedTypes"; ValueType: string; ValueName: ".flv"; ValueData: ""
Root: HKA; Subkey: "Software\Classes\Applications\fe_player.exe\SupportedTypes"; ValueType: string; ValueName: ".wmv"; ValueData: ""
Root: HKA; Subkey: "Software\Classes\Applications\fe_player.exe\SupportedTypes"; ValueType: string; ValueName: ".m4v"; ValueData: ""
Root: HKA; Subkey: "Software\Classes\Applications\fe_player.exe\SupportedTypes"; ValueType: string; ValueName: ".mp3"; ValueData: ""
Root: HKA; Subkey: "Software\Classes\Applications\fe_player.exe\SupportedTypes"; ValueType: string; ValueName: ".wav"; ValueData: ""
Root: HKA; Subkey: "Software\Classes\Applications\fe_player.exe\SupportedTypes"; ValueType: string; ValueName: ".flac"; ValueData: ""
Root: HKA; Subkey: "Software\Classes\Applications\fe_player.exe\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\fe_player.exe"" ""%1"""

; File extension OpenWithProgids registration
Root: HKA; Subkey: "Software\Classes\.mp4\OpenWithProgids"; ValueType: string; ValueName: "FEPlayer.Video"; ValueData: ""; Flags: uninsdeletevalue; Tasks: associatefiles
Root: HKA; Subkey: "Software\Classes\.mkv\OpenWithProgids"; ValueType: string; ValueName: "FEPlayer.Video"; ValueData: ""; Flags: uninsdeletevalue; Tasks: associatefiles
Root: HKA; Subkey: "Software\Classes\.avi\OpenWithProgids"; ValueType: string; ValueName: "FEPlayer.Video"; ValueData: ""; Flags: uninsdeletevalue; Tasks: associatefiles
Root: HKA; Subkey: "Software\Classes\.mov\OpenWithProgids"; ValueType: string; ValueName: "FEPlayer.Video"; ValueData: ""; Flags: uninsdeletevalue; Tasks: associatefiles
Root: HKA; Subkey: "Software\Classes\.webm\OpenWithProgids"; ValueType: string; ValueName: "FEPlayer.Video"; ValueData: ""; Flags: uninsdeletevalue; Tasks: associatefiles
Root: HKA; Subkey: "Software\Classes\.flv\OpenWithProgids"; ValueType: string; ValueName: "FEPlayer.Video"; ValueData: ""; Flags: uninsdeletevalue; Tasks: associatefiles
Root: HKA; Subkey: "Software\Classes\.wmv\OpenWithProgids"; ValueType: string; ValueName: "FEPlayer.Video"; ValueData: ""; Flags: uninsdeletevalue; Tasks: associatefiles
Root: HKA; Subkey: "Software\Classes\.m4v\OpenWithProgids"; ValueType: string; ValueName: "FEPlayer.Video"; ValueData: ""; Flags: uninsdeletevalue; Tasks: associatefiles
Root: HKA; Subkey: "Software\Classes\.mp3\OpenWithProgids"; ValueType: string; ValueName: "FEPlayer.Audio"; ValueData: ""; Flags: uninsdeletevalue; Tasks: associatefiles
Root: HKA; Subkey: "Software\Classes\.wav\OpenWithProgids"; ValueType: string; ValueName: "FEPlayer.Audio"; ValueData: ""; Flags: uninsdeletevalue; Tasks: associatefiles
Root: HKA; Subkey: "Software\Classes\.flac\OpenWithProgids"; ValueType: string; ValueName: "FEPlayer.Audio"; ValueData: ""; Flags: uninsdeletevalue; Tasks: associatefiles

; ProgID FEPlayer.Video & FEPlayer.Audio definition
Root: HKA; Subkey: "Software\Classes\FEPlayer.Video"; ValueType: string; ValueName: ""; ValueData: "FE Player Media File"; Flags: uninsdeletekey; Tasks: associatefiles
Root: HKA; Subkey: "Software\Classes\FEPlayer.Video\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\fe_player.exe,0"; Tasks: associatefiles
Root: HKA; Subkey: "Software\Classes\FEPlayer.Video\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\fe_player.exe"" ""%1"""; Tasks: associatefiles

Root: HKA; Subkey: "Software\Classes\FEPlayer.Audio"; ValueType: string; ValueName: ""; ValueData: "FE Player Audio File"; Flags: uninsdeletekey; Tasks: associatefiles
Root: HKA; Subkey: "Software\Classes\FEPlayer.Audio\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\fe_player.exe,0"; Tasks: associatefiles
Root: HKA; Subkey: "Software\Classes\FEPlayer.Audio\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\fe_player.exe"" ""%1"""; Tasks: associatefiles

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
