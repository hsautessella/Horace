classdef combine_sqw_job_tester < combine_sqw_pix_job
    % the class helper for combine_sqw_pix_job class, providing fake
    % read_pix method
    
    
    properties
        
    end
    methods
    end
    
    methods(Static)
        function [pix_buffer,pos_pixstart] = read_pixels(fid,pos_pixstart,npix2read)
            pix_buffer = ones(9,npix2read)*pos_pixstart;
            if isnumeric(fid)
                pix_buffer(6,:) = fid;
            end
            pos_pixstart = pos_pixstart+npix2read;
        end
    end
end
