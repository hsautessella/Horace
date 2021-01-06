classdef test_mask < TestCase
    
    properties
        this_dir = fileparts(mfilename('fullpath'));
        old_warn_state;
        
        sqw_2d_file_path = '../test_sqw_file/sqw_2d_1.sqw';
        sqw_2d;
        idxs_to_mask;
        mask_array_2d;
        masked_2d_pix_range
        masked_2d_img_range
        
        sqw_3d_file_path = '../test_rebin/w3d_sqw.sqw';
        sqw_3d;
        sqw_3d_paged;
        idxs_to_mask_3d;
        mask_array_3d;
        masked_3d;
        masked_3d_paged;
    end
    
    methods
        
        function obj = test_mask(~)
            obj = obj@TestCase('test_mask');
            
            addpath(fullfile(obj.this_dir, 'utils'));
            
            % Swallow any warnings for when pixel page size set too small
            obj.old_warn_state = warning('OFF', 'PIXELDATA:validate_mem_alloc');
            
            % 2D case setup
            obj.sqw_2d = sqw(obj.sqw_2d_file_path);
            obj.sqw_2d.data.pix.recalculate_pix_range();
            
            obj.idxs_to_mask = [2, 46, 91, 93, 94, 107, 123, 166];
            obj.mask_array_2d = ones(size(obj.sqw_2d.data.npix), 'logical');
            obj.mask_array_2d(obj.idxs_to_mask) = 0;
            
            
            % 3D case setup
            obj.sqw_3d = sqw(obj.sqw_3d_file_path);
            
            num_bins = numel(obj.sqw_3d.data.npix);
            obj.idxs_to_mask_3d = linspace(1, num_bins/2, num_bins/2);
            obj.mask_array_3d = ones(size(obj.sqw_3d.data.npix), 'logical');
            obj.mask_array_3d(obj.idxs_to_mask_3d) = 0;
            
            obj.masked_3d = mask(obj.sqw_3d, obj.mask_array_3d);
            [obj.sqw_3d_paged, obj.masked_3d_paged] = ...
                obj.get_paged_sqw(obj.sqw_3d_file_path, obj.mask_array_3d);
        end
        
        function delete(obj)
            rmpath(fullfile(obj.this_dir, 'utils'));
            warning(obj.old_warn_state);
        end
        
        function test_pix_range_equal_for_paged_and_non_paged_sqw_after_mask(obj)
            %
            if isempty(obj.masked_2d_pix_range)
                masked_2d = mask(obj.sqw_2d, obj.mask_array_2d);
                obj.masked_2d_pix_range = masked_2d.data.pix.pix_range;
                obj.masked_2d_img_range = masked_2d.data.img_range;
            end
            paged_pix_range = obj.masked_2d_paged.data.pix.pix_range;
            mem_pix_range = obj.masked_2d_pix_range;
            assertElementsAlmostEqual(mem_pix_range, paged_pix_range, 'absolute', 0.001);
        end
        
        %
        function test_mask_works_in_memory(obj)
            masked_2d = mask(obj.sqw_2d, obj.mask_array_2d);
            %mask_sets_npix_in_masked_bins_to_zero
            assertEqual(sum(masked_2d.data.npix(~obj.mask_array_2d)), 0);
            %test_mask_sets_signal_in_masked_bins_to_zero
            assertEqual(sum(masked_2d.data.s(~obj.mask_array_2d)), 0);
            %test_mask_sets_error_in_masked_bins_to_zero
            assertEqual(sum(masked_2d.data.e(~obj.mask_array_2d)), 0);
            
            %test_mask_does_not_change_unmasked_bins_signal
            assertEqual(masked_2d.data.s(obj.mask_array_2d), ...
                obj.sqw_2d.data.s(obj.mask_array_2d));
            % test_mask_does_not_change_unmasked_bins_error
            assertEqual(masked_2d.data.s(obj.mask_array_2d), ...
                obj.sqw_2d.data.s(obj.mask_array_2d));
            % test_mask_does_not_change_unmasked_bins_npix
            assertEqual(masked_2d.data.npix(obj.mask_array_2d), ...
                obj.sqw_2d.data.npix(obj.mask_array_2d));
            
            % test_num_pixels_has_been_reduced_by_correct_amount
            expected_num_pix = sum(obj.sqw_2d.data.npix(obj.mask_array_2d));
            assertEqual(masked_2d.data.pix.num_pixels, expected_num_pix);
            
            % test_img_range_recalculated_after_mask
            % TODO: enable check when img_range is fully supported
            obj.masked_2d_img_range = obj.sqw_2d.data.img_range;
            %assertElementsAlmostEqual(original_pix_range(2:end), new_pix_range(2:end), ...
            %    'absolute', 0.001);
            
            original_pix_range = obj.sqw_2d.data.pix.pix_range;
            new_pix_range = masked_2d.data.pix.pix_range;
            obj.masked_2d_pix_range = new_pix_range;
            
            pix_range_diff = abs(original_pix_range - new_pix_range);
            assertTrue(pix_range_diff(1) > 0.001);
            assertElementsAlmostEqual(original_pix_range(2,:), new_pix_range(2,:), ...
                'absolute', 0.001);
            assertElementsAlmostEqual(original_pix_range(1,3:end), new_pix_range(1,3:end), ...
                'absolute', 0.001);
            
            % test_paged_and_non_paged_sqw_have_equivalent_pixels_after_mask
            raw_paged_pix = concatenate_pixel_pages(obj.masked_2d_paged.data.pix);
            assertEqual(raw_paged_pix, masked_2d.data.pix.data);
        end
        
        function test_mask_works_with_paged(obj)
            [~, masked_2d_paged] = ...
                obj.get_paged_sqw(obj.sqw_2d_file_path, obj.mask_array_2d);
            
            %function test_mask_sets_npix_in_masked_bins_to_zero_with_paged_pix(obj)
            assertEqual(sum(masked_2d_paged.data.npix(~obj.mask_array_2d)), 0);
            %function test_mask_sets_signal_in_masked_bins_to_zero_with_paged_pix(obj)
            assertEqual(sum(masked_2d_paged.data.s(~obj.mask_array_2d)), 0);
            %function test_mask_sets_error_in_masked_bins_to_zero_with_paged_pix(obj)
            assertEqual(sum(masked_2d_paged.data.e(~obj.mask_array_2d)), 0);
            %end
            
            %function test_mask_does_not_change_unmasked_bins_signal_with_paged_pix(obj)
            assertEqual(obj.masked_2d_paged.data.s(obj.mask_array_2d), ...
                obj.sqw_2d.data.s(obj.mask_array_2d));
            %function test_mask_does_not_change_unmasked_bins_error_with_paged_pix(obj)
            assertEqual(masked_2d_paged.data.e(obj.mask_array_2d), ...
                obj.sqw_2d.data.e(obj.mask_array_2d));
            %function test_mask_does_not_change_unmasked_bins_npix_with_paged_pix(obj)
            assertEqual(obj.masked_2d_paged.data.npix(obj.mask_array_2d), ...
                obj.sqw_2d.data.npix(obj.mask_array_2d));
            
            % function test_num_pix_has_been_reduced_by_correct_amount_with_paged_pix(obj)
            expected_num_pix = sum(obj.sqw_2d.data.npix(obj.mask_array_2d));
            assertEqual(obj.masked_2d_paged.data.pix.num_pixels, expected_num_pix);
            
            %function test_img_range_recalculated_after_mask_with_paged_pix(obj)
            original_pix_range = obj.sqw_2d.data.pix.pix_range;
            new_pix_range = masked_2d_paged.data.pix.pix_range;
            
            img_range_diff = abs(original_pix_range - new_pix_range);
            assertTrue(img_range_diff(1) > 0.001);
            assertElementsAlmostEqual(original_pix_range(2,:), new_pix_range(2,:), ...
                'absolute', 0.001);
            assertElementsAlmostEqual(original_pix_range(1,3:end), new_pix_range(1,3:end), ...
                'absolute', 0.001);
        end
        
        
        
        function test_mask_sets_npix_in_masked_bins_to_zero_3d(obj)
            assertEqual(sum(obj.masked_3d.data.npix(~obj.mask_array_3d)), 0);
        end
        
        function test_mask_sets_npix_in_masked_bins_to_zero_with_paged_pix_3d(obj)
            assertEqual(sum(obj.masked_3d_paged.data.npix(~obj.mask_array_3d)), 0);
        end
        
        function test_mask_sets_signal_in_masked_bins_to_zero_3d(obj)
            assertEqual(sum(obj.masked_3d.data.s(~obj.mask_array_3d)), 0);
        end
        
        function test_mask_sets_signal_in_masked_bins_to_zero_with_paged_pix_3d(obj)
            assertEqual(sum(obj.masked_3d_paged.data.s(~obj.mask_array_3d)), 0);
        end
        
        function test_mask_sets_error_in_masked_bins_to_zero_3d(obj)
            assertEqual(sum(obj.masked_3d.data.e(~obj.mask_array_3d)), 0);
        end
        
        function test_mask_sets_error_in_masked_bins_to_zero_with_paged_pix_3d(obj)
            assertEqual(sum(obj.masked_3d_paged.data.e(~obj.mask_array_3d)), 0);
        end
        
        function test_mask_does_not_change_unmasked_bins_signal_3d(obj)
            assertEqual(obj.masked_3d.data.s(obj.mask_array_3d), ...
                obj.sqw_3d.data.s(obj.mask_array_3d));
        end
        
        function test_mask_doesnt_change_unmasked_bins_signal_with_paged_pix_3d(obj)
            assertEqual(obj.masked_3d_paged.data.s(obj.mask_array_3d), ...
                obj.sqw_3d.data.s(obj.mask_array_3d));
        end
        
        function test_mask_does_not_change_unmasked_bins_error_3d(obj)
            assertEqual(obj.masked_3d.data.e(obj.mask_array_3d), ...
                obj.sqw_3d.data.e(obj.mask_array_3d));
        end
        
        function test_mask_does_not_change_unmasked_bins_error_with_paged_pix_3d(obj)
            assertEqual(obj.masked_3d_paged.data.e(obj.mask_array_3d), ...
                obj.sqw_3d.data.e(obj.mask_array_3d));
        end
        
        function test_mask_does_not_change_unmasked_bins_npix_3d(obj)
            assertEqual(obj.masked_3d.data.npix(obj.mask_array_3d), ...
                obj.sqw_3d.data.npix(obj.mask_array_3d));
        end
        
        function test_mask_does_not_change_unmasked_bins_npix_with_paged_pix_3d(obj)
            assertEqual(obj.masked_3d_paged.data.npix(obj.mask_array_3d), ...
                obj.sqw_3d.data.npix(obj.mask_array_3d));
        end
        
        function test_num_pixels_has_been_reduced_by_correct_amount_3d(obj)
            expected_num_pix = sum(obj.sqw_3d.data.npix(obj.mask_array_3d));
            assertEqual(obj.masked_3d.data.pix.num_pixels, expected_num_pix);
        end
        
        function test_num_pix_has_been_reduced_by_correct_amount_paged_pix_3d(obj)
            expected_num_pix = sum(obj.sqw_3d.data.npix(obj.mask_array_3d));
            assertEqual(obj.masked_3d_paged.data.pix.num_pixels, expected_num_pix);
        end
        
        function test_img_range_recalculated_after_mask_3d(obj)
            original_img_range = obj.sqw_3d.data.img_range;
            img_range_diff = abs(original_img_range - obj.masked_3d.data.img_range);
            assertTrue(~all(img_range_diff < 0.001, 'all'));
        end
        
        function test_img_range_recalculated_after_mask_with_paged_pix_3d(obj)
            original_img_range = obj.sqw_3d.data.img_range;
            img_range_diff = abs(original_img_range - obj.masked_3d_paged.data.img_range);
            assertTrue(~all(img_range_diff < 0.001, 'all'));
        end
        
        function test_paged_and_non_paged_sqw_have_same_pixels_after_mask_3d(obj)
            raw_paged_pix = concatenate_pixel_pages(obj.masked_3d_paged.data.pix);
            assertEqual(raw_paged_pix, obj.masked_3d.data.pix.data);
        end
        
        function test_img_range_equal_for_paged_and_non_paged_sqw_after_mask_3d(obj)
            paged_img_range = obj.masked_3d_paged.data.img_range;
            mem_img_range = obj.masked_3d.data.img_range;
            assertElementsAlmostEqual(mem_img_range, paged_img_range, 'absolute', 0.001);
        end
        
    end
    
    methods (Static)
        
        % -- Helpers --
        function [paged_sqw, masked_sqw] = get_paged_sqw(file_path, mask_array)
            file_info = dir(file_path);
            new_pg_size = file_info.bytes/6;
            
            paged_sqw = sqw(file_path, 'pixel_page_size', new_pg_size);
            masked_sqw = mask(paged_sqw, mask_array);
            
            % make sure we're actually paging the pixel data
            assertTrue(paged_sqw.data.pix.page_size < paged_sqw.data.pix.num_pixels);
        end
        
    end
    
end
