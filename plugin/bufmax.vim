function! s:SortTimeStamps(lhs, rhs)
    return a:lhs[1] < a:rhs[1]
endfunction

function! s:Close(nb_to_keep)
    let saved_buffers = filter(range(1, bufnr('$')), 'buflisted(v:val) && !getbufvar(v:val, "&modified") && "" == getbufvar(v:val, "&buftype") && (index(g:whitelist_buffers, bufname(v:val)) < 0)')
    " echom 'all saved_buffers=' . join(saved_buffers, ' ')
    let times = map(copy(saved_buffers), '[(v:val), getbufvar(v:val, "buf_open_time"), bufname(v:val)]')
    call filter(times, 'v:val[1] > 0')
    call sort(times, function('s:SortTimeStamps'))
    " echom 'times descendingly ordered=' . join(times, ' ')
    if a:nb_to_keep < len(times) + 1
        let nb_to_keep = min([a:nb_to_keep, len(times)])
        " echom 'nb_to_keep=' . nb_to_keep . ', len(times)=' . len(times)
        " echom 'buffers_to_strip=' . join(copy(times[nb_to_keep-1:-1]), ' ')
        let buffers_to_strip = map(copy(times[nb_to_keep-1:-1]), 'v:val[0]')
        exe 'bw '.join(buffers_to_strip, ' ') 
    endif
endfunction

" Two ways to use it
" - manually
command! -nargs=1 CloseOldBuffers call s:Close(<args>)
" - or automatically
augroup CloseOldBuffers
    au!
    au BufAdd * let b:buf_open_time=localtime() | call s:Close(g:nb_buffers_to_keep)
augroup END
if !exists('g:nb_buffers_to_keep')
    " and don't forget to set the option in your .vimrc
    let g:nb_buffers_to_keep = 10
endif

if !exists('g:whitelist_buffers')
    " these buffers shall not be closed
    let g:whitelist_buffers = ['NERD', 'MiniBufExplorer', 'Help']
endif
