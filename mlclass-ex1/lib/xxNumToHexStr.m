function hexStrOut = xxNumToHexStr(inChar)
%
% This is a cheesy hack to get around the bug in 
% sprintf("%x") in Octave 4.0.0. There must be a
% more native Octave way to do this, but this works.
% 
  switch (inChar)
    case ("1")
      hexStrOut = "31";
    case ("2")
      hexStrOut = "32";
    case ("3")
      hexStrOut = "33";
    case ("4")
      hexStrOut = "34";
    case ("5")
      hexStrOut = "35";
    case ("6")
      hexStrOut = "36";
    case ("7")
      hexStrOut = "37";
    case ("8")
      hexStrOut = "38";
    case ("9")
      hexStrOut = "39";
    otherwise
      hexStrOut = "xx";
  endswitch

end
