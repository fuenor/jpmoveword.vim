"----------------------------------------
" JpMoveWord.vim
"----------------------------------------
""""""""""""""""""""""""""""""
" セパレータ停止W,B,Eコマンド
" W,B,Eでセパレータを判別して停止します。
" デフォルトでは日本語の句読点が設定されています。
"
" jpmoveword_enable_WBE = 1 : WBEを本プラグインで置き換える
"
" jpmoveword_separator = '、。' : 移動時に一旦停止するセパレータ
" jpmoveword_stop_separator = 0 : 移動時にセパレータ自体でも停止する/しない
"
" jpmoveword_stop_eol = 0 : 行末をまたぐ際になにもしない
" jpmoveword_stop_eol = 1 : 行末をまたぐ際にeolで停止
" jpmoveword_stop_eol = 2 : 行末をまたぐ際に行末文字で停止
" * 1と2はvirtualeditを設定しない限り違いはありません
"----------------------------------------
scriptencoding utf-8

let s:cpo_save = &cpo
set cpo&vim
let loaded_jpmoveword = 1

if !exists('jpmoveword_enable_WBE')
  let jpmoveword_enable_WBE = 1
endif
if !exists('jpmoveword_separator')
  let jpmoveword_separator = '、。'
endif
if !exists('jpmoveword_stop_separator')
  let jpmoveword_stop_separator = 0
endif
if !exists('jpmoveword_stop_eol')
  let jpmoveword_stop_eol = 0
endif

au VimEnter * call <SID>jpmovewordKeymap()
function! s:jpmovewordKeymap()
  if !g:jpmoveword_enable_WBE
    return
  endif
  nmap <silent> W <Plug>JpMove_nW
  omap <silent> W <Plug>JpMove_oW
  xmap <silent> W <Plug>JpMove_xW
  nmap <silent> B <Plug>JpMove_nB
  omap <silent> B <Plug>JpMove_oB
  xmap <silent> B <Plug>JpMove_xB
  nmap <silent> E <Plug>JpMove_nE
  omap <silent> E <Plug>JpMove_oE
  xmap <silent> E <Plug>JpMove_xE
  omap <silent> iW <Plug>JpTextObjctIon
  xmap <silent> iW <Plug>JpTextObjctIxn
  omap <silent> aW <Plug>JpTextObjctAon
  xmap <silent> aW <Plug>JpTextObjctAxn
  if g:jpmoveword_enable_WBE >= 2
    omap <silent> il <Plug>JpTextObjctIon
    xmap <silent> il <Plug>JpTextObjctIxn
    omap <silent> al <Plug>JpTextObjctAon
    xmap <silent> al <Plug>JpTextObjctAxn
  endif
endfunction

nnoremap <silent> <Plug>JpMove_nW :<C-U>call <SID>JpMoveW('nW', v:count1)<CR>
onoremap <silent> <Plug>JpMove_oW :<C-U>call <SID>JpMoveW('oW', v:count1)<CR>
xnoremap <silent> <Plug>JpMove_xW :<C-U>call <SID>JpMoveW('xW', v:count1)<CR>
nnoremap <silent> <Plug>JpMove_nB :<C-U>call <SID>JpMoveW('nB', v:count1)<CR>
onoremap <silent> <Plug>JpMove_oB :<C-U>call <SID>JpMoveW('oB', v:count1)<CR>
xnoremap <silent> <Plug>JpMove_xB :<C-U>call <SID>JpMoveW('xB', v:count1)<CR>
nnoremap <silent> <Plug>JpMove_nE :<C-U>call <SID>JpMoveW('nE', v:count1)<CR>
onoremap <silent> <Plug>JpMove_oE :<C-U>call <SID>JpMoveW('oE', v:count1)<CR>
xnoremap <silent> <Plug>JpMove_xE :<C-U>call <SID>JpMoveW('xE', v:count1)<CR>

onoremap <silent> <Plug>JpTextObjctIon :<C-U>call <SID>JpObject('o', 'i', v:count1)<CR>
xnoremap <silent> <Plug>JpTextObjctIxn :<C-U>call <SID>JpObject('x', 'i', v:count1)<CR>
onoremap <silent> <Plug>JpTextObjctAon :<C-U>call <SID>JpObject('o', 'a', v:count1)<CR>
xnoremap <silent> <Plug>JpTextObjctAxn :<C-U>call <SID>JpObject('x', 'a', v:count1)<CR>

function! s:JpMoveW(cmd, count)
  let cmd = a:cmd
  let cnt = a:count > 0 ? a:count : 1
  let stop_eol = g:jpmoveword_stop_eol
  let stop_sep = g:jpmoveword_stop_separator
  let onemore = &virtualedit =~ 'onemore' && stop_eol == 1
  if g:jpmoveword_separator == ''
    let separator = '$^'
    let separatorR = '$^'
  else
    let separator = '['.g:jpmoveword_separator.']'
    let separatorR = '[^'.g:jpmoveword_separator.']'
  endif
  let space = '[[:space:]　]'
  let spaceR = '[^[:space:]　]'

  let regxp = '\(^'.space.'*\zs\)\|'.'\('.space.'\+\zs'.'\)'
  let regxp .= '\|\('.separator.'\+'.(!stop_sep ? '\zs' : '').'\)'
  let regxp .= stop_eol ? '\|$' : '\|[\r\n]\+[\r\n]\+'
  if cmd =~ '[nox]E'
    let regxp = '\('.'\zs'.spaceR.space.'\+'.'\)\|\(\zs'.separatorR.separator.'\+\)'
    let regxp .= (cmd =~ 'nE' ? '\|\zs.$' : '\|\zs$').'\|^$'
  elseif cmd =~ '[nox]B'
    let regxp = '\(^'.spaceR.'\)\|\('.space.'\+\zs'.'\)\|\('.separator.'\+\zs\)'
    let regxp .= stop_eol ? '\|$' : ''
  elseif cmd == 'oW' && v:operator == 'c'
    let regxp = '\('.space.'\+\zs\)\|'.'\('.spaceR.'\zs'.space.'\+'.'\)\|\('.separator.'\+\)'.'\|$'
  endif
  if cmd =~ 'x[WBE]'
    normal!gv
    let lastPos = getpos('.')
    normal! o
    let firstPos = getpos('.')
    normal! o
    normal! v
    call setpos('.', lastPos)
 endif

  let saved_ve = &virtualedit
  if stop_eol == 2
    silent setlocal virtualedit-=onemore
  endif
  for i in range(cnt)
    let [buf, lnum, col, off] = getpos('.')
    let len = strlen(getline(lnum)) - strlen(matchstr(getline(lnum), '.$'))
    let char = matchstr(getline(lnum), '.', col-1)
    if cmd =~ '[nox]E'
      let char = matchstr(getline(lnum), '.', col+strlen(char)-1)
    elseif cmd =~ '[nox]B'
      let char = matchstr(getline(lnum), '.', col-strlen(char)-1)
    endif
    if cmd =~ '[nox]B'
      if char =~ separator && col < len+1 && stop_sep
        if col == 1 && lnum != 1
          call cursor(lnum-1, 1)
          call cursor(line('.'), col('$'))
          if stop_eol == 2
            let char = matchstr(getline(line('.')), '.$')
            call cursor(line('.'), col('$')-strlen(char))
          endif
        else
          call cursor(lnum, col('.')-strlen(char))
        endif
        continue
      endif
    elseif len != 0 && col == len+1 && onemore
      call cursor(line('.'), col('$'))
      continue
    elseif char =~ separator.'\+' && col < len+1
      call cursor(lnum, col('.')+strlen(char))
      if stop_sep
        continue
      endif
    endif
    let stopline = cmd =~ '[nox]B' ? line('.')-(line('.') != 1) : 0
    let flags = cmd =~ '[nox]B' ? 'b' : ''.'W'
    let flags .= a:count < 0 ? 'c' : ''
    let pos = search(regxp, flags, stopline)
    if pos == 0 && cmd =~ '[nox]B'
      call cursor(line('.')-(line('.') != 1), '1')
    elseif !stop_eol && col('.') == col('$')
      let pos = search(regxp, flags, stopline)
    endif
  endfor
  silent exe 'setlocal virtualedit='.saved_ve

  if cmd =~ 'x[WBE]'
    let nextPos = getpos('.')
    call setpos('.', firstPos)
    exe 'normal! v'
    call setpos('.', nextPos)
  endif
  if cmd == 'oE'
    let char = matchstr(getline(lnum), '.', col-1)
    let char = matchstr(getline(lnum), '.', col+strlen(char)-1)
    if char !~ separator
      call cursor(lnum, col('.')+strlen(char))
    endif
  endif
endfunction

function! s:JpObject(mode, cmd, count)
  let stop_eol = g:jpmoveword_stop_eol
  let stop_sep = g:jpmoveword_stop_separator
  let saved_ve = &virtualedit
  set virtualedit+=onemore
  let g:jpmoveword_stop_eol = 1
  let g:jpmoveword_stop_separator = 0

  for loop in range(a:count)
    call s:JpObjectMove(a:mode, a:cmd)
  endfor

  let g:jpmoveword_stop_eol = stop_eol
  let g:jpmoveword_stop_separator = stop_sep
  let &virtualedit = saved_ve
endfunction

function! s:JpObjectMove(mode, cmd)
  let isVisual = a:mode =~ '[vsx]'
  let direction = 'w'
  let isFirst = 1
  if isVisual
    let vfline = line("'<")
    let vlline = line("'>")
    let vfcol = col("'<")
    let vlcol = col("'>") - (&selection == 'exclusive' ? 1 : 0)
    let isFirst = (vlline == vfline) && (vlcol == vfcol)
  endif

  let space = '[[:space:]　]'
  let isSpace = 0
  let pos1 = getpos('.')

  if isVisual && !isFirst
    exe 'normal! gv'
    let dirpos = getpos('.')
    exe 'normal! v'
    call cursor(vfline, vfcol)
    let direction = dirpos == getpos('.') ? 'b' : 'w'
    if direction == 'w'
      call cursor(vlline, vlcol)
    endif
  else
    if matchstr(getline('.'), '.', col('.')-1) =~ space
      let isSpace = 1
      call search(space.'\+', 'cbW', line('.'))
    else
      call s:JpMoveW('nW', 1)
      call s:JpMoveW('nB', 1)
      if line('.') < pos1[1]
        call cursor(pos1[1], 1)
      endif
    endif
  endif
  let pos1 = getpos('.')

  if direction == 'b'
    call s:moveCmd_ib()
  elseif direction == 'w'
    if col('.') >= col('$') - strlen(matchstr(getline('.'), '.$'))
      call cursor(line('.'), col('$'))
    endif

    let cpos = getpos('.')
    if isSpace || matchstr(getline('.'), '.', col('.')-1) =~ space
      call search(space.'\+', 'cbW', line('.'))
      let spcpos1 = getpos('.')
      let pos = search(space.'\+', 'ceW', line('.'))
      let isSpace = isSpace || cpos != getpos('.')
      let spcpos2 = getpos('.')
    endif

    if col('$') == 1 && !isSpace
      let spcpos1 = getpos('.')
      let isSpace = (search('^[\r\n]'.space.'\+', 'ceW', line('.')+1) > 0)
      let spcpos2 = getpos('.')
    endif
    let isSpace = isSpace && !(isVisual && !isFirst)

    let isOneChar = 0
    let separator = '['.g:jpmoveword_separator.']'
    if !(isVisual && !isFirst)
      let len = strlen(matchstr(getline('.'), '.', col('.')-1))
      let isOneChar = col('.') == 1 || matchstr(getline('.'), '.', col('.')-1-len) =~ separator
      let isOneChar = isOneChar && (col('.') == col('$') || matchstr(getline('.'), '.', col('.')-1+len) =~ separator)
      if !isOneChar
        let isOneChar = col('.') == 1 || matchstr(getline('.'), '.', col('.')-1-len) =~ space
        let isOneChar = isOneChar && (col('.') == col('$') || matchstr(getline('.'), '.', col('.')-1+len) =~ space)
      endif
    endif

    if isSpace
      call setpos('.', spcpos2)
    elseif isOneChar
      let pos1 = col('.')
      call setpos('.', pos1)
    elseif a:cmd == 'i'
      call s:moveCmd_iw()
    elseif a:cmd == 'a'
      call s:moveCmd_aw()
    endif
  endif

  if col('.') == col('$')
    call cursor(line('.'), col('$')-1)
  endif
  let pos2 = getpos('.')

  if isVisual && !isFirst
    exe 'normal! gv'
  else
    call setpos('.', pos1)
    exe 'normal! v'
  endif
  call setpos('.', pos2)
  exe 'normal! vgv'
endfunction

function! s:moveCmd_ib()
  call s:JpMoveW('nB', 1)
  if col('.') >= col('$')-1
    call s:JpMoveW('nB', 1)
  endif
endfunction

function! s:moveCmd_iw()
  call s:JpMoveW('nE', 1)
endfunction

function! s:moveCmd_aw()
  call s:JpMoveW('nE', 1)
  if col('.') < col('$')-strlen(matchstr(getline('.'), '.$'))
    call s:JpMoveW('nW', 1)
    if col('.') != 1 && col('.') < col('$')-strlen(matchstr(getline('.'), '.$'))
      exe 'normal! h'
    endif
  endif
endfunction

let s:cpo_save = &cpo
set cpo&vim
