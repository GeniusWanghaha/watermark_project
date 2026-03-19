function groups = cat_transform(channel_image)
%CAT_TRANSFORM Reversible four-group CAT-style transform.
%   The transform is based on odd-even coordinate permutation:
%       G1 = I(1:2:end, 1:2:end)
%       G2 = I(1:2:end, 2:2:end)
%       G3 = I(2:2:end, 1:2:end)
%       G4 = I(2:2:end, 2:2:end)
%   For a 512x512 image, each group is exactly 256x256.

[rows, cols] = size(channel_image);
if mod(rows, 2) ~= 0 || mod(cols, 2) ~= 0
    error('CAT transform requires even-sized dimensions.');
end

groups = struct();
groups.G1 = channel_image(1:2:end, 1:2:end);
groups.G2 = channel_image(1:2:end, 2:2:end);
groups.G3 = channel_image(2:2:end, 1:2:end);
groups.G4 = channel_image(2:2:end, 2:2:end);
groups.original_size = [rows, cols];
end
