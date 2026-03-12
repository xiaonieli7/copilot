import React from "react";
import { deleteSkill, toggleSkill, exportSkillZip, type SkillDTO } from "@/api/skill";
import { message, Modal } from "antd";

export default function SkillList(props: {
  skills: SkillDTO[];
  loading: boolean;
  selectedSkillName: string | null;
  onSelect: (skillName: string) => void;
  onChanged: () => void;
}) {
  const { skills, loading, selectedSkillName, onSelect, onChanged } = props;

  async function onToggle(s: SkillDTO) {
    try {
      await toggleSkill(s.skillName, !Boolean(s.enabled));
      message.success(`技能 ${s.skillName} 已${!s.enabled ? "启用" : "禁用"}`);
      await onChanged();
    } catch (err: any) {
      message.error(err.message || "操作失败");
    }
  }

  async function onDelete(s: SkillDTO) {
    Modal.confirm({
      title: "确定删除技能吗？",
      content: `技能 ${s.skillName} 将被物理删除，此操作不可恢复。`,
      okText: "确定删除",
      okType: "danger",
      cancelText: "取消",
      onOk: async () => {
        try {
          await deleteSkill(s.skillName, (s.scope || "user") as any);
          message.success("技能已删除");
          await onChanged();
        } catch (err: any) {
          message.error(err.message || "删除失败");
        }
      },
    });
  }

  async function onExportZip(s: SkillDTO) {
    try {
      const blob = await exportSkillZip(s.skillName);
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `${s.skillName}.zip`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);
      message.success("导出成功");
    } catch (err: any) {
      message.error(err.message || "导出失败");
    }
  }

  return (
    <div className="flex flex-col h-full">
      <div className="px-3 py-2 border-b border-gray-200 dark:border-[#333333]">
        <div className="text-[13px] font-bold">技能列表</div>
        <div className="text-[12px] text-gray-500 dark:text-gray-400 mt-1">
          共 {skills.length} 个
        </div>
      </div>

      <div className="flex-1 overflow-y-auto">
        {loading && skills.length === 0 ? (
          <div className="p-3 text-[13px] text-gray-500">加载中...</div>
        ) : skills.length === 0 ? (
          <div className="p-3 text-[13px] text-gray-500">暂无技能</div>
        ) : (
          <div className="divide-y divide-gray-100 dark:divide-[#222222]">
            {skills.map((s) => {
              const active = selectedSkillName === s.skillName;
              return (
                <div
                  key={s.skillName}
                  className={
                    "px-3 py-2 cursor-pointer transition-colors " +
                    (active
                      ? "bg-gray-100 dark:bg-[#2a2a2a]"
                      : "hover:bg-gray-50 dark:hover:bg-[#242424]")
                  }
                  onClick={() => onSelect(s.skillName)}
                >
                  <div className="flex items-start justify-between gap-2">
                    <div className="min-w-0">
                      <div className="text-[13px] font-medium truncate">
                        {s.skillName}
                      </div>
                      {s.description ? (
                        <div className="text-[12px] text-gray-500 dark:text-gray-400 line-clamp-2 mt-0.5">
                          {s.description}
                        </div>
                      ) : null}
                      <div className="text-[11px] text-gray-400 mt-1">
                        {s.scope ? (s.scope === "project" ? "项目" : "用户") : ""}
                        {typeof s.enabled === "boolean" ? (s.enabled ? " · 已启用" : " · 已禁用") : ""}
                      </div>
                    </div>

                    <div className="flex flex-col items-end gap-1 shrink-0">
                      <button
                        className={
                          "px-2 py-1 rounded text-[12px] " +
                          (s.enabled
                            ? "bg-green-600 text-white hover:opacity-90"
                            : "bg-gray-200 text-gray-800 hover:bg-gray-300 dark:bg-[#333333] dark:text-gray-200")
                        }
                        onClick={(e) => {
                          e.stopPropagation();
                          void onToggle(s);
                        }}
                      >
                        {s.enabled ? "启用中" : "已禁用"}
                      </button>
                      <button
                        className="px-2 py-1 rounded text-[12px] bg-blue-50 text-blue-700 hover:bg-blue-100 dark:bg-[#1b2b2b] dark:text-blue-300"
                        onClick={(e) => {
                          e.stopPropagation();
                          void onExportZip(s);
                        }}
                      >
                        导出ZIP
                      </button>
                      <button
                        className="px-2 py-1 rounded text-[12px] bg-red-50 text-red-700 hover:bg-red-100 dark:bg-[#2b1b1b] dark:text-red-300"
                        onClick={(e) => {
                          e.stopPropagation();
                          void onDelete(s);
                        }}
                      >
                        删除
                      </button>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
