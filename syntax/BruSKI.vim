" Vim syntax file
" Language: BruSKI
" Maintainer: Nicklas Botö
" Latest Revision: 2 July 2020

if exists("b:current_syntax")
    finish
endif

syn keyword bruKeywords INT CHR UNL PRT
hi def link bruKeywords Function

syn keyword bruImport contained import
syn keyword bruDefine contained define
syn region bruLangdef start="{!" end="!}" fold transparent contains=bruImport,bruDefine

hi def link bruImport Include
hi def link bruDefine Define
hi def link bruLangdef Special

syn match bruAbs /λ\+/
hi def link bruAbs Special

syn match bruAss ':='
hi def link bruAss Keyword

syn match bruDef '::'
syn match bruDef '!!'
hi def link bruDef Keyword

syn match bruVar /\w\+/ nextgroup=bruAss
" hi def link bruVar Statement

syn match bruInt '\d\+'
hi def link bruInt Number

syn keyword bruCommentTodo contained TODO FIXME
syn cluster bruCommentGrp  contains=bruCommentTodo
syn region bruComment start="--" skip="\\$" end="$" keepend contains=@bruCommentGrp
syn region bruComment start="{-" end="-}" contains=@bruCommentGrp
syn region bruAnnounce start="--!--" skip="\\$" end="$" keepend contains=@bruCommentGrp

hi def link bruCommentTodo Todo
hi def link bruComment     Comment
hi def link bruAnnounce    Todo