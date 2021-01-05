function wout = cut_sqw(source, varargin)
%%CUT_SQW
%

% In cut_sqw we enforce that input must be SQW file or sqw object
if ~isa(source, 'sqw')
    if is_string(source)
        [~, ~, file_ext] = fileparts(source);
        if ~strcmpi(file_ext, 'sqw')
            ldr = sqw_formats_factory.instance().get_loader(source);
            if ~ldr.sqw_type
                error('HORACE:cut_sqw', ...
                      'Cannot perform cut_sqw, ''%s'' is not a valid SQW file.', ...
                      source);
            end
            ldr.delete();
        end
    else
        error('HORACE:cut_sqw', ...
              'Cannot perform cut_sqw, expected sqw type, found ''%s''.', ...
              class(source));
    end
end

wout = cut(source, varargin{:});
