function status = gold_run_chain(chain, outdir, maxFull)
%GOLD_RUN_CHAIN  Run a chain of scripts in one shared workspace and capture.
%  Helper for RUN_GOLDENS.m. Keep this file in the same folder.
% Runs the chain in THIS function's workspace so the scripts' own
% `clear; clc; close all` cannot damage the caller. State that must
% survive `clear` lives in root appdata, never in local variables.
    setappdata(0, 'GOLD_STATE', struct('chain', {chain}, 'idx', 1, ...
        'outdir', outdir, 'maxFull', maxFull, 'status', {{}}));
    while true
        GOLD_s = getappdata(0, 'GOLD_STATE');
        if GOLD_s.idx > numel(GOLD_s.chain), break; end
        GOLD_f = GOLD_s.chain{GOLD_s.idx};
        try
            % Run inside evalc so partial console output survives a failure.
            GOLD_txt = evalc(['try, run(GOLD_f); catch GOLD_ME, ' ...
                              'setappdata(0,''GOLD_ERR'',GOLD_ME); end']);
            GOLD_s   = getappdata(0, 'GOLD_STATE');
            if isappdata(0, 'GOLD_ERR')
                GOLD_ME = getappdata(0, 'GOLD_ERR'); rmappdata(0, 'GOLD_ERR');
                [~, GOLD_b] = fileparts(GOLD_s.chain{GOLD_s.idx});
                gold_write_text(fullfile(GOLD_s.outdir, ['console_' GOLD_b '.txt']), GOLD_txt);
                rethrow(GOLD_ME);
            end
            GOLD_e   = gold_entry(GOLD_s.chain{GOLD_s.idx});   % rebuilt post-clear
            GOLD_cap = gold_capture();           % everything the script left behind
            GOLD_fl  = gold_flatten(GOLD_cap, '', GOLD_s.maxFull);
            [~, GOLD_b] = fileparts(GOLD_s.chain{GOLD_s.idx});
            gold_write_text(fullfile(GOLD_s.outdir, [GOLD_b '.json']), jsonencode(GOLD_cap));
            gold_write_csv (fullfile(GOLD_s.outdir, [GOLD_b '.csv']),  GOLD_fl);
            gold_write_text(fullfile(GOLD_s.outdir, ['console_' GOLD_b '.txt']), GOLD_txt);
            GOLD_e.status   = 'ok';
            GOLD_e.n_values = numel(fieldnames(GOLD_fl));
            GOLD_e.chain_position = GOLD_s.idx;
            GOLD_s.status{end+1} = GOLD_e;
            GOLD_s.idx = GOLD_s.idx + 1;
            setappdata(0, 'GOLD_STATE', GOLD_s);
        catch ME
            GOLD_s = getappdata(0, 'GOLD_STATE');
            GOLD_e = gold_entry(GOLD_s.chain{GOLD_s.idx});
            GOLD_e.status  = 'FAILED';
            GOLD_e.message = ME.message;
            GOLD_s.status{end+1} = GOLD_e;
            % Later members of a chain depend on this one: stop the chain.
            for GOLD_r = GOLD_s.idx+1:numel(GOLD_s.chain)
                GOLD_s.status{end+1} = struct('file', GOLD_s.chain{GOLD_r}, ...
                    'status', 'FAILED', 'message', 'skipped: earlier chain member failed');
            end
            setappdata(0, 'GOLD_STATE', GOLD_s);
            break
        end
    end
    GOLD_s = getappdata(0, 'GOLD_STATE');
    status = GOLD_s.status;
    rmappdata(0, 'GOLD_STATE');
end

function e = gold_entry(f)
    e = struct('file', f, 'bytes', gold_bytes(f), 'sha256', gold_sha256(f));
end

function cap = gold_capture()
% Snapshot the CALLER's workspace (the chain runner) minus harness locals.
    names = evalin('caller', 'who');
    cap = struct();
    for k = 1:numel(names)
        nm = names{k};
        if strncmp(nm, 'GOLD_', 5), continue; end
        v = evalin('caller', nm);
        if gold_keep(v), cap.(nm) = gold_clean(v); end
    end
end

function tf = gold_keep(v)
    tf = false;
    if isa(v, 'function_handle'), return; end
    if isobject(v) && ~isstruct(v), return; end   % graphics objects, tables, etc.
    % NOTE: never call isgraphics() on numerics -- under MATLAB a plain number
    % equal to an open figure's handle (1..N) tests true and would be dropped.
    tf = isnumeric(v) || islogical(v) || ischar(v) || isstruct(v) || iscell(v);
end

function out = gold_clean(v)
    if isstruct(v)
        out = struct(); f = fieldnames(v);
        for k = 1:numel(f)
            if numel(v) ~= 1, out.(f{k}) = 'ARRAY_OF_STRUCTS_SKIPPED'; continue; end
            if gold_keep(v.(f{k})), out.(f{k}) = gold_clean(v.(f{k})); end
        end
    elseif iscell(v)
        out = {};
        for k = 1:numel(v)
            if gold_keep(v{k}), out{end+1} = gold_clean(v{k}); end %#ok<AGROW>
        end
    else
        out = v;
    end
end

function flat = gold_flatten(s, prefix, maxFull)
    flat = struct();
    if ~isstruct(s), return; end
    f = fieldnames(s);
    for k = 1:numel(f)
        key = f{k}; if ~isempty(prefix), key = [prefix '.' f{k}]; end
        v = s.(f{k});
        if isstruct(v)
            sub = gold_flatten(v, key, maxFull); sf = fieldnames(sub);
            for j = 1:numel(sf), flat.(sf{j}) = sub.(sf{j}); end
        elseif ischar(v)
            flat.(gold_safe(key)) = v;
        elseif isnumeric(v) || islogical(v)
            v = double(v);
            if isscalar(v)
                flat.(gold_safe(key)) = v;
            elseif numel(v) <= maxFull
                flat.(gold_safe(key)) = mat2str(v(:)', 12);
            else
                flat.(gold_safe([key '.numel'])) = numel(v);
                flat.(gold_safe([key '.sum']))   = sum(v(~isnan(v)));
                flat.(gold_safe([key '.min']))   = min(v(:));
                flat.(gold_safe([key '.max']))   = max(v(:));
                flat.(gold_safe([key '.mean']))  = mean(v(~isnan(v)));
            end
        end
    end
end

function k = gold_safe(k), k = strrep(k, '.', '__'); end

function gold_write_csv(path, flat)
    fid = fopen(path, 'w'); fprintf(fid, 'key,value\n');
    f = fieldnames(flat);
    for k = 1:numel(f)
        key = strrep(f{k}, '__', '.'); v = flat.(f{k});
        if ischar(v), fprintf(fid, '"%s","%s"\n', key, strrep(v, '"', '""'));
        else,         fprintf(fid, '"%s",%.12g\n', key, v); end
    end
    fclose(fid);
end

function gold_write_text(path, txt)
    fid = fopen(path, 'w'); fwrite(fid, txt, 'char'); fclose(fid);
end

function n = gold_bytes(path)
    d = dir(path); if isempty(d), n = -1; else, n = d.bytes; end
end

function h = gold_sha256(path)
    h = 'unavailable';
    try
        fid = fopen(path, 'r'); bytes = fread(fid, Inf, '*uint8'); fclose(fid);
        md = java.security.MessageDigest.getInstance('SHA-256'); md.update(bytes);
        h = lower(reshape(dec2hex(typecast(md.digest(), 'uint8'))', 1, []));
    catch
    end
end
