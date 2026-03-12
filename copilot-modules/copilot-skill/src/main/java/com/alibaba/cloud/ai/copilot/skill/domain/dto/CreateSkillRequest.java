package com.alibaba.cloud.ai.copilot.skill.domain.dto;

import lombok.Data;

import java.util.List;

/**
 * 创建技能请求
 *
 * @author better
 * @since 1.0.0
 */
@Data
public class CreateSkillRequest {

    /**
     * 技能名称 (必填)
     */
    private String skillName;

    /**
     * 显示名称 (必填)
     */
    private String displayName;

    /**
     * 技能描述 (必填)
     */
    private String description;

    /**
     * 范围: user/project (必填)
     */
    private String scope;

    /**
     * SKILL.md 内容 (必填)
     */
    private String content;

    /**
     * 分类 (可选)
     */
    private String category;

    /**
     * 版本 (可选)
     */
    private String version;

    /**
     * 标签 (可选)
     */
    private List<String> tags;

    /**
     * 依赖的工具 (可选)
     */
    private List<String> dependencies;

}
