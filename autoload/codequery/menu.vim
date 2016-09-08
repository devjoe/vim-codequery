
let s:menu_subcommands = [ 'Unite' ]


function! codequery#patch_unite_magic_menu_from_qf(fre_cmds, fun_cmds, cla_cmds)
    call map(a:fre_cmds, '[substitute(v:val[0], "Find", "Switch To", "g"), v:val[1]]')
    call map(a:fun_cmds, '[substitute(v:val[0], "Find", "Switch To", "g"), v:val[1]]')
    call map(a:cla_cmds, '[substitute(v:val[0], "Find", "Switch To", "g"), v:val[1]]')
    call map(a:fre_cmds, '[v:val[0], substitute(v:val[1], "CodeQuery", "CodeQueryAgain", "")]')
    call map(a:fun_cmds, '[v:val[0], substitute(v:val[1], "CodeQuery", "CodeQueryAgain", "")]')
    call map(a:cla_cmds, '[v:val[0], substitute(v:val[1], "CodeQuery", "CodeQueryAgain", "")]')
    call insert(a:fre_cmds, ['▷  Filter', 'call feedkeys(":CodeQueryFilter ")'], 0)
endfunction



function! codequery:use_unite_menu(magic)
    let cword = s:get_valid_cursor_word()
    let menu_frequent_cmds = [['▷  Find Symbol', 'CodeQuery Symbol'],
                             \['▷  Find Text', 'CodeQuery Text']]
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
            call codequery#patch_unite_magic_menu_from_qf(menu_frequent_cmds,
                                               \ menu_function_cmds,
                                               \ menu_class_cmds)
            let menu_other_cmds = []
            let menu_goto_full = []
            if exists('s:last_query_word')
                let cword = s:last_query_word
            endif
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
        if &filetype ==# 'qf'
            echom 'Can Not Open Full Menu In QF (Use Magic Menu)'
            return
        endif
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



