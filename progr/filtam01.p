{admcab.i}
def input parameter p-catcod like produ.catcod.
def input parameter p-clacod like clase.clacod.
/*
sresp = no.
message "Confirma Enquadramento ? " update sresp.
if not sresp then return.
*/        
def temp-table tt-venloj
    field etbcod like movim.etbcod 
    field valor as dec
    field indx as dec
    index i1 etbcod
    index i2 valor descending
    index i3 indx descending
    .

def temp-table tt-venmes
    field etbcod like movim.etbcod 
    field valor as dec
    field anoref as dec
    field mesref as dec
    index i1 etbcod anoref mesref.

def buffer btt-venmes for tt-venmes.

def temp-table tt-classe
    field clacod like clase.clacod
    index i1 clacod.

def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
find clase where clase.clacod = p-clacod no-lock no-error.
if not avail clase
then next.
create tt-classe.
tt-classe.clacod = clase.clacod.
for each bclase where bclase.clasup = clase.clacod no-lock:
    create tt-classe.
    tt-classe.clacod = bclase.clacod.
    for each cclase where cclase.clasup = bclase.clacod no-lock:
        create tt-classe.
        tt-classe.clacod = cclase.clacod.
        for each dclase where dclase.clasup = cclase.clacod no-lock:
            create tt-classe.
            tt-classe.clacod = dclase.clacod.
            for each eclase where eclase.clasup = dclase.clacod no-lock:
                create tt-classe.
                tt-classe.clacod = eclase.clacod.
            end.
        end.
    end.
end.

procedure enquadra-filiais-tamanho:
    def var vdtini as date.
    def var vdtfin as date.
    vdtfin = date(month(today),01,year(today)) - 1.
    vdtini = vdtfin.
    def var vi as int.
    do vi = 1 to 5:
        vdtini = date(month(vdtini),01,year(vdtini)) - 1.
    end.
    vdtini = date(month(vdtini),01,year(vdtini)).
    update vdtini label "Periodo de vendas de" format "99/99/9999"
           vdtfin label "Ate" format "99/99/9999"
           with frame f-dt 1 down side-label row 19
           no-box overlay. 
           
    def var p-catcod like produ.catcod.          
    for each tt-classe:
        find first produ where produ.clacod = tt-classe.clacod
                  no-lock no-error.
        if avail produ
        then do:
            p-catcod = produ.catcod.
            leave.
        end.
    end.                  
    for each produ where produ.catcod = p-catcod no-lock,
        first tt-classe where tt-classe.clacod = produ.clacod no-lock:
    
        disp "processando...." produ.procod produ.pronom
         with frame f-d 1 down centered no-box no-label
         row 10 color message.
        pause 0.     
    
        for each movim where movim.procod = produ.procod and
                         movim.movtdc = 5 and
                         movim.movdat >= vdtini and
                         movim.movdat <= vdtfin
                         no-lock.
                         
            find first tt-venmes where
                   tt-venmes.etbcod = movim.etbcod  and
                   tt-venmes.anoref = year(movim.movdat) and
                   tt-venmes.mesref = month(movim.movdat) no-error.
            if not avail tt-venmes
            then do:
                create tt-venmes.
                assign
                    tt-venmes.etbcod = movim.etbcod
                    tt-venmes.anoref = year(movim.movdat)
                    tt-venmes.mesref = month(movim.movdat) 
                    .
            end.
            tt-venmes.valor = tt-venmes.valor + (movim.movpc * movim.movqtm).
        end.
    end.
    for each tabaux where
             tabaux.tabela = "filref" + string(p-catcod)
             no-lock.
        for each tt-venmes where
                 tt-venmes.etbcod = int(tabaux.nome_campo)
                 :
            find first btt-venmes where
                       btt-venmes.etbcod = int(tabaux.valor_campo) and
                       btt-venmes.anoref = tt-venmes.anoref and
                       btt-venmes.mesref = tt-venmes.mesref
                       no-error.
            if not avail btt-venmes
            then do:
                create btt-venmes.
                assign
                    btt-venmes.etbcod = int(tabaux.valor_campo)
                    btt-venmes.anoref = tt-venmes.anoref 
                    btt-venmes.mesref = tt-venmes.mesref
                    btt-venmes.valor  = tt-venmes.valor
                    .
            end.           
        end.         
    end.         
    def var va as int.
    va = 0.
    def var vind as dec extent 6 init[.75,.75,1,1,1.5,1.5].
    
    for each tt-venmes where tt-venmes.etbcod > 0
                break by tt-venmes.etbcod:
    
        if first-of(tt-venmes.etbcod)
        then va = 1.
        else va = va + 1.
        find first tt-venloj where
                   tt-venloj.etbcod = tt-venmes.etbcod
                   no-error.
        if not avail tt-venloj
        then do:
           create tt-venloj.
           tt-venloj.etbcod = tt-venmes.etbcod. 
        end.
        tt-venloj.valor = tt-venloj.valor + tt-venmes.valor.
        tt-venloj.indx = tt-venloj.indx + (tt-venmes.valor * vind[va]) .                 if va = 7
        then va = 1.
    end.
    hide frame f-d.            
    def var tam-loja as char.
    def var tam-limite as int.
    def var qtd-loja as int.
    assign
        tam-loja = ""
        tam-limite = 0
        qtd-loja = 0
        .
    for each etbtam where 
         etbtam.catcod = p-clacod : 
        delete etbtam.
    end.            
    for each tt-venloj use-index i3:
        if qtd-loja = tam-limite
        then do:
            find first tamloja where 
                   tamloja.catcod = p-catcod and 
                   tamloja.tamanho > tam-loja no-lock no-error.
            if avail tamloja
            then do:
                assign
                    tam-loja = tamloja.tamanho
                    tam-limite = tamloja.limite
                    qtd-loja = 0.
            end.   
            else leave.
        end.

        create etbtam.
        assign
        etbtam.catcod  = p-clacod
        etbtam.tamanho = tam-loja
        etbtam.etbcod  = tt-venloj.etbcod
        etbtam.data-enquadramento = today
        etbtam.situacao = "E"
        etbtam.venda   = tt-venloj.valor
        qtd-loja = qtd-loja + 1.

    end.        
end procedure.

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
    initial ["","  Inclui","  Exclui","",""].
def var esqcom2         as char format "x(20)" extent 5
            initial ["","Novo Enquadramento","","",""].
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

def temp-table tt-tamfil
    field tamanho as char
    field filiais as char
    index i1 tamanho
    .

form tt-tamfil.tamanho label "Tm" format "x(2)" 
     tt-tamfil.filiais label "Filiais" format "x(75)"
     with frame f-linha 8 down color with/cyan 
     width 80.
                                                                                
disp "                         ENQUADRAMENTO FILIAIS A TAMANHO   " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

def  var vfiliais as char.

/***
for each etbtam where etbtam.catcod = p-clacod 
                by etbtam.etbcod no-lock:
    find first tt-tamfil where 
               tt-tamfil.tamanho = etbtam.tamanho
               no-error.
    if not avail tt-tamfil
    then do:
        create tt-tamfil.
        tt-tamfil.tamanho = etbtam.tamanho.
    end.
    tt-tamfil.tamanho = tt-tamfil.tamanho + 
                string(etbtam.etbcod,"999") + " - ".           
end.
***/
l1: repeat:

    hide frame esqcom1 .
    hide frame esqcom2 .
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    
    hide frame f-linha no-pause.
    clear frame f-linha all.
    
    /**********************/
    for each tt-tamfil:
        delete tt-tamfil.
    end.    
    
    for each etbtam where etbtam.catcod = p-clacod and
                          etbtam.situacao = "E" 
                           no-lock by etbtam.etbcod:
        find first tt-tamfil where 
               tt-tamfil.tamanho = etbtam.tamanho
               no-error.
        if not avail tt-tamfil
        then do:
            create tt-tamfil.
            tt-tamfil.tamanho = etbtam.tamanho.
        end.
        tt-tamfil.filiais = tt-tamfil.filiais + 
                string(etbtam.etbcod) + ",".           
    end.
    hide frame f-linha no-pause.
    
    /**************************/
    {sklclstb.i  
        &color = with/cyan
        &file = tt-tamfil  
        &cfield = tt-tamfil.tamanho
        &noncharacter = /* 
        &ofield = " tt-tamfil.filiais "  
        &aftfnd1 = " "
        &where  = " "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom1[esqpos1] = ""  inclui"" or
                           esqcom2[esqpos2] = ""novo enquadramento""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " 
                sresp = no.
                message ""Confirma gerar enquadramento?"" 
                update sresp.
                if sresp = yes
                then run enquadra-filiais-tamanho.
                next l1.
             " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha  "
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
    def var vetbcod like estab.etbcod.
    def var vqtd as int.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
        update vetbcod with frame f-inclui
                centered 1 down side-label row 8
                overlay.
        find first etbtam where 
                   etbtam.catcod = p-clacod and 
                   etbtam.etbcod = vetbcod and
                   etbtam.situacao = "E"
                   no-lock no-error.
        if avail etbtam
        then do:
            bell.
            message color red/with
            "Filial ja enquadrada no tamanho " etbtam.tamanho
            view-as alert-box.
            undo.
        end.           
        else do:
            vqtd = 0.
            for each etbtam where
                     etbtam.catcod = p-clacod and
                     etbtam.tamanho = tt-tamfil.tamanho
                     no-lock.
                vqtd = vqtd + 1.
            end.
            find first tamloja where
                       tamloja.catcod = p-catcod and
                       tamloja.tamanho = tt-tamfil.tamanho
                       no-lock no-error.
            if tamloja.limite >= vqtd 
            then do:
                message color red/with 
                 "Tamanho com limite maximo de filiais."
                 view-as alert-box.
                 undo.
            end.
            else do:                
            create etbtam.
            assign
                etbtam.catcod  = p-clacod
                etbtam.tamanho = tt-tamfil.tamanho
                etbtam.etbcod  = vetbcod
                etbtam.data-enquadramento = today
                etbtam.situacao = "E"
                .
            end.
        end.    
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
    
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        update vetbcod with frame f-exclui
                centered 1 down side-label row 8
                overlay.
        find first etbtam where 
                   etbtam.catcod = p-clacod and 
                   etbtam.etbcod = vetbcod and
                   etbtam.situacao = "E"   and
                   etbtam.tamanho = tt-tamfil.tamanho
                    no-error.
        if not avail etbtam
        then do:
            bell.
            message color red/with
            "Filial nao enquadrada ao tamanho " tt-tamfil.tamanho
            view-as alert-box.
            undo.
        end.           
        else do:
            delete etbtam.
        end.     
    END.
    if esqcom2[esqpos2] = "novo enquadramento"
    THEN DO :
        run enquadra-filiais-tamanho.
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

            
            
                 
                        
                        
                        
