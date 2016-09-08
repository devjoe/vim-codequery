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
                   \ 'FileImporter'    : 4,
                   \ 'Text'            : 21 }


function! s:create_grep_options(word) abort
    if g:codequery_fuzzy
        let fuzzy_option = '-f'
        let word = '"' . a:word . '"'
    else
        let fuzzy_option = '-e'
        let word = a:word
    endif

    let pipeline_script_option = ' \| cut -f 2,3'

    let grepformat = '%f:%l%m'
    let grepprg = 'cqsearch -s ' . g:codequery_db_path . ' -p ' . g:codequery_querytype . ' -t '
                \ . word . ' -u ' . fuzzy_option . pipeline_script_option

    if g:codequery_querytype == s:subcmd_map['FileImporter']
        let grepprg = 'cqsearch -s ' . g:codequery_db_path . ' -p ' . g:codequery_querytype . ' -t '
                    \ . word . ' -u ' . fuzzy_option

    elseif g:codequery_querytype == s:subcmd_map['Callee'] ||
         \ g:codequery_querytype == s:subcmd_map['Caller'] ||
         \ g:codequery_querytype == s:subcmd_map['Member']
        let grepprg = 'cqsearch -s ' . g:codequery_db_path . ' -p ' . g:codequery_querytype . ' -t '
            \ . word . ' -u ' . fuzzy_option . ' \| awk ''{ print $2 " " $1 }'''

    elseif g:codequery_querytype == s:subcmd_map['Text']
        silent execute g:codequery_find_text_cmd . ' ' . a:word
        call codequery#query#prettify_qf_layout_and_map_keys(getqflist())

        let g:codequery_last_query_word = a:word
        let g:last_query_fuzzy = g:codequery_fuzzy
        return
    endif

    return [grepformat, grepprg]
endfunction



" =============================================================================
" Entries


function! codequery#query#is_valid_word(word) abort
    return strlen(matchstr(a:word, '\v^[a-z|A-Z|0-9|_|*|?]+$')) > 0
endfunction


function! codequery#query#get_valid_cursor_word() abort
    return codequery#query#is_valid_word(expand('<cword>')) ? expand('<cword>') : ''
endfunction


function! codequery#query#get_valid_input_word(args) abort
    let args = deepcopy(a:args)
    if g:codequery_fuzzy
        call remove(args, index(args, '-f'))
    endif
    if g:codequery_append_to_qf
        call remove(args, index(args, '-a'))
    endif

    if len(args) <= 1
        return ''
    endif

    return codequery#query#is_valid_word(args[1]) ? args[1] : ''
endfunction


function! codequery#query#get_final_query_word(iword, cword) abort
    if empty(a:iword) && g:codequery_querytype == s:subcmd_map['FunctionList']
        return expand('%')
    elseif empty(a:iword) && g:codequery_querytype == s:subcmd_map['FileImporter']
        return expand('%:r')
    elseif empty(a:iword) && !empty(a:cword)
        return a:cword
    elseif empty(a:iword)
        return ''
    else
        return a:iword
    endif
endfunction


" Ref: MarcWeber's vim-addon-qf-layout
function! codequery#query#prettify_qf_layout_and_map_keys(results) abort
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
    nnoremap <buffer> x :CodeQueryAgain Text<CR>
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


function! codequery#query#do_query(word) abort
    if empty(a:word)
        echom 'Invalid Search Term: ' . a:word
        return
    endif

    let grep_options = s:create_grep_options(a:word)
    if empty(grep_options)
        return
    endif
    let [grepformat, grepprg] = grep_options

    " TODO: Rewrite it when Vim8 is coming
    " ----------------------------------------------------------------
    let grepcmd = g:codequery_append_to_qf ? 'grepadd!' : 'grep!'
    let l:grepprg_bak    = &l:grepprg
    let l:grepformat_bak = &grepformat
    try
        let &l:grepformat = grepformat
        let &l:grepprg = grepprg . ' \| awk "{ sub(/.*\/\.\//,x) }1"'
        silent execute grepcmd
        redraw!

        let results = getqflist()
        call codequery#query#prettify_qf_layout_and_map_keys(results)
        if !empty(results)
            echom 'Found ' . len(results) . ' results'
        else
            echom 'Result Not Found'
        endif
    finally
        let &l:grepprg  = l:grepprg_bak
        let &grepformat = l:grepformat_bak
        let g:codequery_last_query_word = a:word
        let g:last_query_fuzzy = g:codequery_fuzzy
    endtry
    " ----------------------------------------------------------------
endfunction


function! codequery#query#set_options(args) abort
    let g:codequery_querytype = get(s:subcmd_map, a:args[0])

    if index(a:args, '-f') != -1
        let g:codequery_fuzzy = 1
    endif

    if index(a:args, '-a') != -1
        let g:codequery_append_to_qf = 1
    endif
endfunction

