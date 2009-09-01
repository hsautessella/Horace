function mem=horace_memory(chunk_size,n_comp_threads)
% Defines: 
% 1) the size of the data chunk to load in the memory and 
% 2) how many computational threads to use in mex files and my Matlab
%    itself (if Matlab and correspondent mex file supports it)
% Default are: mem.chunk_size=10000000, mem.threads=num_processors.
%
% Usage:
% 1) set the chunk size and the  number of threads (and get optional result):
% >>>[mem=] horace_memory(chunk_size,n_comp_threads)
% 2) get the structure which keeps current values:
%>>> mem = horace_memory;
% where mem is the structure with fields:
%       mem.chunk_size -- is the size of the memory to use
%       mem.threads    -- number of threads used;
%


persistent mem_store;

% Initialise
if isempty(mem_store)
    n_processors = getenv('NUMBER_OF_PROCESSORS');
    Matlab_Version=ver('MATLAB');
    if(isempty(n_processors))
        n_processors=1;  % not good for linux
    else
        n_processors=str2double(n_processors);
    end
    if(str2double(Matlab_Version.Version)>7.7) % Matlab supports settings of the threads from command line
        maxNumCompThreads(n_processors);
    end
    mem_store=struct('chunk_size',10000000,'threads',n_processors);
end

if nargin==2
    if isscalar(chunk_size) && isnumeric(chunk_size)
        mem_store.chunk_size=chunk_size;
    else
        warning('Memory size must be a number, Input is ignored, default value %d used instead',mem_store.chunk_size);
    end
    if isscalar(n_comp_threads) && isnumeric(n_comp_threads) && n_comp_threads>0
        mem_store.threads=n_comp_threads;
    else
        warning('Number of computational threads has to be a positive mumber.\n Input is ignored, value %d used instead',mem_store.threads);

    end
elseif nargin~=0
    warning('Incorrect number of arguments. memory usage and number of computational threads left unchanged')
end

if nargout>0
   mem=mem_store;
end
