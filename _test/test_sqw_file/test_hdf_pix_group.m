classdef test_hdf_pix_group < TestCase
    %Unit tests to validate hdf_pix_group class
    %
    
    properties
    end
    
    methods
        function obj = test_hdf_pix_group(varargin)
            if nargin == 0
                class_name = 'test_hdf_pix_group';
            else
                class_name = varargin{1};
            end
            obj = obj@TestCase(class_name);
        end
        function close_fid(obj,fid,file_h,group_id)
            H5G.close(group_id);
            if ~isempty(file_h)
                H5G.close(fid);
                H5F.close(file_h);
            else
                H5F.close(fid);
            end
        end
        
        
        function test_read_write(obj)
            f_name = [tempname,'.nxsqw'];
            [fid,group_id,file_h,data_version] = open_or_create_nxsqw_head(f_name);
            clob1 = onCleanup(@()close_fid(obj,fid,file_h,group_id));
            clob2 = onCleanup(@()delete(f_name));
            
            arr_size = 100000;
            pix_writer = hdf_pix_group(group_id,arr_size,16*1024);
            assertTrue(exist(f_name,'file')==2);
            pix_alloc_size = pix_writer.max_num_pixels;
            chunk_size     = pix_writer.chunk_size;
            assertEqual(chunk_size,16*1024);
            assertTrue(pix_alloc_size >= arr_size);
            
            data = ones(9,100);
            pos = [2,arr_size/2,arr_size-size(data,2)];
            pix_writer.write_pixels(pos(1),data);
            
            pix_writer.write_pixels(pos(2),2*data);
            
            pix_writer.write_pixels(pos(3),3*data);
            clear pix_writer;
            
            
            pix_reader = hdf_pix_group(group_id);
            assertEqual(chunk_size,pix_reader.chunk_size);
            assertEqual(pix_alloc_size,pix_reader.max_num_pixels);
            
            
            pix1 = pix_reader.read_pixels(pos(1),size(data,2));
            pix2 = pix_reader.read_pixels(pos(2),size(data,2));
            pix3 = pix_reader.read_pixels(pos(3),size(data,2));
            
            assertEqual(single(data),pix1);
            assertEqual(single(2*data),pix2);
            assertEqual(single(3*data),pix3);
            
            clear pix_reader;
            clear clob1
            
            [fid,group_id,file_h,rec_version] = open_or_create_nxsqw_head(f_name);
            clob1 = onCleanup(@()close_fid(obj,fid,file_h,group_id));
            
            assertEqual(data_version,rec_version);
            
            pix_reader = hdf_pix_group(group_id);
            pix3 = pix_reader.read_pixels(pos(3),size(data,2));
            pix2 = pix_reader.read_pixels(pos(2),size(data,2));
            pix1 = pix_reader.read_pixels(pos(1),size(data,2));
            
            
            
            assertEqual(single(data),pix1);
            assertEqual(single(2*data),pix2);
            assertEqual(single(3*data),pix3);
            
            clear pix_reader;
            
            clear clob1;
            clear clob2;
        end
        %
        function test_missing_file(obj)
            f_name = [tempname,'.nxsqw'];
            
            [fid,group_id,file_h] = open_or_create_nxsqw_head(f_name);
            clob1 = onCleanup(@()close_fid(obj,fid,file_h,group_id));
            clob2 = onCleanup(@()delete(f_name));
            
            f_missing = @()hdf_pix_group(group_id);
            assertExceptionThrown(f_missing,'HDF_PIX_GROUP:invalid_argument')
            
        end
        %
        function test_multiblock_read(obj)
            f_name = [tempname,'.nxsqw'];
            
            [fid,group_id,file_h] = open_or_create_nxsqw_head(f_name);
            clob1 = onCleanup(@()close_fid(obj,fid,file_h,group_id));
            clob2 = onCleanup(@()delete(f_name));
            
            arr_size = 100000;
            pix_acc = hdf_pix_group(group_id,arr_size,1024);
            assertTrue(exist(f_name,'file')==2);
            
            data = repmat(1:arr_size,9,1);
            pix_acc.write_pixels(1,data);
            
            pos = [10,100,400];
            npix = 10;
            [pix,pos,npix] = pix_acc.read_pixels(pos,npix);
            assertEqual(pix(2,1:10),single(10:19));
            assertEqual(pix(9,11:20),single(100:109));
            assertEqual(pix(1,21:30),single(400:409));
            assertTrue(isempty(pos));
            assertEqual(npix,10);
            
            pos = [10,2000,5000];
            npix =[1024,2048,1000];
            [pix,pos,npix] = pix_acc.read_pixels(pos,npix);
            
            assertEqual(pix(3,1:1024),single(10:1033));
            assertEqual(numel(pos),2);
            assertEqual(numel(npix),2);
            
            [pix,pos,npix] = pix_acc.read_pixels(pos,npix);
            assertEqual(pix(1,1:2048),single(2000:(1999+2048)));
            assertEqual(numel(pos),1);
            assertEqual(numel(npix),1);
            
            [pix,pos,npix] = pix_acc.read_pixels(pos,npix);
            assertEqual(pix(1,1:1000),single(5000:(4999+1000)));
            assertTrue(isempty(pos));
            assertEqual(npix,1000);
            
            
            % single read operation as total size is smaller than the block
            % size
            pos = [10,1000,2000];
            npix =[128,256,256];
            [pix,pos,npix] = pix_acc.read_pixels(pos,npix);
            assertEqual(pix(1,385:(384+256)),single(2000:(1999+256)));
            assertTrue(isempty(pos));
            assertTrue(isempty(npix));
            
            clear pix_acc;
            clear clob1;
            clear clob2;
            
        end
        %
        function  test_mex_reader_multithread(obj)
            if isempty(which('hdf_mex_reader'))
                warning('TEST_MEX_READER:runtime_error',...
                    'the hdf mex reader was not found in the Matlab path. Testing skipped');
                return
            end
            % use when mex code debuging only
            %clob0 = onCleanup(@()clear('mex'));
            
            f_name = [tempname,'.nxsqw'];
            
            [fid,group_id,file_h] = open_or_create_nxsqw_head(f_name);
            clob1 = onCleanup(@()delete(f_name));
            clob2 = onCleanup(@()close_fid(obj,fid,file_h,group_id));
            
            
            arr_size = 100000;
            pix_acc = hdf_pix_group(group_id,arr_size,1024);
            assertTrue(exist(f_name,'file')==2);
            clob3 = onCleanup(@()delete(pix_acc));
            
            data = repmat(1:arr_size,9,1);
            for i=1:9
                data(i,:) = data(i,:)*i;
            end
            pix_acc.write_pixels(1,data);
            clear clob3;
            clear clob2;            
            
            % check mex file is callable
            clob4 = onCleanup(@()hdf_mex_reader('close','close'));
            
            [root_nx_path,~,data_structure] = find_root_nexus_dir(f_name,"NXSQW");
            group_name = data_structure.GroupHierarchy.Groups.Groups(1).Name;
            
            %-------------------------------------------------------------
            pos = 50;
            npix =5*1000;
            nblock0=0;
            pos0 = 0;
            [pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2000,4);
            assertVectorsAlmostEqual(size(pix_array),[9,2000]);
            assertEqual(nblock0,0);
            assertEqual(pos0,2000);
            assertElementsAlmostEqual(pix_array(:,1:2000),single(data(:,pos(1):(2000+pos(1)-1))));
            %
            pos = [2,50,6000];
            npix =[10,5*1000,10];
            nblock0=0;
            pos0 = 0;
            [pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2000,4);
            assertVectorsAlmostEqual(size(pix_array),[9,2000]);
            assertEqual(nblock0,1);
            assertEqual(pos0,1990);
            assertElementsAlmostEqual(pix_array(:,1:10),single(data(:,pos(1):(npix(1)+pos(1)-1))));
            assertElementsAlmostEqual(pix_array(:,11:2000),single(data(:,pos(2):(1990+pos(2)-1))));
            
            [pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2000,4);
            assertVectorsAlmostEqual(size(pix_array),[9,2000]);
            assertEqual(nblock0,1);
            assertEqual(pos0,3990);
            assertElementsAlmostEqual(pix_array(:,1:2000),single(data(:,pos(2)+1990:(3990+pos(2)-1))));
            
            [pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2000,4);
            assertVectorsAlmostEqual(size(pix_array),[9,1020]);
            assertEqual(nblock0,3);
            assertEqual(pos0,0);
            assertElementsAlmostEqual(pix_array(:,1:1010),single(data(:,pos(2)+3990:(5000+pos(2)-1))));
            assertElementsAlmostEqual(pix_array(:,1011:1020),single(data(:,pos(3):(10+pos(3)-1))));

            pos = [10,2000, 5000];
            npix =[1024,1024,1000];
            nblock0 =0;
            pos0 = 0;
            [pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2048,4);
            
            assertVectorsAlmostEqual(size(pix_array),[9,2048]);
            assertEqual(numel(nblock0),1);
            assertEqual(numel(pos0),1);
            assertEqual(nblock0,2);
            assertEqual(pos0,0);
            assertElementsAlmostEqual(pix_array(:,1:1024),single(data(:,10:1033)));
            assertElementsAlmostEqual(pix_array(:,1025:2048),single(data(:,2000:2000+1023)));            
            %-------------------------------------------------------------
            pos = [10,2000, 5000];
            npix =[1024,1024,1000];
            nblock0 =0;
            pos0 = 0;
            [pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2048,3);
            
            assertVectorsAlmostEqual(size(pix_array),[9,2048]);
            assertEqual(numel(nblock0),1);
            assertEqual(numel(pos0),1);
            assertEqual(nblock0,2);
            assertEqual(pos0,0);
            assertElementsAlmostEqual(pix_array(:,1:1024),single(data(:,10:1033)));
            assertElementsAlmostEqual(pix_array(:,1025:2048),single(data(:,2000:2000+1023)));
            
            [pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2048,3);
            
            assertVectorsAlmostEqual(size(pix_array),[9,1000]);
            assertEqual(nblock0,3);
            assertEqual(pos0,0);
            assertElementsAlmostEqual(pix_array(:,1:1000),single(data(:,5000:5000+999)));
            
            % check limits
            [pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,[1,100000],[1,1],0,0,2048,3);
            assertEqual(nblock0,2);
            assertEqual(pos0,0);
            assertElementsAlmostEqual(pix_array(:,1),single(data(:,1)));
            assertElementsAlmostEqual(pix_array(:,2),single(data(:,100000)));
            
            % check partial buffer
            pos = [10,2000,5000];
            npix =[1024,1024,1000];
            nblock0 = 0;
            pos0  = 0;
            [pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2000,5);
            
            assertVectorsAlmostEqual(size(pix_array),[9,2000]);
            assertEqual(nblock0,1);
            assertEqual(pos0,976);
            assertElementsAlmostEqual(pix_array(:,1:1024),single(data(:,10:1033)));
            assertElementsAlmostEqual(pix_array(:,1025:2000),single(data(:,2000:2000+975)));
            
            [pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2000,5);
            assertVectorsAlmostEqual(size(pix_array),[9,1048]);
            assertEqual(nblock0,3);
            assertEqual(pos0,0);
            assertElementsAlmostEqual(pix_array(:,1:48),single(data(:,2976:(2976+47))));
            assertElementsAlmostEqual(pix_array(:,49:1048),single(data(:,5000:(5000+999))))
            
            
            clear clob4;
            clear clob1;
            %clear clob0;
            
        end
        %
        function  test_mex_reader(obj)
            if isempty(which('hdf_mex_reader'))
                warning('TEST_MEX_READER:runtime_error',...
                    'the hdf mex reader was not found in the Matlab path. Testing skipped');
                return
            end
            % use when mex code debuging only
            %clob0 = onCleanup(@()clear('mex'));
            
            f_name = [tempname,'.nxsqw'];
            
            [fid,group_id,file_h] = open_or_create_nxsqw_head(f_name);
            clob1 = onCleanup(@()delete(f_name));
            clob2 = onCleanup(@()close_fid(obj,fid,file_h,group_id));
            
            
            arr_size = 100000;
            pix_acc = hdf_pix_group(group_id,arr_size,1024);
            assertTrue(exist(f_name,'file')==2);
            clob3 = onCleanup(@()delete(pix_acc));
            
            data = repmat(1:arr_size,9,1);
            for i=1:9
                data(i,:) = data(i,:)*i;
            end
            pix_acc.write_pixels(1,data);
            clear clob3;
            clear clob2;
            
            
            % check mex file is callable
            rev = hdf_mex_reader();
            assertTrue(~isempty(rev));
            
            [pix_array,next_block,block_pos]=hdf_mex_reader('close','close');
            assertTrue(isempty(pix_array))
            assertEqual(next_block,0);
            assertEqual(block_pos,0);
            clob4 = onCleanup(@()hdf_mex_reader('close','close'));
            
            [root_nx_path,~,data_structure] = find_root_nexus_dir(f_name,"NXSQW");
            group_name = data_structure.GroupHierarchy.Groups.Groups(1).Name;
            
            ferr = @()hdf_mex_reader(f_name,group_name);
            assertExceptionThrown(ferr,'HDF_MEX_ACCESS:invalid_argument');
            %-------------------------------------------------------------
            pos = 50;
            npix =5*1000;
            nblock0=0;
            pos0 = 0;
            [pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2000);
            assertVectorsAlmostEqual(size(pix_array),[9,2000]);
            assertEqual(nblock0,0);
            assertEqual(pos0,2000);
            assertElementsAlmostEqual(pix_array(:,1:2000),single(data(:,pos(1):(2000+pos(1)-1))));
            %
            pos = [2,50,6000];
            npix =[10,5*1000,10];
            nblock0=0;
            pos0 = 0;
            [pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2000);
            assertVectorsAlmostEqual(size(pix_array),[9,2000]);
            assertEqual(nblock0,1);
            assertEqual(pos0,1990);
            assertElementsAlmostEqual(pix_array(:,1:10),single(data(:,pos(1):(npix(1)+pos(1)-1))));
            assertElementsAlmostEqual(pix_array(:,11:2000),single(data(:,pos(2):(1990+pos(2)-1))));
            
            [pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2000);
            assertVectorsAlmostEqual(size(pix_array),[9,2000]);
            assertEqual(nblock0,1);
            assertEqual(pos0,3990);
            assertElementsAlmostEqual(pix_array(:,1:2000),single(data(:,pos(2)+1990:(3990+pos(2)-1))));
            
            [pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2000);
            assertVectorsAlmostEqual(size(pix_array),[9,1020]);
            assertEqual(nblock0,3);
            assertEqual(pos0,0);
            assertElementsAlmostEqual(pix_array(:,1:1010),single(data(:,pos(2)+3990:(5000+pos(2)-1))));
            assertElementsAlmostEqual(pix_array(:,1011:1020),single(data(:,pos(3):(10+pos(3)-1))));
            %-------------------------------------------------------------
            pos = [10,2000, 5000];
            npix =[1024,1024,1000];
            nblock0 =0;
            pos0 = 0;
            [pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2048);
            
            assertVectorsAlmostEqual(size(pix_array),[9,2048]);
            assertEqual(numel(nblock0),1);
            assertEqual(numel(pos0),1);
            assertEqual(nblock0,2);
            assertEqual(pos0,0);
            assertElementsAlmostEqual(pix_array(:,1:1024),single(data(:,10:1033)));
            assertElementsAlmostEqual(pix_array(:,1025:2048),single(data(:,2000:2000+1023)));
            
            [pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2048);
            
            assertVectorsAlmostEqual(size(pix_array),[9,1000]);
            assertEqual(nblock0,3);
            assertEqual(pos0,0);
            assertElementsAlmostEqual(pix_array(:,1:1000),single(data(:,5000:5000+999)));
            
            % check limits
            [pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,[1,100000],[1,1],0,0,2048);
            assertEqual(nblock0,2);
            assertEqual(pos0,0);
            assertElementsAlmostEqual(pix_array(:,1),single(data(:,1)));
            assertElementsAlmostEqual(pix_array(:,2),single(data(:,100000)));
            
            % check partial buffer
            pos = [10,2000,5000];
            npix =[1024,1024,1000];
            nblock0 = 0;
            pos0  = 0;
            [pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2000);
            
            assertVectorsAlmostEqual(size(pix_array),[9,2000]);
            assertEqual(nblock0,1);
            assertEqual(pos0,976);
            assertElementsAlmostEqual(pix_array(:,1:1024),single(data(:,10:1033)));
            assertElementsAlmostEqual(pix_array(:,1025:2000),single(data(:,2000:2000+975)));
            
            [pix_array,nblock0,pos0]=hdf_mex_reader(f_name,group_name,pos,npix,nblock0,pos0,2000);
            assertVectorsAlmostEqual(size(pix_array),[9,1048]);
            assertEqual(nblock0,3);
            assertEqual(pos0,0);
            assertElementsAlmostEqual(pix_array(:,1:48),single(data(:,2976:(2976+47))));
            assertElementsAlmostEqual(pix_array(:,49:1048),single(data(:,5000:(5000+999))))
            
            
            clear clob4;
            clear clob1;
            %clear clob0;
            
        end
    end
    
end
