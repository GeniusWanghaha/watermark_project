# 课程作业要求符合性检查表

## 1. 题目核心要求对应情况

| 课程要求 | 完成情况 | 对应文件或结果 |
|---|---|---|
| 针对 `512×512` 彩色宿主图像完成水印嵌入 | 已完成 | `data/host_512.png`，`src/preprocess_images.m`，`src/dwt_embed.m`，`src/cat_embed.m` |
| 针对 `256×256` 水印图像完成嵌入与提取 | 已完成 | `data/watermark_256.png`，`src/dwt_extract.m`，`src/cat_extract.m` |
| 基于频域分解设计水印方案 | 已完成 | `DWT` 方案满足该核心要求，见 `src/dwt_embed.m`、`src/dwt_extract.m` |
| 给出嵌入层级、位置、强度机制 | 已完成 | `docs/final_report.md` 第 4 节；`main.m` 中 `alpha` 参数配置 |
| 输出含水印宿主图像 | 已完成 | `results/dwt/alpha_xx/`，`results/cat/alpha_xx/` |
| 视觉不可见性分析 | 已完成 | `results/original_host.png`，各 `visual_overview`、`difference`、`zoom` 图 |
| 量化不可见性分析 | 已完成 | `imperceptibility_metrics.csv`，`psnr_curve.png`，`ssim_curve.png`，`mse_curve.png` |
| 水印提取与提取效果展示 | 已完成 | `extraction_metrics.csv`，各 `extracted_gray`、`extracted_binary` 图 |
| 提取效果量化分析（NC/PSNR/SSIM） | 已完成 | `results/dwt/extraction_metrics.csv`，`results/cat/extraction_metrics.csv` |
| 系统性鲁棒性分析 | 已完成 | `robustness_metrics.csv`，`attack_nc_bar.png`，`robustness_alpha_curve.png` |

## 2. 具体攻击实验完成情况

| 攻击类型 | 是否完成 | 对应结果 |
|---|---|---|
| JPEG 压缩 | 已完成 | `JPEG_Q90`、`JPEG_Q70`、`JPEG_Q50` 相关攻击图与提取图 |
| 高斯噪声 | 已完成 | `GaussianNoise` 相关攻击图与提取图 |
| 椒盐噪声 | 已完成 | `SaltPepperNoise` 相关攻击图与提取图 |
| 中值滤波 | 已完成 | `MedianFilter3x3` 相关攻击图与提取图 |
| 裁剪后缩放恢复 | 已完成 | `CropResize_75Pct` 相关攻击图与提取图 |

## 3. 报告与提交材料

| 材料 | 是否已生成 | 路径 |
|---|---|---|
| 最终 Markdown 报告 | 已生成 | `docs/final_report.md` |
| 网页版报告 | 已生成 | `docs/final_report.html` |
| PDF 版本 | 已生成 | `docs/final_report.pdf` |
| 摘要版结论 | 已生成 | `docs/final_report_summary.md` |
| 图表索引 | 已生成 | `docs/figure_index.md` |
| 数据亮点摘要 | 已生成 | `docs/result_highlights.md` |

## 4. 提交时需注意的说明

1. 课程要求中的“基于频域分解”核心指标由 DWT 方案直接满足，CAT 方案作为扩展对比方案保留在项目中，用于强化方法比较与课堂中 “four groups for transform domain” 的对应关系。
2. 项目默认使用非盲提取，这是课程实验中便于分析的稳妥实现，但在报告第 8 节已经明确说明了这一局限与后续改进方向。
3. `results/` 目录中包含全部实验产物，数量较多，最终报告已从中筛选并引用关键图表。
