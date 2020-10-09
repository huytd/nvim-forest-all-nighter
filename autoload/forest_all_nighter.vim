" =============================================================================
" URL: https://github.com/sainnhe/forest-all-nighter
" Filename: autoload/forest_all_nighter.vim
" Author: sainnhe
" Email: sainnhe@gmail.com
" License: MIT License
" =============================================================================

function! forest_all_nighter#get_configuration() "{{{
  return {
        \ 'transparent_background': get(g:, 'forest_all_nighter_transparent_background', 0),
        \ 'disable_italic_comment': get(g:, 'forest_all_nighter_disable_italic_comment', 0),
        \ 'enable_italic': get(g:, 'forest_all_nighter_enable_italic', 0),
        \ 'cursor': get(g:, 'forest_all_nighter_cursor', 'auto'),
        \ 'menu_selection_background': get(g:, 'forest_all_nighter_menu_selection_background', 'white'),
        \ 'sign_column_background': get(g:, 'forest_all_nighter_sign_column_background', 'default'),
        \ 'current_word': get(g:, 'forest_all_nighter_current_word', get(g:, 'forest_all_nighter_transparent_background', 0) == 0 ? 'grey background' : 'bold'),
        \ 'lightline_disable_bold': get(g:, 'forest_all_nighter_lightline_disable_bold', 0),
        \ 'diagnostic_line_highlight': get(g:, 'forest_all_nighter_diagnostic_line_highlight', 0),
        \ 'better_performance': get(g:, 'forest_all_nighter_better_performance', 0),
        \ }
endfunction "}}}
function! forest_all_nighter#get_palette() "{{{
  return {
        \ 'bg0':        ['#1c2325',   '235',  'Black'],
        \ 'bg1':        ['#3c474d',   '236',  'DarkGrey'],
        \ 'bg2':        ['#465258',   '237',  'DarkGrey'],
        \ 'bg3':        ['#505a60',   '238',  'DarkGrey'],
        \ 'bg4':        ['#576268',   '239',  'DarkGrey'],
        \ 'bg_visual':  ['#5d4251',   '52',   'DarkRed'],
        \ 'bg_red':     ['#5f4e53',   '52',   'DarkRed'],
        \ 'bg_green':   ['#4f5d52',   '22',   'DarkGreen'],
        \ 'bg_blue':    ['#46575f',   '17',   'DarkBlue'],
        \ 'bg_yellow':  ['#5b5c52',   '136',  'DarkBlue'],
        \ 'fg':         ['#d8caac',   '223',  'White'],
        \ 'red':        ['#e68183',   '167',  'Red'],
        \ 'orange':     ['#e39b7b',   '208',  'Red'],
        \ 'yellow':     ['#d9bb80',   '214',  'Yellow'],
        \ 'green':      ['#a7c080',   '142',  'Green'],
        \ 'aqua':       ['#87c095',   '108',  'Cyan'],
        \ 'blue':       ['#83b6af',   '109',  'Blue'],
        \ 'purple':     ['#d39bb6',   '175',  'Magenta'],
        \ 'grey0':      ['#7c8377',   '243',  'DarkGrey'],
        \ 'grey1':      ['#868d80',   '245',  'Grey'],
        \ 'grey2':      ['#999f93',   '247',  'LightGrey'],
        \ 'none':       ['NONE',      'NONE', 'NONE']
        \ }
endfunction "}}}
function! forest_all_nighter#highlight(group, fg, bg, ...) "{{{
  execute 'highlight' a:group
        \ 'guifg=' . a:fg[0]
        \ 'guibg=' . a:bg[0]
        \ 'ctermfg=' . a:fg[1]
        \ 'ctermbg=' . a:bg[1]
        \ 'gui=' . (a:0 >= 1 ?
          \ (a:1 ==# 'undercurl' ?
            \ (executable('tmux') && $TMUX !=# '' ?
              \ 'underline' :
              \ 'undercurl') :
            \ a:1) :
          \ 'NONE')
        \ 'cterm=' . (a:0 >= 1 ?
          \ (a:1 ==# 'undercurl' ?
            \ 'underline' :
            \ a:1) :
          \ 'NONE')
        \ 'guisp=' . (a:0 >= 2 ?
          \ a:2[0] :
          \ 'NONE')
endfunction "}}}
function! forest_all_nighter#ft_gen(path, last_modified, msg) "{{{
  " Generate the `after/ftplugin` directory.
  let full_content = join(readfile(a:path), "\n") " Get the content of `colors/forest-all-nighter.vim`
  let ft_content = []
  let rootpath = forest_all_nighter#ft_rootpath(a:path) " Get the path to place the `after/ftplugin` directory.
  call substitute(full_content, '" ft_begin.\{-}ft_end', '\=add(ft_content, submatch(0))', 'g') " Search for 'ft_begin.\{-}ft_end' (non-greedy) and put all the search results into a list.
  for content in ft_content
    let ft_list = []
    call substitute(matchstr(matchstr(content, 'ft_begin:.\{-}{{{'), ':.\{-}{{{'), '\(\w\|-\)\+', '\=add(ft_list, submatch(0))', 'g') " Get the file types. }}}}}}
    for ft in ft_list
      call forest_all_nighter#ft_write(rootpath, ft, content) " Write the content.
    endfor
  endfor
  call forest_all_nighter#ft_write(rootpath, 'text', "let g:forest_all_nighter_last_modified = '" . a:last_modified . "'") " Write the last modified time to `after/ftplugin/text/forest_all_nighter.vim`
  if a:msg ==# 'update'
    echohl WarningMsg | echom '[forest-all-nighter] Updated ' . rootpath . '/after/ftplugin' | echohl None
  else
    echohl WarningMsg | echom '[forest-all-nighter] Generated ' . rootpath . '/after/ftplugin' | echohl None
  endif
endfunction "}}}
function! forest_all_nighter#ft_write(rootpath, ft, content) "{{{
  " Write the content.
  let ft_path = a:rootpath . '/after/ftplugin/' . a:ft . '/forest_all_nighter.vim' " The path of a ftplugin file.
  " create a new file if it doesn't exist
  if !filereadable(ft_path)
    call mkdir(a:rootpath . '/after/ftplugin/' . a:ft, 'p')
    call writefile([
          \ "if !exists('g:colors_name') || g:colors_name !=# 'forest-all-nighter'",
          \ '    finish',
          \ 'endif'
          \ ], ft_path, 'a') " Abort if the current color scheme is not forest-all-nighter.
    call writefile([
          \ "if index(g:forest_all_nighter_loaded_file_types, '" . a:ft . "') ==# -1",
          \ "    call add(g:forest_all_nighter_loaded_file_types, '" . a:ft . "')",
          \ 'else',
          \ '    finish',
          \ 'endif'
          \ ], ft_path, 'a') " Abort if this file type has already been loaded.
  endif
  " If there is something like `call forest_all_nighter#highlight()`, then add
  " code to initialize the palette and configuration.
  if matchstr(a:content, 'forest_all_nighter#highlight') !=# ''
    call writefile(['let s:configuration = forest_all_nighter#get_configuration()', 'let s:palette = forest_all_nighter#get_palette()'], ft_path, 'a')
  endif
  " Append the content.
  call writefile(split(a:content, "\n"), ft_path, 'a')
endfunction "}}}
function! forest_all_nighter#ft_rootpath(path) "{{{
  " Get the directory where `after/ftplugin` is generated.
  if (matchstr(a:path, '^/usr/share') ==# '') || has('win32') " Return the plugin directory. The `after/ftplugin` directory should never be generated in `/usr/share`, even if you are a root user.
    return substitute(a:path, '/colors/forest-all-nighter\.vim$', '', '')
  else " Use vim home directory.
    if has('nvim')
      return stdpath('config')
    else
      if has('win32') || has ('win64')
        return $VIM . '/vimfiles'
      else
        return $HOME . '/.vim'
      endif
    endif
  endif
endfunction "}}}
function! forest_all_nighter#ft_newest(path, last_modified) "{{{
  " Determine whether the current ftplugin files are up to date by comparing the last modified time in `colors/forest-all-nighter.vim` and `after/ftplugin/text/forest_all_nighter.vim`.
  let rootpath = forest_all_nighter#ft_rootpath(a:path)
  execute 'source ' . rootpath . '/after/ftplugin/text/forest_all_nighter.vim'
  return a:last_modified ==# g:forest_all_nighter_last_modified ? 1 : 0
endfunction "}}}
function! forest_all_nighter#ft_clean(path, msg) "{{{
  " Clean the `after/ftplugin` directory.
  let rootpath = forest_all_nighter#ft_rootpath(a:path)
  " Remove `after/ftplugin/**/forest_all_nighter.vim`.
  let file_list = split(globpath(rootpath, 'after/ftplugin/**/forest_all_nighter.vim'), "\n")
  for file in file_list
    call delete(file)
  endfor
  " Remove empty directories.
  let dir_list = split(globpath(rootpath, 'after/ftplugin/*'), "\n")
  for dir in dir_list
    if globpath(dir, '*') ==# ''
      call delete(dir, 'd')
    endif
  endfor
  if globpath(rootpath . '/after/ftplugin', '*') ==# ''
    call delete(rootpath . '/after/ftplugin', 'd')
  endif
  if globpath(rootpath . '/after', '*') ==# ''
    call delete(rootpath . '/after', 'd')
  endif
  if a:msg
    echohl WarningMsg | echom '[forest-all-nighter] Cleaned ' . rootpath . '/after/ftplugin' | echohl None
  endif
endfunction "}}}
function! forest_all_nighter#ft_exists(path) "{{{
  return filereadable(forest_all_nighter#ft_rootpath(a:path) . '/after/ftplugin/text/forest_all_nighter.vim')
endfunction "}}}

" vim: set sw=2 ts=2 sts=2 et tw=80 ft=vim fdm=marker fmr={{{,}}}:
