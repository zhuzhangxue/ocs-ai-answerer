# GitHub 发布指南（汉化版）

> 一步步教你把这个项目推到 GitHub。

## 📋 发布前检查清单

在 push 之前，请确认：

- [ ] 删除了所有真实 API key（`.env` / `keys.txt` / `custom_models.json`）
- [ ] 改了 README.md 里的 `your-username` 替换成你的 GitHub 用户名
- [ ] 改了 README.md 里的 `your-email@example.com` 替换成你的真实邮箱
- [ ] 改了 CHANGELOG.md 底部的 GitHub 链接（`your-username`）
- [ ] 改了 SECURITY.md 里的邮箱

## 🚀 三步发布

### 第 1 步：创建 GitHub 仓库

1. 登录 https://github.com （右上角登录）
2. 点右上角 **"+"** 按钮 → 选择 **"新建存储库 / New repository"**
3. 填写：
   - **存储库名称 / Repository name**：`ocs-ai-answerer`（或你喜欢的名字）
   - **描述 / Description**：`为 OCS 网课助手提供 AI 后端，支持图片题自动解答`（简短版）
   - **可见性 / Visibility**：选 `公开 / Public`（让其他人能访问）
   - **❌ 不要勾选** "添加 README 文件 / Add a README file"（我们已经有）
   - **❌ 不要勾选** "添加 .gitignore / Add .gitignore"（我们已经有）
   - **❌ 不要勾选** "选择许可证 / Choose a license"（我们已经有 MIT）
4. 点 **"创建存储库 / Create repository"**
5. 复制显示的仓库 URL，形如 `https://github.com/你的用户名/ocs-ai-answerer.git`

### 第 2 步：在本地初始化 Git 并推送

打开 cmd / PowerShell / Git Bash，cd 到项目目录：

```bash
cd C:\Users\xingzhe\WorkBuddy\2026-07-21-13-48-36\OCS-AI-Answerer-一键包

# 初始化 Git（已完成可跳过）
git init
git branch -M main

# 添加所有文件（已完成可跳过）
git add .

# 第一次提交（已完成可跳过）
git commit -m "feat: initial release v1.0.0

- 图片题两阶段流水线 (豆包视觉 → DeepSeek 推理)
- 6 个模型 + 4 级视觉故障转移
- 智能答案后处理 (多空/数学符号/选项匹配)
- Windows 一键启动脚本
- 完整文档 (使用教程/配置教程/添加新模型)
"

# 关联远程仓库（替换成你自己的 URL）
git remote add origin https://github.com/你的用户名/ocs-ai-answerer.git

# 推送到 GitHub
git push -u origin main
```

### 第 3 步：完善 GitHub 仓库设置

推送成功后，访问你的 GitHub 仓库页面，做这些：

#### 3.1 设置 About 区域
点仓库页面右上角的 ⚙️（在"关于 / About"旁），设置：
- **描述 / Description**：`为 OCS 网课助手提供 AI 后端，支持图片题自动解答（豆包视觉 + DeepSeek 推理）`
- **网站 / Website**：留空
- **主题标签 / Topics**（标签）：点 "添加主题标签 / Add topics"，加：
  - `ocs` `ocsjs` `tampermonkey` `油猴脚本`
  - `ai-tutoring` `网课` `自动答题`
  - `deepseek` `doubao` `volcengine` `flask`
  - `python` `china` `homework-helper`

#### 3.2 创建 Release
1. 右边栏点 **"创建新发布 / Create a new release"**
2. **标签版本 / Tag version**：`v1.0.0`
3. **发布标题 / Release title**：`v1.0.0 - 首版发布`
4. **描述 / Description**：
   ```markdown
   ## 🎉 首版发布

   完整功能请看 [README.md](README.md)

   ### 核心特性
   - 🖼️ 图片题自动解答（豆包视觉 + DeepSeek 推理）
   - 🤖 6 个模型 4 级故障转移
   - 🚀 Windows 一键启动
   - 📝 智能答案后处理
   ```
5. 点 **"发布 / Publish release"**

#### 3.3 启用 Issues / 讨论
**设置 / Settings** → **通用 / General** → **功能 / Features**：
- ✅ **问题 / Issues**（让用户能提 Bug）
- ✅ **讨论 / Discussions**（可选，让用户能提问交流）
- ❌ **Wiki**（用 docs/ 目录就行）
- ❌ **Projects**（除非需要看板）

## 🔄 后续更新

```bash
# 改了代码
git add .
git commit -m "feat: 改了什么"
git push

# 改完发新版本
git tag v1.0.1
git push origin v1.0.1
```

## 📢 推广（可选）

让更多人发现这个项目：

1. **OCS 官方社区**：[ocsjs/ocsjs](https://github.com/ocsjs/ocsjs) 提 Issue/PR 推荐
2. **V2EX / 掘金 / 知乎 / 即刻** 发体验帖
3. **抖音 / B 站** 录个 5 分钟演示视频
4. **QQ 群 / 微信群** 分享给同学

## ❓ 遇到问题？

| 现象 | 解决方案 |
|---|---|
| Git 认证失败 / authentication failed | 用 Personal Access Token (PAT) 代替密码。设置 → 开发者设置 → 个人访问令牌 → 生成新令牌（权限选 `repo`） |
| 推送被拒 / rejected | 先 `git pull origin main --rebase` 再 push |
| 大文件警告 | 检查 `.gitignore` 是不是漏了 `venv/`、`.env` 等 |
| 中文文件名乱码 | 设置 git 编码：`git config --global core.quotepath false` |

## 🌐 GitHub 本身汉化

GitHub 设置项位置经常变，**最稳的方案是浏览器翻译**：

### 方案 A：Chrome/Edge 浏览器右键翻译（最简单）
1. 打开 GitHub 任何英文页面
2. **鼠标右键** → **翻译为中文(简体)**
3. 整页立刻变中文 ✅

### 方案 B：地址栏翻译按钮
- Chrome 打开 GitHub 后，**地址栏右侧**有翻译图标 → 点一下
- Edge 同样

### 方案 C：装翻译扩展（最推荐长期用）
- **沉浸式翻译**（国产，**双语对照**最舒服）：<https://immersivetranslate.com/>
- **彩云小译**（也支持 GitHub 翻译）
- **DeepL**（翻译质量最好）

装好后访问任何 GitHub 页面，**自动在中文下方显示英文原文**，再也不会卡。

### 方案 D：尝试 GitHub 官方设置（位置经常变，不保证有效）
1. 访问 <https://github.com/settings/appearance>
2. 找 **Preferred language** 下拉框
3. 选 **中文(简体)**
4. 保存

> ⚠️ 提示：GitHub 在 2024-2026 年间多次改版，**这个选项可能根本不在 Appearance 里**。如果找不到，请用方案 A/B/C。
