# GitHub 自动构建指南（全程浏览器操作，不用碰终端）

这个指南教你把代码上传到 GitHub，让 GitHub 的云 Mac 机自动帮你打包成 `.app`，最后下载就能用。

## 你需要准备

- 一个 GitHub 账号（没有的话去 https://github.com 注册，免费）
- 浏览器（Chrome / Edge / Safari 都可以）

---

## 第一步：注册 / 登录 GitHub

1. 打开 https://github.com
2. 有账号就点 **Sign in** 登录
3. 没有账号就点 **Sign up**，按提示注册（用邮箱就行，免费）

---

## 第二步：创建一个新仓库（Repository）

1. 登录后，点右上角的 **+** 号，选 **New repository**
2. 填写：
   - **Repository name**：输入 `AirliftSilence`（随便起，英文就行）
   - **Description**：可以留空
   - **Public / Private**：选 **Public**（公开，免费版也能用 Actions）
   - **Add a README file**：**不要勾**（我们自己上传文件）
   - **Add .gitignore**：选 **None**
   - **Choose a license**：选 **None**
3. 点最下面的绿色按钮 **Create repository**

创建成功后，你会看到一个空仓库页面，上面有 Quick setup 提示。**保持这个页面打开**。

---

## 第三步：上传代码文件

有两种方式，选第一种最简单。

### 方式 A：网页上传（推荐，不用装任何软件）

1. 在你刚创建的仓库页面，找到 **uploading an existing file** 这个链接（在 Quick setup 那一行里），点它
2. 会进入上传页面，中间有个区域写着 **Drag files here**
3. 把解压后的 `AirliftSilence-1.0.0` 文件夹里的**所有文件和文件夹**全部选中，拖进去
   - 包括：`.github` 文件夹、`silent` 文件夹、`airlift.py`、`airlift_gui.py`、`双击运行.command`、`双击构建.app.command`、`build_mac.sh`、`run_from_source_mac.sh`、`requirements.txt`、`README.md`、`LICENSE`、`.gitignore`
   - **注意**：要拖文件本身，不是拖外层文件夹
4. 等所有文件上传完成（页面会显示文件列表）
5. 拉到页面底部，点绿色按钮 **Commit changes**

### 方式 B：用 GitHub Desktop（如果上传文件太多搞不定）

1. 下载安装 https://desktop.github.com
2. 登录你的 GitHub 账号
3. 点 **Clone a repository from the internet**，选你刚创建的 `AirliftSilence`
4. 把所有文件复制到克隆下来的文件夹里
5. GitHub Desktop 会自动检测到变更，左下角填个 commit 标题（比如 "init"），点 **Commit to main**
6. 点顶部的 **Push origin**

---

## 第四步：触发自动构建

上传完成后，GitHub 会**自动**开始构建（因为 `.github/workflows/build-mac.yml` 里配置了 push 时自动触发）。

查看构建进度：

1. 回到你的仓库页面
2. 点顶部的 **Actions** 标签（在 Code / Issues / Pull requests 那一排）
3. 你会看到一个工作流，名字叫 **Build macOS .app**，状态是黄色的转圈（运行中）
4. 点进去可以看实时日志

**如果没有自动触发**（可能因为默认分支不是 main）：
1. 在 Actions 页面，左边选 **Build macOS .app**
2. 右边点 **Run workflow** 按钮
3. 分支选 `main` 或 `master`（看你的默认分支叫什么）
4. 点绿色的 **Run workflow**

---

## 第五步：等待构建完成

- 构建大约需要 **3-5 分钟**
- 黄色转圈 = 正在运行
- 绿色对勾 = 成功
- 红色叉 = 失败（点进去看日志，把报错截图发我）

---

## 第六步：下载构建好的 .app

构建成功后：

1. 点进那个成功的工作流（绿色对勾的那条）
2. 拉到页面最底部，找到 **Artifacts** 区域
3. 你会看到 `AirliftSilence-mac-app`，点它下载
4. 下载下来是一个 zip 文件，双击解压
5. 解压后得到 `AirliftSilence.app`，**拖到「应用程序」文件夹或桌面**
6. 双击运行

**如果 Mac 提示「无法打开，因为无法验证开发者」：**
- 右键（或按住 Control 点）`AirliftSilence.app`
- 选 **打开**
- 弹出的对话框里再点 **打开**
- 以后就可以正常双击了

---

## 常见问题

### Q：Actions 页面显示 "Actions are disabled for this repository"
- 进入仓库的 **Settings** → **Actions** → **General**
- 选 **Allow all actions and reusable workflows**
- 点 **Save**
- 然后重新触发构建

### Q：构建失败，日志里有红色错误
- 把错误页面截图或复制文字发给我，我帮你看
- 最常见的是网络问题导致 pip 安装失败，重新 Run workflow 一次就行

### Q：下载的 artifact 是 zip，解压后看不到 .app
- Mac 上解压后，`AirliftSilence.app` 看起来可能像一个文件夹（因为 .app 本质是 bundle）
- 这是正常的，直接双击它就行
- 如果 Finder 里它显示成文件夹而不是应用图标，说明解压有问题，用「归档实用工具」重新解压

### Q：我想在 Apple Silicon 和 Intel 上都能用
- GitHub 的 `macos-latest` 目前是 ARM 架构（M 系列），构建出的 app 只能在 M 系列 Mac 上运行
- 如果需要 Intel 版，可以把 workflow 里的 `runs-on: macos-latest` 改成 `runs-on: macos-13`（macOS 13 是 Intel 的最后一个版本），重新构建
- 或者在两种架构上各构建一次，然后用 `lipo` 合并成 universal2（比较复杂，一般不需要）

### Q：构建出的 app 运行时提示 "AirTrafficHost framework not found"
- 说明你的 macOS 版本太新，苹果已经移除了这个框架
- 这是系统限制，目前没有解决办法
- 可以在较旧的 macOS（12-14 左右）上尝试
