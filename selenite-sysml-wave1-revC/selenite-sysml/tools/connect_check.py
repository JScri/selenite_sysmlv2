"""connect_check.py - resolve every connect / bind / allocate / flow endpoint
path in the model through the definition and usage tree.

Wave 4B (7 Nov 2026, W4B-N2): sysml-validate 0.36.0 accepts an unresolved
feature chain in a connect, bind, allocate or flow statement silently (the
configuration validated at zero hints with two ports that did not exist), so
this check walks the paths itself: definitions with their inherited members,
usage blocks with their local members and nested usages, '~' conjugation and
'::' qualification stripped. Exit 0 when every endpoint resolves, 1 otherwise.

Usage: python tools/connect_check.py [model_dir]   (default: ../model)
"""
import re, sys, pathlib
base = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else pathlib.Path(__file__).resolve().parent.parent / "model"

def strip(t):
    t = re.sub(r"\bdoc(\s+\w+)?\s*/\*.*?\*/", "", t, flags=re.S)
    t = re.sub(r"/\*.*?\*/", "", t, flags=re.S)
    return re.sub(r"//[^\n]*", "", t)

# join continuation lines so every statement is one line
def logical_lines(t):
    out, buf = [], ""
    for raw in t.splitlines():
        s = raw.strip()
        if not s: continue
        buf = (buf + " " + s).strip() if buf else s
        if s.endswith(";") or s.endswith("{") or s.endswith("}"):
            out.append(buf); buf = ""
    if buf: out.append(buf)
    return out

class Block:
    def __init__(self, header): self.header=header; self.stmts=[]; self.children=[]
def parse(lines):
    root = Block("<root>"); stack=[root]
    for l in lines:
        opens, closes = l.count("{"), l.count("}")
        if l.endswith("{") and opens > closes:
            b = Block(l[:-1].strip()); stack[-1].children.append(b); stack.append(b)
        elif l == "}":
            stack.pop()
        elif l.endswith("}") and closes > opens:
            stack[-1].stmts.append(l[:-1].strip()); stack.pop()
        else:
            stack[-1].stmts.append(l)
    return root

DEF = re.compile(r"^(?:abstract\s+)?(?:variation\s+)?(part|action|state|port|interface|item|attribute|enum|requirement|calc|analysis)\s+def\s+(?:<'[^']*'>\s+)?(\w+)(?:\s*:>\s*([\w:,\s]+?))?$")
MEM = re.compile(r"^(?:abstract\s+)?(?:variant\s+)?(?:(part|port|item|attribute|action|interface|state|requirement|calc|analysis|end|in item|out item|in|out|perform action|exhibit state|ref part|ref)\s+)(?:redefines\s+|:>>\s+)?(\w+)(?:\s*\[[^\]]*\])?(?:\s*:\s*(~?[\w:]+))?")

defs = {}
def collect_defs(block):
    for c in block.children:
        m = DEF.match(c.header)
        if m:
            defs[m.group(2)] = dict(parents=[p.strip().split("::")[-1] for p in (m.group(3) or "").split(",") if p.strip()], block=c)
        collect_defs(c)

files = {p.name: parse(logical_lines(strip(p.read_text()))) for p in sorted(base.glob("*.sysml"))}
for root in files.values(): collect_defs(root)

def direct_members(block):
    """name -> (type or None, child block or None)"""
    m = {}
    for s in block.stmts:
        mm = MEM.match(s)
        if mm: m[mm.group(2)] = (mm.group(3).replace("~","").split("::")[-1] if mm.group(3) else None, None)
    for c in block.children:
        mm = MEM.match(c.header)
        if mm and not DEF.match(c.header):
            m[mm.group(2)] = (mm.group(3).replace("~","").split("::")[-1] if mm.group(3) else None, c)
    return m

def type_members(typ, seen=None):
    seen = seen or set()
    if not typ or typ in seen or typ not in defs: return {}
    seen.add(typ); out = {}
    for p in defs[typ]["parents"]: out.update(type_members(p, seen))
    out.update(direct_members(defs[typ]["block"]))
    return out

def context_members(typ, block):
    out = dict(type_members(typ))
    if block:
        for k,(t,c) in direct_members(block).items():
            if t is None and k in out: t = out[k][0]
            out[k] = (t, c)
    return out

def resolve(path, typ, block, where):
    segs = path.split(".")
    members = context_members(typ, block)
    for i,s in enumerate(segs):
        if s not in members:
            return f"{where}: '{path}' - '{s}' not found in {typ or 'usage'}"
        t, c = members[s]
        if i == len(segs)-1: return None
        if t is None:
            return f"{where}: '{path}' - '{s}' has no type to descend"
        members = context_members(t, c)
    return None

PATHS = [re.compile(r"\bconnect\s+([\w.]+)\s+to\s+([\w.]+)"), re.compile(r"\bbind\s+([\w.]+)\s*=\s*([\w.]+)"),
         re.compile(r"\ballocate\s+([\w.]+)\s+to\s+([\w.]+)"), re.compile(r"\bflow\s+([\w.]+)\s+to\s+([\w.]+)")]
errors = []; count = 0
def walk(block, typ, where):
    global count
    for s in block.stmts + [c.header for c in block.children]:
        for rx in PATHS:
            for m in rx.finditer(s):
                for g in (1,2):
                    count += 1
                    e = resolve(m.group(g), typ, block, where)
                    if e: errors.append(e)
    for c in block.children:
        dm = DEF.match(c.header)
        if dm:
            walk(c, dm.group(2), dm.group(2)); continue
        mm = MEM.match(c.header)
        ctype = None
        if mm:
            ctype = mm.group(3).replace("~","").split("::")[-1] if mm.group(3) else context_members(typ, block).get(mm.group(2), (None,None))[0]
            walk(c, ctype, f"{where}.{mm.group(2)}")
        else:
            walk(c, typ, where)
for name, root in files.items():
    walk(root, None, name)
print(f"{count} endpoints checked, {len(errors)} unresolved")
for e in errors: print("  ", e)
sys.exit(1 if errors else 0)
