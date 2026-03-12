package com.alibaba.cloud.ai.copilot.skill.domain.dto;

import lombok.Data;

import java.util.List;

/**
 * 更新技能请求
 *
 * @author better
 * @since 1.0.0
 */
@Data
public class UpdateSkillRequest {

    /**
     * 技能名称 (必填，用于定位)
     */
    private String skillName;

    /**
     * 显示名称
     */
    private String displayName;

    /**
     * 技能描述
     */
    private String description;

    /**
     * SKILL.md 内容
     */
    private String content;

    /**
     * 分类
     */
    private String category;

    /**
     * 版本
     */
    private String version;

    /**
     * 标签
     */
    private List<String> tags;

    /**
     * 依赖的工具
     */
    private List<String> dependencies;

}
