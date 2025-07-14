# Flutter 

## 버전관리 FVM(Flutter Version Management)

### FVM 설치(windows)

1. choch 설치
 
   1) .NET Framework 4.5 이상 확인

```shell
# PowerShell >
    (Get-ItemPropertyValue -LiteralPath 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release) -ge 378389

#    True -> 4.5 이상임

``` 

   2) Chocholatey 설치

```shell
# PowerShell >
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
``` 

2. FVM 설치
```shell
# PowerShell >
  ------------------------------------------------------------
    > choco install fvm
    ------------------------------------------------------------
    
    > fvm --version
    ------------------------------------------------------------
    3.2.1
    
    > dart pub global activate fvm
    ------------------------------------------------------------
    
    > fvm list
    ------------------------------------------------------------
    
    > fvm releases
    ------------------------------------------------------------
    
    > fvm install 3.32.1
    ------------------------------------------------------------
``` 

3. 프로젝트 FVM 설정

```shell
    VS Code 프로젝트 경로 - Terminal
    > fvm use 3.32.1
    ------------------------------------------------------------
    .fvm 폴더 생성
        - flutter_sdk
        - versions
        - version...
``` 
    
4. settings.json 설정
```json
    "dart.flutterSdkPaths": ["c:\\Users\\domsa\\fvm\\versions"],
    "dart.flutterSdkPath": "c:\\Users\\domsa\\fvm\\versions\\3.32.1",
    // Remove .fvm files from search
    "search.exclude": {
        "**/.fvm": true
    },
    // Remove from file watching
    "files.watcherExclude": {
        "**/.fvm": true
    },
```

5. .fvm 폴더 삭제

6. version 오류(참고)
```shell
    PS C:\Dev\work_flutter\fbc_flutter_v3\fbc_flutter_lib_r3> flutter pub get
    Resolving dependencies... 
    The current Dart SDK version is 3.6.2.

    Because fbc_flutter_lib_r3 requires SDK version ^3.8.1, version solving failed.


    You can try the following suggestion to make the pubspec resolve:
    * Try using the Flutter SDK version: 3.32.1.
    Failed to update packages.
    PS C:\Dev\work_flutter\fbc_flutter_v3\fbc_flutter_lib_r3> fvm flutter --version
    fatal: detected dubious ownership in repository at 'C:/Users/domsa/fvm/versions/3.32.1'
    'C:/Users/domsa/fvm/versions/3.32.1' is owned by:
            BUILTIN/Administrators (S-1-5-32-544)
    but the current user is:
            GUN-SURFACE/domsa (S-1-5-21-446179710-660180620-847281094-1001)
    To add an exception for this directory, call:

            git config --global --add safe.directory C:/Users/domsa/fvm/versions/3.32.1
    fatal: detected dubious ownership in repository at 'C:/Users/domsa/fvm/versions/3.32.1'
    'C:/Users/domsa/fvm/versions/3.32.1' is owned by:
            BUILTIN/Administrators (S-1-5-32-544)
    but the current user is:
            GUN-SURFACE/domsa (S-1-5-21-446179710-660180620-847281094-1001)
    To add an exception for this directory, call:

            git config --global --add safe.directory C:/Users/domsa/fvm/versions/3.32.1
    Error: Unable to determine engine version... 
    PS C:\Dev\work_flutter\fbc_flutter_v3\fbc_flutter_lib_r3> git config --global --add safe.directory C:/Users/domsa/fvm/versions/3.32.1
    PS C:\Dev\work_flutter\fbc_flutter_v3\fbc_flutter_lib_r3> fvm flutter --version
    Checking Dart SDK version... 
    Downloading Dart SDK from Flutter engine ... 
    Expanding downloaded archive with PowerShell...
    Building flutter tool... 
    Running pub upgrade... 
    Resolving dependencies... (3.1s)
    Downloading packages... (7.0s)
    Got dependencies.
    Command exited with code 1: git fetch --tags
    Standard error: fatal: bad object refs/remotes/origin/dataAssets
    error: https://github.com/flutter/flutter.git did not send all necessary objects

    Flutter 3.32.1 • channel stable • https://github.com/flutter/flutter.git
    Framework • revision b25305a883 (6 days ago) • 2025-05-29 10:40:06 -0700
    Engine • revision 1425e5e9ec (6 days ago) • 2025-05-28 14:26:27 -0700
    Tools • Dart 3.8.1 • DevTools 2.45.1
    PS C:\Dev\work_flutter\fbc_flutter_v3\fbc_flutter_lib_r3> fvm list
    Cache directory:  C:\Users\domsa\fvm\versions
    Directory Size: 817.32 MB

    ┌─────────┬─────────┬─────────────────┬──────────────┬──────────────┬────────┬───────┐
    │ Version │ Channel │ Flutter Version │ Dart Version │ Release Date │ Global │ Local │
    ├─────────┼─────────┼─────────────────┼──────────────┼──────────────┼────────┼───────┤
    │ 3.32.1  │ stable  │ 3.32.1          │ 3.8.1        │ May 29, 2025 │        │ ●     │
    ├─────────┼─────────┼─────────────────┼──────────────┼──────────────┼────────┼───────┤
    │ 3.27.4  │         │ Need setup      │              │              │        │       │
    └─────────┴─────────┴─────────────────┴──────────────┴──────────────┴────────┴───────┘

    PS C:\Dev\work_flutter\fbc_flutter_v3\fbc_flutter_lib_r3> fvm flutter --version
    Flutter 3.32.1 • channel stable • https://github.com/flutter/flutter.git
    Framework • revision b25305a883 (6 days ago) • 2025-05-29 10:40:06 -0700
    Engine • revision 1425e5e9ec (6 days ago) • 2025-05-28 14:26:27 -0700
    Tools • Dart 3.8.1 • DevTools 2.45.1
``` 




    
        
    
    


    