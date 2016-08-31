" Copyright (c) 2016 excusemejoe
" MIT License

" =============================================================================
" Menu


command! -nargs=* -complete=customlist,s:complete_function CodeQuery
            \ call s:run_codequery(<q-args>)
command! -nargs=* -complete=customlist,s:complete_function CodeQueryAgain
            \ call s:run_codequery_again_with_different_subcmd(<q-args>)
command! -nargs=* CodeQueryFilter call s:filter_qf_results(<q-args>)
command! -nargs=* CodeQueryMakeDB call s:make_codequery_db(<q-args>)
command! -nargs=* CodeQueryViewDB call s:view_codequery_db(<q-args>)
command! -nargs=* CodeQueryMoveDBToGitDir
            \ call s:move_codequery_db_to_git_hidden_dir(<q-args>)
command! -nargs=* CodeQueryMenu call s:show_menu(<q-args>)
command! -nargs=0 CodeQueryShowQF call
            \ s:prettify_qf_layout_and_map_keys(getqflist())

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


function! s:check_filetype(filetype)
    let supported_filetypes =
        \ ['python', 'javascript', 'go', 'ruby', 'java', 'c', 'cpp']
    if index(supported_filetypes, a:filetype) == -1
        return 0
    endif
    return 1
endfunction


" `lcd` brings side effect !! 
function! s:find_db_path(filetype)
    let db_name = a:filetype . '.db'
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
    let path = s:find_db_path(&filetype)
    if empty(path)
        echom 'CodeQuery DB Not Found'
        return 0
    endif

    let s:db_path = path
    return 1
endfunction


function! s:construct_python_db_build_cmd(db_path)
    let cscope_file = 'python_cscope.files'
    let cscopeout_file = 'python_cscope.out'
    let tags_file = 'python_tags'

    let find_cmd = 'find . -iname "*.py" > ' . cscope_file
    let pycscope_cmd = 'pycscope -f "' . cscopeout_file . '" -i ' . cscope_file
    let ctags_cmd = 'ctags --fields=+i -n -R -f "' .
                    \ tags_file . '" -L ' . cscope_file
    let cqmakedb_cmd = 'cqmakedb -s "' . a:db_path . '" -c ' . cscopeout_file .
                       \ ' -t ' . tags_file . ' -p'
    let shell_cmd = find_cmd . ' && ' .
                  \ pycscope_cmd . ' && ' .
                  \ ctags_cmd . ' && ' .
                  \ cqmakedb_cmd
    return shell_cmd
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


" Ref: MarcWeber's vim-addon-qf-layout
function! s:prettify_qf_layout_and_map_keys(results)
    if &filetype !=# 'qf'
        copen
    endif

    " unlock qf to make changes
    setlocal modifiable
    setlocal nolist
    setlocal nowrap

    " delete all the text in qf
    silent %delete

    " insert new text with pretty layout
    let max_fn_len = 0
    let max_lnum_len = 0
    for d in a:results
        let d['filename'] = bufname(d['bufnr'])
        let max_fn_len = max([max_fn_len, len(d['filename'])])
        let max_lnum_len = max([max_lnum_len, len(d['lnum'])])
    endfor
    let reasonable_max_len = 60
    let max_fn_len = min([max_fn_len, reasonable_max_len])
    let qf_format = '"%-' . max_fn_len . 'S | %' . max_lnum_len . 'S | %s"'
    let evaluating_str = 'printf(' . qf_format .
                    \ ', v:val["filename"], v:val["lnum"], v:val["text"])'
    call append('0', map(a:results, evaluating_str))

    " delete empty line
    global/^$/delete

    " put the cursor back
    normal! gg

    " map shortcuts
    nnoremap <buffer> s :CodeQueryAgain Symbol<CR>
    nnoremap <buffer> c :CodeQueryAgain Call<CR>
    nnoremap <buffer> r :CodeQueryAgain Caller<CR>
    nnoremap <buffer> e :CodeQueryAgain Callee<CR>
    nnoremap <buffer> d :CodeQueryAgain Definition<CR>
    nnoremap <buffer> C :CodeQueryAgain Class<CR>
    nnoremap <buffer> M :CodeQueryAgain Member<CR>
    nnoremap <buffer> P :CodeQueryAgain Parent<CR>
    nnoremap <buffer> D :CodeQueryAgain Child<CR>

    nnoremap <buffer> m :CodeQueryMenu Unite Magic<CR>
    nnoremap <buffer> q :cclose<CR>
    nnoremap <buffer> \ :CodeQueryFilter 

    nnoremap <buffer> p <CR><C-W>p
    nnoremap <buffer> u :colder \| CodeQueryShowQF<CR>
    nnoremap <buffer> <C-R> :cnewer \| CodeQueryShowQF<CR>

    " lock qf again
    setlocal nomodifiable
    setlocal nomodified
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
    let grepprg = 'cqsearch -s ' . s:db_path . ' -p ' . s:querytype . ' -t '
                \ . word . ' -u ' . fuzzy_option . pipeline_script_option

    if s:querytype == s:subcmd_map['FileImporter']

        let grepprg = 'cqsearch -s ' . s:db_path . ' -p ' . s:querytype . ' -t '
                    \ . word . ' -u ' . fuzzy_option

    elseif s:querytype == s:subcmd_map['Callee'] ||
         \ s:querytype == s:subcmd_map['Caller'] ||
         \ s:querytype == s:subcmd_map['Member']

        let grepprg = 'cqsearch -s ' . s:db_path . ' -p ' . s:querytype . ' -t '
            \ . word . ' -u ' . fuzzy_option . ' \| awk ''{ print $2 " " $1 }'''

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
        call s:prettify_qf_layout_and_map_keys(results)
        if !empty(results)
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
    call insert(a:fre_cmds, ['▷  Filter', 'call feedkeys(":CodeQueryFilter ")'], -1)
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
    let menu_db_cmds =       [['▷  Make DB', 'call feedkeys(":CodeQueryMakeDB ")'],
                             \['▷  View DB', 'call feedkeys(":CodeQueryViewDB ")'],
                             \['▷  Move DB', 'call feedkeys(":CodeQueryMoveDBToGitDir ")']]
    let menu_show_qf =       [['▷  Show QF ▲', 'CodeQueryShowQF'],
                             \['▷  Hide QF ▼', 'cclose']]
    let menu_goto_magic =    [['▷  Open Magic Menu ▸', 'CodeQueryMenu Unite Magic']]
    let menu_goto_full =     [['▷  Open Full Menu ▸', 'CodeQueryMenu Unite Full']]

    if a:magic
        if &filetype ==# 'qf'
            call s:patch_unite_magic_menu_from_qf(menu_frequent_cmds,
                                               \ menu_function_cmds,
                                               \ menu_class_cmds)
            let menu_other_cmds = []
            let menu_goto_full = []
            let cword = s:last_query_word
        endif

        let menu_description = 'CodeQuery Magic Menu'
        if cword =~# '\C^[A-Z].*'
            let cmd_candidates = menu_frequent_cmds
                             \ + menu_class_cmds
                             \ + menu_other_cmds
                             \ + menu_show_qf
                             \ + menu_goto_full
        else
            let cmd_candidates = menu_frequent_cmds
                             \ + menu_function_cmds
                             \ + menu_other_cmds
                             \ + menu_show_qf
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
                         \ + menu_show_qf
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
    if !s:check_filetype(&filetype)
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


function! s:make_codequery_db(args)
    let args = split(a:args, ' ')
    if empty(args)
        let args = [&filetype]
    endif

    for ft in args
        if !s:check_filetype(ft)
            echom 'Not Supported Filetype: ' . ft
            continue
        endif

        let db_path = s:find_db_path(ft)
        if empty(db_path)
            let db_path = ft . '.db'
        endif

        if ft ==? 'python'
            let shell_cmd = s:construct_python_db_build_cmd(db_path)
        else
            echom 'No Command For Building ' . ft . ' DB'
            continue
        endif

        if exists(':Start')
            silent execute 'Start! -title=Make_CodeQuery_DB -wait=error ' . shell_cmd
            redraw!
            echom 'Making ' . db_path ' => Run :CodeQueryViewDB to Check Status'
        else
            silent execute '!' . shell_cmd
            redraw!
        endif
    endfor
endfunction


function! s:view_codequery_db(args)
    let args = split(a:args, ' ')
    if empty(args)
        let args = [&filetype]
    endif

    for ft in args
        if !s:check_filetype(ft)
            echom 'Not Supported Filetype: ' . ft
            continue
        endif

        let db_path = s:find_db_path(ft)
        if empty(db_path)
            execute '!echo "\n(' . ft . ') DB Not Found"'
            continue
        endif

        execute '!echo "\n(' . db_path . ') is update at: "  &&  stat -f "\%Sm" ' . db_path
    endfor
endfunction


function! s:move_codequery_db_to_git_hidden_dir(args)
    let args = split(a:args, ' ')
    if empty(args)
        let args = [&filetype]
    endif

    for ft in args
        let db_name = ft . '.db'
        let git_root_dir = systemlist('git rev-parse --show-toplevel')[0]
        let db_path = s:find_db_path(ft)

        if !v:shell_error && !empty(db_path)
            let new_db_path = git_root_dir . '/.git/codequery/' . db_name
            call system('mkdir -p ' . git_root_dir . '/.git/codequery/')
            call system('mv ' . db_path . ' ' . new_db_path)
            echom '(' . ft . ') DB Done'
        else
            echom 'Git Dir Not Found or (' . ft . ') DB Not Found'
        endif
    endfor
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


" modify from someone's .vimrc
function! s:filter_qf_results(query)
    let results = getqflist()
    for d in results
        if bufname(d['bufnr']) !~ a:query && d['text'] !~ a:query
            call remove(results, index(results, d))
        endif
    endfor
    call setqflist(results)
    call s:prettify_qf_layout_and_map_keys(results)
endfunction
