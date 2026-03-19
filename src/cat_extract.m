function [watermark_binary, watermark_gray, extract_info] = cat_extract(reference_host_rgb, test_rgb, alpha, options)
%CAT_EXTRACT Non-blind extraction for the CAT-style four-group scheme.
%   The selected group is reconstructed from the test image and the
%   original host image. Their difference divided by embedding gain gives
%   the watermark payload estimate.

reference_ycbcr = rgb2ycbcr(reference_host_rgb);
test_ycbcr = rgb2ycbcr(test_rgb);

reference_groups = cat_transform(reference_ycbcr(:, :, 1));
test_groups = cat_transform(test_ycbcr(:, :, 1));

group_name = sprintf('G%d', options.cat.group_index);
if ~isfield(reference_groups, group_name)
    error('Unsupported CAT group: %s', group_name);
end

raw_payload = (test_groups.(group_name) - reference_groups.(group_name)) / max(alpha / 255, eps);
watermark_gray = min(max((raw_payload + 1) / 2, 0), 1);
watermark_binary = watermark_gray >= 0.5;

extract_info = struct();
extract_info.embedding_domain = ['CAT-' group_name];
extract_info.raw_payload = raw_payload;
end
