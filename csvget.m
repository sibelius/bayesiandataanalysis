function dataset = csvget(fname, header)
    delim = ',';
    % '\,(?=([^"]*"[^"]*")*[^"]*$)' - regular expression to match every comma expect the commas inside quotes
    fid = fopen(fname, 'r');

    if (nargin==1) || (header == true),
        line = fgetl(fid);
        csvheader = regexp(line, delim, 'split');
        csvheader = cellfun(@(x) regexprep(x, '"', ''), csvheader, 'UniformOutput', false); % Remove quote
    else
        csvheader = {};
    end

    expression = strcat('\', delim, '(?=([^"]*"[^"]*")*[^"]*$)'); % match every delim expect the delim inside quotes

    line = fgetl(fid);
    if ischar(line),
        csvdata = regexp(line, expression, 'split');
        csvdata = cellfun(@(x) regexprep(x, '"', ''), csvdata, 'UniformOutput', false); % Remove quote
        line = fgetl(fid);
    end
    while ischar(line),
        csvdata = [csvdata; regexp(line, expression, 'split')];
        csvdata = cellfun(@(x) regexprep(x, '"', ''), csvdata, 'UniformOutput', false); % Remove quote
        line = fgetl(fid);
    end
    fclose(fid);

    dataset.header = csvheader;
    dataset.data = csvdata;
end
