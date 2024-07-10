
{admcab.i }.

{anset.i}.

def var vprocod like produ.procod.

form
    vprocod         label "Codigo" 
    produ.pronom    no-label
    with frame f-produ 
        centered 1 down side-labels title " PRODUTO ".

form
    estoq.etbcod
    estab.etbnom 
    estoq.estmin   
    with frame f-linha
        centered title " LOJAS x MINIMO " 
        down .

repeat :

    update vprocod with frame f-produ.

    find first produ where produ.procod = vprocod no-lock no-error.
    if not avail produ
    then do :
        bell. bell.
        message "Codigo do Produto invalido". 
        pause. clear frame f-produ all.
        next.
    end.

    disp produ.pronom with frame f-produ.

    assign
        an-seeid = -1 an-recid = -1 an-seerec = ?.

    {anbrowse.i
        &File = estoq
        &Cfield = estoq.etbcod
        &OField = "estab.etbnom 
                   estoq.estmin" 
        &Where = " estoq.procod = produ.procod 
                and estoq.etbcod <= 900
                and {conv_igual.i estoq.etbcod} " 
        &NonCharacter = /*        
        &Color = "cyan/black" 
        &AftSelect1 = "update estoq.estmin with frame f-linha.
                       estoq.datexp = today.
                       next keys-loop. " 
        &AftFnd = "find first estab where estab.etbcod = estoq.etbcod 
                                    no-lock no-error. " 
        &form   = " frame f-linha " 
    }.
end.                                       
               
                                    
/****** Criado por Andre Baldini em 20/11/2001 ***************************
******* Manutecao do Estoque Minimo por Produto por Loja           *******/                                    
                                    
                                    
        