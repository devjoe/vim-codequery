![](https://github.com/ruben2020/codequery/raw/master/doc/logotitle.png)
  
  
<img src="https://db.tt/j9XrjR4v" align="center" width="500">  
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
2. **Manage your database easily**.
    * Load, make and move your database file by custom Vim commands.
    * `Note: CodeQuery's SQLite database is built on top of ctags and cscope.`
3. **Know your code more instantly**.
    * (TBD)
  
<br>

##  Supported languages
  * [x] `Python` 😎
  * [x] `Javascript`
  * [x] `Ruby`
  * [x] `Go` 
  * [ ] `Java` (coming very soon)
  * [ ] `C, C++` (coming very soon)  
  
<br>
  
## Demo 

`Choose a query from menu ➙ Get results`  

![](https://db.tt/rf6fO2eJ)

`... ➙ Switch to different query ➙ Get results ... ➙ Filter them ➙ Get Results ➙ Undo ➙ Redo`  

![](https://db.tt/KoZORec3)
  
[more demo and screenshots](https://github.com/devjoe/vim-codequery/wiki/Screenshots-and-Demo)
  
<br>
  
## Schedule

> **This project is almost ready to be released.**   
>  
> Main TODO:
> * Use Vim8's new features to enhance usability.
> * Do lazy-loading.
> * Support Java, C, C++.
>  
> Completeness: 90%  
> v1.0 Release Date: Mid-September  
>  
> It is Ok to try it! 👌  
  
<br>
  
## Installation

#### 1. Make sure these commands are in your system
<pre>
echo mkdir mv cut find awk stat git(optional)
</pre>

#### 2. Install CodeQuery
* Follow installation guide in [CodeQuery project](https://github.com/ruben2020/codequery#how-to-install-it).  
* Enter `cqsearch -h` in your terminal and view the result. Make sure `cqsearch` accepts `-u` option.

> If not, you will have to pull latest CodeQuery code and then [build it](https://github.com/ruben2020/codequery/blob/master/doc/INSTALL-LINUX.md) yourself.
 

#### 3. Install additional ctags/cscope tools for your languages
| Language | Tools | How to install |
| --- | --- | --- |  
| Python | [PyCscope](https://github.com/portante/pycscope) | `sudo pip install pycscope` | 
| Javascript | [Starscope](https://github.com/eapache/starscope) | `sudo gem install starscope` |
| Ruby | [Starscope](https://github.com/eapache/starscope) | `sudo gem install starscope` |
| Go | [Starscope](https://github.com/eapache/starscope) | `sudo gem install starscope` |
| Java | N/A | 
| C | N/A | 
| C++ | N/A | 

> Starscope has been [packaged for Arch Linux](https://aur.archlinux.org/packages/ruby-starscope/)    

#### 4. Install Vim plugins
* Use your favorite plugins manager: [pathogen](https://github.com/tpope/vim-pathogen), [Vundle](https://github.com/VundleVim/Vundle.vim), [Plug](https://github.com/junegunn/vim-plug), [NeoBundle](https://github.com/Shougo/neobundle.vim), [Dein](https://github.com/Shougo/dein.vim),  ...
* Take Plug as an example:  
```vim
" Recommemded => it helps vim-codequery to build DB asynchrously without blocking Vim
Plug 'tpope/vim-dispatch'  
   
" Recommemded => if you don't have an :Ack (or :Ag) liked command => install it !
Plug 'mileszs/ack.vim'  
    
" Highly Recommemded => if you want to use my custom Unite menu
Plug 'Shougo/unite.vim'  
   
" The Must Have One
Plug 'devjoe/vim-codequery'
```
  
<br>
  
## Usage

#### 1. Setup

* Go to the (git) root directory of your project. Open vim and type:
```vim
" Indexing Python files
:CodeQueryMakeDB python
  
" Or indexing Python + Javascript files
:CodeQueryMakeDB python javascript 
```
* That's all! `python.db`, `javascript.db` ... will be created in the root directory. 
* It's recommended that you should use `:CodeQueryMoveDBToGitDir python` to hide the DB file to `.git/codequery/` directory. If you do so, next time you can call `:CodeQueryMakeDB` directly in any opened Python buffer to rebuild the DB file.


#### 2. Search
* **Find symbol under cursor**  

```vim  
:CodeQuery
```  

* **Find `?` under cursor**  

```vim  
:CodeQuery [SubCommand]  
  
" Supported SubCommands are: `Symbol, Text, Call, Caller, Callee, Class, Parent, Child, Member, FunctionList, FileImporter`.  
```  

* **Find arbitrary word**

```vim
:CodeQuery [SubCommand] [word]  
```
  
* **Find `?` again with the same word**

```vim
:CodeQueryAgain [SubCommand]  
```

* **With fuzzy Option**    

```vim
:CodeQuery [SubCommand] [word] -f  
  
" [word] can be: get_* or *user_info or find_*_by_id
```

* **With append Option** (results will be added to current Quickfix)    

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

Currently, vim-codequery only provides [Unite](https://github.com/Shougo/unite.vim) menu because I love and use it a lot ⭐.  There are two types of menu:

* **Open a complete Unite menu**

```vim
:CodeQueryMenu Unite Full  
  
" The string between :: and :: is the word under cursor
" [F] means this action is for 'function variable only'
" [C] is for 'class variable only'  
```
<img src="https://db.tt/j9XrjR4v" align="center" width="400">   
    
* **Open a magic Unite menu**

```vim
:CodeQueryMenu Unite Magic  
  
" This menu changes dynamically:
" 1. If word under cursor is capital (possible be class): remove [F] actions
" 2. If word under cursor is non-capital (possible be function): remove [C] actions
" 3. Show reasonable actions only within Quickfix
```
<img src="https://db.tt/g6ZXMfaY" align="center" width="300">   
  
<br>
  
## Tips
#### Open Menu Smartly  
```vim
nnoremap <space>c :CodeQueryMenu Unite Full<CR>
nnoremap <space>; :CodeQueryMenu Unite Magic<CR>
  
" Or enable typing (to search menu items) by default
nnoremap <space>\ :CodeQueryMenu Unite Magic<CR>A
```
  
#### Query Smartly  
```vim
nnoremap <space><CR> :CodeQuery Symbol<CR>
  
" Chain commands! To find possible tests (for python)
nnoremap <space>t :CodeQuery Caller<CR>:CodeQueryFilter test_<CR>
```
  
#### Load Ctags File
```vim
" Set tags option
set tags=./javascript_tags;/
set tags+=./python_tags;/
set tags+=./ruby_tags;/
set tags+=./go_tags;/
```
  
#### Clean Ctags, Cscope ... Files For Your Languages
```vim
" It accpepts a list of your languages written in lowercase
let g:codequery_enable_auto_clean_languages = ['python']
```
  
#### Custom Database Building
```vim
" Make sure to generate a python.db or xxxx.db file as a result
let g:codequery_build_python_db_cmd = '...'
let g:codequery_build_javascript_db_cmd = '...'
let g:codequery_build_ruby_db_cmd = '...'
let g:codequery_build_go_db_cmd = '...'
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

> And give me [feedback](https://goo.gl/forms/9r8sOS6xTCBjNQEW2) or [bug report](https://docs.google.com/spreadsheets/d/1eSweAzJKYdzeNdTUVfhujEAOy1RHq1_bEBSX8DQ6xvA/edit?usp=sharing).

#### Fork It

> And give me PR. It would be better if you open an [issue](https://github.com/devjoe/vim-codequery/issues) and discuss with me before sending PR.
  
#### Star It

> If you like it. 👍
   
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
