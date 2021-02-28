vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

nno <expr><unique> m* bulletList#unordered()
nno <expr><unique> m** bulletList#unordered() .. '_'
xno <expr><unique> m* bulletList#unordered()

nno <expr><unique> m# bulletList#ordered()
nno <expr><unique> m## bulletList#ordered() .. '_'
xno <expr><unique> m# bulletList#ordered()
