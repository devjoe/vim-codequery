" =============================================================================
" Entries


let g:module_api_path_point = $codequery_base_db_path ? $codequery_base_db_path : expand('$HOME') . '/' . '.doctype'
function! codequery#db#module_found(filetype)
    return codequery#db#path_module_found(g:module_api_path_point, '.*' . a:filetype . '\.db')
endfunction

function! codequery#db#path_module_found(basepath, match_rule_matchstr)
    let dbs = []
    if isdirectory(a:basepath)
        let objs = split(globpath(a:basepath, '**'), '\n')
        for obj in objs
            if strlen(matchstr(obj, '.*' . a:match_rule_matchstr))
                call add(dbs, obj)
            endif
        endfor
    endif
    return dbs
endfunction


" `lcd` brings side effect !!
function! codequery#db#find_db_path(filetype) abort
    if index(g:c_family_filetype_list, a:filetype) != -1
        let db_name = 'c_family.db'
    else
        let db_name = a:filetype . '.db'
    endif

    let lookup_path = findfile(expand('%:p:h') . '/' . db_name, '.')

    if !empty(lookup_path)
        lcd %:p:h
        return lookup_path
    endif

    lcd %:p:h
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
            else
                let cache_paths = codequery#db#module_found(a:filetype)
                let lookup_path = join(cache_paths)
                if strlen(lookup_path)
                    execute 'lcd ' . git_root_dir
                    return lookup_path
                endif
            endif
        endif
    endif
    return ''
endfunction


function! codequery#db#make_db_callback(job, status) dict
    echom 'Done!  (' . self.db_path . ')'
endfunction


function! codequery#db#make_db_nvim_callback(job, data, status) dict
    echom 'Done! Built codequery db!'
endfunction


function! codequery#db#construct_python_db_build_cmd(db_path) abort
    let find_cmd = 'find . -iname "*.py" > python_cscope.files'
    let pycscope_cmd = 'pycscope -f "python_cscope.out" -i python_cscope.files'
    let ctags_cmd = 'ctags --fields=+i -n -R -f "python_tags" -L python_cscope.files'
    let cqmakedb_cmd = 'cqmakedb -s "' . a:db_path . '" -c python_cscope.out' .
                     \ ' -t python_tags -p'
    let shell_cmd = find_cmd . ' && ' .
                  \ pycscope_cmd . ' && ' .
                  \ ctags_cmd . ' && ' .
                  \ cqmakedb_cmd

    if exists('g:codequery_enable_auto_clean_languages') &&
     \ index(g:codequery_enable_auto_clean_languages, 'python') != -1
        let shell_cmd .= '&& rm python_cscope.files python_cscope.out python_tags'
    endif

    return exists('g:codequery_build_python_db_cmd') ? g:codequery_build_python_db_cmd : shell_cmd
endfunction


function! codequery#db#construct_javascript_db_build_cmd(db_path) abort
    let starscope_cmd = 'starscope --force-update -e ctags -e cscope **/*.js'
    let rename_cmd = 'mv tags javascript_tags && mv cscope.out javascript_cscope.out'
    let cqmakedb_cmd = 'cqmakedb -s "' . a:db_path .
                     \ '" -c ./javascript_cscope.out -t ./javascript_tags -p'

    let shell_cmd = starscope_cmd . ' && ' . rename_cmd . ' && ' . cqmakedb_cmd

    if exists('g:codequery_enable_auto_clean_languages') &&
     \ index(g:codequery_enable_auto_clean_languages, 'javascript') != -1
        let shell_cmd .= ' && rm javascript_cscope.out javascript_tags .starscope.db'
    endif

    return exists('g:codequery_build_javascript_db_cmd') ? g:codequery_build_javascript_db_cmd : shell_cmd
endfunction


function! codequery#db#construct_ruby_db_build_cmd(db_path) abort
    let starscope_cmd = 'starscope --force-update -e ctags -e cscope **/*.rb'
    let rename_cmd = 'mv tags ruby_tags && mv cscope.out ruby_cscope.out'
    let cqmakedb_cmd = 'cqmakedb -s "' . a:db_path .
                     \ '" -c ./ruby_cscope.out -t ./ruby_tags -p'

    let shell_cmd = starscope_cmd . ' && ' . rename_cmd . ' && ' . cqmakedb_cmd

    if exists('g:codequery_enable_auto_clean_languages') &&
     \ index(g:codequery_enable_auto_clean_languages, 'ruby') != -1
        let shell_cmd .= ' && rm ruby_cscope.out ruby_tags .starscope.db'
    endif

    return exists('g:codequery_build_ruby_db_cmd') ? g:codequery_build_ruby_db_cmd : shell_cmd
endfunction


function! codequery#db#construct_go_db_build_cmd(db_path) abort
    let starscope_cmd = 'starscope --force-update -e ctags -e cscope **/*.go'
    let rename_cmd = 'mv tags go_tags && mv cscope.out go_cscope.out'
    let cqmakedb_cmd = 'cqmakedb -s "' . a:db_path .
                     \ '" -c ./go_cscope.out -t ./go_tags -p'

    let shell_cmd = starscope_cmd . ' && ' . rename_cmd . ' && ' . cqmakedb_cmd

    if exists('g:codequery_enable_auto_clean_languages') &&
     \ index(g:codequery_enable_auto_clean_languages, 'go') != -1
        let shell_cmd .= ' && rm go_cscope.out go_tags .starscope.db'
    endif

    return exists('g:codequery_build_go_db_cmd') ? g:codequery_build_go_db_cmd : shell_cmd
endfunction


function!  codequery#db#construct_java_db_build_cmd(db_path) abort
    let find_cmd = 'find . -iname "*.java" > java_cscope.files'
    let cscope_cmd = 'cscope -cbR -i java_cscope.files -f java_cscope.out'
    let ctags_cmd = 'ctags --fields=+i -n -R -f "java_tags" -L java_cscope.files'
    let cqmakedb_cmd = 'cqmakedb -s "' . a:db_path . '" -c java_cscope.out' .
                     \ ' -t java_tags -p'
    let shell_cmd = find_cmd . ' && ' .
                  \ cscope_cmd . ' && ' .
                  \ ctags_cmd . ' && ' .
                  \ cqmakedb_cmd

    if exists('g:codequery_enable_auto_clean_languages') &&
     \ index(g:codequery_enable_auto_clean_languages, 'java') != -1
        let shell_cmd .= '&& rm java_cscope.files java_cscope.out java_tags'
    endif

    return exists('g:codequery_build_java_db_cmd') ? g:codequery_build_java_db_cmd : shell_cmd
endfunction


function! codequery#db#construct_c_db_build_cmd(db_path) abort
    let find_cmd = 'find . -iname "*.c" > c_cscope.files && ' .
                 \ 'find . -iname "*.h" >> c_cscope.files && ' .
                 \ 'find . -iname "*.cpp" >> c_cscope.files && ' .
                 \ 'find . -iname "*.cxx" >> c_cscope.files && ' .
                 \ 'find . -iname "*.cc" >>  c_cscope.files && ' .
                 \ 'find . -iname "*.hpp" >> c_cscope.files && ' .
                 \ 'find . -iname "*.hxx" >> c_cscope.files && ' .
                 \ 'find . -iname "*.hh" >> c_cscope.files'
    let cscope_cmd = 'cscope -cbk -i c_cscope.files -f c_cscope.out'
    let ctags_cmd = 'ctags --fields=+i -n -R -f "c_tags" -L c_cscope.files'
    let cqmakedb_cmd = 'cqmakedb -s "' . a:db_path . '" -c c_cscope.out' .
                     \ ' -t c_tags -p'
    let shell_cmd = find_cmd . ' && ' .
                  \ cscope_cmd . ' && ' .
                  \ ctags_cmd . ' && ' .
                  \ cqmakedb_cmd

    if exists('g:codequery_enable_auto_clean_languages') &&
     \ index(g:codequery_enable_auto_clean_languages, 'c') != -1
        let shell_cmd .= '&& rm c_cscope.files c_cscope.out c_tags'
    endif

    return exists('g:codequery_build_c_db_cmd') ? g:codequery_build_c_db_cmd : shell_cmd
endfunction
