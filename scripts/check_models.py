#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OCS AI Answerer - 模型自检脚本

检查 custom_models.json 中的模型配置是否有效，包括：
    - API 密钥是否已配置（真实 key 还是占位符）
    - base_url 是否有效
    - 模型是否启用
    - 题型映射中的模型是否已定义
"""

import os
import sys
import json
import logging

from dotenv import load_dotenv

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)

load_dotenv(os.path.join(PROJECT_DIR, '.env'))

logging.basicConfig(level=logging.INFO, format='  %(message)s')
logger = logging.getLogger(__name__)

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
CONFIG_FILE = os.path.join(PROJECT_DIR, 'custom_models.json')

EXIT_OK = 0
EXIT_WARN = 1
EXIT_ERROR = 2


def resolve_env_var(value: str) -> str:
    """解析 ${ENV_VAR} 占位符为实际环境变量值（不加载 .env 文件避免重复加载）"""
    import re
    if not isinstance(value, str):
        return value
    pattern = r'\$\{([A-Z_]+)\}'
    def replacer(match):
        env_name = match.group(1)
        return os.getenv(env_name, '')
    return re.sub(pattern, replacer, value)


def load_config() -> dict:
    """加载 custom_models.json"""
    if not os.path.exists(CONFIG_FILE):
        logger.error(f"配置文件不存在: {CONFIG_FILE}")
        sys.exit(EXIT_ERROR)

    try:
        with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    except json.JSONDecodeError as e:
        logger.error(f"JSON 格式错误: {e}")
        sys.exit(EXIT_ERROR)


def check_model(model_id: str, model: dict) -> list:
    """检查单个模型配置，返回问题列表"""
    issues = []
    name = model.get('name', model_id)
    enabled = model.get('enabled', True)
    api_key_raw = model.get('api_key', '')
    base_url = model.get('base_url', '')
    model_name = model.get('model_name', '')
    is_multimodal = model.get('is_multimodal', False)

    if not enabled:
        issues.append(f"[OFF] {name} - 已禁用")
        return issues

    # 检查 api_key
    api_key = resolve_env_var(api_key_raw)
    if not api_key_raw or not api_key_raw.strip():
        issues.append(f"[NO_KEY] {name} - api_key 为空")
    elif api_key_raw.startswith('${') and not api_key:
        issues.append(f"[NO_KEY] {name} - 占位符 {api_key_raw} 对应的环境变量未设置")
    elif api_key_raw.startswith('sk-你的') or api_key_raw.startswith('ark-你的'):
        issues.append(f"[PLACEHOLDER] {name} - 仍是示例密钥，请替换为真实 key")

    # 检查 base_url
    if not base_url or not base_url.strip():
        issues.append(f"[NO_URL] {name} - base_url 为空")
    elif not base_url.startswith('https://'):
        issues.append(f"[BAD_URL] {name} - base_url 应以 https:// 开头: {base_url}")

    # 检查 model_name
    if not model_name or not model_name.strip():
        issues.append(f"[NO_MODEL] {name} - model_name 为空")

    # 警告：非多模态模型用于图片题
    if not is_multimodal:
        pass  # 仅文本模型正常

    return issues


def check_question_type_mapping(config: dict) -> list:
    """检查题型映射是否有效"""
    issues = []
    models = config.get('models', {})
    question_type_models = config.get('question_type_models', {})

    expected_types = {'single', 'multiple', 'judgement', 'completion', 'image'}
    for qtype, qconfig in question_type_models.items():
        if not isinstance(qconfig, dict):
            continue
        model_ids = qconfig.get('models', [])
        if not model_ids:
            issues.append(f"[NO_MODELS] 题型 '{qtype}' 未配置任何模型")
            continue
        for mid in model_ids:
            if mid not in models:
                issues.append(f"[MISSING] 题型 '{qtype}' 引用了不存在的模型 '{mid}'")
            else:
                m = models[mid]
                if not m.get('enabled', True):
                    issues.append(f"[DISABLED] 题型 '{qtype}' 引用了已禁用的模型 '{mid}' ({m.get('name', mid)})")

    # 检查缺少的题型
    for qtype in expected_types:
        if qtype not in question_type_models:
            issues.append(f"[MISSING_TYPE] 缺少题型映射: '{qtype}'")

    return issues


def main():
    config = load_config()
    models = config.get('models', {})
    has_error = False
    has_warning = False

    print()
    print(f"  模型自检 - custom_models.json ({len(models)} 个模型)")
    print("  " + "-" * 50)

    # 检查模型
    ok_count = 0
    for model_id, model_def in models.items():
        issues = check_model(model_id, model_def)
        if not issues:
            ok_count += 1
            mm_tag = ' [视觉]' if model_def.get('is_multimodal') else ' [文本]'
            print(f"  [OK] {model_def.get('name', model_id)}{mm_tag}")
        else:
            for issue in issues:
                if issue.startswith('[PLACEHOLDER]'):
                    has_warning = True
                elif issue.startswith('[OFF]'):
                    has_warning = True
                else:
                    has_error = True
                print(f"  {issue}")

    print(f"  -- {ok_count}/{len(models)} 个模型就绪")

    # 检查题型映射
    mapping_issues = check_question_type_mapping(config)
    if mapping_issues:
        print()
        print("  题型映射检查:")
        for issue in mapping_issues:
            has_error = True
            print(f"  {issue}")

    print()
    if has_error:
        print("  自检结果: 存在问题，请检查上述提示")
        sys.exit(EXIT_WARN)
    elif has_warning:
        print("  自检结果: 存在警告，服务仍可启动")
        sys.exit(EXIT_OK)
    else:
        print("  自检结果: 一切正常")
        sys.exit(EXIT_OK)


if __name__ == '__main__':
    main()
