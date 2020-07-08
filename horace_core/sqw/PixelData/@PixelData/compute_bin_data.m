function [mean_signal, mean_variance] = compute_bin_data(obj, npix)
% Compute the mean signal and variance given the number of contributing
% pixels for each bin
%
%   >> [mean_signal, mean_variance] = compute_bin_data(obj, npix)
%
% Input
% -----
% npix   The number of contributing pixels to each bin of the plot axes
%
% Output
% ------
% mean_signal     The average signal for each plot axis bin.
%                 size(mean_signal) = size(npix)
% mean_variance   The average variance for each plot axis bin.
%                 size(mean_variance) = size(npix)
%
[use_mex, n_threads] = ...
    config_store.instance().get_value('hor_config','use_mex','threads');
log_level = ...
    config_store.instance().get_value('herbert_config','log_level');

if use_mex
    try
        [mean_signal, mean_variance] = compute_bin_data_mex_(obj, npix, n_threads);
    catch ME
        use_mex = false;
        if log_level>0
            warning('SQW:mex_code_problem', ...
                    ['sqw:recompute_bin_data -- c-code problem: ' ...
                        '%s\n Trying to use Matlab'], ME.message);
        end
    end
end

if ~use_mex
    [mean_signal, mean_variance] = compute_bin_data_matlab_(obj, npix, log_level);
end
