vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

nnoremap <expr><unique> m* bulletList#unordered()
nnoremap <expr><unique> m** bulletList#unordered() .. '_'
xnoremap <expr><unique> m* bulletList#unordered()

nnoremap <expr><unique> m# bulletList#ordered()
nnoremap <expr><unique> m## bulletList#ordered() .. '_'
xnoremap <expr><unique> m# bulletList#ordered()
