vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

nno <expr><unique> m* bullet_list#unordered()
nno <expr><unique> m** bullet_list#unordered() .. '_'
xno <expr><unique> m* bullet_list#unordered()

nno <expr><unique> m# bullet_list#ordered()
nno <expr><unique> m## bullet_list#ordered() .. '_'
xno <expr><unique> m# bullet_list#ordered()
