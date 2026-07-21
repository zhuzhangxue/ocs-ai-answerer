# 贡献指南

感谢你考虑为本项目做出贡献！🎉

本指南会告诉你如何参与开发、报告 Bug、提交新功能。

---

## 🐛 报告 Bug

提交 Issue 时请包含：

1. **环境信息**：
   - 操作系统（Windows 10 / 11 版本号）
   - Python 版本（`python --version`）
   - 项目版本（看 `CHANGELOG.md`）

2. **复现步骤**：
   - 题目类型（单选/多选/图片等）
   - 题目原文（如果是图片，提供 URL）
   - 期望行为 vs 实际行为

3. **日志**：
   - 终端里 cmd 窗口的报错信息
   - `ocs_request_trace.log` 的相关条目
   - `ocs_answers_log.csv` 里的失败记录

---

## 💡 提功能建议

请先在 Issue 里描述：
- 痛点：现在缺什么 / 哪里不方便
- 方案：你希望怎么解决
- 替代方案：考虑过其他做法吗

---

## 🔧 提交 Pull Request

### 准备
1. Fork 本仓库
2. 克隆你的 fork：`git clone https://github.com/zhuzhangxue/ocs-ai-answerer.git`
3. 创建分支：`git checkout -b feature/your-feature-name`

### 开发
1. **代码风格**：
   - Python 遵循 PEP 8
   - 4 空格缩进
   - 函数/类加 docstring

2. **测试**：
   - 写新功能前先看现有 `AnswerProcessor` 单元测试（用 `python -c "..."` 内联测试）
   - 改动答案处理逻辑时，至少跑通以下 case：
     - 多空填空用 `#` 分隔
     - 数学公式 `x = -1` 匹配选项 `-1`
     - 单选图片选项 AI 不返回字母时降级

3. **不要提交**：
   - `.env`（含真实 API key）
   - `keys.txt`
   - `ocs_answers_log.csv`（含个人答题记录）
   - `custom_models.json`（如含真实 key，先脱敏）

### 提交
1. commit message 格式：`<type>(<scope>): <subject>`
   - `feat(answer): 支持多空填空智能分隔`
   - `fix(processor): 修复 1/3 vs -1/3 子串误匹配`
   - `docs(readme): 更新贡献指南`
2. 推到你 fork：`git push origin feature/your-feature-name`
3. 在 GitHub 上提 PR

---

## 📝 改进文档

文档改进（包括错别字、表述不清、缺例子）都是非常受欢迎的贡献！

- 教程文档在 `docs/` 目录
- 修改后请用浏览器打开测试一下效果

---

## 🌟 添加新模型

参考 [`docs/添加新模型教程.html`](docs/添加新模型教程.html) 了解完整步骤。

简版流程：
1. 在 `custom_models.json` 的 `models` 里添加新条目
2. 在 `question_type_models` 里引用它
3. 跑一次测试题验证
4. 提交 PR（脱敏掉真实 API key）

---

## ❓ 问题？

- 提 Issue：https://github.com/zhuzhangxue/ocs-ai-answerer/issues
- 看 README 和 docs/ 目录

---

再次感谢！每一个 PR 都让这个项目变得更好。
