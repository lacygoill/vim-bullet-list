" guard {{{1

if exists('g:auto_loaded_bullet_list')
    finish
endif
let g:auto_loaded_bullet_list = 1

fu! s:get_comment_patterns() abort "{{{1
    let cms = !empty(&cms)
           \?     split(&cms, '%s')[0]
           \:     ''

    " pattern describing 0 or 1 comment string followed by whitespace
    " pattern describing      1 comment string "
    return [ '\V\%('.escape(cms, '/\').'\)\?\v\s*',
           \ '\V\%('.escape(cms, '/\').'\)\v\s*' ]
endfu

fu! bullet_list#ordered(type) abort "{{{1
    if count([ 'v', 'V', "\<c-v>" ], a:type)
        let [ lnum1, lnum2 ] = [ line("'<"), line("'>") ]
    else
        let [ lnum1, lnum2 ] = [ line("'["), line("']") ]
    endif

    let [ cmt, cmtt ] = s:get_comment_patterns()
    "     │    │
    "     │    └─ pattern describing 1 comment string + sequence of whitespace
    "     └─ pattern describing 0 or 1 comment string + sequence of whitespace

    " If the lines are already prefixed by unordered list markers,
    " we want to change them with digits.
    if getline(lnum1) =~# '\v^\s*'.cmt.'[-*•]'

        " Why the `\s*` at the end of the pattern?
        " Because otherwise, when we switch from a bullet list to a digit
        " list, a space is added between the marker and the text.

        let pat = '\v^\s*'.cmt.'\zs[-*•]\s*'
        let rep = '\=c.". "'

    " If the lines are already prefixed with digits, we want to remove them.
    " This allows to toggle a numbered list.
    elseif getline(lnum1) =~# '\v^\s*'.cmt.'\d+\s*\.'

        let pat = '\v^\s*'.cmt.'\zs\d+\s*\.\s*'
        let rep = ''

    " Otherwise, the lines are unprefixed, so we want to prefix them with digits.
    else
        "                                           ┌ ignore an empty commented line
        "                             ┌─────────────┤
        let pat = '\v^\s*'.cmt.'\zs\ze%('.cmtt.')@!\S'
        let rep = '\=c.". "'
    endif

    let update_index = 'let c = line(".") == line("'']") + 1 ? c+1 : 1'
    let cmd          = 'keepj keepp %s,%s g/%s/'.update_index.'|keepj keepp s/%s/%s/e'

    let c = 0
    sil exe printf(cmd, lnum1, lnum2, pat, pat, rep)
endfu

fu! bullet_list#unordered(type) abort "{{{1
    if count([ 'v', 'V', "\<c-v>" ], a:type)
        let [ lnum1, lnum2 ] = [ line("'<"), line("'>") ]
    else
        let [ lnum1, lnum2 ] = [ line("'["), line("']") ]
    endif

    let [ cmt, cmtt ] = s:get_comment_patterns()

    " If the lines are prefixed with digits, we want to replace them with marks (`•`).
    if getline(lnum1) =~# '\v^\s*'.cmt.'\d+\s*\.'
        let pat = '\v^\s*'.cmt.'\zs\d+\s*\.\s?'
        let rep = '• '

    " If the lines are prefixed with marks (`-`, `*`, `•`), we want to remove them.
    elseif getline(lnum1) =~# '\v^\s*'.cmt.'[-*•]'
        let pat = '\v^\s*'.cmt.'\zs\S\s*'
        let rep = ''

    " Otherwise, the lines are unprefixed, so we want to prefix them with marks (`•`).
    else
        "                                           ┌ ignore an empty commented line
        "                             ┌─────────────┤
        let pat = '\v^\s*'.cmt.'\zs\ze%('.cmtt.')@!\S'
        let rep = '• '
    endif

    let cmd = 'keepj keepp %s,%s s/%s/%s/e'

    sil exe printf(cmd, lnum1, lnum2, pat, rep)
endfu
