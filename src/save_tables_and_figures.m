function summary = save_tables_and_figures(scheme_name, quality_table, extraction_table, attack_table, output_dir)
%SAVE_TABLES_AND_FIGURES Export CSV tables and summary plots.
%   This function centralizes the quantitative result saving process so
%   each scheme leaves behind ready-to-use curves and tables.

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

quality_table = sortrows(quality_table, 'Alpha');
extraction_table = sortrows(extraction_table, 'Alpha');
attack_table = sortrows(attack_table, {'Alpha', 'Attack'});

writetable(quality_table, fullfile(output_dir, 'imperceptibility_metrics.csv'));
writetable(extraction_table, fullfile(output_dir, 'extraction_metrics.csv'));
writetable(attack_table, fullfile(output_dir, 'robustness_metrics.csv'));

save_single_curve(quality_table.Alpha, quality_table.PSNR_dB, '\alpha', 'PSNR / dB', ...
    sprintf('%s: alpha-PSNR curve', upper(scheme_name)), fullfile(output_dir, 'psnr_curve.png'));
save_single_curve(quality_table.Alpha, quality_table.SSIM, '\alpha', 'SSIM', ...
    sprintf('%s: alpha-SSIM curve', upper(scheme_name)), fullfile(output_dir, 'ssim_curve.png'));
save_single_curve(quality_table.Alpha, quality_table.MSE, '\alpha', 'MSE', ...
    sprintf('%s: alpha-MSE curve', upper(scheme_name)), fullfile(output_dir, 'mse_curve.png'));

no_attack_figure = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1100, 420]);
tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

nexttile;
plot(extraction_table.Alpha, extraction_table.NC, '-o', 'LineWidth', 1.8, 'MarkerSize', 7);
grid on;
xlabel('\alpha');
ylabel('NC');
title(sprintf('%s: NC without attacks', upper(scheme_name)));

nexttile;
plot(extraction_table.Alpha, extraction_table.Watermark_SSIM, '-s', 'LineWidth', 1.8, 'MarkerSize', 7);
grid on;
xlabel('\alpha');
ylabel('Watermark SSIM');
title(sprintf('%s: watermark SSIM without attacks', upper(scheme_name)));

saveas(no_attack_figure, fullfile(output_dir, 'no_attack_metrics.png'));
close(no_attack_figure);

attack_names = unique(attack_table.Attack, 'stable');
alphas = unique(attack_table.Alpha, 'stable');

nc_matrix = nan(numel(attack_names), numel(alphas));
ssim_matrix = nan(numel(attack_names), numel(alphas));

for attack_idx = 1:numel(attack_names)
    for alpha_idx = 1:numel(alphas)
        mask = strcmp(attack_table.Attack, attack_names{attack_idx}) & attack_table.Alpha == alphas(alpha_idx);
        if any(mask)
            nc_matrix(attack_idx, alpha_idx) = mean(attack_table.NC(mask));
            ssim_matrix(attack_idx, alpha_idx) = mean(attack_table.Watermark_SSIM(mask));
        end
    end
end

nc_bar_figure = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1200, 500]);
bar(nc_matrix, 'grouped');
grid on;
xticklabels(attack_names);
xtickangle(20);
set(gca, 'TickLabelInterpreter', 'none');
xlabel('Attack type');
ylabel('NC');
title(sprintf('%s: NC under different attacks', upper(scheme_name)));
legend(compose('\\alpha = %d', alphas), 'Location', 'bestoutside');
saveas(nc_bar_figure, fullfile(output_dir, 'attack_nc_bar.png'));
close(nc_bar_figure);

ssim_bar_figure = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1200, 500]);
bar(ssim_matrix, 'grouped');
grid on;
xticklabels(attack_names);
xtickangle(20);
set(gca, 'TickLabelInterpreter', 'none');
xlabel('Attack type');
ylabel('Watermark SSIM');
title(sprintf('%s: watermark SSIM under different attacks', upper(scheme_name)));
legend(compose('\\alpha = %d', alphas), 'Location', 'bestoutside');
saveas(ssim_bar_figure, fullfile(output_dir, 'attack_ssim_bar.png'));
close(ssim_bar_figure);

robustness_line_figure = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1200, 500]);
plot(alphas, nc_matrix.', '-o', 'LineWidth', 1.6, 'MarkerSize', 6);
grid on;
xlabel('\alpha');
ylabel('NC');
title(sprintf('%s: robustness change with alpha', upper(scheme_name)));
legend(attack_names, 'Location', 'bestoutside', 'Interpreter', 'none');
saveas(robustness_line_figure, fullfile(output_dir, 'robustness_alpha_curve.png'));
close(robustness_line_figure);

mean_nc = zeros(numel(alphas), 1);
mean_ssim = zeros(numel(alphas), 1);
for alpha_idx = 1:numel(alphas)
    mask = attack_table.Alpha == alphas(alpha_idx);
    mean_nc(alpha_idx) = mean(attack_table.NC(mask));
    mean_ssim(alpha_idx) = mean(attack_table.Watermark_SSIM(mask));
end

attack_alpha_table = table(alphas, mean_nc, mean_ssim, 'VariableNames', {'Alpha', 'MeanNC', 'MeanSSIM'});
writetable(attack_alpha_table, fullfile(output_dir, 'robustness_alpha_average.csv'));

peak_alpha = max(alphas);
attack_peak_table = attack_table(attack_table.Alpha == peak_alpha, :);
attack_peak_table = sortrows(attack_peak_table, 'Attack');

summary = struct();
summary.quality_table = quality_table;
summary.extraction_table = extraction_table;
summary.attack_table = attack_table;
summary.attack_alpha_table = attack_alpha_table;
summary.attack_peak_table = attack_peak_table;
end

function save_single_curve(x_data, y_data, x_label, y_label, figure_title, output_path)
curve_figure = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 720, 460]);
plot(x_data, y_data, '-o', 'LineWidth', 1.8, 'MarkerSize', 7);
grid on;
xlabel(x_label);
ylabel(y_label);
title(figure_title);
saveas(curve_figure, output_path);
close(curve_figure);
end
