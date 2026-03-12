package com.alibaba.cloud.ai.copilot.skill.domain.dto;

import lombok.Data;

import java.util.List;

/**
 * 技能 DTO
 *
 * @author better
 * @since 1.0.0
 */
@Data
public class SkillDTO {

    /**
     * 主键ID
     */
    private Long id;

    /**
     * 技能名称
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
     * 范围: user/project
     */
    private String scope;

    /**
     * 是否启用
     */
    private Boolean enabled;

    /**
     * 分类
     */
    private String category;

    /**
     * 版本
     */
    private String version;

    /**
     * 作者
     */
    private String author;

    /**
     * 标签
     */
    private List<String> tags;

    /**
     * 依赖的工具
     */
    private List<String> dependencies;

    /**
     * SKILL.md 内容
     */
    private String content;

    /**
     * 文件路径
     */
    private String filePath;

}
