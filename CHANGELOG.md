# 更新日志

本项目的所有重要变更都会记录在此文件。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [Unreleased]

### 新增
- GitHub 项目发布准备（README、LICENSE、.gitignore、贡献指南）
- 用户填 key 模板 `keys.txt`（一键启动.bat 自动读取）
- 后台启动支持（vbs + pythonw，不弹黑窗口）
- 自动创建桌面快捷方式

## [1.0.0] - 2026-07-21

### 新增
- 🎉 首版发布
- 🖼️ 图片题两阶段流水线（豆包视觉 → DeepSeek 推理）
- 🤖 6 个模型配置（DeepSeek V4 Flash/Pro + 豆包 Mini/Turbo/2.0 Pro/2.1 Pro）
- 🛡️ 4 级视觉模型故障转移链
- 📝 智能答案后处理：
  - 多空填空自动 `#` 分隔
  - 数学符号规范化
  - 三道防线选项匹配
  - "AI 不听话" 单选兜底（返回字母 A）
- 🚀 Windows 一键启动脚本
- 🎛️ 可视化配置面板（`/config_legacy`）
- 📊 答题日志 CSV 自动记录
- 🔌 支持任意 OpenAI 兼容 API（Kimi/Qwen/智谱/GPT/Claude）
- 📖 4 个 HTML 教程文档

### 修复
- OCS 4.7.21 之前的 spread syntax 报错（用 `${}` 占位符替代 `data.handler`）
- 多空填空被合并成一句
- 数学公式匹配失败（`x = -1` vs `-1`）
- 1/3 vs -1/3 子串误匹配
- 图片选项 AI 不返回字母
- 图片尺寸 < 14px 豆包 API 400 错误
- completion 题型无 fallback 500 错误

### 已知限制
- 【其它】题（问答题）后端能答但 OCS 端文本框无法接收长描述
- 多空题分空错误属 OCS 客户端问题，需手动调整
- 仅支持 Windows（macOS / Linux 需手动 `python ocs_ai_answerer_advanced.py`）

---

[Unreleased]: https://github.com/zhuzhangxue/ocs-ai-answerer/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/zhuzhangxue/ocs-ai-answerer/releases/tag/v1.0.0
