import pefile, hashlib, struct, sys, os

ORIG_SHA = "656f4f482ed698958e1108938f7e5baff5b5dd31b3b310a7ea51386faca635d8"
EXPECTED_V5 = None  # accept any valid state; compute below
SRC = "CK2game333.exe"
OUT = "CK2game333_v6_test.exe"

data = bytearray(open(SRC,"rb").read())
assert hashlib.sha256(data).hexdigest()==ORIG_SHA, "not exact original"

pe = pefile.PE(SRC, fast_load=True)
ib = pe.OPTIONAL_HEADER.ImageBase
fa = pe.OPTIONAL_HEADER.FileAlignment
sa = pe.OPTIONAL_HEADER.SectionAlignment
nsec = pe.FILE_HEADER.NumberOfSections

# ---- 1. sanity: the read case must still be original ----
off_case = 0x7818ae
assert data[off_case:off_case+6]==bytes.fromhex("0f8412090000"), data[off_case:off_case+6].hex()

# ---- 2. build trampoline (position-independent) ----
JMP_EPILOGUE = struct.pack("<i", 0x140782dc6 - 0)  # patched after section VA known
# We'll assemble then patch the jmp displacement.
def rip_call(target_va, next_va):
    return b'\xe8'+struct.pack("<i", target_va-(next_va+5))
# reserve placeholder; fill after cave VA known
tramp_pre = bytes([
    0x41,0x57,             # push r15
    0x41,0x56,             # push r14
    0x41,0x55,             # push r13
    0x53,                  # push rbx
    0x56,                  # push rsi
    0x57,                  # push rdi
    0x55,                  # push rbp
])
# After 7 pushes (48 bytes) including ret addr, RSP is 16-aligned at next call.
tramp_body_template = [
    ('sub_rsp_38', b'\x48\x83\xec\x38'),          # sub rsp,0x38
    # ctx.vector = &[r13+0x138]
    ('lea_rcx', None),                            # lea rcx,[r13+0x138] -> 4C 8D 6D 38? actually r13: 49 8D 6D 38? r13=4D, modrm
    ('mov_rsp28', b'\x48\x89\x4c\x24\x28'),       # mov [rsp+0x28],rcx
    ('lea_rcx2', b'\x48\x8d\x49\x10'),            # lea rcx,[rcx+0x10]  (begin = vector._Mylast? Actually vector layout: begin,end,end_cap. The dead code reads [rbx+8]=begin,[rbx+10]=end)
    ('mov_rsp30', b'\x48\x89\x4c\x24\x30'),       # mov [rsp+0x30],rcx (begin)
    ('lea_rdx', b'\x48\x83\xc1\x08'),             # add rcx,8 (end)
    ('mov_rsp38', b'\x48\x89\x4c\x24\x38'),       # mov [rsp+38],rcx (end)
    ('mov_rdx_node', b'\x48\x8b\xd1'),            # mov rdx,rcx? NO, need rdx=node (which is current node). We need to keep rcx (the read case) — but we overwrote it. Use r12? save node earlier.
]
# We need the current archive node in rdx for 0x140d75fd8. At read case, rcx=current node. Save it in a callee-saved register (r12) at start.
# Let's just write manually and carefully.

