{admcab.i}

def var vdata as date.
def var vdti  as date.
def var vdtf  as date.
def var vsetcod like setaut.setcod.
def var vetbcod like estab.etbcod.
def var vforcod like forne.forcod.
def var vfatnum like fatudesp.fatnum format ">>>>>>>>9".
def var vetbfun as int.
def var vfuncod as int.
 
form with frame f1.

do on error undo with frame f1 1 down side-label width 80.
 
    update vsetcod label "Setor".
    if vsetcod > 0
    then do:
        find setaut where setaut.setcod = vsetcod no-lock no-error.
        if not avail setaut
        then do:
            message "Setor nao cadastrado".
            undo, retry.
        end.
        disp setaut.setnom no-label with frame f1 .
        pause 0.
    end.
    update vetbcod at 1 label "Filial" .
    if vetbcod > 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message color red/with
            "Estabelecimento nao cadastrado"
            view-as alert-box.
            undo, retry.
        end.
        disp estab.etbnom no-label.
        pause 0. 
    end.
    update vforcod at 1 label "Fornecedor".
    if vforcod > 0
    then do:
        find forne where 
             forne.forcod = vforcod no-lock no-error.
        if not avail forne
        then do:
            undo, retry.
        end.     
        disp forne.fornom no-label.
        pause 0.
    end.
    update vfatnum at 1 label "Numero".
    
    update vdti at 1 label "Inclusao de" format "99/99/9999"
           vdtf label "Ate" format "99/99/9999".
end.
def buffer modctb for modal.

def var varquivo as char.
def var vobs as char.

varquivo = "/admcom/relat/rfatdes1." + string(time).

{mdad.i &Saida     = "value(varquivo)" 
                        &Page-Size = "64" 
                        &Cond-Var  = "80" 
                        &Page-Line = "64" 
                        &Nom-Rel   = ""tablan"" 
                        &Nom-Sis   = """SISTEMA CONTABILIDADE""" 
                        &Tit-Rel   = """LISTAGEM DESPESAS SETOR"""
                        &Width     = "80"  
                        &Form      = "frame f-cabcab"}
                        .
DISP WITH FRAME F1.                        
def var vtotal-tit as dec. 
for each fatudesp where 
         (if vsetcod > 0 then fatudesp.setcod = vsetcod else true) and
         (if vetbcod > 0 then fatudesp.etbcod = vetbcod else true) and
         (if vforcod > 0 then fatudesp.clicod = vforcod else true) and
         (if vfatnum > 0 then int(fatudesp.fatnum) = vfatnum else true) and
         (if vdti <> ? then fatudesp.inclusao >= vdti else true) and
         (if vdtf <> ? then fatudesp.inclusao <= vdtf else true)
         no-lock:
    find forne where forne.forcod = fatudesp.clicod no-lock.    
    find modal where modal.modcod = fatudesp.modcod no-lock. 
    find modctb where modctb.modcod = fatudesp.modctb no-lock.
    vetbfun = int(acha("FILIAL", fatudesp.char1)).
    vfuncod = int(acha("FUNC", fatudesp.char1)). 
    find first func where 
                   func.etbcod = vetbfun and
                   func.funcod = vfuncod
                   no-lock no-error.

    disp fill("=",80) format "x(80)"
         
         fatudesp.etbcod to 40 label "Filial"
         fatudesp.setcod to 40
         func.funcod to 40 when avail func
         func.funnom no-label when avail func
         fatudesp.modcod to 40 label "Modalidade FIN"
         modal.modnom no-label
         fatudesp.modctb to 40 label "Modalidade CTB"
         modctb.modnom no-label
         fatudesp.numerodi to 40 label "Processo"
         fatudesp.fatnum  to 40  format ">>>>>>>>9"
         fatudesp.clicod  to 40
         forne.fornom    no-label
         forne.forcgc     to 50 label "CNPJ/CPF" format "x(20)"
         fatudesp.emissao   to 40
         fatudesp.inclusao  to 40 label "Data Inclusao"
         fatudesp.val-total to 40 label "Valor Total"
         fatudesp.val-icms  to 40 label "Valor ICMS"
         fatudesp.val-ipi   to 40 label "Valor IPI"
         fatudesp.val-acr   to 40 label "Valor Acrescimo"
         fatudesp.val-des   to 40 label "Valor Desconto"
         fatudesp.val-ir    to 40 label "Valor IRRF"
         fatudesp.val-iss   to 40 label "Valor ISS" 
         fatudesp.val-inss  to 40 label "Valor INSS"
         fatudesp.val-pis   to 40 label "Valor PIS" 
         fatudesp.val-cofins to 40 label "Valor COFINS"
         fatudesp.val-csll   to 40  label "Valor CSLL"
         fatudesp.val-liquido to 40 label "Valor Liquido" 
         fatudesp.qtd-parcela to 40 label "Quantidade Parcelas"
         with frame f-disp  side-label
         width 100
             .
    vtotal-tit = 0.
    for each tituctb where
             tituctb.clifor = fatudesp.clicod and
             tituctb.titnum = string(int(fatudesp.fatnum)) and
             tituctb.titdtemi = fatudesp.inclusao
             no-lock:
        disp tituctb.titnum
                         tituctb.titdtemi
                         tituctb.titdtven
                         tituctb.modcod
                         tituctb.titvlcob  format ">,>>>,>>9.99"
                         tituctb.etbcod column-label "Fil"
                         tituctb.titbanpag column-label "Set"
                    with frame ftit-tctb width 100 down
                    .
                    down with frame ftit-tctb.
    end.
    
    put skip(3).
    
    for each titulo where
             titulo.empcod = 19 and
             /*titulo.titnat = yes and
             titulo.modcod = fatudesp.modcod and*/
             titulo.etbcod = fatudesp.etbcod and
             titulo.clifor = fatudesp.clicod and
             titulo.titnum = string(int(fatudesp.fatnum)) and
             titulo.titdtemi = fatudesp.inclusao
             no-lock break by titulo.titnum by titulo.titpar:
        vtotal-tit = vtotal-tit + titulo.titvlcob.
        if last-of(titulo.titpar)
        then do:
            for each titudesp where
                         titudesp.clifor = fatudesp.clicod and
                         titudesp.titnum = string(int(fatudesp.fatnum)) and
                         titudesp.titpar = titulo.titpar
                         no-lock:
                    disp titudesp.titnum
                         titudesp.titpar
                         titudesp.titdtemi
                         titudesp.titdtven
                         titudesp.modcod
                         titudesp.titvlcob  format ">,>>>,>>9.99"
                         titudesp.etbcod column-label "Fil"
                         titudesp.titbanpag column-label "Set"
                    with frame ftit-t width 100 down
                    .
                    down with frame ftit-t.
            
                end.
                vtotal-tit = 0.
               /*
            disp titulo.titnum
             titulo.titpar
             titulo.titdtemi
             titulo.titdtven
             vtotal-tit  format ">,>>>,>>9.99"
             with frame ftit width 100 down
             .

            down with frame ftit.
            vtotal-tit = 0.
            */
            
            vobs = "OBS: " + titulo.titobs[1] + " " + titulo.titobs[2].
            disp substr(vobs,1,70) no-label format "x(70)"
                 substr(vobs,71,70) no-label format "x(70)"
                 with frame f-obs side-label width 100.
            
        end.
    end.         
end.             

/*
put skip(60).

page.
*/
put skip(10).

if vfatnum > 0
then do:
    put skip(5).
    for each fatudesp where 
         (if vsetcod > 0 then fatudesp.setcod = vsetcod else true) and
         (if vetbcod > 0 then fatudesp.etbcod = vetbcod else true) and
         (if vforcod > 0 then fatudesp.clicod = vforcod else true) and
         (if vfatnum > 0 then int(fatudesp.fatnum) = vfatnum else true) and
         (if vdti <> ? then fatudesp.inclusao >= vdti else true) and
         (if vdtf <> ? then fatudesp.inclusao <= vdtf else true)
         no-lock:
        find forne where forne.forcod = fatudesp.clicod no-lock.    
        find modal where modal.modcod = fatudesp.modcod no-lock. 
    
    vetbfun = int(acha("FILIAL", fatudesp.char1)).
    vfuncod = int(acha("FUNC", fatudesp.char1)). 
    find first func where 
                   func.etbcod = vetbfun and
                   func.funcod = vfuncod
                   no-lock no-error.

    vtotal-tit = 0.
    for each titulo where
             titulo.empcod = 19 and
             /*titulo.titnat = yes and
             titulo.modcod = fatudesp.modcod and*/
             titulo.etbcod = fatudesp.etbcod and
             titulo.clifor = fatudesp.clicod and
             titulo.titnum = string(int(fatudesp .fatnum)) and
             titulo.titdtemi = fatudesp.inclusao
             no-lock break by titulo.titnum by titulo.titpar:
        vtotal-tit = vtotal-tit + titulo.titvlcob.
        if last-of(titulo.titpar)
        then do:     
        disp 
         fatudesp.etbcod at 1 label "Filial"
         fatudesp.setcod
         func.funcod when avail func
         func.funnom no-label when avail func
         fatudesp.modcod
         modal.modnom no-label 
         fatudesp.fatnum format ">>>>>>>>9"
         fatudesp.clicod
         forne.fornom    no-label
         forne.forcgc     
         fatudesp.emissao   
         fatudesp.inclusao  
         with frame f-disp1  side-label
         width 100
             .
        disp titulo.titnum
             titulo.titpar
             titulo.titdtemi
             titulo.titdtven
             vtotal-tit  format ">,>>>,>>9.99"
             with frame ftit1 width 100 down
             .
        down with frame ftit1.
        vtotal-tit = 0.
        put skip(10).
        end.
    end.         
end.  
end.         
OUTPUT CLOSE.
run visurel.p(varquivo,"").
       
