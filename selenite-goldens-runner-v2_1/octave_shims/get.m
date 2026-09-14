function varargout = get(varargin)
%GET  Headless shim: root object (0) passes through to the builtin
%  so appdata works; everything else is a no-op (figure handles are fake).
  if nargin >= 1 && isnumeric(varargin{1}) && isscalar(varargin{1}) && varargin{1} == 0
    [varargout{1:max(nargout,0)}] = builtin('get', varargin{:});
  elseif nargout > 0
    varargout = repmat({[]}, 1, nargout);
  end
end
