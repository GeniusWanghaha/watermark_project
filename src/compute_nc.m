function nc_value = compute_nc(reference_watermark, extracted_watermark)
%COMPUTE_NC Compute normalized correlation between two watermark images.
%   Both inputs are converted to double precision. The implementation
%   matches the assignment formula and supports both binary and grayscale
%   watermarks.

reference_watermark = double(reference_watermark);
extracted_watermark = double(extracted_watermark);

if ~isequal(size(reference_watermark), size(extracted_watermark))
    error('Watermark images must have the same size.');
end

numerator = sum(sum(reference_watermark .* extracted_watermark));
denominator = sqrt(sum(sum(reference_watermark .^ 2)) * sum(sum(extracted_watermark .^ 2)));

if denominator < eps
    nc_value = 0;
else
    nc_value = numerator / denominator;
end
end
