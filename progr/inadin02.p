{admcab.i}
{setbrw.i}                                                                      
def temp-table tt-cli
    field clicod like clien.clicod.
    
def temp-table tt-finan
        field fincod like fin.finan.fincod
        field finnom like fin.finan.finnom
        field finent like fin.finan.finent
        field finnpc like fin.finan.finnpc
        field marca   as char format "x(1)"
        index idx1 fincod.

def temp-table tit-etb
    field etbcod   like fin.titulo.etbcod
    field valor-vs like fin.titulo.titvlcob
    field valor-vi like fin.titulo.titvlcob
    field vtot-par like fin.titulo.titpar format ">>>>>9"
    field vtot-con as int
    index i2 etbcod.

def temp-table tt-inadim
       field etbcod like estab.etbcod
       field catcod like categoria.catcod
       field clacod like clase.clacod
       field procod like produ.procod
       field val-vi as dec
       field val-vs as dec
       field qtdtit as int
       field qtdcon as int
       index i1 catcod clacod procod.
    
    def var achou as log.
    def var recatu1         as recid.
    def var recatu2         as recid.
    def var reccont         as int.
    def var esqpos1         as int.
    def var esqpos2         as int.
    def var esqregua        as log.
    def var esqvazio        as log.
    def var esqascend     as log initial yes.
    def var esqcom1         as char format "x(15)" extent 5
        initial ["","  MARCA","DESMARCA "," ","  "].
    def var esqcom2         as char format "x(15)" extent 5
        initial ["",""," ","  "," "].
    def var esqhel1         as char format "x(80)" extent 5
        initial ["teste teste",
                 "",
                 "",
                 "",
                 ""].
    def var esqhel2         as char format "x(12)" extent 5
        initial ["teste teste  ",
                 " ",
                 " ",
                 " ",
                 " "].

    form
        esqcom1
        with frame f-com1
                     row 11 no-box no-labels side-labels column 1 centered.
    form
        esqcom2
        with frame f-com2
                     row screen-lines no-box no-labels side-labels column 1
                     centered.
    assign
        esqregua = yes
        esqpos1  = 1
        esqpos2  = 1.
        
form " " 
     " "
     with frame f-linha 5 down color with/cyan /*no-box*/
     centered.

def buffer bcontrato for fin.contrato.
def var vsaldo as dec.
def var vcarteira as dec.
def var vpct as dec.
def var vok as log.
def var vqtd as int.
def var vqtdcont as int.
def var vnovacao as log format "Sim/Nao" init no.
def var vplano as int.
def var vplanosel as char format "x(40)".
def var vprocod like produ.procod.
form vcre as log format  "Geral/Facil" label "Cliente"  at 4
     help "Informe [G]eral ou [F]acil"
     vetbcod like estab.etbcod label "  Filial" 
     estab.etbnom no-label
     vdti as date format "99/99/9999" label "Periodo de" at 1
     vdtf as date format "99/99/9999" label "Ate"
     vcatcod as int label "Categoria"       at 2
     categoria.catnom  format "x(15)" no-label       
     vclacod as int label "Classe"   
     clase.clanom format "x(15)" no-label   
     vprocod label "Produto"   at 4               
     produ.pronom format "x(20)" no-label           
     vplano                           label "Plano"  at 6
     vqtdcont                         label "Qtd. Contratos"
     vnovacao                         label "Novacoes?"
     vplanosel                        label "Planos Selecionados"
     with frame f1 side-label width 80.     

vcre = yes.
update vcre with frame f1.

update vetbcod with frame f1.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        bell.
        message color red/with
        "Filial nao cadastrada."
        view-as alert-box.
        undo.
    end.
    disp estab.etbnom with frame f1.
end.
else disp "Todas " @ estab.etbnom with frame f1.

update vdti vdtf with frame f1.
if vdti = ? or vdtf = ? or vdti > vdtf then do:
        bell.
        message color red/with
        "Periodo invalido para processamento."
        view-as alert-box.
        undo.
end.
 
update vcatcod  with frame f1.
if vcatcod > 0 then do:
   find categoria where categoria.catcod = vcatcod no-lock no-error.
   if not avail categoria then do:
      bell.
      message color red/with
      "Categoria nao cadastrada"
      view-as alert-box.
      undo.
   end.
   disp categoria.catnom with frame f1.
end.
else disp "Todas " @ categoria.catnom with frame f1.  

update vclacod with frame f1.
if vclacod > 0 then do:
    find clase where clase.clacod = vclacod no-lock no-error.
    if not avail clase then do:
        bell.
        message color red/with
        "Classe nao cadastrada."
        view-as alert-box.
        undo.
    end.
    disp clase.clanom with frame f1.
end.
else disp "Todas " @ clase.clanom with frame f1.

update vprocod  with frame f1.
if vprocod > 0 then do:
    find produ where produ.procod = vprocod  no-lock no-error.
    if not avail produ then do:
        bell.
        message color red/with
        "Produto nao cadatrado."
        view-as alert-box.
        undo.
    end.
    disp produ.pronom with frame f1.
end.
else disp "Todos " @ produ.pronom with frame f1.

update vplano with frame f1.

if vplano = 0 then do:
    
    for each fin.finan 
             no-lock:
        find tt-finan where tt-finan.fincod = fin.finan.fincod no-lock no-error.
        if not avail tt-finan then do:
            create tt-finan.
            assign tt-finan.fincod = fin.finan.fincod
                   tt-finan.finnom = fin.finan.finnom
                   tt-finan.finent = fin.finan.finent
                   tt-finan.finnpc = fin.finan.finnpc
                   tt-finan.marca  = "".
        end.
             
    end.         

 /*   disp "                         TABELA DE FINANCIAMENTO      " 
            with frame f3 1 down width 80                                      ~           color message no-box no-label row 14.*/
                                                  
   /* disp " " with frame f2 1 down width 160 color message no-box no-label    ~  ~      row 20.*/                                                                 l1: repeat:
        disp esqcom1 with frame f-com1.
        disp esqcom2 with frame f-com2.
        assign
            a-seeid = -1 a-recid = -1 a-seerec = ?
            esqpos1 = 1 esqpos2 = 1. 
        hide frame f-linha no-pause.
        clear frame f-linha all.
        {sklclstb.i  
            &color  = with/cyan
            &file   = tt-finan  
            &cfield = tt-finan.fincod
            &ofield = "tt-finan.marca tt-finan.finnom tt-finan.finent tt-finan.finnpc"   
            &noncharacter = /* 
            &aftfnd1 = " "
            &where  = "  "
            &aftselect1 = " run aftselect.
                            a-seeid = -1.
                            disp with frame f3.
                            disp with frame f2.
                            disp with frame f-com1.
                            disp with frame f-com2."
            &go-on = TAB 
            &naoexiste1 = " " 
            &otherkeys1 = " run controle. "
            &locktype = " "
            &form   = " frame f-linha "
        }   
        if keyfunction(lastkey) = "end-error"
        then DO:
            leave l1.       
        END.
    end.
hide frame f3 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

end.

    hide frame f-com1.
    hide frame f-com2.

update vqtdcont vnovacao with frame f1 .  
  
pause 0.

def var vdata as date.

form with frame ff11.

form with frame f-disp.
hide frame f3 no-pause.
    hide frame f2 no-pause.
    hide frame ff2 no-pause.
    hide frame f-linha no-pause.


       
    if vcre = no
    then do:
    
        for each tt-cli:
            delete tt-cli.
        end.
      
        for each clien where clien.classe = 1 no-lock:
    
            display clien.clicod
                    clien.clinom
                    clien.datexp format "99/99/9999" with 1 down. pause 0.
    
            create tt-cli.
            assign tt-cli.clicod = clien.clicod.
        end.
    end.
    do vdata = vdti to vdtf:
        
        disp    "Processamdo AGUARDE.... >> "
                vdata with frame ff1.
        pause 0.
        if vcre 
        then do:
            for each estab where
                     estab.etbcod = vetbcod
                  or vetbcod = 0
                     no-lock, 
                each fin.titulo where
                     fin.titulo.empcod = 19 
                 and fin.titulo.titnat = no
                 and fin.titulo.modcod = "CRE" 
                 and fin.titulo.etbcod = estab.etbcod 
                 and fin.titulo.titdtven = vdata 
                     no-lock:

                disp fin.titulo.etbcod fin.titulo.titnum fin.titulo.titdtemi 
                     with frame ff1 1 down no-box no-label.
                pause 0.
                if vnovacao and 
                   fin.titulo.tpcontrato = "" /*titpar < 30*/
                then next.    

                vqtd = 0.
                if vqtdcont > 0
                then do:
                    for each bcontrato where 
                             bcontrato.clicod = fin.titulo.clifor
                             no-lock:
                        vqtd = vqtd + 1.
                    end.   
                    if vqtd > vqtdcont
                    then next.      
                end.
                find fin.contrato where 
                     contrato.contnum = int(fin.titulo.titnum) no-lock no-error.

                if vplano > 0 and
                   vplano <> contrato.crecod
                then next.
                
                if vplano = 0 then do:
                    if not can-find(tt-finan where
                                    tt-finan.fincod = contrato.crecod
                                and tt-finan.marca = "*") then do:
                    next.                                               
                    end.
                end.
                find first tit-etb where
                    tit-etb.etbcod = fin.titulo.etbcod no-lock no-error.
                if not avail tit-etb 
                then do:
                    create tit-etb.
                    tit-etb.etbcod = fin.titulo.etbcod.
                end. 
                
                find first fin.contnf where
                               contnf.etbcod  = fin.titulo.etbcod
                           and contnf.contnum = contrato.contnum
                               no-lock no-error.

                find plani where plani.etbcod = contnf.etbcod and
                                 plani.placod = contnf.placod and
                                 plani.serie  = contnf.notaser
                                 no-lock no-error.
                if avail plani
                then do:
                    vok = no.
                    for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
                                     no-lock:
                        find produ where produ.procod = movim.procod no-lock.
                                                    if vcatcod > 0 and
                           vcatcod <> produ.catcod
                        then next.
                        if vclacod > 0 and
                           vclacod  <> produ.clacod
                        then next.
                        if vprocod > 0 and
                           vprocod <> produ.procod
                        then next.
                        vok = yes.   
                        find first tt-inadim where 
                                   tt-inadim.etbcod = fin.titulo.etbcod and 
                                   tt-inadim.catcod = produ.catcod and
                                   tt-inadim.clacod = produ.clacod and
                                   tt-inadim.procod = produ.procod
                                   no-error.
                        if not avail tt-inadim
                        then do:
                            create tt-inadim.
                            assign
                                tt-inadim.etbcod = fin.titulo.etbcod
                                tt-inadim.catcod = produ.catcod
                                tt-inadim.clacod = produ.clacod
                                tt-inadim.procod = produ.procod
                                .
                        end.
                        assign
                            tt-inadim.val-vs = tt-inadim.val-vs +
                                   (movim.movpc * movim.movqtm)
                            tt-inadim.qtdtit = 0
                            tt-inadim.qtdcon = 0
                            .       
                        if fin.titulo.titsit = "LIB" and
                           fin.titulo.titdtpag = ?
                        then assign
                                tt-inadim.val-vi = tt-inadim.val-vi +
                                    (movim.movpc * movim.movqtm).
                                   
                    end.
                    if vok = yes
                    then do:
                      tit-etb.valor-vs = tit-etb.valor-vs + fin.titulo.titvlcob.
               
                        if fin.titulo.titsit = "LIB" and
                            fin.titulo.titdtpag = ?
                        then do:
                            tit-etb.valor-vi = 
                                tit-etb.valor-vi + fin.titulo.titvlcob.
                        end.
                   end.
                end.
            end.
/***dragao
            if vnovacao = yes
            then do:
            for each estab where 
                     estab.etbcod = vetbcod 
                  or vetbcod = 0 
                     no-lock, 
                each d.titulo where d.titulo.empcod = 19 and
                                  d.titulo.titnat = no and
                                  d.titulo.modcod = "CRE" and
                                  d.titulo.etbcod = estab.etbcod and
                                  d.titulo.titdtven = vdata no-lock:

                disp d.titulo.etbcod d.titulo.titnum d.titulo.titdtemi 
                        with frame ff11 1 down no-box no-label.
                pause 0.
                if vnovacao and 
                   d.titulo.titpar < 30
                then next.    

                vqtd = 0.
                if vqtdcont > 0
                then do:
                    for each bcontrato where 
                             bcontrato.clicod = d.titulo.clifor
                             no-lock:
                        vqtd = vqtd + 1.
                    end.   
                    if vqtd > vqtdcont
                    then next.      
                end.
                find fin.contrato where 
                     contrato.contnum = int(d.titulo.titnum) no-lock no-error.

                if vplano > 0 and
                   vplano <> contrato.crecod
                then next.
                
                if vplano = 0 then do:
                    if not can-find(tt-finan where
                                    tt-finan.fincod = contrato.crecod
                                and tt-finan.marca = "*") then do:
                        next.
                    end.                                               
                end.

                find first tit-etb where
                    tit-etb.etbcod = d.titulo.etbcod no-error.
                if not avail tit-etb 
                then do:
                    create tit-etb.
                    tit-etb.etbcod = d.titulo.etbcod.
                end. 
                
                find first fin.contnf where contnf.etbcod = d.titulo.etbcod and
                                  contnf.contnum = contrato.contnum
                                  no-lock no-error.

                find plani where plani.etbcod = contnf.etbcod and
                                 plani.placod = contnf.placod and
                                 plani.serie  = contnf.notaser
                                 no-lock no-error.
                if avail plani
                then do:
                    vok = no.
                    for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
                                     no-lock:
                        find produ where produ.procod = movim.procod no-lock.
                        if vcatcod > 0 and
                           vcatcod <> produ.catcod
                        then next.
                        if vclacod  > 0 and
                           vclacod  <> produ.clacod
                        then next.
                        if vprocod > 0 and
                           vprocod <> produ.procod
                        then next.
                        vok = yes.   
                        find first tt-inadim where 
                                   tt-inadim.etbcod = d.titulo.etbcod and 
                                   tt-inadim.catcod = produ.catcod and
                                   tt-inadim.clacod = produ.clacod and
                                   tt-inadim.procod = produ.procod
                                   no-error.
                        if not avail tt-inadim
                        then do:
                            create tt-inadim.
                            assign
                                tt-inadim.etbcod = d.titulo.etbcod
                                tt-inadim.catcod = produ.catcod
                                tt-inadim.clacod = produ.clacod
                                tt-inadim.procod = produ.procod
                                .
                        end.
                        assign
                            tt-inadim.val-vs = tt-inadim.val-vs +
                                   (movim.movpc * movim.movqtm)
                            tt-inadim.qtdtit = 0
                            tt-inadim.qtdcon = 0
                            .       
                        if d.titulo.titsit = "LIB" and
                           d.titulo.titdtpag = ?
                        then assign
                                tt-inadim.val-vi = tt-inadim.val-vi +
                                    (movim.movpc * movim.movqtm).
                                   
                    end.
                    if vok = yes
                    then do:
                        tit-etb.valor-vs = tit-etb.valor-vs + 
                                    d.titulo.titvlcob.
               
                        if d.titulo.titsit = "LIB" and
                            d.titulo.titdtpag = ?
                        then do:
                            tit-etb.valor-vi = 
                                tit-etb.valor-vi + d.titulo.titvlcob.
                        end.
                    end.
                end.
            end.
            end.
dragao***/
        end.
        else do:
            for each tt-cli,
                each fin.titulo use-index iclicod where 
                                  fin.titulo.empcod = 19 and
                                  fin.titulo.titnat = no and
                                  fin.titulo.modcod = "CRE" and
                                  fin.titulo.clifor = tt-cli.clicod and
                                  fin.titulo.titdtven = vdata no-lock:
                
                disp fin.titulo.etbcod fin.titulo.titnum fin.titulo.titdtemi 
                    with frame ff1 1 down centered row 15 no-box
                    no-label.
                pause 0.
                if vnovacao and 
                   fin.titulo.tpcontrato = "" /*titpar < 30*/
                then next.  
                if vetbcod > 0 and fin.titulo.etbcod <> vetbcod
                then next.
                
                find first tit-etb where
                    tit-etb.etbcod = fin.titulo.etbcod no-error.
                if not avail tit-etb 
                then do:
                    create tit-etb.
                    tit-etb.etbcod = fin.titulo.etbcod.
                end.   
                tit-etb.valor-vs = tit-etb.valor-vs + fin.titulo.titvlcob.
                if fin.titulo.titsit = "LIB" and
                   fin.titulo.titdtpag = ?
                then do:
                    tit-etb.valor-vi = tit-etb.valor-vi + fin.titulo.titvlcob.
                 
                find contrato where 
                     contrato.contnum = int(fin.titulo.titnum) no-lock no-error.

                if vplano > 0 and
                   vplano <> contrato.crecod
                then next.

                if vplano = 0 then do:
                    if not can-find(tt-finan where
                                    tt-finan.fincod = contrato.crecod
                                and tt-finan.marca = "*") then do:
                    next.                                               
                    end.
                end.
 
                find first contnf where contnf.etbcod = fin.titulo.etbcod and
                                  contnf.contnum = contrato.contnum
                                  no-lock no-error.
                find contrato where 
                     contrato.contnum = int(fin.titulo.titnum) no-lock no-error.
                find plani where plani.etbcod = contnf.etbcod and
                                 plani.placod = contnf.placod and
                                 plani.serie  = contnf.notaser
                                 no-lock no-error.
                if avail plani
                then do:
                    vok = no.
                    for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
                                     no-lock:
                        find produ where produ.procod = movim.procod no-lock.
                        if vcatcod > 0 and
                           vcatcod <> produ.catcod
                        then next.
                        if vclacod  > 0 and
                           vclacod  <> produ.clacod
                        then next.
                        if vprocod > 0 and
                           vprocod <> produ.procod
                        then next.
                        vok = yes.  
                        find first tt-inadim where 
                                   tt-inadim.catcod = produ.catcod and
                                   tt-inadim.clacod = produ.clacod and
                                   tt-inadim.procod = produ.procod
                                   no-error.
                        if not avail tt-inadim
                        then do:
                            create tt-inadim.
                            assign
                                tt-inadim.catcod = produ.catcod
                                tt-inadim.clacod = produ.clacod
                                tt-inadim.procod = produ.procod
                                .
                        end.
                        assign
                            tt-inadim.val-vs = tt-inadim.val-vs +
                                   (movim.movpc * movim.movqtm)
                            tt-inadim.qtdtit = 0
                            tt-inadim.qtdcon = 0
                            .       
                        if fin.titulo.titsit = "LIB" and
                           fin.titulo.titdtpag = ?
                        then assign
                                tt-inadim.val-vi = tt-inadim.val-vi +
                                    (movim.movpc * movim.movqtm).
                                   
                    end.
                    if vok = yes
                    then do:
                        tit-etb.valor-vs = tit-etb.valor-vs + fin.titulo.titvlcob.
               
                        if fin.titulo.titsit = "LIB" and
                        fin.titulo.titdtpag = ?
                        then do:
                            tit-etb.valor-vi = 
                                tit-etb.valor-vi + fin.titulo.titvlcob.
                        end.
                    end.
                end.
                end.
            end.
/***dragao
            if vnovacao = yes
            then do:
            for each tt-cli,
                each d.titulo use-index iclicod where 
                                  d.titulo.empcod = 19 and
                                  d.titulo.titnat = no and
                                  d.titulo.modcod = "CRE" and
                                  d.titulo.clifor = tt-cli.clicod and
                                  d.titulo.titdtven = vdata no-lock:
                
                disp d.titulo.etbcod d.titulo.titnum d.titulo.titdtemi 
                    with frame ff11 1 down centered row 15 no-box
                    no-label.
                pause 0.
                if vnovacao and 
                   d.titulo.titpar < 30
                then next.  
                if vetbcod > 0 and d.titulo.etbcod <> vetbcod
                then next.
                
                find first tit-etb where
                    tit-etb.etbcod = d.titulo.etbcod no-lock no-error.
                if not avail tit-etb 
                then do:
                    create tit-etb.
                    tit-etb.etbcod = d.titulo.etbcod.
                end.   
                tit-etb.valor-vs = tit-etb.valor-vs + d.titulo.titvlcob.
                if d.titulo.titsit = "LIB" and
                   d.titulo.titdtpag = ?
                then do:
                    tit-etb.valor-vi = tit-etb.valor-vi + d.titulo.titvlcob.
                 
                find contrato where 
                     contrato.contnum = int(d.titulo.titnum) no-lock no-error.

                if vplano > 0 and
                   vplano <> contrato.crecod
                then next.
                
                if vplano = 0 then do:
                    if not can-find(tt-finan where
                                    tt-finan.fincod = contrato.crecod
                                and tt-finan.marca = "*") then do:
                    next.                                               
                    end.
                end.

                    
                find first contnf where contnf.etbcod = d.titulo.etbcod and
                                  contnf.contnum = contrato.contnum
                                  no-lock no-error.
                find plani where plani.etbcod = contnf.etbcod and
                                 plani.placod = contnf.placod and
                                 plani.serie  = contnf.notaser
                                 no-lock no-error.
                if avail plani
                then do:
                    vok = no.
                    for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
                                     no-lock:
                        find produ where produ.procod = movim.procod no-lock.
                        if vcatcod > 0 and
                           vcatcod <> produ.catcod
                        then next.
                        if vclacod  > 0 and
                           vclacod  <> produ.clacod
                        then next.
                        if vprocod  > 0 and
                           vprocod  <> produ.procod
                        then next.
                        vok = yes.  
                        find first tt-inadim where 
                                   tt-inadim.catcod = produ.catcod and
                                   tt-inadim.clacod = produ.clacod and
                                   tt-inadim.procod = produ.procod
                                   no-error.
                        if not avail tt-inadim
                        then do:
                            create tt-inadim.
                            assign
                                tt-inadim.catcod = produ.catcod
                                tt-inadim.clacod = produ.clacod
                                tt-inadim.procod = produ.procod
                                .
                        end.
                        assign
                            tt-inadim.val-vs = tt-inadim.val-vs +
                                   (movim.movpc * movim.movqtm)
                            tt-inadim.qtdtit = 0
                            tt-inadim.qtdcon = 0
                            .       
                        if d.titulo.titsit = "LIB" and
                           d.titulo.titdtpag = ?
                        then assign
                                tt-inadim.val-vi = tt-inadim.val-vi +
                                    (movim.movpc * movim.movqtm).
                                   
                    end.
                    if vok = yes
                    then do:
                        tit-etb.valor-vs = 
                            tit-etb.valor-vs + d.titulo.titvlcob.
               
                        if d.titulo.titsit = "LIB" and
                        d.titulo.titdtpag = ?
                        then do:
                            tit-etb.valor-vi = 
                                tit-etb.valor-vi + d.titulo.titvlcob.
                        end.
                    end.
                end.
                end.
            end.
            end.
***/
        end.
    end.

    def var varquivo as char.
    if opsys = "UNIX"
    then  varquivo = "../relat/cartl" + string(day(today)).
    else  varquivo = "..\relat\cartw" + string(day(today)).
 
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""inadin01""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """RELATORIO DE INADINPLENCIA"""
            &Width     = "130"
            &Form      = "frame f-cabcab"}

    DISP WITH FRAME F1.
    vcarteira = 0. vsaldo = 0. vpct = 0.
    for each tit-etb by tit-etb.etbcod:
        find estab where estab.etbcod = tit-etb.etbcod no-lock.
        vpct = (tit-etb.valor-vi / tit-etb.valor-vs) * 100 .
        
        disp tit-etb.etbcod 
             estab.etbnom no-label
             tit-etb.valor-vs column-label "Carteira"  format ">>,>>>,>>9.99"
             tit-etb.valor-vi column-label "Saldo" format ">>,>>>,>>9.99"
             vpct format ">>>,>>9.99%"
             with frame f-disp down width 120.
        down with frame f-disp.
        vcarteira = vcarteira + tit-etb.valor-vs.
        vsaldo    = vsaldo    + tit-etb.valor-vi.
        /**
        for each tt-inadim where
                 tt-inadim.etbcod = tit-etb.etbcod
                 break by tt-inadim.catcod by tt-inadim.clacod 
                 :
            find produ where produ.procod = tt-inadim.procod
                    no-lock.
            disp tt-inadim.catcod column-label "Cat"               
                 tt-inadim.clacod column-label "Classe"
                 tt-inadim.procod column-label "Produto"
                 produ.pronom no-label   
                 /*tt-inadim.val-vi (sub-total by tt-inadim.catcod)
                    column-label "Valor" format ">>>,>>9.99" */
                 with frame f-disp.
            down with frame f-disp.
        end.        
        **/
    end.
    down(2) with frame f-disp.
    disp vcarteira @ tit-etb.valor-vs
         vsaldo    @ tit-etb.valor-vi
         (vsaldo / vcarteira) * 100   @ vpct
              with frame f-disp.
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}.
    end.  

procedure controle:
        def var ve as int.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    esqpos1 = 1.
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    do ve = 1 to 5:
                    color display normal esqcom2[ve] with frame f-com2.
                    end.
                    esqpos2 = 1.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-lef1"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
end procedure.

procedure aftselect:

    if esqcom1[esqpos1] = "  MARCA"
    THEN DO on error undo:
        assign tt-finan.marca = "*".
        assign vplanosel = if vplanosel = "" then string(tt-finan.fincod) else vplanosel + "," + string(tt-finan.fincod).
        disp skip vplanosel with frame f1.
    end.        
    if esqcom1[esqpos1] = "DESMARCA " THEN DO:
        assign tt-finan.marca = " "
               vplanosel      = " "
               achou          = no.
        for each tt-finan where
                 tt-finan.marca = "*" no-lock:
            assign achou = yes.     
            assign vplanosel = if vplanosel = "" then string(tt-finan.fincod) else vplanosel + "," + string(tt-finan.fincod).
            disp skip vplanosel with frame f1.
        end.         
        if achou = no then do:
           assign vplanosel = "".
           disp skip vplanosel with frame f1.
        end.
    END.
   /* if esqcom1[esqpos1] = " MARCA TODOS "
    THEN DO:
        for each tt-finan
                 exclusive-lock:
          assign tt-finan.marca = "*"
                 vplanosel = "Todos".
        end.
        disp skip vplanosel with frame f1.
    END.
    if esqcom1[esqpos1] = " DESMARCA TODOS "
    THEN DO:
        for each tt-finan
                 exclusive-lock:
          assign tt-finan.marca = " "
                 vplanosel = " ".
        end.
        disp skip vplanosel with frame f1.
    END.*/
end procedure.


 
