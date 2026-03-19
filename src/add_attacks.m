function attacks = add_attacks(input_rgb, attack_config, working_dir)
%ADD_ATTACKS Generate common robustness attacks for watermark evaluation.
%   Implemented attacks:
%       1. JPEG compression (Q = 90, 70, 50)
%       2. Gaussian noise
%       3. Salt-and-pepper noise
%       4. Median filtering
%       5. Crop and resize

if nargin < 3 || isempty(working_dir)
    working_dir = tempdir;
end
if ~exist(working_dir, 'dir')
    mkdir(working_dir);
end

attacks = struct('name', {}, 'image', {});
attack_counter = 0;

for quality_idx = 1:numel(attack_config.jpeg_qualities)
    quality = attack_config.jpeg_qualities(quality_idx);
    jpeg_path = fullfile(working_dir, sprintf('temporary_quality_%d.jpg', quality));
    imwrite(im2uint8(input_rgb), jpeg_path, 'jpg', 'Quality', quality);
    jpeg_image = im2double(imread(jpeg_path));
    if exist(jpeg_path, 'file')
        delete(jpeg_path);
    end

    attack_counter = attack_counter + 1;
    attacks(attack_counter).name = sprintf('JPEG_Q%d', quality);
    attacks(attack_counter).image = jpeg_image;
end

gaussian_image = imnoise(input_rgb, 'gaussian', 0, attack_config.gaussian_variance);
attack_counter = attack_counter + 1;
attacks(attack_counter).name = 'GaussianNoise';
attacks(attack_counter).image = gaussian_image;

sp_image = imnoise(input_rgb, 'salt & pepper', attack_config.salt_pepper_density);
attack_counter = attack_counter + 1;
attacks(attack_counter).name = 'SaltPepperNoise';
attacks(attack_counter).image = sp_image;

median_image = zeros(size(input_rgb));
for channel_idx = 1:size(input_rgb, 3)
    median_image(:, :, channel_idx) = medfilt2(input_rgb(:, :, channel_idx), [3, 3], 'symmetric');
end
attack_counter = attack_counter + 1;
attacks(attack_counter).name = 'MedianFilter3x3';
attacks(attack_counter).image = median_image;

[rows, cols, ~] = size(input_rgb);
crop_ratio = attack_config.crop_ratio;
crop_rows = round(rows * crop_ratio);
crop_cols = round(cols * crop_ratio);
row_start = floor((rows - crop_rows) / 2) + 1;
col_start = floor((cols - crop_cols) / 2) + 1;
row_end = row_start + crop_rows - 1;
col_end = col_start + crop_cols - 1;

cropped_image = input_rgb(row_start:row_end, col_start:col_end, :);
cropped_resized = imresize(cropped_image, [rows, cols]);

attack_counter = attack_counter + 1;
attacks(attack_counter).name = sprintf('CropResize_%02dPct', round(crop_ratio * 100));
attacks(attack_counter).image = cropped_resized;
end
