{admcab.i}

def var vetbcod like estab.etbcod.

def var vescolha as char format "x(30)" extent 3.
vescolha[1] = "TODOS OS PRODUTOS".
vescolha[2] = "SEM DESCONTINUADOS ".
vescolha[3] = "SOMENTE DESCONTINUADOS".

def var pro-mix as log.
def var cla-mix as log.
def buffer c-tabmix for tabmix.
def buffer e-tabmix for tabmix.
def buffer p-tabmix for tabmix.
def var vcatcod like categoria.catcod.
vcatcod = 31.

find categoria where categoria.catcod = vcatcod no-lock.
disp vcatcod at 6 label "Setor"
     categoria.catnom no-label
     with frame f1 width 80 side-label.

update vetbcod at 5 label "Filial"
        with frame f1.
if vetbcod <> 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
end.
else 
    disp "Geral" @ estab.etbnom no-label with frame f1.
    
def var vforcod like forne.forcod .
update vforcod at 1 label "Fornecedor"
    with frame f1.
if vforcod > 0
then do:
    find forne where forne.forcod = vforcod 
            no-lock no-error.
    if not avail forne
    then do:
        message color red/with
            "Fornecedor nao cadastrado."
            view-as alert-box.
        undo.
    end.
    disp forne.fornom no-label with frame f1.        
end.
else disp "GERAL" @ FORNE.FORNOM with frame f1.
def var vclacod like clase.clacod.
update vclacod at 5 label "Classe" with frame f1.
if vclacod > 0
then do:
    find clase where clase.clacod = vclacod no-lock no-error.
    if not avail clase
    then do:
        message color red/with
            "Classe nao cadastrada."
            view-as alert-box.
        undo.
    end.
    disp clase.clanom no-label with frame f1.
end.
else disp "GERAL" @ clase.clanom with frame f1.            

def var vcobertura as int.
update vcobertura at 50 label "Cobertura >=" with frame f1 .

def var vindex as int.
disp vescolha with frame f-esco centered 1 column no-label.
choose field vescolha with frame f-esco.
vindex = frame-index.
hide frame f-esco.
disp vescolha[vindex] with frame f-es 
    1 down no-box color message no-label.
def var vmovqtm like movim.movqtm.
def temp-table tt-cober
    field etbcod  like estab.etbcod
    field procod like produ.procod
    field pronom like produ.pronom
    field estatual like estoq.estatual
    field cobertura as dec
    field v90 as dec
    field estvenda like estoq.estvenda
    field estcusto like estoq.estcusto
    field mix as log format "Sim/Nao"
    index i1 procod
    index i2 etbcod cobertura descending.
    

def buffer bestab for estab.

def var vqtdsug as int.
def var vdiasvenda as int.

def temp-table tt-fil
    field etbcod like estab.etbcod
    field diasvenda as int.

if vetbcod <> 0
then do:
    create tt-fil.
    tt-fil.etbcod = vetbcod.
    if vetbcod = 993
    then do:
        create tt-fil.
        tt-fil.etbcod = 995.
    end.    
end.
else do:
   for each estab no-lock:
       find first tt-fil where tt-fil.etbcod = estab.etbcod no-error.
       if not avail tt-fil 
       then do:
            create tt-fil.
            tt-fil.etbcod = estab.etbcod.
            if estab.etbcod = 993 then do:
               create tt-fil.
               tt-fil.etbcod = 995.
            end.
       end. 
   end.
end.

def var vestoque as log.
def var vqtdest like estoq.estatual.
for each produ where produ.catcod = vcatcod 
/*and produ.procod = 408138 */
no-lock:
    find clase where clase.clacod = produ.clacod no-lock.
    disp "Processando...-->> " produ.proco format ">>>>>>>>9"
                        produ.pronom format "x(30)" skip
         "                    A G U A R D E ! " 
        with frame f-disp 1 down no-label row 14 centered
        no-box color message.
    pause 0.
    if produ.pronom begins "*"
    then do:
        if vindex = 2
        then next.
    end.
    else if vindex = 3
        then next.
    
    if vforcod > 0 and
       vforcod <> produ.fabcod
    then next.
       
    if vclacod > 0 and
       vclacod <> produ.clacod and
       vclacod <> clase.clasup
    then next. 
    vestoque = no.  
    vqtdest = 0.
    for each tt-fil no-lock:  
        find estoq where estoq.procod = produ.procod and
                     estoq.etbcod = tt-fil.etbcod and
                     estoq.estatual > 0
                     no-lock no-error.
        if avail estoq 
        then do:

            find first tt-cober where tt-cober.etbcod = tt-fil.etbcod and
                                      tt-cober.procod = produ.procod  no-error.
            if not avail tt-cober
            then do: 
                create tt-cober.
                tt-cober.etbcod    = tt-fil.etbcod.
                tt-cober.procod    = produ.procod.
                tt-cober.pronom    = produ.pronom.
                tt-cober.estvenda   = estoq.estvenda.
                tt-cober.estcusto  = estoq.estcusto.
                run tem-mix.
                if pro-mix = yes
                then tt-cober.mix = yes.
            end.
            tt-cober.estatual  = tt-cober.estatual + estoq.estatual.
            vestoque = yes.
        end.
    end.          
    
    if vestoque = no
    then next.
    
    find first estoq where estoq.procod = produ.procod and
                     estoq.estvenda > 0
                     no-lock no-error.
    if not avail estoq then next.
    vmovqtm = 0.
    
    vdiasvenda = 0.
    run prazo-analise.
    if vetbcod <> 993
    then
    for each bestab /*where bestab.etbnom begins "DREBES-FIL"*/  no-lock,
        first tt-fil WHERE TT-FIL.ETBCOD = bestab.etbcod  no-lock:
        if tt-fil.etbcod > 0 and
           tt-fil.etbcod <> 993 and
           tt-fil.etbcod <> bestab.etbcod
        then next .  
        
        assign vmovqtm = 0.              
        
        for each movim where 
             movim.etbcod = bestab.etbcod and
             movim.movtdc = 5 and
             movim.procod = produ.procod and
             movim.movdat >= today - tt-fil.diasvenda
                  no-lock:
            vmovqtm = vmovqtm + movim.movqtm .                    
        end.
        find first tt-cober where tt-cober.etbcod = tt-fil.etbcod and
                                  tt-cober.procod = produ.procod  no-error.
        if avail tt-cober 
        then tt-cober.v90       = tt-cober.v90 + vmovqtm.
            
        if vetbcod = 0 and tt-fil.etbcod <> 993
        then do:
        find first tt-cober where tt-cober.etbcod = 993 and
                                  tt-cober.procod = produ.procod  no-error.
        if avail tt-cober 
        then tt-cober.v90       = tt-cober.v90 + vmovqtm .
        end.
     end.
     else if vetbcod = 993
     then do:
        for each tt-fil where tt-fil.etbcod = 993 no-lock:
            assign vmovqtm = 0.              
            for each bestab no-lock:
                for each movim where 
                    movim.etbcod = bestab.etbcod and
                    movim.movtdc = 5 and
                    movim.procod = produ.procod and
                    movim.movdat >= today - tt-fil.diasvenda
                  no-lock:
                    vmovqtm = vmovqtm + movim.movqtm .                    
                 end.
            end.
            find first tt-cober 
                where tt-cober.etbcod = tt-fil.etbcod and
                      tt-cober.procod = produ.procod  no-error.
            if not avail tt-cober then next.
            assign
                tt-cober.v90       = tt-cober.v90 + vmovqtm.
                                                            /*
                tt-cober.cobertura = tt-cober.cobertura + 
                            (tt-cober.estatual / (vmovqtm / tt-fil.diasvenda)).
            */
        end.
     end.
end.

for each tt-cober :
    find first tt-fil where tt-fil.etbcod = tt-cober.etbcod no-error.                                  
        tt-cober.cobertura = tt-cober.cobertura + 
                            (tt-cober.estatual / 
                            (tt-cober.v90 / tt-fil.diasvenda)).
        if tt-cober.cobertura = ?
        then tt-cober.cobertura = 0.
        if  vcobertura > 0 and
            tt-cober.cobertura < vcobertura
        then delete tt-cober.  

end.

hide frame f-disp no-pause.
/****
disp vcatcod at 6 label "Setor"
     categoria.catnom no-label
     vetbcod at 5 label "Filial"
     estab.etbnom no-label 
     vforcod at 40 label "Fornecedor"
     forne.fornom no-label
     vclacod at 5 label "Classe" 
     clase.clanom no-label 
     vcobertura at 50 label "Cobertura" 
    with frame f12 width 80 side-label.
*****/

{setbrw.i}                                                                      

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","","","",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["  RELATORIO","  ARQUIVO CSV","","",""].
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
                 row 8 no-box no-labels side-labels column 1 centered
                 OVERLAY.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


form 
      tt-cober.etbcod   column-label "Fil"       format ">>9"
      tt-cober.procod   column-label "Codigo"    format ">>>>>>>9"
      tt-cober.pronom   column-label "Descricao" format "x(27)"
      tt-cober.estatual column-label "Est."   format ">>>9"
      tt-cober.v90      column-label "Venda"     format ">>>9"
      tt-cober.cobertura column-label "Cob."   format ">>>>>9"
      tt-cober.estcusto  column-label "Pr.Custo" format ">>,>>9.99"
      tt-cober.estvenda  column-label "Pr.Venda" format ">>,>>9.99"
     with frame f-linha 8 down color with/cyan /*no-box*/
     centered width 80 overlay row 9.
                                                        
                                                                         
/**                                                                                
disp "                  COBERTURA DE ESTOQUE      " 
            with frame f11 1 down width 80
            color message no-box no-label row 8 overlay.
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.  
 */                                                                      
def buffer btbcntgen for tbcntgen.                            
def var i as int.

if not can-find(first tt-cober)
then do:
     message "Nao encontrou cobertura".
     pause 6.
     leave.
end.
     
l1: repeat:
    /*
    disp esqcom1 with frame f-com1.
    */
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tt-cober  
        &cfield =  tt-cober.procod
        &noncharacter = /* 
        &ofield = " tt-cober.etbcod
                    tt-cober.pronom
                    tt-cober.v90
                    tt-cober.estatual
                    tt-cober.cobertura 
                    tt-cober.estvenda
                    tt-cober.estcusto  "  
        &aftfnd1 = " "
        &where  = " "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        "
        &go-on = TAB 
        &naoexiste1 = "  " 
        &otherkeys1 = " run controle. "
        &locktype = " use-index i2 "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
        
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
    
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        
    END.
    if esqcom2[esqpos2] = "  RELATORIO"
    THEN DO on error undo:
        run relatorio.
    END.
    if esqcom2[esqpos2] = "  ARQUIVO CSV"
    THEN DO on error undo:
        run arquivo-csv.
    END.


end procedure.

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
            if keyfunction(lastkey) = "cursor-left"
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

                     
procedure prazo-analise:

def buffer b-tt-fil for tt-fil.

for each b-tt-fil: 

    find first tbcntgen where
               tbcntgen.tipcon = 3 and 
               tbcntgen.etbcod = b-tt-fil.etbcod and
               tbcntgen.numfim = string(vcatcod) and
               tbcntgen.numini = string(produ.clacod) and
               (tbcntgen.validade = ? or
                tbcntgen.validade >= today)
           no-lock no-error.
    if not avail tbcntgen
    then find first tbcntgen where
                    tbcntgen.tipcon = 3 and 
                    tbcntgen.etbcod = 0 and
                    tbcntgen.numfim = string(vcatcod) and
                    tbcntgen.numini = string(produ.clacod) and
                    (tbcntgen.validade = ? or
                    tbcntgen.validade >= today)
                    no-lock no-error.
     if not avail tbcntgen
     then find first tbcntgen where
                    tbcntgen.tipcon = 3 and 
                    tbcntgen.etbcod = b-tt-fil.etbcod and
                    tbcntgen.numfim = string(vcatcod) and
                    tbcntgen.numini = string(0) and
                    (tbcntgen.validade = ? or
                     tbcntgen.validade >= today)
           no-lock no-error.
      if not avail tbcntgen
      then find first tbcntgen where
           tbcntgen.tipcon = 3 and 
           tbcntgen.etbcod = 0 and
           tbcntgen.numfim = string(vcatcod) and
           tbcntgen.numini = string(0) and
           (tbcntgen.validade = ? or
           tbcntgen.validade >= today)
           no-lock no-error.


    if avail tbcntgen
    then do:
        find first movim where movim.procod = produ.procod 
                   and movim.etbcod = b-tt-fil.etbcod
                   and movim.movdat < today - tbcntgen.quantidade
                   no-lock no-error. 
        if avail movim
        then b-tt-fil.diasvenda = tbcntgen.quantidade.
        else do:
            find first movim where movim.procod = produ.procod 
                           and movim.etbcod = b-tt-fil.etbcod
                   no-lock no-error. 
            if avail movim
            then b-tt-fil.diasvenda = today - movim.movdat.
            else b-tt-fil.diasvenda = tbcntgen.quantidade.
         end.
    end.
    else b-tt-fil.diasvenda = 90.
    
    b-tt-fil.diasvenda = 30.
    
end.
end procedure.
              
def buffer sub-clase for clase.
                     
procedure relatorio:
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/cobertura"  + string(time).
    else varquivo = "l:\relat\cobertura" + string(time).
                                    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""rcobert1"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """ COBERTURA DE ESTOQUE """ 
                &Width     = "80"
                &Form      = "frame f-cabcab"}
    disp with frame f1.
    for each tt-cober use-index i2:
        find produ where produ.procod = tt-cober.procod no-lock.
        find sub-clase where 
             sub-clase.clacod = produ.clacod no-lock.
        find clase where
             clase.clacod = sub-clase.clasup no-lock.
        disp 
            tt-cober.etbcod   column-label "Etbcod"    format ">>9"
            tt-cober.procod   column-label "Codigo"    format ">>>>>>>9"
            clase.clanom      column-label "Clase" format "x(20)"
            sub-clase.clanom  column-label "Sub-Clase" format "x(20)"
            tt-cober.pronom   column-label "Descricao" format "x(30)"
            tt-cober.estatual column-label "Est."   format ">>>9"
            tt-cober.v90      column-label "Venda"     format ">>>9"
            tt-cober.cobertura column-label "Cob."   format ">>>>>9"
            tt-cober.estcusto  column-label "Pr.Custo" format ">>,>>9.99"
            tt-cober.estvenda  column-label "Pr.Venda" format ">>,>>9.99"
            tt-cober.mix       column-label "Mix" format "Sim/Nao"
            with frame f-linhar down width 140.
        down with frame f-linhar.
    end. 
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.    
    else do:
        {mrod.i}
    end.                
end procedure.

procedure arquivo-csv:
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/cobertura"  + string(vetbcod) + ".csv".
    else varquivo = "l:\relat\cobertura" + string(vetbcod) + ".csv".
    message "Arquivo:" update varquivo format "x(70)".
    output to value(varquivo).
    
    put unformatted 
        "Estab ; Codigo ; Classe ; Sub Classe ; Descricao ; Est. ; Venda ; Cob. ; Pr.Cu~ sto ; Pr.Venda" 
        skip.
    def var vchar-cober as char.
        
    for each tt-cober use-index i2:
        if tt-cober.cobertura = 0
        then vchar-cober = "SEM VENDA".
        else vchar-cober = string(tt-cober.cobertura,">>>>>9").

        find produ where produ.procod = tt-cober.procod no-lock.
        find sub-clase where 
             sub-clase.clacod = produ.clacod no-lock.
        find clase where
             clase.clacod = sub-clase.clasup no-lock.
 
        put unformatted 
            tt-cober.etbcod  format ">>9"
            ";"
            tt-cober.procod  format ">>>>>>>9"
            ";"
            clase.clanom       format "x(20)"
            ";"
            sub-clase.clanom   format "x(20)"
            ";"
            tt-cober.pronom    format "x(30)"
            ";"
            tt-cober.estatual  format ">>>>>9"
            ";"    
            tt-cober.v90       format ">>>>>9"
            ";"
            vchar-cober        format "x(15)"
            /*
            tt-cober.cobertura  format ">>>>>>9"
            */
            ";"
            tt-cober.estcusto  format ">>>,>>9.99"
            ";"    
            tt-cober.estvenda   format ">>>,>>9.99"
            ";"
            tt-cober.mix format "Sim/Nao" 
            skip.
    end. 
    output close.
    if opsys = "unix"
    then do:
        run visurel.p(varquivo,"").
    end.
end procedure. 

procedure tem-mix:
    cla-mix = no.
    pro-mix = no.
        find first c-tabmix where c-tabmix.tipomix = "F" and
                          c-tabmix.codmix  <> 99 and
                          c-tabmix.promix  = produ.clacod 
                          no-lock no-error.
        if avail c-tabmix
        then do:
                                              
            for each tabmix where tabmix.tipomix = "M" and
                      tabmix.codmix  < 99 no-lock:
                find p-tabmix where p-tabmix.tipomix = "P" and
                             p-tabmix.codmix  = tabmix.codmix and
                             p-tabmix.promix  = produ.procod
                             no-lock no-error.
                if avail p-tabmix
                then do:
                    pro-mix = yes.
                    leave.
                end.    
            end.
        end.
end.                                                              


