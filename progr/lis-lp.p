{admcab.i}
def var vgeral like titulo.titvlcob.
def stream stela.
def var vtot like titulo.titvlcob.
def temp-table tt-tit like titulo.
for each tt-tit:
    delete tt-tit.
end.
input from ..\work9\titluc.d.
output stream stela to terminal.
repeat:
    create tt-tit.
    import tt-tit.
    disp stream stela tt-tit.clifor with frame f-tela 1 down. pause 0. 
end.
input close.
output stream stela close.



        {mdadmcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""LIS-LP""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """SALDO EM ABERTO"""
            &Width     = "130"
            &Form      = "frame f-cabcab"}
 

for each tt-tit no-lock break by tt-tit.clifor:
    if tt-tit.titsit = "LIB"
    then assign vtot = vtot + tt-tit.titvlcob
                vgeral = vgeral + tt-tit.titvlcob.


    if last-of(tt-tit.clifor)
    then do:
        find clien where clien.clicod = tt-tit.clifor no-lock no-error.
        disp tt-tit.clifor 
             clien.clinom when avail clien
             vtot column-label "Total!Aberto"
                with frame f-lista down width 80.
             vtot = 0.
    end.
end.

display vgeral label "Total Geral" with frame f-geral side-label centered.
output close.


    
