import { apiUrl } from "./base";

export interface ApiResponse<T> {
  code: number;
  msg?: string;
  data: T;
}

export type SkillScope = "user" | "project" | "all";

export interface SkillDTO {
  skillName: string;
  displayName?: string;
  description?: string;
  scope?: "user" | "project";
  enabled?: boolean;
  category?: string;
  version?: string;
  author?: string;
  tags?: string[];
  dependencies?: string[];
  filePath?: string;
  content?: string;
}

export interface CreateSkillRequest {
  skillName: string;
  displayName?: string;
  description?: string;
  scope: "user" | "project";
  content: string;
  category?: string;
  version?: string;
  author?: string;
  tags?: string[];
  dependencies?: string[];
}

export interface UpdateSkillRequest {
  skillName: string;
  displayName?: string;
  description?: string;
  scope?: "user" | "project";
  content?: string;
  category?: string;
  version?: string;
  author?: string;
  tags?: string[];
  dependencies?: string[];
  enabled?: boolean;
}

function authHeaders(extra?: Record<string, string>) {
  return {
    Authorization: `Bearer ${localStorage.getItem("token") || ""}`,
    ...(extra ?? {}),
  };
}

async function unwrap<T>(res: Response, errMsg: string): Promise<T> {
  if (!res.ok) {
    throw new Error(errMsg);
  }
  const json = (await res.json()) as ApiResponse<T>;
  if (json.code !== 200) {
    throw new Error(json.msg || errMsg);
  }
  return json.data;
}

export async function listSkills(scope: SkillScope = "all"): Promise<SkillDTO[]> {
  const qs = new URLSearchParams();
  if (scope) qs.set("scope", scope);
  const res = await fetch(apiUrl(`/api/skill/list?${qs.toString()}`), {
    method: "GET",
    headers: authHeaders(),
  });
  return unwrap<SkillDTO[]>(res, "获取技能列表失败");
}

export async function getSkill(skillName: string): Promise<SkillDTO> {
  const res = await fetch(apiUrl(`/api/skill/${encodeURIComponent(skillName)}`), {
    method: "GET",
    headers: authHeaders(),
  });
  return unwrap<SkillDTO>(res, "获取技能详情失败");
}

export async function createSkill(payload: CreateSkillRequest): Promise<void> {
  const res = await fetch(apiUrl("/api/skill/create"), {
    method: "POST",
    headers: authHeaders({ "Content-Type": "application/json" }),
    body: JSON.stringify(payload),
  });
  await unwrap<void>(res, "创建技能失败");
}

export async function updateSkill(payload: UpdateSkillRequest): Promise<void> {
  const res = await fetch(apiUrl("/api/skill/update"), {
    method: "POST",
    headers: authHeaders({ "Content-Type": "application/json" }),
    body: JSON.stringify(payload),
  });
  await unwrap<void>(res, "更新技能失败");
}

export async function deleteSkill(skillName: string, scope: Exclude<SkillScope, "all"> = "user"): Promise<void> {
  const qs = new URLSearchParams();
  qs.set("scope", scope);
  const res = await fetch(
    apiUrl(`/api/skill/${encodeURIComponent(skillName)}?${qs.toString()}`),
    {
      method: "DELETE",
      headers: authHeaders(),
    }
  );
  await unwrap<void>(res, "删除技能失败");
}

export async function toggleSkill(skillName: string, enabled: boolean): Promise<void> {
  const qs = new URLSearchParams();
  qs.set("enabled", String(enabled));
  const res = await fetch(
    apiUrl(`/api/skill/${encodeURIComponent(skillName)}/toggle?${qs.toString()}`),
    {
      method: "POST",
      headers: authHeaders(),
    }
  );
  await unwrap<void>(res, "切换技能状态失败");
}

export async function exportSkill(skillName: string): Promise<string> {
  const res = await fetch(apiUrl(`/api/skill/${encodeURIComponent(skillName)}/export`), {
    method: "GET",
    headers: authHeaders(),
  });
  return unwrap<string>(res, "导出技能失败");
}

/**
 * 导出技能为 ZIP 压缩包
 */
export async function exportSkillZip(skillName: string): Promise<Blob> {
  const res = await fetch(apiUrl(`/api/skill/${encodeURIComponent(skillName)}/export-zip`), {
    method: "GET",
    headers: authHeaders(),
  });
  if (!res.ok) {
    throw new Error("导出 ZIP 失败");
  }
  return res.blob();
}

/**
 * 从 ZIP 压缩包导入技能
 */
export async function importSkillZip(file: File, scope: "user" | "project" = "user"): Promise<void> {
  const formData = new FormData();
  formData.append("file", file);
  
  const res = await fetch(apiUrl(`/api/skill/import-zip?scope=${scope}`), {
    method: "POST",
    headers: {
      Authorization: `Bearer ${localStorage.getItem("token") || ""}`,
    },
    body: formData,
  });
  
  await unwrap<void>(res, "导入 ZIP 失败");
}

export async function importSkill(skillData: string): Promise<void> {
  const res = await fetch(apiUrl("/api/skill/import"), {
    method: "POST",
    headers: authHeaders({ "Content-Type": "application/json" }),
    body: JSON.stringify(skillData),
  });
  await unwrap<void>(res, "导入技能失败");
}
