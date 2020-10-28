import {Catch, IsVim9} from 'lg.vim'

fu s:get_comment_patterns() abort "{{{1
    if s:IsVim9()
        return ['#\=\s*', '#\s*']
    endif

    let cml = matchstr(&l:cms, '\S*\ze\s*%s')
    if empty(cml) | return ['', ''] | endif

    " pattern describing 0 or 1 comment string followed by whitespace
    " pattern describing      1 comment string "
    return ['\V\%(' .. escape(cml, '\') .. '\)\=\m\s*',
        \ '\V' .. escape(cml, '\') .. '\m\s*']
endfu

fu bullet_list#ordered(...) abort "{{{1
    if !a:0
        let &opfunc = 'bullet_list#ordered'
        return 'g@'
    endif
    let [lnum1, lnum2] = [line("'["), line("']")]

    let [cmt, cmtt] = s:get_comment_patterns()
    "     │    │
    "     │    └ pattern describing 1 comment string + sequence of whitespace
    "     └ pattern describing 0 or 1 comment string + sequence of whitespace

    " If the lines are already prefixed by unordered list markers,
    " we want to change them with digits.
    if getline(lnum1) =~# '^\s*' .. cmt .. '[-*+]'

        " Why the `\s*` at the end of the pattern?
        " Because otherwise, when we switch from a bullet list to a digit
        " list, a space is added between the marker and the text.

        let pat = '^\s*' .. cmt .. '\zs[-*+]\s*'
        let rep = '\=c.". "'

        " If the lines are already prefixed with digits, we want to remove them.
        " This allows to toggle a numbered list.
    elseif getline(lnum1) =~# '^\s*' .. cmt .. '\d\+\s*\.'

        let pat = '^\s*' .. cmt .. '\zs\d\+\s*\.\s*'
        let rep = ''

        " Otherwise, the lines are unprefixed, so we want to prefix them with digits.
    else
        "                                                     ┌ ignore an empty commented line
        "                                                     ├────────────────────────┐
        let pat = '^\s*' .. cmt .. '\zs\ze' .. (!empty(cmt) ? '\%(' .. cmtt .. '\)\@!\S' : '')
        let rep = '\=c.". "'
    endif

    let update_index = 'let c = line(".") == line("'']") + 1 ? c+1 : 1'
    let cmd = 'keepj keepp %s,%s g/%s/' .. update_index .. '|keepj keepp s/%s/%s/e'

    let c = 0
    try
        sil exe printf(cmd, lnum1, lnum2, pat, pat, rep)
    catch
        return s:Catch()
    endtry
endfu

fu bullet_list#unordered(...) abort "{{{1
    if !a:0
        let &opfunc = 'bullet_list#unordered'
        return 'g@'
    endif
    let [lnum1, lnum2] = [line("'["), line("']")]

    let [cmt, cmtt] = s:get_comment_patterns()

    " if the lines are prefixed with digits, we want to replace them with markers
    if getline(lnum1) =~# '^\s*' .. cmt .. '\d\+\.'
        let pat = '^\s*' .. cmt .. '\zs\%(\d\+\.\s\+\)'
        let rep = '- '

        " if the lines are already prefixed with markers, remove them
    elseif getline(lnum1) =~# '^\s*' .. cmt .. '[-*+]'
        let pat = '^\s*' .. cmt .. '\zs[-*+]\s*'
        let rep = ''

        " otherwise, the lines are unprefixed, so we want to prefix them with markers
    else
        "                                                     ┌ ignore an empty commented line
        "                                                     ├────────────────────────┐
        let pat = '^\s*' .. cmt .. '\zs\ze' .. (!empty(cmt) ? '\%(' .. cmtt .. '\)\@!\S' : '')
        let rep = '- '
    endif

    let cmd = 'keepj keepp %s,%s s/%s/%s/e'

    try
        sil exe printf(cmd, lnum1, lnum2, pat, rep)
    catch
        return s:Catch()
    endtry
endfu
