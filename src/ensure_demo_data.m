function ensure_demo_data(host_path, watermark_path)
%ENSURE_DEMO_DATA Create deterministic default images when input files are absent.
%   The generated images are purely deterministic, so experiments remain
%   reproducible across runs.

[host_dir, ~, ~] = fileparts(host_path);
if ~exist(host_dir, 'dir')
    mkdir(host_dir);
end

if ~exist(host_path, 'file')
    host_image = generate_host_image();
    imwrite(im2uint8(host_image), host_path);
end

if ~exist(watermark_path, 'file')
    watermark_image = generate_watermark_image();
    imwrite(im2uint8(watermark_image), watermark_path);
end
end

function host_image = generate_host_image()
image_size = 512;
[x, y] = meshgrid(linspace(-1, 1, image_size), linspace(-1, 1, image_size));
radius = sqrt(x .^ 2 + y .^ 2);
angle_map = atan2(y, x);

stripe_a = 0.5 + 0.5 * sin(2 * pi * (2.8 * x + 1.6 * y));
stripe_b = 0.5 + 0.5 * cos(2 * pi * (1.5 * x - 2.4 * y));
checker = 0.5 + 0.5 * sin(2 * pi * 7 * x) .* sin(2 * pi * 7 * y);
ring = double(radius > 0.38 & radius < 0.48);
disk = double(radius < 0.62);
diagonal_band = double(abs(x - y) < 0.08);
spiral = 0.5 + 0.5 * cos(12 * radius + 4 * angle_map);

red_channel = 0.18 + 0.34 * stripe_a + 0.22 * disk + 0.16 * spiral;
green_channel = 0.16 + 0.38 * stripe_b + 0.18 * checker + 0.14 * diagonal_band;
blue_channel = 0.14 + 0.42 * (1 - radius / max(radius(:))) + 0.18 * ring + 0.14 * checker;

top_left_patch = abs(x + 0.55) < 0.14 & abs(y + 0.52) < 0.10;
bottom_right_patch = abs(x - 0.52) < 0.16 & abs(y - 0.48) < 0.14;
center_cross = abs(x) < 0.04 | abs(y) < 0.04;

red_channel = red_channel + 0.22 * top_left_patch - 0.05 * bottom_right_patch;
green_channel = green_channel + 0.18 * bottom_right_patch + 0.10 * center_cross;
blue_channel = blue_channel + 0.12 * top_left_patch + 0.20 * ring;

host_image = cat(3, red_channel, green_channel, blue_channel);
host_image = min(max(host_image, 0), 1);
end

function watermark_image = generate_watermark_image()
image_size = 256;
[x, y] = meshgrid(linspace(-1, 1, image_size), linspace(-1, 1, image_size));
radius = sqrt(x .^ 2 + y .^ 2);

checker = mod(floor((x + 1) * 10) + floor((y + 1) * 10), 2) == 0;
ring = double(radius > 0.55 & radius < 0.74);
cross = double(abs(x) < 0.05 | abs(y) < 0.05);
corner_blocks = double(abs(x) > 0.72 & abs(y) > 0.72);
diamond = double(abs(x) + abs(y) < 0.72);
sin_texture = 0.5 + 0.5 * sin(2 * pi * 5 * x) .* cos(2 * pi * 5 * y);

watermark_image = 0.10 ...
    + 0.18 * double(checker) ...
    + 0.28 * ring ...
    + 0.26 * cross ...
    + 0.18 * corner_blocks ...
    + 0.18 * diamond ...
    + 0.12 * sin_texture;

watermark_image = mat2gray(watermark_image);
end
