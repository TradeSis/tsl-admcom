/* HUBSEG 19/10/2021 */

def input parameter par-cpfcnpj as dec.
def output parameter var-propriedades as char.

def new global shared var setbcod    like estab.etbcod.

/*#4*/
{/admcom/progr/acha.i}

def var var-limite as dec.
def var var-limiteEP as dec.
def var var-sallimite as dec.
def var var-sallimiteEP as dec.
def var var-salabprinc as dec.
def var var-salabprincEP as dec. 
def var var-salaberto as dec.
def var var-salabertoEP as dec.
def var var-salabertoCDC as dec.
def var var-salabertoNORM as dec.
def var var-salabertoNOV as dec.

def var var-salabertoEPNORM as dec.
def var var-salabertoEPNOV as dec.

def var var-salabhubseg as dec.

def var vtitdes as dec.

    
    find first neuclien where neuclien.cpf = par-cpfcnpj no-lock no-error.
    if not avail neuclien
    then next.

    var-limite     = if avail neuclien and 
                        neuclien.vctolimite >= today and
                        neuclien.vctolimite <> ? 
                     then neuclien.vlrlimite
                     else 0.
    var-limiteEP = 0.

    if neuclien.clicod <> ?
    then
    for each titulo where titulo.clifor = neuclien.clicod no-lock.    
        if titulo.modcod = "CHQ" or
           titulo.modcod = "DEV" or
           titulo.modcod = "BON" or
           titulo.modcod = "VVI" or   /* #5 Sujeira de banco */
           length(titulo.titnum) > 11 /* Sujeira de banco */
        then next. /*** ***/
    
        find contrato where contrato.contnum = int(titulo.titnum) no-lock no-error.
        if not avail contrato
        then next.  
        if titulo.titpar <> 0
        then do:    
            if titulo.titsit = "LIB"
            then do:
                var-salaberto = var-salaberto + titulo.titvlcob.   
                if titulo.modcod begins "CP"  
                then var-salabertoEP    = var-salabertoEP   + titulo.titvlcob. 
                else var-salabertoCDC   = var-salabertoCDC  + titulo.titvlcob.

                if titulo.tpcontrato = "N"
                then var-salabertoNOV  = var-salabertoNOV + titulo.titvlcob. 
                else var-salabertoNORM = var-salabertoNORM + titulo.titvlcob. 

                /* helio 21/07/2021 */
                if titulo.modcod begins "CP"
                then do:
                    if titulo.modcod = "CPN"
                    then var-salabertoEPNOV  = var-salabertoEPNOV + titulo.titvlcob. 
                    else var-salabertoEPNORM = var-salabertoEPNORM + titulo.titvlcob. 
                end.


                    if  titulo.vlf_hubseg > 0 
                    then do: 
                        var-salabhubseg =  var-salabhubseg + titulo.vlf_hubseg. 
                    end.                
                
                    if  titulo.vlf_principal > 0 
                    then do: 
                        vtitdes = titulo.titdes.
                        if vtitdes = 0 and contrato.vlseguro > 0
                        then vtitdes = contrato.vlseguro / contrato.nro_parcela.  
                    
                        var-salabprinc =  var-salabprinc + titulo.vlf_principal. 
                        if titulo.titdtemi < 04/20/2021         /* versao anterior a mudanca na integracao */ 
                        then var-salabprinc =  var-salabprinc - vtitdes . /* retira o seguro */  
                        if titulo.modcod begins "CP" 
                        then do: 
                            var-salabprincEP =  var-salabprincEP + titulo.vlf_principal. 
                            if titulo.titdtemi < 04/20/2021         /* versao anterior a mudanca na integracao */ 
                            then var-salabprincEP =  var-salabprincEP - vtitdes . /* retira o seguro */ 
                        end.           
                    end. 
                    else do: 
                        var-salabprinc   = var-salabprinc   + titulo.titvlcob. 
                        if titulo.modcod begins "CP"
                        then  var-salabprincEP = var-salabprincEP + titulo.titvlcob. 
                    end.    
                end.    
        end.
    end.
        
    var-salabprinc = round(var-salabprinc,2).
    var-salabhubseg = round(var-salabhubseg,2).
    
    var-sallimite = var-limite - var-salabprinc - var-salabhubseg.
    if var-sallimite < 0 then var-sallimite = 0.
    var-sallimiteEP = 0.
    
        find first profin where profin.situacao no-lock no-error.
        if avail profin
        then do:
             find first profinparam where profinparam.fincod = profin.fincod
                                 and profinparam.etbcod  = 0
                                 and profinparam.dtinicial <= today
                                 and (profinparam.dtfinal = ? or
                                      profinparam.dtfinal >= today)
                              no-lock no-error.
            if avail profinparam
            then do:
                var-limiteEP = (var-sallimite + var-salabprincEP) * (profinparam.perclimite / 100).
                var-limiteEP = if var-limiteEP > profinparam.vlmaximo
                               then profinparam.vlmaximo
                               else var-limiteEP.
                var-sallimiteEP = var-limiteEP - /* 12/05/2021 mudou  var-salabprinc -> */ var-salabprincEP.
                if var-sallimiteEP < 0  then var-sallimiteEP = 0.
            end.
        end.    

var-propriedades =   
      "#LIMITE="       + trim(string(var-limite,"->>>>>>>>>9.99"))
    + "#LIMITETOM="    + trim(string(var-salaberto,"->>>>>>>>>9.99"))
    + "#LIMITETOMPR="  + trim(string(ROUND(var-salabprinc, 2),"->>>>>>>>>9.99"))
    + "#LIMITEDISP="   + trim(string(var-sallimite,"->>>>>>>>>9.99"))
    + "#LIMITETOMNORM="    + trim(string(var-salabertoNORM,"->>>>>>>>>9.99"))
    + "#LIMITETOMNOV="    + trim(string(var-salabertoNOV,"->>>>>>>>>9.99"))

    + "#LIMITEEP="     + trim(string(var-limiteEP,"->>>>>>>>>9.99")) /* helio 14042021 - a pedido aline - chamado 68725 */
    + "#LIMITETOMEP="  + trim(string(var-salabertoEP,"->>>>>>>>>9.99"))
    + "#LIMITETOMPREP="  + trim(string(var-salabPrincEP,"->>>>>>>>>9.99"))
    + "#LIMITEDISPEP=" + trim(string(var-sallimiteEP,"->>>>>>>>>9.99"))
    + "#LIMITETOMEPNORM="  + trim(string(var-salabertoEPNORM,"->>>>>>>>>9.99"))
    + "#LIMITETOMEPNOV="  + trim(string(var-salabertoEPNOV,"->>>>>>>>>9.99"))

    + "#LIMITETOMCDC="  + trim(string(var-salabertoCDC,"->>>>>>>>>9.99"))
    + "#LIMITETOMHUBSEG="  + trim(string(ROUND(var-salabhubseg, 2),"->>>>>>>>>9.99"))
    
    + "#FIM=".


/* fim */
