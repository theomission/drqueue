; Script generated by the HM NIS Edit Script Wizard.

!define ALL_USERS
!include nsis2io.nsh
!include WriteEnvStr.nsh
!include Service.nsh

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "drqueue"
!define PRODUCT_VERSION "beta"
!define PRODUCT_PUBLISHER "Jorge Daza and Vincent Dedun (Windows)"
!define PRODUCT_WEB_SITE "http://www.drqueue.org"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\ServicesController.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
#!define MUI_ICON "..\Resources\drqueue.ico"
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Language Selection Dialog Settings
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

; Welcome page
!define MUI_WELCOMEPAGE_TITLE "Welcome to drqueue installation"
!define MUI_WELCOMEPAGE_TEXT "Drqueue uses GTK+2, please download and install it from this website before you use drqueue : \r\nhttp://prdownloads.sourceforge.net/gladewin32/\ngtk-win32-2.4.14-rc3.exe\r\n\r\nYou also need DOTNET runtime, please download and install it from this website : \r\nhttp://www.microsoft.com/downloads/details.aspx?FamilyID\r\n=262d25e3-f589-4842-8157-034d1e7cf3a3&displaylang=en\r\n"
!insertmacro MUI_PAGE_WELCOME
; License page
!insertmacro MUI_PAGE_LICENSE "..\..\..\COPYING"
Page custom SetCustom ValidateCustom
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_TEXT_REBOOT "Drqueue needs a reboot of the computer to run, please reboot." 
#define MUI_FINISHPAGE_RUN "$INSTDIR\contrib\ServicesController.exe"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "Install.exe"
InstallDir "$PROGRAMFILES\drqueue"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails hide
ShowUnInstDetails show

var InstallationMaster
var InstallationSlave
var MasterName
var TempDir
var LogsDir

Function .onInit
#  !insertmacro MUI_LANGDLL_DISPLAY
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "installer.ini"
FunctionEnd

Function .onGUIEnd
  Delete "$TEMP\installer.ini"
FunctionEnd

ReserveFile "installer.ini"
ReserveFile "${NSISDIR}\Plugins\InstallOptions.dll"

LangString TEXT_IO_TITLE ${LANG_ENGLISH} "Install Settings"
LangString TEXT_IO_SUBTITLE ${LANG_ENGLISH} "Options"

Function SetCustom
  !insertmacro MUI_HEADER_TEXT "$(TEXT_IO_TITLE)" "$(TEXT_IO_SUBTITLE)"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "installer.ini"
FunctionEnd

Function ValidateCustom

  !insertmacro MUI_INSTALLOPTIONS_READ $R0 "installer.ini" "Field 1" "State"
  StrCmp $R0 "0" 0 +3
    push 0
    pop $InstallationSlave
  StrCmp $R0 "1" 0 +3
    push 1
    pop $InstallationSlave

  !insertmacro MUI_INSTALLOPTIONS_READ $R0 "installer.ini" "Field 2" "State"
  StrCmp $R0 "0" 0 +3
    push 0
    pop $InstallationMaster
  StrCmp $R0 "1" 0 +3
    push 1
    pop $InstallationMaster

  IntCmp $InstallationMaster 0 slave_selected
  ReadEnvStr $0 COMPUTERNAME
  # MessageBox MB_OK "Get $0 as master host name"
  push $0
  pop $MasterName
  Goto hostname_ok
  
slave_selected:
  !insertmacro MUI_INSTALLOPTIONS_READ $R0 "installer.ini" "Field 3" "State"
  #MessageBox MB_OK $R0
  push $R0
  pop $MasterName

hostname_ok:
  !insertmacro MUI_INSTALLOPTIONS_READ $R0 "installer.ini" "Field 4" "State"
  StrCmp $R0 "" 0 +3
    MessageBox MB_ICONEXCLAMATION|MB_OK "Please enter your temporary directory."
    Abort
  Push $R0
  Call Nsis2Io
  Pop $0
  StrCpy $0 $0 2
  ;StrCmp $0 "\\" 0 +3
  ;MessageBox MB_ICONEXCLAMATION|MB_OK "Temporary directory must be x:\ form, unc path are not supported (\\computer\path). Please enter your temporary directory again."
  ;Abort
  push $R0
  pop $TempDir

  !insertmacro MUI_INSTALLOPTIONS_READ $R0 "installer.ini" "Field 5" "State"
  StrCmp $R0 "" 0 +3
    MessageBox MB_ICONEXCLAMATION|MB_OK "Please enter your logs directory."
    Abort
  Push $R0
  Call Nsis2Io
  Pop $0
  StrCpy $0 $0 2
  ;StrCmp $0 "\\" 0 +3
  ;MessageBox MB_ICONEXCLAMATION|MB_OK "Logs directory must be x:\ form, unc path are not supported (\\computer\path). Please enter your logs directory again."
  ;Abort
  push $R0
  pop $LogsDir

FunctionEnd

Section "SectionPrincipale" SEC01
  SetShellVarContext all
  SetRebootFlag true  
  SetOutPath "$INSTDIR\bin"
  SetOverwrite try
  File "..\..\..\bin\*.exe"
  File "..\..\..\bin\*.dll"
  CreateDirectory "$SMPROGRAMS\drqueue"
  CreateShortCut "$SMPROGRAMS\drqueue\drqman.lnk" "$INSTDIR\bin\drqman.exe"
  SetOutPath "$INSTDIR\contrib"
  File "..\..\..\contrib\sendjob.blender.py"
  File "..\..\..\contrib\windows\service.exe"
  File "..\..\..\contrib\windows\servicesController.exe"
  CreateShortCut "$SMSTARTUP\drqueue-services.lnk" "$INSTDIR\contrib\servicesController.exe"
  CreateShortCut "$SMPROGRAMS\drqueue\drqueue-services.lnk" "$INSTDIR\contrib\servicesController.exe"
  CreateShortCut "$DESKTOP\drqueue-services.lnk" "$INSTDIR\contrib\servicesController.exe"
  File "..\..\..\contrib\windows\service-ipc.exe"
  File "..\..\..\contrib\windows\service-master.exe"
  SetOutPath "$INSTDIR\etc"
  File "..\..\..\etc\3delight.sg"
  File "..\..\..\etc\aqsis.sg"
  File "..\..\..\etc\blender.sg"
  File "..\..\..\etc\bmrt.sg"
  File "..\..\..\etc\drqman.conf"
  CreateShortCut "$SMPROGRAMS\drqueue\drqman.conf.lnk" "$INSTDIR\etc\drqman.conf"
  File "..\..\..\etc\drqman.rc"
  File "..\..\..\etc\drqman-windows.rc"
  File "..\..\..\etc\master.conf"
  File "..\..\..\etc\maya.sg"
  File "..\..\..\etc\mentalray.sg"
  File "..\..\..\etc\pixie.sg"
  File "..\..\..\etc\slave.conf"
  CreateShortCut "$SMPROGRAMS\drqueue\slave.conf.lnk" "$INSTDIR\etc\slave.conf"
  CreateDirectory "$INSTDIR\db"
  CreateDirectory "$INSTDIR\tmp"
  CreateDirectory "$INSTDIR\logs"

SectionEnd

Section -AdditionalIcons
  SetOutPath $INSTDIR
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  CreateShortCut "$SMPROGRAMS\drqueue\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
  CreateShortCut "$SMPROGRAMS\drqueue\Uninstall.lnk" "$INSTDIR\uninst.exe"
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\contrib\servicesController.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\contrib\servicesController.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  #add variables
  Push "DRQUEUE_ROOT"
  Push "$INSTDIR"
  Call WriteEnvStr
  Push "DRQUEUE_BIN"
  Push "$INSTDIR\bin"
  Call WriteEnvStr
  Push "DRQUEUE_TMP"
  ;Push "$INSTDIR\tmp"
  Push "$TempDir"
  Call WriteEnvStr
  Push "DRQUEUE_LOGS"
  ;Push "$INSTDIR\logs"
  Push "$LogsDir"
  Call WriteEnvStr
  Push "DRQUEUE_DB"
  Push "$INSTDIR\db"
  Call WriteEnvStr
  Push "DRQUEUE_ETC"
  Push "$INSTDIR\etc"
  Call WriteEnvStr
  Push "DRQUEUE_MASTER"
  Push "$MasterName"
  Call WriteEnvStr
  Push "DRQUEUE_ISSLAVE"
  Push "$InstallationSlave"
  Call WriteEnvStr
  Push "CYGWIN"
  Push "server"
  Call WriteEnvStr
  
  !insertmacro SERVICE "delete" "drqueue_master" ""
  !insertmacro SERVICE "delete" "drqueue_ipc" ""

  nsExec::Exec '$INSTDIR\contrib\service.exe i drqueue_ipc "$INSTDIR\contrib\service-ipc.exe" "Drqueue IPC Service" a'
  !insertmacro SERVICE "start" "drqueue_ipc" ""

  IntCmp $InstallationMaster 1 0 skip_master
  DetailPrint "Installing master"
   #MessageBox MB_OK '$INSTDIR\contrib\service.exe i drqueue_master "$INSTDIR\contrib\service-master.exe" "Drqueue Master Service" a drqueue_ipc'
   nsExec::Exec '$INSTDIR\contrib\service.exe i drqueue_master "$INSTDIR\contrib\service-master.exe" "Drqueue Master Service" a drqueue_ipc'
   !insertmacro SERVICE "start" "drqueue_master" ""
  GoTo end_master
skip_master:
  nsExec::Exec '$INSTDIR\contrib\service.exe i drqueue_master "$INSTDIR\contrib\service-master.exe" "Drqueue Master Service" m drqueue_ipc'
end_master:

  Delete "$INSTDIR\contrib\service.exe"

SectionEnd


Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) has been removed from your computer."
FunctionEnd

Function un.onInit
!insertmacro MUI_UNGETLANGUAGE
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure to completly uninstall $(^Name) ?" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  SetShellVarContext all
  Delete "$INSTDIR\${PRODUCT_NAME}.url"
  Delete "$INSTDIR\uninst.exe"
  Delete "$INSTDIR\etc\slave.conf"
  Delete "$INSTDIR\etc\pixie.sg"
  Delete "$INSTDIR\etc\mentalray.sg"
  Delete "$INSTDIR\etc\maya.sg"
  Delete "$INSTDIR\etc\master.conf"
  Delete "$INSTDIR\etc\drqman.rc"
  Delete "$INSTDIR\etc\drqman-windows.rc"
  Delete "$INSTDIR\etc\drqman.conf"
  Delete "$INSTDIR\etc\bmrt.sg"
  Delete "$INSTDIR\etc\blender.sg"
  Delete "$INSTDIR\etc\aqsis.sg"
  Delete "$INSTDIR\etc\3delight.sg~"
  Delete "$INSTDIR\etc\3delight.sg"
  Delete "$INSTDIR\contrib\sendjob.blender.py"
  Delete "$INSTDIR\contrib\service-ipc.exe"
  Delete "$INSTDIR\contrib\service-master.exe"
  Delete "$INSTDIR\contrib\servicesController.exe"
  Delete "$INSTDIR\bin\*.exe"
  Delete "$INSTDIR\bin\*.dll"

  Delete "$SMPROGRAMS\drqueue\Uninstall.lnk"
  Delete "$SMPROGRAMS\drqueue\Website.lnk"
  Delete "$SMPROGRAMS\drqueue\slave.conf.lnk"
  Delete "$SMPROGRAMS\drqueue\drqman.conf.lnk"
  Delete "$SMPROGRAMS\drqueue\drqman.lnk"
  Delete "$SMPROGRAMS\drqueue\drqueue-services.lnk"
  Delete "$DESKTOP\drqueue-services.lnk"
  Delete "$SMSTARTUP\drqueue-services.lnk"

  RMDir "$SMPROGRAMS\drqueue"
  RMDir "$INSTDIR\etc"
  RMDir "$INSTDIR\contrib"
  RMDir "$INSTDIR\bin"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
  
  # remove the variable
  Push "DRQUEUE_ROOT"
  Call un.DeleteEnvStr
  Push "DRQUEUE_BIN"
  Call un.DeleteEnvStr
  Push "DRQUEUE_TMP"
  Call un.DeleteEnvStr
  Push "DRQUEUE_LOGS"
  Call un.DeleteEnvStr
  Push "DRQUEUE_DB"
  Call un.DeleteEnvStr
  Push "DRQUEUE_ETC"
  Call un.DeleteEnvStr
  Push "DRQUEUE_MASTER"
  Call un.DeleteEnvStr
  Push "DRQUEUE_ISSLAVE"
  Call un.DeleteEnvStr
  Push "CYGWIN"
  Call un.DeleteEnvStr

  !undef UN
  !define UN "un."
  !insertmacro SERVICE "stop" "drqueue_master" ""
  !insertmacro SERVICE "stop" "drqueue_ipc" ""
  !insertmacro SERVICE "delete" "drqueue_master" ""
  !insertmacro SERVICE "delete" "drqueue_ipc" ""

SectionEnd
