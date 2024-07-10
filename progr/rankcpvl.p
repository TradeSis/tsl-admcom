{admcab.i}

def var val_acr like plani.platot.
def var val_des like plani.platot.
def var val_dev like plani.platot.
def var val_com like plani.platot.
def var val_fin like plani.platot.

def var vcatcod like categoria.catcod.
def var v-total     as dec.
def var d           as date.
def var varqsai     as char.
def var varquivo    as char.

def temp-table ttvend
    field etbcod    like plani.etbcod
    field funcod    like plani.vencod 
    field usercod   like func.usercod
    field qtd-ven   as int
    field qtd-con   as int
    field qtd-cli   as int
    field val-vis   as dec
    field val-pra   as dec
    field val-tot   as dec
    field numseq as int
    field numloj as int
    index valor     val-tot desc
    index vencod funcod etbcod.

def temp-table ttvend1
    field etbcod    like plani.etbcod
    field funcod    like plani.vencod
    field usercod like func.usercod
    field qtd-ven   as int
    field qtd-con   as int
    field qtd-cli   as int
    field val-vis   as dec
    field val-pra   as dec
    field val-tot   as dec
    field numseq as int
    field numloj as int
    .

def var v-nome      like estab.etbnom.


def var v-titven    as char.
def var v-titvenpro as char.

def var tot-vis as dec.
def var tot-pra as dec.
def var tot-ger as dec.
def var p-vende     like func.funcod.
def var i           as int.
def var vdti        as date format "99/99/9999" no-undo label "Dt.Ini".
def var vdtf        as date format "99/99/9999" no-undo label "Dt.Fin".
def var v-valor     as dec.

def buffer sclase   for clase.
def buffer grupo    for clase.
def var p-loja      like estab.etbcod.

form
    ttvend1.numseq   column-label "Rk" format ">>9" 
    ttvend1.numloj   column-label "RLj" format ">>9" 
    ttvend1.etbcod   column-label "L" format ">>9" 
    ttvend1.funcod   column-label "Cod" format ">>>9"
    ttvend1.usercod  format "x(8)" column-label "Fol" 
    func.funnom     format "x(9)" column-label "Nome" 

    ttvend1.qtd-ven  format ">>>>9" column-label "Qtd!Ven"
    ttvend1.qtd-con  format ">>>>9" column-label "Qtd!Con"
    ttvend1.qtd-cli  format ">>>>9" column-label "Qtd!Cli" 
    ttvend1.val-vis  format ">>>,>>9.99" column-label "Venda(2)!Vista" 
    ttvend1.val-pra  format ">>>,>>9.99" column-label "Venda(2)!Prazo"
    ttvend1.val-tot  format ">>>>,>>9.99" column-label "Venda(2)!Total"
    with frame f-vend width 80 down  title v-titven.

form
    ttvend1.numseq   column-label "Rk" format ">>9" 
    ttvend1.numloj   column-label "RLj" format ">>9" 
    ttvend1.etbcod   column-label "L" format ">>9" 
    ttvend1.funcod   column-label "Cod" format ">>>9"
    func.funnom      format "x(9)" column-label "Nome"
    ttvend1.usercod  format "x(8)" column-label "Fol" 
     
    ttvend1.qtd-ven  format ">>>>>9" column-label "Qtd!Ven"
    ttvend1.qtd-con  format ">>>>>9" column-label "Qtd!Con"
    ttvend1.qtd-cli  format ">>>>>9" column-label "Qtd!Cli" 
    ttvend1.val-vis  format ">>>>,>>9.99" column-label "Venda(2)!Vista" 
    ttvend1.val-pra  format ">>>>,>>9.99" column-label "Venda(2)!Prazo"
    ttvend1.val-tot  format ">>>>>,>>9.99" column-label "Venda(2)!Total"
    with frame f-vend1 width 100 down.
     
form
    p-loja label "Filial" 
    estab.etbnom no-label format "x(60)"
    vcatcod at 1 label "Setor" format ">>" 
    categoria.catnom no-label format "x(7)"
    vdti   at 1 label "Periodo de"
    vdtf    label "Ate"
    with frame f-loja
        width 80
        1 down side-labels title " Parametros iniciais ". 

hide frame f-opcao. clear frame f-opcao all.

for each ttvend :
        delete ttvend.
end.    
clear frame f-loja all.
{selestab.i p-loja f-loja} 

def var v31 as log.
def var v41 as log.

def temp-table tt-cli
    field clicod  like clien.clicod
    field etbcod  like estab.etbcod
    field funcod  like func.funcod
    field usercod like func.usercod
    field qtd-ven as int
    index i1 clicod etbcod funcod
    .
   
do:
    vcatcod = 0.
    update vcatcod with frame f-loja.  
    
    if vcatcod > 0
    then do: 
        find categoria where categoria.catcod = vcatcod no-lock no-error. 
        if not avail categoria 
        then do: 
            message "Categoria nao Cadastrada". 
            undo. 
        end. 
        else disp categoria.catnom with frame f-loja.
    end.
    else disp "Geral" @ categoria.catnom with frame f-loja.

    vdti = today.
    vdtf = today.
    
    update vdti
           vdtf with frame f-loja.

    if vdti = ? or vdtf = ? or vdti > vdtf 
    then do :
        bell. bell.
        message "Periodo invalido".
        pause. clear frame f-loja all.
        next.
    end.    

    for each tt-lj no-lock:
        find estab where estab.etbcod = tt-lj.etbcod no-lock no-error.
        if not avail estab then next.
        
        for each plani where plani.movtdc = 5 
                         and  plani.etbcod = estab.etbcod and
                              plani.pladat >= vdti and
                              plani.pladat <= vdtf 
                           no-lock : 

            find clien where clien.clicod = plani.desti no-lock no-error.
            if not avail clien then next.
            disp "Processando ...."
                plani.etbcod plani.pladat with frame f11 
                    centered row 10 1 down no-labels. pause 0.
            v31 = no.
            v41 = no.
            for each movim where movim.etbcod = plani.etbcod and
                               movim.placod = plani.placod and
                               movim.movtdc = plani.movtdc
                               no-lock: 
                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail movim
                then next.      
                if produ.catcod = 31
                then do:
                    v41 = no.
                    v31 = yes.
                    leave.
                end.
                if produ.catcod = 41
                then v41 = yes.
            end.  
            if vcatcod = 41 and
               v41 = no then next.
            if vcatcod = 31 and
               v31 = no then next.
               
            find first func where func.funcod = plani.vencod 
                                  and func.etbcod = plani.etbcod  
                                no-lock no-error.
            if not avail func
            then do :
                find first func where func.etbcod = 0     
                        and func.funcod = plani.vencod
                                    no-lock no-error.
                if not avail func
                then next.
            end.
            v-valor = 0.     
            /*    
            if plani.biss > 0
            then v-valor = plani.biss.
            else v-valor = plani.platot - plani.vlserv.
            */
            
            val_acr = 0.
            val_des = 0.
                                    
            if plani.biss > (plani.platot - plani.vlserv)
            then assign val_acr = plani.biss -
                        (plani.platot - plani.vlserv).
            else val_acr = plani.acfprod.
                                                
            if val_acr < 0 or val_acr = ?
            then val_acr = 0.
            
            assign val_des = val_des + plani.descprod.
                        
            assign
                v-valor = (plani.platot - /* plani.vlserv -*/
                   val_des + val_acr).
                   
            find first ttvend where ttvend.funcod = func.funcod    
                                and ttvend.etbcod = func.etbcod
                                  no-error.
            if not avail ttvend
            then do:
                create ttvend.
                ttvend.etbcod = func.etbcod.
                ttvend.funcod = func.funcod.
                ttvend.usercod = func.usercod.
            end.
            
            ttvend.qtd-ven = ttvend.qtd-ven + 1              .
            if plani.crecod = 2
            then do:
                ttvend.val-pra = ttvend.val-pra + v-valor.
                find first contnf where contnf.etbcod = plani.etbcod and
                        contnf.placod = plani.placod
                        no-lock no-error.
                if avail contnf
                then do:
                    find contrato where contrato.contnum = 
                            contnf.contnum no-lock no-error.
                    if avail contrato
                    then ttvend.qtd-con = ttvend.qtd-con + 1.        
                end.
            end.
            else ttvend.val-vis = ttvend.val-vis + v-valor.

            find first tt-cli where 
                       tt-cli.clicod = clien.clicod and
                       tt-cli.etbcod = func.etbcod and
                       tt-cli.funcod = func.funcod
                       no-error.
            if not avail tt-cli  
            then do:
                create tt-cli.
                assign
                    tt-cli.clicod = clien.clicod
                    tt-cli.etbcod = func.etbcod 
                    tt-cli.funcod = func.funcod
                    tt-cli.usercod = func.usercod
                    ttvend.qtd-cli = ttvend.qtd-cli + 1
                    .
            end.
            tt-cli.qtd-ven = tt-cli.qtd-ven + 1.                
        end.
        
    end.
end.
    
hide frame f11.
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
    initial ["","  Relatorio","  Ranking","",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
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
                 row 8 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


disp "                             RANKING DE VENDEDORES       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 7 overlay.
                   
/*                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
*/

run ranking(1).

pause 0.

l1: repeat:
    clear frame f-com1 all.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1. 
    disp esqcom1 with frame f-com1.
    hide frame f-linha no-pause.
    clear frame f-linha all.
    pause 0.
    {sklclstb.i  
        &color = with/cyan
        &file = ttvend1  
        &cfield = ttvend1.funcod
        &noncharacter = /* 
        &ofield = "  
                 ttvend1.val-vis
                        ttvend1.val-pra
                        func.funnom
                        ttvend1.usercod
                        ttvend1.val-tot
                        ttvend1.numseq
                        ttvend1.qtd-ven
                        ttvend1.qtd-con
                        ttvend1.qtd-cli
                        ttvend1.numloj
                        ttvend1.etbcod                 "  
        &aftfnd1 = " 
                    find first func where 
                            func.funcod = ttvend1.funcod 
                           and func.etbcod = ttvend1.etbcod no-lock no-error.
                  if not avail func
                  then find first func where func.funcod = ttvend1.funcod
                                         and func.etbcod = 0 no-lock. 
                     "
        &where  = " true "
        &aftselect1 = " run aftselect.
                        if esqcom1[esqpos1] = ""  ranking""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  bell.
                        leave l1. " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-vend "
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
    if esqcom1[esqpos1] = "  Relatorio"
    THEN DO on error undo:
        run relatorio.    
    END.
    if esqcom1[esqpos1] = "  Ranking"
    THEN DO:
        run ranking(0).
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        
    END.
    if esqcom2[esqpos2] = "    "
    THEN DO on error undo:
    
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

procedure relatorio:

    def var tot-ven as int.
    def var tot-con as int.
    def var tot-cli as int.
    def var tot-tot as dec.
    
    tot-vis = 0.
    tot-pra = 0.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/corkven" + string(time).
    else varquivo = "..\relat\corkven" + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "60"
        &Cond-Var  = "80"
        &Page-Line = "66"
        &Nom-Rel   = ""CORKVEN9""
        &Nom-Sis   = """SISTEMA COMERCIAL"""  
        &Tit-Rel   = """ RANKING DE VENDEDORES """ 
        &Width     = "110"
        &Form      = "frame f-cabcab"}

    disp with frame f-loja.
        
    for each ttvend1:

           find func where func.funcod = ttvend1.funcod and
                           func.etbcod = ttvend1.etbcod no-lock no-error.
           disp ttvend1.numseq
                ttvend1.numloj
                ttvend1.etbcod
                ttvend1.funcod
                ttvend1.usercod
                func.funnom when avail func
                ttvend1.qtd-ven
                ttvend1.qtd-con
                ttvend1.qtd-cli
                ttvend1.val-vis
                ttvend1.val-pra
                ttvend1.val-tot
                with frame f-vend1.
            
           down with frame f-vend1.

           assign
                tot-ven = tot-ven + ttvend1.qtd-ven
                tot-con = tot-con + ttvend1.qtd-con
                tot-cli = tot-cli + ttvend1.qtd-cli
                tot-vis = tot-vis + ttvend1.val-vis
                tot-pra = tot-pra + ttvend1.val-pra
                tot-tot = tot-tot + ttvend1.val-tot
                .
    end.
    down(1) with frame f-vend1.
    disp tot-ven @ ttvend1.qtd-ven
         tot-con @ ttvend1.qtd-con
         tot-cli @ ttvend1.qtd-cli
         tot-vis @ ttvend1.val-vis
         tot-pra @ ttvend1.val-pra
         tot-tot @ ttvend1.val-tot
         with frame f-vend1.
         
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end. 
    
end procedure.

procedure ranking:
    def input parameter p-index as int.
    if p-index = 0
    then do:
        def var v-esc as char extent 6 format "x(15)".
        assign
        v-esc[1] = " VENDA TOTAL "    
         v-esc[2] = " VENDA PRAZO "
          v-esc[3] = " VENDA VISTA "
           v-esc[4] = " QTD CLIENTES "
            v-esc[5] = " QTD CONTRATOS "
             v-esc[6] = " QTD VENDA "
              .
        disp v-esc with frame f-esc 1 down row 10 centered no-label
           1 column .
        choose field v-esc with frame f-esc.
        p-index = frame-index.
        hide frame f-esc.
    end.  
    for each ttvend1: delete ttvend1. end.
         
    if p-index = 1
    then do:
        i = 1.
        tot-vis = 0. 
        tot-pra = 0.
        tot-ger = 0.
        
        for each ttvend :
            ttvend.val-tot = ttvend.val-vis + ttvend.val-pra.
        end. 
        
        for each ttvend break by ttvend.val-tot desc :
            ttvend.numseq = i.
            i = i + 1.
            assign  tot-vis = tot-vis + ttvend.val-vis
                    tot-pra = tot-pra + ttvend.val-pra
                    tot-ger = tot-ger + ttvend.val-vis + ttvend.val-pra
                    .
        end.           
        i = 0.                
        for each ttvend break by ttvend.etbcod
                                 by ttvend.val-tot desc :
            if first-of(ttvend.etbcod) 
            then i = 1.
            ttvend.numloj = i.
            i = i + 1.
        end. 
        for each ttvend break by ttvend.val-tot descending:
            create ttvend1.
            buffer-copy ttvend to ttvend1.
        end.    
    end.
    if p-index = 2
    then do:
        i = 1.
        
        for each ttvend break by ttvend.val-pra desc :
            ttvend.numseq = i.
            i = i + 1.
        end.           
        i = 0.                
        for each ttvend break by ttvend.etbcod
                                 by ttvend.val-pra desc :
            if first-of(ttvend.etbcod) 
            then i = 1.
            ttvend.numloj = i.
            i = i + 1.
        end. 
        for each ttvend break by ttvend.val-pra descending:
            create ttvend1.
            buffer-copy ttvend to ttvend1.
        end.       end.
    if p-index = 3
    then do:
        i = 1.
        
        for each ttvend break by ttvend.val-vis desc :
            ttvend.numseq = i.
            i = i + 1.
        end.           
        i = 0.                
        for each ttvend break by ttvend.etbcod
                                 by ttvend.val-vis desc :
            if first-of(ttvend.etbcod) 
            then i = 1.
            ttvend.numloj = i.
            i = i + 1.
        end. 
        for each ttvend break by ttvend.val-vis descending:
            create ttvend1.
            buffer-copy ttvend to ttvend1.
        end.       end.
    if p-index = 4
    then do:
        i = 1.
        
        for each ttvend break by ttvend.qtd-cli desc :
            ttvend.numseq = i.
            i = i + 1.
        end.           
        i = 0.                
        for each ttvend break by ttvend.etbcod
                                 by ttvend.qtd-cli desc :
            if first-of(ttvend.etbcod) 
            then i = 1.
            ttvend.numloj = i.
            i = i + 1.
        end. 
        for each ttvend break by ttvend.qtd-cli descending:
            create ttvend1.
            buffer-copy ttvend to ttvend1.
        end.       end.
    if p-index = 5
    then do:
        i = 1.
        
        for each ttvend break by ttvend.qtd-con desc :
            ttvend.numseq = i.
            i = i + 1.
        end.           
        i = 0.                
        for each ttvend break by ttvend.etbcod
                                 by ttvend.qtd-con desc :
            if first-of(ttvend.etbcod) 
            then i = 1.
            ttvend.numloj = i.
            i = i + 1.
        end. 
        for each ttvend break by ttvend.qtd-con descending:
            create ttvend1.
            buffer-copy ttvend to ttvend1.
        end.       end.
    if p-index = 6
    then do:
        i = 1.
        
        for each ttvend break by ttvend.qtd-ven desc :
            ttvend.numseq = i.
            i = i + 1.
        end.           
        i = 0.                
        for each ttvend break by ttvend.etbcod
                                 by ttvend.qtd-ven desc :
            if first-of(ttvend.etbcod) 
            then i = 1.
            ttvend.numloj = i.
            i = i + 1.
        end. 
        for each ttvend break by ttvend.qtd-ven descending:
            create ttvend1.
            buffer-copy ttvend to ttvend1.
        end.       
    end.
end procedure.

/***
procedure procat:

    if p-loja <> 0
    then do:
    
        find first estab where estab.etbcod = p-loja no-lock.

    do d = vdti to vdtf :

        for each plani where plani.movtdc = 5 
                         and  plani.etbcod = estab.etbcod and
                               plani.pladat = d 
                           no-lock  
                           use-index pladat:

          disp "Processando ...."
                plani.etbcod plani.pladat with frame f11 
                    centered row 10 1 down no-labels. pause 0.

            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat no-lock.

                find produ where produ.procod = movim.procod no-lock.
                if produ.catcod <> vcatcod then next.

            find first func where func.funcod = plani.vencod 
                                  and func.etbcod = plani.etbcod  
                                no-lock no-error.
            if not avail func
            then do :
                find first func where func.etbcod = 0                          ~                      and func.funcod = plani.vencod
                                    no-lock no-error.
                if not avail func
                then next.
            end.
                    
            v-valor = (movim.movpc * movim.movqtm).
                
            find first ttvend where ttvend.funcod = func.funcod                ~                    and ttvend.etbcod = func.etbcod
                                    use-index vencod
                                  no-error.
            if not avail ttvend
            then do:
                create ttvend.
                ttvend.etbcod = func.etbcod.
                ttvend.funcod = func.funcod.
            end.
            if plani.movtdc = 5 
            then do :
                ttvend.qtd = ttvend.qtd + 1.                                   

                /**acres*/
                
                val_fin = 0.                   
                val_des = 0.  
                val_dev = 0.  
                val_acr = 0. 
                         
                val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.acfprod.
                if val_acr = ? then val_acr = 0.
                
                val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.descprod.
                if val_des = ? then val_des = 0.
                
                val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.vlserv.
                if val_dev = ? then val_dev = 0.
                
                if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
                then
                    val_fin =  ((((movim.movpc * movim.movqtm) 
                            - val_dev - val_des) / 
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).
                if val_fin = ? then val_fin = 0.
                
                val_com = (movim.movpc * movim.movqtm) - 
                          val_dev - val_des + val_acr + val_fin. 
                if val_com = ? then val_com = 0.
                
                ttvend.platot = ttvend.platot + val_com.
                if plani.pladat = vdtf
                then ttvend.pladia = ttvend.pladia + val_com.
                
                /*******/
                
                /*ttvend.platot = ttvend.platot + v-valor.
                if plani.pladat = vdtf
                then ttvend.pladia = ttvend.pladia + v-valor.*/
            end.    

          end.          
          
        end.
    
        for each plani where plani.movtdc = 12
                     and  plani.etbcod = estab.etbcod                          ~                       and  plani.pladat = d
                           no-lock  
                           use-index pladat:
                          
            disp "Processando ...."
                plani.etbcod plani.pladat with frame f21
                    centered row 10 1 down no-labels. pause 0.

            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat no-lock.
                find produ where produ.procod = movim.procod no-lock.
                if produ.catcod <> vcatcod then next.
                     
            find first func where func.funcod = plani.vencod 
                                  and func.etbcod = plani.etbcod
                                no-lock no-error.
            if not avail func 
            then do :
                find first func where func.etbcod = 0
                                      and func.funcod = plani.vencod
                                    no-lock no-error.
                if not avail func
                then next.
            end.
            v-valor = (movim.movpc * movim.movqtm).
            
            find first ttvend where ttvend.funcod = func.funcod
                                    and ttvend.etbcod = func.etbcod
                                  use-index vencod  
                                  no-error.
            if not avail ttvend
            then do:
                create ttvend.
                ttvend.etbcod = func.etbcod.
                ttvend.funcod = func.funcod.
            end.
            if plani.movtdc = 12 
            then do :
                ttvend.qtd = ttvend.qtd - 1.
                ttvend.platot = ttvend.platot - v-valor.
                if plani.pladat = vdtf
                then  ttvend.pladia = ttvend.pladia - v-valor.
            end.    
        end. 
       end.
    end.
    end.
    
        
    if p-loja = 0
    then do:
    
    for each estab no-lock.

    do d = vdti to vdtf :
        for each plani where plani.movtdc = 5 
                         and  plani.etbcod = estab.etbcod and
                               plani.pladat = d 
                           no-lock  
                           use-index pladat:
                          
            disp "Processando ...."
                plani.etbcod plani.pladat with frame f1 
                    centered row 10 1 down no-labels. pause 0.

            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat no-lock.
                find produ where produ.procod = movim.procod no-lock.
                if produ.catcod <> vcatcod then next.
            
            find first func where func.funcod = plani.vencod 
                                  and func.etbcod = plani.etbcod  
                                no-lock no-error. 
            if not avail func
            then do :
                find first func where func.etbcod = 0   
                                      and func.funcod = plani.vencod
                                    no-lock no-error.
                if not avail func
                then next.
            end.
                    
            v-valor = (movim.movpc * movim.movqtm).
                
            find first ttvend where ttvend.funcod = func.funcod
                                    and ttvend.etbcod = func.etbcod
                                    use-index vencod
                                  no-error.
            if not avail ttvend
            then do:
                create ttvend.
                ttvend.etbcod = func.etbcod.
                ttvend.funcod = func.funcod.
            end.
            if plani.movtdc = 5 
            then do :
                ttvend.qtd = ttvend.qtd + 1.

                /**acres*/
                
                val_fin = 0.                   
                val_des = 0.  
                val_dev = 0.  
                val_acr = 0. 
                         
                val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.acfprod.
                if val_acr = ? then val_acr = 0.
                
                val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.descprod.
                if val_des = ? then val_des = 0.
                
                val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.vlserv.
                if val_dev = ? then val_dev = 0.
                
                if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
                then
                    val_fin =  ((((movim.movpc * movim.movqtm) 
                            - val_dev - val_des) / 
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).
                if val_fin = ? then val_fin = 0.
                
                val_com = (movim.movpc * movim.movqtm) - 
                          val_dev - val_des + val_acr + val_fin. 

                if val_com = ? then val_com = 0.
                
                ttvend.platot = ttvend.platot + val_com.
                if plani.pladat = vdtf
                then ttvend.pladia = ttvend.pladia + val_com.
                
                /*******/
                
                /*ttvend.platot = ttvend.platot + v-valor.
                if plani.pladat = vdtf
                then ttvend.pladia = ttvend.pladia + v-valor.*/
            end.    
           end.         
        end.
    
        for each plani where plani.movtdc = 12
                     and  plani.etbcod = estab.etbcod and
                           plani.pladat = d
                           no-lock  
                           use-index pladat:
                          
            disp "Processando ...."
                plani.etbcod plani.pladat with frame f2
                    centered row 10 1 down no-labels. pause 0.

            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat no-lock.

                find produ where produ.procod = movim.procod no-lock.
                if produ.catcod <> vcatcod then next.
                     
            find first func where func.funcod = plani.vencod 
                                and func.etbcod = plani.etbcod
                                no-lock no-error.
            if not avail func 
            then do :
                find first func where func.etbcod = 0
                                   and func.funcod = plani.vencod
                                    no-lock no-error.
                if not avail func
                then next.
            end.
            v-valor = (movim.movpc * movim.movqtm).

            find first ttvend where ttvend.funcod = func.funcod
                                  and ttvend.etbcod = func.etbcod
                                  use-index vencod  
                                  no-error.
            if not avail ttvend
            then do:
                create ttvend.
                ttvend.etbcod = func.etbcod.
                ttvend.funcod = func.funcod.
            end.
            if plani.movtdc = 12 
            then do :
                ttvend.qtd = ttvend.qtd - 1.
                ttvend.platot = ttvend.platot - v-valor.
                if plani.pladat = vdtf
                then  ttvend.pladia = ttvend.pladia - v-valor.
            end.    
          end.        
        end.
    end.
    end.
    end.

end procedure.
***/