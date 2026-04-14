vim9script
g:mapleader = ' '


def g:Open_file_tree()
	var buftypes = []
	for i in range(1, winnr('$'))
		add(buftypes, getwinvar(i, '&filetype'))
	endfor

	if index(buftypes, 'netrw') != -1
		echo "You already have a Explorer instance opened!!!"
		return
	endif

	execute ":25vsplit"
	execute "Ex"
enddef

var BUFFER_HANDLER = -1
var WINID = -1

var BUFFER_HANDLER_NO_PAR = -1
var WINID_NO_PAR = -1
def g:Close_terminal(flag: number = 0)
	if flag == 1
		if WINID != -1
			popup_close(WINID)
			WINID = -1
		endif
		if BUFFER_HANDLER != -1
			term_setkill(BUFFER_HANDLER, "kill")
			BUFFER_HANDLER = -1
		endif
	elseif flag == 2
		popup_close(WINID_NO_PAR)
		WINID_NO_PAR = -1
		term_setkill(BUFFER_HANDLER_NO_PAR, "kill")
		BUFFER_HANDLER_NO_PAR = -1
	else
		return
	endif
enddef
def g:Popup_terminal(command = "NONE")
	var ccc = ""
	var winwidth = &columns
	var winheight = &lines
	var termwidth = float2nr(winwidth * 0.8)
	var termheight = float2nr(winheight * 0.8)
	var buftype = &buftype
	if command == "NONE"
		var shell_env_var = split(execute("echo $SHELL"), "/")
		var shell = shell_env_var[-1]
		var buff_was_open = 0
		ccc = shell
		if BUFFER_HANDLER == -1
			BUFFER_HANDLER = term_start(ccc, {
				hidden: 1,
				term_rows: termheight,
				term_cols: termwidth,
				term_finish: "close"
			})
		else
			buff_was_open = 1
		endif
		if WINID == -1
			WINID = popup_create(BUFFER_HANDLER, {
				minwidth: termwidth,
				minheight: termheight,
				maxwidth: termwidth,
				maxheight: termheight,
				drag: 1, close: "button",
				highlight: "normal",
				border: [1, 1, 1, 1],
				pos: "center",
				mapping: 1
			})
			execute "tnoremap <silent> <buffer> <Space><Esc> <C-\\><C-n>:call Close_terminal(1)<CR>"
			execute "nnoremap <silent> <buffer> <Space><Esc> <C-\\><C-n>:call Close_terminal(1)<CR>"
			execute "tnoremap <silent> <buffer> <Space>ter <C-\\><C-n>:call Popup_terminal()<CR>"
		elseif buftype == "terminal"
			popup_close(WINID)
			WINID = -1
			return
		endif
		if buff_was_open == 1
			call feedkeys("i", 'n')
		endif
	else
		ccc = command
		BUFFER_HANDLER_NO_PAR = term_start(ccc, {
			hidden: 1,
			term_rows: termheight,
			term_cols: termwidth,
		})
		WINID_NO_PAR = popup_create(BUFFER_HANDLER_NO_PAR, {
			minwidth: termwidth,
			minheight: termheight,
			maxwidth: termwidth,
			maxheight: termheight,
			drag: 1,
			close: "button",
			highlight: "normal",
			border: [1, 1, 1, 1],
			pos: "center",
			mapping: 1
		})
		win_execute(WINID_NO_PAR, "noremap <buffer> <silent> q <C-\\><C-n>:call Close_terminal(2)<CR>")
	endif
enddef

def g:Open_file_under_cursor_while_split()
	var file_name = expand("<cfile>")
	var directory = b:netrw_curdir
	var full_path = directory .. "/" .. file_name

	if empty(full_path)
		return
	elseif isdirectory(full_path)
		execute "Ex " .. fnameescape(full_path)
		execute "cd " .. fnameescape(full_path)
		return
	else
		execute "cd %:p:h"
		execute "wincmd l"
		execute "e " .. file_name
	endif

enddef

def g:Open_file_under_cursor()
	var file_name = expand("<cfile>")
	var directory = b:netrw_curdir
	var full_path = directory .. "/" .. file_name

	if isdirectory(full_path)
		execute "Ex " .. fnameescape(full_path)
		execute "cd " .. fnameescape(full_path)
		return
	endif

	execute "cd %:p:h"
	execute "e " .. fnameescape(full_path)
	execute "only"
enddef

def g:NetrwMaps()
	silent! nunmap <buffer> <CR>
	silent! nunmap <buffer> <Space>
	silent! nunmap <buffer> <C-l>
	silent! nunmap <buffer> <C-h>
	silent! nunmap <buffer> <C-k>
	silent! nunmap <buffer> <C-j>
	silent! nunmap <buffer> v
	nnoremap <buffer> <silent> :normal v<CR>
	nnoremap <buffer> <silent> <Leader><CR> :call Open_file_under_cursor()<CR>
	nnoremap <buffer> <silent> <CR> :call Open_file_under_cursor_while_split()<CR>
	nnoremap <silent> <C-l> <C-w>l
	nnoremap <silent> <C-h> <C-w>h
	nnoremap <silent> <C-k> <C-w>k
	nnoremap <silent> <C-j> <C-w>j
enddef
augroup MyCustomMappings
	autocmd!
	autocmd FileType netrw g:NetrwMaps()
augroup END

set number
set relativenumber
set noswapfile
execute "set mouse=a"

syntax on
filetype on
filetype plugin indent on

nnoremap <silent> <C-l> <C-w>l
nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-k> <C-w>k
nnoremap <silent> <C-j> <C-w>j

nnoremap <silent> <Leader>n :next<CR>
nnoremap <silent> <Leader>p :prev<CR>
nnoremap <silent> <Leader>bf :Ex<CR>
nnoremap <silent> <Leader>sc :source ~/.vimrc<CR>
nnoremap <silent> <Leader>ft :call Open_file_tree()<CR>
nnoremap <silent> <Leader>o :only<CR>
nnoremap <silent> <Leader>ter :call Popup_terminal()<CR>
tnoremap <silent> <Leader><Esc> <C-\><C-n>:q!<CR>
tnoremap <silent> <Esc> <C-\><C-n>
vnoremap <silent> <Leader>y :call Copy_selected_text_to_clipboard()<CR>

tnoremap <silent> <Leader>qa :qa!<CR>
nnoremap <silent> <Leader>qa :qa!<CR>
vnoremap <silent> <Leader>qa :qa!<CR>
