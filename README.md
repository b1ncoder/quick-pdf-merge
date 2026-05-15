# Quick PDF Merge

Choose a language / 选择语言:

<details open>
<summary><strong>中文说明</strong></summary>

## 简介

Quick PDF Merge 是一个用于 Windows 的轻量 PDF 合并工具。安装后，可以在资源管理器中选中多个 PDF，通过右键菜单的 `发送到 -> 合并PDF` 直接合并文件。

成功合并时程序会静默运行，不弹出命令行窗口，也不显示成功提示；只有在合并失败、依赖缺失、文件不足等异常情况下才会弹窗提示。

## 功能

- 支持在 Windows 资源管理器中多选 PDF 后合并。
- 输出文件会保存到第一个 PDF 所在目录。
- 默认输出文件名为 `merged.pdf`。
- 如果 `merged.pdf` 已存在，会自动生成 `merged_001.pdf`、`merged_002.pdf` 等文件名。
- 成功时后台静默运行。
- 失败时弹窗提示原因。
- 安装脚本会生成 Total Commander 用户菜单配置提示。

## 系统要求

- Windows
- Python 3.8 或更高版本
- `pypdf`

安装脚本会自动安装 `pypdf`。也可以手动安装：

```powershell
python -m pip install -r requirements.txt
```

## 安装

下载 Release ZIP 后解压，在 PowerShell 中运行：

```powershell
Set-Location 'C:\path\to\quick-pdf-merge'
& '.\setup_context_menu.bat'
```

也可以直接双击运行：

```text
setup_context_menu.bat
```

安装后会注册：

- PDF 右键菜单项：`合并PDF`
- Windows 资源管理器 `发送到` 快捷方式：`合并PDF`

推荐使用方式：

```text
选中多个 PDF -> 右键 -> 发送到 -> 合并PDF
```

## 卸载

在 PowerShell 中运行：

```powershell
& '.\setup_context_menu.bat' uninstall
```

## 说明

安装时会生成 `merge_pdf_sendto.vbs`，该文件包含本机绝对路径，因此不会提交到 Git。

## 许可证

本项目使用 MIT License。

</details>

<details>
<summary><strong>English</strong></summary>

## Overview

Quick PDF Merge is a lightweight Windows utility for merging PDF files from File Explorer. After installation, select multiple PDF files, then use `Send to -> Merge PDF` from the context menu.

Successful merges run silently in the background. No console window and no success dialog are shown. A message box appears only when an error occurs, such as missing dependencies, too few selected files, or a merge failure.

## Features

- Merge multiple PDF files from Windows File Explorer.
- Save the output next to the first selected PDF.
- Use `merged.pdf` as the default output name.
- If `merged.pdf` already exists, use `merged_001.pdf`, `merged_002.pdf`, and so on.
- Run silently in the background on success.
- Show a message box only when an error occurs.
- Generate an optional Total Commander user menu hint during installation.

## Requirements

- Windows
- Python 3.8 or later
- `pypdf`

The installer installs `pypdf` automatically. You can also install it manually:

```powershell
python -m pip install -r requirements.txt
```

## Install

Download and extract the Release ZIP, then run from PowerShell:

```powershell
Set-Location 'C:\path\to\quick-pdf-merge'
& '.\setup_context_menu.bat'
```

You can also double-click:

```text
setup_context_menu.bat
```

The installer registers:

- PDF context menu item: `合并PDF`
- Windows File Explorer `Send to` shortcut: `合并PDF`

Recommended usage:

```text
Select multiple PDF files -> Right click -> Send to -> 合并PDF
```

## Uninstall

Run from PowerShell:

```powershell
& '.\setup_context_menu.bat' uninstall
```

## Notes

`merge_pdf_sendto.vbs` is generated during installation and contains local absolute paths. It is intentionally ignored by Git.

## License

This project is licensed under the MIT License.

</details>
