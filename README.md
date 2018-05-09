![](https://github.com/ruben2020/codequery/raw/master/doc/logotitle.png)
  
  
<img src="https://devjoe.github.io/public/menu_only.png" align="center" width="500">  
> Choose what you want to know! 😼
     
```vim
" Open menu
:CodeQueryMenu Unite Full

" Or query directly
:CodeQuery Definition get_user_id
```
  <br>  
  <br>

# vim-codequery
  
This Vim plugin is built on top of the great tool [CodeQuery](https://github.com/ruben2020/codequery) created by ruben2020, and aims at providing three primary functions to help you to:
  
1. **Search source code gracefully within Vim**.
    * You can find: `definition, call, caller, callee, symbol, class, parent, child` and more for a string.
    * Convenient menus are created for you.
    * Well-formated results are shown in a custom Quickfix window with usable key bindings.
    * Support asynchronous search (Vim version >= 8.0)
2. **Manage your database easily**.
    * Load, make and move your database file by custom Vim commands.
    * Support asynchronous build (Vim version >= 8.0 or NeoVim or by `Dispatch` plugin)
    * `Note: CodeQuery's SQLite database is built on top of ctags and cscope.`
3. **Know your code more instantly**.
    * (TBD)
  
<br>

##  Supported languages
  * [x] `Python` 😎
  * [x] `Javascript`
  * [x] `Ruby`
  * [x] `Go` 
  * [x] `Java`
  * [x] `C, C++`
  
<br>
  
## Demo

`Choose a query from menu ➙ Get results`  

![](https://devjoe.github.io/public/cq_demo1.gif)

`... ➙ Switch to different query ➙ Get results ... ➙ Filter them ➙ Get Results ➙ Undo ➙ Redo`  

![](https://devjoe.github.io/public/ca_demo2.gif)
  
[more demo and screenshots](https://github.com/devjoe/vim-codequery/wiki/Screenshots-and-Demo)  
    
```
These videos are quite old.   
Now vim-codequery works better than what you see by using Vim8's async feature.
```
<br>
  
## Schedule

> **This project is released.**   
>  
> Main TODO:
> * ~~Use Vim8's new features to enhance usability.~~
> * ~~Do lazy-loading.~~
> * ~~Enhance usability.~~
> * ~~Test it.~~
> * ~~Support NeoVim at a certain level.~~
> * Add **explain** command in v1.0.0
> * Make UI be optional
> * Doc it.
>  
> Current Version: v0.9.2  
>  
> Welcome to try it! 👌  
  
<br>
  
## Installation

#### 1. Make sure these commands are in your system
<pre>
/bin/sh echo mkdir mv cut find awk stat git(optional)
</pre>

#### 2. Install CodeQuery
* Linux => Install [binaries](https://sourceforge.net/projects/codequery/files/) or [build it](https://github.com/ruben2020/codequery/blob/master/doc/INSTALL-LINUX.md).
* Mac => `brew install codequery` 🍺 (make sure codequery version >= v0.17.0)

#### 3. Install additional ctags/cscope tools for your languages
| Language | Tools | How to install |
| --- | --- | --- |  
| Python | [PyCscope](https://github.com/portante/pycscope) | `sudo pip install pycscope` | 
| Javascript | [Starscope](https://github.com/eapache/starscope) | `sudo gem install starscope` |
| Ruby | [Starscope](https://github.com/eapache/starscope) | `sudo gem install starscope` |
| Go | [Starscope](https://github.com/eapache/starscope) | `sudo gem install starscope` |

> `Java`, `C` and `C++` users do not need to install additional ctags/cscope tools.  
> Starscope has been [packaged for Arch Linux](https://aur.archlinux.org/packages/ruby-starscope/)    

#### 4. Install Vim plugins
* Use your favorite plugins manager: [pathogen](https://github.com/tpope/vim-pathogen), [Vundle](https://github.com/VundleVim/Vundle.vim), [Plug](https://github.com/junegunn/vim-plug), [NeoBundle](https://github.com/Shougo/neobundle.vim), [Dein](https://github.com/Shougo/dein.vim),  ...
* Take Plug as an example:  
```vim
" Required
Plug 'Shougo/unite.vim'
Plug 'devjoe/vim-codequery'
  
" Optional
" if your vim version < 8.0
Plug 'tpope/vim-dispatch'
" if you don't have an :Ack (or :Ag) liked command
Plug 'mileszs/ack.vim'
```
* In case you prefer to use Vim8's native package manager to manage plugins manually. Here comes an installation guide for that:  
  1. Go to `~/.vim`
  2. Run `mkdir -p pack/vim-codequery/start/` and then go to `start` directory
  3. Run `git clone https://github.com/devjoe/vim-codequery` to get latest vim-codequery code
  4. It's done. 😎 Now `vim-codequery` will be loaded when your Vim starts. You can install [unite](https://github.com/Shougo/unite.vim) in the same way
  5. Learn more about Vim8's package system by typing `:help package | only`  
  
<br>
  
## Usage

#### 1. Setup

* Go to the (git) root directory of your project. Open vim and type:
```vim
" Index Python files
:CodeQueryMakeDB python
  
" Or index Python + Javascript files
:CodeQueryMakeDB python javascript 
```
* That's all. `python.db`, `javascript.db` ... will be created in the root directory. 
* It's recommended that you should use `:CodeQueryMoveDBToGitDir python` to hide the DB file to `.git/codequery/` directory. If you do so, next time you can call `:CodeQueryMakeDB` directly in any opened Python buffer to rebuild the DB file.


#### 2. Search
* **Find symbol under your cursor**  

```vim  
:CodeQuery
```  

* **Find word (by subcommands) under your cursor**  

```vim  
:CodeQuery [SubCommand]  
  
" Supported SubCommands are: `Symbol, Text, Call, Caller, Callee, Class, Parent, Child, Member, FunctionList, FileImporter`.  
```  

* **Find arbitrary word**

```vim
:CodeQuery [SubCommand] [word]  
```
  
* **Find again with the same word**

```vim
:CodeQueryAgain [SubCommand]  
```

* **Use fuzzy Option**    

```vim
:CodeQuery [SubCommand] [word] -f  
  
" [word] can be: get_* or *user_info or find_*_by_id
```

* **Use append Option** (results will be added to the current Quickfix)    

```vim
:CodeQuery [SubCommand] [word] -a  
```

* **Filter Search Results**  

```vim
:CodeQueryFilter [string]  
  
" [string] can be a regex
```
    
#### 3. Use Quickfix
* **Move your cursor inside Quickfix window to use these key bindings**

| Key | Action | Note | 
| --- | --- | --- | 
| s | `:CodeQueryAgain Symbol` | |
| x | `:CodeQueryAgain Text` | use `:Ack!` by default. #1 | 
| c | `:CodeQueryAgain Call` | |
| r | `:CodeQueryAgain Caller` | |
| e | `:CodeQueryAgain Callee` | |
| d | `:CodeQueryAgain Definition` | |
| C | `:CodeQueryAgain Class` | |
| M | `:CodeQueryAgain Member` | |
| P | `:CodeQueryAgain Parent` | |
| D | `:CodeQueryAgain Child` | |
| m | `:CodeQueryMenu Unite Magic` | |
| q | `:cclose` | |
| \ | `:CodeQueryFilter` | |
| p | `<CR><C-W>p` | Preview |
| u | `:colder \| CodeQueryShowQF` | Older Quickfix Result | 
| \<C-R> | `:cnewer \| CodeQueryShowQF` | Newer Quickfix Result | 
  
>  #1 
> You can override `g:codequery_find_text_cmd` to change it.

* **Show Quickfix with above key bindings**

```vim
:CodeQueryShowQF  
  
" This command can also be used to **patch** standard Quickfix.
```

#### 4. Open Menu

Currently, vim-codequery only provides [Unite](https://github.com/Shougo/unite.vim) menu because I love it ⭐.  There are two types of menu:

* **Full Unite menu**

```vim
:CodeQueryMenu Unite Full  
  
" The string between :: and :: is the word under cursor
" [F] means this action is for 'function variable only'
" [C] is for 'class variable only'  
```
<img src="https://devjoe.github.io/public/fullmenu.png" align="center" width="400">   
    
* **Magic Unite menu**

```vim
:CodeQueryMenu Unite Magic  
  
" This menu changes dynamically:
" 1. If the word under your cursor begins with a capital letter (possible be class): show [C] actions
" 2. Vice versa (possible be function): show [F] actions
" 3. Show reasonable actions within Quickfix
```
<img src="https://devjoe.github.io/public/magicmenu.png" align="center" width="300">   
  
<br>
  
## Tips
#### Open Menu  
```vim
nnoremap <space>c :CodeQueryMenu Unite Full<CR>
nnoremap <space>; :CodeQueryMenu Unite Magic<CR>
  
" Or enable typing (to search menu items) by default
nnoremap <space>\ :CodeQueryMenu Unite Magic<CR>A
```
  
#### Query  
```vim
nnoremap <space><CR> :CodeQuery Symbol<CR>
  
" Chain commands to find possible tests (for python)
nnoremap <space>t :CodeQuery Caller<CR>:CodeQueryFilter test_<CR>
```
  
#### Filter  
```vim
" Filter reversely by adding '!'
:CodeQueryFilter ! [word]
```
  
#### Build  
```vim
" Trigger db building (in current filetype) when your query fails
let g:codequery_trigger_build_db_when_db_not_found = 1
```

#### Find Text 
```vim
" Custom your `CodeQuery Text` commands
let g:codequery_find_text_cmd = 'Ack!'
  
let g:codequery_find_text_from_current_file_dir = 0
" 0 => search from project dir (git root directory -> then the directory containing xxx.db file)
" 1 => search from the directory containing current file
  
" If you use ':CodeQuery Symbol' in a txt file, of course, it will fail due to wrong filetype.
" With the following option set to 1, ':CodeQuery Text' will be automatically sent when your query fails.
let g:codequery_auto_switch_to_find_text_for_wrong_filetype = 0
```  
  
#### Load Ctags File
```vim
" Set tags option
set tags=./javascript_tags;/
set tags+=./python_tags;/
set tags+=./ruby_tags;/
set tags+=./go_tags;/
set tags+=./java_tags;/
set tags+=./c_tags;/
```
  
#### Clean Ctags, Cscope ... Files by Languages
```vim
let g:codequery_enable_auto_clean_languages = ['python']
  
" It accpepts a list of your languages written in lowercase
```
  
#### Custom Database Building
```vim
" Make sure to generate a python.db or xxxx.db file as a result
let g:codequery_build_python_db_cmd = '...'
let g:codequery_build_javascript_db_cmd = '...'
let g:codequery_build_ruby_db_cmd = '...'
let g:codequery_build_go_db_cmd = '...'  
let g:codequery_build_java_db_cmd = '...'  
let g:codequery_build_c_db_cmd = '...'  
```
  
  
#### Others
```vim
" You can disable key binding within quickfix
let g:codequery_disable_qf_key_bindings = 1
  
" if your function usually begins with a capital letter ..., you can change your magic menu to a not-so-magic one
let g:codequery_enable_not_so_magic_menu = 1
```
  
<br>
  
## FAQ 

#### Why writing this plugin?

> Because I need it. 
>   
> I already shared the story of making this plugin in local Python user groups [Taipei.py](http://www.meetup.com/Taipei-py/) and [Tainan.py](http://www.meetup.com/Tainan-py-Python-Tainan-User-Group/).  
> Slides are available here: [Taipei.py](http://www.slideshare.net/excusemejoe/joe-vim-plugin-taipeipy20160825) / [Tainan.py](http://www.slideshare.net/excusemejoe/vim-plugin-20160827) (Language: Traditional Chinese)
  
#### Why not using Ctags or Cscope directly?
  
> Read what @ruben2020 the author of CodeQuery said: [Link](https://github.com/ruben2020/codequery#how-is-it-different-from-cscope-and-ctags-what-are-the-advantages)   
> 
> In addittion, vim-codequery provides: 
>   
> 1. Good interface.
> 2. Separated Database Management Mechanism.  
> (You can open as many projects as you wish in a single Vim session without worrying about messing up Ctags or Cscope files or getting wrong result!) 
>    
> for Vim users.
  
#### More Questions

> Ask [here](https://docs.google.com/document/d/1gIvP9wrp1i3xLPDEKNVy76gUeYt1QkIUoqSvJDEbOfM/edit?usp=sharing) or create an issue. 
   
<br>
   
## How to Contribute
#### Use It

#### Fork It

> And give me PR. It would be better if you open an [issue](https://github.com/devjoe/vim-codequery/issues) and discuss with me before sending PR.
  
#### Star It

> If you like it. 👍
   
<br>
   
## Contributors
* [devjoe](https://github.com/devjoe)
* [johnzeng](https://github.com/johnzeng)
* [syslot](https://github.com/syslot)
   
<br>
   
## Credits

Thank all for working on these great projects!

* [CodeQuery](https://github.com/ruben2020/codequery)
* [Starscope](https://github.com/eapache/starscope)
* [PyCscope](https://github.com/portante/pycscope)
* [Unite.vim](https://github.com/Shougo/unite.vim)
* [dispatch.vim](https://github.com/tpope/vim-dispatch)
* [ack.vim](https://github.com/mileszs/ack.vim)
* [vim-addon-qf-layout](https://github.com/MarcWeber/vim-addon-qf-layout)
