![](https://github.com/ruben2020/codequery/raw/master/doc/logotitle.png)
  
  
<img src="https://db.tt/j9XrjR4v" align="center" width="500">  
> Choose what you want to know! 😼
     
  <br>  
  <br>

# vim-codequery
  
This Vim plugin is built on top of the great tool [CodeQuery](https://github.com/ruben2020/codequery) created by ruben2020, and aims at providing three primary functions to help you to:
  
1. **Search source code gracefully within Vim**.
    * You can find: `definition, call, caller, callee, symbol, class, parent, child` and more for a string.
    * Well-formated results are shown in a custom Quickfix window with usable key bindings.
2. **Manage your database easily**.
    * Load, make and move your database file by custom Vim commands.
    * `Note: CodeQuery's SQLite database is built on top of ctags and cscope.`
3. **Know your code more instantly**.
    * (TBD)
  
##  Supported languages
  * [X] `Python` (in beta: **give it a try! 😎**)
  * [ ] `Javascript` (coming soon)
  * [ ] `Ruby` (coming soon)
  * [ ] `Go` (coming soon)
  * [ ] `Java` (coming later)
  * [ ] `C, C++` (coming very later)  
  
## Demo 

`Choose a query from menu ➙ Get results`  

![](https://db.tt/rf6fO2eJ)

`... ➙ Switch to different query ➙ Get results ... ➙ Filter them ➙ Get Results ➙ Undo ➙ Redo`  

![](https://db.tt/KoZORec3)
  
[more demo and screenshots](https://github.com/devjoe/vim-codequery/wiki/Screenshots-and-Demo)

## Schedule

> **This project is still under development.**   
>  
> Completeness: 70%  
> v1.0 Release Date: Mid-September
>  
> If you are a pythoner, it is ready for you to use. Try it!  
> This plugin will support javascript/ruby/go ASAP.

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
* Use your favorite plugins manager: [pathogen](https://github.com/tpope/vim-pathogen), [Vundle](https://github.com/VundleVim/Vundle.vim), [Plug](https://github.com/junegunn/vim-plug), [NeoBundle](https://github.com/Shougo/neobundle.vim), [Dein](https://github.com/Shougo/dein.vim)  ...
* Take Plug as an example:  
  
```vim
" Highly Recommemded => it helps Vim-CodeQuery to build DB asynchrously without blocking Vim
Plug 'tpope/vim-dispatch'  
" Highly Recommemded => if you want to use built-in Unite menu
Plug 'Shougo/unite.vim'  
" The Must Have One
Plug 'devjoe/vim-codequery'
```
  
## Basic Usage

## Commnads

## Tips

## FAQ 

## How can I contribute?

## Credits
