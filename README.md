![](https://github.com/ruben2020/codequery/raw/master/doc/logotitle.png)
  
  
<img src="https://db.tt/j9XrjR4v" align="center" width="500">  
> Choose what you want to know! 😼
     
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
  * [X] `Python` (in beta: **give it a try! 😎**)
  * [ ] `Javascript` (coming soon)
  * [ ] `Ruby` (coming soon)
  * [ ] `Go` (coming soon)
  * [ ] `Java` (coming later)
  * [ ] `C, C++` (coming very later)  
  
<br>
  
## Demo 

`Choose a query from menu ➙ Get results`  

![](https://db.tt/rf6fO2eJ)

`... ➙ Switch to different query ➙ Get results ... ➙ Filter them ➙ Get Results ➙ Undo ➙ Redo`  

![](https://db.tt/KoZORec3)
  
[more demo and screenshots](https://github.com/devjoe/vim-codequery/wiki/Screenshots-and-Demo)
  
<br>
  
## Schedule

> **This project is still under development.**   
>  
> Completeness: 70%  
> v1.0 Release Date: Mid-September
>  
> If you are a pythoner, it is ready for you to use. Try it!  
> This plugin will support Javascript/Ruby/Go ASAP.
  
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

### 4. Install Vim plugins
* Use your favorite plugins manager: [pathogen](https://github.com/tpope/vim-pathogen), [Vundle](https://github.com/VundleVim/Vundle.vim), [Plug](https://github.com/junegunn/vim-plug), [NeoBundle](https://github.com/Shougo/neobundle.vim), [Dein](https://github.com/Shougo/dein.vim),  ...
* Take Plug as an example:  
```vim
" Highly Recommemded => it helps Vim-CodeQuery to build DBasynchrously without blocking Vim
Plug 'tpope/vim-dispatch'  
  
" Highly Recommemded => if you want to use Unite menu
Plug 'Shougo/unite.vim'  
  
" The Must Have One
Plug 'devjoe/vim-codequery'
```
  
<br>
  
## Usage

#### 1. Setup

* Go to the (git) root directory of your project. Then open an arbitrary file with the same file type you want to index under the current directory. For example:  
<pre>
readme.md
setup.py
foldA
├── a.py
├── b.py 
└── c.py
</pre>
In this Python project, you can use `vim setup.py` to open a Python file and then call `:CodeQueryMakeDB` to make CodeQuery DB. If there is no Python file in root directory, you can temporarily open a new one. (like `vim tmp.py`)
* When the DB file `python.db` (or xxxx.db) and related ctags and cscope files are created, it's ready for you to do searching!  
    *  Call `:CodeQueryMakeDB` again to update the DB file if you need.
    *  Vim-CodeQuery will not clean ctags and cscope files, you can use them if you need.
* Furthermore, if you are also under a git repository, it's recommended you to use `:CodeQueryMoveDBToGitDir` to hide the DB file under `.git/codequery/` directory. If you do so, next time you can call `:CodeQueryMakeDB` in any Python file under the repository to update the DB file.

#### 2. Search
* **Find symbol under cursor**  

```vim  
:CodeQuery
```  

* **Find `?` under cursor**  

```vim  
:CodeQuery [SubCommand]  
  
" Supported SubCommands are: `Symbol, Call, Caller, Callee, Class, Parent, Child, Member, FunctionList, FileImporter`.  
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
* **Move inside Quickfix window to use these key bindings**

| Key | Action | Note | 
| --- | --- | --- | 
| s | `:CodeQueryAgain Symbol` |
| c | `:CodeQueryAgain Call` |
| r | `:CodeQueryAgain Caller` |
| y | `:CodeQueryAgain Callee` |
| d | `:CodeQueryAgain Definition` |
| C | `:CodeQueryAgain Class` |
| M | `:CodeQueryAgain Member` |
| P | `:CodeQueryAgain Parent` |
| D | `:CodeQueryAgain Child` |
| \ | `:CodeQueryFilter` |
| p | `<CR><C-W>p` | Preview
| u | `:colder \| CodeQueryShowQF` | Older Quickfix Result
| \<C-R> | `:cnewer \| CodeQueryShowQF` | Newer Quickfix Result


* **Show Quickfix with above key bindings**

```vim
:CodeQueryShowQF  
  
" This command also works for standard Quickfix result
```

#### 4. Open Menu

Currently, Vim-CodeQuery only provides [Unite](https://github.com/Shougo/unite.vim) menu because I love and use it a lot.  There are two types of menu:

* **Open a complete Unite menu**

```vim
:CodeQueryMenu Unite Full  
  
" The string between :: and :: is the word under cursor
" [F] means this action is for 'function variable only'
" [C] is for 'class variable only'  
```
<img src="https://db.tt/j9XrjR4v" align="center" width="400">   
    
* **Open a necessary Unite menu**

```vim
:CodeQueryMenu Unite Magic  
  
" This menu changes dynamically:
" 1. Word under cursor is capital (possible be class): remove [F] actions
" 2. Word under cursor is non-capital (possible be function): remove [C] actions
" 3. Show reasonable actions only within Quickfix
```
<img src="https://db.tt/g6ZXMfaY" align="center" width="300">   
  
<br>
  
## Tips

## FAQ 

## How to Contribute

## Credits
