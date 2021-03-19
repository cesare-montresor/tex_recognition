function gaussFilter = gauss2D(mu,sigma,w,h)

    % Initializing value of x-axis and y-axis 
    [bgx, bgy] = meshgrid(linspace(-h/2,h/2,h), linspace(-w/2,w/2,w)); 
    dst = sqrt(bgx.^2 + bgy.^2);
    % Calculating Gaussian array 
    gaussFilter = exp(-( (dst-mu).^2 / ( 2.0 * sigma.^2 ) ) );
    return
end