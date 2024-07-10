/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : convgenw.p
*******************************************************************************/

{cabec.i}
{anset.i}.

def input parameter par-recid as recid.
def input parameter vrow        as int.

def var p-vencod     like func.funcod.
def shared var p-loja      like estab.etbcod.
def var v-perc      as dec label "% Acum".
def var v-percproj  as dec.

def shared      var vdti        as date format "99/99/9999" no-undo.
def shared      var vdtf        as date format "99/99/9999" no-undo.

def shared temp-table ttloja
    field medven    like plani.platot
    field medproj   like plani.platot
    field metlj     like plani.platot
    field platot    like plani.platot
    field acfprod   like plani.acfprod
    field nome      like estab.etbnom 
    field etbcod    like plani.etbcod
    field cusmed    like produ.procmed
    field margem    as dec format "->>9.99"
    field qtdnota as int
    field qtditem as int
    field tktmed  as dec
    field movqtm  as dec
    index loja     is unique etbcod 
    index platot  is primary platot desc.

def shared temp-table ttvendedor
    field etbcod    like plani.etbcod
    field vencod    like plani.vencod
    field medven    like plani.platot
    field medproj   like plani.platot
    field metlj     like plani.platot
    field platot    like plani.platot
    field acfprod   like plani.acfprod
    field nome      like estab.etbnom 
    field cusmed    like produ.procmed
    field margem    as dec format "->>9.99"
    field numseq    as int
    field qtdnota as int
    field qtditem as int
    field tktmed  as dec
    field movqtm    as dec
    index loja     is unique etbcod asc vencod asc 
    index platot  is primary platot desc.

form
    ttloja.etbcod
        help "ENTER=Seleciona F4=Encerra F8=Imprime F9-Detalhe" 
    ttloja.nome format "x(10)" column-label "Estabel." 
    ttloja.cusmed  format "->>>>>9" column-label "CMV"
    ttloja.margem column-label "Marg" format "->>9.9"
    ttloja.platot  format "->>>>,>>9" column-label "Venda"
    ttloja.acfprod format ">>>>9" column-label "Fin"
    ttloja.metlj  column-label "Meta" format ">>>>>>9" 
    v-perc column-label "%" format ">>9"
    ttloja.medven   column-label "Med.Dia" format ">>,>>9"
    ttloja.medproj column-label "Proj" format ">>>>>>9"
    v-percproj column-label "%" format ">>>9"
    with frame f-lojas
        width 80
        centered
        1 down 
        row 5
        no-box
        overlay.

form header "*** V E N D E D O R E S ***"
     with frame f-vendedor.

form
    ttvendedor.nome format "x(10)" column-label "Vendedor" 
        help "ENTER=Seleciona F4=Encerra F8=Imprime" 
    ttvendedor.cusmed  format "->>>>>9" column-label "CMV"
    ttvendedor.margem column-label "Marg" format "->99.9"
    ttvendedor.platot  format "->>>>,>>9" column-label "Venda"
    ttvendedor.acfprod format ">>>>9" column-label "Out"
    ttvendedor.metlj  column-label "Meta" format ">>>>>>9" 
    v-perc column-label "%" format ">>9"
    ttvendedor.medven   column-label "DiaM" format ">>>>>9"
    ttvendedor.tktmed   column-label "TktM" format ">>>9"
    ttvendedor.medproj column-label "Proj" format ">>>>>>9"
    v-percproj column-label "%" format ">>>>9"
    with frame f-vendedor
        width 80
        centered
        10 down 
        row 8
        no-box
        overlay
        no-labels.
        /*
        title " VENDAS POR LOJA ".
          */

find ttloja where recid(ttloja) = par-recid.
/* 
disp
    ttloja.etbcod
        help "ENTER=Seleciona F4=Encerra F8=Imprime" 
    ttloja.nome format "x(10)" column-label "Estabel." 
    ttloja.cusmed  format "->>>>>9" column-label "CMV"
    ttloja.margem column-label "Marg" format "->>9.9"
    ttloja.platot  format "->>>>,>>9" column-label "Venda"
    ttloja.acfprod format ">>>>9" column-label "Fin"
    ttloja.metlj  column-label "Meta" format ">>>>>>9" 
    v-perc column-label "%" format ">>9"
    ttloja.medven   column-label "Med.Dia" format ">>,>>9"
    ttloja.medproj column-label "Proj" format ">>>>>>9"
    v-percproj column-label "%" format ">>>9"
    with frame f-lojas.
*/  
repeat.
            assign  an-seeid = -1 an-recid = -1 
                    an-seerec = ?.

            {anbrowse.i
                &File   = ttvendedor
                &CField = ttvendedor.nome
                &color  = write/cyan
            &Ofield = " ttvendedor.platot ttvendedor.metlj ttvendedor.cusmed 
            v-perc ttvendedor.margem ttvendedor.medven ttvendedor.tktmed ttvendedor.medproj ttvendedor.acfprod v-percproj"
                &Where = "ttvendedor.etbcod  = p-loja"
                &NonCharacter = /*
                &Aftfnd = "
                    assign v-perc = ttvendedor.platot * 100 / ttvendedor.metlj. 
                    assign v-percproj = ttvendedor.medproj * 100 / ttvendedor.metlj. 
                
                "
            &otherkeys1 = "perfoven.i"
             
                &AftSelect1 = "p-loja = ttvendedor.etbcod. 
                               p-vencod = ttvendedor.vencod.
                       leave keys-loop. "
                &LockType = "use-index platot" 
                &Form = " frame f-vendedor" 
            }.

            if keyfunction(lastkey) = "END-ERROR"
            then leave.
            
            clear frame f-vendedor all no-pause.
            disp

            ttvendedor.nome
 ttvendedor.platot ttvendedor.metlj ttvendedor.cusmed 
            v-perc ttvendedor.margem ttvendedor.medven ttvendedor.tktmed ttvend~edor.medproj ttvendedor.acfprod v-percproj
    with frame f-vendedor.
             run perfopro.p (input ttloja.etbcod,p-vencod).
    
    end.