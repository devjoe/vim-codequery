" Copyright (c) 2016 excusemejoe
" MIT License

" =============================================================================
" Options

" Init with default value
let g:codequery_find_text_cmd = 'Ack!'
let g:codequery_find_text_from_current_file_dir = 0


" No need to init
"let g:codequery_build_python_db_cmd = ''
"let g:codequery_build_javascript_db_cmd = ''
"let g:codequery_build_ruby_db_cmd = ''
"let g:codequery_build_go_db_cmd = ''
"let g:codequery_build_java_db_cmd = ''
"let g:codequery_build_c_db_cmd = ''
"let g:codequery_enable_auto_clean_languages = []


" =============================================================================
" Commands


command! -nargs=* -complete=customlist,s:complete_function CodeQuery
            \ call codequery#run_codequery(<q-args>)
command! -nargs=* -complete=customlist,s:complete_function CodeQueryAgain
            \ call codequery#run_codequery_again_with_different_subcmd(<q-args>)
command! -nargs=* CodeQueryFilter call codequery#filter_qf_results(<q-args>)
command! -nargs=* CodeQueryMakeDB call codequery#make_codequery_db(<q-args>)
command! -nargs=* CodeQueryViewDB call codequery#view_codequery_db(<q-args>)
command! -nargs=* CodeQueryMoveDBToGitDir
            \ call codequery#move_codequery_db_to_git_hidden_dir(<q-args>)
command! -nargs=* CodeQueryMenu call codequery#show_menu(<q-args>)
command! -nargs=0 CodeQueryShowQF call
            \ codequery#query#prettify_qf_layout_and_map_keys(getqflist())

let g:codequery_subcommands = [ 'Symbol', 'Text',
                    \ 'Definition',
                    \ 'Caller', 'Callee', 'Call',
                    \ 'Class', 'Member', 'Parent', 'Child',
                    \ 'FunctionList',
                    \ 'FileImporter',
                    \ ]

function! s:complete_function(arg_lead, cmd_line, cursor_pos)
    return g:codequery_subcommands
endfunction
