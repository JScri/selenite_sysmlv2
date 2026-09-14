function varargout = xlim(varargin)
%XLIM  Shim: returns a sane range when queried (headless Octave).
  if nargout > 0, varargout = repmat({[0 1]}, 1, nargout); end
end
