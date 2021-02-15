function obj = validate_pixel_positions(obj)
    pix_end = obj.eof_pix_pos_;  % position in file we should be in
    fseek(obj.file_id_,0,'eof');
    file_end = ftell(obj.file_id_);  % actual position of end of file
    if uint64(pix_end) > uint64(file_end)
        npix_expected = obj.npixels;
        npix_written = (pix_end - obj.pix_position)/(4*9);
        warning('FACCESS_SQW_V3:runtime_error',...
            'Expected %d but written %d pixels. File end position %d is smaller than pixel end position: %d\n%s',...
            npix_expected,npix_written,file_end,pix_end,...
            'Missing pixels: waiting 10 sec to flush filesystem in hope that pixels will be written.');
        for i=1:10
            fprintf('.')
            pause(1);
            fseek(obj.file_id_,0,'eof');
            file_end = ftell(obj.file_id_);
            if uint64(pix_end) == uint64(file_end)
                break;
            end
        end
        fprintf('.\n')

        if uint64(pix_end) ~= uint64(file_end)
            % make object an sqw_v2 object and exit
            write_v2_obj_header_(obj);
            error('FACCESS_SQW_V3:runtime_error',...
                ['can not move to pixel end to write auxiliary V3 information\n',...
                ' File written as v2 file, which may have corrupted pixels.']);
        end
    end
end
