/* #1 06.04.2018 - Acertado Indices para melhorar Performance */
/** #6 **/ /** 02.2019 Helio.Neto - Versao 4 - Inclui Elegiveis e acerta percentuais */

    
    def input param par-clicod as int.
    def output param par-perc-15 as dec decimals 4.
    def output param par-perc-45 as dec decimals 4.
    def output param par-perc-46 as dec decimals 4.
     
    def var par-qtd-15 as int.
    def var par-qtd-45 as int.
    def var par-qtd-46 as int.
    def var par-paga as int.
    
    def var vaberta as int.
    
    par-paga = 0.
    vaberta = 0.
    par-qtd-15 = 0.
    par-qtd-45 = 0.
    par-qtd-46 = 0.

    def var c1 as char.
    def var r1 as char format "x(30)".
    def var il as int.
    def var vcampo as char format "x(20)". 

 DEFINE TEMP-TABLE ttcomportamento NO-UNDO   serialize-name 'comportamentoCliente'
    field clicod        as char format "x(12)"
            serialize-hidden
    field atributo      as char format "x(20)"     
            serialize-name 'atributo' 
    field valorAtributo as char format "x(30)"     
            serialize-name 'valorAtributo' 
    index cli is unique primary clicod asc atributo asc.

{neuro/achahash.i}
{neuro/varcomportamento.i}


    run neuro/comportamento.p (par-clicod,?,output var-propriedades).

    do il = 1 to num-entries(var-propriedades,"#") with down.
    
        vcampo = entry(1,entry(il,var-propriedades,"#"),"=").
        if vcampo = "FIM"
        then next.
        r1 = pega_prop(vcampo).

        create ttcomportamento.
        ttcomportamento.clicod = string(par-clicod).
        ttcomportamento.atributo        = vcampo.
        ttcomportamento.valoratributo   = r1.
    end.


    find first ttcomportamento where
            ttcomportamento.atributo = "ATRASOPARCPERC"
            no-error.
    if avail ttcomportamento
    then do:
        par-perc-15 = dec(entry(1,replace(valorAtributo,"%",""),"|") ).
        par-perc-45 = dec(entry(2,replace(valorAtributo,"%",""),"|") ).
        par-perc-46 = dec(entry(3,replace(valorAtributo,"%",""),"|") ).
    end.    

