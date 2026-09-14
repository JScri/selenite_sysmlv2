function s = ternary(cond, a, b)
%TERNARY  Hoisted from the script-local definition (Octave compatibility).
  if cond, s = a; else, s = b; end
end
