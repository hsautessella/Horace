#ifndef H_COMBINE_SQW
#define H_COMBINE_SQW

#include "../../build_all/CommonCode.h"

#include <sstream>
#include <iostream>
#include <fstream>
#include <memory>
#include <map>
//
// $Revision::      $ ($Date::                                              $)" 
//

// information, describes files to combine (will be processed later)
class fileParameters {
public:
    std::string fileName;
    size_t nbin_start_pos;   // the initial file position where nbin array is located in the file
    size_t pix_start_pos;   // the initial file position where the pixel array is located in file
    int    file_id;
    size_t total_NfileBins; // the number of bins in this file (has to be the same for all files)
    fileParameters(const mxArray *pFileParam);
    fileParameters():fileName(""),nbin_start_pos(0), pix_start_pos(0),
    file_id(0), total_NfileBins(0){}
private:
    static const std::map<std::string, int> fileParamNames;
};

enum readBinInfoOption {
    sumPixInfo,
    keepPixInfo
};
//-----------------------------------------------------------------------------------------------------------------
class cells_in_memory {
    public:
        cells_in_memory(size_t buf_size) :
            nTotalBins(0), binFileStartPos(0),
            num_first_buf_bin(0), buf_bin_end(0), pix_before_buffer(0),
            BIN_BUF_SIZE(buf_size), BUF_SIZE_STEP(buf_size), buf_end(1){
        }
        void init(std::fstream  &fileDescr, size_t bin_start_pos,size_t n_tot_bins,size_t bufSize=4096);

        size_t num_pix_described(size_t bin_number)const;
        size_t num_pix_to_fit(size_t bin_number,size_t buf_size)const;
        void   get_npix_for_bin(size_t bin_number, size_t &pix_start_num, size_t &num_bin_pix);
        void expand_pixels_selection(size_t bin_number);
    private:
        size_t  nTotalBins;
        size_t  binFileStartPos;

        size_t  num_first_buf_bin; // number of first bin in the buffer
        size_t  buf_bin_end; //  number of the last bin in the buffer+1
                             // buffer containing bin info
        size_t  pix_before_buffer; /* number of pixels, located before the first pixel, described by the buffer 
        e.g. position of the first pixel located in the first bin of the buffer */
        std::vector<uint64_t> nbin_buffer;
        std::vector<uint64_t> pix_pos_in_buffer;
        size_t BIN_BUF_SIZE; // physical size of the pixels buffer
        size_t BUF_SIZE_STEP; // unit step for BIN_BUF_SIZE, which should not exceed 2*BUF_SIZE_STEP;
        size_t buf_end; /* points to the place after the last bin actually read into the buffer.
        Differs from BIN_BUF_SIZE, as BIN_BUF_SIZE is physical buffer size which may not have all or any bins read into
        e.g at the end, where all available bins were read */

        std::fstream  *fReader;

        size_t read_bins(size_t num_bin,size_t buf_start,size_t buf_size);
        void read_all_bin_info(size_t bin_number);

        static const size_t BIN_SIZE_BYTES=8;
};
//-----------------------------------------------------------------------------------------------------------------
class sqw_pix_writer {
public:
    sqw_pix_writer(size_t buf_size):
    PIX_BUF_SIZE(buf_size),
    last_pix_written(0), pix_array_position(0){}

    void init(const fileParameters &fpar);
    void write_pixels(const size_t nPixelsToWrite);
    float * get_pBuffer(){return &pix_buffer[0]; }
    ~sqw_pix_writer();
private:
    // size of write pixels buffer (in pixels)
    size_t PIX_BUF_SIZE;
    std::string filename;

    std::ofstream h_out_sqw;
    size_t last_pix_written;
    size_t pix_array_position;
    size_t nbin_position;

    std::vector<float> pix_buffer;
    //
    static const size_t PIX_SIZE = 9; // size of the pixel in pixel data units (float)
    static const size_t PIX_BLOCK_SIZE_BYTES = 36; //9 * 4; // size of the pixel block in bytes


};

//-----------------------------------------------------------------------------------------------------------------
class sqw_reader {
    /* Class provides bin and pixel information for a pixels of an sqw file.

    Created to read bin and pixel information from a cell stored on hdd,
    but optimized for subsequent data access, so subsequent cells are
    cashed in a buffer and provided from the buffer if available

    %
    % $Revision$($Date : 2015 - 12 - 07 21 : 20 : 34 + 0000 (Mon, 07 Dec 2015) $)
    %
    */
public:
    sqw_reader(size_t working_buf_size=4096);
    sqw_reader(const fileParameters &fpar, bool changefileno, bool fileno_provided,size_t working_buf_size=4096);
    void init(const fileParameters &fpar,bool changefileno, bool fileno_provided,size_t working_buf_size=4096);
    ~sqw_reader() {
        h_data_file.close();
    }
    /* get number of pixels, stored in the bin and the position of these pixels within pixel array */
    void get_npix_for_bin(size_t bin_number, size_t &pix_start_num, size_t &num_bin_pix);
    /* return pixel information for the pixels stored in the bin */
    void get_pix_for_bin(size_t bin_number, float *pix_info,size_t cur_buf_position,
                         size_t &pix_start_num, size_t &num_bin_pix, bool position_is_defined = false);
private:
    void read_pixels(size_t bin_number, size_t pix_start_num);
    size_t check_binInfo_loaded_(size_t bin_number, bool extend_pix_buffer=true);

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
    //Boolean indicating that the id, which specify pixel run number should be modified
    bool change_fileno;
    // Boolean, indicating if one needs to offset pixel's run number id by fileDescr.file_id
    // or set up its value into fileDescr.file_id;
    bool fileno;

    static const size_t PIX_SIZE = 9; // size of the pixel in pixel data units (float)
    static const size_t PIX_BLOCK_SIZE_BYTES = 36; //9 * 4; // size of the pixel block in bytes


};




#endif
