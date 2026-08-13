#!/usr/bin/env node
// Gera metadata/skills.catalog.json a partir de fontes já curadas no acervo:
// docs/keywords/*.md (keywords/path/tipo/descricao por skill), docs/precedencia-de-skills.md
// (conflitos com o plugin superpowers) e a seção "## Skills Relacionadas" de cada skill,
// quando existir. Não inventa dependência/conflito que não esteja em alguma dessas fontes.
//
// Uso: node scripts/build-skill-catalog.js
// Saída: metadata/skills.catalog.json

const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const SKILLS_DIR = path.join(ROOT, "skills");
const KEYWORDS_DIR = path.join(ROOT, "docs", "keywords");
const PRECEDENCIA_PATH = path.join(ROOT, "docs", "precedencia-de-skills.md");
const OUT_PATH = path.join(ROOT, "metadata", "skills.catalog.json");

function walkSkillFiles(dir) {
  const out = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (entry.name === "references" || entry.name === "assets") continue;
      out.push(...walkSkillFiles(full));
    } else if (entry.name.endsWith(".md")) {
      out.push(full);
    }
  }
  return out;
}

function relPath(p) {
  return path.relative(ROOT, p).split(path.sep).join("/");
}

// --- 1. Parse docs/keywords/*.md: blocos [nome] / keywords / path / tipo / descricao ---
function parseKeywordsMap() {
  const byPath = new Map();
  if (!fs.existsSync(KEYWORDS_DIR)) return byPath;
  for (const file of fs.readdirSync(KEYWORDS_DIR)) {
    if (!file.endsWith(".md")) continue;
    const text = fs.readFileSync(path.join(KEYWORDS_DIR, file), "utf8");
    const blocks = text.split(/\n(?=\[)/).filter((b) => b.trim().startsWith("["));
    for (const block of blocks) {
      const pathMatch = block.match(/^- path:\s*(\S+)/m);
      if (!pathMatch) continue;
      const skillPath = pathMatch[1].trim();
      const keywordsMatch = block.match(/^- keywords:\s*(.+)$/m);
      const tipoMatch = block.match(/^- tipo:\s*(\S+)/m);
      const descMatch = block.match(/^- descricao:\s*(.+)$/m);
      const tags = keywordsMatch
        ? keywordsMatch[1].split(",").map((k) => k.trim()).filter(Boolean)
        : [];
      byPath.set(skillPath, {
        tags,
        tipo: tipoMatch ? tipoMatch[1].trim() : null,
        summary: descMatch ? descMatch[1].trim() : null,
        keywords_category: path.basename(file, ".md"),
      });
    }
  }
  return byPath;
}

// --- 2. Parse docs/precedencia-de-skills.md: tabela acervo x superpowers ---
function parsePrecedencia() {
  const map = new Map();
  if (!fs.existsSync(PRECEDENCIA_PATH)) return map;
  const text = fs.readFileSync(PRECEDENCIA_PATH, "utf8");
  const rows = text.match(/^\|\s*`([^`]+)`\s*\|\s*`([^`]+)`.*$/gm) || [];
  for (const row of rows) {
    const m = row.match(/^\|\s*`([^`]+)`\s*\|\s*`([^`]+)`/);
    if (!m) continue;
    const acervoSkill = m[1].trim(); // ex: skills/audit/systematic-debugging
    const pluginSkill = m[2].trim(); // ex: superpowers:systematic-debugging
    const skillPath = acervoSkill.endsWith(".md") ? acervoSkill : `${acervoSkill}.md`;
    map.set(skillPath, pluginSkill);
  }
  return map;
}

// --- 3. "## Skills Relacionadas" explícito dentro do próprio arquivo ---
function parseRelated(fileText) {
  const section = fileText.match(/## Skills Relacionadas\n([\s\S]*?)(\n## |\n---|\n$|$)/i);
  if (!section) return [];
  const lines = section[1].split("\n");
  const related = [];
  for (const line of lines) {
    const m = line.match(/`([a-zA-Z0-9_\-./]+\.md)`/);
    if (m) related.push(m[1]);
  }
  return related;
}

function firstParagraphAfterTitle(fileText) {
  const lines = fileText.split("\n");
  let sawTitle = false;
  const buf = [];
  for (const line of lines) {
    const trimmed = line.trim();
    if (!sawTitle) {
      if (trimmed.startsWith("#")) sawTitle = true;
      continue;
    }
    if (!trimmed) {
      if (buf.length) break;
      continue;
    }
    if (trimmed.startsWith("#") || trimmed.startsWith("---")) break;
    buf.push(trimmed);
  }
  return buf.join(" ").slice(0, 220) || null;
}

function main() {
  const keywordsMap = parseKeywordsMap();
  const precedenciaMap = parsePrecedencia();
  const files = walkSkillFiles(SKILLS_DIR);

  const catalog = [];
  for (const abs of files) {
    const skillPath = relPath(abs);
    const category = skillPath.split("/")[1]; // skills/<category>/...
    const name = path.basename(skillPath, ".md");
    const fileText = fs.readFileSync(abs, "utf8");
    const fromKeywords = keywordsMap.get(skillPath);
    const related = parseRelated(fileText);
    const superpowersEquivalent = precedenciaMap.get(skillPath) || null;

    catalog.push({
      path: skillPath,
      category,
      name,
      tipo: fromKeywords?.tipo || (category === "behavioral" ? "behavioral" : "tecnica"),
      tags: fromKeywords?.tags || [],
      summary: fromKeywords?.summary || firstParagraphAfterTitle(fileText),
      related,
      superpowers_equivalent: superpowersEquivalent,
      agnostic_skills_pattern: skillPath.replace(/^skills\//, "").replace(/\.md$/, ""),
    });
  }

  catalog.sort((a, b) => a.path.localeCompare(b.path));

  const output = {
    _comment:
      "Gerado por scripts/build-skill-catalog.js a partir de docs/keywords/*.md, docs/precedencia-de-skills.md e das seções 'Skills Relacionadas' de cada skill. Não editar à mão — rode o script de novo após mudar skills/ ou docs/keywords/.",
    generated_at: new Date().toISOString(),
    count: catalog.length,
    skills: catalog,
  };

  fs.mkdirSync(path.dirname(OUT_PATH), { recursive: true });
  fs.writeFileSync(OUT_PATH, JSON.stringify(output, null, 2) + "\n");

  const withoutTags = catalog.filter((s) => s.tags.length === 0).length;
  console.log(`metadata/skills.catalog.json gerado: ${catalog.length} skills.`);
  if (withoutTags) {
    console.log(
      `${withoutTags} sem tags curadas em docs/keywords/ (summary derivado direto do arquivo) — considerar adicionar ao keywords-map se forem tecnicas.`
    );
  }
}

main();
