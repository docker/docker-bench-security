#!/usr/bin/env python3
import json, sys, pathlib

log_dir = pathlib.Path(__file__).parent / "log"
json_file = log_dir / "docker-bench-security.log.json"
output_file = log_dir / "report.html"

with open(json_file) as f:
    data = json.load(f)

COLORS = {"PASS": "#2ecc71", "WARN": "#e74c3c", "INFO": "#3498db", "NOTE": "#f39c12"}
BG     = {"PASS": "#eafaf1", "WARN": "#fdedec", "INFO": "#eaf4fb", "NOTE": "#fef9e7"}

rows = []
totals = {"PASS": 0, "WARN": 0, "INFO": 0, "NOTE": 0}

for section in data.get("tests", []):
    rows.append(f'<tr><td colspan="4" style="background:#2c3e50;color:#fff;padding:8px 12px;font-weight:bold">'
                f'{section["id"]} — {section["desc"]}</td></tr>')
    for r in section.get("results", []):
        result = r.get("result", "INFO")
        totals[result] = totals.get(result, 0) + 1
        color = COLORS.get(result, "#999")
        bg    = BG.get(result, "#fff")
        details = r.get("details", "")
        items   = "<br>".join(r.get("items", []))
        extra   = (details + ("<br>" if details and items else "") + items).strip()
        rows.append(
            f'<tr style="background:{bg}">'
            f'<td style="width:80px;text-align:center;font-weight:bold;color:{color}">{result}</td>'
            f'<td style="width:70px;color:#555">{r["id"]}</td>'
            f'<td>{r["desc"]}</td>'
            f'<td style="font-size:0.85em;color:#555">{extra}</td>'
            f'</tr>'
        )

score = data.get("score", "?")
html = f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Docker Bench Security Report</title>
<style>
  body {{ font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }}
  h1   {{ color: #2c3e50; }}
  .summary {{ display:flex; gap:16px; margin-bottom:20px; flex-wrap:wrap; }}
  .badge   {{ padding:12px 24px; border-radius:8px; font-size:1.1em; font-weight:bold; color:#fff; }}
  table    {{ border-collapse: collapse; width:100%; background:#fff; box-shadow:0 1px 4px rgba(0,0,0,.1); }}
  td       {{ padding:8px 12px; border-bottom:1px solid #eee; vertical-align:top; }}
</style>
</head>
<body>
<h1>Docker Bench for Security v{data.get("dockerbenchsecurity","?")} — Reporte</h1>
<div class="summary">
  <div class="badge" style="background:#2c3e50">Score: {score}</div>
  <div class="badge" style="background:#2ecc71">PASS: {totals.get("PASS",0)}</div>
  <div class="badge" style="background:#e74c3c">WARN: {totals.get("WARN",0)}</div>
  <div class="badge" style="background:#3498db">INFO: {totals.get("INFO",0)}</div>
  <div class="badge" style="background:#f39c12">NOTE: {totals.get("NOTE",0)}</div>
</div>
<table>
  <thead><tr style="background:#34495e;color:#fff">
    <th>Resultado</th><th>ID</th><th>Descripción</th><th>Detalle</th>
  </tr></thead>
  <tbody>{"".join(rows)}</tbody>
</table>
</body>
</html>"""

output_file.write_text(html)
print(f"Reporte generado: {output_file}")
