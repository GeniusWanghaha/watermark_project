function visualize_results(original_rgb, watermarked_rgb, reference_watermark, extracted_gray, scheme_name, alpha, output_dir, zoom_region)
%VISUALIZE_RESULTS Save qualitative comparison images for a watermark test.
%   The function stores:
%       - difference map
%       - zoomed original / watermarked crops
%       - a combined 2x4 summary figure

if nargin < 8 || isempty(zoom_region)
    zoom_region = [161, 320, 161, 320];
end
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

row_start = max(1, zoom_region(1));
row_end = min(size(original_rgb, 1), zoom_region(2));
col_start = max(1, zoom_region(3));
col_end = min(size(original_rgb, 2), zoom_region(4));

diff_image = abs(watermarked_rgb - original_rgb);
diff_visual = diff_image / max(diff_image(:) + eps);

original_zoom = original_rgb(row_start:row_end, col_start:col_end, :);
watermarked_zoom = watermarked_rgb(row_start:row_end, col_start:col_end, :);
zoom_diff = abs(watermarked_zoom - original_zoom);
zoom_diff_visual = zoom_diff / max(zoom_diff(:) + eps);

imwrite(im2uint8(diff_visual), fullfile(output_dir, sprintf('%s_difference_alpha_%02d.png', scheme_name, alpha)));
imwrite(im2uint8(original_zoom), fullfile(output_dir, sprintf('%s_zoom_original_alpha_%02d.png', scheme_name, alpha)));
imwrite(im2uint8(watermarked_zoom), fullfile(output_dir, sprintf('%s_zoom_watermarked_alpha_%02d.png', scheme_name, alpha)));

summary_figure = figure('Visible', 'off', 'Color', 'w', 'Position', [80, 80, 1500, 820]);
tiledlayout(2, 4, 'Padding', 'compact', 'TileSpacing', 'compact');

nexttile;
imshow(original_rgb);
title('Original Host');

nexttile;
imshow(watermarked_rgb);
title(sprintf('Watermarked Host (\\alpha = %d)', alpha));

nexttile;
imshow(diff_visual);
title('|I_w - I|');

nexttile;
imshow(reference_watermark);
title('Reference Watermark');

nexttile;
imshow(original_zoom);
title('Zoomed Original');

nexttile;
imshow(watermarked_zoom);
title('Zoomed Watermarked');

nexttile;
imshow(zoom_diff_visual);
title('Zoomed Difference');

nexttile;
imshow(extracted_gray);
title('Extracted Watermark');

saveas(summary_figure, fullfile(output_dir, sprintf('%s_visual_overview_alpha_%02d.png', scheme_name, alpha)));
close(summary_figure);
end
