function varargout = axes(varargin)
%%axes  No-op graphics shim for headless Octave golden capture.
  if nargout > 0, varargout = repmat({[]}, 1, nargout); end
end
