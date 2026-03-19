clear;
clc;
close all;

project_root = fileparts(mfilename('fullpath'));
addpath(fullfile(project_root, 'src'));

data_dir = fullfile(project_root, 'data');
results_dir = fullfile(project_root, 'results');
docs_dir = fullfile(project_root, 'docs');

if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end
if ~exist(fullfile(results_dir, 'dwt'), 'dir')
    mkdir(fullfile(results_dir, 'dwt'));
end
if ~exist(fullfile(results_dir, 'cat'), 'dir')
    mkdir(fullfile(results_dir, 'cat'));
end
if ~exist(docs_dir, 'dir')
    mkdir(docs_dir);
end

host_path = fullfile(data_dir, 'host_512.png');
watermark_path = fullfile(data_dir, 'watermark_256.png');
ensure_demo_data(host_path, watermark_path);

config.alphas = [2, 4, 6, 8, 10];
config.watermark_mode = 'binary';
config.zoom_region = [161, 320, 161, 320]; % [row_start, row_end, col_start, col_end]

config.dwt.wavelet = 'haar';
config.dwt.subband = 'HL';

config.cat.group_index = 2;

config.attack.jpeg_qualities = [90, 70, 50];
config.attack.gaussian_variance = 0.001;
config.attack.salt_pepper_density = 0.01;
config.attack.crop_ratio = 0.75;

fprintf('===============================================\n');
fprintf(' 数字图像水印实验开始 \n');
fprintf(' 宿主图像路径 : %s\n', host_path);
fprintf(' 水印图像路径 : %s\n', watermark_path);
fprintf(' Alpha 参数   : %s\n', mat2str(config.alphas));
fprintf('===============================================\n');

[host_rgb, watermark, preprocess_info] = preprocess_images(host_path, watermark_path);

switch lower(config.watermark_mode)
    case 'binary'
        watermark_payload = watermark.for_embed;
        watermark_reference = double(watermark.binary);
    case 'grayscale'
        watermark_payload = watermark.for_embed_gray;
        watermark_reference = watermark.gray;
    otherwise
        error('Unsupported watermark mode: %s', config.watermark_mode);
end

imwrite(im2uint8(host_rgb), fullfile(results_dir, 'original_host.png'));
imwrite(im2uint8(watermark.gray), fullfile(results_dir, 'original_watermark_gray.png'));
imwrite(im2uint8(double(watermark.binary)), fullfile(results_dir, 'original_watermark_binary.png'));

fprintf('Host image resized to       : %dx%dx%d\n', size(host_rgb, 1), size(host_rgb, 2), size(host_rgb, 3));
fprintf('Watermark image resized to  : %dx%d\n', size(watermark.gray, 1), size(watermark.gray, 2));
fprintf('Watermark Otsu threshold    : %.4f\n', preprocess_info.watermark_threshold);

schemes = {'dwt', 'cat'};
scheme_summaries = struct();

for scheme_idx = 1:numel(schemes)
    scheme_name = schemes{scheme_idx};
    scheme_dir = fullfile(results_dir, scheme_name);
    if ~exist(scheme_dir, 'dir')
        mkdir(scheme_dir);
    end

    fprintf('\n-----------------------------------------------\n');
    fprintf('执行方案：%s\n', upper(scheme_name));
    fprintf('-----------------------------------------------\n');

    quality_records = struct('Alpha', {}, 'MSE', {}, 'PSNR_dB', {}, 'SSIM', {});
    extraction_records = struct('Alpha', {}, 'NC', {}, 'NC_Binary', {}, 'Watermark_PSNR_dB', {}, 'Watermark_SSIM', {}, 'Watermark_MSE', {});
    attack_records = struct('Alpha', {}, 'Attack', {}, 'NC', {}, 'Watermark_PSNR_dB', {}, 'Watermark_SSIM', {}, 'Watermark_MSE', {});

    for alpha_idx = 1:numel(config.alphas)
        alpha = config.alphas(alpha_idx);
        alpha_tag = sprintf('alpha_%02d', alpha);
        alpha_dir = fullfile(scheme_dir, alpha_tag);
        if ~exist(alpha_dir, 'dir')
            mkdir(alpha_dir);
        end

        fprintf('  Alpha = %d ...\n', alpha);

        switch lower(scheme_name)
            case 'dwt'
                [watermarked_rgb, embed_info] = dwt_embed(host_rgb, watermark_payload, alpha, config);
                [extracted_bin, extracted_gray] = dwt_extract(host_rgb, watermarked_rgb, alpha, config);
            case 'cat'
                [watermarked_rgb, embed_info] = cat_embed(host_rgb, watermark_payload, alpha, config);
                [extracted_bin, extracted_gray] = cat_extract(host_rgb, watermarked_rgb, alpha, config);
            otherwise
                error('Unknown scheme: %s', scheme_name);
        end

        [host_mse, host_psnr, host_ssim] = compute_psnr_ssim_mse(host_rgb, watermarked_rgb);
        [wm_mse, wm_psnr, wm_ssim] = compute_psnr_ssim_mse(watermark_reference, extracted_gray);
        nc_value = compute_nc(watermark_reference, extracted_gray);
        nc_binary = compute_nc(double(watermark.binary), double(extracted_bin));

        quality_records(end + 1) = struct( ...
            'Alpha', alpha, ...
            'MSE', host_mse, ...
            'PSNR_dB', host_psnr, ...
            'SSIM', host_ssim);

        extraction_records(end + 1) = struct( ...
            'Alpha', alpha, ...
            'NC', nc_value, ...
            'NC_Binary', nc_binary, ...
            'Watermark_PSNR_dB', wm_psnr, ...
            'Watermark_SSIM', wm_ssim, ...
            'Watermark_MSE', wm_mse);

        imwrite(im2uint8(watermarked_rgb), fullfile(alpha_dir, sprintf('%s_watermarked_alpha_%02d.png', scheme_name, alpha)));
        imwrite(im2uint8(extracted_gray), fullfile(alpha_dir, sprintf('%s_extracted_gray_alpha_%02d.png', scheme_name, alpha)));
        imwrite(im2uint8(double(extracted_bin)), fullfile(alpha_dir, sprintf('%s_extracted_binary_alpha_%02d.png', scheme_name, alpha)));

        visualize_results( ...
            host_rgb, ...
            watermarked_rgb, ...
            watermark_reference, ...
            extracted_gray, ...
            scheme_name, ...
            alpha, ...
            alpha_dir, ...
            config.zoom_region);

        attacks = add_attacks(watermarked_rgb, config.attack, alpha_dir);
        for attack_idx = 1:numel(attacks)
            attacked_image = attacks(attack_idx).image;
            attack_name = attacks(attack_idx).name;

            switch lower(scheme_name)
                case 'dwt'
                    [attacked_bin, attacked_gray] = dwt_extract(host_rgb, attacked_image, alpha, config);
                case 'cat'
                    [attacked_bin, attacked_gray] = cat_extract(host_rgb, attacked_image, alpha, config);
            end

            [attack_mse, attack_psnr, attack_ssim] = compute_psnr_ssim_mse(watermark_reference, attacked_gray);

            attack_records(end + 1) = struct( ...
                'Alpha', alpha, ...
                'Attack', attack_name, ...
                'NC', compute_nc(watermark_reference, attacked_gray), ...
                'Watermark_PSNR_dB', attack_psnr, ...
                'Watermark_SSIM', attack_ssim, ...
                'Watermark_MSE', attack_mse);

            imwrite(im2uint8(attacked_image), fullfile(alpha_dir, sprintf('%s_%s_attacked_alpha_%02d.png', scheme_name, attack_name, alpha)));
            imwrite(im2uint8(attacked_gray), fullfile(alpha_dir, sprintf('%s_%s_extracted_gray_alpha_%02d.png', scheme_name, attack_name, alpha)));
            imwrite(im2uint8(double(attacked_bin)), fullfile(alpha_dir, sprintf('%s_%s_extracted_binary_alpha_%02d.png', scheme_name, attack_name, alpha)));
        end

        fprintf('    Host metrics     -> PSNR = %7.4f dB, SSIM = %0.5f, MSE = %0.6f\n', host_psnr, host_ssim, host_mse);
        fprintf('    Watermark metric -> NC   = %0.5f, SSIM = %0.5f, PSNR = %7.4f dB\n', nc_value, wm_ssim, wm_psnr);
        fprintf('    Embedding area   -> %s\n', embed_info.embedding_domain);
    end

    quality_table = struct2table(quality_records);
    extraction_table = struct2table(extraction_records);
    attack_table = struct2table(attack_records);

    scheme_summaries.(scheme_name) = save_tables_and_figures( ...
        scheme_name, quality_table, extraction_table, attack_table, scheme_dir);
end

fprintf('\n-----------------------------------------------\n');
fprintf('生成跨方案对比图与汇总表 ...\n');
fprintf('-----------------------------------------------\n');

dwt_quality = scheme_summaries.dwt.quality_table;
cat_quality = scheme_summaries.cat.quality_table;
dwt_extraction = scheme_summaries.dwt.extraction_table;
cat_extraction = scheme_summaries.cat.extraction_table;
dwt_attack_mean = scheme_summaries.dwt.attack_alpha_table;
cat_attack_mean = scheme_summaries.cat.attack_alpha_table;

comparison_fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1200, 460]);
tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

nexttile;
plot(dwt_quality.Alpha, dwt_quality.PSNR_dB, '-o', 'LineWidth', 1.8, 'MarkerSize', 7);
hold on;
plot(cat_quality.Alpha, cat_quality.PSNR_dB, '-s', 'LineWidth', 1.8, 'MarkerSize', 7);
grid on;
xlabel('\alpha');
ylabel('PSNR / dB');
title('Imperceptibility Comparison');
legend({'DWT', 'CAT'}, 'Location', 'best');

nexttile;
plot(dwt_attack_mean.Alpha, dwt_attack_mean.MeanNC, '-o', 'LineWidth', 1.8, 'MarkerSize', 7);
hold on;
plot(cat_attack_mean.Alpha, cat_attack_mean.MeanNC, '-s', 'LineWidth', 1.8, 'MarkerSize', 7);
grid on;
xlabel('\alpha');
ylabel('Average NC under attacks');
title('Robustness Comparison');
legend({'DWT', 'CAT'}, 'Location', 'best');

saveas(comparison_fig, fullfile(results_dir, 'scheme_comparison.png'));
close(comparison_fig);

highest_alpha = max(config.alphas);
dwt_attack_peak = scheme_summaries.dwt.attack_peak_table;
cat_attack_peak = scheme_summaries.cat.attack_peak_table;
attack_labels = dwt_attack_peak.Attack;

peak_fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1100, 500]);
nc_peak_matrix = [dwt_attack_peak.NC, cat_attack_peak.NC];
bar(nc_peak_matrix, 'grouped');
grid on;
xticklabels(attack_labels);
xtickangle(20);
set(gca, 'TickLabelInterpreter', 'none');
xlabel('Attack type');
ylabel('NC');
title(sprintf('NC Comparison at \\alpha = %d', highest_alpha));
legend({'DWT', 'CAT'}, 'Location', 'best');
saveas(peak_fig, fullfile(results_dir, sprintf('scheme_attack_comparison_alpha_%02d.png', highest_alpha)));
close(peak_fig);

comparison_table = table( ...
    dwt_quality.Alpha, ...
    dwt_quality.PSNR_dB, ...
    cat_quality.PSNR_dB, ...
    dwt_extraction.NC, ...
    cat_extraction.NC, ...
    dwt_attack_mean.MeanNC, ...
    cat_attack_mean.MeanNC, ...
    'VariableNames', { ...
    'Alpha', ...
    'DWT_PSNR_dB', ...
    'CAT_PSNR_dB', ...
    'DWT_NC_NoAttack', ...
    'CAT_NC_NoAttack', ...
    'DWT_MeanNC_Attacked', ...
    'CAT_MeanNC_Attacked'});
writetable(comparison_table, fullfile(results_dir, 'scheme_comparison.csv'));

fprintf('\n实验完成。\n');
fprintf('结果目录：%s\n', results_dir);
fprintf('报告文件：%s\n', fullfile(docs_dir, 'final_report.md'));
