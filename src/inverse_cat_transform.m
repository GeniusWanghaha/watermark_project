function channel_image = inverse_cat_transform(groups)
%INVERSE_CAT_TRANSFORM Inverse mapping of the four-group CAT-style transform.
%   The inverse simply places each group back onto its odd-even coordinate
%   positions, which guarantees exact reversibility.

group_names = {'G1', 'G2', 'G3', 'G4'};
for idx = 1:numel(group_names)
    if ~isfield(groups, group_names{idx})
        error('Missing CAT group: %s', group_names{idx});
    end
end

[group_rows, group_cols] = size(groups.G1);
channel_image = zeros(group_rows * 2, group_cols * 2);

channel_image(1:2:end, 1:2:end) = groups.G1;
channel_image(1:2:end, 2:2:end) = groups.G2;
channel_image(2:2:end, 1:2:end) = groups.G3;
channel_image(2:2:end, 2:2:end) = groups.G4;
end
