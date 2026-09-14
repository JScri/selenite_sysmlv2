function varargout = hold(varargin)
%%hold  No-op graphics shim for headless Octave golden capture.
  h = 1; % numeric placeholder handle
  if nargout > 0, varargout = repmat({h}, 1, nargout); end
end
