# 面向数字图像版权保护的频域水印嵌入与提取系统设计与分析

本项目基于李小伟老师的数字密码技术课程，提供一个可直接运行的 MATLAB 课程实验工程，面向 `512x512` 彩色宿主图像和 `256x256` 水印图像，完整实现以下两套版权保护方案：

1. `DWT` 频域水印方案
2. `CAT` 风格四分组变换域水印方案

项目已经包含：

- 自动数据预处理与尺寸检查
- 水印嵌入与非盲提取
- 不可见性分析
- 鲁棒性分析
- 图像、曲线、CSV 表格自动保存
- 完整 Markdown 报告
- 示例输入图像自动生成逻辑

## 运行环境

- MATLAB `R2023a` 或更新版本
- 建议安装以下常用工具箱：
  - Image Processing Toolbox
  - Wavelet Toolbox

项目中使用的常见函数包括：`dwt2`、`idwt2`、`rgb2ycbcr`、`ycbcr2rgb`、`ssim`、`imnoise`、`medfilt2`、`imwrite`。

## 文件结构

```text
watermark_project/
├── main.m
├── README.md
├── data/
│   ├── host_512.png
│   └── watermark_256.png
├── src/
│   ├── ensure_demo_data.m
│   ├── preprocess_images.m
│   ├── dwt_embed.m
│   ├── dwt_extract.m
│   ├── cat_transform.m
│   ├── inverse_cat_transform.m
│   ├── cat_embed.m
│   ├── cat_extract.m
│   ├── compute_psnr_ssim_mse.m
│   ├── compute_nc.m
│   ├── add_attacks.m
│   ├── visualize_results.m
│   └── save_tables_and_figures.m
├── results/
│   ├── dwt/
│   └── cat/
└── docs/
    ├── final_report.md
    ├── final_report.pdf
    ├── final_report.html
    ├── final_report_summary.md
    ├── figure_index.md
    ├── result_highlights.md
    └── submission_checklist.md
```

## 输入图像准备

默认情况下，项目会使用：

- `data/host_512.png`
- `data/watermark_256.png`

若这两个文件不存在，`main.m` 会自动调用 `src/ensure_demo_data.m` 生成可复现实验用的示例图像。

亦可手动替换为自备实验图像，程序会自动执行以下预处理：

- 宿主图不足 `512x512` 时自动 resize 到 `512x512`
- 宿主图若为灰度图则扩展为三通道 RGB
- 水印图自动 resize 到 `256x256`
- 水印图若为彩色，会先转灰度
- 同时生成归一化灰度水印与二值水印

## 如何运行

在 MATLAB 中进入项目根目录后直接运行：

```matlab
main
```

程序会自动完成：

1. 读取并预处理输入图像
2. 分别执行 DWT 与 CAT 两种方案
3. 对 `alpha = [2, 4, 6, 8, 10]` 进行循环实验
4. 生成无攻击提取结果和有攻击提取结果
5. 计算 `PSNR`、`SSIM`、`MSE`、`NC`
6. 保存图像、曲线和 CSV 表格

## 输出结果说明

运行结束后，主要结果位于 `results/` 目录下。

- `results/original_host.png`：原始宿主图
- `results/original_watermark_gray.png`：原始灰度水印
- `results/original_watermark_binary.png`：原始二值水印
- `results/dwt/`：DWT 方案所有结果
- `results/cat/`：CAT 方案所有结果
- `results/scheme_comparison.png`：两种方案的不可见性与鲁棒性对比图
- `results/scheme_comparison.csv`：两种方案的核心指标对比表

在每个方案目录下还包含：

- `imperceptibility_metrics.csv`
- `extraction_metrics.csv`
- `robustness_metrics.csv`
- `psnr_curve.png`
- `ssim_curve.png`
- `mse_curve.png`
- `attack_nc_bar.png`
- `attack_ssim_bar.png`
- `robustness_alpha_curve.png`

并且每个 `alpha_xx/` 子目录会保存：

- 含水印图像
- 差分图
- 局部放大图
- 可视化总览图
- 攻击后的图像
- 攻击条件下提取的水印图像

## 默认实现说明

### DWT 方案

- 色彩空间：`YCbCr`
- 嵌入通道：`Y`
- 小波：`haar`
- 分解层数：`1`
- 嵌入子带：`HL`
- 嵌入方式：二值符号加性嵌入
- 提取方式：非盲提取

### CAT 方案

- 色彩空间：`YCbCr`
- 嵌入通道：`Y`
- 变换方式：四分组可逆奇偶重排 CAT 风格变换
- 分组定义：
  - `G1 = I(1:2:end, 1:2:end)`
  - `G2 = I(1:2:end, 2:2:end)`
  - `G3 = I(2:2:end, 1:2:end)`
  - `G4 = I(2:2:end, 2:2:end)`
- 默认嵌入组：`G2`
- 嵌入方式：二值符号加性嵌入
- 提取方式：非盲提取

## 可修改参数

在 `main.m` 中可以直接修改：

- `config.alphas`
- `config.watermark_mode`
- `config.dwt.subband`
- `config.cat.group_index`
- `config.attack.jpeg_qualities`
- `config.attack.gaussian_variance`
- `config.attack.salt_pepper_density`
- `config.attack.crop_ratio`

## 报告文件

- 正式 Markdown 报告：`docs/final_report.md`
- 网页阅读版：`docs/final_report.html`
- PDF 版：`docs/final_report.pdf`
- 摘要版结论：`docs/final_report_summary.md`
- 图表索引：`docs/figure_index.md`
- 数据亮点摘要：`docs/result_highlights.md`
- 课程要求检查表：`docs/submission_checklist.md`

运行实验后，可直接将 `results/` 下生成的图表插入或替换到 Markdown 报告中。
