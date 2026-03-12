package com.alibaba.cloud.ai.copilot.skill.service;

import com.alibaba.cloud.ai.copilot.skill.domain.dto.CreateSkillRequest;
import com.alibaba.cloud.ai.copilot.skill.domain.dto.SkillDTO;
import com.alibaba.cloud.ai.copilot.skill.domain.dto.UpdateSkillRequest;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.List;

/**
 * 技能管理服务接口
 *
 * @author Alibaba Cloud AI Team
 * @since 1.0.0
 */
public interface SkillService {

    /**
     * 获取技能列表
     *
     * @param scope 范围: "user", "project", "all" 或 null
     * @return 技能列表
     */
    List<SkillDTO> listSkills(String scope);

    /**
     * 获取技能详情
     *
     * @param skillName 技能名称
     * @return 技能详情
     */
    SkillDTO getSkill(String skillName);

    /**
     * 创建技能
     *
     * @param request 创建请求
     */
    void createSkill(CreateSkillRequest request);

    /**
     * 更新技能
     *
     * @param request 更新请求
     */
    void updateSkill(UpdateSkillRequest request);

    /**
     * 删除技能
     *
     * @param skillName 技能名称
     * @param scope 范围: "user" 或 "project"
     */
    void deleteSkill(String skillName, String scope);

    /**
     * 启用/禁用技能
     *
     * @param skillName 技能名称
     * @param enabled 是否启用
     */
    void toggleSkill(String skillName, boolean enabled);

    /**
     * 导出技能
     *
     * @param skillName 技能名称
     * @return 技能数据 (JSON 格式)
     */
    String exportSkill(String skillName);

    /**
     * 导入技能
     *
     * @param skillData 技能数据 (JSON 格式)
     */
    void importSkill(String skillData);

    /**
     * 导出技能为 ZIP
     * @param skillName 技能名称
     * @param outputStream 输出流
     */
    void exportSkillZip(String skillName, OutputStream outputStream);

    /**
     * 从 ZIP 导入技能
     * @param inputStream 输入流
     * @param scope 导入范围
     */
    void importSkillZip(InputStream inputStream, String scope);

}
