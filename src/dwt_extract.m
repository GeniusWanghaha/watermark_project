function [watermark_binary, watermark_gray, extract_info] = dwt_extract(reference_host_rgb, test_rgb, alpha, options)
%DWT_EXTRACT Non-blind DWT watermark extraction.
%   Since the implementation is non-blind, the original host image is used
%   to compute the reference subband. The watermark estimate is obtained by
%   reversing the additive embedding:
%       P_hat = (S_test - S_ref) / (alpha / 255)

if ~isfield(options, 'dwt')
    error('Missing options.dwt configuration.');
end

reference_ycbcr = rgb2ycbcr(reference_host_rgb);
test_ycbcr = rgb2ycbcr(test_rgb);
reference_y = reference_ycbcr(:, :, 1);
test_y = test_ycbcr(:, :, 1);

[~, ref_lh, ref_hl, ~] = dwt2(reference_y, options.dwt.wavelet);
[~, test_lh, test_hl, ~] = dwt2(test_y, options.dwt.wavelet);

switch upper(options.dwt.subband)
    case 'LH'
        raw_payload = (test_lh - ref_lh) / max(alpha / 255, eps);
        extraction_domain = 'DWT-LH';
    case 'HL'
        raw_payload = (test_hl - ref_hl) / max(alpha / 255, eps);
        extraction_domain = 'DWT-HL';
    otherwise
        error('Unsupported DWT subband: %s', options.dwt.subband);
end

watermark_gray = min(max((raw_payload + 1) / 2, 0), 1);
watermark_binary = watermark_gray >= 0.5;

extract_info = struct();
extract_info.embedding_domain = extraction_domain;
extract_info.raw_payload = raw_payload;
end
