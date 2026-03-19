function [watermarked_rgb, embed_info] = dwt_embed(host_rgb, watermark_data, alpha, options)
%DWT_EMBED Embed a watermark into the DWT detail subband of the Y channel.
%   The host image is converted to YCbCr. A one-level Haar DWT is applied
%   to the Y channel. The selected 256x256 detail subband receives additive
%   watermark modulation:
%       S_w = S + (alpha / 255) * P
%   where P is either a binary sign map in {-1, +1} or a zero-centered
%   grayscale payload in [-1, +1].

if ~isfield(options, 'dwt')
    error('Missing options.dwt configuration.');
end
if size(host_rgb, 3) ~= 3
    error('DWT embedding expects an RGB host image.');
end

ycbcr_image = rgb2ycbcr(host_rgb);
y_channel = ycbcr_image(:, :, 1);

[ll_band, lh_band, hl_band, hh_band] = dwt2(y_channel, options.dwt.wavelet);
payload = build_payload(watermark_data, options.watermark_mode);
alpha_scaled = alpha / 255;

switch upper(options.dwt.subband)
    case 'LH'
        target_band_w = lh_band + alpha_scaled * payload;
        y_channel_w = idwt2(ll_band, target_band_w, hl_band, hh_band, options.dwt.wavelet, size(y_channel));
        embedding_domain = 'DWT-LH';
    case 'HL'
        target_band_w = hl_band + alpha_scaled * payload;
        y_channel_w = idwt2(ll_band, lh_band, target_band_w, hh_band, options.dwt.wavelet, size(y_channel));
        embedding_domain = 'DWT-HL';
    otherwise
        error('Unsupported DWT subband: %s', options.dwt.subband);
end

ycbcr_image(:, :, 1) = min(max(y_channel_w, 0), 1);
watermarked_rgb = ycbcr2rgb(ycbcr_image);
watermarked_rgb = min(max(watermarked_rgb, 0), 1);

embed_info = struct();
embed_info.embedding_domain = embedding_domain;
embed_info.alpha_scaled = alpha_scaled;
embed_info.wavelet = options.dwt.wavelet;
embed_info.subband = upper(options.dwt.subband);
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
