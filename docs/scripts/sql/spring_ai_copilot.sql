/*
 Navicat Premium Dump SQL

 Source Server         : spring_ai_copilot
 Source Server Type    : MySQL
 Source Server Version : 80036 (8.0.36)
 Source Host           : 129.211.24.7:3306
 Source Schema         : spring_ai_copilot

 Target Server Type    : MySQL
 Target Server Version : 80036 (8.0.36)
 File Encoding         : 65001

 Date: 15/01/2026 00:57:03
*/

SET NAMES utf8mb4;
SET
FOREIGN_KEY_CHECKS = 0;


-- =====================================================
-- 技能市场表
-- 存储技能市场中的技能信息
-- =====================================================
CREATE TABLE IF NOT EXISTS `skill_market` (
                                              `id` BIGINT NOT NULL COMMENT '主键ID',
                                              `skill_name` VARCHAR(100) NOT NULL COMMENT '技能名称',
    `display_name` VARCHAR(200) DEFAULT NULL COMMENT '显示名称',
    `description` TEXT COMMENT '技能描述',
    `category` VARCHAR(50) DEFAULT NULL COMMENT '分类',
    `version` VARCHAR(20) DEFAULT NULL COMMENT '版本',
    `author` VARCHAR(100) DEFAULT NULL COMMENT '作者',
    `download_url` VARCHAR(500) DEFAULT NULL COMMENT '下载地址',
    `star_count` INT DEFAULT 0 COMMENT '点赞数',
    `download_count` INT DEFAULT 0 COMMENT '下载次数',
    `is_official` TINYINT(1) DEFAULT 0 COMMENT '是否官方技能',
    `status` VARCHAR(20) DEFAULT 'active' COMMENT '状态: active/inactive/deprecated',
    `created_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_skill_name` (`skill_name`),
    KEY `idx_category` (`category`),
    KEY `idx_status` (`status`),
    KEY `idx_is_official` (`is_official`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='技能市场表';

-- =====================================================
-- 插入一些示例数据 (可选)
-- =====================================================
INSERT INTO `skill_metadata` (`id`, `skill_name`, `display_name`, `description`, `scope`, `enabled`, `category`, `version`, `author`, `file_path`) VALUES
(1, 'code-commit-helper', '代码提交助手', '生成规范的 Git Commit 消息、添加代码注释、生成 PR 描述', 'project', 1, '代码工具', '1.0.0', 'Alibaba Cloud AI Team', './skills/code-commit-helper/SKILL.md'),
(2, 'clean-chinese-writing', '专业中文写作', '帮助撰写专业、简洁的中文内容，避免 AI 味', 'project', 1, '文档工具', '1.0.0', 'Alibaba Cloud AI Team', './skills/clean-chinese-writing/SKILL.md'),
(3, 'weekly-report', '周报生成器', '自动生成结构化的工作周报', 'project', 1, '文档工具', '1.0.0', 'Alibaba Cloud AI Team', './skills/weekly-report/SKILL.md'),
(4, 'pdf-extractor', 'PDF 提取器', '从 PDF 文件中提取文本、表格和图片', 'project', 1, '文档处理', '1.0.0', 'Alibaba Cloud AI Team', './skills/pdf-extractor/SKILL.md')
ON DUPLICATE KEY UPDATE updated_time = CURRENT_TIMESTAMP;

    -- ----------------------------
-- Table structure for chat_memory_store
-- ----------------------------
DROP TABLE IF EXISTS `chat_chat_memory_store`;
CREATE TABLE `chat_memory_store`
(
    `id`           bigint                                                        NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `namespace`    varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '命名空间（JSON数组格式，如：["users","user_123"]）',
    `key`          varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '记忆键',
    `value`        json                                                          NOT NULL COMMENT '记忆值（JSON格式）',
    `user_id`      bigint NULL DEFAULT NULL COMMENT '用户ID（用于权限控制）',
    `created_time` datetime                                                      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_time` datetime                                                      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX          `idx_user_id` (`user_id`) USING BTREE,
    INDEX          `idx_namespace` (`namespace`(255)) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '长期记忆存储表';


-- ----------------------------
-- Table structure for chat_conversation
-- ----------------------------
DROP TABLE IF EXISTS `chat_conversation`;
CREATE TABLE `chat_conversation`
(
    `id`                bigint                                                       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `conversation_id`   varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '会话ID（UUID）',
    `user_id`           bigint                                                       NOT NULL COMMENT '用户ID',
    `title`             varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会话标题（自动生成）',
    `model_config_id`   bigint NULL DEFAULT NULL COMMENT '使用的模型配置ID',
    `message_count`     int NULL DEFAULT 0 COMMENT '消息数量',
    `last_message_time` datetime NULL DEFAULT NULL COMMENT '最后一条消息时间',
    `created_time`      datetime                                                     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_time`      datetime                                                     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `del_flag`          tinyint(1) NOT NULL DEFAULT 0 COMMENT '删除标志（0-未删除，1-已删除）',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX               `idx_user_id` (`user_id`) USING BTREE,
    INDEX               `idx_user_updated` (`user_id`, `updated_time`) USING BTREE,
    INDEX               `idx_del_flag` (`del_flag`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '会话表';

-- ----------------------------
-- Table structure for chat_message
-- ----------------------------
DROP TABLE IF EXISTS `chat_message`;
CREATE TABLE `chat_message`
(
    `id`                    bigint                                                       NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `conversation_id`       varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '会话ID',
    `message_id`            varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '消息ID',
    `role`                  varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '消息角色：user, assistant, system, tool',
    `content`               text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '消息内容',
    `is_compressed`         tinyint(1) NULL DEFAULT 0 COMMENT '是否为压缩消息',
    `original_count`        int NULL DEFAULT NULL COMMENT '原始消息数量（压缩消息使用）',
    `compression_timestamp` datetime NULL DEFAULT NULL COMMENT '压缩时间',
    `metadata`              json NULL COMMENT '扩展元数据（JSON格式）',
    `created_time`          datetime                                                     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_time`          datetime                                                     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX                   `idx_conversation_id`(`conversation_id` ASC) USING BTREE,
    INDEX                   `idx_conversation_compressed`(`conversation_id` ASC, `is_compressed` ASC) USING BTREE,
    INDEX                   `idx_created_time`(`created_time` ASC) USING BTREE,
    INDEX                   `idx_conversation_time`(`conversation_id`, `created_time`) USING BTREE COMMENT '会话消息时间联合索引，优化历史消息查询'
) ENGINE = InnoDB AUTO_INCREMENT = 2010358791843348482 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '聊天消息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of chat_message
-- ----------------------------

-- ----------------------------
-- Table structure for mcp_market_info
-- ----------------------------
DROP TABLE IF EXISTS `mcp_market_info`;
CREATE TABLE `mcp_market_info`
(
    `id`          bigint                                                        NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `name`        varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '市场名称',
    `url`         varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '市场URL',
    `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '市场描述',
    `auth_config` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '认证配置（JSON格式）',
    `status`      varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'ENABLED' COMMENT '状态：ENABLED-启用, DISABLED-禁用',
    `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MCP市场表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of mcp_market_info
-- ----------------------------
INSERT INTO `mcp_market_info`
VALUES (1, 'MCP Servers 官方市场', 'https://mcpservers.cn/api/servers/list', '官方 MCP 服务器市场，提供丰富的 MCP 工具',
        NULL, 'ENABLED', '2026-01-11 21:46:53', '2026-01-11 21:46:53');

-- ----------------------------
-- Table structure for mcp_market_tool
-- ----------------------------
DROP TABLE IF EXISTS `mcp_market_tool`;
CREATE TABLE `mcp_market_tool`
(
    `id`               bigint                                                        NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `market_id`        bigint                                                        NOT NULL COMMENT '市场ID',
    `tool_name`        varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工具名称',
    `tool_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '工具描述',
    `tool_version`     varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工具版本',
    `tool_metadata`    json NULL COMMENT '工具元数据（JSON格式）',
    `is_loaded`        tinyint(1) NULL DEFAULT 0 COMMENT '是否已加载到本地：0-未加载, 1-已加载',
    `local_tool_id`    bigint NULL DEFAULT NULL COMMENT '关联的本地工具ID',
    `create_time`      datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MCP市场工具关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of mcp_market_tool
-- ----------------------------

-- ----------------------------
-- Table structure for mcp_tool_info
-- ----------------------------
DROP TABLE IF EXISTS `mcp_tool_info`;
CREATE TABLE `mcp_tool_info`
(
    `id`          bigint                                                        NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `name`        varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工具名称',
    `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '工具描述',
    `type`        varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'LOCAL' COMMENT '工具类型：LOCAL-本地, REMOTE-远程',
    `status`      varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'ENABLED' COMMENT '状态：ENABLED-启用, DISABLED-禁用',
    `config_json` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '配置信息（JSON格式）',
    `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'MCP工具表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of mcp_tool_info
-- ----------------------------

-- ----------------------------
-- Table structure for model_config
-- ----------------------------
DROP TABLE IF EXISTS `model_config`;
CREATE TABLE `model_config`
(
    `id`            bigint                                                        NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id`       bigint                                                        NOT NULL COMMENT '用户ID',
    `visibility`    varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci  NOT NULL DEFAULT 'PUBLIC' COMMENT '可见性/权限: PUBLIC(公开), ORGANIZATION(组织), PRIVATE(个人)',
    `model_name`    varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '模型名称',
    `model_key`     varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '模型标识键',
    `model_type`    varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci  NOT NULL DEFAULT 'llm' COMMENT '模型类型: llm(大模型), embedding(文本向量), image2text(图像转文本), asr(语音识别), chat(聊天)',
    `use_image`     tinyint(1) NULL DEFAULT 0 COMMENT '是否支持图像处理 0-不支持 1-支持',
    `description`   text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '模型描述',
    `icon_url`      varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图标URL',
    `provider`      varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci  NOT NULL COMMENT '模型提供商',
    `max_token`     int                                                           NOT NULL DEFAULT 4096 COMMENT '模型最大token数',
    `api_key`       varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'API密钥',
    `api_url`       varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'API地址',
    `function_call` tinyint(1) NULL DEFAULT 1 COMMENT '是否支持函数调用 0-不支持 1-支持',
    `enabled`       tinyint(1) NULL DEFAULT 1 COMMENT '是否启用 0-禁用 1-启用',
    `sort_order`    int NULL DEFAULT 0 COMMENT '排序顺序',
    `created_time`  timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_time`  timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `model_key`(`model_key` ASC) USING BTREE,
    INDEX           `idx_provider`(`provider` ASC) USING BTREE,
    INDEX           `idx_enabled`(`enabled` ASC) USING BTREE,
    INDEX           `idx_sort_order`(`sort_order` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '模型配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of model_config
-- ----------------------------

-- ----------------------------
-- Table structure for model_llm_factories
-- ----------------------------
DROP TABLE IF EXISTS `model_llm_factories`;
CREATE TABLE `model_llm_factories`
(
    `id`            bigint                                                        NOT NULL AUTO_INCREMENT COMMENT 'LLM厂商ID',
    `name`          varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'LLM厂商名称',
    `provider_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci  NOT NULL COMMENT '厂商代码',
    `logo`          text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '厂商logo base64字符串',
    `tags`          varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模型类型标签: LLM, Text Embedding, Image2Text, ASR',
    `sort_order`    int NULL DEFAULT 0 COMMENT '排序权重',
    `status`        tinyint NULL DEFAULT 0 COMMENT '状态: 0-正常, 1-禁用',
    `created_time`  timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_time`  timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `name`(`name` ASC) USING BTREE,
    UNIQUE INDEX `provider_code`(`provider_code` ASC) USING BTREE,
    INDEX           `idx_status`(`status` ASC) USING BTREE,
    INDEX           `idx_tags`(`tags` ASC) USING BTREE,
    INDEX           `idx_code`(`provider_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '模型厂商' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of model_llm_factories
-- ----------------------------
INSERT INTO `model_llm_factories`
VALUES (6, 'DeeSeek', 'DeepSeek', NULL, 'LLM,Chat', 10, 0, '2026-01-11 21:46:52', '2026-01-11 21:46:52');
INSERT INTO `model_llm_factories`
VALUES (7, '阿里百炼', 'ALiBaiLian', NULL, 'LLM,Text Embedding,Chat', 20, 0, '2026-01-11 21:46:52',
        '2026-01-11 21:46:52');
INSERT INTO `model_llm_factories`
VALUES (8, 'OpenAI', 'OpenAI', NULL, 'LLM,Text Embedding,Image2Text,ASR,Chat', 30, 0, '2026-01-11 21:46:52',
        '2026-01-11 21:46:52');
INSERT INTO `model_llm_factories`
VALUES (9, '硅基流动', 'SILICONFLOW', NULL, 'LLM,Text Embedding,Image2Text,ASR,Chat', 40, 0, '2026-01-11 21:46:52',
        '2026-01-11 21:46:52');
INSERT INTO `model_llm_factories`
VALUES (10, '自定义供应商', 'OpenAiCompatible', NULL, 'LLM,Text Embedding,Image2Text,ASR,Chat', 40, 0,
        '2026-01-11 21:46:52', '2026-01-11 21:46:52');

-- ----------------------------
-- Table structure for model_llm
-- ----------------------------
DROP TABLE IF EXISTS `model_llm`;
CREATE TABLE `model_llm`
(
    `id`           bigint                                                        NOT NULL AUTO_INCREMENT COMMENT 'LLM模型ID',
    `fid`          varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '厂商ID（引用 llm_factories.name）',
    `llm_name`     varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模型名称',
    `model_type`   varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模型类型: LLM, Text Embedding, Image2Text, ASR',
    `max_tokens`   int NULL DEFAULT 0 COMMENT '最大token数',
    `tags`         varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '功能标签: LLM, Text Embedding, Image2Text, Chat, 32k...',
    `is_tools`     tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否支持工具调用',
    `status`       tinyint NULL DEFAULT 0 COMMENT '状态: 0-正常, 1-禁用',
    `created_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `uk_fid_llm_name`(`fid` ASC, `llm_name` ASC) USING BTREE,
    INDEX          `idx_model_type`(`model_type` ASC) USING BTREE,
    INDEX          `idx_llm_name`(`llm_name` ASC) USING BTREE,
    INDEX          `idx_status`(`status` ASC) USING BTREE,
    INDEX          `idx_tags`(`tags` ASC) USING BTREE,
    CONSTRAINT `modell_llm_ibfk_1` FOREIGN KEY (`fid`) REFERENCES `model_llm_factories` (`provider_code`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 116 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '厂商模型信息' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of model_llm
-- ----------------------------
INSERT INTO `model_llm`
VALUES (67, 'OpenAI', 'gpt-3.5-turbo', 'CHAT', 4096, 'LLM,CHAT,4K', 0, 1, '2025-12-03 16:37:44', '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (68, 'OpenAI', 'gpt-3.5-turbo-16k-0613', 'CHAT', 16385, 'LLM,CHAT,16k', 0, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (69, 'OpenAI', 'gpt-4', 'CHAT', 8191, 'LLM,CHAT,8K', 0, 1, '2025-12-03 16:37:44', '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (70, 'OpenAI', 'gpt-4-32k', 'CHAT', 32768, 'LLM,CHAT,32K', 0, 1, '2025-12-03 16:37:44', '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (71, 'OpenAI', 'gpt-4-turbo', 'CHAT', 8191, 'LLM,CHAT,8K', 1, 1, '2025-12-03 16:37:44', '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (72, 'OpenAI', 'gpt-4.1', 'CHAT', 1047576, 'LLM,CHAT,1M,IMAGE2TEXT', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (73, 'OpenAI', 'gpt-4.1-mini', 'CHAT', 1047576, 'LLM,CHAT,1M,IMAGE2TEXT', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (74, 'OpenAI', 'gpt-4.1-nano', 'CHAT', 1047576, 'LLM,CHAT,1M,IMAGE2TEXT', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (75, 'OpenAI', 'gpt-4.5-preview', 'CHAT', 128000, 'LLM,CHAT,128K', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (76, 'OpenAI', 'gpt-4o', 'CHAT', 128000, 'LLM,CHAT,128K,IMAGE2TEXT', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (77, 'OpenAI', 'gpt-4o-mini', 'CHAT', 128000, 'LLM,CHAT,128K,IMAGE2TEXT', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (78, 'OpenAI', 'gpt-5', 'CHAT', 400000, 'LLM,CHAT,400k,IMAGE2TEXT', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (79, 'OpenAI', 'gpt-5-chat-latest', 'CHAT', 400000, 'LLM,CHAT,400k,IMAGE2TEXT', 0, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (80, 'OpenAI', 'gpt-5-mini', 'CHAT', 400000, 'LLM,CHAT,400k,IMAGE2TEXT', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (81, 'OpenAI', 'gpt-5-nano', 'CHAT', 400000, 'LLM,CHAT,400k,IMAGE2TEXT', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (82, 'OpenAI', 'o3', 'CHAT', 200000, 'LLM,CHAT,200K,IMAGE2TEXT', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (83, 'OpenAI', 'o4-mini', 'CHAT', 200000, 'LLM,CHAT,200K,IMAGE2TEXT', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (84, 'OpenAI', 'o4-mini-high', 'CHAT', 200000, 'LLM,CHAT,200K,IMAGE2TEXT', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (85, 'SILICONFLOW', 'deepseek-ai/DeepSeek-R1', 'CHAT', 64000, 'LLM,CHAT,64k', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (86, 'SILICONFLOW', 'deepseek-ai/DeepSeek-R1-Distill-Qwen-14B', 'CHAT', 32000, 'LLM,CHAT,32k', 1, 1,
        '2025-12-03 16:37:44', '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (87, 'SILICONFLOW', 'deepseek-ai/DeepSeek-R1-Distill-Qwen-32B', 'CHAT', 32000, 'LLM,CHAT,32k', 1, 1,
        '2025-12-03 16:37:44', '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (88, 'SILICONFLOW', 'deepseek-ai/DeepSeek-R1-Distill-Qwen-7B', 'CHAT', 32000, 'LLM,CHAT,32k', 1, 1,
        '2025-12-03 16:37:44', '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (89, 'SILICONFLOW', 'deepseek-ai/DeepSeek-V2.5', 'CHAT', 32000, 'LLM,CHAT,32k', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (90, 'SILICONFLOW', 'deepseek-ai/DeepSeek-V3', 'CHAT', 64000, 'LLM,CHAT,64k', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (91, 'SILICONFLOW', 'deepseek-ai/DeepSeek-V3.1', 'CHAT', 160000, 'LLM,CHAT,160', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (92, 'SILICONFLOW', 'internlm/internlm2_5-7b-chat', 'CHAT', 32000, 'LLM,CHAT,32k', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (93, 'SILICONFLOW', 'Pro/deepseek-ai/DeepSeek-R1', 'CHAT', 64000, 'LLM,CHAT,64k', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (94, 'SILICONFLOW', 'Pro/deepseek-ai/DeepSeek-R1-Distill-Qwen-7B', 'CHAT', 32000, 'LLM,CHAT,32k', 1, 1,
        '2025-12-03 16:37:44', '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (95, 'SILICONFLOW', 'Pro/deepseek-ai/DeepSeek-V3', 'CHAT', 64000, 'LLM,CHAT,64k', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (96, 'SILICONFLOW', 'Pro/deepseek-ai/DeepSeek-V3.1', 'CHAT', 160000, 'LLM,CHAT,160k', 1, 1,
        '2025-12-03 16:37:44', '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (97, 'SILICONFLOW', 'Pro/Qwen/Qwen2-7B-Instruct', 'CHAT', 32000, 'LLM,CHAT,32k', 0, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (98, 'SILICONFLOW', 'Pro/Qwen/Qwen2.5-7B-Instruct', 'CHAT', 32000, 'LLM,CHAT,32k', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (99, 'SILICONFLOW', 'Pro/Qwen/Qwen2.5-Coder-7B-Instruct', 'CHAT', 32000, 'LLM,CHAT,32k', 0, 1,
        '2025-12-03 16:37:44', '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (100, 'SILICONFLOW', 'Pro/THUDM/glm-4-9b-chat', 'CHAT', 128000, 'LLM,CHAT,128k', 0, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (101, 'SILICONFLOW', 'Qwen/Qwen2-7B-Instruct', 'CHAT', 32000, 'LLM,CHAT,32k', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (102, 'SILICONFLOW', 'Qwen/Qwen2.5-14B-Instruct', 'CHAT', 32000, 'LLM,CHAT,32k', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (103, 'SILICONFLOW', 'Qwen/Qwen2.5-32B-Instruct', 'CHAT', 32000, 'LLM,CHAT,32k', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (104, 'SILICONFLOW', 'Qwen/Qwen2.5-72B-Instruct', 'CHAT', 32000, 'LLM,CHAT,32k', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (105, 'SILICONFLOW', 'Qwen/Qwen2.5-7B-Instruct', 'CHAT', 32000, 'LLM,CHAT,32k', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (106, 'SILICONFLOW', 'Qwen/Qwen2.5-Coder-32B-Instruct', 'CHAT', 32000, 'LLM,CHAT,32k', 0, 1,
        '2025-12-03 16:37:44', '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (107, 'SILICONFLOW', 'Qwen/Qwen2.5-Coder-7B-Instruct', 'CHAT', 32000, 'LLM,CHAT,32k', 1, 1,
        '2025-12-03 16:37:44', '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (108, 'SILICONFLOW', 'Qwen/Qwen3-14B', 'CHAT', 128000, 'LLM,CHAT,128k', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (109, 'SILICONFLOW', 'Qwen/Qwen3-235B-A22B', 'CHAT', 128000, 'LLM,CHAT,128k', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (110, 'SILICONFLOW', 'Qwen/Qwen3-30B-A3B', 'CHAT', 128000, 'LLM,CHAT,128k', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (111, 'SILICONFLOW', 'Qwen/Qwen3-32B', 'CHAT', 128000, 'LLM,CHAT,128k', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (112, 'SILICONFLOW', 'Qwen/Qwen3-8B', 'CHAT', 64000, 'LLM,CHAT,64k', 1, 1, '2025-12-03 16:37:44',
        '2025-12-03 16:37:44');
INSERT INTO `model_llm`
VALUES (113, 'DeepSeek', 'deepseek-chat', 'CHAT', 8191, 'LLM,CHAT', 1, 1, '2025-12-05 17:25:47', '2025-12-05 17:25:50');
INSERT INTO `model_llm`
VALUES (114, 'DeepSeek', 'deepseek-reasoner', 'CHAT', 64000, 'LLM,CHAT', 1, 1, '2025-12-05 17:26:44',
        '2025-12-05 17:26:47');
INSERT INTO `model_llm`
VALUES (115, 'ALiBaiLian', 'qwen3-max-preview', 'CHAT', 64000, 'LLM,CHAT,128k', 1, 1, '2025-12-08 09:14:14',
        '2025-12-08 13:59:28');

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`
(
    `user_id`      bigint                                                       NOT NULL COMMENT '用户ID',
    `open_id`      varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '微信用户标识',
    `user_balance` double(20, 2) NULL DEFAULT 0.00 COMMENT '账户余额',
    `user_name`    varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户账号',
    `nick_name`    varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户昵称',
    `user_type`    varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'sys_user' COMMENT '用户类型（sys_user系统用户）',
    `email`        varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '用户邮箱',
    `phone_number` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '手机号码',
    `sex`          char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
    `avatar`       varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像地址',
    `wx_avatar`    varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '微信头像地址',
    `password`     varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '密码',
    `status`       char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '帐号状态（0正常 1停用）',
    `del_flag`     char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
    `login_ip`     varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '最后登录IP',
    `login_date`   datetime NULL DEFAULT NULL COMMENT '最后登录时间',
    `domain_name`  varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '注册域名',
    `create_time`  datetime NULL DEFAULT (curtime()) COMMENT '创建时间',
    `update_by`    bigint NULL DEFAULT NULL COMMENT '更新者',
    `update_time`  datetime NULL DEFAULT (curtime()) COMMENT '更新时间',
    `remark`       varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
    PRIMARY KEY (`user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户信息表' ROW_FORMAT = DYNAMIC;

CREATE TABLE IF NOT EXISTS file_index_state (
                                                id VARCHAR(64) NOT NULL PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    file_path VARCHAR(700) NOT NULL,
    content_hash VARCHAR(64) NOT NULL,
    last_modified_at DATETIME,
    file_size BIGINT,
    INDEX idx_file_path (file_path)
    );

-- FTS 全文检索表
-- 使用 MySQL FULLTEXT + ngram 解析器，支持中英文混合检索
CREATE TABLE IF NOT EXISTS knowledge_fts (
                                             id          VARCHAR(64)   NOT NULL PRIMARY KEY,
    user_id     VARCHAR(64)   NOT NULL,
    file_path   VARCHAR(700)  NOT NULL,
    content     MEDIUMTEXT    NOT NULL,   -- title + signature + 代码内容
    start_line  INT           DEFAULT 0,
    end_line    INT           DEFAULT 0,
    INDEX idx_kfts_user (user_id),
    FULLTEXT INDEX idx_kfts_content (content) WITH PARSER ngram
                                                  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user`
VALUES (1, NULL, 9999.00, 'admin', 'admin', 'sys_user', 'ageerle@163.com', '15888888888', '0', NULL, NULL,
        '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '0:0:0:0:0:0:0:1',
        '2026-01-11 22:08:14', NULL, '2026-01-15 22:01:33', NULL, '2026-01-21 22:01:39', NULL);

SET
FOREIGN_KEY_CHECKS = 1;
