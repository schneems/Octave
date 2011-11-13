function submit(partId)
%SUBMIT Submit your code and output to the ml-class servers
%   SUBMIT() will connect to the ml-class server and submit your solution

  fprintf('==\n== [ml-class] Submitting Solutions | Programming Exercise %s\n==\n', ...
          homework_id());
  if ~exist('partId', 'var') || isempty(partId)
    partId = promptPart();
  end
  
  % Check valid partId
  partNames = validParts();
  if ~isValidPartId(partId)
    fprintf('!! Invalid homework part selected.\n');
    fprintf('!! Expected an integer from 1 to %d.\n', numel(partNames) + 1);
    fprintf('!! Submission Cancelled\n');
    return
  end

  [login password] = loginPrompt();
  if isempty(login)
    fprintf('!! Submission Cancelled\n');
    return
  end

  fprintf('\n== Connecting to ml-class ... '); 
  if exist('OCTAVE_VERSION') 
    fflush(stdout);
  end
  
  % Setup submit list
  if partId == numel(partNames) + 1
    submitParts = 1:numel(partNames);
  else
    submitParts = [partId];
  end

  for s = 1:numel(submitParts)
    % Submit this part
    partId = submitParts(s);
    
    % Get Challenge
    [login, ch, signature] = getChallenge(login);
    if isempty(login) || isempty(ch) || isempty(signature)
      % Some error occured, error string in first return element.
      fprintf('\n!! Error: %s\n\n', login);
      return
    end
  
    % Attempt Submission with Challenge
    ch_resp = challengeResponse(login, password, ch);
    [result, str] = submitSolution(login, ch_resp, partId, output(partId), ...
                                 source(partId), signature);
                                 
    fprintf('\n== [ml-class] Submitted Homework %s - Part %d - %s\n', ...
            homework_id(), partId, partNames{partId});
    fprintf('== %s\n', strtrim(str));
    if exist('OCTAVE_VERSION') 
      fflush(stdout);
    end
  end
  
end

% ================== CONFIGURABLES FOR EACH HOMEWORK ==================

function id = homework_id() 
  id = '4';
end

function [partNames] = validParts()
  partNames = { 'Feedforward and Cost Function', ...
                'Regularized Cost Function', ...
                'Sigmoid Gradient', ...
                'Neural Network Gradient (Backpropagation)' ...
                'Regularized Gradient' ...
                };
end

function srcs = sources()
  % Separated by part
  srcs = { { 'nnCostFunction.m' }, ...
           { 'nnCostFunction.m' }, ...
           { 'sigmoidGradient.m' }, ...
           { 'nnCostFunction.m' }, ...
           { 'nnCostFunction.m' } };
end

function out = output(partId)
  % Random Test Cases
  X = reshape(3 * sin(1:1:30), 3, 10);
  Xm = reshape(sin(1:32), 16, 2) / 5;
  ym = 1 + mod(1:16,4)';
  t1 = sin(reshape(1:2:24, 4, 3));
  t2 = cos(reshape(1:2:40, 4, 5));
  t  = [t1(:) ; t2(:)];
  if partId == 1
    [J] = nnCostFunction(t, 2, 4, 4, Xm, ym, 0);
    out = sprintf('%0.5f ', J);
  elseif partId == 2
    [J] = nnCostFunction(t, 2, 4, 4, Xm, ym, 1.5);
    out = sprintf('%0.5f ', J);
  elseif partId == 3
    out = sprintf('%0.5f ', sigmoidGradient(X));
  elseif partId == 4
    [J, grad] = nnCostFunction(t, 2, 4, 4, Xm, ym, 0);
    out = sprintf('%0.5f ', J);
    out = [out sprintf('%0.5f ', grad)];
  elseif partId == 5
    [J, grad] = nnCostFunction(t, 2, 4, 4, Xm, ym, 1.5);
    out = sprintf('%0.5f ', J);
    out = [out sprintf('%0.5f ', grad)];
  end 
end

function url = challenge_url()
  url = 'http://www.ml-class.org/course/homework/challenge';
end

function url = submit_url()
  url = 'http://www.ml-class.org/course/homework/submit';
end

% ========================= CHALLENGE HELPERS =========================

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
  ret = (~isempty(partId)) && (partId >= 1) && (partId <= numel(partNames) + 1);
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
  fprintf('==   %d) All of the above \n==\nEnter your choice [1-%d]: ', ...
          numel(partNames) + 1, numel(partNames) + 1);
  selPart = input('', 's');
  partId = str2num(selPart);
  if ~isValidPartId(partId)
    partId = -1;
  end
end

function [email,ch,signature] = getChallenge(email)
  str = urlread(challenge_url(), 'post', {'email_address', email});

  str = strtrim(str);
  [email, str] = strtok (str, '|');
  [ch, str] = strtok (str, '|');
  [signature, str] = strtok (str, '|');
end


function [result, str] = submitSolution(email, ch_resp, part, output, ...
                                        source, signature)

  params = {'homework', homework_id(), ...
            'part', num2str(part), ...
            'email', email, ...
            'output', output, ...
            'source', source, ...
            'challenge_response', ch_resp, ...
            'signature', signature};

  str = urlread(submit_url(), 'post', params);
  
  % Parse str to read for success / failure
  result = 0;

end

% =========================== LOGIN HELPERS ===========================

function [login password] = loginPrompt()
  % Prompt for password
  [login password] = basicPrompt();
  
  if isempty(login) || isempty(password)
    login = []; password = [];
  end
end


function [login password] = basicPrompt()
  login = input('Login (Email address): ', 's');
  password = input('Password: ', 's');
end


function [str] = challengeResponse(email, passwd, challenge)
  salt = ')~/|]QMB3[!W`?OVt7qC"@+}';
  str = sha1([challenge sha1([salt email passwd])]);
  sel = randperm(numel(str));
  sel = sort(sel(1:16));
  str = str(sel);
end


% =============================== SHA-1 ================================

function hash = sha1(str)
  
  % Initialize variables
  h0 = uint32(1732584193);
  h1 = uint32(4023233417);
  h2 = uint32(2562383102);
  h3 = uint32(271733878);
  h4 = uint32(3285377520);
  
  % Convert to word array
  strlen = numel(str);

  % Break string into chars and append the bit 1 to the message
  mC = [double(str) 128];
  mC = [mC zeros(1, 4-mod(numel(mC), 4), 'uint8')];
  
  numB = strlen * 8;
  if exist('idivide')
    numC = idivide(uint32(numB + 65), 512, 'ceil');
  else
    numC = ceil(double(numB + 65)/512);
  end
  numW = numC * 16;
  mW = zeros(numW, 1, 'uint32');
  
  idx = 1;
  for i = 1:4:strlen + 1
    mW(idx) = bitor(bitor(bitor( ...
                  bitshift(uint32(mC(i)), 24), ...
                  bitshift(uint32(mC(i+1)), 16)), ...
                  bitshift(uint32(mC(i+2)), 8)), ...
                  uint32(mC(i+3)));
    idx = idx + 1;
  end
  
  % Append length of message
  mW(numW - 1) = uint32(bitshift(uint64(numB), -32));
  mW(numW) = uint32(bitshift(bitshift(uint64(numB), 32), -32));

  % Process the message in successive 512-bit chs
  for cId = 1 : double(numC)
    cSt = (cId - 1) * 16 + 1;
    cEnd = cId * 16;
    ch = mW(cSt : cEnd);
    
    % Extend the sixteen 32-bit words into eighty 32-bit words
    for j = 17 : 80
      ch(j) = ch(j - 3);
      ch(j) = bitxor(ch(j), ch(j - 8));
      ch(j) = bitxor(ch(j), ch(j - 14));
      ch(j) = bitxor(ch(j), ch(j - 16));
      ch(j) = bitrotate(ch(j), 1);
    end
  
    % Initialize hash value for this ch
    a = h0;
    b = h1;
    c = h2;
    d = h3;
    e = h4;
    
    % Main loop
    for i = 1 : 80
      if(i >= 1 && i <= 20)
        f = bitor(bitand(b, c), bitand(bitcmp(b), d));
        k = uint32(1518500249);
      elseif(i >= 21 && i <= 40)
        f = bitxor(bitxor(b, c), d);
        k = uint32(1859775393);
      elseif(i >= 41 && i <= 60)
        f = bitor(bitor(bitand(b, c), bitand(b, d)), bitand(c, d));
        k = uint32(2400959708);
      elseif(i >= 61 && i <= 80)
        f = bitxor(bitxor(b, c), d);
        k = uint32(3395469782);
      end
      
      t = bitrotate(a, 5);
      t = bitadd(t, f);
      t = bitadd(t, e);
      t = bitadd(t, k);
      t = bitadd(t, ch(i));
      e = d;
      d = c;
      c = bitrotate(b, 30);
      b = a;
      a = t;
      
    end
    h0 = bitadd(h0, a);
    h1 = bitadd(h1, b);
    h2 = bitadd(h2, c);
    h3 = bitadd(h3, d);
    h4 = bitadd(h4, e);

  end

  hash = reshape(dec2hex(double([h0 h1 h2 h3 h4]), 8)', [1 40]);
  
  hash = lower(hash);

end

function ret = bitadd(iA, iB)
  ret = double(iA) + double(iB);
  ret = bitset(ret, 33, 0);
  ret = uint32(ret);
end

function ret = bitrotate(iA, places)
  t = bitshift(iA, places - 32);
  ret = bitshift(iA, places);
  ret = bitor(ret, t);
end
