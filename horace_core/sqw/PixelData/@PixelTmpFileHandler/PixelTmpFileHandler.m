classdef PixelTmpFileHandler

properties (Constant, Access=private)
    TMP_DIR_BASE_NAME_ = 'sqw_pix%05d';
    TMP_FILE_BASE_NAME_ = '%09d.tmp';
    FILE_DATA_FORMAT_ = 'float32';
end

properties (Access=private)
    tmp_dir_path_ = '';  % The path to the directory in which to write the tmp files
    pix_id_ = -1;        % The ID of the PixelData instance linked to this object
end

methods

    function obj = PixelTmpFileHandler(pix_id)
        % Construct a PixelTmpFileHandler object
        %
        % Input
        % -----
        % pix_id   The ID of the PixelData instance this object is linked to.
        %          This sets the tmp directory name
        %
        obj.pix_id_ = pix_id;
        obj.tmp_dir_path_ = obj.generate_tmp_dir_path_(obj.pix_id_);
    end

    function raw_pix = load_page(obj, page_number, ncols)
        % Load a page of data from the tmp file with the given page number
        %
        % Input
        % -----
        % page_number   The number of the page to read data from
        % ncols         The number of columns in the page, used for reshaping
        %               (default = 1)
        %
        if nargin == 2
            ncols = 1;
        end

        tmp_file_path = obj.generate_tmp_pix_file_path_(page_number);
        [file_id, err_msg] = fopen(tmp_file_path, 'rb');
        if file_id < 0
            error('PIXELTMPFILEHANDLER:load_page', ...
                  'Could not open ''%s'' for reading:\n%s', tmp_file_path, ...
                  err_msg);
        end
        clean_up = onCleanup(@() fclose(file_id));

        page_shape = [ncols, Inf];
        raw_pix = do_fread(file_id, page_shape, obj.FILE_DATA_FORMAT_);
    end

    function raw_pix = load_pixels_at_indices(obj, page_number, indices, ncols)
        if nargin == 2
            ncols = 1;
        end

        NUM_BYTES_IN_FLOAT = 4;
        PIXEL_SIZE = NUM_BYTES_IN_FLOAT*ncols;  % bytes

        tmp_file_path = obj.generate_tmp_pix_file_path_(page_number);
        [file_id, err_msg] = fopen(tmp_file_path, 'rb');
        if file_id < 0
            error('PIXELTMPFILEHANDLER:load_page', ...
                  'Could not open ''%s'' for reading:\n%s', tmp_file_path, ...
                  err_msg);
        end
        clean_up = onCleanup(@() fclose(file_id));

        indices_monotonic = issorted(indices, 'strictascend');
        if ~indices_monotonic
            [indices, ~, idx_map] = unique(indices);
        end

        [read_sizes, seek_sizes] = get_read_and_seek_sizes(indices);

        raw_pix = zeros(ncols, numel(indices));

        num_pix_read = 0;
        for block_num = 1:numel(read_sizes)
            fseek(file_id, seek_sizes(block_num)*PIXEL_SIZE, 'cof');

            out_pix_start = num_pix_read + 1;
            out_pix_end = out_pix_start + read_sizes(block_num) - 1;
            read_size = [ncols, read_sizes(block_num)];
            read_pix = do_fread(file_id, read_size, obj.FILE_DATA_FORMAT_);
            raw_pix(:, out_pix_start:out_pix_end) = read_pix;

            num_pix_read = num_pix_read + read_sizes(block_num);
        end
        if ~indices_monotonic
            raw_pix = raw_pix(:, idx_map);
        end
    end

    function obj = write_page(obj, page_number, raw_pix)
        % Write the given pixel data to tmp file with the given page number
        %
        % Inputs
        % ------
        % page_number   The number of the page being written, this sets the tmp file name
        % raw_pix       The raw pixel data array to write
        %
        tmp_file_path = obj.generate_tmp_pix_file_path_(page_number);
        if ~exist(obj.tmp_dir_path_, 'dir')
            mkdir(obj.tmp_dir_path_);
        end

        file_id = fopen(tmp_file_path, 'wb');
        if file_id < 0
            error('PIXELTMPFIELHANDLER:write_page', ...
                  'Could not open file ''%s'' for writing.\n', tmp_file_path);
        end
        clean_up = onCleanup(@() fclose(file_id));

        obj.write_float_data_(file_id, raw_pix);
    end

    function copy_folder(obj, target_pix_id)
        % Copy the temporary files managed by this class instance to a new folder
        %
        % Input
        % -----
        % target_pix_id   The ID of the PixelData instance the new tmp folder
        %                 will be linked to
        %
        if ~exist(obj.tmp_dir_path_, 'dir')
            return;
        end

        new_dir_path = obj.generate_tmp_dir_path_(target_pix_id);
        [status, err_msg] = copyfile(obj.tmp_dir_path_, new_dir_path);
        if status == 0
            error('PIXELDATA:copy_folder', ...
                  'Could not copy PixelData tmp files from ''%s'' to ''%s'':\n%s', ...
                  obj.tmp_dir_path_, new_dir_path, err_msg);
        end
    end

    function delete_files(obj)
        % Delete the directory containing the tmp files
        if exist(obj.tmp_dir_path_, 'dir')
            rmdir(obj.tmp_dir_path_, 's');
        end
    end

end

methods (Access=private)

    function obj = write_float_data_(obj, file_id, pix_data)
        % Write the given data to the file corresponding to the given file ID
        % in float32
        SIZE_OF_FLOAT = 4;
        chunk_size = hor_config().mem_chunk_size/SIZE_OF_FLOAT;

        try
            for start_idx = 1:chunk_size:numel(pix_data)
                end_idx = min(start_idx + chunk_size - 1, numel(pix_data));
                fwrite(file_id, pix_data(start_idx:end_idx), obj.FILE_DATA_FORMAT_);
            end
        catch ME
            switch ME.identifier
            case 'MATLAB:badfid_mx'
                error('PIXELTMPFIELHANDLER:write_float_data_', ...
                      ['Could not write to file with ID ''%d'':\n' ...
                       'The file is not open'], file_id);
            otherwise
                tmp_file_path = fopen(file_id);
                error('PIXELTMPFIELHANDLER:write_float_data_', ...
                      'Could not write to file ''%s'':\n%s', ...
                      tmp_file_path, ferror(file_id));
            end
        end
    end

    function tmp_file_path = generate_tmp_pix_file_path_(obj, page_number)
        % Generate the file path to a tmp file with the given page number
        file_name = sprintf(obj.TMP_FILE_BASE_NAME_, page_number);
        tmp_file_path = fullfile(obj.tmp_dir_path_, file_name);
    end

    function tmp_dir_path = generate_tmp_dir_path_(obj, pix_id)
        % Generate the file path to the tmp directory for this object instance
        tmp_dir_name = sprintf(obj.TMP_DIR_BASE_NAME_, pix_id);
        tmp_dir_path = fullfile(tempdir(), tmp_dir_name);
    end

end

end
