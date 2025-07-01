# dotfiles

我的 dotfiles 的一部分子集，由 [chezmoi](https://www.chezmoi.io/) 管理。

我看重 chezmoi 的跨平台能力。我主要采用的平台为 Windows 和 openSUSE WSL2，最近在玩票 Windows on ARM。

## 不由 chezmoi 管理的

* [.emacs.d](https://github.com/Master-Hash/.emacs.d)
* ~/.ssh/*.pem
* ~/.gnupg
* ~/age.pem
* 两步认证的恢复密钥
* 网络配置

## 需要手动处理的

Windows 有一大票环境变量、注册表、组策略、设置项、powercfg 要设置。一一枚举过于繁杂。

不完全枚举：

* [禁用联网搜索](https://www.landiannews.com/archives/107320.html)
* [卸载小组件](https://www.landiannews.com/archives/95616.html)
* [卸载 Edge 和 Webview2](https://github.com/ShadowWhisperer/Remove-MS-Edge)
* [管理员保护，以及提权时需要密码](https://www.landiannews.com/archives/106731.html)

----

我的代理软件配置由 OneDrive 加手动同步，不管理版本。

2025年夏起，我结合使用 OpenVPN，sing-box 和 naïve。过去的 mihomo 配置存留作参考。

----

msys2 的 gnupg 质量甚低，我个人推荐 Gpg4win。如果一定要用，请关闭 Emacs 的 gpg 校验，并手动创建以下两处符号链接：

```cmd
mklink /J C:\msys64\${MSYSTEM}\home %HOMEPATH%\.gnupg
mklink /J C:\msys64\${MSYSTEM}\gnupg %HOMEPATH%\.gnupg
```

----

msys2 的 bash home 路径在 %USERPROFILE% 之外，无法统一管理。我建议从 Linux 的 .profile 和 .bashrc 里摘取有用部分。

## 有用的指南

* [在模板里引用加密文件的办法](https://github.com/twpayne/chezmoi/discussions/3713)
