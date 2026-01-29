using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# Shell 集成
# https://learn.microsoft.com/zh-cn/windows/terminal/tutorials/shell-integration
$Global:__LastHistoryId = -1

function Global:__Terminal-Get-LastExitCode {
  if ($? -eq $True) {
    return 0
  }
  $LastHistoryEntry = $(Get-History -Count 1)
  $IsPowerShellError = $Error[0].InvocationInfo.HistoryId -eq $LastHistoryEntry.Id
  if ($IsPowerShellError) {
    return -1
  }
  return $LastExitCode
}

function prompt {

# First, emit a mark for the _end_ of the previous command.

$gle = $(__Terminal-Get-LastExitCode);
  $LastHistoryEntry = $(Get-History -Count 1)
  # Skip finishing the command if the first command has not yet started
  if ($Global:__LastHistoryId -ne -1) {
    if ($LastHistoryEntry.Id -eq $Global:__LastHistoryId) {
      # Don't provide a command line or exit code if there was no history entry (eg. ctrl+c, enter on no command)
      $out += "`e]133;D`a"
    } else {
      $out += "`e]133;D;$gle`a"
    }
  }

$loc = $($executionContext.SessionState.Path.CurrentLocation);
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

# Prompt started
  $out += "`e]133;A$([char]07)";

# CWD
  $out += "`e]9;9;`"$loc`"$([char]07)";

# (your prompt here)
  # https://gist.github.com/skarllot/2648493
  $out += $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) ? "`e[31;1m$env:USERNAME@$($env:COMPUTERNAME.ToLower()) `e[34;1m$($loc.ToString().StartsWith($env:USERPROFILE) ? $loc.ToString().Replace($env:USERPROFILE, "~") : $loc) `#$('>' * ($nestedPromptLevel + 0))`e[0m " : "`e[32;1m$env:USERNAME@$($env:COMPUTERNAME.ToLower()) `e[34;1m$($loc.ToString().StartsWith($env:USERPROFILE) ? $loc.ToString().Replace($env:USERPROFILE, "~") : $loc) `$$('>' * ($nestedPromptLevel + 0))`e[0m ";
  # $out += "PS $loc$('>' * ($nestedPromptLevel + 1)) ";

# Prompt ended, Command started
  $out += "`e]133;B$([char]07)";

$Global:__LastHistoryId = $LastHistoryEntry.Id

return $out
}
# 不好用，算了

if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
    $MSYSTEM = "clangarm64"
    $MUCRT = "ucrt64"
}
if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
    $MSYSTEM = "clang64"
}

Set-PSReadLineOption -EditMode Emacs
$env:LANG="zh_CN.UTF-8"
$tmp_path = $env:Path
if ($env:Path -match ";$") {
    $env:Path = $env:Path + "C:\msys64\${MSYSTEM}\bin;C:\msys64\usr\bin" + ";"
}
else {
    $env:Path = $env:Path + ";C:\msys64\${MSYSTEM}\bin;C:\msys64\usr\bin" + ";"
}
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
$env:Path = $tmp_path
Set-Alias which "where.exe"
Set-Alias grep Select-String
Set-Alias gitui C:\msys64\${MSYSTEM}\bin\gitui.exe
Set-Alias curl C:\msys64\${MSYSTEM}\bin\curl.exe
Set-Alias hx C:\msys64\${MSYSTEM}\bin\hx.exe
Set-Alias git C:\msys64\${MSYSTEM}\bin\git.exe
Set-Alias wasm-objdump C:\msys64\${MSYSTEM}\bin\wasm-objdump.exe
Set-Alias fortune C:\msys64\${MSYSTEM}\bin\fortune.exe
Set-Alias ntldd C:\msys64\${MSYSTEM}\bin\ntldd.exe
Set-Alias python C:\msys64\${MSYSTEM}\bin\python.exe
function weather {
    Invoke-RestMethod "https://v2d.wttr.in?lang=zh"
}
function objdump {
    & C:\msys64\${MSYSTEM}\bin\llvm-objdump.exe -M intel $args;
}
function clang-path {
    if ($env:Path -match ";$") {
        $env:Path = $env:Path + "C:\msys64\${MSYSTEM}\bin;C:\msys64\usr\bin" + ";"
    }
    else {
        $env:Path = $env:Path + ";C:\msys64\${MSYSTEM}\bin;C:\msys64\usr\bin" + ";"
    }
}
function gcc-path {
    if ($env:Path -match ";$") {
        $env:Path = $env:Path + "C:\msys64\ucrt64\bin;C:\msys64\usr\bin" + ";"
    }
    else {
        $env:Path = $env:Path + ";C:\msys64\ucrt64\bin;C:\msys64\usr\bin" + ";"
    }
}
#Set-Alias emacs "C:\msys64\ucrt64\bin\runemacs.exe"
function emacs {
    if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
        if ($args -contains "-nw") {
            C:\msys64\clangarm64\bin\emacs.exe --dump-file "${env:APPDATA}/.emacs.d/emacs.pdmp" $args;
        }
        else {
            C:\msys64\clangarm64\bin\runemacs.exe --dump-file "${env:APPDATA}/.emacs.d/emacs.pdmp" $args;
        }
    }
    if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
        if ($args -contains "-nw") {
            C:\msys64\ucrt64\bin\emacs.exe --dump-file "${env:APPDATA}/.emacs.d/emacs.pdmp" $args;
        }
        else {
            C:\msys64\ucrt64\bin\runemacs.exe --dump-file "${env:APPDATA}/.emacs.d/emacs.pdmp" $args;
        }
    }
}
# function emacs-x { C:\msys64\ucrt64\bin\runemacs.exe $args; }
function u { winget update $args; }
# $env:HTTPS_PROXY = "http://127.0.0.1:7890"
$mihomo = "C:\Users\hash\OneDrive\应用\clash\mihomo.yaml"
$land = "C:\Users\hash\Desktop\land\hashland"
$post = "C:\Users\hash\Desktop\post-test"
$iter = "C:\Users\hash\Desktop\0b3e7e329d14129d12b7667bd5a922ee"

# https://docs.rs/cc/latest/cc/#external-configuration-via-environment-variables
# 理论上可以添加 target 三元组，但是懒
#${env:AR_x86_64-pc-windows-gnullvm} = "C:\msys64\clang64\bin\llvm-ar.exe"
#${env:CC_x86_64-pc-windows-gnullvm} = "C:\msys64\clang64\bin\clang.exe"
#${env:CFLAGS_x86_64-pc-windows-gnullvm} = "-march=x86-64-v3 -fsanitize=cfi -fvisibility=hidden -flto=thin"
#${env:CXX_x86_64-pc-windows-gnullvm} = "C:\msys64\clang64\bin\clang++.exe"
#${env:CXXFLAGS_x86_64-pc-windows-gnullvm} = "-march=x86-64-v3 -fsanitize=cfi -fvisibility=hidden -flto=thin"
# $env:CC_ENABLE_DEBUG_OUTPUT = "1"

#Import-Module "C:\Users\90895\scoop\modules\scoop-completion"
#python "C:\Users\90895\OneDrive\项目\hitokoto\main.py"



# Import-Module posh-git

# https://devblogs.microsoft.com/commandline/winget-commandnotfound/
Import-Module Microsoft.WinGet.CommandNotFound

# https://learn.microsoft.com/zh-cn/windows/package-manager/winget/tab-completion
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

# rclone completion powershell | Out-String | Invoke-Expression
# sing-box completion powershell | Out-String | Invoke-Expression
# deno completions powershell | Out-String | Invoke-Expression
# moon shell-completion --shell powershell | Out-String | Invoke-Expression


Register-ArgumentCompleter -Native -CommandName 'rustup' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $commandElements = $commandAst.CommandElements
    $command = @(
        'rustup'
        for ($i = 1; $i -lt $commandElements.Count; $i++) {
            $element = $commandElements[$i]
            if ($element -isnot [StringConstantExpressionAst] -or
                $element.StringConstantType -ne [StringConstantType]::BareWord -or
                $element.Value.StartsWith('-') -or
                $element.Value -eq $wordToComplete) {
                break
        }
        $element.Value
    }) -join ';'

    $completions = @(switch ($command) {
        'rustup' {
            [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Set log level to ''DEBUG'' if ''RUSTUP_LOG'' is unset')
            [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Set log level to ''DEBUG'' if ''RUSTUP_LOG'' is unset')
            [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Disable progress output, set log level to ''WARN'' if ''RUSTUP_LOG'' is unset')
            [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Disable progress output, set log level to ''WARN'' if ''RUSTUP_LOG'' is unset')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('install', 'install', [CompletionResultType]::ParameterValue, 'Install or update the given toolchains, or by default the active toolchain')
            [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstall the given toolchains')
            [CompletionResult]::new('dump-testament', 'dump-testament', [CompletionResultType]::ParameterValue, 'Dump information about the build')
            [CompletionResult]::new('toolchain', 'toolchain', [CompletionResultType]::ParameterValue, 'Install, uninstall, or list toolchains')
            [CompletionResult]::new('default', 'default', [CompletionResultType]::ParameterValue, 'Set the default toolchain')
            [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Show the active and installed toolchains or profiles')
            [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Update Rust toolchains and rustup')
            [CompletionResult]::new('check', 'check', [CompletionResultType]::ParameterValue, 'Check for updates to Rust toolchains and rustup')
            [CompletionResult]::new('target', 'target', [CompletionResultType]::ParameterValue, 'Modify a toolchain''s supported targets')
            [CompletionResult]::new('component', 'component', [CompletionResultType]::ParameterValue, 'Modify a toolchain''s installed components')
            [CompletionResult]::new('override', 'override', [CompletionResultType]::ParameterValue, 'Modify toolchain overrides for directories')
            [CompletionResult]::new('run', 'run', [CompletionResultType]::ParameterValue, 'Run a command with an environment configured for a given toolchain')
            [CompletionResult]::new('which', 'which', [CompletionResultType]::ParameterValue, 'Display which binary will be run for a given command')
            [CompletionResult]::new('doc', 'doc', [CompletionResultType]::ParameterValue, 'Open the documentation for the current toolchain')
            [CompletionResult]::new('man', 'man', [CompletionResultType]::ParameterValue, 'View the man page for a given command')
            [CompletionResult]::new('self', 'self', [CompletionResultType]::ParameterValue, 'Modify the rustup installation')
            [CompletionResult]::new('set', 'set', [CompletionResultType]::ParameterValue, 'Alter rustup settings')
            [CompletionResult]::new('completions', 'completions', [CompletionResultType]::ParameterValue, 'Generate tab-completion scripts for your shell')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'rustup;install' {
            [CompletionResult]::new('--profile', '--profile', [CompletionResultType]::ParameterName, 'profile')
            [CompletionResult]::new('-c', '-c', [CompletionResultType]::ParameterName, 'Comma-separated list of components to be added on installation')
            [CompletionResult]::new('--component', '--component', [CompletionResultType]::ParameterName, 'Comma-separated list of components to be added on installation')
            [CompletionResult]::new('-t', '-t', [CompletionResultType]::ParameterName, 'Comma-separated list of targets to be added on installation')
            [CompletionResult]::new('--target', '--target', [CompletionResultType]::ParameterName, 'Comma-separated list of targets to be added on installation')
            [CompletionResult]::new('--no-self-update', '--no-self-update', [CompletionResultType]::ParameterName, 'Don''t perform self update when running the `rustup toolchain install` command')
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Force an update, even if some components are missing')
            [CompletionResult]::new('--allow-downgrade', '--allow-downgrade', [CompletionResultType]::ParameterName, 'Allow rustup to downgrade the toolchain to satisfy your component choice')
            [CompletionResult]::new('--force-non-host', '--force-non-host', [CompletionResultType]::ParameterName, 'Install toolchains that require an emulator. See https://github.com/rust-lang/rustup/wiki/Non-host-toolchains')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;uninstall' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;dump-testament' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;toolchain' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List installed toolchains')
            [CompletionResult]::new('install', 'install', [CompletionResultType]::ParameterValue, 'Install or update the given toolchains, or by default the active toolchain')
            [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstall the given toolchains')
            [CompletionResult]::new('link', 'link', [CompletionResultType]::ParameterValue, 'Create a custom toolchain by symlinking to a directory')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'rustup;toolchain;list' {
            [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Enable verbose output with toolchain information')
            [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Enable verbose output with toolchain information')
            [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Force the output to be a single column')
            [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Force the output to be a single column')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;toolchain;install' {
            [CompletionResult]::new('--profile', '--profile', [CompletionResultType]::ParameterName, 'profile')
            [CompletionResult]::new('-c', '-c', [CompletionResultType]::ParameterName, 'Comma-separated list of components to be added on installation')
            [CompletionResult]::new('--component', '--component', [CompletionResultType]::ParameterName, 'Comma-separated list of components to be added on installation')
            [CompletionResult]::new('-t', '-t', [CompletionResultType]::ParameterName, 'Comma-separated list of targets to be added on installation')
            [CompletionResult]::new('--target', '--target', [CompletionResultType]::ParameterName, 'Comma-separated list of targets to be added on installation')
            [CompletionResult]::new('--no-self-update', '--no-self-update', [CompletionResultType]::ParameterName, 'Don''t perform self update when running the `rustup toolchain install` command')
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Force an update, even if some components are missing')
            [CompletionResult]::new('--allow-downgrade', '--allow-downgrade', [CompletionResultType]::ParameterName, 'Allow rustup to downgrade the toolchain to satisfy your component choice')
            [CompletionResult]::new('--force-non-host', '--force-non-host', [CompletionResultType]::ParameterName, 'Install toolchains that require an emulator. See https://github.com/rust-lang/rustup/wiki/Non-host-toolchains')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;toolchain;uninstall' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;toolchain;link' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;toolchain;help' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List installed toolchains')
            [CompletionResult]::new('install', 'install', [CompletionResultType]::ParameterValue, 'Install or update the given toolchains, or by default the active toolchain')
            [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstall the given toolchains')
            [CompletionResult]::new('link', 'link', [CompletionResultType]::ParameterValue, 'Create a custom toolchain by symlinking to a directory')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'rustup;toolchain;help;list' {
            break
        }
        'rustup;toolchain;help;install' {
            break
        }
        'rustup;toolchain;help;uninstall' {
            break
        }
        'rustup;toolchain;help;link' {
            break
        }
        'rustup;toolchain;help;help' {
            break
        }
        'rustup;default' {
            [CompletionResult]::new('--force-non-host', '--force-non-host', [CompletionResultType]::ParameterName, 'Install toolchains that require an emulator. See https://github.com/rust-lang/rustup/wiki/Non-host-toolchains')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;show' {
            [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Enable verbose output with rustc information for all installed toolchains')
            [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Enable verbose output with rustc information for all installed toolchains')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('active-toolchain', 'active-toolchain', [CompletionResultType]::ParameterValue, 'Show the active toolchain')
            [CompletionResult]::new('home', 'home', [CompletionResultType]::ParameterValue, 'Display the computed value of RUSTUP_HOME')
            [CompletionResult]::new('profile', 'profile', [CompletionResultType]::ParameterValue, 'Show the default profile used for the `rustup install` command')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'rustup;show;active-toolchain' {
            [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Enable verbose output with rustc information')
            [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Enable verbose output with rustc information')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;show;home' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;show;profile' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;show;help' {
            [CompletionResult]::new('active-toolchain', 'active-toolchain', [CompletionResultType]::ParameterValue, 'Show the active toolchain')
            [CompletionResult]::new('home', 'home', [CompletionResultType]::ParameterValue, 'Display the computed value of RUSTUP_HOME')
            [CompletionResult]::new('profile', 'profile', [CompletionResultType]::ParameterValue, 'Show the default profile used for the `rustup install` command')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'rustup;show;help;active-toolchain' {
            break
        }
        'rustup;show;help;home' {
            break
        }
        'rustup;show;help;profile' {
            break
        }
        'rustup;show;help;help' {
            break
        }
        'rustup;update' {
            [CompletionResult]::new('--no-self-update', '--no-self-update', [CompletionResultType]::ParameterName, 'Don''t perform self update when running the `rustup update` command')
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Force an update, even if some components are missing')
            [CompletionResult]::new('--force-non-host', '--force-non-host', [CompletionResultType]::ParameterName, 'Install toolchains that require an emulator. See https://github.com/rust-lang/rustup/wiki/Non-host-toolchains')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;check' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;target' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List installed and available targets')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add a target to a Rust toolchain')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove a target from a Rust toolchain')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'rustup;target;list' {
            [CompletionResult]::new('--toolchain', '--toolchain', [CompletionResultType]::ParameterName, 'Toolchain name, such as ''stable'', ''nightly'', or ''1.8.0''. For more information see `rustup help toolchain`')
            [CompletionResult]::new('--installed', '--installed', [CompletionResultType]::ParameterName, 'List only installed targets')
            [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Force the output to be a single column')
            [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Force the output to be a single column')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;target;add' {
            [CompletionResult]::new('--toolchain', '--toolchain', [CompletionResultType]::ParameterName, 'Toolchain name, such as ''stable'', ''nightly'', or ''1.8.0''. For more information see `rustup help toolchain`')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;target;remove' {
            [CompletionResult]::new('--toolchain', '--toolchain', [CompletionResultType]::ParameterName, 'Toolchain name, such as ''stable'', ''nightly'', or ''1.8.0''. For more information see `rustup help toolchain`')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;target;help' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List installed and available targets')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add a target to a Rust toolchain')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove a target from a Rust toolchain')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'rustup;target;help;list' {
            break
        }
        'rustup;target;help;add' {
            break
        }
        'rustup;target;help;remove' {
            break
        }
        'rustup;target;help;help' {
            break
        }
        'rustup;component' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List installed and available components')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add a component to a Rust toolchain')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove a component from a Rust toolchain')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'rustup;component;list' {
            [CompletionResult]::new('--toolchain', '--toolchain', [CompletionResultType]::ParameterName, 'Toolchain name, such as ''stable'', ''nightly'', or ''1.8.0''. For more information see `rustup help toolchain`')
            [CompletionResult]::new('--installed', '--installed', [CompletionResultType]::ParameterName, 'List only installed components')
            [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Force the output to be a single column')
            [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Force the output to be a single column')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;component;add' {
            [CompletionResult]::new('--toolchain', '--toolchain', [CompletionResultType]::ParameterName, 'Toolchain name, such as ''stable'', ''nightly'', or ''1.8.0''. For more information see `rustup help toolchain`')
            [CompletionResult]::new('--target', '--target', [CompletionResultType]::ParameterName, 'target')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;component;remove' {
            [CompletionResult]::new('--toolchain', '--toolchain', [CompletionResultType]::ParameterName, 'Toolchain name, such as ''stable'', ''nightly'', or ''1.8.0''. For more information see `rustup help toolchain`')
            [CompletionResult]::new('--target', '--target', [CompletionResultType]::ParameterName, 'target')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;component;help' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List installed and available components')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add a component to a Rust toolchain')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove a component from a Rust toolchain')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'rustup;component;help;list' {
            break
        }
        'rustup;component;help;add' {
            break
        }
        'rustup;component;help;remove' {
            break
        }
        'rustup;component;help;help' {
            break
        }
        'rustup;override' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List directory toolchain overrides')
            [CompletionResult]::new('set', 'set', [CompletionResultType]::ParameterValue, 'Set the override toolchain for a directory')
            [CompletionResult]::new('unset', 'unset', [CompletionResultType]::ParameterValue, 'Remove the override toolchain for a directory')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'rustup;override;list' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;override;set' {
            [CompletionResult]::new('--path', '--path', [CompletionResultType]::ParameterName, 'Path to the directory')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;override;unset' {
            [CompletionResult]::new('--path', '--path', [CompletionResultType]::ParameterName, 'Path to the directory')
            [CompletionResult]::new('--nonexistent', '--nonexistent', [CompletionResultType]::ParameterName, 'Remove override toolchain for all nonexistent directories')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;override;help' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List directory toolchain overrides')
            [CompletionResult]::new('set', 'set', [CompletionResultType]::ParameterValue, 'Set the override toolchain for a directory')
            [CompletionResult]::new('unset', 'unset', [CompletionResultType]::ParameterValue, 'Remove the override toolchain for a directory')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'rustup;override;help;list' {
            break
        }
        'rustup;override;help;set' {
            break
        }
        'rustup;override;help;unset' {
            break
        }
        'rustup;override;help;help' {
            break
        }
        'rustup;run' {
            [CompletionResult]::new('--install', '--install', [CompletionResultType]::ParameterName, 'Install the requested toolchain if needed')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;which' {
            [CompletionResult]::new('--toolchain', '--toolchain', [CompletionResultType]::ParameterName, 'Toolchain name, such as ''stable'', ''nightly'', ''1.8.0'', or a custom toolchain name. For more information see `rustup help toolchain`')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;doc' {
            [CompletionResult]::new('--toolchain', '--toolchain', [CompletionResultType]::ParameterName, 'Toolchain name, such as ''stable'', ''nightly'', or ''1.8.0''. For more information see `rustup help toolchain`')
            [CompletionResult]::new('--path', '--path', [CompletionResultType]::ParameterName, 'Only print the path to the documentation')
            [CompletionResult]::new('--alloc', '--alloc', [CompletionResultType]::ParameterName, 'The Rust core allocation and collections library')
            [CompletionResult]::new('--book', '--book', [CompletionResultType]::ParameterName, 'The Rust Programming Language book')
            [CompletionResult]::new('--cargo', '--cargo', [CompletionResultType]::ParameterName, 'The Cargo Book')
            [CompletionResult]::new('--clippy', '--clippy', [CompletionResultType]::ParameterName, 'The Clippy Documentation')
            [CompletionResult]::new('--core', '--core', [CompletionResultType]::ParameterName, 'The Rust Core Library')
            [CompletionResult]::new('--edition-guide', '--edition-guide', [CompletionResultType]::ParameterName, 'The Rust Edition Guide')
            [CompletionResult]::new('--embedded-book', '--embedded-book', [CompletionResultType]::ParameterName, 'The Embedded Rust Book')
            [CompletionResult]::new('--error-codes', '--error-codes', [CompletionResultType]::ParameterName, 'The Rust Error Codes Index')
            [CompletionResult]::new('--nomicon', '--nomicon', [CompletionResultType]::ParameterName, 'The Dark Arts of Advanced and Unsafe Rust Programming')
            [CompletionResult]::new('--proc_macro', '--proc_macro', [CompletionResultType]::ParameterName, 'A support library for macro authors when defining new macros')
            [CompletionResult]::new('--reference', '--reference', [CompletionResultType]::ParameterName, 'The Rust Reference')
            [CompletionResult]::new('--rust-by-example', '--rust-by-example', [CompletionResultType]::ParameterName, 'A collection of runnable examples that illustrate various Rust concepts and standard libraries')
            [CompletionResult]::new('--rustc', '--rustc', [CompletionResultType]::ParameterName, 'The compiler for the Rust programming language')
            [CompletionResult]::new('--rustdoc', '--rustdoc', [CompletionResultType]::ParameterName, 'Documentation generator for Rust projects')
            [CompletionResult]::new('--std', '--std', [CompletionResultType]::ParameterName, 'Standard library API documentation')
            [CompletionResult]::new('--style-guide', '--style-guide', [CompletionResultType]::ParameterName, 'The Rust Style Guide')
            [CompletionResult]::new('--test', '--test', [CompletionResultType]::ParameterName, 'Support code for rustc''s built in unit-test and micro-benchmarking framework')
            [CompletionResult]::new('--unstable-book', '--unstable-book', [CompletionResultType]::ParameterName, 'The Unstable Book')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;man' {
            [CompletionResult]::new('--toolchain', '--toolchain', [CompletionResultType]::ParameterName, 'Toolchain name, such as ''stable'', ''nightly'', or ''1.8.0''. For more information see `rustup help toolchain`')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;self' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Download and install updates to rustup')
            [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstall rustup')
            [CompletionResult]::new('upgrade-data', 'upgrade-data', [CompletionResultType]::ParameterValue, 'Upgrade the internal data format')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'rustup;self;update' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;self;uninstall' {
            [CompletionResult]::new('-y', '-y', [CompletionResultType]::ParameterName, 'y')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;self;upgrade-data' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;self;help' {
            [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Download and install updates to rustup')
            [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstall rustup')
            [CompletionResult]::new('upgrade-data', 'upgrade-data', [CompletionResultType]::ParameterValue, 'Upgrade the internal data format')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'rustup;self;help;update' {
            break
        }
        'rustup;self;help;uninstall' {
            break
        }
        'rustup;self;help;upgrade-data' {
            break
        }
        'rustup;self;help;help' {
            break
        }
        'rustup;set' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('default-host', 'default-host', [CompletionResultType]::ParameterValue, 'The triple used to identify toolchains when not specified')
            [CompletionResult]::new('profile', 'profile', [CompletionResultType]::ParameterValue, 'The default components installed with a toolchain')
            [CompletionResult]::new('auto-self-update', 'auto-self-update', [CompletionResultType]::ParameterValue, 'The rustup auto self update mode')
            [CompletionResult]::new('auto-install', 'auto-install', [CompletionResultType]::ParameterValue, 'The auto toolchain install mode')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'rustup;set;default-host' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;set;profile' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;set;auto-self-update' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;set;auto-install' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;set;help' {
            [CompletionResult]::new('default-host', 'default-host', [CompletionResultType]::ParameterValue, 'The triple used to identify toolchains when not specified')
            [CompletionResult]::new('profile', 'profile', [CompletionResultType]::ParameterValue, 'The default components installed with a toolchain')
            [CompletionResult]::new('auto-self-update', 'auto-self-update', [CompletionResultType]::ParameterValue, 'The rustup auto self update mode')
            [CompletionResult]::new('auto-install', 'auto-install', [CompletionResultType]::ParameterValue, 'The auto toolchain install mode')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'rustup;set;help;default-host' {
            break
        }
        'rustup;set;help;profile' {
            break
        }
        'rustup;set;help;auto-self-update' {
            break
        }
        'rustup;set;help;auto-install' {
            break
        }
        'rustup;set;help;help' {
            break
        }
        'rustup;completions' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'rustup;help' {
            [CompletionResult]::new('install', 'install', [CompletionResultType]::ParameterValue, 'Install or update the given toolchains, or by default the active toolchain')
            [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstall the given toolchains')
            [CompletionResult]::new('dump-testament', 'dump-testament', [CompletionResultType]::ParameterValue, 'Dump information about the build')
            [CompletionResult]::new('toolchain', 'toolchain', [CompletionResultType]::ParameterValue, 'Install, uninstall, or list toolchains')
            [CompletionResult]::new('default', 'default', [CompletionResultType]::ParameterValue, 'Set the default toolchain')
            [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Show the active and installed toolchains or profiles')
            [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Update Rust toolchains and rustup')
            [CompletionResult]::new('check', 'check', [CompletionResultType]::ParameterValue, 'Check for updates to Rust toolchains and rustup')
            [CompletionResult]::new('target', 'target', [CompletionResultType]::ParameterValue, 'Modify a toolchain''s supported targets')
            [CompletionResult]::new('component', 'component', [CompletionResultType]::ParameterValue, 'Modify a toolchain''s installed components')
            [CompletionResult]::new('override', 'override', [CompletionResultType]::ParameterValue, 'Modify toolchain overrides for directories')
            [CompletionResult]::new('run', 'run', [CompletionResultType]::ParameterValue, 'Run a command with an environment configured for a given toolchain')
            [CompletionResult]::new('which', 'which', [CompletionResultType]::ParameterValue, 'Display which binary will be run for a given command')
            [CompletionResult]::new('doc', 'doc', [CompletionResultType]::ParameterValue, 'Open the documentation for the current toolchain')
            [CompletionResult]::new('man', 'man', [CompletionResultType]::ParameterValue, 'View the man page for a given command')
            [CompletionResult]::new('self', 'self', [CompletionResultType]::ParameterValue, 'Modify the rustup installation')
            [CompletionResult]::new('set', 'set', [CompletionResultType]::ParameterValue, 'Alter rustup settings')
            [CompletionResult]::new('completions', 'completions', [CompletionResultType]::ParameterValue, 'Generate tab-completion scripts for your shell')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'rustup;help;install' {
            break
        }
        'rustup;help;uninstall' {
            break
        }
        'rustup;help;dump-testament' {
            break
        }
        'rustup;help;toolchain' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List installed toolchains')
            [CompletionResult]::new('install', 'install', [CompletionResultType]::ParameterValue, 'Install or update the given toolchains, or by default the active toolchain')
            [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstall the given toolchains')
            [CompletionResult]::new('link', 'link', [CompletionResultType]::ParameterValue, 'Create a custom toolchain by symlinking to a directory')
            break
        }
        'rustup;help;toolchain;list' {
            break
        }
        'rustup;help;toolchain;install' {
            break
        }
        'rustup;help;toolchain;uninstall' {
            break
        }
        'rustup;help;toolchain;link' {
            break
        }
        'rustup;help;default' {
            break
        }
        'rustup;help;show' {
            [CompletionResult]::new('active-toolchain', 'active-toolchain', [CompletionResultType]::ParameterValue, 'Show the active toolchain')
            [CompletionResult]::new('home', 'home', [CompletionResultType]::ParameterValue, 'Display the computed value of RUSTUP_HOME')
            [CompletionResult]::new('profile', 'profile', [CompletionResultType]::ParameterValue, 'Show the default profile used for the `rustup install` command')
            break
        }
        'rustup;help;show;active-toolchain' {
            break
        }
        'rustup;help;show;home' {
            break
        }
        'rustup;help;show;profile' {
            break
        }
        'rustup;help;update' {
            break
        }
        'rustup;help;check' {
            break
        }
        'rustup;help;target' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List installed and available targets')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add a target to a Rust toolchain')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove a target from a Rust toolchain')
            break
        }
        'rustup;help;target;list' {
            break
        }
        'rustup;help;target;add' {
            break
        }
        'rustup;help;target;remove' {
            break
        }
        'rustup;help;component' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List installed and available components')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add a component to a Rust toolchain')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove a component from a Rust toolchain')
            break
        }
        'rustup;help;component;list' {
            break
        }
        'rustup;help;component;add' {
            break
        }
        'rustup;help;component;remove' {
            break
        }
        'rustup;help;override' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List directory toolchain overrides')
            [CompletionResult]::new('set', 'set', [CompletionResultType]::ParameterValue, 'Set the override toolchain for a directory')
            [CompletionResult]::new('unset', 'unset', [CompletionResultType]::ParameterValue, 'Remove the override toolchain for a directory')
            break
        }
        'rustup;help;override;list' {
            break
        }
        'rustup;help;override;set' {
            break
        }
        'rustup;help;override;unset' {
            break
        }
        'rustup;help;run' {
            break
        }
        'rustup;help;which' {
            break
        }
        'rustup;help;doc' {
            break
        }
        'rustup;help;man' {
            break
        }
        'rustup;help;self' {
            [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Download and install updates to rustup')
            [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstall rustup')
            [CompletionResult]::new('upgrade-data', 'upgrade-data', [CompletionResultType]::ParameterValue, 'Upgrade the internal data format')
            break
        }
        'rustup;help;self;update' {
            break
        }
        'rustup;help;self;uninstall' {
            break
        }
        'rustup;help;self;upgrade-data' {
            break
        }
        'rustup;help;set' {
            [CompletionResult]::new('default-host', 'default-host', [CompletionResultType]::ParameterValue, 'The triple used to identify toolchains when not specified')
            [CompletionResult]::new('profile', 'profile', [CompletionResultType]::ParameterValue, 'The default components installed with a toolchain')
            [CompletionResult]::new('auto-self-update', 'auto-self-update', [CompletionResultType]::ParameterValue, 'The rustup auto self update mode')
            [CompletionResult]::new('auto-install', 'auto-install', [CompletionResultType]::ParameterValue, 'The auto toolchain install mode')
            break
        }
        'rustup;help;set;default-host' {
            break
        }
        'rustup;help;set;profile' {
            break
        }
        'rustup;help;set;auto-self-update' {
            break
        }
        'rustup;help;set;auto-install' {
            break
        }
        'rustup;help;completions' {
            break
        }
        'rustup;help;help' {
            break
        }
    })

    $completions.Where{ $_.CompletionText -like "$wordToComplete*" } |
        Sort-Object -Property ListItemText
}

# ripgrep
Register-ArgumentCompleter -Native -CommandName 'rg' -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)
  $commandElements = $commandAst.CommandElements
  $command = @(
    'rg'
    for ($i = 1; $i -lt $commandElements.Count; $i++) {
        $element = $commandElements[$i]
        if ($element -isnot [StringConstantExpressionAst] -or
            $element.StringConstantType -ne [StringConstantType]::BareWord -or
            $element.Value.StartsWith('-')) {
            break
    }
    $element.Value
  }) -join ';'

  $completions = @(switch ($command) {
    'rg' {
      [CompletionResult]::new('--regexp', 'regexp', [CompletionResultType]::ParameterName, 'A pattern to search for.')
      [CompletionResult]::new('-e', 'e', [CompletionResultType]::ParameterName, 'A pattern to search for.')
      [CompletionResult]::new('--file', 'file', [CompletionResultType]::ParameterName, 'Search for patterns from the given file.')
      [CompletionResult]::new('-f', 'f', [CompletionResultType]::ParameterName, 'Search for patterns from the given file.')
      [CompletionResult]::new('--after-context', 'after-context', [CompletionResultType]::ParameterName, 'Show NUM lines after each match.')
      [CompletionResult]::new('-A', 'A', [CompletionResultType]::ParameterName, 'Show NUM lines after each match.')
      [CompletionResult]::new('--before-context', 'before-context', [CompletionResultType]::ParameterName, 'Show NUM lines before each match.')
      [CompletionResult]::new('-B', 'B', [CompletionResultType]::ParameterName, 'Show NUM lines before each match.')
      [CompletionResult]::new('--binary', 'binary', [CompletionResultType]::ParameterName, 'Search binary files.')
      [CompletionResult]::new('--no-binary', 'no-binary', [CompletionResultType]::ParameterName, 'Search binary files.')
      [CompletionResult]::new('--block-buffered', 'block-buffered', [CompletionResultType]::ParameterName, 'Force block buffering.')
      [CompletionResult]::new('--no-block-buffered', 'no-block-buffered', [CompletionResultType]::ParameterName, 'Force block buffering.')
      [CompletionResult]::new('--byte-offset', 'byte-offset', [CompletionResultType]::ParameterName, 'Print the byte offset for each matching line.')
      [CompletionResult]::new('-b', 'b', [CompletionResultType]::ParameterName, 'Print the byte offset for each matching line.')
      [CompletionResult]::new('--no-byte-offset', 'no-byte-offset', [CompletionResultType]::ParameterName, 'Print the byte offset for each matching line.')
      [CompletionResult]::new('--case-sensitive', 'case-sensitive', [CompletionResultType]::ParameterName, 'Search case sensitively (default).')
      [CompletionResult]::new('-s', 's', [CompletionResultType]::ParameterName, 'Search case sensitively (default).')
      [CompletionResult]::new('--color', 'color', [CompletionResultType]::ParameterName, 'When to use color.')
      [CompletionResult]::new('--colors', 'colors', [CompletionResultType]::ParameterName, 'Configure color settings and styles.')
      [CompletionResult]::new('--column', 'column', [CompletionResultType]::ParameterName, 'Show column numbers.')
      [CompletionResult]::new('--no-column', 'no-column', [CompletionResultType]::ParameterName, 'Show column numbers.')
      [CompletionResult]::new('--context', 'context', [CompletionResultType]::ParameterName, 'Show NUM lines before and after each match.')
      [CompletionResult]::new('-C', 'C', [CompletionResultType]::ParameterName, 'Show NUM lines before and after each match.')
      [CompletionResult]::new('--context-separator', 'context-separator', [CompletionResultType]::ParameterName, 'Set the separator for contextual chunks.')
      [CompletionResult]::new('--no-context-separator', 'no-context-separator', [CompletionResultType]::ParameterName, 'Set the separator for contextual chunks.')
      [CompletionResult]::new('--count', 'count', [CompletionResultType]::ParameterName, 'Show count of matching lines for each file.')
      [CompletionResult]::new('-c', 'c', [CompletionResultType]::ParameterName, 'Show count of matching lines for each file.')
      [CompletionResult]::new('--count-matches', 'count-matches', [CompletionResultType]::ParameterName, 'Show count of every match for each file.')
      [CompletionResult]::new('--crlf', 'crlf', [CompletionResultType]::ParameterName, 'Use CRLF line terminators (nice for Windows).')
      [CompletionResult]::new('--no-crlf', 'no-crlf', [CompletionResultType]::ParameterName, 'Use CRLF line terminators (nice for Windows).')
      [CompletionResult]::new('--debug', 'debug', [CompletionResultType]::ParameterName, 'Show debug messages.')
      [CompletionResult]::new('--dfa-size-limit', 'dfa-size-limit', [CompletionResultType]::ParameterName, 'The upper size limit of the regex DFA.')
      [CompletionResult]::new('--encoding', 'encoding', [CompletionResultType]::ParameterName, 'Specify the text encoding of files to search.')
      [CompletionResult]::new('-E', 'E', [CompletionResultType]::ParameterName, 'Specify the text encoding of files to search.')
      [CompletionResult]::new('--no-encoding', 'no-encoding', [CompletionResultType]::ParameterName, 'Specify the text encoding of files to search.')
      [CompletionResult]::new('--engine', 'engine', [CompletionResultType]::ParameterName, 'Specify which regex engine to use.')
      [CompletionResult]::new('--field-context-separator', 'field-context-separator', [CompletionResultType]::ParameterName, 'Set the field context separator.')
      [CompletionResult]::new('--field-match-separator', 'field-match-separator', [CompletionResultType]::ParameterName, 'Set the field match separator.')
      [CompletionResult]::new('--files', 'files', [CompletionResultType]::ParameterName, 'Print each file that would be searched.')
      [CompletionResult]::new('--files-with-matches', 'files-with-matches', [CompletionResultType]::ParameterName, 'Print the paths with at least one match.')
      [CompletionResult]::new('-l', 'l', [CompletionResultType]::ParameterName, 'Print the paths with at least one match.')
      [CompletionResult]::new('--files-without-match', 'files-without-match', [CompletionResultType]::ParameterName, 'Print the paths that contain zero matches.')
      [CompletionResult]::new('--fixed-strings', 'fixed-strings', [CompletionResultType]::ParameterName, 'Treat all patterns as literals.')
      [CompletionResult]::new('-F', 'F', [CompletionResultType]::ParameterName, 'Treat all patterns as literals.')
      [CompletionResult]::new('--no-fixed-strings', 'no-fixed-strings', [CompletionResultType]::ParameterName, 'Treat all patterns as literals.')
      [CompletionResult]::new('--follow', 'follow', [CompletionResultType]::ParameterName, 'Follow symbolic links.')
      [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'Follow symbolic links.')
      [CompletionResult]::new('--no-follow', 'no-follow', [CompletionResultType]::ParameterName, 'Follow symbolic links.')
      [CompletionResult]::new('--generate', 'generate', [CompletionResultType]::ParameterName, 'Generate man pages and completion scripts.')
      [CompletionResult]::new('--glob', 'glob', [CompletionResultType]::ParameterName, 'Include or exclude file paths.')
      [CompletionResult]::new('-g', 'g', [CompletionResultType]::ParameterName, 'Include or exclude file paths.')
      [CompletionResult]::new('--glob-case-insensitive', 'glob-case-insensitive', [CompletionResultType]::ParameterName, 'Process all glob patterns case insensitively.')
      [CompletionResult]::new('--no-glob-case-insensitive', 'no-glob-case-insensitive', [CompletionResultType]::ParameterName, 'Process all glob patterns case insensitively.')
      [CompletionResult]::new('--heading', 'heading', [CompletionResultType]::ParameterName, 'Print matches grouped by each file.')
      [CompletionResult]::new('--no-heading', 'no-heading', [CompletionResultType]::ParameterName, 'Print matches grouped by each file.')
      [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Show help output.')
      [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'Show help output.')
      [CompletionResult]::new('--hidden', 'hidden', [CompletionResultType]::ParameterName, 'Search hidden files and directories.')
      [CompletionResult]::new('-.', '.', [CompletionResultType]::ParameterName, 'Search hidden files and directories.')
      [CompletionResult]::new('--no-hidden', 'no-hidden', [CompletionResultType]::ParameterName, 'Search hidden files and directories.')
      [CompletionResult]::new('--hostname-bin', 'hostname-bin', [CompletionResultType]::ParameterName, 'Run a program to get this system''s hostname.')
      [CompletionResult]::new('--hyperlink-format', 'hyperlink-format', [CompletionResultType]::ParameterName, 'Set the format of hyperlinks.')
      [CompletionResult]::new('--iglob', 'iglob', [CompletionResultType]::ParameterName, 'Include/exclude paths case insensitively.')
      [CompletionResult]::new('--ignore-case', 'ignore-case', [CompletionResultType]::ParameterName, 'Case insensitive search.')
      [CompletionResult]::new('-i', 'i', [CompletionResultType]::ParameterName, 'Case insensitive search.')
      [CompletionResult]::new('--ignore-file', 'ignore-file', [CompletionResultType]::ParameterName, 'Specify additional ignore files.')
      [CompletionResult]::new('--ignore-file-case-insensitive', 'ignore-file-case-insensitive', [CompletionResultType]::ParameterName, 'Process ignore files case insensitively.')
      [CompletionResult]::new('--no-ignore-file-case-insensitive', 'no-ignore-file-case-insensitive', [CompletionResultType]::ParameterName, 'Process ignore files case insensitively.')
      [CompletionResult]::new('--include-zero', 'include-zero', [CompletionResultType]::ParameterName, 'Include zero matches in summary output.')
      [CompletionResult]::new('--no-include-zero', 'no-include-zero', [CompletionResultType]::ParameterName, 'Include zero matches in summary output.')
      [CompletionResult]::new('--invert-match', 'invert-match', [CompletionResultType]::ParameterName, 'Invert matching.')
      [CompletionResult]::new('-v', 'v', [CompletionResultType]::ParameterName, 'Invert matching.')
      [CompletionResult]::new('--no-invert-match', 'no-invert-match', [CompletionResultType]::ParameterName, 'Invert matching.')
      [CompletionResult]::new('--json', 'json', [CompletionResultType]::ParameterName, 'Show search results in a JSON Lines format.')
      [CompletionResult]::new('--no-json', 'no-json', [CompletionResultType]::ParameterName, 'Show search results in a JSON Lines format.')
      [CompletionResult]::new('--line-buffered', 'line-buffered', [CompletionResultType]::ParameterName, 'Force line buffering.')
      [CompletionResult]::new('--no-line-buffered', 'no-line-buffered', [CompletionResultType]::ParameterName, 'Force line buffering.')
      [CompletionResult]::new('--line-number', 'line-number', [CompletionResultType]::ParameterName, 'Show line numbers.')
      [CompletionResult]::new('-n', 'n', [CompletionResultType]::ParameterName, 'Show line numbers.')
      [CompletionResult]::new('--no-line-number', 'no-line-number', [CompletionResultType]::ParameterName, 'Suppress line numbers.')
      [CompletionResult]::new('-N', 'N', [CompletionResultType]::ParameterName, 'Suppress line numbers.')
      [CompletionResult]::new('--line-regexp', 'line-regexp', [CompletionResultType]::ParameterName, 'Show matches surrounded by line boundaries.')
      [CompletionResult]::new('-x', 'x', [CompletionResultType]::ParameterName, 'Show matches surrounded by line boundaries.')
      [CompletionResult]::new('--max-columns', 'max-columns', [CompletionResultType]::ParameterName, 'Omit lines longer than this limit.')
      [CompletionResult]::new('-M', 'M', [CompletionResultType]::ParameterName, 'Omit lines longer than this limit.')
      [CompletionResult]::new('--max-columns-preview', 'max-columns-preview', [CompletionResultType]::ParameterName, 'Show preview for lines exceeding the limit.')
      [CompletionResult]::new('--no-max-columns-preview', 'no-max-columns-preview', [CompletionResultType]::ParameterName, 'Show preview for lines exceeding the limit.')
      [CompletionResult]::new('--max-count', 'max-count', [CompletionResultType]::ParameterName, 'Limit the number of matching lines.')
      [CompletionResult]::new('-m', 'm', [CompletionResultType]::ParameterName, 'Limit the number of matching lines.')
      [CompletionResult]::new('--max-depth', 'max-depth', [CompletionResultType]::ParameterName, 'Descend at most NUM directories.')
      [CompletionResult]::new('-d', 'd', [CompletionResultType]::ParameterName, 'Descend at most NUM directories.')
      [CompletionResult]::new('--max-filesize', 'max-filesize', [CompletionResultType]::ParameterName, 'Ignore files larger than NUM in size.')
      [CompletionResult]::new('--mmap', 'mmap', [CompletionResultType]::ParameterName, 'Search with memory maps when possible.')
      [CompletionResult]::new('--no-mmap', 'no-mmap', [CompletionResultType]::ParameterName, 'Search with memory maps when possible.')
      [CompletionResult]::new('--multiline', 'multiline', [CompletionResultType]::ParameterName, 'Enable searching across multiple lines.')
      [CompletionResult]::new('-U', 'U', [CompletionResultType]::ParameterName, 'Enable searching across multiple lines.')
      [CompletionResult]::new('--no-multiline', 'no-multiline', [CompletionResultType]::ParameterName, 'Enable searching across multiple lines.')
      [CompletionResult]::new('--multiline-dotall', 'multiline-dotall', [CompletionResultType]::ParameterName, 'Make ''.'' match line terminators.')
      [CompletionResult]::new('--no-multiline-dotall', 'no-multiline-dotall', [CompletionResultType]::ParameterName, 'Make ''.'' match line terminators.')
      [CompletionResult]::new('--no-config', 'no-config', [CompletionResultType]::ParameterName, 'Never read configuration files.')
      [CompletionResult]::new('--no-ignore', 'no-ignore', [CompletionResultType]::ParameterName, 'Don''t use ignore files.')
      [CompletionResult]::new('--ignore', 'ignore', [CompletionResultType]::ParameterName, 'Don''t use ignore files.')
      [CompletionResult]::new('--no-ignore-dot', 'no-ignore-dot', [CompletionResultType]::ParameterName, 'Don''t use .ignore or .rgignore files.')
      [CompletionResult]::new('--ignore-dot', 'ignore-dot', [CompletionResultType]::ParameterName, 'Don''t use .ignore or .rgignore files.')
      [CompletionResult]::new('--no-ignore-exclude', 'no-ignore-exclude', [CompletionResultType]::ParameterName, 'Don''t use local exclusion files.')
      [CompletionResult]::new('--ignore-exclude', 'ignore-exclude', [CompletionResultType]::ParameterName, 'Don''t use local exclusion files.')
      [CompletionResult]::new('--no-ignore-files', 'no-ignore-files', [CompletionResultType]::ParameterName, 'Don''t use --ignore-file arguments.')
      [CompletionResult]::new('--ignore-files', 'ignore-files', [CompletionResultType]::ParameterName, 'Don''t use --ignore-file arguments.')
      [CompletionResult]::new('--no-ignore-global', 'no-ignore-global', [CompletionResultType]::ParameterName, 'Don''t use global ignore files.')
      [CompletionResult]::new('--ignore-global', 'ignore-global', [CompletionResultType]::ParameterName, 'Don''t use global ignore files.')
      [CompletionResult]::new('--no-ignore-messages', 'no-ignore-messages', [CompletionResultType]::ParameterName, 'Suppress gitignore parse error messages.')
      [CompletionResult]::new('--ignore-messages', 'ignore-messages', [CompletionResultType]::ParameterName, 'Suppress gitignore parse error messages.')
      [CompletionResult]::new('--no-ignore-parent', 'no-ignore-parent', [CompletionResultType]::ParameterName, 'Don''t use ignore files in parent directories.')
      [CompletionResult]::new('--ignore-parent', 'ignore-parent', [CompletionResultType]::ParameterName, 'Don''t use ignore files in parent directories.')
      [CompletionResult]::new('--no-ignore-vcs', 'no-ignore-vcs', [CompletionResultType]::ParameterName, 'Don''t use ignore files from source control.')
      [CompletionResult]::new('--ignore-vcs', 'ignore-vcs', [CompletionResultType]::ParameterName, 'Don''t use ignore files from source control.')
      [CompletionResult]::new('--no-messages', 'no-messages', [CompletionResultType]::ParameterName, 'Suppress some error messages.')
      [CompletionResult]::new('--messages', 'messages', [CompletionResultType]::ParameterName, 'Suppress some error messages.')
      [CompletionResult]::new('--no-require-git', 'no-require-git', [CompletionResultType]::ParameterName, 'Use .gitignore outside of git repositories.')
      [CompletionResult]::new('--require-git', 'require-git', [CompletionResultType]::ParameterName, 'Use .gitignore outside of git repositories.')
      [CompletionResult]::new('--no-unicode', 'no-unicode', [CompletionResultType]::ParameterName, 'Disable Unicode mode.')
      [CompletionResult]::new('--unicode', 'unicode', [CompletionResultType]::ParameterName, 'Disable Unicode mode.')
      [CompletionResult]::new('--null', 'null', [CompletionResultType]::ParameterName, 'Print a NUL byte after file paths.')
      [CompletionResult]::new('-0', '0', [CompletionResultType]::ParameterName, 'Print a NUL byte after file paths.')
      [CompletionResult]::new('--null-data', 'null-data', [CompletionResultType]::ParameterName, 'Use NUL as a line terminator.')
      [CompletionResult]::new('--one-file-system', 'one-file-system', [CompletionResultType]::ParameterName, 'Skip directories on other file systems.')
      [CompletionResult]::new('--no-one-file-system', 'no-one-file-system', [CompletionResultType]::ParameterName, 'Skip directories on other file systems.')
      [CompletionResult]::new('--only-matching', 'only-matching', [CompletionResultType]::ParameterName, 'Print only matched parts of a line.')
      [CompletionResult]::new('-o', 'o', [CompletionResultType]::ParameterName, 'Print only matched parts of a line.')
      [CompletionResult]::new('--path-separator', 'path-separator', [CompletionResultType]::ParameterName, 'Set the path separator for printing paths.')
      [CompletionResult]::new('--passthru', 'passthru', [CompletionResultType]::ParameterName, 'Print both matching and non-matching lines.')
      [CompletionResult]::new('--pcre2', 'pcre2', [CompletionResultType]::ParameterName, 'Enable PCRE2 matching.')
      [CompletionResult]::new('-P', 'P', [CompletionResultType]::ParameterName, 'Enable PCRE2 matching.')
      [CompletionResult]::new('--no-pcre2', 'no-pcre2', [CompletionResultType]::ParameterName, 'Enable PCRE2 matching.')
      [CompletionResult]::new('--pcre2-version', 'pcre2-version', [CompletionResultType]::ParameterName, 'Print the version of PCRE2 that ripgrep uses.')
      [CompletionResult]::new('--pre', 'pre', [CompletionResultType]::ParameterName, 'Search output of COMMAND for each PATH.')
      [CompletionResult]::new('--no-pre', 'no-pre', [CompletionResultType]::ParameterName, 'Search output of COMMAND for each PATH.')
      [CompletionResult]::new('--pre-glob', 'pre-glob', [CompletionResultType]::ParameterName, 'Include or exclude files from a preprocessor.')
      [CompletionResult]::new('--pretty', 'pretty', [CompletionResultType]::ParameterName, 'Alias for colors, headings and line numbers.')
      [CompletionResult]::new('-p', 'p', [CompletionResultType]::ParameterName, 'Alias for colors, headings and line numbers.')
      [CompletionResult]::new('--quiet', 'quiet', [CompletionResultType]::ParameterName, 'Do not print anything to stdout.')
      [CompletionResult]::new('-q', 'q', [CompletionResultType]::ParameterName, 'Do not print anything to stdout.')
      [CompletionResult]::new('--regex-size-limit', 'regex-size-limit', [CompletionResultType]::ParameterName, 'The size limit of the compiled regex.')
      [CompletionResult]::new('--replace', 'replace', [CompletionResultType]::ParameterName, 'Replace matches with the given text.')
      [CompletionResult]::new('-r', 'r', [CompletionResultType]::ParameterName, 'Replace matches with the given text.')
      [CompletionResult]::new('--search-zip', 'search-zip', [CompletionResultType]::ParameterName, 'Search in compressed files.')
      [CompletionResult]::new('-z', 'z', [CompletionResultType]::ParameterName, 'Search in compressed files.')
      [CompletionResult]::new('--no-search-zip', 'no-search-zip', [CompletionResultType]::ParameterName, 'Search in compressed files.')
      [CompletionResult]::new('--smart-case', 'smart-case', [CompletionResultType]::ParameterName, 'Smart case search.')
      [CompletionResult]::new('-S', 'S', [CompletionResultType]::ParameterName, 'Smart case search.')
      [CompletionResult]::new('--sort', 'sort', [CompletionResultType]::ParameterName, 'Sort results in ascending order.')
      [CompletionResult]::new('--sortr', 'sortr', [CompletionResultType]::ParameterName, 'Sort results in descending order.')
      [CompletionResult]::new('--stats', 'stats', [CompletionResultType]::ParameterName, 'Print statistics about the search.')
      [CompletionResult]::new('--no-stats', 'no-stats', [CompletionResultType]::ParameterName, 'Print statistics about the search.')
      [CompletionResult]::new('--stop-on-nonmatch', 'stop-on-nonmatch', [CompletionResultType]::ParameterName, 'Stop searching after a non-match.')
      [CompletionResult]::new('--text', 'text', [CompletionResultType]::ParameterName, 'Search binary files as if they were text.')
      [CompletionResult]::new('-a', 'a', [CompletionResultType]::ParameterName, 'Search binary files as if they were text.')
      [CompletionResult]::new('--no-text', 'no-text', [CompletionResultType]::ParameterName, 'Search binary files as if they were text.')
      [CompletionResult]::new('--threads', 'threads', [CompletionResultType]::ParameterName, 'Set the approximate number of threads to use.')
      [CompletionResult]::new('-j', 'j', [CompletionResultType]::ParameterName, 'Set the approximate number of threads to use.')
      [CompletionResult]::new('--trace', 'trace', [CompletionResultType]::ParameterName, 'Show trace messages.')
      [CompletionResult]::new('--trim', 'trim', [CompletionResultType]::ParameterName, 'Trim prefix whitespace from matches.')
      [CompletionResult]::new('--no-trim', 'no-trim', [CompletionResultType]::ParameterName, 'Trim prefix whitespace from matches.')
      [CompletionResult]::new('--type', 'type', [CompletionResultType]::ParameterName, 'Only search files matching TYPE.')
      [CompletionResult]::new('-t', 't', [CompletionResultType]::ParameterName, 'Only search files matching TYPE.')
      [CompletionResult]::new('--type-not', 'type-not', [CompletionResultType]::ParameterName, 'Do not search files matching TYPE.')
      [CompletionResult]::new('-T', 'T', [CompletionResultType]::ParameterName, 'Do not search files matching TYPE.')
      [CompletionResult]::new('--type-add', 'type-add', [CompletionResultType]::ParameterName, 'Add a new glob for a file type.')
      [CompletionResult]::new('--type-clear', 'type-clear', [CompletionResultType]::ParameterName, 'Clear globs for a file type.')
      [CompletionResult]::new('--type-list', 'type-list', [CompletionResultType]::ParameterName, 'Show all supported file types.')
      [CompletionResult]::new('--unrestricted', 'unrestricted', [CompletionResultType]::ParameterName, 'Reduce the level of "smart" filtering.')
      [CompletionResult]::new('-u', 'u', [CompletionResultType]::ParameterName, 'Reduce the level of "smart" filtering.')
      [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Print ripgrep''s version.')
      [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Print ripgrep''s version.')
      [CompletionResult]::new('--vimgrep', 'vimgrep', [CompletionResultType]::ParameterName, 'Print results in a vim compatible format.')
      [CompletionResult]::new('--with-filename', 'with-filename', [CompletionResultType]::ParameterName, 'Print the file path with each matching line.')
      [CompletionResult]::new('-H', 'H', [CompletionResultType]::ParameterName, 'Print the file path with each matching line.')
      [CompletionResult]::new('--no-filename', 'no-filename', [CompletionResultType]::ParameterName, 'Never print the path with each matching line.')
      [CompletionResult]::new('-I', 'I', [CompletionResultType]::ParameterName, 'Never print the path with each matching line.')
      [CompletionResult]::new('--word-regexp', 'word-regexp', [CompletionResultType]::ParameterName, 'Show matches surrounded by word boundaries.')
      [CompletionResult]::new('-w', 'w', [CompletionResultType]::ParameterName, 'Show matches surrounded by word boundaries.')
      [CompletionResult]::new('--auto-hybrid-regex', 'auto-hybrid-regex', [CompletionResultType]::ParameterName, '(DEPRECATED) Use PCRE2 if appropriate.')
      [CompletionResult]::new('--no-auto-hybrid-regex', 'no-auto-hybrid-regex', [CompletionResultType]::ParameterName, '(DEPRECATED) Use PCRE2 if appropriate.')
      [CompletionResult]::new('--no-pcre2-unicode', 'no-pcre2-unicode', [CompletionResultType]::ParameterName, '(DEPRECATED) Disable Unicode mode for PCRE2.')
      [CompletionResult]::new('--pcre2-unicode', 'pcre2-unicode', [CompletionResultType]::ParameterName, '(DEPRECATED) Disable Unicode mode for PCRE2.')
      [CompletionResult]::new('--sort-files', 'sort-files', [CompletionResultType]::ParameterName, '(DEPRECATED) Sort results by file path.')
      [CompletionResult]::new('--no-sort-files', 'no-sort-files', [CompletionResultType]::ParameterName, '(DEPRECATED) Sort results by file path.')
    }
  })

  $completions.Where{ $_.CompletionText -like "$wordToComplete*" } |
    Sort-Object -Property ListItemText
}


# mdbook
Register-ArgumentCompleter -Native -CommandName 'mdbook' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $commandElements = $commandAst.CommandElements
    $command = @(
        'mdbook'
        for ($i = 1; $i -lt $commandElements.Count; $i++) {
            $element = $commandElements[$i]
            if ($element -isnot [StringConstantExpressionAst] -or
                $element.StringConstantType -ne [StringConstantType]::BareWord -or
                $element.Value.StartsWith('-') -or
                $element.Value -eq $wordToComplete) {
                break
        }
        $element.Value
    }) -join ';'

    $completions = @(switch ($command) {
        'mdbook' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('init', 'init', [CompletionResultType]::ParameterValue, 'Creates the boilerplate structure and files for a new book')
            [CompletionResult]::new('build', 'build', [CompletionResultType]::ParameterValue, 'Builds a book from its markdown files')
            [CompletionResult]::new('test', 'test', [CompletionResultType]::ParameterValue, 'Tests that a book''s Rust code samples compile')
            [CompletionResult]::new('clean', 'clean', [CompletionResultType]::ParameterValue, 'Deletes a built book')
            [CompletionResult]::new('completions', 'completions', [CompletionResultType]::ParameterValue, 'Generate shell completions for your shell to stdout')
            [CompletionResult]::new('watch', 'watch', [CompletionResultType]::ParameterValue, 'Watches a book''s files and rebuilds it on changes')
            [CompletionResult]::new('serve', 'serve', [CompletionResultType]::ParameterValue, 'Serves a book at http://localhost:3000, and rebuilds it on changes')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'mdbook;init' {
            [CompletionResult]::new('--title', '--title', [CompletionResultType]::ParameterName, 'Sets the book title')
            [CompletionResult]::new('--ignore', '--ignore', [CompletionResultType]::ParameterName, 'Creates a VCS ignore file (i.e. .gitignore)')
            [CompletionResult]::new('--theme', '--theme', [CompletionResultType]::ParameterName, 'Copies the default theme into your source folder')
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Skips confirmation prompts')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mdbook;build' {
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Output directory for the book Relative paths are interpreted relative to the book''s root directory. If omitted, mdBook uses build.build-dir from book.toml or defaults to `./book`.')
            [CompletionResult]::new('--dest-dir', '--dest-dir', [CompletionResultType]::ParameterName, 'Output directory for the book Relative paths are interpreted relative to the book''s root directory. If omitted, mdBook uses build.build-dir from book.toml or defaults to `./book`.')
            [CompletionResult]::new('-o', '-o', [CompletionResultType]::ParameterName, 'Opens the compiled book in a web browser')
            [CompletionResult]::new('--open', '--open', [CompletionResultType]::ParameterName, 'Opens the compiled book in a web browser')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mdbook;test' {
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Output directory for the book Relative paths are interpreted relative to the book''s root directory. If omitted, mdBook uses build.build-dir from book.toml or defaults to `./book`.')
            [CompletionResult]::new('--dest-dir', '--dest-dir', [CompletionResultType]::ParameterName, 'Output directory for the book Relative paths are interpreted relative to the book''s root directory. If omitted, mdBook uses build.build-dir from book.toml or defaults to `./book`.')
            [CompletionResult]::new('-c', '-c', [CompletionResultType]::ParameterName, 'c')
            [CompletionResult]::new('--chapter', '--chapter', [CompletionResultType]::ParameterName, 'chapter')
            [CompletionResult]::new('-L', '-L ', [CompletionResultType]::ParameterName, 'A comma-separated list of directories to add to the crate search path when building tests')
            [CompletionResult]::new('--library-path', '--library-path', [CompletionResultType]::ParameterName, 'A comma-separated list of directories to add to the crate search path when building tests')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mdbook;clean' {
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Output directory for the book Relative paths are interpreted relative to the book''s root directory. If omitted, mdBook uses build.build-dir from book.toml or defaults to `./book`.')
            [CompletionResult]::new('--dest-dir', '--dest-dir', [CompletionResultType]::ParameterName, 'Output directory for the book Relative paths are interpreted relative to the book''s root directory. If omitted, mdBook uses build.build-dir from book.toml or defaults to `./book`.')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mdbook;completions' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mdbook;watch' {
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Output directory for the book Relative paths are interpreted relative to the book''s root directory. If omitted, mdBook uses build.build-dir from book.toml or defaults to `./book`.')
            [CompletionResult]::new('--dest-dir', '--dest-dir', [CompletionResultType]::ParameterName, 'Output directory for the book Relative paths are interpreted relative to the book''s root directory. If omitted, mdBook uses build.build-dir from book.toml or defaults to `./book`.')
            [CompletionResult]::new('--watcher', '--watcher', [CompletionResultType]::ParameterName, 'The filesystem watching technique')
            [CompletionResult]::new('-o', '-o', [CompletionResultType]::ParameterName, 'Opens the compiled book in a web browser')
            [CompletionResult]::new('--open', '--open', [CompletionResultType]::ParameterName, 'Opens the compiled book in a web browser')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mdbook;serve' {
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Output directory for the book Relative paths are interpreted relative to the book''s root directory. If omitted, mdBook uses build.build-dir from book.toml or defaults to `./book`.')
            [CompletionResult]::new('--dest-dir', '--dest-dir', [CompletionResultType]::ParameterName, 'Output directory for the book Relative paths are interpreted relative to the book''s root directory. If omitted, mdBook uses build.build-dir from book.toml or defaults to `./book`.')
            [CompletionResult]::new('-n', '-n', [CompletionResultType]::ParameterName, 'Hostname to listen on for HTTP connections')
            [CompletionResult]::new('--hostname', '--hostname', [CompletionResultType]::ParameterName, 'Hostname to listen on for HTTP connections')
            [CompletionResult]::new('-p', '-p', [CompletionResultType]::ParameterName, 'Port to use for HTTP connections')
            [CompletionResult]::new('--port', '--port', [CompletionResultType]::ParameterName, 'Port to use for HTTP connections')
            [CompletionResult]::new('--watcher', '--watcher', [CompletionResultType]::ParameterName, 'The filesystem watching technique')
            [CompletionResult]::new('-o', '-o', [CompletionResultType]::ParameterName, 'Opens the compiled book in a web browser')
            [CompletionResult]::new('--open', '--open', [CompletionResultType]::ParameterName, 'Opens the compiled book in a web browser')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mdbook;help' {
            [CompletionResult]::new('init', 'init', [CompletionResultType]::ParameterValue, 'Creates the boilerplate structure and files for a new book')
            [CompletionResult]::new('build', 'build', [CompletionResultType]::ParameterValue, 'Builds a book from its markdown files')
            [CompletionResult]::new('test', 'test', [CompletionResultType]::ParameterValue, 'Tests that a book''s Rust code samples compile')
            [CompletionResult]::new('clean', 'clean', [CompletionResultType]::ParameterValue, 'Deletes a built book')
            [CompletionResult]::new('completions', 'completions', [CompletionResultType]::ParameterValue, 'Generate shell completions for your shell to stdout')
            [CompletionResult]::new('watch', 'watch', [CompletionResultType]::ParameterValue, 'Watches a book''s files and rebuilds it on changes')
            [CompletionResult]::new('serve', 'serve', [CompletionResultType]::ParameterValue, 'Serves a book at http://localhost:3000, and rebuilds it on changes')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'mdbook;help;init' {
            break
        }
        'mdbook;help;build' {
            break
        }
        'mdbook;help;test' {
            break
        }
        'mdbook;help;clean' {
            break
        }
        'mdbook;help;completions' {
            break
        }
        'mdbook;help;watch' {
            break
        }
        'mdbook;help;serve' {
            break
        }
        'mdbook;help;help' {
            break
        }
    })

    $completions.Where{ $_.CompletionText -like "$wordToComplete*" } |
        Sort-Object -Property ListItemText
}

# Atuin PowerShell module
#
# Usage: atuin init powershell | Out-String | Invoke-Expression

# if (Get-Module Atuin -ErrorAction Ignore) {
#     Write-Warning "The Atuin module is already loaded."
#     return
# }

# if (!(Get-Command atuin -ErrorAction Ignore)) {
#     Write-Error "The 'atuin' executable needs to be available in the PATH."
#     return
# }

# if (!(Get-Module PSReadLine -ErrorAction Ignore)) {
#     Write-Error "Atuin requires the PSReadLine module to be installed."
#     return
# }

# New-Module -Name Atuin -ScriptBlock {
#     $env:ATUIN_SESSION = atuin uuid

#     $script:atuinHistoryId = $null
#     $script:previousPSConsoleHostReadLine = $Function:PSConsoleHostReadLine

#     # The ReadLine overloads changed with breaking changes over time, make sure the one we expect is available.
#     $script:hasExpectedReadLineOverload = ([Microsoft.PowerShell.PSConsoleReadLine]::ReadLine).OverloadDefinitions.Contains("static string ReadLine(runspace runspace, System.Management.Automation.EngineIntrinsics engineIntrinsics, System.Threading.CancellationToken cancellationToken, System.Nullable[bool] lastRunStatus)")

#     function PSConsoleHostReadLine {
#         # This needs to be done as the first thing because any script run will flush $?.
#         $lastRunStatus = $?

#         # Exit statuses are maintained separately for native and PowerShell commands, this needs to be taken into account.
#         $exitCode = if ($lastRunStatus) { 0 } elseif ($global:LASTEXITCODE) { $global:LASTEXITCODE } else { 1 }

#         if ($script:atuinHistoryId) {
#             # The duration is not recorded in old PowerShell versions, let Atuin handle it.
#             $duration = (Get-History -Count 1).Duration.Ticks * 100
#             $durationArg = if ($duration) { "--duration=$duration" } else { "" }

#             atuin history end --exit=$exitCode $durationArg -- $script:atuinHistoryId | Out-Null

#             $global:LASTEXITCODE = $exitCode
#             $script:atuinHistoryId = $null
#         }

#         # PSConsoleHostReadLine implementation from PSReadLine, adjusted to support old versions.
#         Microsoft.PowerShell.Core\Set-StrictMode -Off

#         $line = if ($script:hasExpectedReadLineOverload) {
#             # When the overload we expect is available, we can pass $lastRunStatus to it.
#             [Microsoft.PowerShell.PSConsoleReadLine]::ReadLine($Host.Runspace, $ExecutionContext, [System.Threading.CancellationToken]::None, $lastRunStatus)
#         } else {
#             # Either PSReadLine is older than v2.2.0-beta3, or maybe newer than we expect, so use the function from PSReadLine as-is.
#             & $script:previousPSConsoleHostReadLine
#         }

#         $script:atuinHistoryId = atuin history start -- $line

#         return $line
#     }

#     function RunSearch {
#         param([string]$ExtraArgs = "")

#         $line = $null
#         $cursor = $null
#         [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

#         # Atuin is started through Start-Process to avoid interfering with the current shell,
#         # and to capture its output which is provided in stderr (redirected to a temporary file).

#         $suggestion = ""
#         $resultFile = New-TemporaryFile
#         try {
#             $env:ATUIN_SHELL_POWERSHELL = "true"
#             $argString = "search -i $ExtraArgs -- $line"
#             Start-Process -Wait -NoNewWindow -RedirectStandardError $resultFile.FullName -FilePath atuin -ArgumentList $argString
#             $suggestion = (Get-Content -Raw $resultFile | Out-String).Trim()
#         }
#         finally {
#             $env:ATUIN_SHELL_POWERSHELL = $null
#             Remove-Item $resultFile
#         }

#         $previousOutputEncoding = [System.Console]::OutputEncoding
#         try {
#             [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8

#             # PSReadLine maintains its own cursor position, which will no longer be valid if Atuin scrolls the display in inline mode.
#             # Fortunately, InvokePrompt can receive a new Y position and reset the internal state.
#             [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt($null, $Host.UI.RawUI.CursorPosition.Y)
#         }
#         finally {
#             [System.Console]::OutputEncoding = $previousOutputEncoding
#         }

#         if ($suggestion -eq "") {
#             # The previous input was already rendered by InvokePrompt
#             return
#         }

#         $acceptPrefix = "__atuin_accept__:"

#         if ( $suggestion.StartsWith($acceptPrefix)) {
#             [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
#             [Microsoft.PowerShell.PSConsoleReadLine]::Insert($suggestion.Substring($acceptPrefix.Length))
#             [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
#         } else {
#             [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
#             [Microsoft.PowerShell.PSConsoleReadLine]::Insert($suggestion)
#         }
#     }

#     function Enable-AtuinSearchKeys {
#         param([bool]$CtrlR = $true, [bool]$UpArrow = $true)

#         if ($CtrlR) {
#             Set-PSReadLineKeyHandler -Chord "Ctrl+r" -BriefDescription "Runs Atuin search" -ScriptBlock {
#                 RunSearch
#             }
#         }

#         if ($UpArrow) {
#             Set-PSReadLineKeyHandler -Chord "UpArrow" -BriefDescription "Runs Atuin search" -ScriptBlock {
#                 $line = $null
#                 [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$null)

#                 if (!$line.Contains("`n")) {
#                     RunSearch -ExtraArgs "--shell-up-key-binding"
#                 } else {
#                     [Microsoft.PowerShell.PSConsoleReadLine]::PreviousLine()
#                 }
#             }
#         }
#     }

#     $ExecutionContext.SessionState.Module.OnRemove += {
#         $env:ATUIN_SESSION = $null
#         $Function:PSConsoleHostReadLine = $script:previousPSConsoleHostReadLine
#     }

#     Export-ModuleMember -Function @("Enable-AtuinSearchKeys", "PSConsoleHostReadLine")
# } | Import-Module -Global

# Enable-AtuinSearchKeys -CtrlR $true -UpArrow $false

# pdm completion 坏了

# hyfetch
# neofetch
# C:\Users\hash\Documents\fastfetch-windows-amd64\fastfetch.exe -c paleofetch.jsonc
& C:\msys64\${MSYSTEM}\bin\fastfetch.exe -c C:\msys64\${MSYSTEM}\share\fastfetch\presets\paleofetch.jsonc -l windows
& C:\msys64\${MSYSTEM}\bin\fortune.exe
# $choices = "chinese", "song100", "tang300"
# $choice = $choices | Get-Random
# function fortune($Path) {
#     if(!(Test-Path $Path)) {
#         throw "File not found: $path"
#     }

#     $datfile = "$Path.dat"
#     if(Test-Path $datfile) {
#         $dat = New-Object "System.IO.FileStream" $datfile, 'Open', 'Read', 'Read'
#         [byte[]] $dat_bytes = New-Object byte[] 8
#         $seek = (Get-Random -Minimum 7 -Maximum ([int]($dat.Length / 4))) * 4
#         [void] $dat.Seek($seek, 'Begin')
#         [void] $dat.Read($dat_bytes, 0, 8)
#         [array]::Reverse($dat_bytes) # Swap endianness
#         $start = [BitConverter]::ToInt32($dat_bytes, 4)
#         $end = [BitConverter]::ToInt32($dat_bytes, 0)
#         $len = $end - $start - 2
#         $dat.Close()

#         $cookie = New-Object "System.IO.FileStream" $Path, 'Open', 'Read', 'Read'
#         [byte[]] $cookie_bytes = New-Object byte[] $len
#         [void] $cookie.Seek($start, 'Begin')
#         [void] $cookie.Read($cookie_bytes, 0, $len)
#         # If you want multiple encodings you'll have to do it yourself
#         [System.Text.Encoding]::UTF8.GetString($cookie_bytes)
#         $cookie.Close()
#     } else {
#         [System.IO.File]::ReadAllText($Path) -replace "`r`n", "`n" -split "`n%`n" | Get-Random
#     }
# }
# fortune "C:\Users\hash\fortunes\debian\$choice"
# fortune-go C:\Users\hash\fortunes\data\cat


# powershell completion for chezmoi                              -*- shell-script -*-

function __chezmoi_debug {
    if ($env:BASH_COMP_DEBUG_FILE) {
        "$args" | Out-File -Append -FilePath "$env:BASH_COMP_DEBUG_FILE"
    }
}

filter __chezmoi_escapeStringWithSpecialChars {
    $_ -replace '\s|#|@|\$|;|,|''|\{|\}|\(|\)|"|`|\||<|>|&','`$&'
}

[scriptblock]${__chezmoiCompleterBlock} = {
    param(
            $WordToComplete,
            $CommandAst,
            $CursorPosition
        )

    # Get the current command line and convert into a string
    $Command = $CommandAst.CommandElements
    $Command = "$Command"

    __chezmoi_debug ""
    __chezmoi_debug "========= starting completion logic =========="
    __chezmoi_debug "WordToComplete: $WordToComplete Command: $Command CursorPosition: $CursorPosition"

    # The user could have moved the cursor backwards on the command-line.
    # We need to trigger completion from the $CursorPosition location, so we need
    # to truncate the command-line ($Command) up to the $CursorPosition location.
    # Make sure the $Command is longer then the $CursorPosition before we truncate.
    # This happens because the $Command does not include the last space.
    if ($Command.Length -gt $CursorPosition) {
        $Command=$Command.Substring(0,$CursorPosition)
    }
    __chezmoi_debug "Truncated command: $Command"

    $ShellCompDirectiveError=1
    $ShellCompDirectiveNoSpace=2
    $ShellCompDirectiveNoFileComp=4
    $ShellCompDirectiveFilterFileExt=8
    $ShellCompDirectiveFilterDirs=16
    $ShellCompDirectiveKeepOrder=32

    # Prepare the command to request completions for the program.
    # Split the command at the first space to separate the program and arguments.
    $Program,$Arguments = $Command.Split(" ",2)

    $RequestComp="$Program __complete $Arguments"
    __chezmoi_debug "RequestComp: $RequestComp"

    # we cannot use $WordToComplete because it
    # has the wrong values if the cursor was moved
    # so use the last argument
    if ($WordToComplete -ne "" ) {
        $WordToComplete = $Arguments.Split(" ")[-1]
    }
    __chezmoi_debug "New WordToComplete: $WordToComplete"


    # Check for flag with equal sign
    $IsEqualFlag = ($WordToComplete -Like "--*=*" )
    if ( $IsEqualFlag ) {
        __chezmoi_debug "Completing equal sign flag"
        # Remove the flag part
        $Flag,$WordToComplete = $WordToComplete.Split("=",2)
    }

    if ( $WordToComplete -eq "" -And ( -Not $IsEqualFlag )) {
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go method.
        __chezmoi_debug "Adding extra empty parameter"
        # PowerShell 7.2+ changed the way how the arguments are passed to executables,
        # so for pre-7.2 or when Legacy argument passing is enabled we need to use
        # `"`" to pass an empty argument, a "" or '' does not work!!!
        if ($PSVersionTable.PsVersion -lt [version]'7.2.0' -or
            ($PSVersionTable.PsVersion -lt [version]'7.3.0' -and -not [ExperimentalFeature]::IsEnabled("PSNativeCommandArgumentPassing")) -or
            (($PSVersionTable.PsVersion -ge [version]'7.3.0' -or [ExperimentalFeature]::IsEnabled("PSNativeCommandArgumentPassing")) -and
              $PSNativeCommandArgumentPassing -eq 'Legacy')) {
             $RequestComp="$RequestComp" + ' `"`"'
        } else {
             $RequestComp="$RequestComp" + ' ""'
        }
    }

    __chezmoi_debug "Calling $RequestComp"
    # First disable ActiveHelp which is not supported for Powershell
    ${env:CHEZMOI_ACTIVE_HELP}=0

    #call the command store the output in $out and redirect stderr and stdout to null
    # $Out is an array contains each line per element
    Invoke-Expression -OutVariable out "$RequestComp" 2>&1 | Out-Null

    # get directive from last line
    [int]$Directive = $Out[-1].TrimStart(':')
    if ($Directive -eq "") {
        # There is no directive specified
        $Directive = 0
    }
    __chezmoi_debug "The completion directive is: $Directive"

    # remove directive (last element) from out
    $Out = $Out | Where-Object { $_ -ne $Out[-1] }
    __chezmoi_debug "The completions are: $Out"

    if (($Directive -band $ShellCompDirectiveError) -ne 0 ) {
        # Error code.  No completion.
        __chezmoi_debug "Received error from custom completion go code"
        return
    }

    $Longest = 0
    [Array]$Values = $Out | ForEach-Object {
        #Split the output in name and description
        $Name, $Description = $_.Split("`t",2)
        __chezmoi_debug "Name: $Name Description: $Description"

        # Look for the longest completion so that we can format things nicely
        if ($Longest -lt $Name.Length) {
            $Longest = $Name.Length
        }

        # Set the description to a one space string if there is none set.
        # This is needed because the CompletionResult does not accept an empty string as argument
        if (-Not $Description) {
            $Description = " "
        }
        New-Object -TypeName PSCustomObject -Property @{
            Name = "$Name"
            Description = "$Description"
        }
    }


    $Space = " "
    if (($Directive -band $ShellCompDirectiveNoSpace) -ne 0 ) {
        # remove the space here
        __chezmoi_debug "ShellCompDirectiveNoSpace is called"
        $Space = ""
    }

    if ((($Directive -band $ShellCompDirectiveFilterFileExt) -ne 0 ) -or
       (($Directive -band $ShellCompDirectiveFilterDirs) -ne 0 ))  {
        __chezmoi_debug "ShellCompDirectiveFilterFileExt ShellCompDirectiveFilterDirs are not supported"

        # return here to prevent the completion of the extensions
        return
    }

    $Values = $Values | Where-Object {
        # filter the result
        $_.Name -like "$WordToComplete*"

        # Join the flag back if we have an equal sign flag
        if ( $IsEqualFlag ) {
            __chezmoi_debug "Join the equal sign flag back to the completion value"
            $_.Name = $Flag + "=" + $_.Name
        }
    }

    # we sort the values in ascending order by name if keep order isn't passed
    if (($Directive -band $ShellCompDirectiveKeepOrder) -eq 0 ) {
        $Values = $Values | Sort-Object -Property Name
    }

    if (($Directive -band $ShellCompDirectiveNoFileComp) -ne 0 ) {
        __chezmoi_debug "ShellCompDirectiveNoFileComp is called"

        if ($Values.Length -eq 0) {
            # Just print an empty string here so the
            # shell does not start to complete paths.
            # We cannot use CompletionResult here because
            # it does not accept an empty string as argument.
            ""
            return
        }
    }

    # Get the current mode
    $Mode = (Get-PSReadLineKeyHandler | Where-Object {$_.Key -eq "Tab" }).Function
    __chezmoi_debug "Mode: $Mode"

    $Values | ForEach-Object {

        # store temporary because switch will overwrite $_
        $comp = $_

        # PowerShell supports three different completion modes
        # - TabCompleteNext (default windows style - on each key press the next option is displayed)
        # - Complete (works like bash)
        # - MenuComplete (works like zsh)
        # You set the mode with Set-PSReadLineKeyHandler -Key Tab -Function <mode>

        # CompletionResult Arguments:
        # 1) CompletionText text to be used as the auto completion result
        # 2) ListItemText   text to be displayed in the suggestion list
        # 3) ResultType     type of completion result
        # 4) ToolTip        text for the tooltip with details about the object

        switch ($Mode) {

            # bash like
            "Complete" {

                if ($Values.Length -eq 1) {
                    __chezmoi_debug "Only one completion left"

                    # insert space after value
                    $CompletionText = $($comp.Name | __chezmoi_escapeStringWithSpecialChars) + $Space
                    if ($ExecutionContext.SessionState.LanguageMode -eq "FullLanguage"){
                        [System.Management.Automation.CompletionResult]::new($CompletionText, "$($comp.Name)", 'ParameterValue', "$($comp.Description)")
                    } else {
                        $CompletionText
                    }

                } else {
                    # Add the proper number of spaces to align the descriptions
                    while($comp.Name.Length -lt $Longest) {
                        $comp.Name = $comp.Name + " "
                    }

                    # Check for empty description and only add parentheses if needed
                    if ($($comp.Description) -eq " " ) {
                        $Description = ""
                    } else {
                        $Description = "  ($($comp.Description))"
                    }

                    $CompletionText = "$($comp.Name)$Description"
                    if ($ExecutionContext.SessionState.LanguageMode -eq "FullLanguage"){
                        [System.Management.Automation.CompletionResult]::new($CompletionText, "$($comp.Name)$Description", 'ParameterValue', "$($comp.Description)")
                    } else {
                        $CompletionText
                    }
                }
             }

            # zsh like
            "MenuComplete" {
                # insert space after value
                # MenuComplete will automatically show the ToolTip of
                # the highlighted value at the bottom of the suggestions.

                $CompletionText = $($comp.Name | __chezmoi_escapeStringWithSpecialChars) + $Space
                if ($ExecutionContext.SessionState.LanguageMode -eq "FullLanguage"){
                    [System.Management.Automation.CompletionResult]::new($CompletionText, "$($comp.Name)", 'ParameterValue', "$($comp.Description)")
                } else {
                    $CompletionText
                }
            }

            # TabCompleteNext and in case we get something unknown
            Default {
                # Like MenuComplete but we don't want to add a space here because
                # the user need to press space anyway to get the completion.
                # Description will not be shown because that's not possible with TabCompleteNext

                $CompletionText = $($comp.Name | __chezmoi_escapeStringWithSpecialChars)
                if ($ExecutionContext.SessionState.LanguageMode -eq "FullLanguage"){
                    [System.Management.Automation.CompletionResult]::new($CompletionText, "$($comp.Name)", 'ParameterValue', "$($comp.Description)")
                } else {
                    $CompletionText
                }
            }
        }

    }
}

Register-ArgumentCompleter -CommandName 'chezmoi' -ScriptBlock ${__chezmoiCompleterBlock}
# powershell completion for sing-box                             -*- shell-script -*-

function __sing-box_debug {
    if ($env:BASH_COMP_DEBUG_FILE) {
        "$args" | Out-File -Append -FilePath "$env:BASH_COMP_DEBUG_FILE"
    }
}

filter __sing-box_escapeStringWithSpecialChars {
    $_ -replace '\s|#|@|\$|;|,|''|\{|\}|\(|\)|"|`|\||<|>|&','`$&'
}

[scriptblock]${__sing_boxCompleterBlock} = {
    param(
            $WordToComplete,
            $CommandAst,
            $CursorPosition
        )

    # Get the current command line and convert into a string
    $Command = $CommandAst.CommandElements
    $Command = "$Command"

    __sing-box_debug ""
    __sing-box_debug "========= starting completion logic =========="
    __sing-box_debug "WordToComplete: $WordToComplete Command: $Command CursorPosition: $CursorPosition"

    # The user could have moved the cursor backwards on the command-line.
    # We need to trigger completion from the $CursorPosition location, so we need
    # to truncate the command-line ($Command) up to the $CursorPosition location.
    # Make sure the $Command is longer then the $CursorPosition before we truncate.
    # This happens because the $Command does not include the last space.
    if ($Command.Length -gt $CursorPosition) {
        $Command=$Command.Substring(0,$CursorPosition)
    }
    __sing-box_debug "Truncated command: $Command"

    $ShellCompDirectiveError=1
    $ShellCompDirectiveNoSpace=2
    $ShellCompDirectiveNoFileComp=4
    $ShellCompDirectiveFilterFileExt=8
    $ShellCompDirectiveFilterDirs=16
    $ShellCompDirectiveKeepOrder=32

    # Prepare the command to request completions for the program.
    # Split the command at the first space to separate the program and arguments.
    $Program,$Arguments = $Command.Split(" ",2)

    $RequestComp="$Program __complete $Arguments"
    __sing-box_debug "RequestComp: $RequestComp"

    # we cannot use $WordToComplete because it
    # has the wrong values if the cursor was moved
    # so use the last argument
    if ($WordToComplete -ne "" ) {
        $WordToComplete = $Arguments.Split(" ")[-1]
    }
    __sing-box_debug "New WordToComplete: $WordToComplete"


    # Check for flag with equal sign
    $IsEqualFlag = ($WordToComplete -Like "--*=*" )
    if ( $IsEqualFlag ) {
        __sing-box_debug "Completing equal sign flag"
        # Remove the flag part
        $Flag,$WordToComplete = $WordToComplete.Split("=",2)
    }

    if ( $WordToComplete -eq "" -And ( -Not $IsEqualFlag )) {
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go method.
        __sing-box_debug "Adding extra empty parameter"
        # PowerShell 7.2+ changed the way how the arguments are passed to executables,
        # so for pre-7.2 or when Legacy argument passing is enabled we need to use
        # `"`" to pass an empty argument, a "" or '' does not work!!!
        if ($PSVersionTable.PsVersion -lt [version]'7.2.0' -or
            ($PSVersionTable.PsVersion -lt [version]'7.3.0' -and -not [ExperimentalFeature]::IsEnabled("PSNativeCommandArgumentPassing")) -or
            (($PSVersionTable.PsVersion -ge [version]'7.3.0' -or [ExperimentalFeature]::IsEnabled("PSNativeCommandArgumentPassing")) -and
              $PSNativeCommandArgumentPassing -eq 'Legacy')) {
             $RequestComp="$RequestComp" + ' `"`"'
        } else {
             $RequestComp="$RequestComp" + ' ""'
        }
    }

    __sing-box_debug "Calling $RequestComp"
    # First disable ActiveHelp which is not supported for Powershell
    ${env:SING_BOX_ACTIVE_HELP}=0

    #call the command store the output in $out and redirect stderr and stdout to null
    # $Out is an array contains each line per element
    Invoke-Expression -OutVariable out "$RequestComp" 2>&1 | Out-Null

    # get directive from last line
    [int]$Directive = $Out[-1].TrimStart(':')
    if ($Directive -eq "") {
        # There is no directive specified
        $Directive = 0
    }
    __sing-box_debug "The completion directive is: $Directive"

    # remove directive (last element) from out
    $Out = $Out | Where-Object { $_ -ne $Out[-1] }
    __sing-box_debug "The completions are: $Out"

    if (($Directive -band $ShellCompDirectiveError) -ne 0 ) {
        # Error code.  No completion.
        __sing-box_debug "Received error from custom completion go code"
        return
    }

    $Longest = 0
    [Array]$Values = $Out | ForEach-Object {
        #Split the output in name and description
        $Name, $Description = $_.Split("`t",2)
        __sing-box_debug "Name: $Name Description: $Description"

        # Look for the longest completion so that we can format things nicely
        if ($Longest -lt $Name.Length) {
            $Longest = $Name.Length
        }

        # Set the description to a one space string if there is none set.
        # This is needed because the CompletionResult does not accept an empty string as argument
        if (-Not $Description) {
            $Description = " "
        }
        New-Object -TypeName PSCustomObject -Property @{
            Name = "$Name"
            Description = "$Description"
        }
    }


    $Space = " "
    if (($Directive -band $ShellCompDirectiveNoSpace) -ne 0 ) {
        # remove the space here
        __sing-box_debug "ShellCompDirectiveNoSpace is called"
        $Space = ""
    }

    if ((($Directive -band $ShellCompDirectiveFilterFileExt) -ne 0 ) -or
       (($Directive -band $ShellCompDirectiveFilterDirs) -ne 0 ))  {
        __sing-box_debug "ShellCompDirectiveFilterFileExt ShellCompDirectiveFilterDirs are not supported"

        # return here to prevent the completion of the extensions
        return
    }

    $Values = $Values | Where-Object {
        # filter the result
        $_.Name -like "$WordToComplete*"

        # Join the flag back if we have an equal sign flag
        if ( $IsEqualFlag ) {
            __sing-box_debug "Join the equal sign flag back to the completion value"
            $_.Name = $Flag + "=" + $_.Name
        }
    }

    # we sort the values in ascending order by name if keep order isn't passed
    if (($Directive -band $ShellCompDirectiveKeepOrder) -eq 0 ) {
        $Values = $Values | Sort-Object -Property Name
    }

    if (($Directive -band $ShellCompDirectiveNoFileComp) -ne 0 ) {
        __sing-box_debug "ShellCompDirectiveNoFileComp is called"

        if ($Values.Length -eq 0) {
            # Just print an empty string here so the
            # shell does not start to complete paths.
            # We cannot use CompletionResult here because
            # it does not accept an empty string as argument.
            ""
            return
        }
    }

    # Get the current mode
    $Mode = (Get-PSReadLineKeyHandler | Where-Object {$_.Key -eq "Tab" }).Function
    __sing-box_debug "Mode: $Mode"

    $Values | ForEach-Object {

        # store temporary because switch will overwrite $_
        $comp = $_

        # PowerShell supports three different completion modes
        # - TabCompleteNext (default windows style - on each key press the next option is displayed)
        # - Complete (works like bash)
        # - MenuComplete (works like zsh)
        # You set the mode with Set-PSReadLineKeyHandler -Key Tab -Function <mode>

        # CompletionResult Arguments:
        # 1) CompletionText text to be used as the auto completion result
        # 2) ListItemText   text to be displayed in the suggestion list
        # 3) ResultType     type of completion result
        # 4) ToolTip        text for the tooltip with details about the object

        switch ($Mode) {

            # bash like
            "Complete" {

                if ($Values.Length -eq 1) {
                    __sing-box_debug "Only one completion left"

                    # insert space after value
                    $CompletionText = $($comp.Name | __sing-box_escapeStringWithSpecialChars) + $Space
                    if ($ExecutionContext.SessionState.LanguageMode -eq "FullLanguage"){
                        [System.Management.Automation.CompletionResult]::new($CompletionText, "$($comp.Name)", 'ParameterValue', "$($comp.Description)")
                    } else {
                        $CompletionText
                    }

                } else {
                    # Add the proper number of spaces to align the descriptions
                    while($comp.Name.Length -lt $Longest) {
                        $comp.Name = $comp.Name + " "
                    }

                    # Check for empty description and only add parentheses if needed
                    if ($($comp.Description) -eq " " ) {
                        $Description = ""
                    } else {
                        $Description = "  ($($comp.Description))"
                    }

                    $CompletionText = "$($comp.Name)$Description"
                    if ($ExecutionContext.SessionState.LanguageMode -eq "FullLanguage"){
                        [System.Management.Automation.CompletionResult]::new($CompletionText, "$($comp.Name)$Description", 'ParameterValue', "$($comp.Description)")
                    } else {
                        $CompletionText
                    }
                }
             }

            # zsh like
            "MenuComplete" {
                # insert space after value
                # MenuComplete will automatically show the ToolTip of
                # the highlighted value at the bottom of the suggestions.

                $CompletionText = $($comp.Name | __sing-box_escapeStringWithSpecialChars) + $Space
                if ($ExecutionContext.SessionState.LanguageMode -eq "FullLanguage"){
                    [System.Management.Automation.CompletionResult]::new($CompletionText, "$($comp.Name)", 'ParameterValue', "$($comp.Description)")
                } else {
                    $CompletionText
                }
            }

            # TabCompleteNext and in case we get something unknown
            Default {
                # Like MenuComplete but we don't want to add a space here because
                # the user need to press space anyway to get the completion.
                # Description will not be shown because that's not possible with TabCompleteNext

                $CompletionText = $($comp.Name | __sing-box_escapeStringWithSpecialChars)
                if ($ExecutionContext.SessionState.LanguageMode -eq "FullLanguage"){
                    [System.Management.Automation.CompletionResult]::new($CompletionText, "$($comp.Name)", 'ParameterValue', "$($comp.Description)")
                } else {
                    $CompletionText
                }
            }
        }

    }
}

Register-ArgumentCompleter -CommandName 'sing-box' -ScriptBlock ${__sing_boxCompleterBlock}
# powershell completion for rclone                               -*- shell-script -*-

function __rclone_debug {
    if ($env:BASH_COMP_DEBUG_FILE) {
        "$args" | Out-File -Append -FilePath "$env:BASH_COMP_DEBUG_FILE"
    }
}

filter __rclone_escapeStringWithSpecialChars {
    $_ -replace '\s|#|@|\$|;|,|''|\{|\}|\(|\)|"|`|\||<|>|&','`$&'
}

[scriptblock]${__rcloneCompleterBlock} = {
    param(
            $WordToComplete,
            $CommandAst,
            $CursorPosition
        )

    # Get the current command line and convert into a string
    $Command = $CommandAst.CommandElements
    $Command = "$Command"

    __rclone_debug ""
    __rclone_debug "========= starting completion logic =========="
    __rclone_debug "WordToComplete: $WordToComplete Command: $Command CursorPosition: $CursorPosition"

    # The user could have moved the cursor backwards on the command-line.
    # We need to trigger completion from the $CursorPosition location, so we need
    # to truncate the command-line ($Command) up to the $CursorPosition location.
    # Make sure the $Command is longer then the $CursorPosition before we truncate.
    # This happens because the $Command does not include the last space.
    if ($Command.Length -gt $CursorPosition) {
        $Command=$Command.Substring(0,$CursorPosition)
    }
    __rclone_debug "Truncated command: $Command"

    $ShellCompDirectiveError=1
    $ShellCompDirectiveNoSpace=2
    $ShellCompDirectiveNoFileComp=4
    $ShellCompDirectiveFilterFileExt=8
    $ShellCompDirectiveFilterDirs=16
    $ShellCompDirectiveKeepOrder=32

    # Prepare the command to request completions for the program.
    # Split the command at the first space to separate the program and arguments.
    $Program,$Arguments = $Command.Split(" ",2)

    $RequestComp="$Program __completeNoDesc $Arguments"
    __rclone_debug "RequestComp: $RequestComp"

    # we cannot use $WordToComplete because it
    # has the wrong values if the cursor was moved
    # so use the last argument
    if ($WordToComplete -ne "" ) {
        $WordToComplete = $Arguments.Split(" ")[-1]
    }
    __rclone_debug "New WordToComplete: $WordToComplete"


    # Check for flag with equal sign
    $IsEqualFlag = ($WordToComplete -Like "--*=*" )
    if ( $IsEqualFlag ) {
        __rclone_debug "Completing equal sign flag"
        # Remove the flag part
        $Flag,$WordToComplete = $WordToComplete.Split("=",2)
    }

    if ( $WordToComplete -eq "" -And ( -Not $IsEqualFlag )) {
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go method.
        __rclone_debug "Adding extra empty parameter"
        # PowerShell 7.2+ changed the way how the arguments are passed to executables,
        # so for pre-7.2 or when Legacy argument passing is enabled we need to use
        # `"`" to pass an empty argument, a "" or '' does not work!!!
        if ($PSVersionTable.PsVersion -lt [version]'7.2.0' -or
            ($PSVersionTable.PsVersion -lt [version]'7.3.0' -and -not [ExperimentalFeature]::IsEnabled("PSNativeCommandArgumentPassing")) -or
            (($PSVersionTable.PsVersion -ge [version]'7.3.0' -or [ExperimentalFeature]::IsEnabled("PSNativeCommandArgumentPassing")) -and
              $PSNativeCommandArgumentPassing -eq 'Legacy')) {
             $RequestComp="$RequestComp" + ' `"`"'
        } else {
             $RequestComp="$RequestComp" + ' ""'
        }
    }

    __rclone_debug "Calling $RequestComp"
    # First disable ActiveHelp which is not supported for Powershell
    ${env:RCLONE_ACTIVE_HELP}=0

    #call the command store the output in $out and redirect stderr and stdout to null
    # $Out is an array contains each line per element
    Invoke-Expression -OutVariable out "$RequestComp" 2>&1 | Out-Null

    # get directive from last line
    [int]$Directive = $Out[-1].TrimStart(':')
    if ($Directive -eq "") {
        # There is no directive specified
        $Directive = 0
    }
    __rclone_debug "The completion directive is: $Directive"

    # remove directive (last element) from out
    $Out = $Out | Where-Object { $_ -ne $Out[-1] }
    __rclone_debug "The completions are: $Out"

    if (($Directive -band $ShellCompDirectiveError) -ne 0 ) {
        # Error code.  No completion.
        __rclone_debug "Received error from custom completion go code"
        return
    }

    $Longest = 0
    [Array]$Values = $Out | ForEach-Object {
        #Split the output in name and description
        $Name, $Description = $_.Split("`t",2)
        __rclone_debug "Name: $Name Description: $Description"

        # Look for the longest completion so that we can format things nicely
        if ($Longest -lt $Name.Length) {
            $Longest = $Name.Length
        }

        # Set the description to a one space string if there is none set.
        # This is needed because the CompletionResult does not accept an empty string as argument
        if (-Not $Description) {
            $Description = " "
        }
        New-Object -TypeName PSCustomObject -Property @{
            Name = "$Name"
            Description = "$Description"
        }
    }


    $Space = " "
    if (($Directive -band $ShellCompDirectiveNoSpace) -ne 0 ) {
        # remove the space here
        __rclone_debug "ShellCompDirectiveNoSpace is called"
        $Space = ""
    }

    if ((($Directive -band $ShellCompDirectiveFilterFileExt) -ne 0 ) -or
       (($Directive -band $ShellCompDirectiveFilterDirs) -ne 0 ))  {
        __rclone_debug "ShellCompDirectiveFilterFileExt ShellCompDirectiveFilterDirs are not supported"

        # return here to prevent the completion of the extensions
        return
    }

    $Values = $Values | Where-Object {
        # filter the result
        $_.Name -like "$WordToComplete*"

        # Join the flag back if we have an equal sign flag
        if ( $IsEqualFlag ) {
            __rclone_debug "Join the equal sign flag back to the completion value"
            $_.Name = $Flag + "=" + $_.Name
        }
    }

    # we sort the values in ascending order by name if keep order isn't passed
    if (($Directive -band $ShellCompDirectiveKeepOrder) -eq 0 ) {
        $Values = $Values | Sort-Object -Property Name
    }

    if (($Directive -band $ShellCompDirectiveNoFileComp) -ne 0 ) {
        __rclone_debug "ShellCompDirectiveNoFileComp is called"

        if ($Values.Length -eq 0) {
            # Just print an empty string here so the
            # shell does not start to complete paths.
            # We cannot use CompletionResult here because
            # it does not accept an empty string as argument.
            ""
            return
        }
    }

    # Get the current mode
    $Mode = (Get-PSReadLineKeyHandler | Where-Object {$_.Key -eq "Tab" }).Function
    __rclone_debug "Mode: $Mode"

    $Values | ForEach-Object {

        # store temporary because switch will overwrite $_
        $comp = $_

        # PowerShell supports three different completion modes
        # - TabCompleteNext (default windows style - on each key press the next option is displayed)
        # - Complete (works like bash)
        # - MenuComplete (works like zsh)
        # You set the mode with Set-PSReadLineKeyHandler -Key Tab -Function <mode>

        # CompletionResult Arguments:
        # 1) CompletionText text to be used as the auto completion result
        # 2) ListItemText   text to be displayed in the suggestion list
        # 3) ResultType     type of completion result
        # 4) ToolTip        text for the tooltip with details about the object

        switch ($Mode) {

            # bash like
            "Complete" {

                if ($Values.Length -eq 1) {
                    __rclone_debug "Only one completion left"

                    # insert space after value
                    $CompletionText = $($comp.Name | __rclone_escapeStringWithSpecialChars) + $Space
                    if ($ExecutionContext.SessionState.LanguageMode -eq "FullLanguage"){
                        [System.Management.Automation.CompletionResult]::new($CompletionText, "$($comp.Name)", 'ParameterValue', "$($comp.Description)")
                    } else {
                        $CompletionText
                    }

                } else {
                    # Add the proper number of spaces to align the descriptions
                    while($comp.Name.Length -lt $Longest) {
                        $comp.Name = $comp.Name + " "
                    }

                    # Check for empty description and only add parentheses if needed
                    if ($($comp.Description) -eq " " ) {
                        $Description = ""
                    } else {
                        $Description = "  ($($comp.Description))"
                    }

                    $CompletionText = "$($comp.Name)$Description"
                    if ($ExecutionContext.SessionState.LanguageMode -eq "FullLanguage"){
                        [System.Management.Automation.CompletionResult]::new($CompletionText, "$($comp.Name)$Description", 'ParameterValue', "$($comp.Description)")
                    } else {
                        $CompletionText
                    }
                }
             }

            # zsh like
            "MenuComplete" {
                # insert space after value
                # MenuComplete will automatically show the ToolTip of
                # the highlighted value at the bottom of the suggestions.

                $CompletionText = $($comp.Name | __rclone_escapeStringWithSpecialChars) + $Space
                if ($ExecutionContext.SessionState.LanguageMode -eq "FullLanguage"){
                    [System.Management.Automation.CompletionResult]::new($CompletionText, "$($comp.Name)", 'ParameterValue', "$($comp.Description)")
                } else {
                    $CompletionText
                }
            }

            # TabCompleteNext and in case we get something unknown
            Default {
                # Like MenuComplete but we don't want to add a space here because
                # the user need to press space anyway to get the completion.
                # Description will not be shown because that's not possible with TabCompleteNext

                $CompletionText = $($comp.Name | __rclone_escapeStringWithSpecialChars)
                if ($ExecutionContext.SessionState.LanguageMode -eq "FullLanguage"){
                    [System.Management.Automation.CompletionResult]::new($CompletionText, "$($comp.Name)", 'ParameterValue', "$($comp.Description)")
                } else {
                    $CompletionText
                }
            }
        }

    }
}

Register-ArgumentCompleter -CommandName 'rclone' -ScriptBlock ${__rcloneCompleterBlock}
# powershell completion for caddy                                -*- shell-script -*-

function __caddy_debug {
    if ($env:BASH_COMP_DEBUG_FILE) {
        "$args" | Out-File -Append -FilePath "$env:BASH_COMP_DEBUG_FILE"
    }
}

filter __caddy_escapeStringWithSpecialChars {
    $_ -replace '\s|#|@|\$|;|,|''|\{|\}|\(|\)|"|`|\||<|>|&','`$&'
}

[scriptblock]${__caddyCompleterBlock} = {
    param(
            $WordToComplete,
            $CommandAst,
            $CursorPosition
        )

    # Get the current command line and convert into a string
    $Command = $CommandAst.CommandElements
    $Command = "$Command"

    __caddy_debug ""
    __caddy_debug "========= starting completion logic =========="
    __caddy_debug "WordToComplete: $WordToComplete Command: $Command CursorPosition: $CursorPosition"

    # The user could have moved the cursor backwards on the command-line.
    # We need to trigger completion from the $CursorPosition location, so we need
    # to truncate the command-line ($Command) up to the $CursorPosition location.
    # Make sure the $Command is longer then the $CursorPosition before we truncate.
    # This happens because the $Command does not include the last space.
    if ($Command.Length -gt $CursorPosition) {
        $Command=$Command.Substring(0,$CursorPosition)
    }
    __caddy_debug "Truncated command: $Command"

    $ShellCompDirectiveError=1
    $ShellCompDirectiveNoSpace=2
    $ShellCompDirectiveNoFileComp=4
    $ShellCompDirectiveFilterFileExt=8
    $ShellCompDirectiveFilterDirs=16
    $ShellCompDirectiveKeepOrder=32

    # Prepare the command to request completions for the program.
    # Split the command at the first space to separate the program and arguments.
    $Program,$Arguments = $Command.Split(" ",2)

    $RequestComp="$Program __complete $Arguments"
    __caddy_debug "RequestComp: $RequestComp"

    # we cannot use $WordToComplete because it
    # has the wrong values if the cursor was moved
    # so use the last argument
    if ($WordToComplete -ne "" ) {
        $WordToComplete = $Arguments.Split(" ")[-1]
    }
    __caddy_debug "New WordToComplete: $WordToComplete"


    # Check for flag with equal sign
    $IsEqualFlag = ($WordToComplete -Like "--*=*" )
    if ( $IsEqualFlag ) {
        __caddy_debug "Completing equal sign flag"
        # Remove the flag part
        $Flag,$WordToComplete = $WordToComplete.Split("=",2)
    }

    if ( $WordToComplete -eq "" -And ( -Not $IsEqualFlag )) {
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go method.
        __caddy_debug "Adding extra empty parameter"
        # PowerShell 7.2+ changed the way how the arguments are passed to executables,
        # so for pre-7.2 or when Legacy argument passing is enabled we need to use
        # `"`" to pass an empty argument, a "" or '' does not work!!!
        if ($PSVersionTable.PsVersion -lt [version]'7.2.0' -or
            ($PSVersionTable.PsVersion -lt [version]'7.3.0' -and -not [ExperimentalFeature]::IsEnabled("PSNativeCommandArgumentPassing")) -or
            (($PSVersionTable.PsVersion -ge [version]'7.3.0' -or [ExperimentalFeature]::IsEnabled("PSNativeCommandArgumentPassing")) -and
              $PSNativeCommandArgumentPassing -eq 'Legacy')) {
             $RequestComp="$RequestComp" + ' `"`"'
        } else {
             $RequestComp="$RequestComp" + ' ""'
        }
    }

    __caddy_debug "Calling $RequestComp"
    # First disable ActiveHelp which is not supported for Powershell
    ${env:CADDY_ACTIVE_HELP}=0

    #call the command store the output in $out and redirect stderr and stdout to null
    # $Out is an array contains each line per element
    Invoke-Expression -OutVariable out "$RequestComp" 2>&1 | Out-Null

    # get directive from last line
    [int]$Directive = $Out[-1].TrimStart(':')
    if ($Directive -eq "") {
        # There is no directive specified
        $Directive = 0
    }
    __caddy_debug "The completion directive is: $Directive"

    # remove directive (last element) from out
    $Out = $Out | Where-Object { $_ -ne $Out[-1] }
    __caddy_debug "The completions are: $Out"

    if (($Directive -band $ShellCompDirectiveError) -ne 0 ) {
        # Error code.  No completion.
        __caddy_debug "Received error from custom completion go code"
        return
    }

    $Longest = 0
    [Array]$Values = $Out | ForEach-Object {
        #Split the output in name and description
        $Name, $Description = $_.Split("`t",2)
        __caddy_debug "Name: $Name Description: $Description"

        # Look for the longest completion so that we can format things nicely
        if ($Longest -lt $Name.Length) {
            $Longest = $Name.Length
        }

        # Set the description to a one space string if there is none set.
        # This is needed because the CompletionResult does not accept an empty string as argument
        if (-Not $Description) {
            $Description = " "
        }
        New-Object -TypeName PSCustomObject -Property @{
            Name = "$Name"
            Description = "$Description"
        }
    }


    $Space = " "
    if (($Directive -band $ShellCompDirectiveNoSpace) -ne 0 ) {
        # remove the space here
        __caddy_debug "ShellCompDirectiveNoSpace is called"
        $Space = ""
    }

    if ((($Directive -band $ShellCompDirectiveFilterFileExt) -ne 0 ) -or
       (($Directive -band $ShellCompDirectiveFilterDirs) -ne 0 ))  {
        __caddy_debug "ShellCompDirectiveFilterFileExt ShellCompDirectiveFilterDirs are not supported"

        # return here to prevent the completion of the extensions
        return
    }

    $Values = $Values | Where-Object {
        # filter the result
        $_.Name -like "$WordToComplete*"

        # Join the flag back if we have an equal sign flag
        if ( $IsEqualFlag ) {
            __caddy_debug "Join the equal sign flag back to the completion value"
            $_.Name = $Flag + "=" + $_.Name
        }
    }

    # we sort the values in ascending order by name if keep order isn't passed
    if (($Directive -band $ShellCompDirectiveKeepOrder) -eq 0 ) {
        $Values = $Values | Sort-Object -Property Name
    }

    if (($Directive -band $ShellCompDirectiveNoFileComp) -ne 0 ) {
        __caddy_debug "ShellCompDirectiveNoFileComp is called"

        if ($Values.Length -eq 0) {
            # Just print an empty string here so the
            # shell does not start to complete paths.
            # We cannot use CompletionResult here because
            # it does not accept an empty string as argument.
            ""
            return
        }
    }

    # Get the current mode
    $Mode = (Get-PSReadLineKeyHandler | Where-Object {$_.Key -eq "Tab" }).Function
    __caddy_debug "Mode: $Mode"

    $Values | ForEach-Object {

        # store temporary because switch will overwrite $_
        $comp = $_

        # PowerShell supports three different completion modes
        # - TabCompleteNext (default windows style - on each key press the next option is displayed)
        # - Complete (works like bash)
        # - MenuComplete (works like zsh)
        # You set the mode with Set-PSReadLineKeyHandler -Key Tab -Function <mode>

        # CompletionResult Arguments:
        # 1) CompletionText text to be used as the auto completion result
        # 2) ListItemText   text to be displayed in the suggestion list
        # 3) ResultType     type of completion result
        # 4) ToolTip        text for the tooltip with details about the object

        switch ($Mode) {

            # bash like
            "Complete" {

                if ($Values.Length -eq 1) {
                    __caddy_debug "Only one completion left"

                    # insert space after value
                    $CompletionText = $($comp.Name | __caddy_escapeStringWithSpecialChars) + $Space
                    if ($ExecutionContext.SessionState.LanguageMode -eq "FullLanguage"){
                        [System.Management.Automation.CompletionResult]::new($CompletionText, "$($comp.Name)", 'ParameterValue', "$($comp.Description)")
                    } else {
                        $CompletionText
                    }

                } else {
                    # Add the proper number of spaces to align the descriptions
                    while($comp.Name.Length -lt $Longest) {
                        $comp.Name = $comp.Name + " "
                    }

                    # Check for empty description and only add parentheses if needed
                    if ($($comp.Description) -eq " " ) {
                        $Description = ""
                    } else {
                        $Description = "  ($($comp.Description))"
                    }

                    $CompletionText = "$($comp.Name)$Description"
                    if ($ExecutionContext.SessionState.LanguageMode -eq "FullLanguage"){
                        [System.Management.Automation.CompletionResult]::new($CompletionText, "$($comp.Name)$Description", 'ParameterValue', "$($comp.Description)")
                    } else {
                        $CompletionText
                    }
                }
             }

            # zsh like
            "MenuComplete" {
                # insert space after value
                # MenuComplete will automatically show the ToolTip of
                # the highlighted value at the bottom of the suggestions.

                $CompletionText = $($comp.Name | __caddy_escapeStringWithSpecialChars) + $Space
                if ($ExecutionContext.SessionState.LanguageMode -eq "FullLanguage"){
                    [System.Management.Automation.CompletionResult]::new($CompletionText, "$($comp.Name)", 'ParameterValue', "$($comp.Description)")
                } else {
                    $CompletionText
                }
            }

            # TabCompleteNext and in case we get something unknown
            Default {
                # Like MenuComplete but we don't want to add a space here because
                # the user need to press space anyway to get the completion.
                # Description will not be shown because that's not possible with TabCompleteNext

                $CompletionText = $($comp.Name | __caddy_escapeStringWithSpecialChars)
                if ($ExecutionContext.SessionState.LanguageMode -eq "FullLanguage"){
                    [System.Management.Automation.CompletionResult]::new($CompletionText, "$($comp.Name)", 'ParameterValue', "$($comp.Description)")
                } else {
                    $CompletionText
                }
            }
        }

    }
}

Register-ArgumentCompleter -CommandName 'caddy' -ScriptBlock ${__caddyCompleterBlock}

###-begin-pnpm-completion-###

Register-ArgumentCompleter -CommandName 'pnpm' -ScriptBlock {
    param(
            $WordToComplete,
            $CommandAst,
            $CursorPosition
        )

    function __pnpm_debug {
        if ($env:BASH_COMP_DEBUG_FILE) {
            "$args" | Out-File -Append -FilePath "$env:BASH_COMP_DEBUG_FILE"
        }
    }

    filter __pnpm_escapeStringWithSpecialChars {
        $_ -replace '\s|#|@|\$|;|,|''|\{|\}|\(|\)|"|`|\||<|>|&','`$&'
    }

    # Get the current command line and convert into a string
    $Command = $CommandAst.CommandElements
    $Command = "$Command"

    __pnpm_debug ""
    __pnpm_debug "========= starting completion logic =========="
    __pnpm_debug "WordToComplete: $WordToComplete Command: $Command CursorPosition: $CursorPosition"

    # The user could have moved the cursor backwards on the command-line.
    # We need to trigger completion from the $CursorPosition location, so we need
    # to truncate the command-line ($Command) up to the $CursorPosition location.
    # Make sure the $Command is longer then the $CursorPosition before we truncate.
    # This happens because the $Command does not include the last space.
    if ($Command.Length -gt $CursorPosition) {
        $Command=$Command.Substring(0,$CursorPosition)
    }
    __pnpm_debug "Truncated command: $Command"

    # Prepare the command to request completions for the program.
    # Split the command at the first space to separate the program and arguments.
    $Program,$Arguments = $Command.Split(" ",2)
    $RequestComp="$Program completion-server"
    __pnpm_debug "RequestComp: $RequestComp"

    # we cannot use $WordToComplete because it
    # has the wrong values if the cursor was moved
    # so use the last argument
    if ($WordToComplete -ne "" ) {
        $WordToComplete = $Arguments.Split(" ")[-1]
    }
    __pnpm_debug "New WordToComplete: $WordToComplete"


    # Check for flag with equal sign
    $IsEqualFlag = ($WordToComplete -Like "--*=*" )
    if ( $IsEqualFlag ) {
        __pnpm_debug "Completing equal sign flag"
        # Remove the flag part
        $Flag,$WordToComplete = $WordToComplete.Split("=",2)
    }

    if ( $WordToComplete -eq "" -And ( -Not $IsEqualFlag )) {
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go method.
        __pnpm_debug "Adding extra empty parameter"
        # We need to use `"`" to pass an empty argument a "" or '' does not work!!!
        $Command="$Command" + ' `"`"'
    }

    __pnpm_debug "Calling $RequestComp"

    $oldenv = ($env:SHELL, $env:COMP_CWORD, $env:COMP_LINE, $env:COMP_POINT)
    $env:SHELL = "pwsh"
    $env:COMP_CWORD = $Command.Split(" ").Count - 1
    $env:COMP_POINT = $CursorPosition
    $env:COMP_LINE = $Command

    try {
        #call the command store the output in $out and redirect stderr and stdout to null
        # $Out is an array contains each line per element
        Invoke-Expression -OutVariable out "$RequestComp" 2>&1 | Out-Null
    } finally {
        ($env:SHELL, $env:COMP_CWORD, $env:COMP_LINE, $env:COMP_POINT) = $oldenv
    }

    __pnpm_debug "The completions are: $Out"

    $Longest = 0
    $Values = $Out | ForEach-Object {
        #Split the output in name and description
        $Name, $Description = $_.Split("`t",2)
        __pnpm_debug "Name: $Name Description: $Description"

        # Look for the longest completion so that we can format things nicely
        if ($Longest -lt $Name.Length) {
            $Longest = $Name.Length
        }

        # Set the description to a one space string if there is none set.
        # This is needed because the CompletionResult does not accept an empty string as argument
        if (-Not $Description) {
            $Description = " "
        }
        @{Name="$Name";Description="$Description"}
    }


    $Space = " "
    $Values = $Values | Where-Object {
        # filter the result
        if (-not $WordToComplete.StartsWith("-") -and $_.Name.StartsWith("-")) {
            # skip flag completions unless a dash is present
            return
        } else {
            $_.Name -like "$WordToComplete*"
        }

        # Join the flag back if we have an equal sign flag
        if ( $IsEqualFlag ) {
            __pnpm_debug "Join the equal sign flag back to the completion value"
            $_.Name = $Flag + "=" + $_.Name
        }
    }

    # Get the current mode
    $Mode = (Get-PSReadLineKeyHandler | Where-Object {$_.Key -eq "Tab" }).Function
    __pnpm_debug "Mode: $Mode"

    $Values | ForEach-Object {

        # store temporary because switch will overwrite $_
        $comp = $_

        # PowerShell supports three different completion modes
        # - TabCompleteNext (default windows style - on each key press the next option is displayed)
        # - Complete (works like bash)
        # - MenuComplete (works like zsh)
        # You set the mode with Set-PSReadLineKeyHandler -Key Tab -Function <mode>

        # CompletionResult Arguments:
        # 1) CompletionText text to be used as the auto completion result
        # 2) ListItemText   text to be displayed in the suggestion list
        # 3) ResultType     type of completion result
        # 4) ToolTip        text for the tooltip with details about the object

        switch ($Mode) {

            # bash like
            "Complete" {

                if ($Values.Length -eq 1) {
                    __pnpm_debug "Only one completion left"

                    # insert space after value
                    [System.Management.Automation.CompletionResult]::new($($comp.Name | __pnpm_escapeStringWithSpecialChars) + $Space, "$($comp.Name)", 'ParameterValue', "$($comp.Description)")

                } else {
                    # Add the proper number of spaces to align the descriptions
                    while($comp.Name.Length -lt $Longest) {
                        $comp.Name = $comp.Name + " "
                    }

                    # Check for empty description and only add parentheses if needed
                    if ($($comp.Description) -eq " " ) {
                        $Description = ""
                    } else {
                        $Description = "  ($($comp.Description))"
                    }

                    [System.Management.Automation.CompletionResult]::new("$($comp.Name)$Description", "$($comp.Name)$Description", 'ParameterValue', "$($comp.Description)")
                }
             }

            # zsh like
            "MenuComplete" {
                # insert space after value
                # MenuComplete will automatically show the ToolTip of
                # the highlighted value at the bottom of the suggestions.
                [System.Management.Automation.CompletionResult]::new($($comp.Name | __pnpm_escapeStringWithSpecialChars) + $Space, "$($comp.Name)", 'ParameterValue', "$($comp.Description)")
            }

            # TabCompleteNext and in case we get something unknown
            Default {
                # Like MenuComplete but we don't want to add a space here because
                # the user need to press space anyway to get the completion.
                # Description will not be shown because that's not possible with TabCompleteNext
                [System.Management.Automation.CompletionResult]::new($($comp.Name | __pnpm_escapeStringWithSpecialChars), "$($comp.Name)", 'ParameterValue', "$($comp.Description)")
            }
        }

    }
}

###-end-pnpm-completion-###

