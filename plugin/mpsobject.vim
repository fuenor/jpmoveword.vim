"----------------------------------------
" mpsobject.vim
"----------------------------------------
""""""""""""""""""""""""""""""
" 「matchpairsテキストオブジェクト」
" % の移動範囲を対象とするテキストオブジェクト
" 移動範囲はmatchpairsやmatchit.vimで設定する
" (matchit.vimは%の移動範囲を正規表現やバッファ単位で変更可能)

" オプション
" matchpairs_textobject = 1 : matchpairsテキストオブジェクトを有効にする
"
""""""""""""""""""""""""""""""
scriptencoding utf-8

let s:cpo_save = &cpo
set cpo&vim
let loaded_mpsobject = 1

" matchpairsテキストオブジェクトを有効化
if !exists('matchpairs_textobject')
  let matchpairs_textobject = 1
endif

au VimEnter * call <SID>mpsobjectKeymap()
function! s:mpsobjectKeymap()
  if !g:matchpairs_textobject
    return
  endif
  omap <silent> i% <Plug>MatchPairsObjctIon
  xmap <silent> i% <Plug>MatchPairsObjctIxn
  omap <silent> a% <Plug>MatchPairsObjctAon
  xmap <silent> a% <Plug>MatchPairsObjctAxn
  if g:matchpairs_textobject > 1
    omap <silent> im <Plug>MatchPairsObjctIon
    xmap <silent> im <Plug>MatchPairsObjctIxn
    omap <silent> am <Plug>MatchPairsObjctAon
    xmap <silent> am <Plug>MatchPairsObjctAxn
    omap <silent> ij <Plug>MatchPairsObjctIoj
    xmap <silent> ij <Plug>MatchPairsObjctIxj
    omap <silent> aj <Plug>MatchPairsObjctAoj
    xmap <silent> aj <Plug>MatchPairsObjctAxj
  endif
endfunction

onoremap <silent> <Plug>MatchPairsObjctIon :<C-U>call <SID>mpsobject('o', 'i', 'b')<CR>
xnoremap <silent> <Plug>MatchPairsObjctIxn :<C-U>call <SID>mpsobject('x', 'i', 'b')<CR>
onoremap <silent> <Plug>MatchPairsObjctAon :<C-U>call <SID>mpsobject('o', 'a', 'b')<CR>
xnoremap <silent> <Plug>MatchPairsObjctAxn :<C-U>call <SID>mpsobject('x', 'a', 'b')<CR>
let g:mps_jsep = '（:）,「:」,『:』,《:》,〈:〉,｛:｝,［:］,【:】,‘:’,“:”'
onoremap <silent> <Plug>MatchPairsObjctIoj :<C-U>call <SID>mpsobject('o', 'i', 'b', g:mps_jsep)<CR>
xnoremap <silent> <Plug>MatchPairsObjctIxj :<C-U>call <SID>mpsobject('x', 'i', 'b', g:mps_jsep)<CR>
onoremap <silent> <Plug>MatchPairsObjctAoj :<C-U>call <SID>mpsobject('o', 'a', 'b', g:mps_jsep)<CR>
xnoremap <silent> <Plug>MatchPairsObjctAxj :<C-U>call <SID>mpsobject('x', 'a', 'b', g:mps_jsep)<CR>

function! s:mpsobject(mode, cmd, op, ...)
  let isVisual = a:mode =~ '[vsx]'
  let prevPos = getpos('.')
  let [col, line] = [col('.'), line('.')]
  let mps = &matchpairs
  if a:0
    let mps .= a:1
  endif
  let sstr = printf('[%s]', substitute(mps, ':.,', '', 'g'))
  let flag = 'ncbW'
  let addflag = ''
  if isVisual
    let fline = line("'<")
    let lline = line("'>")
    let fcol = col("'<")
    let lcol = col("'>") - (&selection == 'exclusive' ? 1 : 0)
    let first = (lline == fline) && (lcol == fcol)
    call cursor(fline, fcol)
    if !first
      let add = 0
      let [firstCol, firstLine, lastCol, lastLine] = s:getmpscol(mps)
      if fline == firstLine && lline == lastLine
        if a:cmd == 'a' && fcol ==firstCol && lcol == lastCol
          let add = 1
        else
          let [firstCol, firstLine, lastCol, lastLine] = s:getmpscol(mps, 'iw')
          if fcol == firstCol && lcol == lastCol
            let add = 1
          endif
        endif
      endif
      if add
        let pos = search(sstr, 'bcW')
        let pos = search(sstr, 'bW')
        if pos == 0
          call cursor(line, col)
          if isVisual
            exe 'normal! gv'
          endif
          return
        endif
      endif
    endif
  endif
  let pos = search(sstr, flag)
  if pos == 0
    call cursor(line, col)
    if isVisual
      exe 'normal! gv'
    endif
    return
  endif
  while (pos != 0)
    let [firstCol, firstLine, lastCol, lastLine] = s:getmpscol(mps)
    if (((firstLine == lastLine) && (firstCol == lastCol)) || (lastLine < line))
      call cursor(line, col)
      if isVisual
        exe 'normal! gv'
      endif
      return
    endif
    if (((firstLine < line) || (firstLine == line) && (firstCol <= col)) && ((lastLine > line) || (lastLine == line) && (lastCol >= col)))
      break
    endif
    let pos = search(sstr, 'bW')
  endwhile
  " ()かどうか
  let [fcol, fline, lcol, lline] = s:getmpscol(mps, 'iw')
  if fline < 0
    call cursor(line, col)
    if isVisual
      exe 'normal! gv'
    endif
    return
  endif
  call cursor(firstLine, firstCol)
  " TODO: matchit.vim使用時には b:match_wordsのキーワード末尾へ移動させる？
  if 0 && exists('b:match_words')
    " matchend()
    echoe 'Not implemented'
  else
    let char = matchstr(getline('.'), '.', col('.')-1)
    if char =~ '[[:alpha:]]'
      exe 'normal! e'
    endif
  endif
  exe 'normal! v'
  if a:cmd == 'i'
    if col('.') != col('$')
      exe 'normal! l'
    else
      call cursor(firstLine+1, 1)
    endif
  endif
  exe 'normal! o'
  call cursor(lastLine, lastCol)
  if a:cmd == 'i'
    if lastCol != 1
      exe 'normal! h'
    else
      call cursor(lastLine-1, col('$'))
    endif
  endif
  return
endfunction

function! s:getmpscol(mps, ...)
  let [col, line] = [col('.'), line('.')]
  let saved_mps = &matchpairs
  let &matchpairs = a:mps
  exe 'normal %'
  let [col1, line1] = [col('.'), line('.')]
  exe 'normal %'
  let [col2, line2] = [col('.'), line('.')]
  let firstCol  = line1 < line2 ?  col1 :  col2
  let firstLine = line1 < line2 ? line1 : line2
  let lastCol   = line1 < line2 ?  col2 :  col1
  let lastLine  = line1 < line2 ? line2 : line1
  if line1 == line2
    let firstCol  = col1 <= col2 ? col1 : col2
    let firstLine = col1 <= col2 ? line1 : line2
    let lastCol   = col1 <= col2 ? col2 : col1
    let lastLine  = col1 <= col2 ? line2 : line1
  endif
  let &matchpairs = saved_mps
  call cursor(line, col)

  if a:0
    " inner wordを返す
    let char = matchstr(getline(firstLine), '.', firstCol-1)
    let width = strlen(char)
    if firstLine == lastLine && firstCol+width == lastCol
      return [-1, -2, -3, -4]
    endif
  endif
  return [firstCol, firstLine, lastCol, lastLine]
endfunction

let s:cpo_save = &cpo
set cpo&vim

