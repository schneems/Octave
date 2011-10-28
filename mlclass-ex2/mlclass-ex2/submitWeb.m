function submitWeb(partId)
%SUBMITWEB Generates a base64 encoded string for web-based submissions
%   SUBMITWEB() will generate a base64 encoded string so that you can submit your
%   solutions via a web form

  fprintf('==\n== [ml-class] Submitting Solutions | Programming Exercise %s\n==\n', ...
          homework_id());
  if ~exist('partId', 'var') || isempty(partId)
    partId = promptPart();
  end
  
  % Check valid partId
  partNames = validParts();
  if ~isValidPartId(partId)
    fprintf('!! Invalid homework part selected.\n');
    fprintf('!! Expected an integer from 1 to %d.\n', numel(partNames));
    fprintf('!! Submission Cancelled\n');
    return
  end

  [login] = loginPrompt();
  if isempty(login)
    fprintf('!! Submission Cancelled\n');
    return
  end
  
  [result] = submitSolution(login, partId, output(partId), ...
                            source(partId));
  result = base64encode(result);

  fprintf('\nSave as submission file [submit_ex%s_part%d.txt]: ', ...
          homework_id(), partId);
  saveAsFile = input('', 's');
  if (isempty(saveAsFile))
    saveAsFile = sprintf('submit_ex%s_part%d.txt', homework_id(), partId);
  end

  fid = fopen(saveAsFile, 'w');
  if (fid)
    fwrite(fid, result);
    fclose(fid);
    fprintf('\nSaved your solutions to %s.\n\n', saveAsFile);
    fprintf(['You can now submit your solutions through the web \n' ...
             'form in the programming exercises. Select the corresponding \n' ...
             'programming exercise to access the form.\n']);

  else
    fprintf('Unable to save to %s\n\n', saveAsFile);
    fprintf(['You can create a submission file by saving the \n' ...
             'following text in a file: (press enter to continue)\n\n']);
    pause;
    fprintf(result);
  end                  

end

% ================== CONFIGURABLES FOR EACH HOMEWORK ==================

function id = homework_id() 
  id = '2';
end

function [partNames] = validParts()
  partNames = { 'Sigmoid Function ', ...
                'Logistic Regression Cost', ...
                'Logistic Regression Gradient', ...
                'Predict', ...
                'Regularized Logistic Regression Cost' ...
                'Regularized Logistic Regression Gradient' ...
                };
end

function srcs = sources()
  % Separated by part
  srcs = { { 'sigmoid.m' }, ...
           { 'costFunction.m' }, ...
           { 'costFunction.m' }, ...
           { 'predict.m' }, ...
           { 'costFunctionReg.m' }, ...
           { 'costFunctionReg.m' } };
end

function out = output(partId)
  % Random Test Cases
  X = [ones(20,1) (exp(1) * sin(1:1:20))' (exp(0.5) * cos(1:1:20))'];
  y = sin(X(:,1) + X(:,2)) > 0;
  if partId == 1
    out = sprintf('%0.5f ', sigmoid(X));
  elseif partId == 2
    out = sprintf('%0.5f ', costFunction([0.25 0.5 -0.5]', X, y));
  elseif partId == 3
    [cost, grad] = costFunction([0.25 0.5 -0.5]', X, y);
    out = sprintf('%0.5f ', grad);
  elseif partId == 4
    out = sprintf('%0.5f ', predict([0.25 0.5 -0.5]', X));
  elseif partId == 5
    out = sprintf('%0.5f ', costFunctionReg([0.25 0.5 -0.5]', X, y, 0.1));
  elseif partId == 6
    [cost, grad] = costFunctionReg([0.25 0.5 -0.5]', X, y, 0.1);
    out = sprintf('%0.5f ', grad);
  end 
end


% ========================= SUBMIT HELPERS =========================

function src = source(partId)
  src = '';
  src_files = sources();
  if partId <= numel(src_files)
      flist = src_files{partId};
      for i = 1:numel(flist)
          fid = fopen(flist{i});
          while ~feof(fid)
            line = fgets(fid);
            src = [src line];
          end
          fclose(fid);
          src = [src '||||||||'];
      end
  end
end

function ret = isValidPartId(partId)
  partNames = validParts();
  ret = (~isempty(partId)) && (partId >= 1) && (partId <= numel(partNames));
end

function partId = promptPart()
  fprintf('== Select which part(s) to submit:\n', ...
          homework_id());
  partNames = validParts();
  srcFiles = sources();
  for i = 1:numel(partNames)
    fprintf('==   %d) %s [', i, partNames{i});
    fprintf(' %s ', srcFiles{i}{:});
    fprintf(']\n');
  end
  fprintf('\nEnter your choice [1-%d]: ', ...
          numel(partNames));
  selPart = input('', 's');
  partId = str2num(selPart);
  if ~isValidPartId(partId)
    partId = -1;
  end
end


function [result, str] = submitSolution(email, part, output, source)

  result = ['a:5:{' ...
            p_s('homework') p_s64(homework_id()) ...
            p_s('part') p_s64(part) ...
            p_s('email') p_s64(email) ...
            p_s('output') p_s64(output) ...
            p_s('source') p_s64(source) ...
            '}'];

end

function s = p_s(str)
   s = ['s:' num2str(numel(str)) ':"' str '";'];
end

function s = p_s64(str)
   str = base64encode(str, '');
   s = ['s:' num2str(numel(str)) ':"' str '";'];
end

% =========================== LOGIN HELPERS ===========================

function [login] = loginPrompt()
  % Prompt for password
  [login] = basicPrompt();
end


function [login] = basicPrompt()
  login = input('Login (Email address): ', 's');
end


% =========================== Base64 Encoder ============================
% Thanks to Peter John Acklam
%

function y = base64encode(x, eol)
%BASE64ENCODE Perform base64 encoding on a string.
%
%   BASE64ENCODE(STR, EOL) encode the given string STR.  EOL is the line ending
%   sequence to use; it is optional and defaults to '\n' (ASCII decimal 10).
%   The returned encoded string is broken into lines of no more than 76
%   characters each, and each line will end with EOL unless it is empty.  Let
%   EOL be empty if you do not want the encoded string broken into lines.
%
%   STR and EOL don't have to be strings (i.e., char arrays).  The only
%   requirement is that they are vectors containing values in the range 0-255.
%
%   This function may be used to encode strings into the Base64 encoding
%   specified in RFC 2045 - MIME (Multipurpose Internet Mail Extensions).  The
%   Base64 encoding is designed to represent arbitrary sequences of octets in a
%   form that need not be humanly readable.  A 65-character subset
%   ([A-Za-z0-9+/=]) of US-ASCII is used, enabling 6 bits to be represented per
%   printable character.
%
%   Examples
%   --------
%
%   If you want to encode a large file, you should encode it in chunks that are
%   a multiple of 57 bytes.  This ensures that the base64 lines line up and
%   that you do not end up with padding in the middle.  57 bytes of data fills
%   one complete base64 line (76 == 57*4/3):
%
%   If ifid and ofid are two file identifiers opened for reading and writing,
%   respectively, then you can base64 encode the data with
%
%      while ~feof(ifid)
%         fwrite(ofid, base64encode(fread(ifid, 60*57)));
%      end
%
%   or, if you have enough memory,
%
%      fwrite(ofid, base64encode(fread(ifid)));
%
%   See also BASE64DECODE.

%   Author:      Peter John Acklam
%   Time-stamp:  2004-02-03 21:36:56 +0100
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   if isnumeric(x)
      x = num2str(x);
   end

   % make sure we have the EOL value
   if nargin < 2
      eol = sprintf('\n');
   else
      if sum(size(eol) > 1) > 1
         error('EOL must be a vector.');
      end
      if any(eol(:) > 255)
         error('EOL can not contain values larger than 255.');
      end
   end

   if sum(size(x) > 1) > 1
      error('STR must be a vector.');
   end

   x   = uint8(x);
   eol = uint8(eol);

   ndbytes = length(x);                 % number of decoded bytes
   nchunks = ceil(ndbytes / 3);         % number of chunks/groups
   nebytes = 4 * nchunks;               % number of encoded bytes

   % add padding if necessary, to make the length of x a multiple of 3
   if rem(ndbytes, 3)
      x(end+1 : 3*nchunks) = 0;
   end

   x = reshape(x, [3, nchunks]);        % reshape the data
   y = repmat(uint8(0), 4, nchunks);    % for the encoded data

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Split up every 3 bytes into 4 pieces
   %
   %    aaaaaabb bbbbcccc ccdddddd
   %
   % to form
   %
   %    00aaaaaa 00bbbbbb 00cccccc 00dddddd
   %
   y(1,:) = bitshift(x(1,:), -2);                  % 6 highest bits of x(1,:)

   y(2,:) = bitshift(bitand(x(1,:), 3), 4);        % 2 lowest bits of x(1,:)
   y(2,:) = bitor(y(2,:), bitshift(x(2,:), -4));   % 4 highest bits of x(2,:)

   y(3,:) = bitshift(bitand(x(2,:), 15), 2);       % 4 lowest bits of x(2,:)
   y(3,:) = bitor(y(3,:), bitshift(x(3,:), -6));   % 2 highest bits of x(3,:)

   y(4,:) = bitand(x(3,:), 63);                    % 6 lowest bits of x(3,:)

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Now perform the following mapping
   %
   %   0  - 25  ->  A-Z
   %   26 - 51  ->  a-z
   %   52 - 61  ->  0-9
   %   62       ->  +
   %   63       ->  /
   %
   % We could use a mapping vector like
   %
   %   ['A':'Z', 'a':'z', '0':'9', '+/']
   %
   % but that would require an index vector of class double.
   %
   z = repmat(uint8(0), size(y));
   i =           y <= 25;  z(i) = 'A'      + double(y(i));
   i = 26 <= y & y <= 51;  z(i) = 'a' - 26 + double(y(i));
   i = 52 <= y & y <= 61;  z(i) = '0' - 52 + double(y(i));
   i =           y == 62;  z(i) = '+';
   i =           y == 63;  z(i) = '/';
   y = z;

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Add padding if necessary.
   %
   npbytes = 3 * nchunks - ndbytes;     % number of padding bytes
   if npbytes
      y(end-npbytes+1 : end) = '=';     % '=' is used for padding
   end

   if isempty(eol)

      % reshape to a row vector
      y = reshape(y, [1, nebytes]);

   else

      nlines = ceil(nebytes / 76);      % number of lines
      neolbytes = length(eol);          % number of bytes in eol string

      % pad data so it becomes a multiple of 76 elements
      y = [y(:) ; zeros(76 * nlines - numel(y), 1)];
      y(nebytes + 1 : 76 * nlines) = 0;
      y = reshape(y, 76, nlines);

      % insert eol strings
      eol = eol(:);
      y(end + 1 : end + neolbytes, :) = eol(:, ones(1, nlines));

      % remove padding, but keep the last eol string
      m = nebytes + neolbytes * (nlines - 1);
      n = (76+neolbytes)*nlines - neolbytes;
      y(m+1 : n) = '';

      % extract and reshape to row vector
      y = reshape(y, 1, m+neolbytes);

   end

   % output is a character array
   y = char(y);

end
