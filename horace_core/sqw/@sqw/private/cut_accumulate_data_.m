function [s, e, npix, pix_out, urange_pix, pix_comb_info] = ...
    cut_accumulate_data_(obj, proj, keep_pix, log_level, return_cut)
%%CUT_ACCUMULATE_DATA Accumulate image and pixel data for a cut
%
% Input:
% ------
% proj       A 'projection' object, defining the projection of the cut.
% keep_pix   A boolean defining whether pixel data should be retained. If this
%            is false return variable 'pix_out' will be empty.
% log_level  The verbosity of the log messages. The values correspond to those
%            used in 'hor_config', see `help hor_config/log_level`.
%
% Output:
% -------
% s                The image signal data.
% e                The variance in the image signal data.
% npix             Array defining how many pixels are contained in each image
%                  bin. size(npix) == size(s)
% pix_out          A PixelData object containing pixels that contribute to the
%                  cut.
% urange_pix       The range of u1, u2, u3, and dE in the contributing pixels.
%                  size(urange_pix) == [2, 4].
%
% CALLED BY cut_single
%

% Pre-allocate image data
nbin_as_size = get_nbin_as_size(proj.target_nbin);
s = zeros(nbin_as_size);
e = zeros(nbin_as_size);
npix = zeros(nbin_as_size);
urange_step_pix = [Inf(1, 4); -Inf(1, 4)];

[bin_starts, bin_ends] = proj.get_nbin_range(obj.data.npix);
if isempty(bin_starts)
    % No pixels in range, we can return early
    pix_out = PixelData();
    pix_comb_info = [];
    urange_pix = urange_step_pix;
    return
end

% Get the cumulative sum of pixel bin sizes and work out how many
% iterations we're going to need
cum_bin_sizes = cumsum(bin_ends - bin_starts);
block_size = obj.data.pix.base_page_size;
max_num_iters = ceil(cum_bin_sizes(end)/block_size);

% If we only have one iteration to cut then we must be able to fit it in memory.
% Set this to stop us using tmp files
% TODO: replace "return_cut" with something more descriptive e.g. use_tmp_files
return_cut = return_cut || max_num_iters == 1;

if keep_pix
    if return_cut
        % Pre-allocate cell arrays to hold PixelData chunks
        pix_retained = cell(1, max_num_iters);
        pix_ix_retained = cell(1, max_num_iters);
    else
        num_bins = numel(s);
        pix_comb_info = init_pix_combine_info(max_num_iters, num_bins);
    end
end

block_end_idx = 0;
for iter = 1:max_num_iters
    block_start_idx = block_end_idx + 1;
    if block_start_idx > numel(cum_bin_sizes)
        % If start index has reached end of bin sizes, we've reached the end
        break
    end

    % Work out how many full bins we can load given we only want to load
    % block_size number of pixels
    next_idx_end = find(cum_bin_sizes(block_start_idx:end) > block_size, 1);
    block_end_idx = block_end_idx + next_idx_end - 1;
    if isempty(block_end_idx)
        % There are less than block_size no. of pixels in the remaining bins
        block_end_idx = numel(cum_bin_sizes);
    end

    if block_start_idx > block_end_idx
        % Occurs where bin size greater than block size, just read in the
        % whole bin
        block_end_idx = block_start_idx;
        pix_assigned = bin_ends(block_end_idx) - bin_starts(block_start_idx);
    else
        pix_assigned = block_size;
    end

    % Subtract the number of pixels we've assigned from our cumulative sum
    cum_bin_sizes = cum_bin_sizes - pix_assigned;

    % Get pixels that will likely contribute to the cut
    candidate_pix = obj.data.pix.get_pix_in_ranges( ...
        bin_starts(block_start_idx:block_end_idx), ...
        bin_ends(block_start_idx:block_end_idx) ...
    );

    if log_level >= 0
        fprintf(['Step %3d of maximum %3d; Have read data for %d pixels -- ' ...
                    'now processing data...'], iter, max_num_iters, ...
                candidate_pix.num_pixels);
    end

    [ ...
        s, ...
        e, ...
        npix, ...
        urange_step_pix, ...
        del_npix_retain, ...
        ok, ...
        ix ...
    ] = cut_data_from_file_job.accumulate_cut( ...
            s, ...
            e, ...
            npix, ...
            urange_step_pix, ...
            keep_pix, ...
            candidate_pix, ...
            proj, ...
            proj.target_pax ...
    );

    if log_level >= 0
        fprintf(' ----->  retained  %d pixels\n', del_npix_retain);
    end

    if keep_pix
        if return_cut
            % Retain only the pixels that contributed to the cut
            pix_retained{iter} = candidate_pix.get_pixels(ok);
            pix_ix_retained{iter} = ix;
        else
            % Generate tmp files and get a pix_combine_info object to manage
            % the files - this object then recombines the files once it is
            % passed to 'put_sqw'.
            buf_size = obj.data.pix.page_size;
            pix_comb_info = cut_data_from_file_job.accumulate_pix_to_file( ...
                pix_comb_info, false, candidate_pix, ok, ix, npix, buf_size, ...
                del_npix_retain ...
            );
        end
    end

end  % loop over pixel blocks

if keep_pix
    if return_cut
        % Pixels stored in-memory in PixelData object
        pix_comb_info = [];
        pix_out = sort_pix(pix_retained, pix_ix_retained, npix);
    else
        % Pixels are stored in tmp files managed by pix_combine_info object
        pix_out = PixelData();

        buf_size = obj.data.pix.page_size;
        ok = [];
        ix = [];
        candidate_pix = [];
        pix_comb_info = cut_data_from_file_job.accumulate_pix_to_file( ...
            pix_comb_info, true, candidate_pix, ok, ix, npix, buf_size, 0 ...
        );
    end
else
    pix_out = PixelData();
    pix_comb_info = [];
end

% Convert range from steps to actual range with respect to output uoffset
urange_offset = repmat(proj.urange_offset, [2, 1]);
urange_pix = urange_step_pix.*repmat(proj.usteps, [2, 1]) + urange_offset;

[s, e] = average_signal(s, e, npix);

end  % function


% -----------------------------------------------------------------------------
function nbin_as_size = get_nbin_as_size(nbin)
    % Get the given nbin array as a size

    % Note: Matlab silliness when one dimensional: MUST add an outer dimension
    % of unity. For 2D and higher, outer dimensions can always be assumed.
    % The problem with 1D is that e.g. zeros([5]) is not the same as
    % zeros([5,1]) whereas zeros([5,3]) is the same as zeros([5,3,1]).
    if isempty(nbin)
        nbin_as_size = [1, 1];
    elseif length(nbin) == 1
        nbin_as_size = [nbin, 1];
    else
        nbin_as_size = nbin;
    end
end


function [s, e] = average_signal(s, e, npix)
    % Convert summed signal & error into averages
    s = s./npix;
    e = e./(npix.^2);
    no_pix = (npix == 0);  % true where no pixels contribute to given bin

    % By convention, signal and error are zero if no pixels contribute to bin
    s(no_pix) = 0;
    e(no_pix) = 0;
end


function pci = init_pix_combine_info(nfiles, nbins)
    % Define temp files to store in working directory
    wk_dir = get(parallel_config, 'working_directory');
    tmp_file_names = cell(1, nfiles);
    gen_dir_name = @(x) fullfile( ...
        wk_dir, ['horace_subcut_', rand_digit_string(16), '.tmp'] ...
    );
    tmp_file_names = cellfun(gen_dir_name, tmp_file_names, 'UniformOutput', false);
    pci = pix_combine_info(tmp_file_names, nbins);
end


function str = rand_digit_string(n)
    % Create string of n random digits
    digits = max(0, min(9, floor(10*rand(1, n))));
    str = blanks(n);
    for i=1:n
        str(i) = int2str(digits(i));
    end
end
