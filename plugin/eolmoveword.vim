"----------------------------------------
" MyMoveWord.vim
"----------------------------------------
""""""""""""""""""""""""""""""
" 行末停止w,b,eコマンド
" w,b,eのカーソルを行末(eol)でも一旦停止させます。
"
" オプション
" moveword_enable_wbe = 1 : wbeを本プラグインで置き換える
"
" moveword_stop_eol = 0 : 行末をまたぐ時になにもしない
" moveword_stop_eol = 1 : 行末をまたぐ時にeolで停止
" moveword_stop_eol = 2 : 行末をまたぐ時に行末文字で停止
" * 1と2はvirtualeditを設定しない限り違いはありません
"----------------------------------------
scriptencoding utf-8

let s:cpo_save = &cpo
set cpo&vim

if !exists('moveword_enable_wbe')
  let moveword_enable_wbe = 1
endif
if !exists('moveword_stop_eol')
  let moveword_stop_eol = 1
endif
let loaded_moveword = 1

au VimEnter * call <SID>movewordKeymap()
function! s:movewordKeymap()
  if !g:moveword_enable_wbe
    return
  endif
  nmap <silent> w <Plug>EolMove_w
  nmap <silent> b <Plug>EolMove_b
  nmap <silent> e <Plug>EolMove_e
endfunction

nnoremap <silent> <Plug>EolMove_w :<C-U>call <SID>eolMove('w', v:count1)<CR>
nnoremap <silent> <Plug>EolMove_b :<C-U>call <SID>eolMove('b', v:count1)<CR>
nnoremap <silent> <Plug>EolMove_e :<C-U>call <SID>eolMove('e', v:count1)<CR>

function! s:eolMove(cmd, count)
  let eol = g:moveword_stop_eol
  let cnt = a:count - (eol != 0)
  if cnt > 0
    exe 'normal! '.cnt.a:cmd
  endif
  if !eol
    return
  endif

  let prev = getpos('.')
  exe 'normal! '.a:cmd
  let post = getpos('.')

  if prev[1] != post[1]
    if a:cmd == 'w' || (a:cmd == 'e' && &virtualedit =~ 'onemore')
      let char = matchstr(getline(prev[1]), '.$')
      let len = strlen(getline(prev[1]))
      let len += ((&virtualedit =~ 'onemore' && eol != 2) ? 1 : 1 - strlen(char))
      if prev[2] != len
        let prev[2] = len
        call setpos('.', prev)
      endif
    elseif a:cmd == 'b'
      let post[2] = col('$') - (eol == 2)*strlen(matchstr(getline(post[1]), '.$'))
      call setpos('.', post)
    endif
  endif
endfunction

let s:cpo_save = &cpo
set cpo&vim

