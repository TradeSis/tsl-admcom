{admcab.i}
{setbrw.i}

def input parameter p-procod like tabmix.promix.

def /*shared*/ temp-table tt-mix 
    field marca   as char
    field codmix  like tabmix.codmix
    field descmix like tabmix.descmix
    field etbcod  like tabmix.etbcod

    index i1 descmix.

for each tt-mix:
    delete tt-mix.
end.
    
form
    a-seelst format "x" column-label "*"
    tt-mix.descmix   format "x(20)"
    tt-mix.codmix
    with frame f-nome
        centered down title "LOJAS"
        color withe/red overlay row 8.

def buffer btabmix for tabmix.

for each tabmix where tabmix.tipomix = "M" no-lock.
     if tabmix.codmix = 99
     then next.
     if p-procod > 0 and
        not can-find(first btabmix where
                        btabmix.codmix = tabmix.codmix and
                        btabmix.tipomix = "P" and
                        btabmix.promix = p-procod)
     then next.
                        
     create tt-mix.
     assign
         tt-mix.codmix = tabmix.codmix
         tt-mix.descmix = string(tabmix.descmix).
         tt-mix.etbcod  = tabmix.etbcod.
end.

assign 
    a-seeid = -1
    a-recid = -1
    a-seerec = ?
    a-seelst = "".

{sklcls.i
    &File   = tt-mix
    &help   = "         F4=Retorna  ENTER=Consulta "
    &CField = tt-mix.descmix    
    &Ofield = " tt-mix.codmix tt-mix.etbcod"
    &noncharacter = /*
    &Where  = " true
                use-index i1 no-lock"
    &aftselect1 = "
        if keyfunction(lastkey) = ""RETURN""
        THEN DO:
            find first tabmix where
                        tabmix.codmix = tt-mix.codmix and
                        tabmix.tipomix = ""P"" and
                        tabmix.promix = p-procod
                        no-lock no-error.
            if avail tabmix
            THEN DO on error undo, retry with frame f-consulta 
                              side-label centered color message
                              row 10 TITLE "" "" + tt-mix.descmix + "" "":
                disp tabmix.promix  label ""Produto"" format "">>>>>>>9"" .
                find produ where  produ.procod = tabmix.promix  no-lock.
                disp produ.pronom  label ""Descricao"".
                disp tabmix.qtdmix      label ""Quantidade""
                     tabmix.mostruario  label ""Mostruario""
                     tabmix.campoint2  label ""Dias cobertura(minimo)""
                            format "">>9""
                     tabmix.sazonal     label ""Sazonal""
                     tabmix.qtdsazonal  label ""QtdSazonal""    
                     tabmix.dtsazonali  label ""Inicio""
                     tabmix.dtsazonalf  label ""Fim"".
                pause.
                a-seeid = a-recid.
                a-recid = recid(TT-MIX).
                hide frame f-consulta.
            END.
            next keys-loop.
        END."
    &naoexiste1 = "message ""Nenhum registro encontrado."" view-as alert-box.
                   leave keys-loop."  
    &Form = "frame f-nome" 
    }. 

hide frame f-nome.

