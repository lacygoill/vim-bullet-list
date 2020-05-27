if exists('g:loaded_bullet_list')
    finish
endif
let g:loaded_bullet_list = 1

nno <expr><unique> m* bullet_list#unordered()
nno <expr><unique> m** bullet_list#unordered()..'_'
xno <expr><unique> m* bullet_list#unordered()

nno <expr><unique> m# bullet_list#ordered()
nno <expr><unique> m## bullet_list#ordered()..'_'
xno <expr><unique> m# bullet_list#ordered()
