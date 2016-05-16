function! s:SortTimeStamps(lhs, rhs)
    return a:lhs[1] > a:rhs[1]
endfunction

function! s:Close(nb_to_keep)
    let saved_buffers = filter(range(0, bufnr('$')), 'buflisted(v:val) && ! getbufvar(v:val, "&modified")')
    let times = map(copy(saved_buffers), '[(v:val), getftime(bufname(v:val))]')
    call filter(times, 'v:val[1] > 0')
    call sort(times, function('s:SortTimeStamps'))
    let nb_to_keep = min([a:nb_to_keep, len(times)])
    let buffers_to_strip = map(copy(times[0:(nb_to_keep-1)]), 'v:val[0]')
    exe 'bw '.join(buffers_to_strip, ' ') 
endfunction

" Two ways to use it
" - manually
command! -nargs=1 CloseOldBuffers call s:Close(<args>)
" - or automatically
augroup CloseOldBuffers
    au!
    au BufNew * call s:Close(g:nb_buffers_to_keep)
augroup END
" and don't forget to set the option in your .vimrc
let g:nb_buffers_to_keep = 42
