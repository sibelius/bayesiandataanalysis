function processed = preprocess(str)
    str = lower(str);                         % tolower
    str = regexprep(str, '&(.|\n)*?;', '');     % Remove &lt; Html entities 
    str = regexprep(str, '<(.|\n)*?>', '');     % Remove HTML tokens

    % Save C++ and C#
    str = regexprep(str, 'c\+\+', 'CXX');
    str = regexprep(str, 'c\#', 'CT');

    str = regexprep(str, '[^a-z ]', '');         % Remove Numbers and Punctuation
    
    % Restore C++ and C#
    regexprep(str, 'C#', 'c++');
    regexprep(str, 'CT', 'c#');

    regRemoveStopWords = sprintf('\\<(%s)\\>', getStopWords());
    %regRemoveStopWords = sprintf('\\<(%s)\\>', strjoin(getStopWords(), '|'));
    str = regexprep(str, regRemoveStopWords, ''); % Remove Stop Words
    
    str = regexprep(str, ' +', ' ');            % Strip whitespaces
    str = strtrim(str);                         % Remove any possible initial or final spaces

    processed = str;
end
