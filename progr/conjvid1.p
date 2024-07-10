/*  /admcom/progr/conjvid1.p    */
{admcab.i}
{setbrw.i}                                                                      

DEFINE shared WORK-TABLE wwmsconj 
  FIELD campo-ch AS CHARACTER
  FIELD campo-de AS DECIMAL     DECIMALS 2
  FIELD campo-i  AS INTEGER
  FIELD procod   AS INTEGER     
  FORMAT ">>>>>>9" LABEL "Produto" COLUMN-LABEL "Pro"
  FIELD proean   AS CHARACTER   FORMAT "x(13)" LABEL "EAN" COLUMN-LABEL "EAN"
  FIELD qtd      AS INTEGER     FORMAT ">>>>>>9" LABEL "Qtd" COLUMN-LABEL "Qtd"
  .

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  ALTERA","  EXCLUI","  RELATORIO",""].
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


def var vetbnom like estab.etbnom.
def var qtd-venda-ideal as int.

form " " 
     tbcntgen.numfim column-label "Produto"
     produ.pronom no-label format "x(50)"
     /*tbcntgen.etbcod column-label "Filial"
     vetbnom no-label*/
     tbcntgen.quantidade format ">>9" column-label "Qtd!Conj"
     tbcntgen.valor format ">>9%" column-label "Venda!Ideal"
     qtd-venda-ideal no-label format "zzz"   
     " "
     with frame f-linha 9 down color with/cyan 
     centered width 80.
                                                                         
                                                                                
disp "                      PARAMETROS PARA CONJUNTOS  " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
def var vclacod like clase.clacod.
def var vcatcod like categoria.catcod init 31.

disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     

def buffer btbcntgen for tbcntgen.                            
def var i as int.

for each tbcntgen where
            tbcntgen.tipcon = 5 and
                        tbcntgen.etbcod = 0
                                    :
                                        find first conjunto where conjunto.procod = int(tbcntgen.numfim)
                no-lock no-error.
                    if not avail conjunto
                        then tbcntgen.etbcod = 9999.
                        end.

for each conjunto no-lock:
    find produ where produ.procod = conjunto.procod no-lock no-error.
    if not avail produ then next.
    find first tbcntgen where
               tbcntgen.tipcon = 5 and
               tbcntgen.etbcod = 0 and
               tbcntgen.numfim = string(conjunto.procod) no-error.
    if not avail tbcntgen
    then do:
        create tbcntgen.
        assign
            tbcntgen.tipcon = 5 
            tbcntgen.etbcod = 0
            tbcntgen.numfim = string(conjunto.procod) .
    end.      
    tbcntgen.quantidade = conjunto.qtd.
end.               

l1: repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?.
        
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tbcntgen  
        &cfield = tbcntgen.numfim
        &noncharacter = /*
        &ofield = " produ.pronom
                    /*tbcntgen.etbcod
                    vetbnom*/
                    tbcntgen.quantidade
                    tbcntgen.valor
                    qtd-venda-ideal
                    "  
        &aftfnd1 = "
            /*
            if tbcntgen.etbcod = 0
            then vetbnom = ""PARAMETRO GERAL""  .
            else do:
                find estab where 
                     estab.etbcod = tbcntgen.etbcod no-lock no-error.
                if avail estab
                then vetbnom = estab.etbnom.
                else estab.etbnom = "" "".
            end.*/
            find produ where produ.procod = int(tbcntgen.numfim) no-lock.    
            if tbcntgen.valor > 0
            then qtd-venda-ideal = tbcntgen.quantidade * 
                                    (tbcntgen.valor / 100).
            else qtd-venda-ideal = 0.
            "
        &where  = " tbcntgen.tipcon = 5 and
                    tbcntgen.etbcod = 0 "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" 
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " bell.
                        message color red/with
                            ""Nenhum conjunto cadastrado.""                   
                            view-as alert-box.
                        leave l1.
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
    if esqregua
    then do:
    if esqcom1[esqpos1] = "  RELATORIO"
    THEN DO on error undo:
        run relatorio. 
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
        update tbcntgen.valor with frame f-linha.
        if tbcntgen.valor > 0
        then qtd-venda-ideal = tbcntgen.quantidade * 
                                    (tbcntgen.valor / 100).
        else qtd-venda-ideal = 0.
        disp qtd-venda-ideal with frame f-linha. pause 0.
        a-recid = recid(tbcntgen).
        next.
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        sresp = no.
        message "Confirma EXCLUIR regsitro? " update sresp.
        if sresp
        then delete tbcntgen. 
        
    END.
    end.
    else do:
    if esqcom2[esqpos2] = "  PRODUTO"
    THEN DO on error undo:
        /***
        update vprocod with frame f-clase.
        if vclacod > 0
        then do:
            find clase where clase.clacod = vclacod no-lock.
            disp clase.clanom no-label with frame f-clase. 
            find first produ where 
                       produ.clacod = clase.clacod 
                       no-lock no-error.
            if not avail produ or produ.catcod <> 31
            then do:
                bell.
                message color red/with
                    "Controle permitido somente para classe" skip
                    "a nivel de produto para o setor 31"
                    view-as alert-box.
                undo.    
            end.           
        end.
        else disp "Todas as classes" @ clase.clanom with frame f-clase.
        ***/
    END.
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
    then varquivo = "../relat/conjvid1" + string(day(today),"99") 
                                       + string(month(today),"99") 
                                       + string(year(today),"9999")
                                       + "." + string(time).
    else varquivo = "..\relat\conjvid1" + string(day(today),"99") 
                                       + string(month(today),"99") 
                                       + string(year(today),"9999")
                                       + "." + string(time).
                                  
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""conjvid1"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """LISTAGEM DE CONJUMTOS""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}


    for each  tbcntgen where
               tbcntgen.tipcon = 5 no-lock:
        find produ where produ.procod = int(tbcntgen.numfim) no-lock.
        if tbcntgen.valor > 0
        then qtd-venda-ideal = tbcntgen.quantidade * 
                                    (tbcntgen.valor / 100).
        else qtd-venda-ideal = 0.

        disp tbcntgen.numfim
             produ.pronom 
             tbcntgen.quantidade
             tbcntgen.valor
             qtd-venda-ideal
             with frame f-linha.
        down with frame f-linha.     
    end.
    output close.
    
    IF opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"") .
    end.
    else do:
        {mrod.i}
    end.
END PROCEDURE.    

