function ssim_index = metes_ssim(img1, img2)
    % define constant parameters
    C1 = (0.01 * 255)^2;
    C2 = (0.03 * 255)^2;
    % resize
    size_index = 7000;
    img1 = imresize(img1,[size_index size_index]);
    img2 = imresize(img2,[size_index size_index]);
    img1 = double(img1);
    img2 = double(img2);
    
    % define gaussian filter
    kernel_size = 11;
    sigma = 1.5;
    window = fspecial('gaussian', [kernel_size, kernel_size], sigma);
    
    % means
    mu1 = imfilter(img1, window, 'replicate');
    mu2 = imfilter(img2, window, 'replicate');
    
    % squared means
    mu1_sq = mu1.^2;
    mu2_sq = mu2.^2;
    mu1_mu2 = mu1 .* mu2;
    
    % variances and covariance
    sigma1_sq = imfilter(img1.^2, window, 'replicate') - mu1_sq;
    sigma2_sq = imfilter(img2.^2, window, 'replicate') - mu2_sq;
    sigma12 = imfilter(img1 .* img2, window, 'replicate') - mu1_mu2;
    
    % SSIM mapping
    ssim_map = ((2 * mu1_mu2 + C1) .* (2 * sigma12 + C2)) ./ ((mu1_sq + mu2_sq + C1) .* (sigma1_sq + sigma2_sq + C2));
    
    % mean SSIM value
    ssim_index = mean(ssim_map(:));
end
