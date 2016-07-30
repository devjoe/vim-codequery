" Copyright (c) 2016 excusemejoe
" MIT License

" =============================================================================
" Menu


command! -nargs=* -complete=customlist,s:complete_function CodeQuery call s:run_codequery(<q-args>)

let s:subcommands = [ 'Symbol',
                    \ 'Definition', 'DefinitionGroup',
                    \ 'Caller', 'Callee', 'Call',
                    \ 'Class', 'Member', 'Parent', 'Child',
                    \ 'FunctionList',
                    \ 'FileImporter',
                    \ ]

function! s:complete_function(arg_lead, cmd_line, cursor_pos)
    return s:subcommands
endfunction



" =============================================================================
" Helpers


let s:subcmd_map = { 'Symbol'          : 1,
                   \ 'Definition'      : 2,
                   \ 'Caller'          : 6,
                   \ 'Callee'          : 7,
                   \ 'Call'            : 8,
                   \ 'Class'           : 3,
                   \ 'Member'          : 9,
                   \ 'Parent'          : 12,
                   \ 'Child'           : 11,
                   \ 'FunctionList'    : 13,
                   \ 'FileImporter'    : 4 ,
                   \ 'DefinitionGroup' : 20 }


function! s:is_valid_word(word)
    return strlen(matchstr(a:word, '\v[a-z|A-Z|0-9|_]+')) > 0
endfunction


function! s:get_valid_cursor_word()
    return s:is_valid_word(expand('<cword>')) ? expand('<cword>') : ''
endfunction


function! s:get_valid_input_word(args)
    let args = deepcopy(a:args)
    if s:fuzzy
        call remove(args, index(args, '-f'))
    endif
    if s:append_to_quickfix
        call remove(args, index(args, '-a'))
    endif

    if len(args) <= 1
        return ''
    endif

    return s:is_valid_word(args[1]) ? args[1] : ''
endfunction


function! s:do_grep(word)
    if empty(a:word)
        echom 'Invalid Search Term: ' . a:word
        return
    endif

    let fuzzy_option = s:fuzzy ? '-f' : '-e'
    let pipeline_script_option = ' \| cut -f 2,3'

    let grepformat = '%f:%l%m'
    let grepprg = 'cqsearch -s myproject.db -p ' . s:querytype . ' -t ' .
                \ a:word . ' ' . fuzzy_option . pipeline_script_option

    if s:querytype == s:subcmd_map['FileImporter']

        let grepprg = 'cqsearch -s myproject.db -p ' . s:querytype . ' -t ' .
                    \ a:word . ' ' . fuzzy_option

    elseif s:querytype == s:subcmd_map['Callee'] ||
         \ s:querytype == s:subcmd_map['Caller'] ||
         \ s:querytype == s:subcmd_map['Member']

        let grepprg = 'cqsearch -s myproject.db -p ' . s:querytype . ' -t ' .
            \ a:word . ' ' . fuzzy_option . ' \| awk ''{ print $2 " " $1 }'''

    elseif s:querytype == s:subcmd_map['DefinitionGroup']
        echom 'Not Implement !'
        return
    endif

    let grepcmd = s:append_to_quickfix ? 'grepadd!' : 'grep!'
    let l:grepprg_bak    = &l:grepprg
    let l:grepformat_bak = &grepformat
    try
        let &l:grepformat = grepformat
        let &l:grepprg = grepprg
        silent execute grepcmd
        redraw!
        copen
    finally
        let &l:grepprg  = l:grepprg_bak
        let &grepformat = l:grepformat_bak
    endtry
endfunction


function! s:set_options(args)
    let s:querytype = get(s:subcmd_map, a:args[0])

    if index(a:args, '-f') != -1
        let s:fuzzy = 1
    endif

    if index(a:args, '-a') != -1
        let s:append_to_quickfix = 1
    endif
endfunction



" =============================================================================
" Entries


function! s:run_codequery(args)
    let s:fuzzy = 0
    let s:append_to_quickfix = 0
    let s:querytype = 1

    let args = split(a:args, ' ')
    let args_num = len(args)
    let cword = s:get_valid_cursor_word()

    if args_num == 0
        " Example:
        " :CodeQuery
        call s:do_grep(cword)

    elseif index(s:subcommands, args[0]) != -1
        " Examples:
        " :CodeQuery Symbol
        " :CodeQuery Symbol -f -a
        " :CodeQuery Symbol search_term -f -a
        call s:set_options(args)
        let iword = s:get_valid_input_word(args)

        if empty(iword) && s:querytype == s:subcmd_map['FunctionList']
            let iword = expand('%')
        elseif empty(iword) && s:querytype == s:subcmd_map['FileImporter']
            let iword = expand('%:r')
        elseif empty(iword) && !empty(cword)
            let iword = cword
        elseif empty(iword)
            echom 'Invalid Args: ' . a:args
            return
        endif

        call s:do_grep(iword)
    else
        echo 'Wrong Subcommand !'
    endif
endfunction



" =============================================================================
" Debugging


"nnoremap <leader>c :CodeQuery 
