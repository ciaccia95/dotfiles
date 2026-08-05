" ==============================================================================
" Autocommands
" ==============================================================================

augroup antonello_filetypes
  autocmd!

  " Python uses four spaces per indentation level.
  autocmd FileType python setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4

  " Makefile recipes require literal tab characters.
  autocmd FileType make setlocal noexpandtab tabstop=8 shiftwidth=8 softtabstop=0
augroup END
