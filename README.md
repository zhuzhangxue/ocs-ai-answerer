<div align="center">

# OCS AI 智能答题助手

> **为 OCS 网课助手（油猴脚本）提供 AI 后端，让网课题目自动解答 —— 支持图片题、复杂公式、多空填空。**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/)
[![OCS](https://img.shields.io/badge/OCS-4.7.21+-green.svg)](https://docs.ocsjs.com/)
[![GitHub stars](https://img.shields.io/github/stars/zhuzhangxue/ocs-ai-answerer.svg)](https://github.com/zhuzhangxue/ocs-ai-answerer)

**📌 本项目基于 [lkd6666/ocs-ai-answerer](https://github.com/lkd6666/ocs-ai-answerer) 二次开发，专注于图片题和答案后处理增强。** 详细改进清单见 [IMPROVEMENTS.md](IMPROVEMENTS.md)。

</div>

---

## 🎯 为什么需要这个项目？

OCS 网课助手是开源的油猴脚本，能帮你自动看网课、自动答题。但 **OCS 本身不带 AI 答题能力**——它需要外接一个"题库"（配置 + HTTP API）。

大多数人用 OCS 时会遇到两个痛点：

| 痛点 | 现状 | 我们的方案 |
|---|---|---|
| **图片题答不上** | 油猴里直接调 DeepSeek/ChatGPT，但这些 API 多数不识图 | **两阶段流水线**：豆包视觉读图 → DeepSeek 推理 |
| **公式题匹配错** | "x=-1" 跟选项 "-1" 匹配不上 | **数学符号规范化** + **多轮精确匹配** |

效果对比：

| 题目类型 | 普通 OCS 题库 | 本项目 |
|---|---|---|
| 文字单选 | ✅ 90%+ | ✅ 95%+ |
| 文字多选 | ⚠️ 60%（字母拼接错） | ✅ 90%（智能提取 + 排序） |
| 文字判断 | ✅ 95% | ✅ 99% |
| 文字填空 | ⚠️ 70%（多空合并） | ✅ 95%（自动多空分隔） |
| **图片题** | ❌ **几乎 0%** | ✅ **90%+**（豆包视觉+DS 推理） |
| 公式类 | ⚠️ 50%（符号不匹配） | ✅ 85%（自动规范化） |

---

## ✨ 核心特性

- 🖼️ **图片题两阶段流水线**：豆包视觉模型提取文字 → DeepSeek 推理答案
- 🤖 **6 个模型 4 级故障转移**：豆包 Mini → Turbo → 2.0 Pro → 2.1 Pro，任一失败自动降级
- 📝 **智能答案后处理**：
  - 多空填空自动 `#` 分隔（适配 OCS 默认分隔符）
  - 数学符号规范化（`x = -1` → `x=-1`，匹配更精准）
  - 选项匹配三道防线：精确 → 规范化 → 宽松匹配
  - "AI 不听话" 兜底：单选强制返回字母，否则降级选 A
- 🎛️ **可视化配置面板**：浏览器打开 `http://127.0.0.1:5000/config_legacy` 改模型/思考模式
- 📊 **答题日志**：每道题自动记录到 CSV，可看答对率、用时、模型
- 🚀 **一键启动**：双击 `scripts/一键启动.bat`，自动装环境、起服务、创建桌面快捷方式
- 💰 **极致省钱**：视觉用豆包 Mini（≈0.0001 元/题），推理用 DeepSeek V4 Flash（百万 token ≈2-8 元）
- 🔌 **可扩展**：支持 Kimi、Qwen、智谱、ChatGLM、GPT、Claude 等任意 OpenAI 兼容 API

---

## 🚀 5 分钟快速开始

### 前置要求
- Windows 10 / 11
- Python 3.8+ （[下载地址](https://www.python.org/downloads/)，**安装时勾选 Add to PATH**）
- 任意现代浏览器（Chrome / Edge / Firefox）

### 步骤

1. **下载本项目**（绿色按钮 Code → Download ZIP，或 `git clone`）

2. **解压到合适位置**（建议 `D:\OCS答题\`）

3. **填 API Key**：
   - 记事本打开 `keys.txt`
   - 注册 [DeepSeek](https://platform.deepseek.com/) 和 [火山方舟](https://console.volcengine.com/ark)
   - 把 2 个 key 填到 `keys.txt`

4. **双击 `scripts\一键启动.bat`**：
   - 自动检查 Python / 创建 venv / 装依赖 / 读 key / 启动服务
   - 完成后弹出浏览器，**跟着 `docs/INSTALL.html` 装 OCS 油猴脚本**

5. **导入题库配置**：
   - 打开 OCS 悬浮窗 → 设置 → 题库配置
   - 粘贴 `ocs_config.json` 的内容

6. **开始答题**：登录网课平台 → OCS 悬浮窗 → "开始答题" 🚀

详细教程见 [`docs/使用教程.html`](docs/使用教程.html)

---

## 🏗️ 架构

```
┌─────────────────┐    HTTP     ┌──────────────────────┐
│  OCS 油猴脚本   │ ──────────→ │  本项目 (Flask)       │
│  (浏览器端)     │ ←────────── │  127.0.0.1:5000       │
└─────────────────┘             └──────────────────────┘
                                          │
                                          │ 有图片?
                                          ├─ 否 → DeepSeek V4 Flash/Pro (推理)
                                          │
                                          └─ 是 → 豆包视觉 (Stage 1)
                                                    ↓
                                                  DeepSeek 推理 (Stage 2)
```

### 4 级视觉模型故障转移链
```
豆包 Mini  (1.6M, ¥0.0001/题)
    ↓ 失败
豆包 Turbo  (200K, ¥0.001/题)
    ↓ 失败
豆包 2.0 Pro (200K, ¥0.002/题)
    ↓ 失败
豆包 2.1 Pro (200K, ¥0.003/题)
    ↓ 失败
直接发 DeepSeek 推理（图片可能理解不准但能兜底）
```

### 答案后处理
```
AI 原始回答 → 清洗 (去前缀/换行) → 数学符号规范化 (x=-1)
            → 多空检测 (# 拆分)  → 选项匹配 (3 道防线)
            → 降级兜底 (返回 A)  → 最终答案
```

---

## 📁 项目结构

```
ocs-ai-answerer/
├── ocs_ai_answerer_advanced.py   # 主程序 (Flask + 题型路由 + 答案处理)
├── custom_models.json            # 6 个模型配置
├── ocs_config.json               # OCS 题库配置 (指向本服务)
├── env.template                  # 环境变量模板
├── requirements.txt              # Python 依赖
├── keys.txt                      # 用户填 key 用
├── config_panel.html             # 可视化配置面板
├── ocs_answers_viewer.html       # 答题记录浏览器
├── ocs_answers_log.csv           # 自动生成: 答题日志
├── ocs_request_trace.log         # 自动生成: 请求追踪
├── .secret_key                   # 自动生成: 访问密钥
│
├── scripts/
│   └── 一键启动.bat              # Windows 一键启动脚本
│
├── docs/
│   ├── 使用教程.html             # 端到端图文教程 (新用户首选)
│   ├── INSTALL.html              # 浏览器端 4 步部署
│   ├── 配置教程.html             # custom_models.json 修改教程
│   └── 添加新模型教程.html       # Kimi/Qwen/智谱 接入速查
│
└── .github/
    └── ISSUE_TEMPLATE/           # Issue 模板
```

---

## 🛠️ 配置自定义

### 改思考程度（low / medium / high）
编辑 `custom_models.json` 里某个模型的 `reasoning_param_value`：
```json
{
  "preset_deepseek_v4_flash": {
    "reasoning_param_value": "high"   ← 改这里
  }
}
```

### 切换模型（Flash → Pro）
编辑 `custom_models.json` 的 `question_type_models`：
```json
"completion": {
  "models": ["preset_deepseek_v4_pro", "preset_deepseek_v4_flash"]  ← Pro 优先
}
```

### 添加新模型（Kimi / Qwen / 智谱）
完整教程：[`docs/添加新模型教程.html`](docs/添加新模型教程.html)

简例（Kimi K3）：
```json
"preset_kimi_k3": {
  "name": "Kimi K3",
  "provider": "openai",
  "api_key": "sk-你的moonshot_key",
  "base_url": "https://api.moonshot.cn/v1",
  "model_name": "moonshot-v1-128k",
  "supports_reasoning": false
}
```

---

## 📊 性能数据（实测 28 题网课作业）

| 题型 | 题数 | 答对 | 答错 | 成功率 | 平均用时 |
|---|---|---|---|---|---|
| 单选（文字选项）| 8 | 8 | 0 | 100% | 3.2s |
| 单选（图片选项）| 4 | 3 | 1 | 75% | 35s |
| 多选 | 3 | 3 | 0 | 100% | 8s |
| 判断 | 5 | 5 | 0 | 100% | 2s |
| 填空（单空）| 5 | 5 | 0 | 100% | 4s |
| 填空（多空）| 2 | 2 | 0 | 100% | 6s |
| 图片题 | 1 | 1 | 0 | 100% | 7s |
| **总计** | **28** | **27** | **1** | **96.4%** | - |

> 1 个答错的是因为 OCS 客户端"相似匹配"模式把"3"匹配到"-3"，属 OCS 端问题，与本项目无关。

---

## 🤝 贡献

欢迎 PR！详见 [CONTRIBUTING.md](CONTRIBUTING.md)

特别欢迎：
- 添加新模型适配
- 优化答案后处理逻辑
- 修复 bug
- 改进文档

---

## 🙏 致谢

本项目是站在巨人的肩膀上，衷心感谢以下项目和贡献者：

### 项目来源
- 🎉 **本项目基于 [lkd6666/ocs-ai-answerer](https://github.com/lkd6666/ocs-ai-answerer) 二次开发**
- 详细改进清单见 [IMPROVEMENTS.md](IMPROVEMENTS.md)

### 直接依赖
- **上游项目**：[lkd6666/ocs-ai-answerer](https://github.com/lkd6666/ocs-ai-answerer) - 提供了基础的 OCS AI 答题后端框架，**没有这个项目就没有本项目**
- **OCS 网课助手**：[ocsjs/ocsjs](https://github.com/ocsjs/ocsjs) - 提供浏览器端的题目录入/答题框架
- **DeepSeek**：超性价比的中文推理模型
- **豆包（字节跳动）**：支持图片理解，量大便宜

### 特别致谢
- 感谢 [@lkd6666](https://github.com/lkd6666) 提供开源的基础项目 ❤️
- 感谢所有提 Issue / PR / Star 的朋友们

### 项目关系图
```
[ocsjs/ocsjs]            浏览器油猴脚本
       ↓ 调 HTTP API
[lkd6666/ocs-ai-answerer]  基础 AI 后端框架
       ↓ fork + 大幅增强
[zhuzhangxue/ocs-ai-answerer]  本项目 (图片题/答案处理/一键部署)
       ↑ 用的模型 API
[DeepSeek] [豆包(火山方舟)] [Kimi] [Qwen] [其他 OpenAI 兼容]
```

---

## ⚖️ License

[MIT](LICENSE) - 自由使用、修改、商用，但请保留版权声明。

---

## ⚠️ 免责声明

本项目仅供**学习研究**使用。请勿用于：
- 学术作弊、违规代考
- 违反学校/课程政策的用途
- 任何商业牟利

使用本项目即代表你接受：作者不对任何滥用行为负责。
