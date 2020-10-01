classdef test_PixelData_operations < TestCase

properties
    NUM_BYTES_IN_VALUE = 8;
    NUM_COLS_IN_PIX_BLOCK = 9;
    SIGNAL_IDX = 8;
    VARIANCE_IDX = 9;

    FLOAT_TOLERANCE = 4.75e-4;

    this_dir = fileparts(mfilename('fullpath'));
    test_sqw_file_path = '../test_sqw_file/sqw_1d_1.sqw';
    test_sqw_2d_file_path = '../test_sqw_file/sqw_2d_1.sqw';
    ref_npix_data = [];
    ref_s_data = [];
    ref_e_data = [];
    ref_raw_pix_data = [];

    pix_in_memory_base;
    pix_in_memory;
    pix_with_pages_base;
    pix_with_pages;
    page_size;

    pix_with_pages_2d;
    page_size_2d;
    ref_npix_data_2d;
    ref_s_data_2d;
    ref_e_data_2d;

    config;
    old_config;
    old_warn_state;
end

methods

    function obj = test_PixelData_operations(~)
        obj = obj@TestCase('test_PixelData_operations');

        addpath(fullfile(obj.this_dir, 'utils'));

        % Swallow any warnings for when pixel page size set too small
        obj.old_warn_state = warning('OFF', 'PIXELDATA:validate_mem_alloc');

        % Load a 1D SQW file
        sqw_test_obj = sqw(obj.test_sqw_file_path);
        obj.ref_npix_data = sqw_test_obj.data.npix;
        obj.ref_s_data = sqw_test_obj.data.s;
        obj.ref_e_data = sqw_test_obj.data.e;
        obj.ref_raw_pix_data = sqw_test_obj.data.pix.data;

        file_info = dir(obj.test_sqw_file_path);
        obj.page_size = file_info.bytes/6;

        obj.pix_in_memory_base = sqw_test_obj.data.pix;
        obj.pix_with_pages_base = PixelData(obj.test_sqw_file_path, obj.page_size);

        % Load 2D SQW file
        sqw_2d_test_object = sqw(obj.test_sqw_2d_file_path);
        obj.ref_npix_data_2d = sqw_2d_test_object.data.npix;
        obj.ref_s_data_2d = sqw_2d_test_object.data.s;
        obj.ref_e_data_2d = sqw_2d_test_object.data.e;

        file_info = dir(obj.test_sqw_2d_file_path);
        obj.page_size_2d = file_info.bytes/6;

        obj.pix_with_pages_2d = PixelData(obj.test_sqw_2d_file_path, ...
                                          obj.page_size_2d);
    end

    function delete(obj)
        rmpath(fullfile(obj.this_dir, 'utils'));
        warning(obj.old_warn_state);
    end

    function setUp(obj)
        obj.pix_in_memory = copy(obj.pix_in_memory_base);
        obj.pix_with_pages = copy(obj.pix_with_pages_base);
    end

    function test_compute_bin_data_correct_output_in_memory_mex_1_thread(obj)
        cleanup = set_config_option(hor_config(), {'use_mex', 'threads'}, ...
                                    {true, 1});

        [s, e] = obj.pix_in_memory.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
        assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
    end

    function test_compute_bin_data_correct_output_in_memory_mex_4_threads(obj)
        cleanup = set_config_option(hor_config(), {'use_mex', 'threads'}, ...
                                    {true, 4});
        [s, e] = obj.pix_in_memory.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
        assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
    end

    function test_compute_bin_data_correct_output_all_data_in_memory_mex_off(obj)
        cleanup = set_config_option(hor_config(), 'use_mex', false);

        [s, e] = obj.pix_in_memory.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
        assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
    end

    function test_compute_bin_data_correct_output_file_backed_mex_1_thread(obj)
        cleanup = set_config_option(hor_config(), {'use_mex', 'threads'}, ...
                                    {true, 1});

        [s, e] = obj.pix_with_pages.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
        assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
    end

    function test_compute_bin_data_correct_output_5_pages_mex_1_thread(obj)
        cleanup = set_config_option(hor_config(), {'use_mex', 'threads'}, ...
                                    {true, 1});

        file_info = dir(obj.test_sqw_file_path);
        pg_size = file_info.bytes/5;
        pix = PixelData(obj.test_sqw_file_path, pg_size);
        [s, e] = pix.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
        assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
    end

    function test_compute_bin_data_correct_output_file_backed_mex_4_threads(obj)
        cleanup = set_config_option(hor_config(), {'use_mex', 'threads'}, ...
                                    {true, 4});

        [s, e] = obj.pix_with_pages.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
        assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
    end

    function test_compute_bin_data_file_backed_2d_data_mex_4_threads(obj)
        cleanup = set_config_option(hor_config(), {'use_mex', 'threads'}, ...
                                    {true, 4});

        [s, e] = obj.pix_with_pages_2d.compute_bin_data(obj.ref_npix_data_2d);

        % Scale the signal and error to account for rounding errors
        max_s = max(s, [], 'all');
        scaled_s = s/max_s;
        scaled_ref_s = obj.ref_s_data_2d/max_s;

        max_e = max(e, [], 'all');
        scaled_e = e/max_e;
        scaled_ref_e = obj.ref_e_data_2d/max_e;

        assertEqual(scaled_s, scaled_ref_s, '', obj.FLOAT_TOLERANCE);
        assertEqual(scaled_e, scaled_ref_e, '', obj.FLOAT_TOLERANCE);

    end

    function test_compute_bin_data_correct_output_file_backed_mex_off(obj)
        cleanup = set_config_option(hor_config(), 'use_mex', false);

        [s, e] = obj.pix_with_pages.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', obj.FLOAT_TOLERANCE);
        assertEqual(e, obj.ref_e_data, '', obj.FLOAT_TOLERANCE);
    end

    function test_do_unary_op_returns_correct_output_with_cosine_gt_1_page(obj)
        data = rand(9, 50);
        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

        pix = pix.do_unary_op(@cos_single);

        % Loop back through and validate values
        pix.move_to_first_page();
        iter = 0;
        while true
            start_idx = (iter*npix_in_page) + 1;
            end_idx = min(start_idx + npix_in_page - 1, pix.num_pixels);

            original_signal = data(obj.SIGNAL_IDX, start_idx:end_idx);
            original_variance = data(obj.VARIANCE_IDX, start_idx:end_idx);

            expected_data = data;
            % Use the formulas used in sqw.cos to get the expected sig/var data
            expected_data(obj.SIGNAL_IDX, start_idx:end_idx) = ...
                    cos(original_signal);
            expected_data(obj.VARIANCE_IDX, start_idx:end_idx) = ...
                    abs(1 - pix.signal.^2).*original_variance;

            assertEqual(pix.data, expected_data(:, start_idx:end_idx), '', ...
                        obj.FLOAT_TOLERANCE);

            if pix.has_more()
                pix = pix.advance();
                iter = iter + 1;
            else
                break;
            end
        end
    end

    function test_do_unary_op_with_nargout_1_doesnt_affect_called_instance(obj)
        data = rand(9, 10);
        pix = PixelData(data);
        sin_pix = pix.do_unary_op(@sin);
        assertEqual(pix.data, data);
    end

    function test_paged_data_returns_same_unary_op_result_as_all_in_memory(obj)
        % the unary operation and the range the data it acts on should take
        unary_ops = {
            @acos, [0, 1], ...
            @acosh, [1, 3], ...
            @acot, [0, 1], ...
            @acoth, [10, 15], ...
            @acsc, [1, 3], ...
            @acsch, [1, 3], ...
            @asec, [1.5, 3], ...
            @asech, [0, 1], ...
            @asin, [0, 1], ...
            @asinh, [1, 3], ...
            @atan, [0, 1], ...
            @atanh, [0, 0.5], ...
            @cos, [0, 1], ...
            @cosh, [0, 1], ...
            @cot, [0, 1], ...
            @coth, [1.5, 3], ...
            @csc, [0.5, 2.5], ...
            @csch, [1, 3], ...
            @exp, [0, 1], ...
            @log, [1, 3], ...
            @log10, [1, 3], ...
            @sec, [2, 4], ...
            @sech, [0, 1.4], ...
            @sin, [0, 3], ...
            @sinh, [0, 3], ...
            @sqrt, [0, 3], ...
            @tan, [0, 1], ...
            @tanh [0, 3], ...
        };

        % For each unary operator, perform the operation on some file-backed
        % data and compare the result to the same operation used on the same
        % data all held in memory
        num_pix = 7;
        npix_in_page = 3;
        for i = 1:numel(unary_ops)/2
            unary_op = unary_ops{2*i - 1};
            data_range = unary_ops{2*i};

            data = obj.get_random_data_in_range(obj.NUM_COLS_IN_PIX_BLOCK, ...
                                                num_pix, data_range);
            pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
            pix.do_unary_op(unary_op);

            file_backed_data = concatenate_pixel_pages(pix);

            pix_in_mem = PixelData(data);
            pix_in_mem = pix_in_mem.do_unary_op(unary_op);
            in_memory_data = pix_in_mem.data;

            assertEqual( ...
                file_backed_data, in_memory_data, ...
                sprintf(['In-memory and file-backed data do not match after ' ...
                         'operation: ''%s''.'], char(unary_op)), ...
                obj.FLOAT_TOLERANCE);
        end
    end

    function test_mask_does_nothing_if_mask_array_eq_ones_when_pix_in_memory(~)
        data = rand(9, 11);
        pix = PixelData(data);
        mask_array = ones(1, pix.num_pixels);
        pix_out = pix.mask(mask_array);
        assertEqual(pix_out.data, data);
    end

    function test_mask_returns_empty_PixelData_if_mask_array_all_zeros(~)
        data = rand(9, 11);
        pix = PixelData(data);
        mask_array = zeros(1, pix.num_pixels);
        pix_out = pix.mask(mask_array);
        assertTrue(isa(pix_out, 'PixelData'));
        assertTrue(isempty(pix_out));
    end

    function test_mask_raises_if_mask_array_len_neq_to_pg_size_or_num_pixels(obj)
        data = rand(9, 30);
        npix_in_page = 10;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);
        mask_array = zeros(5);
        f = @() pix.mask(mask_array);
        assertExceptionThrown(f, 'PIXELDATA:mask');
    end

    function test_mask_removes_in_memory_pix_if_len_mask_array_eq_num_pixels(~)
        data = rand(9, 11);
        pix = PixelData(data);
        mask_array = ones(1, pix.num_pixels);
        pix_to_remove = [3, 6, 7];
        mask_array(pix_to_remove) = 0;

        pix = pix.mask(mask_array);

        assertEqual(pix.num_pixels, size(data, 2) - numel(pix_to_remove));
        expected_data = data;
        expected_data(:, pix_to_remove) = [];
        assertEqual(pix.data, expected_data);
    end

    function test_mask_throws_PIXELDATA_if_called_with_no_output_args(~)
        pix = PixelData(5);
        f = @() pix.mask(zeros(1, pix.num_pixels), 'logical');
        assertExceptionThrown(f, 'PIXELDATA:mask');
    end

    function test_mask_deletes_pixels_when_given_npix_argument_pix_in_pages(obj)
        data = rand(9, 20);
        npix_in_page = 11;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

        mask_array = [0, 1, 1, 0, 1, 0];
        npix = [4, 5, 1, 2, 3, 5];

        pix = pix.mask(mask_array, npix);

        full_mask_array = repelem(mask_array, npix);
        expected_data = data(:, logical(full_mask_array));

        actual_data = concatenate_pixel_pages(pix);
        assertEqual(actual_data, expected_data);
    end

    function test_mask_deletes_pix_with_npix_argument_all_pages_full(obj)
        data = rand(9, 20);
        npix_in_page = 10;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

        mask_array = [0, 1, 1, 0, 1, 0];
        npix = [4, 5, 1, 2, 3, 5];

        pix = pix.mask(mask_array, npix);

        full_mask_array = repelem(mask_array, npix);
        expected_data = data(:, logical(full_mask_array));

        actual_data = concatenate_pixel_pages(pix);
        assertEqual(actual_data, expected_data);
    end

    function test_mask_deletes_pixels_when_given_npix_argument_pix_in_mem(obj)
        data = rand(9, 20);
        pix = PixelData(data);

        mask_array = [0, 1, 1, 0, 1, 0];
        npix = [4, 5, 1, 2, 3, 5];

        pix = pix.mask(mask_array, npix);

        full_mask_array = repelem(mask_array, npix);
        expected_data = data(:, logical(full_mask_array));

        actual_data = concatenate_pixel_pages(pix);
        assertEqual(actual_data, expected_data);
    end

    function test_PIXELDATA_thrown_if_sum_of_npix_ne_to_num_pixels(~)
        pix = PixelData(5);
        npix = [1, 2];
        f = @() pix.mask([0, 1], npix);
        assertExceptionThrown(f, 'PIXELDATA:mask');
    end

    function test_error_if_passing_mask_npix_and_num_pix_len_mask_array(~)

        function out = f()
            num_pix = 10;
            pix = PixelData(rand(9, num_pix));
            mask_array = randi([0, 1], [1, num_pix]);
            npix = rand(1, 4);
            out = pix.mask(mask_array, npix);
        end

        assertExceptionThrown(@() f(), 'PIXELDATA:mask');
    end

    function test_not_enough_args_error_if_calling_mask_with_no_args(~)

        function pix = f()
            pix = PixelData(rand(9, 10));
            pix = pix.mask();
        end

        assertExceptionThrown(@() f(), 'MATLAB:minrhs');
    end

    function test_binary_op_plus_with_scalar_returns_correct_data_1_page(obj)
        pix = obj.pix_in_memory;
        operand = 3;

        pix_result = pix.do_binary_op(operand, @plus_single);

        assertEqual(pix_result.signal, operand + pix.signal);
        assertEqual(pix_result.data([1:7, 9], :), pix.data([1:7, 9], :));
    end

    function test_binary_op_plus_with_scalar_returns_correct_data_gt_1_page(obj)
        pix = obj.pix_with_pages;
        operand = 3;

        pix_result = pix.do_binary_op(operand, @plus_single);
        new_pix_data = concatenate_pixel_pages(pix_result);

        assertEqual(new_pix_data(8, :), operand + obj.pix_in_memory.signal, ...
                    '', obj.FLOAT_TOLERANCE);
        assertEqual(new_pix_data([1:7, 9], :), ...
                    obj.ref_raw_pix_data([1:7, 9], :), ...
                    '', obj.FLOAT_TOLERANCE);
    end

    function test_binary_minus_with_scalar_returns_correct_data_1_page(obj)
        pix = obj.pix_in_memory;
        operand = 3;

        pix_result = pix.do_binary_op(operand, @minus_single, 'flip', true);

        assertEqual(pix_result.signal, operand - pix.signal);
        assertEqual(pix_result.data([1:7, 9], :), pix.data([1:7, 9], :));
    end

    function test_binary_minus_with_scalar_returns_correct_data_gt_1_page(obj)
        pix = obj.pix_with_pages;
        operand = 3;

        pix_result = pix.do_binary_op(operand, @minus_single);
        new_pix_data = concatenate_pixel_pages(pix_result);

        assertEqual(new_pix_data(8, :), obj.pix_in_memory.signal - operand, ...
                    '', obj.FLOAT_TOLERANCE);
        assertEqual(new_pix_data([1:7, 9], :), ...
                    obj.ref_raw_pix_data([1:7, 9], :), ...
                    '', obj.FLOAT_TOLERANCE);
    end

    function test_binary_mtimes_with_scalar_returns_correct_data_1_page(obj)
        pix = obj.pix_in_memory;
        operand = 1.5;

        pix_result = pix.do_binary_op(operand, @mtimes_single, 'flip', true);

        assertEqual(pix_result.signal, operand*pix.signal);
        assertEqual(pix_result.variance, (operand.^2).*pix.variance);
        assertEqual(pix_result.data(1:7, :), pix.data(1:7, :));
    end

    function test_binary_mtimes_with_scalar_returns_correct_data_gt_1_page(obj)
        pix = obj.pix_with_pages;
        operand = 1.5;

        pix_result = pix.do_binary_op(operand, @mtimes_single);
        new_pix_data = concatenate_pixel_pages(pix_result);

        assertElementsAlmostEqual(new_pix_data(8, :), ...
                                  obj.pix_in_memory.signal*operand, ...
                                  'relative', obj.FLOAT_TOLERANCE);
        assertElementsAlmostEqual(new_pix_data(9, :), ...
                                  (operand.^2).*obj.pix_in_memory.variance, ...
                                  'relative', obj.FLOAT_TOLERANCE);
        assertEqual(new_pix_data(1:7, :), obj.ref_raw_pix_data(1:7, :), ...
                    '', obj.FLOAT_TOLERANCE);
    end

    function test_binary_mrdivide_with_scalar_returns_correct_data_1_page(obj)
        pix = obj.pix_in_memory;
        operand = 1.5;

        pix_result = pix.do_binary_op(operand, @mrdivide_single, 'flip', true);

        assertEqual(pix_result.signal, operand./pix.signal);
        expected_var = pix.variance.*((pix_result.signal./pix.signal).^2);
        assertEqual(pix_result.variance, expected_var);
        assertEqual(pix_result.data(1:7, :), pix.data(1:7, :));
    end

    function test_binary_mrdivide_with_scalar_returns_correct_data_gt_1_page(obj)
        pix = obj.pix_with_pages;
        operand = 1.5;

        pix_result = pix.do_binary_op(operand, @mrdivide_single);
        new_pix_data = concatenate_pixel_pages(pix_result);

        assertElementsAlmostEqual(new_pix_data(8, :), ...
                                  obj.pix_in_memory.signal./operand, ...
                                  'relative', obj.FLOAT_TOLERANCE);

        original_variance = obj.ref_raw_pix_data(9, :);
        expected_var = original_variance/(operand^2);
        expected_var(isnan(expected_var)) = 0;
        assertElementsAlmostEqual(new_pix_data(9, :), expected_var, ...
                                  'relative', obj.FLOAT_TOLERANCE);

        assertEqual(new_pix_data(1:7, :), obj.ref_raw_pix_data(1:7, :), ...
                    '', obj.FLOAT_TOLERANCE);
    end

    function test_binary_op_with_double_array_with_size_eq_to_num_pixels(obj)
        pix = obj.pix_with_pages;
        operand = ones(1, pix.num_pixels);

        pix_result = pix.do_binary_op(operand, @minus_single, 'flip', true);
        full_pix_array = concatenate_pixel_pages(pix_result);

        expected_signal = 1 - obj.pix_in_memory.signal;
        assertElementsAlmostEqual(full_pix_array(8, :), expected_signal, ...
                                  'relative', obj.FLOAT_TOLERANCE);
        assertElementsAlmostEqual(full_pix_array([1:7, 9], :), ...
                                  obj.ref_raw_pix_data([1:7, 9], :), ...
                                  'relative', obj.FLOAT_TOLERANCE);
    end

    function test_binary_op_error_adding_double_with_length_neq_num_pixels(obj)
        pix = obj.pix_with_pages;
        operand = ones(1, pix.num_pixels - 1);

        f = @() pix.do_binary_op(operand, @plus_single);
        assertExceptionThrown(f, 'PIXELDATA:do_binary_op');
    end

    function test_error_binary_op_two_PixelData_with_different_num_pixels(~)
        pix1 = PixelData(rand(9, 10));
        pix2 = PixelData(rand(9, 11));
        f = @() pix1.do_binary_op(pix2, @plus_single);
        assertExceptionThrown(f, 'PIXELDATA:do_binary_op');
    end

    function test_binary_op_minus_two_in_memory_PixelData_objects(~)
        data1 = rand(9, 10);
        pix1 = PixelData(data1);
        data2 = rand(9, 10);
        pix2 = PixelData(data2);

        pix_diff = pix1.do_binary_op(pix2, @minus_single);

        expected_diff = data1;
        expected_diff(8, :) = pix1.signal - pix2.signal;
        expected_diff(9, :) = pix1.variance + pix2.variance;

        assertElementsAlmostEqual(pix_diff.data, expected_diff);
    end

    function test_binary_op_minus_two_PixelData_objects_with_gt_1_pages(obj)
        pix1 = obj.pix_with_pages;
        pix2 = copy(obj.pix_with_pages);
        % make sure we can deal with case where operand not on first page
        pix2.advance();

        pix_diff = pix1.do_binary_op(pix2, @minus_single);
        full_pix_diff = concatenate_pixel_pages(pix_diff);

        expected_diff = obj.ref_raw_pix_data;
        expected_diff(8, :) = 0;
        expected_diff(9, :) = 2*obj.ref_raw_pix_data(9, :);
        assertEqual(full_pix_diff, expected_diff);
    end

    function test_binary_minus_2_PixelData_objects_1_in_mem_1_with_pages(obj)
        pix1 = obj.pix_with_pages;
        pix2 = obj.pix_in_memory;

        pix_diff = pix1.do_binary_op(pix2, @minus_single);
        full_pix_diff = concatenate_pixel_pages(pix_diff);

        expected_diff = obj.ref_raw_pix_data;
        expected_diff(8, :) = 0;
        expected_diff(9, :) = 2*obj.ref_raw_pix_data(9, :);
        assertEqual(full_pix_diff, expected_diff);
    end

    function test_binary_plus_with_signal_array_and_npix_multiple_pages(obj)
        data = rand(9, 10);
        npix_in_page = 3;
        pix = obj.get_pix_with_fake_faccess(data, npix_in_page);

        npix = [1, 3, 0; 1, 1, 2; 0, 1, 1];
        sig_array = npix*rand(3);

        pix.do_binary_op(sig_array, @plus_single, 'npix', npix);
        new_pix_data = concatenate_pixel_pages(pix);

        expected_pix = data;
        start_idx = 1;
        for i = 1:numel(npix)
            end_idx = start_idx + npix(i);
            expected_pix(8, start_idx:end_idx - 1) = ...
                    expected_pix(8, start_idx:end_idx - 1) + sig_array(i);
            start_idx = end_idx;
        end

        assertEqual(new_pix_data, expected_pix, '', obj.FLOAT_TOLERANCE);
    end

    function test_binary_plus_with_signal_array_and_npix_1_page(~)
        data = rand(9, 10);
        pix = PixelData(data);

        npix = [1, 3, 0; 1, 1, 2; 0, 1, 1];
        sig_array = npix*rand(3);

        new_pix = pix.do_binary_op(sig_array, @plus_single, 'npix', npix);

        expected_pix = data;
        start_idx = 1;
        for i = 1:numel(npix)
            end_idx = start_idx + npix(i);
            expected_pix(8, start_idx:end_idx - 1) = ...
                    expected_pix(8, start_idx:end_idx - 1) + sig_array(i);
            start_idx = end_idx;
        end

        assertEqual(new_pix.data, expected_pix);
    end

    function test_PIXELDATA_error_on_binary_op_where_npix_ne_num_pixels(obj)
        num_pixels = 11;
        pix = PixelData(num_pixels);
        npix = [3, 4, 3];
        sig = [0.5, 0.6, 0.7];

        f = @() pix.do_binary_op(sig, @plus_single, 'npix', npix);
        assertExceptionThrown(f, 'PIXELDATA:binary_op_double_');
    end

    function test_PIXELDATA_error_on_binary_op_with_dnd_of_wrong_size(obj)
        dnd_obj = d1d(obj.test_sqw_file_path);
        pix = PixelData(zeros(9, 2));
        f = @() pix.do_binary_op(dnd_obj, @plus_single);
        assertExceptionThrown(f, 'PIXELDATA:do_binary_op');
    end

    function test_binary_op_with_1d_dnd_returns_correct_pix_with_single_page(obj)
        dnd_obj = d1d(obj.test_sqw_file_path);
        pix = PixelData(ones(9, sum(dnd_obj.npix)));

        new_pix = pix.do_binary_op(dnd_obj, @plus_single, 'flip', false, ...
                                   'npix', dnd_obj.npix);

        expected_signal = zeros(1, sum(dnd_obj.npix));
        expected_variance = zeros(1, sum(dnd_obj.npix));
        pix_processed = 0;
        for i = 1:numel(dnd_obj.s)
            npix_val = dnd_obj.npix(i);
            start_idx = pix_processed + 1;
            end_idx = pix_processed + npix_val;
            expected_signal(start_idx:end_idx) = ...
                pix.signal(start_idx:end_idx) + dnd_obj.s(i);
            expected_variance(start_idx:end_idx) = ...
                pix.variance(start_idx:end_idx) + dnd_obj.e(i);
            pix_processed = pix_processed + npix_val;
        end
        assertEqual(new_pix.signal, expected_signal);
    end

    function test_binary_op_with_sigvar_returns_correct_pix_with_single_page(obj)
        dnd_obj = d1d(obj.test_sqw_file_path);
        svar = sigvar(dnd_obj.s, dnd_obj.e);

        pix = PixelData(ones(9, sum(dnd_obj.npix)));

        new_pix = pix.do_binary_op(svar, @plus_single, 'flip', false, ...
                                   'npix', dnd_obj.npix);

        expected_signal = zeros(1, sum(dnd_obj.npix));
        expected_variance = zeros(1, sum(dnd_obj.npix));
        pix_processed = 0;
        for i = 1:numel(svar.s)
            npix_val = dnd_obj.npix(i);
            start_idx = pix_processed + 1;
            end_idx = pix_processed + npix_val;
            expected_signal(start_idx:end_idx) = ...
                pix.signal(start_idx:end_idx) + svar.s(i);
            expected_variance(start_idx:end_idx) = ...
                pix.variance(start_idx:end_idx) + svar.e(i);
            pix_processed = pix_processed + npix_val;
        end
        assertEqual(new_pix.signal, expected_signal);
        assertEqual(new_pix.variance, expected_variance);
    end

    function test_binary_op_with_1d_dnd_returns_correct_pix_with_gt_1_page(obj)
        dnd_obj = d1d(obj.test_sqw_file_path);
        npix = dnd_obj.npix;

        pix_per_page = floor(sum(npix)/6);
        mem_alloc = pix_per_page*PixelData.DATA_POINT_SIZE*PixelData.DEFAULT_NUM_PIX_FIELDS;
        pix = PixelData(obj.test_sqw_file_path, mem_alloc);

        new_pix = pix.do_binary_op(dnd_obj, @plus_single, 'flip', false, ...
                                   'npix', npix);

        original_pix_data = concatenate_pixel_pages(pix);
        new_pix_data = concatenate_pixel_pages(new_pix);

        expected_pix = original_pix_data;
        expected_pix(8, :) = expected_pix(8, :) + repelem(dnd_obj.s(:), npix(:))';
        expected_pix(9, :) = expected_pix(9, :) + repelem(dnd_obj.e(:), npix(:))';
        assertElementsAlmostEqual(new_pix_data, expected_pix, 'relative', ...
                                  obj.FLOAT_TOLERANCE);
    end

    function test_binary_op_with_sigvar_returns_correct_pix_with_gt_1_page(obj)
        dnd_obj = d1d(obj.test_sqw_file_path);
        npix = dnd_obj.npix;
        svar = sigvar(dnd_obj.s, dnd_obj.e);

        pix_per_page = floor(sum(npix)/6);
        mem_alloc = pix_per_page*PixelData.DATA_POINT_SIZE*PixelData.DEFAULT_NUM_PIX_FIELDS;
        pix = PixelData(obj.test_sqw_file_path, mem_alloc);

        new_pix = pix.do_binary_op(svar, @plus_single, 'flip', false, ...
                                   'npix', npix);

        original_pix_data = concatenate_pixel_pages(pix);
        new_pix_data = concatenate_pixel_pages(new_pix);

        expected_pix = original_pix_data;
        expected_pix(8, :) = expected_pix(8, :) + repelem(dnd_obj.s(:), npix(:))';
        expected_pix(9, :) = expected_pix(9, :) + repelem(dnd_obj.e(:), npix(:))';
        assertElementsAlmostEqual(new_pix_data, expected_pix, 'relative', ...
                                  obj.FLOAT_TOLERANCE);
    end

    function test_PIXELDATA_error_in_binary_op_sigvar_if_sum_npix_ne_num_pix(obj)
        dnd_obj = d1d(obj.test_sqw_file_path);
        svar = sigvar(dnd_obj.s, dnd_obj.e);

        pix = PixelData(ones(9, sum(dnd_obj.npix) + 1));

        f = @() pix.do_binary_op(svar, @plus_single, 'flip', false, ...
                                 'npix', dnd_obj.npix);
        assertExceptionThrown(f, 'PIXELDATA:binary_op_sigvar_');
    end

    function test_binary_op_with_2Dsigvar_returns_correct_pix_with_gt_1_page(obj)
        dnd_obj = d2d(obj.test_sqw_2d_file_path);
        npix = dnd_obj.npix;
        svar = sigvar(dnd_obj.s, dnd_obj.e);

        pix_per_page = floor(sum(npix(:)/6));
        mem_alloc = pix_per_page*PixelData.DATA_POINT_SIZE*PixelData.DEFAULT_NUM_PIX_FIELDS;
        pix = PixelData(obj.test_sqw_2d_file_path, mem_alloc);

        new_pix = pix.do_binary_op(svar, @plus_single, 'flip', false, ...
                                   'npix', npix);

        original_pix_data = concatenate_pixel_pages(pix);
        new_pix_data = concatenate_pixel_pages(new_pix);

        expected_pix = original_pix_data;
        expected_pix(8, :) = expected_pix(8, :) + repelem(svar.s(:), npix(:))';
        expected_pix(9, :) = expected_pix(9, :) + repelem(svar.e(:), npix(:))';
        assertElementsAlmostEqual(new_pix_data, expected_pix, 'relative', 1e-7);
    end

    function test_binary_op_with_2D_dnd_returns_correct_pix_with_gt_1_page(obj)
        dnd_obj = d2d(obj.test_sqw_2d_file_path);
        npix = dnd_obj.npix;

        pix_per_page = floor(sum(npix(:)/6));
        mem_alloc = pix_per_page*PixelData.DATA_POINT_SIZE*PixelData.DEFAULT_NUM_PIX_FIELDS;
        pix = PixelData(obj.test_sqw_2d_file_path, mem_alloc);

        new_pix = pix.do_binary_op(dnd_obj, @plus_single, 'flip', false, ...
                                   'npix', npix);

        original_pix_data = concatenate_pixel_pages(pix);
        new_pix_data = concatenate_pixel_pages(new_pix);

        expected_pix = original_pix_data;
        expected_pix(8, :) = expected_pix(8, :) + repelem(dnd_obj.s(:), npix(:))';
        expected_pix(9, :) = expected_pix(9, :) + repelem(dnd_obj.e(:), npix(:))';
        assertElementsAlmostEqual(new_pix_data, expected_pix, 'relative', 1e-7);
    end

    % -- Helpers --
    function pix = get_pix_with_fake_faccess(obj, data, npix_in_page)
        faccess = FakeFAccess(data);
        mem_alloc = npix_in_page*obj.NUM_BYTES_IN_VALUE*obj.NUM_COLS_IN_PIX_BLOCK;
        pix = PixelData(faccess, mem_alloc);
    end
end

methods (Static)
    function data = get_random_data_in_range(cols, rows, data_range)
        data = data_range(1) + (data_range(2) - data_range(1)).*rand(cols, rows);
    end
end


end
