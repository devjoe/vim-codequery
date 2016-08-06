" Copyright (c) 2016 excusemejoe
" MIT License

" =============================================================================
" Menu


command! -nargs=* -complete=customlist,s:complete_function CodeQuery call s:run_codequery(<q-args>)
command! -nargs=0 CodeQueryMakeDB call s:make_codequery_db()

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


function! s:check_filetype()
    let supported_filetypes =
        \ ['python', 'javascript', 'go', 'ruby', 'java', 'c', 'cpp']
    if index(supported_filetypes, &filetype) == -1
        return 0
    endif
    return 1
endfunction


" `lcd` brings side effect !! 
function! s:find_db_path()
    let db_name = &filetype . '.db'
    let lookup_path = findfile(expand('%:h') . '/' . db_name, '.')

    if !empty(lookup_path)
        lcd %:h
        return lookup_path
    endif

    lcd %:h
    let git_root_dir = systemlist('git rev-parse --show-toplevel')[0]
    if !v:shell_error
        let lookup_path = findfile(git_root_dir . '/' . db_name, '.')
        if !empty(lookup_path)
            execute 'lcd ' . git_root_dir
            return lookup_path
        else
            let lookup_path = findfile(git_root_dir . '/.git/codequery/' .
                                        \ db_name, '.')
            if !empty(lookup_path)
                execute 'lcd ' . git_root_dir
                return lookup_path
            endif
        endif
    endif
endfunction


function! s:set_db()
    let path = s:find_db_path()
    if empty(path)
        echom 'CodeQuery DB Not Found'
        return 0
    endif

    let s:db_path = path
    return 1
endfunction


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
    let grepprg = 'cqsearch -s ' . s:db_path . ' -p ' . s:querytype . ' -t ' .
                \ a:word . ' -u ' . fuzzy_option . pipeline_script_option

    if s:querytype == s:subcmd_map['FileImporter']

        let grepprg = 'cqsearch -s ' . s:db_path . ' -p ' . s:querytype . ' -t ' .
                    \ a:word . ' -u ' . fuzzy_option

    elseif s:querytype == s:subcmd_map['Callee'] ||
         \ s:querytype == s:subcmd_map['Caller'] ||
         \ s:querytype == s:subcmd_map['Member']

        let grepprg = 'cqsearch -s ' . s:db_path . ' -p ' . s:querytype . ' -t ' .
            \ a:word . ' -u ' . fuzzy_option . ' \| awk ''{ print $2 " " $1 }'''

    elseif s:querytype == s:subcmd_map['DefinitionGroup']
        echom 'Not Implement !'
        return
    endif

    let grepcmd = s:append_to_quickfix ? 'grepadd!' : 'grep!'
    let l:grepprg_bak    = &l:grepprg
    let l:grepformat_bak = &grepformat
    try
        let &l:grepformat = grepformat
        let &l:grepprg = grepprg . ' \| awk "{ sub(/.*\/\.\//,x) }1"'
        silent execute grepcmd
        redraw!

        let results = getqflist()
        if !empty(results)
            echo 'Found ' . len(results) . ' results'
            copen
        else
            echo 'Result Not Found'
        endif
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
    if !s:check_filetype()
        echom 'Not Supported Filetype: ' . &filetype
        return
    endif

    let s:fuzzy = 0
    let s:append_to_quickfix = 0
    let s:querytype = 1
    let s:db_path = ''
    if !s:set_db()
        return
    endif

    let args = split(a:args, ' ')
    let args_num = len(args)
    let cword = s:get_valid_cursor_word()

    if args_num == 0
        call s:do_grep(cword)

    elseif index(s:subcommands, args[0]) != -1
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


function! s:make_codequery_db()
    if !s:check_filetype()
        echom 'Not Supported Filetype: ' . &filetype
        return
    endif

    let db_path = s:find_db_path()
    if empty(db_path)
        let db_path = &filetype . '.db'
    endif

    " TODO: refactor later ---------------
    let cscope_file = &filetype . '_cscope.files'
    let cscopeout_file = &filetype . '_cscope.out'
    let tags_file = &filetype . '_tags'

    let find_cmd = 'find . -iname "*.py" > ' . cscope_file
    let pycscope_cmd = 'pycscope -f "' . cscopeout_file . '" -i ' . cscope_file
    let ctags_cmd = 'ctags --fields=+i -n -R -f "' .
                    \ tags_file . '" -L ' . cscope_file
    let cqmakedb_cmd = 'cqmakedb -s "' . db_path . '" -c ' . cscopeout_file .
                       \ ' -t ' . tags_file . ' -p'
    let shell_cmd = find_cmd . ' && ' .
                  \ pycscope_cmd . ' && ' .
                  \ ctags_cmd . ' && ' .
                  \ cqmakedb_cmd
    " ------------------------------------

    if exists(':Start')
        execute 'Start! -title=Make_CodeQuery_DB -wait=error ' . shell_cmd
    else
        silent execute '!' . shell_cmd
        redraw!
    endif
endfunction


" =============================================================================
" Debugging


"nnoremap <leader>c :CodeQuery<CR> 
