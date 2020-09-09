function npix_section = read_npix_block_(obj,ibin_start,nbin_buf_size)
% read npix information, describing pixels positions in every input file
%
%
% Inputs:
% ibin_start -- first bin to process
% nbin_buf_size -- number of bins to read and process
%
% Uses pix_combine info, containing locations of the npix blocks in all
% input files and defined as property of the cobine_pix job
%
fid = obj.fid_;
pos_npixstart = obj.pix_combine_info_.pos_npixstart;

nfiles = numel(fid);
npix_section = int64(zeros(nbin_buf_size,nfiles));

for i=1:nfiles
    status=fseek(fid(i),pos_npixstart(i)+8*(ibin_start-1),'bof'); % location of npix for bin number ibin_start 
    % (recall written as int64)
    if status<0
        filename = fopen(fid);
        mess = ['Unable to find location of npix data in ',filename];
        error('SQW_BINFILE_IO:runtime_error',mess);
    end
    npix_section(:,i) = fread(fid(i),nbin_buf_size,'*int64');
    %
    [f_message,f_errnum] = ferror(fid(i));
    if f_errnum ~=0
        error('SQW_BINFILE_IO:runtime_error',f_message);
    end
end
