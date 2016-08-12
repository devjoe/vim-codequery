" Copyright (c) 2016 excusemejoe
" MIT License

" =============================================================================
" Menu


command! -nargs=* -complete=customlist,s:complete_function CodeQuery
            \ call s:run_codequery(<q-args>)
command! -nargs=* -complete=customlist,s:complete_function CodeQueryAgain
            \ call s:run_codequery_again_with_different_subcmd(<q-args>)
command! -nargs=0 CodeQueryMakeDB call s:make_codequery_db()
command! -nargs=0 CodeQueryViewDB call s:view_codequery_db()
command! -nargs=0 CodeQueryMoveDBToGitDir
            \ call s:move_codequery_db_to_git_hidden_dir()
command! -nargs=* CodeQueryMenu call s:show_menu(<q-args>)

let s:query_subcommands = [ 'Symbol',
                    \ 'Definition', 'DefinitionGroup',
                    \ 'Caller', 'Callee', 'Call',
                    \ 'Class', 'Member', 'Parent', 'Child',
                    \ 'FunctionList',
                    \ 'FileImporter',
                    \ ]
let s:menu_subcommands = [ 'Unite' ]

function! s:complete_function(arg_lead, cmd_line, cursor_pos)
    return s:query_subcommands
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
    return strlen(matchstr(a:word, '\v^[a-z|A-Z|0-9|_|*|?]+$')) > 0
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

    if s:fuzzy
        let fuzzy_option = '-f'
        let word = '"' . a:word . '"'
    else
        let fuzzy_option = '-e'
        let word = a:word
    endif

    let pipeline_script_option = ' \| cut -f 2,3'

    let grepformat = '%f:%l%m'
    let grepprg = 'cqsearch -s ' . s:db_path . ' -p ' . s:querytype . ' -t ' .
                \ word . ' -u ' . fuzzy_option . pipeline_script_option

    if s:querytype == s:subcmd_map['FileImporter']

        let grepprg = 'cqsearch -s ' . s:db_path . ' -p ' . s:querytype . ' -t ' .
                    \ word . ' -u ' . fuzzy_option

    elseif s:querytype == s:subcmd_map['Callee'] ||
         \ s:querytype == s:subcmd_map['Caller'] ||
         \ s:querytype == s:subcmd_map['Member']

        let grepprg = 'cqsearch -s ' . s:db_path . ' -p ' . s:querytype . ' -t ' .
            \ word . ' -u ' . fuzzy_option . ' \| awk ''{ print $2 " " $1 }'''

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
            copen
            echom 'Found ' . len(results) . ' results'
        else
            echom 'Result Not Found'
        endif
    finally
        let &l:grepprg  = l:grepprg_bak
        let &grepformat = l:grepformat_bak
        let s:last_query_word = a:word
        let s:last_query_fuzzy = s:fuzzy
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


function! s:patch_unite_magic_menu_from_qf(fre_cmds, fun_cmds, cla_cmds)
    call map(a:fre_cmds, '[substitute(v:val[0], "Find", "Switch To", "g"), v:val[1]]')
    call map(a:fun_cmds, '[substitute(v:val[0], "Find", "Switch To", "g"), v:val[1]]')
    call map(a:cla_cmds, '[substitute(v:val[0], "Find", "Switch To", "g"), v:val[1]]')
    call map(a:fre_cmds, '[v:val[0], substitute(v:val[1], "CodeQuery", "CodeQueryAgain", "")]')
    call map(a:fun_cmds, '[v:val[0], substitute(v:val[1], "CodeQuery", "CodeQueryAgain", "")]')
    call map(a:cla_cmds, '[v:val[0], substitute(v:val[1], "CodeQuery", "CodeQueryAgain", "")]')
endfunction


function! s:use_unite_menu(magic)
    let cword = s:get_valid_cursor_word()
    let menu_frequent_cmds = [['▷  Find Symbol', 'CodeQuery Symbol']]
    let menu_function_cmds = [['▷  Find Function Def.     [F]', 'CodeQuery Definition'],
                             \['▷  Find Call              [F]', 'CodeQuery Call'],
                             \['▷  Find Caller            [F]', 'CodeQuery Caller'],
                             \['▷  Find Callee            [F]', 'CodeQuery Callee']]
    let menu_class_cmds =    [['▷  Find Class Def.        [C]', 'CodeQuery Class'],
                             \['▷  Find Class Member      [C]', 'CodeQuery Member'],
                             \['▷  Find Parent            [C]', 'CodeQuery Parent'],
                             \['▷  Find Child             [C]', 'CodeQuery Child']]
    let menu_other_cmds =    [['▷  List Function', 'CodeQuery FunctionList'],
                             \['▷  List Imports', 'CodeQuery FileImporter']]
    let menu_delimiter =     [['* ------------------------- *', '']]
    let menu_db_cmds =       [['▷  Make DB', 'CodeQueryMakeDB'],
                             \['▷  View DB', 'CodeQueryViewDB'],
                             \['▷  Move DB', 'CodeQueryMoveDBToGitDir']]
    let menu_goto_magic =    [['▷  <Open Magic Menu>', 'CodeQueryMenu Unite Magic']]
    let menu_goto_full =     [['▷  <Open Full Menu>', 'CodeQueryMenu Unite Full']]

    if a:magic
        if &filetype ==# 'qf'
            call s:patch_unite_magic_menu_from_qf(menu_frequent_cmds,
                                               \ menu_function_cmds,
                                               \ menu_class_cmds)
            let menu_other_cmds = []
            let menu_goto_full = []
            let cword = s:last_query_word
        endif

        let menu_description = 'CodeQuery Smart Menu'
        if cword =~# '\C^[A-Z].*'
            let cmd_candidates = menu_frequent_cmds
                             \ + menu_class_cmds
                             \ + menu_other_cmds
                             \ + menu_goto_full
        else
            let cmd_candidates = menu_frequent_cmds
                             \ + menu_function_cmds
                             \ + menu_other_cmds
                             \ + menu_goto_full
        endif
    else
        let menu_description = 'CodeQuery Full Menu'
        let cmd_candidates = menu_frequent_cmds
                         \ + menu_function_cmds
                         \ + menu_class_cmds
                         \ + menu_other_cmds
                         \ + menu_delimiter
                         \ + menu_db_cmds
                         \ + menu_delimiter
                         \ + menu_goto_magic
    endif

    if !exists('g:unite_source_menu_menus')
        let g:unite_source_menu_menus = {}
    endif
    let g:unite_source_menu_menus.codequery = {
        \ 'description' : menu_description,
    \}
    let g:unite_source_menu_menus.codequery.command_candidates = cmd_candidates
    execute 'Unite -silent -prompt-visible -prompt=::' . cword
                \ . ':: menu:codequery'
endfunction



" =============================================================================
" Entries


function! s:run_codequery(args)
    if !s:check_filetype()
        echom 'Not Supported Filetype: ' . &filetype
        return
    endif

    let s:last_query_word = ''
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

    elseif index(s:query_subcommands, args[0]) != -1
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
        echom 'Wrong Subcommand !'
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
        silent execute 'Start! -title=Make_CodeQuery_DB -wait=error ' . shell_cmd
        redraw!
        echom 'Run :CodeQueryViewDB to Check Status'
    else
        silent execute '!' . shell_cmd
        redraw!
    endif
endfunction


function! s:view_codequery_db()
    " TODO: remove duplicated filetype checking code
    if !s:check_filetype()
        echom 'Not Supported Filetype: ' . &filetype
        return
    endif

    let db_path = s:find_db_path()
    if empty(db_path)
        echom 'DB not Found'
    endif

    execute '!echo "\nYour DB is update at: "  &&  stat -f "\%Sm" ' . db_path
endfunction


function! s:move_codequery_db_to_git_hidden_dir()
    let db_name = &filetype . '.db'
    let git_root_dir = systemlist('git rev-parse --show-toplevel')[0]
    let db_path = s:find_db_path()

    if !v:shell_error && !empty(db_path)
        let new_db_path = git_root_dir . '/.git/codequery/' . db_name
        call system('mkdir -p ' . git_root_dir . '/.git/codequery/')
        call system('mv ' . db_path . ' ' . new_db_path)
        echom 'Done'
    else
        echom 'Git Dir Not Found or DB Not Found'
    endif
endfunction


function! s:show_menu(args)
    let args = split(a:args, ' ')
    let args_num = len(args)

    if args_num > 0 && index(s:menu_subcommands, args[0]) != -1
        if args[0] ==# 'Unite'
            if args_num > 1 && args[1] ==# 'Magic'
                let magic_menu = 1
            else
                let magic_menu = 0
            endif
            call s:use_unite_menu(magic_menu)
            return
        endif
    endif

    echom 'Wrong Subcommands! Try: ' . join(s:menu_subcommands, ', ')
endfunction


function! s:run_codequery_again_with_different_subcmd(args)
    let args = split(a:args, ' ')
    let args_num = len(args)
    if !empty(s:last_query_word) && args_num > 0
        cclose
        let again_cmd = 'CodeQuery ' . args[0] . ' ' . s:last_query_word . ' '
                      \ . (s:last_query_fuzzy ? '-f' : '')
        execute again_cmd
    else
        echom 'Wrong Subcommands!'
    endif
endfunction


" =============================================================================
" Debugging


"nnoremap <leader>c :CodeQuery<CR> 
