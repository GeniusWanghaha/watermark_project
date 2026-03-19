function [mse_value, psnr_value, ssim_value] = compute_psnr_ssim_mse(reference_image, test_image)
%COMPUTE_PSNR_SSIM_MSE Compute MSE, PSNR and SSIM on normalized images.
%   Input images are internally converted to double in [0, 1].

reference_image = im2double(reference_image);
test_image = im2double(test_image);

if ~isequal(size(reference_image), size(test_image))
    error('Input images must have the same size.');
end

difference = reference_image - test_image;
mse_value = mean(difference(:) .^ 2);

if mse_value < eps
    psnr_value = Inf;
else
    psnr_value = 10 * log10(1 / mse_value);
end

if ndims(reference_image) == 2 || size(reference_image, 3) == 1
    ssim_value = ssim(test_image, reference_image);
else
    channel_ssim = zeros(1, size(reference_image, 3));
    for channel_idx = 1:size(reference_image, 3)
        channel_ssim(channel_idx) = ssim(test_image(:, :, channel_idx), reference_image(:, :, channel_idx));
    end
    ssim_value = mean(channel_ssim);
end
end
