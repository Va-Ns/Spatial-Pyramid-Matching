function [GX,GY] = gaussVN(sigma)
        
    % This function computes the gradients of a Gaussian filter for a given standard deviation (sigma).
    % It supports both isotropic and anisotropic Gaussian filters based on the input sigma.
    %
    % INPUT:
    %   sigma - A scalar or a 2-element vector specifying the standard deviation of the Gaussian filter.
    %           If sigma is a scalar, an isotropic Gaussian filter is used.
    %           If sigma is a vector, an anisotropic Gaussian filter is used.
    %
    % OUTPUT:
    %   GX - The gradient of the Gaussian filter in the x-direction.
    %   GY - The gradient of the Gaussian filter in the y-direction.
    %
    % The function performs the following steps:
    % 1. Checks if the input sigma is a scalar or a vector.
    % 2. For a scalar sigma, computes an isotropic Gaussian filter using fspecial.
    % 3. For a vector sigma, computes an anisotropic Gaussian filter using normpdf.
    % 4. Computes the gradients of the Gaussian filter using the gradient function.
    % 5. Normalizes the gradient components GX and GY.

        if all(size(sigma) == [1 1])

            % Isotropic Gaussian

            f_wid = 4 * ceil(sigma) + 1;
            G = fspecial("gaussian",f_wid,sigma);
            
            %	G = normpdf(-f_wid:f_wid,0,sigma);
            %	G = G' * G;
        
        else
           
            % Anisotropic Gaussian
            f_wid_x = 2 * ceil(sigma(1)) + 1;
            f_wid_y = 2 * ceil(sigma(2)) + 1;
            G_x = normpdf(-f_wid_x:f_wid_x,0,sigma(1));
            G_y = normpdf(-f_wid_y:f_wid_y,0,sigma(2));
            G = G_y' * G_x;

        end

        [GX,GY] = gradient(G);
        
        % Normalization of the GX and GY components
        GX = GX * 2 ./ sum(sum(abs(GX)));
        GY = GY * 2 ./ sum(sum(abs(GY)));
        
end