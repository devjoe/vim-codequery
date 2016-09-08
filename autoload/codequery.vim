" =============================================================================
" Helpers


let g:c_family_filetype_list =
    \ ['c', 'h', 'cpp', 'cxx', 'cc', 'hpp', 'hxx', 'hh']


let s:supported_filetypes = g:c_family_filetype_list +
    \ ['python', 'javascript', 'go', 'ruby', 'java', 'c', 'cpp']


let s:menu_subcommands = [ 'Unite' ]


function! s:check_filetype(filetype) abort
    if index(s:supported_filetypes, a:filetype) == -1
        return 0
    endif
    return 1
endfunction


function! s:set_db() abort
    let path = codequery#db#find_db_path(&filetype)
    if empty(path)
        echom 'CodeQuery DB Not Found'
        return 0
    endif

    let g:codequery_db_path = path
    return 1
endfunction



" =============================================================================
" Entries


function! codequery#run_codequery(args) abort
    if !s:check_filetype(&filetype)
        echom 'Not Supported Filetype: ' . &filetype
        return
    endif

    let g:codequery_last_query_word = ''
    let g:codequery_fuzzy = 0
    let g:codequery_append_to_qf = 0
    let g:codequery_querytype = 1
    let g:codequery_db_path = ''
    if !s:set_db()
        return
    endif

    let args = split(a:args, ' ')
    let args_num = len(args)
    let cword = codequery#query#get_valid_cursor_word()

    if args_num == 0
        call codequery#query#do_query(cword)

    elseif index(g:codequery_subcommands, args[0]) != -1
        call codequery#query#set_options(args)
        let iword = codequery#query#get_valid_input_word(args)
        let word = codequery#query#get_final_query_word(iword, cword)
        if empty(word)
            echom 'Invalid Args: ' . a:args
            return
        endif

        call codequery#query#do_query(word)
    else
        echom 'Wrong Subcommand !'
    endif
endfunction


function! codequery#make_codequery_db(args) abort
    let args = split(a:args, ' ')
    if empty(args)
        let args = [&filetype]
    endif

    for ft in args
        if !s:check_filetype(ft)
            echom 'Not Supported Filetype: ' . ft
            continue
        endif

        let db_path = codequery#db#find_db_path(ft)
        if empty(db_path)
            if index(g:c_family_filetype_list, ft) != -1
                let db_path = 'c_family.db'
            else
                let db_path = ft . '.db'
            endif
        endif

        if ft ==? 'python'
            let shell_cmd = codequery#db#construct_python_db_build_cmd(db_path)
        elseif ft ==? 'javascript'
            let shell_cmd = codequery#db#construct_javascript_db_build_cmd(db_path)
        elseif ft ==? 'ruby'
            let shell_cmd = codequery#db#construct_ruby_db_build_cmd(db_path)
        elseif ft ==? 'go'
            let shell_cmd = codequery#db#construct_go_db_build_cmd(db_path)
        elseif ft ==? 'java'
            let shell_cmd = codequery#db#construct_java_db_build_cmd(db_path)
        elseif index(g:c_family_filetype_list, ft) != -1
            let shell_cmd = codequery#db#construct_c_db_build_cmd(db_path)
        else
            echom 'No Command For Building .' . ft . ' file'
            continue
        endif

        " TODO: Rewrite it when Vim8 is coming
        " ----------------------------------------------------------------
        if exists(':Start')
            silent execute 'Start! -title=Make_CodeQuery_DB -wait=error ' . shell_cmd
            redraw!
            echom 'Making ' . db_path ' => Run :CodeQueryViewDB to Check Status'
        else
            silent execute '!' . shell_cmd
            redraw!
        endif
        " ----------------------------------------------------------------
    endfor
endfunction


function! codequery#view_codequery_db(args) abort
    let args = split(a:args, ' ')
    if empty(args)
        let args = [&filetype]
    endif

    for ft in args
        if !s:check_filetype(ft)
            echom 'Not Supported Filetype: ' . ft
            continue
        endif

        let db_path = codequery#db#find_db_path(ft)
        if empty(db_path)
            if index(g:c_family_filetype_list, ft) != -1
                execute '!echo "\n(c family) DB Not Found"'
            else
                execute '!echo "\n(' . ft . ') DB Not Found"'
            endif
            continue
        endif

        execute '!echo "\n(' . db_path . ') is update at: "  &&  stat -f "\%Sm" ' . db_path
    endfor
endfunction


function! codequery#move_codequery_db_to_git_hidden_dir(args) abort
    let args = split(a:args, ' ')
    if empty(args)
        let args = [&filetype]
    endif

    for ft in args
        if index(g:c_family_filetype_list, ft) != -1
            let db_name = 'c_family.db'
        else
            let db_name = ft . '.db'
        endif
        let git_root_dir = systemlist('git rev-parse --show-toplevel')[0]
        let db_path = codequery#db#find_db_path(ft)

        if !v:shell_error && !empty(db_path)
            let new_db_path = git_root_dir . '/.git/codequery/' . db_name
            call system('mkdir -p ' . git_root_dir . '/.git/codequery/')
            call system('mv ' . db_path . ' ' . new_db_path)
            echom 'Done (' . db_name . ')'
        else
            echom 'Git Dir Not Found or (' . db_name . ') Not Found'
        endif
    endfor
endfunction


function! codequery#show_menu(args) abort
    let args = split(a:args, ' ')
    let args_num = len(args)

    if args_num > 0 && index(s:menu_subcommands, args[0]) != -1
        if args[0] ==# 'Unite'
            if args_num > 1 && args[1] ==# 'Magic'
                let magic_menu = 1
            else
                let magic_menu = 0
            endif
            call codequery#menu#use_unite_menu(magic_menu)
            return
        endif
    endif

    echom 'Wrong Subcommands! Try: ' . join(s:menu_subcommands, ', ')
endfunction


function! codequery#run_codequery_again_with_different_subcmd(args) abort
    let args = split(a:args, ' ')
    let args_num = len(args)
    if !empty(g:codequery_last_query_word) && args_num > 0
        cclose
        let again_cmd = 'CodeQuery ' . args[0] . ' ' . g:codequery_last_query_word . ' '
                      \ . (g:last_query_fuzzy ? '-f' : '')
        execute again_cmd
    else
        echom 'Wrong Subcommands!'
    endif
endfunction


" modify from someone's .vimrc
function! codequery#filter_qf_results(query) abort
    let results = getqflist()
    for d in results
        if bufname(d['bufnr']) !~ a:query && d['text'] !~ a:query
            call remove(results, index(results, d))
        endif
    endfor
    call setqflist(results)
    call codequery#query#prettify_qf_layout_and_map_keys(results)
endfunction
