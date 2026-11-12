; Ghillie (CAMO wallet) Installer for Windows
; Copyright (c) 2026, The CAMO Project
; Copyright (c) 2017-2024, The Monero Project
; See LICENSE
#define GuiVersion GetFileVersion("bin\ghillie.exe")

[Setup]
AppName=Ghillie
; For InnoSetup this is the property that uniquely identifies the application as such.
; Keep it stable over releases.
AppId={{7C3A5F0E-4B9D-4E2A-9C61-CA4D0E9A1F27}
AppVersion={#GuiVersion}
VersionInfoVersion={#GuiVersion}
DefaultDirName={commonpf}\Ghillie
DefaultGroupName=Ghillie
UninstallDisplayIcon={app}\ghillie.exe
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64 arm64
WizardSmallImageFile=WizardSmallImage.bmp
WizardImageFile=WelcomeImage.bmp
DisableWelcomePage=no
LicenseFile=LICENSE
AppPublisher=The CAMO Project
AppPublisherURL=https://camocoin.org
TimeStampsInUTC=yes
CompressionThreads=1

UsedUserAreasWarning=no
; The installer needs admin rights to put the program files somewhere protected, and it also writes per-user
; settings (registry, icons) for the installing user. See the original Monero installer for the background.

[Messages]
SetupWindowTitle=%1 {#GuiVersion} Installer

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
; Without localized versions of special forms, messages etc. of the installer, and without translated ReadMe's
; it probably does not make much sense to offer other install-time languages beside English
; Name: "fr"; MessagesFile: "compiler:Languages\French.isl"
; Name: "it"; MessagesFile: "compiler:Languages\Italian.isl"
; Name: "jp"; MessagesFile: "compiler:Languages\Japanese.isl"
; Name: "nl"; MessagesFile: "compiler:Languages\Dutch.isl"
; Name: "pt"; MessagesFile: "compiler:Languages\Portuguese.isl"

[Dirs]
Name: "{app}";

[Files]
; "ignoreversion": updates always replace every file, regardless of dates or version info. All files are private to Ghillie.

Source: {#file AddBackslash(SourcePath) + "ReadMe.htm"}; DestDir: "{app}"; DestName: "ReadMe.htm"; Flags: ignoreversion
Source: "FinishImage.bmp"; Flags: dontcopy
Source: "LICENSE"; DestDir: "{app}"; Flags: ignoreversion

; Ghillie wallet
Source: "bin\ghillie.exe"; DestDir: "{app}"; Flags: ignoreversion

; CAMO node (Ghillie starts it for you)
Source: "bin\camod.exe"; DestDir: "{app}"; Flags: ignoreversion

; CAMO node wrapped in a batch file that stops before the text window closes, to see any error messages
Source: "camo-daemon.bat"; DestDir: "{app}"; Flags: ignoreversion;

; Qt Quick 2D Renderer fallback for systems without 3D support
Source: "bin\start-low-graphics-mode.bat"; DestDir: "{app}"; Flags: ignoreversion

; Mesa, open-source OpenGL implementation; part of "low-level graphics" support
Source: "bin\opengl32sw.dll"; DestDir: "{app}"; Flags: ignoreversion


; Delete any files and directories that were installed by previous installer versions but are not
; needed anymore, thanks to the static linking of the GUI wallet exe - all those things are now
; neatly contained in that single exe file;
; InnoSetup does NOT automatically delete objects not present anymore in a new version.
; Deleting them is simpler and faster than forcing a full re-install.
[InstallDelete]
Type: filesandordirs; Name: "{app}\translations"
Type: files; Name: "{app}\Qt5*.dll"
Type: filesandordirs; Name: "{app}\Qt"
Type: filesandordirs; Name: "{app}\audio"
Type: filesandordirs; Name: "{app}\bearer"
Type: filesandordirs; Name: "{app}\platforms"
Type: filesandordirs; Name: "{app}\platforminputcontexts"
Type: filesandordirs; Name: "{app}\iconengines"
Type: filesandordirs; Name: "{app}\imageformats"
Type: filesandordirs; Name: "{app}\QtMultimedia"
Type: filesandordirs; Name: "{app}\mediaservice"
Type: filesandordirs; Name: "{app}\playlistformats"
Type: filesandordirs; Name: "{app}\QtGraphicalEffects"
Type: filesandordirs; Name: "{app}\private"
Type: filesandordirs; Name: "{app}\QtQml"
Type: filesandordirs; Name: "{app}\QtQuick"
Type: filesandordirs; Name: "{app}\QtQuick.2"
Type: filesandordirs; Name: "{app}\Material"
Type: filesandordirs; Name: "{app}\Universal"
Type: filesandordirs; Name: "{app}\scenegraph"
Type: filesandordirs; Name: "{app}\p2pool"
Type: files; Name: "{app}\D3Dcompiler_47.dll"
Type: files; Name: "{app}\libbz2-1.dll"
Type: files; Name: "{app}\libEGL.dll"
Type: files; Name: "{app}\libGLESV2.dll"
Type: files; Name: "{app}\libfreetype-6.dll"
Type: files; Name: "{app}\libgcc_s_seh-1.dll"
Type: files; Name: "{app}\libglib-2.0-0.dll"
Type: files; Name: "{app}\libgraphite2.dll"
Type: files; Name: "{app}\libharfbuzz-0.dll"
Type: files; Name: "{app}\libiconv-2.dll"
Type: files; Name: "{app}\libicudt??.dll"
Type: files; Name: "{app}\libicuin??.dll"
Type: files; Name: "{app}\libicuio??.dll"
Type: files; Name: "{app}\libicutu??.dll"
Type: files; Name: "{app}\libicuuc??.dll"
Type: files; Name: "{app}\libintl-8.dll"
Type: files; Name: "{app}\libjpeg-8.dll"
Type: files; Name: "{app}\liblcms2-2.dll"
Type: files; Name: "{app}\liblzma-5.dll"
Type: files; Name: "{app}\libmng-2.dll"
Type: files; Name: "{app}\libpcre-1.dll"
Type: files; Name: "{app}\libpcre16-0.dll"
Type: files; Name: "{app}\libpcre2-16-0.dll"
Type: files; Name: "{app}\libpng16-16.dll"
Type: files; Name: "{app}\libstdc++-6.dll"
Type: files; Name: "{app}\libtiff-5.dll"
Type: files; Name: "{app}\libwinpthread-1.dll"
Type: files; Name: "{app}\zlib1.dll"
Type: files; Name: "{app}\libhidapi-0.dll"
Type: files; Name: "{app}\libeay32.dll"
Type: files; Name: "{app}\ssleay32.dll"
Type: files; Name: "{app}\start-high-dpi.bat"
Type: files; Name: "{group}\Utilities\x (Check Blockchain Folder).lnk"

[UninstallDelete]

[Tasks]
Name: desktopicon; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:";


[Run]
Filename: "{app}\ReadMe.htm"; Description: "Show ReadMe"; Flags: postinstall shellexec skipifsilent

; DON'T offer to run the wallet right away, let the people read about initial blockchain download first in the ReadMe
; Filename: "{app}\ghillie.exe"; Description: "Run Ghillie now"; Flags: postinstall nowait skipifsilent


[Code]
var
  BlockChainDirPage: TInputDirWizardPage;
  blockChainDefaultDir: String;

procedure InitializeWizard;
var s: String;
    blockChainDir: String;
begin
  // Large image for the "Welcome" page, with page reconfigured
  WizardForm.WelcomeLabel1.Visible := false;
  WizardForm.WelcomeLabel2.Visible := false;
  WizardForm.WizardBitmapImage.Height := 300;
  WizardForm.WizardBitmapImage.Width := 500;

  // Image for the "Finnish" screen, in standard WizardBitmapImage size of 164 x 314
  ExtractTemporaryFile('FinishImage.bmp');
  WizardForm.WizardBitmapImage2.Bitmap.LoadFromFile(ExpandConstant('{tmp}\FinishImage.bmp'));

  // Additional wizard page for entering a special blockchain location
  blockChainDefaultDir := ExpandConstant('{commonappdata}\camo');
  s := 'The default folder to store the CAMO blockchain is ' + blockChainDefaultDir;
  s := s + '. The CAMO blockchain is small today but grows over time, so you may want to use a folder on a drive with plenty of free space.';
  s := s + ' If yes, specify that folder here.';

  BlockChainDirPage := CreateInputDirPage(wpSelectDir,
    'Select Blockchain Directory', 'Where should the blockchain be installed?',
    s,
    False, '');
  BlockChainDirPage.Add('');

  // Evaluate proposal for the blockchain location
  // In case of an update take the blockchain location from the actual setting in the registry
  RegQueryStringValue(HKEY_CURRENT_USER, 'Software\camo\ghillie', 'blockchainDataDir', blockChainDir);
  if blockChainDir = '' then begin
    blockChainDir := GetPreviousData('BlockChainDir', '');
  end;
  if blockChainDir = '' then begin
    // Unfortunately 'TInputDirWizardDirPage' does not allow empty field, so "propose" the CAMO default location
    blockChainDir := blockChainDefaultDir;
  end;
  BlockChainDirPage.Values[0] := blockChainDir;
end;

procedure RegisterPreviousData(PreviousDataKey: Integer);
begin
  // Store the selected folder for further reinstall/upgrade
  SetPreviousData(PreviousDataKey, 'BlockChainDir', BlockChainDirPage.Values[0]);
end;

function BlockChainDir(Param: String) : String;
// Directory of the blockchain
var s: String;
begin
  s := BlockChainDirPage.Values[0];
  Result := s;
  // No quotes for folder name with blanks as this is never used as part of a command line
end;

function BlockChainDirOrEmpty(Param: String) : String;
VAR s: String;
begin
  s := BlockChainDir('');
  if s = blockChainDefaultDir then begin
    // No need to add the default dir as setting
    s := '';
  end;
  Result := s;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo,
  MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
var s: String;
begin
  // Fill the 'Ready Memo' with the normal settings and the custom settings
  s := '';
  s := s + MemoDirInfo + NewLine + NewLine;

  s := s + 'Blockchain folder' + NewLine;
  s := s + Space + BlockChainDir('') + NewLine;

  Result := s;
end;

function DaemonLog(Param: String) : String;
// Full filename of the log of the daemon
begin
  Result := BlockChainDir('') + '\camo.log';
  // No quotes for filename with blanks as this is never used as part of a command line
end;

function DaemonFlags(Param: String): String;
// Flags to add to the shortcut to the daemon
var s: String;
begin
  s := BlockChainDir('');
  if s = blockChainDefaultDir then begin
    // No need to add the default dir as flags for the daemon
    s := '';
  end;
  if Pos(' ', s) > 0 then begin
    // Quotes needed for filename with blanks
    s := '"' + s + '"';
  end;
  if s <> '' then begin
    s := '--data-dir ' + s;
  end;
  Result := s;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var s: TArrayOfString;
begin
  if CurStep = ssPostInstall then begin
    // Re-build "camo-daemon.bat" according to actual install and blockchain directory used
    SetArrayLength(s, 3);
    s[0] := 'REM Run the CAMO node (camod) and keep the window open after it exits';
    s[1] := '"' + ExpandConstant('{app}\camod.exe') + '" ' + DaemonFlags('');
    s[2] := 'PAUSE';
    SaveStringsToFile(ExpandConstant('{app}\camo-daemon.bat'), s, false); 
  end;
end;

function InitializeUninstall(): Boolean;
var s: String;
begin
  s := 'Please note: Uninstall will not delete any downloaded blockchain. ';
  s := s + 'If you do not need it anymore you have to delete it manually.';
  s := s + #13#10#13#10 + 'Uninstall will not delete any wallets that you created either.';
  MsgBox(s, mbInformation, MB_OK);
  Result := true;
end;


[Icons]
; Icons in the "Ghillie" program group
Name: "{group}\Ghillie"; Filename: "{app}\ghillie.exe";
Name: "{group}\Uninstall Ghillie"; Filename: "{uninstallexe}"

; Sub-folder "Utilities" (Windows 10/11 show all icons on one level anyway)
Name: "{group}\Utilities\CAMO Node"; Filename: "{app}\camod.exe"; Parameters: {code:DaemonFlags}
Name: "{group}\Utilities\Read Me"; Filename: "{app}\ReadMe.htm"

; Troubleshooting icons, sorted last with "x"
Name: "{group}\Utilities\x (Check Blockchain Folder)"; Filename: "{win}\Explorer.exe"; Parameters: {code:BlockChainDir}
Name: "{group}\Utilities\x (Check Node Log)"; Filename: "Notepad"; Parameters: {code:DaemonLog}
Name: "{group}\Utilities\x (Check Default Wallet Folder)"; Filename: "{win}\Explorer.exe"; Parameters: """{userdocs}\Ghillie\wallets"""
Name: "{group}\Utilities\x (Check Ghillie Log Folder)"; Filename: "{win}\Explorer.exe"; Parameters: """{userappdata}\camo"""
Name: "{group}\Utilities\x (Try Node, Exit Confirm)"; Filename: "{app}\camo-daemon.bat"
Name: "{group}\Utilities\x (Try Ghillie Low Graphics Mode)"; Filename: "{app}\start-low-graphics-mode.bat"
Name: "{group}\Utilities\x (Try Stop Node)"; Filename: "Taskkill.exe"; Parameters: "/IM camod.exe /T /F"

; Desktop icon, optional via the "Tasks" section
Name: "{commondesktop}\Ghillie"; Filename: "{app}\ghillie.exe"; Tasks: desktopicon


[Registry]
; Ghillie's settings live under HKCU\Software\camo\ghillie (Qt organization "camo", application "ghillie").
; Store a custom blockchain folder there so Ghillie passes it to camod; the uninstaller cleans it up.
Root: HKCU; Subkey: "Software\camo"; Flags: uninsdeletekeyifempty
Root: HKCU; Subkey: "Software\camo\ghillie"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\camo\ghillie"; ValueType: string; ValueName: "blockchainDataDir"; ValueData: {code:BlockChainDirOrEmpty};

; Payment links: "camo:<address>?tx_amount=5.0" opens Ghillie with the link
Root: HKCR; Subkey: "camo"; ValueType: "string"; ValueData: "URL:CAMO Payment Protocol"; Flags: uninsdeletekey
Root: HKCR; Subkey: "camo"; ValueType: "string"; ValueName: "URL Protocol"; ValueData: ""
Root: HKCR; Subkey: "camo\DefaultIcon"; ValueType: "string"; ValueData: "{app}\ghillie.exe,0"
Root: HKCR; Subkey: "camo\shell\open\command"; ValueType: "string"; ValueData: """{app}\ghillie.exe"" ""%1"""

; Seed node links: "camoseed://a.b.c.d:port" hands a node address to Ghillie
Root: HKCR; Subkey: "camoseed"; ValueType: "string"; ValueData: "URL:CAMO Seed Node Protocol"; Flags: uninsdeletekey
Root: HKCR; Subkey: "camoseed"; ValueType: "string"; ValueName: "URL Protocol"; ValueData: ""
Root: HKCR; Subkey: "camoseed\DefaultIcon"; ValueType: "string"; ValueData: "{app}\ghillie.exe,0"
Root: HKCR; Subkey: "camoseed\shell\open\command"; ValueType: "string"; ValueData: """{app}\ghillie.exe"" ""%1"""
