function [host_rgb, watermark, metadata] = preprocess_images(host_path, watermark_path)
%PREPROCESS_IMAGES Read, resize, normalize and prepare host and watermark.
%   Host image is forced to RGB 512x512.
%   Watermark image is forced to grayscale 256x256 and additionally
%   converted into a binary map for sign-based embedding.

if ~exist(host_path, 'file')
    error('Host image not found: %s', host_path);
end
if ~exist(watermark_path, 'file')
    error('Watermark image not found: %s', watermark_path);
end

host_raw = imread(host_path);
if ndims(host_raw) == 2
    host_raw = repmat(host_raw, [1, 1, 3]);
elseif size(host_raw, 3) > 3
    host_raw = host_raw(:, :, 1:3);
end
host_rgb = im2double(imresize(host_raw, [512, 512]));

watermark_raw = imread(watermark_path);
if ndims(watermark_raw) == 3
    watermark_rgb = im2double(imresize(watermark_raw(:, :, 1:3), [256, 256]));
    watermark_gray = rgb2gray(watermark_rgb);
else
    watermark_rgb = im2double(imresize(watermark_raw, [256, 256]));
    watermark_gray = watermark_rgb;
end
watermark_gray = mat2gray(watermark_gray);
watermark_threshold = graythresh(watermark_gray);
watermark_binary = imbinarize(watermark_gray, watermark_threshold);

watermark = struct();
watermark.rgb = watermark_rgb;
watermark.gray = watermark_gray;
watermark.binary = watermark_binary;
watermark.sign = 2 * double(watermark_binary) - 1;
watermark.for_embed = watermark_binary;
watermark.for_embed_gray = watermark_gray;

metadata = struct();
metadata.host_original_size = size(host_raw);
metadata.watermark_original_size = size(watermark_raw);
metadata.watermark_threshold = watermark_threshold;
end
