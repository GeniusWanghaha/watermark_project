function [watermarked_rgb, embed_info] = cat_embed(host_rgb, watermark_data, alpha, options)
%CAT_EMBED Embed a watermark into one CAT-style transform group.
%   The host image is converted to YCbCr and the Y channel is decomposed
%   into four 256x256 groups using reversible odd-even coordinate
%   permutation. The selected group receives additive watermark embedding:
%       Gk_w = Gk + (alpha / 255) * P

if ~isfield(options, 'cat') || ~isfield(options.cat, 'group_index')
    error('Missing options.cat.group_index configuration.');
end

ycbcr_image = rgb2ycbcr(host_rgb);
y_channel = ycbcr_image(:, :, 1);
groups = cat_transform(y_channel);

payload = build_payload(watermark_data, options.watermark_mode);
alpha_scaled = alpha / 255;
group_name = sprintf('G%d', options.cat.group_index);

if ~isfield(groups, group_name)
    error('Unsupported CAT group: %s', group_name);
end

groups.(group_name) = groups.(group_name) + alpha_scaled * payload;
y_channel_w = inverse_cat_transform(groups);
y_channel_w = min(max(y_channel_w, 0), 1);

ycbcr_image(:, :, 1) = y_channel_w;
watermarked_rgb = ycbcr2rgb(ycbcr_image);
watermarked_rgb = min(max(watermarked_rgb, 0), 1);

embed_info = struct();
embed_info.embedding_domain = ['CAT-' group_name];
embed_info.alpha_scaled = alpha_scaled;
embed_info.group_name = group_name;
end

function payload = build_payload(watermark_data, watermark_mode)
switch lower(watermark_mode)
    case 'binary'
        payload = 2 * double(watermark_data >= 0.5) - 1;
    case 'grayscale'
        payload = 2 * mat2gray(double(watermark_data)) - 1;
    otherwise
        error('Unsupported watermark mode: %s', watermark_mode);
end
end
