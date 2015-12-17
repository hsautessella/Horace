#ifndef H_COMBINE_SQW
#define H_COMBINE_SQW

#include "../../build_all/CommonCode.h"

#include <sstream>
#include <iostream>
#include <fstream>
#include <memory>
//
// $Revision:: 1045 $ ($Date:: 2015-08-04 13:42:10 +0100 (Tue, 04 Aug 2015) $)" 
//

// information, describes files to combine (will be processed later)
struct fileParameters {
    size_t nbin_start_pos;   // the initial file position where nbin array is located in the file
    size_t pix_start_pos;   // the initial file position where the pixel array is located in file
    int    file_id;
    size_t total_NfileBins; // the number of bins in this file
};

enum readBinInfoOption {
    sumPixInfo,
    keepPixInfo
};
class cells_in_memory {
    public:
        cells_in_memory(size_t buf_size) :
            nTotalBins(0), binFileStartPos(0),
            num_first_buf_bin(0), buf_bin_end(0), sum_prev_bins(0),
            BIN_BUF_SIZE(buf_size) {
        }
        void init(std::fstream  &fileDescr, size_t bin_start_pos,size_t n_tot_bins);

        size_t num_pix_described(size_t bin_number)const;
        size_t num_pix_to_fit(size_t bin_number,size_t buf_size)const;
        void   get_npix_for_bin(size_t bin_number, size_t &pix_start_num, size_t &num_bin_pix);
    private:
        size_t  nTotalBins;
        size_t  binFileStartPos;

        size_t  num_first_buf_bin; // number of first bin in the buffer
        size_t  buf_bin_end; //  number of the last bin in the buffer+1
                             // buffer containing bin info
        size_t  sum_prev_bins;
        std::vector<uint64_t> nbin_buffer;
        std::vector<uint64_t> pix_pos_in_buffer;
        // number of pixels to read in bin buffer
        size_t BIN_BUF_SIZE;
        std::fstream  *fReader;

        size_t read_bins(size_t num_bin);
        void read_all_bin_info(size_t bin_number);

        static const size_t BIN_SIZE_BYTES=8;
};

class sqw_reader {
    /* Class provides bin and pixel information for a pixels of an sqw file.

    Created to read bin and pixel information from a cell stored on hdd,
    but optimized for subsequent data access, so subsequent cells are
    cashed in a buffer and provided from the buffer if available

    %
    % $Revision: 1099 $($Date : 2015 - 12 - 07 21 : 20 : 34 + 0000 (Mon, 07 Dec 2015) $)
    %
    */
public:
    sqw_reader();
    sqw_reader(const std::string &infile, const fileParameters &fpar);
    void init(const std::string &infile, const fileParameters &fpar);
    ~sqw_reader() {
        h_data_file.close();
    }
    /* get number of pixels, stored in the bin and the position of these pixels within pixel array */
    void get_npix_for_bin(size_t bin_number, size_t &pix_start_num, size_t &num_bin_pix);
    /* return pixel information for the pixels stored in the bin */
    void get_pix_for_bin(size_t bin_number, float *pix_info,size_t cur_position,
                         size_t &pix_start_num, size_t &num_bin_pix, bool position_is_defined = false);
private:
    void read_pixels(size_t bin_number, size_t pix_start_num);
    size_t check_binInfo_loaded_(size_t bin_number);

    // the name of the file to process
    std::string full_file_name;
    // handle pointing to open file
    std::fstream h_data_file;
    // parameters, which describe 
    fileParameters fileDescr;

    cells_in_memory bin_buffer;

    size_t npix_in_buf_start; //= 0;
    size_t buf_pix_end; //  number of last pixel in the buffer+1
    std::vector<float> pix_buffer; // buffer containing pixels (9*npix size)

     // number of pixels to read in pix buffer
    size_t PIX_BUF_SIZE;
};




#endif
