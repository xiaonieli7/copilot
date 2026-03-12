import React, { useEffect, useMemo, useState, useRef } from "react";
import { message, Dropdown, type MenuProps } from "antd";
import {
  createSkill,
  getSkill,
  listSkills,
  updateSkill,
  importSkillZip,
  type SkillDTO,
} from "@/api/skill";
import SkillList from "@/components/Settings/SkillSettings/SkillList";
import SkillEditor from "@/components/Settings/SkillSettings/SkillEditor";
import CreateSkillModal from "@/components/Settings/SkillSettings/CreateSkillModal";

export default function SkillSettings() {
  const [loading, setLoading] = useState(false);
  const [skills, setSkills] = useState<SkillDTO[]>([]);
  const [selectedSkillName, setSelectedSkillName] = useState<string | null>(null);
  const [selectedSkill, setSelectedSkill] = useState<SkillDTO | null>(null);
  const [detailLoading, setDetailLoading] = useState(false);

  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [importScope, setImportScope] = useState<"user" | "project">("project");

  const selectedSummary = useMemo(() => {
    if (!selectedSkillName) return null;
    return skills.find((s) => s.skillName === selectedSkillName) || null;
  }, [selectedSkillName, skills]);

  async function refresh() {
    setLoading(true);
    try {
      const data = await listSkills("all");
      setSkills(data);
      if (data.length > 0 && !selectedSkillName) {
        setSelectedSkillName(data[0].skillName);
      }
    } catch (err: any) {
      message.error(err?.message || "刷新技能列表失败");
    } finally {
      setLoading(false);
    }
  }

  async function loadDetail(skillName: string) {
    setDetailLoading(true);
    try {
      const detail = await getSkill(skillName);
      setSelectedSkill(detail);
    } catch (err: any) {
      message.error(err?.message || "加载技能详情失败");
    } finally {
      setDetailLoading(false);
    }
  }

  useEffect(() => {
    refresh();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    if (!selectedSkillName) {
      setSelectedSkill(null);
      return;
    }
    loadDetail(selectedSkillName);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedSkillName]);

  async function onSave(content: string) {
    if (!selectedSkillName) return;

    await updateSkill({
      skillName: selectedSkillName,
      scope: selectedSummary?.scope,
      content,
    });

    await loadDetail(selectedSkillName);
    await refresh();
  }

  async function onCreate(payload: {
    skillName: string;
    scope: "user" | "project";
    description?: string;
    content: string;
  }) {
    await createSkill({
      skillName: payload.skillName,
      scope: payload.scope,
      description: payload.description,
      content: payload.content,
    });
    setIsCreateOpen(false);
    await refresh();
    setSelectedSkillName(payload.skillName);
  }

  const handleImportClick = (scope: "user" | "project") => {
    setImportScope(scope);
    fileInputRef.current?.click();
  };

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    message.loading({ content: "正在导入技能...", key: "import-skill" });
    try {
      await importSkillZip(file, importScope);
      message.success({ content: "导入成功", key: "import-skill" });
      await refresh();
    } catch (err: any) {
      message.error({ content: err.message || "导入失败", key: "import-skill" });
    } finally {
      // 清空 input 方便重复选择同一个文件
      e.target.value = "";
    }
  };

  const importMenuItems: MenuProps["items"] = [
    {
      key: "project",
      label: "导入到项目级 (./skills)",
      onClick: () => handleImportClick("project"),
    },
    {
      key: "user",
      label: "导入到用户级 (~/.copilot/skills)",
      onClick: () => handleImportClick("user"),
    },
  ];

  return (
    <div className="flex flex-col gap-3">
      <input
        type="file"
        ref={fileInputRef}
        onChange={handleFileChange}
        accept=".zip"
        className="hidden"
      />
      <div className="flex items-center justify-between">
        <div className="text-[14px] font-bold">技能管理</div>

        <div className="flex items-center gap-2">
          <button
            className="px-3 py-1.5 rounded-lg text-[13px] bg-gray-100 hover:bg-gray-200 dark:bg-[#2a2a2a] dark:hover:bg-[#333333]"
            onClick={() => refresh()}
            disabled={loading}
          >
            刷新
          </button>
          
          <Dropdown menu={{ items: importMenuItems }} placement="bottomRight">
            <button className="px-3 py-1.5 rounded-lg text-[13px] bg-gray-100 hover:bg-gray-200 dark:bg-[#2a2a2a] dark:hover:bg-[#333333]">
              导入 ZIP
            </button>
          </Dropdown>

          <button
            className="px-3 py-1.5 rounded-lg text-[13px] bg-black text-white hover:opacity-90 dark:bg-white dark:text-black"
            onClick={() => setIsCreateOpen(true)}
          >
            创建技能
          </button>
        </div>
      </div>

      <div className="grid grid-cols-12 gap-3 h-[560px]">
        <div className="col-span-4 border border-gray-200 dark:border-[#333333] rounded-lg overflow-hidden">
          <SkillList
            skills={skills}
            loading={loading}
            selectedSkillName={selectedSkillName}
            onSelect={setSelectedSkillName}
            onChanged={async () => {
              await refresh();
              if (selectedSkillName) {
                await loadDetail(selectedSkillName);
              }
            }}
          />
        </div>

        <div className="col-span-8 border border-gray-200 dark:border-[#333333] rounded-lg overflow-hidden">
          <SkillEditor
            skill={selectedSkill}
            loading={detailLoading}
            onSave={onSave}
          />
        </div>
      </div>

      <CreateSkillModal
        open={isCreateOpen}
        onClose={() => setIsCreateOpen(false)}
        onCreate={onCreate}
      />
    </div>
  );
}
