def shared temp-table rfvtot
    field rfv   as int format "999"
    field recencia   as char format "x(7)"
    field frequencia as char format "x(7)"
    field valor      as char format "x(7)"
    field qtd-ori   as int
    field qtd-sel   as int
    field flag  as log format "*/ "
    field per-tot   as dec format ">>9.99%"
    field etbcod  like estab.etbcod
    field lim-credito as dec
    field lim-disponivel as dec
    index irfv-asc as primary unique rfv etbcod
    index irfv-des rfv descending
    index iqtd-asc qtd-ori
    index iqtd-des qtd-ori descending
    index ietbcod etbcod
    index iflagetb flag etbcod.

def var vlimite-credito as dec.
def var vsaldo-aberto as dec.

def var vcalclim as dec.
def var vpardias as dec.
def var vdisponivel as dec.
def new shared temp-table tt-dados
    field parametro as char
    field valor     as dec
    field valoralt  as dec
    field percent   as dec
    field vcalclim  as dec
    field operacao  as char format "x(1)" column-label ""
    field numseq    as int
    index dado1 numseq.

vcalclim = 0.
vpardias = 0.
vdisponivel = 0.
def buffer crm for ncrm.
def var vqtd as int init 0.

for each rfvtot:
    disp "Processando Limite Disponivel... "
            "Filial " rfvtot.etbcod  
            with frame f-disprfv1 1 down centered row 12 no-box no-label.
        pause 0.


          
    for each crm where 
             crm.rfv    = rfvtot.rfv and
             crm.etbcod = rfvtot.etbcod no-lock:

        find clien where clien.clicod = crm.clicod no-lock.
        vqtd = vqtd + 1.
        disp clien.clicod no-label
             vqtd no-label
             with frame f-disprfv1 .
        pause 0. 
        vcalclim = 0.
        vpardias = 0.
        vdisponivel = 0.
        /*
         /* antonio - sol 26885*/
        if not connected ("dragao") 
        then connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld d.
        /**/

        run calccredscore.p (input "",
                        input recid(clien),
                        output vcalclim,
                        output vpardias,
                        output vdisponivel).

        vlimite-credito = vcalclim.
        /*
        /**/
        vlimite-credito = crm.limcrd.
        /**/
        
        run salabertocli.p ( input recid(clien),
                        output vsaldo-aberto).

        rfvtot.lim-credito = rfvtot.lim-credito + vlimite-credito.
        if vlimite-credito > vsaldo-aberto
        then rfvtot.lim-disponivel = rfvtot.lim-disponivel +
                (vlimite-credito - vsaldo-aberto) .
    end.
    
end.