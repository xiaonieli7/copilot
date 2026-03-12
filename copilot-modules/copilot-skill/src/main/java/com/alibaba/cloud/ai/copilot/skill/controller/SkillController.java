package com.alibaba.cloud.ai.copilot.skill.controller;

import com.alibaba.cloud.ai.copilot.core.domain.R;
import com.alibaba.cloud.ai.copilot.skill.domain.dto.CreateSkillRequest;
import com.alibaba.cloud.ai.copilot.skill.domain.dto.SkillDTO;
import com.alibaba.cloud.ai.copilot.skill.domain.dto.UpdateSkillRequest;
import com.alibaba.cloud.ai.copilot.skill.service.SkillService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import java.util.List;

/**
 * 技能管理 Controller
 *
 * @author better
 * @since 1.0.0
 */
@Tag(name = "技能管理", description = "技能管理相关接口")
@Slf4j
@RestController
@RequestMapping("/api/skill")
@RequiredArgsConstructor
public class SkillController {

    private final SkillService skillService;

    /**
     * 导出技能为 ZIP
     *
     * @param skillName 技能名称
     * @return ZIP 文件流
     */
    @Operation(summary = "导出技能 ZIP", description = "将技能及其附件打包为 ZIP 文件下载")
    @GetMapping("/{skillName}/export-zip")
    public ResponseEntity<StreamingResponseBody> exportSkillZip(
            @Parameter(description = "技能名称", required = true)
            @PathVariable String skillName
    ) {
        log.info("导出技能 ZIP: {}", skillName);
        StreamingResponseBody responseBody = outputStream -> {
            skillService.exportSkillZip(skillName, outputStream);
        };

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + skillName + ".zip\"")
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .body(responseBody);
    }

    /**
     * 导入技能 ZIP
     *
     * @param file ZIP 文件
     * @param scope 范围: user/project
     * @return 操作结果
     */
    @Operation(summary = "导入技能 ZIP", description = "上传 ZIP 文件并解压到指定技能目录")
    @PostMapping(value = "/import-zip", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public R<Void> importSkillZip(
            @RequestPart("file") MultipartFile file,
            @RequestParam(required = false, defaultValue = "user") String scope
    ) {
        log.info("导入技能 ZIP, scope: {}", scope);
        try {
            skillService.importSkillZip(file.getInputStream(), scope);
            return R.ok();
        } catch (Exception e) {
            log.error("导入技能 ZIP 失败", e);
            return R.fail("导入失败: " + e.getMessage());
        }
    }

    /**
     * 获取技能列表
     *
     * @param scope 范围过滤: "user", "project", "all" 或 null
     * @return 技能列表
     */
    @Operation(summary = "获取技能列表", description = "获取所有技能或按范围过滤的技能列表")
    @GetMapping("/list")
    public R<List<SkillDTO>> listSkills(
            @Parameter(description = "范围: user/project/all")
            @RequestParam(required = false) String scope
    ) {
        log.info("查询技能列表, scope: {}", scope);
        try {
            List<SkillDTO> skills = skillService.listSkills(scope);
            return R.ok(skills);
        } catch (Exception e) {
            log.error("查询技能列表失败", e);
            return R.fail(e.getMessage());
        }
    }

    /**
     * 获取技能详情
     *
     * @param skillName 技能名称
     * @return 技能详情
     */
    @Operation(summary = "获取技能详情", description = "根据技能名称获取技能的详细信息，包括 SKILL.md 内容")
    @GetMapping("/{skillName}")
    public R<SkillDTO> getSkill(
            @Parameter(description = "技能名称", required = true)
            @PathVariable String skillName
    ) {
        log.info("获取技能详情: {}", skillName);
        try {
            SkillDTO skill = skillService.getSkill(skillName);
            return R.ok(skill);
        } catch (Exception e) {
            log.error("获取技能详情失败: {}", skillName, e);
            return R.fail(e.getMessage());
        }
    }

    /**
     * 创建技能
     *
     * @param request 创建技能请求
     * @return 操作结果
     */
    @Operation(summary = "创建技能", description = "创建新的技能，包括创建目录、文件和数据库记录")
    @PostMapping("/create")
    public R<Void> createSkill(@RequestBody CreateSkillRequest request) {
        log.info("创建技能: {}", request.getSkillName());
        try {
            skillService.createSkill(request);
            return R.ok();
        } catch (Exception e) {
            log.error("创建技能失败: {}", request.getSkillName(), e);
            return R.fail(e.getMessage());
        }
    }

    /**
     * 更新技能
     *
     * @param request 更新技能请求
     * @return 操作结果
     */
    @Operation(summary = "更新技能", description = "更新现有技能的信息和内容")
    @PostMapping("/update")
    public R<Void> updateSkill(@RequestBody UpdateSkillRequest request) {
        log.info("更新技能: {}", request.getSkillName());
        try {
            skillService.updateSkill(request);
            return R.ok();
        } catch (Exception e) {
            log.error("更新技能失败: {}", request.getSkillName(), e);
            return R.fail(e.getMessage());
        }
    }

    /**
     * 删除技能
     *
     * @param skillName 技能名称
     * @param scope 范围: user/project
     * @return 操作结果
     */
    @Operation(summary = "删除技能", description = "删除指定的技能，包括文件和数据库记录")
    @DeleteMapping("/{skillName}")
    public R<Void> deleteSkill(
            @Parameter(description = "技能名称", required = true)
            @PathVariable String skillName,
            @Parameter(description = "范围: user/project")
            @RequestParam(required = false, defaultValue = "user") String scope
    ) {
        log.info("删除技能: {}, scope: {}", skillName, scope);
        try {
            skillService.deleteSkill(skillName, scope);
            return R.ok();
        } catch (Exception e) {
            log.error("删除技能失败: {}, scope: {}", skillName, scope, e);
            return R.fail(e.getMessage());
        }
    }

    /**
     * 启用/禁用技能
     *
     * @param skillName 技能名称
     * @param enabled 是否启用
     * @return 操作结果
     */
    @Operation(summary = "切换技能状态", description = "启用或禁用指定的技能")
    @PostMapping("/{skillName}/toggle")
    public R<Void> toggleSkill(
            @Parameter(description = "技能名称", required = true)
            @PathVariable String skillName,
            @Parameter(description = "是否启用", required = true)
            @RequestParam boolean enabled
    ) {
        log.info("切换技能状态: {}, enabled: {}", skillName, enabled);
        try {
            skillService.toggleSkill(skillName, enabled);
            return R.ok();
        } catch (Exception e) {
            log.error("切换技能状态失败: {}", skillName, e);
            return R.fail(e.getMessage());
        }
    }

    /**
     * 导出技能
     *
     * @param skillName 技能名称
     * @return 技能数据 (JSON 格式)
     */
    @Operation(summary = "导出技能", description = "将技能导出为 JSON 格式")
    @GetMapping("/{skillName}/export")
    public R<String> exportSkill(
            @Parameter(description = "技能名称", required = true)
            @PathVariable String skillName
    ) {
        log.info("导出技能: {}", skillName);
        try {
            String exportData = skillService.exportSkill(skillName);
            return R.ok(exportData);
        } catch (Exception e) {
            log.error("导出技能失败: {}", skillName, e);
            return R.fail(e.getMessage());
        }
    }

    /**
     * 导入技能
     *
     * @param skillData 技能数据 (JSON 格式)
     * @return 操作结果
     */
    @Operation(summary = "导入技能", description = "从 JSON 数据导入技能")
    @PostMapping("/import")
    public R<Void> importSkill(@RequestBody String skillData) {
        log.info("导入技能");
        try {
            skillService.importSkill(skillData);
            return R.ok();
        } catch (Exception e) {
            log.error("导入技能失败", e);
            return R.fail(e.getMessage());
        }
    }

}
