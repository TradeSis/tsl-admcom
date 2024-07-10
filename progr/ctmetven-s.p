{admcab.i}
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
    initial ["","  INCLUI","  ALTERA"," MERCADOLOGICO"," IMPORTA METAS"].
def var esqcom2         as char format "x(15)" extent 5
    initial ["","CREDITO PESSOAL"," INADINPLENCIA","   GARANTIA","    RFQ"].
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
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def new shared temp-table tt-metven like metven
    field vp-moveis as int
    field vp-moda   as int
    field ms-moda   as int
    field ms-moveis as int
    index i1 metano metmes etbcod .

form   tt-metven.etbcod column-label "Fil" format ">>>"
       tt-metven.aux-dec column-label "Meta!Moda" format ">>>,>>>,>>9.99"
       tt-metven.metval column-label "Meta!Moveis" format ">>>,>>>,>>9.99"
       tt-metven.ms-moda column-label "Meta!Seguro!Moda" format ">>>>9"
       tt-metven.ms-moveis column-label "Meta!Seguro!Moveis" format ">>>>9"
       tt-metven.dias column-label "Dias" format ">>>>>9"
       tt-metven.aux-cha1 format "x(4)" column-label "Vend!Move" 
       tt-metven.aux-cha2 format "x(4)" column-label "Vend!Moda" 
       tt-metven.vp-moveis column-label "Vend!Move!Pres" format ">>>>>9"
       tt-metven.vp-moda   column-label "Vend!Moda!Pres" format ">>>>>9"
     with frame f-linha 9 down color with/cyan /*no-box*/
     width 80 row 5.
                                                                         
disp "                        CONTROLE DE METAS DE VENDA    "
            with frame f1 1 down width 80                                                   color message no-box no-label row 4.
                           
def buffer btabaux for tabaux.

def var vmes as int format "99".
def var vano as int format "9999".
def var i as int.

update 
    vmes label "Mes" format "99"
    vano label "Ano" format "9999" with frame f-mt side-labe.

hide frame f1.

disp "             CONTROLE DE METAS DE VENDA - MES " + STRING(VMES,"99") +
            " ANO " + string(vano,"9999")        format "x(70)"
            with frame f-1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.   
    
def buffer btt-metven for tt-metven.
create btt-metven.
assign
    btt-metven.metano = vano
    btt-metven.metmes = vmes
    btt-metven.etbcod = 0
    .

for each duplic where 
         duplic.duppc = vmes no-lock:
    create tt-metven.
    assign
        tt-metven.metano = vano
        tt-metven.metmes = vmes
        tt-metven.etbcod = duplic.fatnum
        tt-metven.metval = duplic.dupjur
        tt-metven.aux-dec = duplic.dupval
        tt-metven.dias = duplic.dupdia .
    btt-metven.metval =  btt-metven.metval + duplic.dupjur.
    btt-metven.aux-dec = btt-metven.aux-dec + duplic.dupval.
    btt-metven.dias = btt-metven.dias + duplic.dupdia.
    find first tabaux where
               tabaux.tabela = "META-VENDA-31" and
               tabaux.nome_campo = string(duplic.fatnum,"999") +
                                   ";" + string(vmes,"99") 
               no-lock no-error.
    if avail tabaux and tabaux.valor_campo <> ""
    then do:
        if num-entries(tabaux.valor_campo,";") = 1
        then do:
            tt-metven.aux-cha1 = tabaux.valor_campo.
            btt-metven.aux-cha1 = string(int(btt-metven.aux-cha1) +
                    int(tabaux.valor_campo)).
        end.
        else do:
            tt-metven.aux-cha1 = entry(1,tabaux.valor_campo,";").
            tt-metven.ms-moveis = int(entry(2,tabaux.valor_campo,";")).
            btt-metven.ms-moveis = btt-metven.ms-moveis +
                        int(entry(2,tabaux.valor_campo,";")).
            btt-metven.aux-cha1 = string(int(btt-metven.aux-cha1) +
                    int(entry(1,tabaux.valor_campo,";"))).
        end.
    end.                
    find first tabaux where
               tabaux.tabela = "META-VENDA-41" and
               tabaux.nome_campo = string(duplic.fatnum,"999") +
                            ";" + string(vmes,"99")
               no-lock no-error.
    if avail tabaux and tabaux.valor_campo <> ""
    then do:
        if num-entries(tabaux.valor_campo,";") = 1
        then do:
            tt-metven.aux-cha2 = tabaux.valor_campo.
            btt-metven.aux-cha2 = string(int(btt-metven.aux-cha2) +
                            int(tabaux.valor_campo)).
        end.    
        else do:
            tt-metven.aux-cha2 = entry(1,tabaux.valor_campo,";").
                tt-metven.ms-moda = int(entry(2,tabaux.valor_campo,";")).
                btt-metven.ms-moda = btt-metven.ms-moda +
                                int(entry(2,tabaux.valor_campo,";")).
                btt-metven.aux-cha2 = string(int(btt-metven.aux-cha2) +
                    int(entry(1,tabaux.valor_campo,";"))).
        end.
    end.
    find first tvendfil where
               tvendfil.anoref = vano and
               tvendfil.mesref = vmes and
               tvendfil.etbcod = duplic.fatnum
               no-lock no-error.
    if avail tvendfil
    then assign
             tt-metven.vp-moveis  = tvendfil.moveis
             btt-metven.vp-moveis = btt-metven.vp-moveis + tvendfil.moveis
             tt-metven.vp-moda    = tvendfil.moda
             btt-metven.vp-moda   = btt-metven.vp-moda + tvendfil.moda   
             .
end.               

hide frame f-mt no-pause.

l1: repeat:
    hide frame f-com1.
    hide frame f-com2.
    clear frame f-com1 all.
    clear frame f-com2 all.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
 
    {sklclstb.i  
        &color = with/cyan
        &file = tt-metven  
        &cfield = tt-metven.etbcod
        &noncharacter = /* 
        &ofield = " tt-metven.metval
                    tt-metven.aux-dec
                    tt-metven.ms-moda
                    tt-metven.ms-moveis
                    tt-metven.dias
                    tt-metven.aux-cha1
                    tt-metven.aux-cha2
                    tt-metven.vp-moveis
                    tt-metven.vp-moda
                      "
        &aftfnd1 = " "
        &where  = " tt-metven.procod = 0 and
                    tt-metven.forcod = 0 and
                    tt-metven.clacod = 0  use-index i1 "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = "" IMPORTA METAS"" or
                           esqcom2[esqpos2] = ""  CLASSE"" 
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  Message ""Nenhum registro encontrado.""
                        .
                        sresp = no.
                        message ""Deseja incluir? "" update sresp. 
                        if sresp 
                        then do:
                            esqcom1[esqpos1] = ""  INCLUI"".
                            run aftselect.
                            next l1.
                        end.
                        else leave l1.
                           " 
        &otherkeys1 = " run controle. "
        &locktype = " "
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
    pause 0.
    def var vq-mes as int.
    def var d-mes like vmes.
    def var d-ano like vano.
    d-mes = vmes.
    d-ano = vano.
    
    if esqregua
    then do:
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
        scroll from-current down with frame flinha. 
        create tt-metven.
        tt-metven.metano = vano.
        tt-metven.metmes = vmes.
        
        update tt-metven.etbcod
               tt-metven.aux-dec
               tt-metven.metval
               tt-metven.ms-moda
               tt-metven.ms-moveis
               tt-metven.dias
               tt-metven.aux-cha1
               tt-metven.aux-cha2
                 with frame f-linha. 
        find first duplic where duplic.duppc = tt-metven.metmes and
                          duplic.fatnum = tt-metven.etbcod 
                          no-error.
        if not avail duplic
        then do:                  
            create duplic.
            assign
            duplic.duppc = tt-metven.metmes
            duplic.fatnum = tt-metven.etbcod
            duplic.dupjur = tt-metven.metval 
            duplic.dupval = tt-metven.aux-dec
            duplic.dupdia = tt-metven.dias
                       .
                
            find first tabaux where
                      tabaux.tabela = "META-VENDA-31" and
                      tabaux.nome_campo = string(duplic.fatnum,"999") +
                                            ";" + string(vmes,"99")
                       no-error.
            if not avail tabaux
            then do:
                create tabaux.
                assign
                        tabaux.tabela = "META-VENDA-31"
                        tabaux.nome_campo = string(duplic.fatnum,"999") +
                                        ";" + string(vmes,"99")
                        tabaux.tipo_campo = "INT"
                        tabaux.valor_campo = tt-metven.aux-cha1 + ";" +
                                             string(tt-metven.ms-moveis).
            end.            
            find first btabaux where
                      btabaux.tabela = "META-VENDA-41" and
                      btabaux.nome_campo = string(duplic.fatnum,"999") +
                                ";" + string(vmes,"99")
                       no-error.
            if not avail btabaux
            then do:
                    create btabaux.
                    assign
                        btabaux.tabela = "META-VENDA-41"
                        btabaux.nome_campo = string(duplic.fatnum,"999") +
                                        ";" + string(vmes,"99")
                        btabaux.tipo_campo = "INT"
                        btabaux.valor_campo = tt-metven.aux-cha2 + ";" +
                                              string(tt-metven.ms-moda).
             end.
             duplic.dupven = today.
        end.
    END.
    else if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
       
        update 
                    tt-metven.aux-dec
                tt-metven.metval
                tt-metven.ms-moda
                tt-metven.ms-moveis
                    tt-metven.dias
                    tt-metven.aux-cha1
                    tt-metven.aux-cha2
                    with frame f-linha.
        sresp = yes. 
        message "Confirma alterar ?" update sresp.
        if sresp
        then do:
            
            message "Replicar quantos meses?"  update vq-mes .

            find first duplic where duplic.duppc = tt-metven.metmes and
                              duplic.fatnum = tt-metven.etbcod
                              no-error.
            if avail duplic
            then do:
                assign
                    duplic.dupval = tt-metven.aux-dec
                    duplic.dupjur = tt-metven.metval
                    duplic.dupdia = tt-metven.dias
                     .
                          
                repeat:              
                find first tabaux where
                      tabaux.tabela = "META-VENDA-31" and
                      tabaux.nome_campo = string(duplic.fatnum,"999") +
                               ";" + string(d-mes,"99")
                       no-error.
                if not avail tabaux
                then do:
                    create tabaux.
                    assign 
                        tabaux.tabela = "META-VENDA-31"
                        tabaux.nome_campo = string(duplic.fatnum,"999") +
                        ";" + string(d-mes,"99")
                        .
                end.
                tabaux.valor_campo = tt-metven.aux-cha1 + ";" +
                                    string(tt-metven.ms-moveis).
                        
                find first btabaux where
                      btabaux.tabela = "META-VENDA-41" and
                      btabaux.nome_campo = string(duplic.fatnum,"999") +
                                   ";" + string(d-mes,"99")
                       no-error.
                if not avail btabaux
                then do:
                    create btabaux.
                    assign
                        btabaux.tabela = "META-VENDA-41"
                        btabaux.nome_campo = string(duplic.fatnum,"999") +
                                        ";" + string(d-mes,"99")
                        .
                end.                        
                btabaux.valor_campo = tt-metven.aux-cha2 + ";" +
                                        string(tt-metven.ms-moda).

                if vq-mes = 0 then leave.
                if d-mes = 12
                then assign d-mes = 1 d-ano = d-ano + 1.
                else d-mes = d-mes + 1.
                vq-mes = vq-mes - 1.
                end.
            end.
         end.
    END.
    else if esqcom1[esqpos1] = " MERCADOLOGICO"
    then do:
        run meta-mercadologico.p(tt-metven.etbcod,
                                 tt-metven.metmes,
                                 tt-metven.metano).
    end.
    else if esqcom1[esqpos1] = " Importa Metas"
    THEN DO:
        hide frame f-linha no-pause.
        run importa_metas.p(input vmes, input vano).    
        view frame f-linha.
    END.
    end.
    else do:
        if esqcom2[esqpos2] = "  classe"
        THEN DO on error undo:
            hide frame f-linha no-pause.
            pause 0.
            run ctmetven-cla.p(tt-metven.etbcod, vano, vmes).
            pause 0.
        END.
        if esqcom2[esqpos2] = "CREDITO PESSOAL"
        THEN DO on error undo:
            hide frame f-linha no-pause.
            pause 0.
            run meta-creditopessoal.p(vmes, vano).
            pause 0.
        END.
        if esqcom2[esqpos2] = " INADINPLENCIA"
        THEN DO on error undo:
            hide frame f-linha no-pause.
            pause 0.
            run meta-inadinplencia.p(vmes, vano).
            pause 0.
        END.
        if esqcom2[esqpos2] = "   GARANTIA"
        THEN DO:
            hide frame f-linha no-pause.
            pause 0.
            run meta-garantia.p(vmes, vano).
            pause 0.
        end.
        if esqcom2[esqpos2] = "    RFQ"
        THEN DO:
            hide frame f-linha no-pause.
            pause 0.
            run meta-rfq.p(vmes, vano).
            pause 0.
        end.
    end.
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

    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """TITULO""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.

