/*
#1 tpcontrato
#2 09.10.2017 -  Revisão modalidades: CRE, CP0, CP1 e CPN
#3 26.06.2018 - helio TP 25424103 - Quando tem Neuclien com Limite usa-o
#4 26.03.2019 - helio.neto - trello Processo 77171 - Padronização de Consulta de Limites "Ajustar para quando cliente tem limite vencido devolver limite zero"
*/
def input  parameter par-tipo  as char. /* "Tela" = Extrato */
def input  parameter rec-clien as recid.
def output parameter vcalclimite as dec.
def output parameter par-dias    as int.
def output parameter limite-disponivel as dec.

def var p-etbcod as int.
if substr(par-tipo,1,1) = "1" or
   substr(par-tipo,1,1) = "2" or
   substr(par-tipo,1,1) = "3" or
   substr(par-tipo,1,1) = "4" or
   substr(par-tipo,1,1) = "5" or
   substr(par-tipo,1,1) = "6" or
   substr(par-tipo,1,1) = "7" or
   substr(par-tipo,1,1) = "8" or
   substr(par-tipo,1,1) = "9" 
then assign
        p-etbcod = int(par-tipo)
        par-tipo = "".
else p-etbcod = ?.
            
def var dtemres as date.
def var dtemtra as int.
def var vano as int.
def var vaux as int.
def var vidade as int.
def var vtipoc as int.
def var jacli as int format "9".
def var vnovatras as log.
def var vrendacalclim as dec.
def var vtempocarro as int.
def var vsomapar as int.
def var vtotalpar as dec.
def var vcontapar         as int.
def var vnumparcpg        as int.
def var vvalparcpg        as dec.
def var vpercrenda        as dec.
def var vperc             as dec.
def var vguardaval        as dec.
def var vguardacampo      as char.
def var vlimmatraso as int init 0.
def var vlimmaximo  as dec init 0.
def var vlimmaximoc as dec init 0.
def var vdescalug       as log initial yes format "Sim/Nao".    
def var vrensalmin      as dec init 0.
def var vsalariominimo  as dec init 0.
def var vcontarefer as int init 0.
def var vcampopess  as int init 0.
def var vcampocomer as int init 0.
def var ref as int.
def var vrefcampos as log. 
def var vestcivil as char.
def var saldo-aberto as dec init 0.
def var vmaioratraso as dec.
def var vqtdpagas as int.
def var vvlrpagas as dec.


FUNCTION acha returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"|"). 
        if entry(1,entry(vx,par-onde,"|"),"=") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"="). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.

par-dias = ?.

def shared temp-table tt-dados
    field parametro as char
    field valor     as dec
    field valoralt  as dec
    field percent   as dec
    field vcalclim  as dec
    field operacao  as char format "x(1)" column-label ""
    field numseq    as int
    index dado1 numseq.
    
def buffer btt-dados for tt-dados.

for each tt-dados.
    delete tt-dados.
end.

/* Limite Maximo - Behavior */
find first credscore where credscore.campo = "LIMMAXIMO" no-lock no-error.
if avail credscore
then vlimmaximo = credscore.vl-ini.
else vlimmaximo = 0.

/* Limite Maximo - Credscore */
find first credscore where credscore.campo = "LIMMAXIMOC" no-lock no-error.
if avail credscore
then vlimmaximoc = credscore.vl-ini.
else vlimmaximoc = 0.

/* Limite de Media de Atraso */
find first credscore where credscore.campo = "LIMMATRASO" no-lock no-error.
if avail credscore
then vlimmatraso = credscore.vl-ini.
else vlimmatraso = 0.

find clien where recid(clien) = rec-clien no-lock.
find cpclien where cpclien.clicod = clien.clicod no-lock no-error.

/* Renda para Calculo de Limite */
vrendacalclim = clien.prorenda[1] /*** + clien.prorenda[2] ***/.

/* 25465 */
if clien.prorenda[1] = 0 and clien.prorenda[2] <> 0
then vrendacalclim = clien.prorenda[2] / 2.

if p-etbcod <> ?
then do:
    find first rendaprofi where
           rendaprofi.etbcod  = p-etbcod and
           rendaprofi.codprof = cpclien.var-int4
           no-lock no-error.
    if avail rendaprofi and rendaprofi.valrenda > 0
        and vrendacalclim > rendaprofi.valrenda
    then vrendacalclim = rendaprofi.valrenda.
end.
else do:
    find first rendaprofi where
           rendaprofi.etbcod  = 0 and
           rendaprofi.codprof = cpclien.var-int4
           no-lock no-error.
    if avail rendaprofi and rendaprofi.valrenda > 0
        and vrendacalclim > rendaprofi.valrenda
    then vrendacalclim = rendaprofi.valrenda.
end.            
                
find first tt-dados where tt-dados.parametro = "Renda Para Calculo de Limite"
    no-lock no-error.
if not avail tt-dados
then do:
    create tt-dados.
    tt-dados.parametro = "Renda para Calculo de Limite".
end.
tt-dados.vcalclim = vrendacalclim.

vcontapar = 0.                                                                 
/* Percentual para Calculo de Limite */
find first credscore where credscore.campo = "PERCRENDA" no-lock no-error.
if avail credscore
then assign vpercrenda = credscore.vl-ini.
else assign vpercrenda = 60.

vcalclimite = vrendacalclim.

/***
    /* Desconta Aluguel */
    find first credscore where credscore.campo = "descalug" no-lock no-error.
    if avail credscore
    then vdescalug = credscore.vl-log.
    else vdescalug = no.
    
    if avail credscore and vdescalug and clien.vlalug <> 0 
    then do:
        vguardaval = vcalclimite.
        vcalclimite = vcalclimite - clien.vlalug.
        if vcalclimite <> vguardaval
        then do:
            find first tt-dados where tt-dados.parametro = credscore.campo
                no-lock no-error.
            if not avail tt-dados
            then do:
                create tt-dados.
                tt-dados.parametro = trim(credscore.desc-campo).
            end.
            tt-dados.valoralt  = vguardaval.
            tt-dados.valor = clien.vlalug.
            tt-dados.vcalclim = vcalclimite.
            tt-dados.operacao = "-".
            find last btt-dados no-lock no-error.
            if not avail btt-dados
            then tt-dados.numseq = 1.
            else tt-dados.numseq = btt-dados.numseq + 1.
        end.          
        
    end. 
***/

vguardaval = vcalclimite.
vcalclimite = vguardaval * (vpercrenda / 100).
vguardacampo = ?.

    /* Quantidade de Parcelas Pagas */                                         
    find first credscore where credscore.campo = "NUMPARCPG" no-lock no-error.
    if avail credscore
    then assign vnumparcpg = credscore.vl-ini
                vguardacampo = credscore.campo.
    else assign vnumparcpg = 0
                vguardacampo = ?.

    if vguardacampo <> ?
    then do:
        find tt-dados where tt-dados.parametro = vguardacampo no-lock no-error.
        if not avail tt-dados
        then do:
            create tt-dados.
            tt-dados.parametro = credscore.desc-campo.
        end.
        tt-dados.valoralt  = vnumparcpg.
        tt-dados.valor     = vguardaval.
        find last btt-dados no-lock no-error.
        if not avail btt-dados
        then tt-dados.numseq = 1.
        else tt-dados.numseq = btt-dados.numseq + 1.
    end.

/***
    /* Possui Fone Convencional */
    find first credscore where credscore.campo = "descalug"
                           and credscore.valor > 0
                         no-lock no-error.
    if avail credscore and clien.tipres = no
    then run le-credscore.    
***/

def var vtamanho as int.
def var vestab as int.

    /* Estabelecimento do Cliente */
    for each credscore where credscore.desc-campo = "ESTABCLI"
                         and credscore.valor <> 0 no-lock
                       by credscore.vl-ini.
       vtamanho = int(length(trim(string(clien.clicod,">>>>>>>>>9")))).
       
       vestab = 0.
       if vtamanho > 2
       then do:
           if vtamanho >= 10
           then vestab = int(substr(trim(string(clien.clicod)),2,3)).
           else vestab = int(substr(trim(string(clien.clicod)),vtamanho - 1,2)).
       end.  
       if vestab = int(credscore.campo)
       /***
        (
         (
           (vtamanho < 10 and
            int(substr(string(clien.clicod),vtamanho - 1, 2) =
               int(credscore.campo))
         )  or
         (int(substr(string(clien.clicod),2,3))
         )
        ) 
        ***/
        then do:                                                            
            run le-credscore.                                               
            leave.                                                          
        end.                                                                
    end.

/*
message "estabcli" vcalclimite view-as alert-box.
*/

/***/
/* Unificado 2 leituras: titulos pagos */
for each fin.titulo where fin.titulo.empcod = 19
                      and fin.titulo.titnat = no
                      and fin.titulo.clifor = clien.clicod
                      and fin.titulo.titdtpag <> ?
                      and fin.titulo.titsit = "PAG"
                    no-lock.
    if titulo.modcod <> "CRE" and
       titulo.modcod <> "CP0" and
       titulo.modcod <> "CP1" and
       titulo.modcod <> "CPN"
    then next.

    assign
        vqtdpagas = vqtdpagas + 1
        vvlrpagas = vvlrpagas + fin.titulo.titvlpag.
end.

/* Valor Total das Parcelas Pagas */
find first credscore where credscore.campo = "VALPARCPG" no-lock no-error.
if avail credscore
then assign vvalparcpg = credscore.vl-ini
            vguardacampo = credscore.campo.
else assign vvalparcpg = 0
            vguardacampo = ?.

if vguardacampo <> ?
then do:
    find tt-dados where tt-dados.parametro = vguardacampo no-lock no-error.
    if not avail tt-dados
    then do:
        create tt-dados.
        tt-dados.parametro = credscore.desc-campo + " parcelas pagas".
    end.
    tt-dados.valoralt  = vnumparcpg.
    find last btt-dados no-lock no-error.
    if not avail btt-dados
    then tt-dados.numseq = 1.
    else tt-dados.numseq = btt-dados.numseq + 1.
end.    
if vnumparcpg > 0
then do:
    vcontapar = vqtdpagas.
    vtotalpar = vvlrpagas.

    find first posicli where posicli.clicod = clien.clicod no-lock no-error.
    if avail posicli
    then assign
            vcontapar = vcontapar + posicli.qtdparpg.
end.

/***/
jacli = 0.
if vcontapar > vnumparcpg and vnumparcpg <> 0 and vtotalpar > vvalparcpg
then jacli = 1.

/* Possui Fone Convencional */
find first credscore where credscore.campo = "descalug"
                       and credscore.valor > 0
                     no-lock no-error.
if avail credscore and clien.tipres = no
then run le-credscore.
/***/    
    
jacli = 0.
if vcontapar > vnumparcpg and vnumparcpg <> 0 and vtotalpar > vvalparcpg
then do:
    run p-cliente (input-output vcalclimite).
    jacli = 1.
end.
/*else do:*/

/***
    /* Possui Fone Convencional */
    find first credscore where credscore.campo = "descalug"
                           and credscore.valor > 0
                         no-lock no-error.
    if avail credscore and clien.tipres = no
    then run le-credscore.    

/*
message "descalug" vcalclimite view-as alert-box.
*/

    /* Estabelecimento do Cliente */
    for each credscore where credscore.desc-campo = "ESTABCLI"
                         and credscore.valor <> 0 no-lock
                       by credscore.vl-ini.
       if length(string(clien.clicod)) > 2 and
         int(substr(string(clien.clicod),length(string(clien.clicod)) - 1, 2))
        = int(credscore.campo)
        then do:                                                            
            run le-credscore.                                               
            leave.                                                          
        end.                                                                
    end.

/*
message "estabcli" vcalclimite view-as alert-box.
*/
***/

    vcontapar = vqtdpagas.
    find first posicli where posicli.clicod = clien.clicod no-lock no-error.
    if avail posicli
    then assign
            vcontapar = vcontapar + posicli.qtdparpg.

    /* Dependentes */
    for each credscore where credscore.campo = "depen"                      
                         and credscore.valor <> 0 no-lock
                       by credscore.vl-ini.
        if credscore.vl-ini = clien.numdep                                    
        then do:                                                            
            run le-credscore.                                               
            leave.                                                          
        end.                                                                
    end.

    /* Possui Fone Convencional */
    find first credscore where credscore.campo = "foneconv"
                           and credscore.valor > 0
                         no-lock no-error.
    if avail credscore and clien.fone <> "" and clien.fone <> ?
    then run le-credscore.

    /* Possui E-mail */
    find first credscore where credscore.campo = "email"
                           and credscore.valor > 0
                         no-lock no-error.
/*message clien.zona avail credscore and clien.zona <> "" and clien.zona <> ?
                       and clien.zona matches("*@*") view-as alert-box.*/
                       
    if avail credscore and clien.zona <> "" and clien.zona <> ?
                       and clien.zona matches("*@*")
    then run le-credscore.

    /* Possui Plano de Saude */
    find first credscore where credscore.campo = "psaude"
                           and credscore.valor > 0
                         no-lock no-error.
    if avail credscore and (avail cpclien and cpclien.var-log7 = yes)
    then run le-credscore.
    
    /* Possui Carro */
    find carro where carro.clicod = clien.clicod no-lock no-error.
    find first credscore where credscore.campo = "carro"
                           and credscore.valor > 0
                         no-lock no-error.
    if avail credscore and avail carro and carro.carsit = yes    
    then do:
        run le-credscore.
        /* Ano de Fabricacao do Carro */
        if carro.ano <> 0
        then do:
            vtempocarro = year(today) - carro.ano.
            for each credscore where credscore.campo = "anocarro"
                                 and credscore.valor > 0
                               no-lock.
                if vtempocarro >= credscore.vl-ini and
                   vtempocarro <= credscore.vl-fin
                then do:
                    run le-credscore.
                    leave.
                end.
            end.                
        end.    
    end.        
    
    /* Grau de Instrucao */
    if avail cpclien
    then
        for each credscore where credscore.campo = "grinstru"
                             and credscore.valor > 0
                           no-lock.
            if credscore.vl-char = acha("INSTRUCAO",cpclien.var-char8)
            then do:
                run le-credscore.
                leave.
            end.
        end.                             
    
    /* Idade */
    vidade = (today - clien.dtnasc) / 365.
    for each credscore where credscore.campo = "idade"
                         and credscore.valor > 0
                       no-lock.
        if vidade >= credscore.vl-ini and
           vidade <= credscore.vl-fin
        then do:
            run le-credscore.
            leave.
        end.
    end.                             
    
    /* Seguros */
    if avail cpclien and cpclien.var-log6 = yes
    then do:
        for each credscore where credscore.campo = "seguros"
                             and credscore.valor > 0
                           no-lock.

            if credscore.vl-char = "Nao Possui" and
               acha("Nao Possui",cpclien.var-char6) <> ?
            then do:
                run le-credscore.
            end.
            if credscore.vl-char = "De Saude" and
               acha("De Saude",cpclien.var-char6) <> ?
            then do:
                run le-credscore.
            end.
            if credscore.vl-char = "De Vida" and
               acha("De Vida",cpclien.var-char6) <> ?
            then do:
                run le-credscore.
            end.
            if credscore.vl-char = "Residencial" and
               acha("Residencial",cpclien.var-char6) <> ?
            then do:
                run le-credscore.
            end.                                    
            if credscore.vl-char = "Automovel" and
               acha("Automovel",cpclien.var-char6) <> ?
            then do:
                run le-credscore.
            end.            
        end.    
    end.    
    
    /* Tempo de Residencia */
/*    message "tempo" view-as alert-box.*/
    if int(substring(string(clien.temres,"999999"),1,2)) > 0 and
       int(substring(string(clien.temres,"999999"),3,4)) > 0
    then do:
        dtemres = date(int(substring(string(clien.temres,"999999"),1,2)),
                       01,
                       int(substring(string(clien.temres,"999999"),3,4))).
        for each credscore where credscore.campo = "tempores"
                             and credscore.valor > 0
                           no-lock.
                                  
            if ((today - dtemres) / 30) >= credscore.vl-ini and
               ((today - dtemres) / 30) <= credscore.vl-fin
            then do:
                run le-credscore.
                leave.
            end.
        end.
    end.    

    /* Tempo de Residencia */
    dtemtra = today - clien.prodta[1].
    for each credscore where credscore.campo = "tempotrab"
                         and credscore.valor > 0
                       no-lock.
        if (dtemtra / 30) >= credscore.vl-ini and
           (dtemtra / 30) <= credscore.vl-fin
        then do:
            run le-credscore.
            leave.
        end.
    end.
    
/* Referencias Bancarias */
if avail cpclien
then do:
    vano = 0.
    do vaux = 1 to 4:
       if vano = 0 or
          (int(cpclien.var-ext4[vaux]) <> 0 and      
           int(cpclien.var-ext4[vaux]) < vano)
        then assign vano = int(cpclien.var-ext4[vaux])
                    vtipoc = int(cpclien.var-ext3[vaux]).
    end.          
    if vano <> 0
    then do:
        for each credscore where credscore.campo = "refban"
                             and credscore.valor > 0
                           no-lock.
            if (year(today) - vano) >= credscore.vl-ini and
               (year(today) - vano) <= credscore.vl-fin
            then do:
                run le-credscore.
                leave.
            end.
        end.    
    end.    
end.
    if vtipoc <> ? and vtipoc <> 0
    then do:
        for each credscore where credscore.campo = "tipconta"
                             and credscore.valor > 0
                           no-lock.
            if vtipoc = 2
            then if credscore.vl-char = "Tipo 2"
                 then run le-credscore.
                 else .
            else if credscore.vl-char = "Tipo 1"
                 then run le-credscore.
                 else .
        end.
    end.
            
if avail cpclien
then do:
    for each credscore where credscore.campo = "cartoes"
                         and credscore.valor > 0
                       no-lock.
      repeat vaux = 1 to 7:
        if ( (int(cpclien.var-int[vaux]) = 1 or
              int(cpclien.var-int[vaux]) = 2) and
             (credscore.vl-char matches("*Visa*") or
              credscore.vl-char matches("*Master*"))) or
           ( (int(cpclien.var-int[vaux]) = 3 or
              int(cpclien.var-int[vaux]) = 4) and
             (credscore.vl-char matches("*Banri*") or
              credscore.vl-char matches("*Hiper*"))) or
           ( int(cpclien.var-int[vaux]) = 5 and
             credscore.vl-char matches("*Loja*")) or
           ( (int(cpclien.var-int[vaux]) = 6 or
              int(cpclien.var-int[vaux]) = 7) and
             (credscore.vl-char matches("*Amex*") or
              credscore.vl-char matches("*Dinners*")))
        then do:
            run le-credscore.
            leave.
        end.
      end. /* repeat ... */  
    end.
end.
        
    /* Sexo */
    for each credscore where credscore.campo = "sexo"
                         and credscore.valor > 0
                       no-lock:
        if (clien.sexo = yes and credscore.vl-char = "Masculino") or 
           (clien.sexo = no and credscore.vl-char = "Feminino")                
        then do:
            run le-credscore.                         
            leave.
        end.
    end.                             
    
    /* Estado Civil */
    vestcivil = "".
    if clien.estciv = 1
    then vestcivil = "Solteiro".
    if clien.estciv = 2
    then vestcivil = "Casado".
    if clien.estciv = 3
    then vestcivil = "Viuvo".
    if clien.estciv = 4
    then vestcivil = "Desquitado".
    if clien.estciv = 5
    then vestcivil = "Divorciado".
    if clien.estciv = 6
    then vestcivil = "Falecido".                    
    for each credscore where credscore.campo = "estcivil"
                         and credscore.valor > 0
                       no-lock:
        if vestcivil = credscore.vl-char
        then do:
            run le-credscore.                         
            leave.
        end.                                           
    end.                             
    
    /* Valor do Salario Minimo */
    find first credscore where credscore.campo = "salariominimo"
                           and credscore.vl-ini > 0
                         no-lock no-error.
    if avail credscore
    then vsalariominimo = credscore.vl-ini.
    else vsalariominimo = 0.
    
    /* Renda em Salarios Minimos */
    if vsalariominimo > 0
    then do:
        find first credscore where credscore.campo = "rensalmin"
                               and credscore.valor > 0
                             no-lock no-error.
        if avail credscore
        then vrensalmin = vrendacalclim / vsalariominimo.
        else vrensalmin = 0.
        if avail credscore and vrensalmin <= credscore.vl-ini
        then run le-credscore.
    end.

    /* Quantidade de Referencias  Pessoais */
    /* Nao preenchimento dos campos da Referencia */
    vcontarefer = 0.
    vcampopess  = 0.
    do ref = 1 to 4:
        if clien.entbairro[ref] <> "" and clien.entbairro[ref] <> ?
        then vcontarefer = vcontarefer + 1.
        if (clien.entbairro[ref] <> "" and clien.entbairro[ref] <> ?) and
           (clien.entcep[ref]    <> "" and clien.entcep[ref] <> ?) or 
           (clien.entcidade[ref] <> "" and clien.entcidade[ref] <> ?) or
           (clien.entcompl[ref]  <> "" and clien.entcompl[ref] <> ?)
        then vcampopess = vcampopess + 1.
    end.
    vrefcampos = no.
    if clien.entbairro[1] = ""
    then vrefcampos = yes.
       
    find first credscore where credscore.campo = "qtdrefer"
                         no-lock no-error.
    if avail credscore
    then do:
        if credscore.valor > 0 and
           vcontarefer <> 0 and
           int(vcontarefer) >= int(credscore.vl-ini)
        then do:
            run le-credscore.
        end.
    end.
    
    find first credscore where credscore.campo = "refernaopreench"    
                           and credscore.valor > 0 no-lock no-error.
    if avail credscore
    then do:
        if (credscore.vl-log = no and vcampopess = 0) or
           (credscore.vl-log = yes and vcampopess > 0)
        then run le-credscore.
    end.
    
    /* Quantidade de Referencias Comerciais */
    /* Nao preenchimento dos campos da Referencia */
    vcontarefer = 0.
    vcampocomer = 0.
    if avail cpclien
    then do ref = 1 to 4:
        if clien.refcom[ref] <> "" and clien.refcom[ref] <> ?
        then vcontarefer = vcontarefer + 1.
        if (clien.refcom[ref]    <> "" and clien.refcom[ref] <> ?) and
           (cpclien.var-ext1[ref]  <> "" and cpclien.var-ext1[ref] <> ?)
        then vcampocomer = vcampocomer + 1.        
    end.
    vrefcampos = no.
    if clien.refcom[1] = ""
    then vrefcampos = yes.
       
    find first credscore where credscore.campo = "qtdreferc"
                         no-lock no-error.
    if avail credscore
    then do:
        if credscore.valor > 0 and
           vcontarefer <> 0 and
           vcontarefer >= credscore.vl-ini
        then do:
            run le-credscore.
        end.
    end.    

    find first credscore where credscore.campo = "refernaopreenchc"    
                           and credscore.valor > 0 no-lock no-error.
    if avail credscore
    then do:
        if (credscore.vl-log = no and vcampocomer = 0) or
           (credscore.vl-log = yes and vcampocomer > 0)
        then run le-credscore.
    end.    
    
    /***
def var qtdpos as int no-undo.
def var v-rcomtotpg       as dec extent 4.
def var v-rcomdeved       as dec extent 4.
    /* Possui carnes em outras lojas */ 
repeat qtdpos = 1 to 4:
    if cpfis.rcomnome[qtdpos] = "" or cpfis.rcomnome[qtdpos] = ?
    then next.
    else do:    
        v-rcomtotpg[qtdpos] = cpfis.rcomparcpg[qtdpos]
                            * cpfis.rcomvlparc[qtdpos].
        v-rcomdeved[qtdpos] = (cpfis.rcomnparc[qtdpos]
                            * cpfis.rcomvlparc[qtdpos])
                            - v-rcomtotpg[qtdpos].    

        if v-rcomdeved[qtdpos] > 0
        then do:
            vcalclimite = vcalclimite - v-rcomdeved[qtdpos].
    find first tt-dados where tt-dados.parametro = cpfis.rcomnome[qtdpos]
                  no-lock no-error.
    if not avail tt-dados
    then do:
        create tt-dados.
        tt-dados.parametro = cpfis.rcomnome[qtdpos].
    end.
    tt-dados.valoralt   = vcalclimite.
    tt-dados.valor      = v-rcomdeved[qtdpos].
    tt-dados.vcalclim   = vcalclimite + v-rcomdeved[qtdpos].
    tt-dados.operacao   = "-".
    find last btt-dados no-lock no-error.
    if not avail btt-dados
    then tt-dados.numseq = 1.
    else tt-dados.numseq = btt-dados.numseq + 1.
            
        end.    
        else next.
    end.    
end.
***/

/*** Foi Unificado tres leituras: leitura de todos os titulos em aberto ***/
vnovatras  = no.
vguardaval = vcalclimite.
vmaioratraso = ?.

for each fin.titulo where fin.titulo.empcod = 19
                      and fin.titulo.titnat = no
                      and fin.titulo.clifor = clien.clicod
                      and fin.titulo.titdtpag = ?
                      and fin.titulo.titsit = "LIB" 
                    no-lock
                    use-index por-clifor.
    if titulo.modcod <> "CRE" and
       titulo.modcod <> "CP0" and
       titulo.modcod <> "CP1" and
       titulo.modcod <> "CPN"
    then next.    

    if fin.titulo.tpcontrato <> ""
    then do.
        /* 1a. leitura */
        if fin.titulo.titdtven < today
        then vnovatras = yes. /* Procura se o cliente tem novacao */

        /* 2a. leitura */
        if vcalclimite > 1500
        then vcalclimite = 1500.
    end.

    /* 3a leitura */
    saldo-aberto = saldo-aberto + fin.titulo.titvlcob.
    if vmaioratraso = ? or
       vmaioratraso < (today - fin.titulo.titdtven)
    then vmaioratraso = (today - fin.titulo.titdtven).
end.

/*****  FIM alteração 09/09/15 ********************/

if vcalclimite <> vguardaval
then do:
    find first tt-dados where tt-dados.parametro = "POSSUI NOVACAO"
                no-lock no-error.
    if not avail tt-dados
    then do:
        create tt-dados.
        tt-dados.parametro = "POSSUI NOVACAO".
    end.
    tt-dados.valoralt = vguardaval.
    tt-dados.vcalclim = vcalclimite.
    tt-dados.valor    = vguardaval.
    tt-dados.operacao = "-".
    find last btt-dados no-lock no-error.
    if not avail btt-dados
    then tt-dados.numseq = 1.
    else tt-dados.numseq = btt-dados.numseq + 1.
end.            

if jacli = 0
then do:
    /* Nota do Cliente */
    for each credscore where credscore.desc-campo = "NOTACLI"
                         and credscore.valor <> 0 no-lock
                       by credscore.vl-ini.
        if avail cpclien and
           cpclien.var-int3 = int(credscore.campo)
        then do:                                                            
            run le-credscore.                                               
            leave.                                                          
        end.                                                                
    end.    
end.

if vcalclimite < 0
then vcalclimite = 0.

if jacli = 1
then if vcalclimite > vlimmaximo
     then vcalclimite = vlimmaximo.
     else .
else if vcalclimite > vlimmaximoc
     then vcalclimite = vlimmaximoc.
     else .

if vnovatras = yes
then do:
    vguardaval = vcalclimite.
    vcalclimite = 0.
    if vcalclimite <> vguardaval
    then do:
        find first tt-dados where tt-dados.parametro = "NOVACAO COM ATRASO"
                no-lock no-error.
        if not avail tt-dados
        then do:
            create tt-dados.
            tt-dados.parametro = "NOVACAO COM ATRASO".
        end.
        tt-dados.valoralt = vguardaval.
        tt-dados.vcalclim = vcalclimite.
        tt-dados.valor    = vguardaval.
        tt-dados.operacao = "-".
        find last btt-dados no-lock no-error.
        if not avail btt-dados
        then tt-dados.numseq = 1.
        else tt-dados.numseq = btt-dados.numseq + 1.
    end.    
end.    

/* */
if vmaioratraso <> ? and vmaioratraso >= vlimmatraso
then do:
    vguardaval = vcalclimite.
    vcalclimite = 0.
    if vcalclimite <> vguardaval
    then do:
        find first tt-dados where tt-dados.parametro = "MEDIA ATRASO > LIMITE"
                no-lock no-error.
        if not avail tt-dados
        then do:
            create tt-dados.
            tt-dados.parametro = "MEDIA ATRASO > LIMITE".
        end.
        tt-dados.valoralt = vguardaval.
        tt-dados.vcalclim = vcalclimite.
        tt-dados.valor    = vguardaval.
        tt-dados.operacao = "-".
        find last btt-dados no-lock no-error.
        if not avail btt-dados
        then tt-dados.numseq = 1.
        else tt-dados.numseq = btt-dados.numseq + 1.
    end.    
end.

/*
message 2 vnovatras view-as alert-box.
*/

/*
end.
else vcalclimite = 0.
*/

/* #3 */
find neuclien where neuclien.clicod = clien.clicod no-lock no-error.
if avail neuclien
then do:
    if neuclien.vlrlimite <> ? and
       neuclien.vlrlimite <> 0 and 
       neuclien.vctolimite >= today 
    then vcalclimite = neuclien.vlrlimite.
    else do:
        /* #4 */
        vcalclimite = 0.
    end.      
end.
else do:
    vcalclimite = 0. /* #4 */
end.
/* #3 */

limite-disponivel = vcalclimite - saldo-aberto.


procedure p-cliente.                                                           

    def input-output parameter vcalclimite as dec.
    def var vcontrpar as int. /* controla as ultimas 10 parcelas */
    def var vmaioratraso as int.
    def var vmediaatraso as dec.
    def var vatraso as dec.

    vcontrpar = 0.
    vmaioratraso = 0.
                                                               
    for each fin.titulo where fin.titulo.empcod = 19
                          and fin.titulo.titnat = no
                          and fin.titulo.clifor = clien.clicod
                          and fin.titulo.titdtpag <> ?
                          and fin.titulo.titsit = "PAG"
                        no-lock
                        break by fin.titulo.titdtpag descending.      
        if titulo.modcod <> "CRE" and
           titulo.modcod <> "CP0" and
           titulo.modcod <> "CP1" and
           titulo.modcod <> "CPN"
        then next.

        if vatraso = 0 or ((today - fin.titulo.titdtven) > 0 and
           vatraso < (today - fin.titulo.titdtven))
        then vatraso = (today - fin.titulo.titdtven).
        if vcontrpar < vnumparcpg
        then do:
            vcontrpar = vcontrpar + 1.   
            vmaioratraso = vmaioratraso +
                                   (fin.titulo.titdtpag - fin.titulo.titdtven).
        end.
        vsomapar = vsomapar + 1.
    end.
    find first posicli where posicli.clicod = clien.clicod no-lock no-error.
    if avail posicli
    then assign
            vsomapar = vsomapar + posicli.qtdparpg.

    vmediaatraso = vmaioratraso / vcontrpar.

    find first agfilcre where
               agfilcre.tipo   = "CREDSCORECP" and
               agfilcre.etbcod = clien.etbcad no-lock no-error.
    find last credscore where 
               (if avail agfilcre
                then credscore.grupo = agfilcre.codigo
                else credscore.grupo = 0) and
               credscore.desc-campo = "PC PAGAS"
                           and credscore.int2 <= vsomapar
                           no-lock no-error.
    if not avail credscore
    then find last credscore where 
                   (if avail agfilcre
                    then credscore.grupo = agfilcre.codigo
                    else credscore.grupo = 0) and
                    credscore.desc-campo = "PC PAGAS"
                                and credscore.int2 <= vsomapar
                                no-lock no-error.
    if avail credscore
    then do:
        vperc = 0.
        vguardaval = vcalclimite.
        par-dias = credscore.int1.
    /*** Luciane - 30/06/2009 - Visita Drebes ***/
    if vmediaatraso <= credscore.valor
    then assign vcalclimite = (vrendacalclim * credscore.vl-ini) / 100
                vperc = credscore.vl-ini.
    else if vmediaatraso > credscore.valor                                                then assign vcalclimite = (vrendacalclim * credscore.vl-fin) / 100
                     vperc = credscore.vl-fin.
         else vcalclimite = vrendacalclim * (vpercrenda / 100).         
         /***/
         /***
         assign vcalclimite = (vrendacalclim * credscore.vl-ini) / 100
                vperc = credscore.vl-ini.
         ***/       
                
         if vcalclimite <> vguardaval
         then do:
             find first tt-dados where tt-dados.parametro = credscore.campo
                  no-lock no-error.
             if not avail tt-dados
             then do:
                 create tt-dados.
                 tt-dados.parametro = /* trim(credscore.desc-campo) + " " + */string(vsomapar) + " pcs pagas".
             end.
             tt-dados.valoralt  = vguardaval.
             tt-dados.percent = vperc.
             /*
/*           tt-dados.valor = if credscore.tipo-vl = yes then ((vguardaval * credscore.valor) / 100) else credscore.valor.*/
*/
            tt-dados.vcalclim = vcalclimite.
            tt-dados.operacao = if tt-dados.vcalclim > tt-dados.valoralt then "+" else "-".
            find last btt-dados no-lock no-error.
            if not avail btt-dados
            then tt-dados.numseq = 1.
            else tt-dados.numseq = btt-dados.numseq + 1.
        end.
        
        /***
        /*** Calculo Henrique ***/
        vguardaval = vcalclimite.
        /*
        if vmediaatraso > 0 and vmediaatraso <= vlimmatraso
        then vcalclimite = vcalclimite - ((vcalclimite * vmediaatraso) / 100).
        else vcalclimite = 0.
        */
        if vmediaatraso > 0
        then if vmediaatraso <= vlimmatraso
             then vcalclimite = vcalclimite
                              - ((vcalclimite * vmediaatraso) / 100).
             else vcalclimite = 0.
        else .                                    
        if vcalclimite <> vguardaval
        then do:
            find first tt-dados where tt-dados.parametro = credscore.campo
                 no-lock no-error.
            if not avail tt-dados
            then do:
                create tt-dados.
                tt-dados.parametro =  "Percentual pela media de atraso: " + string(vmediaatraso) + " dias".
            end.
            tt-dados.valoralt  = vguardaval.
            if vmediaatraso > 0
            then if vmediaatraso > vlimmatraso
                 then tt-dados.percent = 100.
                 else tt-dados.percent = vmediaatraso.
            else .
            tt-dados.vcalclim = vcalclimite.
            tt-dados.operacao = if vmediaatraso < 0 then "+" else "-".
            find last btt-dados no-lock no-error.
            if not avail btt-dados
            then tt-dados.numseq = 1.
            else tt-dados.numseq = btt-dados.numseq + 1.
        end.        
        ***/
        
end.
else vcalclimite = vcalclimite.

/***/
if vcontapar < vnumparcpg
then do:
    for each tt-dados.
        delete tt-dados.
    end.
    vcalclimite = 0.
    find first tt-dados where tt-dados.parametro = credscore.campo
        no-lock no-error.
    if not avail tt-dados
    then do:
        create tt-dados.
        tt-dados.parametro = "Cliente com " + string(vcontapar) + 
            " parcelas pagas (<30 parcelas pagas zera limite)".
    end.
    tt-dados.vcalclim = vcalclimite.
    find last btt-dados no-lock no-error.
    if not avail btt-dados
    then tt-dados.numseq = 1.
    else tt-dados.numseq = btt-dados.numseq + 1.    
end.
/***/

end procedure.


procedure le-credscore.                                                        

    vguardaval = vcalclimite.
    vperc = 0.
/***
   if credscore.tipo-vl = yes /* Percentual */                                     then if credscore.operacao = yes /* Diminui */                                      then if credscore.consnumparc = yes /* Considera parcelas pagas */                   then if vcontapar >= vnumparcpg
                   then do:
                       assign vperc = credscore.valor
                              vcalclimite = vcalclimite                                                                    - ((vcalclimite * credscore.valor)                                               / 100).                                             end.
                   else .
              else do:
                  vperc = credscore.valor.
                  vcalclimite = vcalclimite - ((vcalclimite * credscore.valor)                                 / 100).                                     
              end.             
              /***
          else do:                                                                           vcalclimite = vcalclimite                                                                   - ((vcalclimite * credscore.valor)                   
                           / 100).                                             
          end.                                                              
          ***/
          /* Soma */                                                        
          else if credscore.consnumparc = yes /* Considera parcelas pagas */                   then if vsomapar > vnumparcpg                                                      then do:
                       assign vperc = credscore.valor
                              vcalclimite = vcalclimite                                                                    + ((vcalclimite * credscore.valor)                                               / 100).  
                  end.                   
                  else .
               else do:                                                                          vperc = credscore.valor.
                  vcalclimite = vcalclimite + ((vcalclimite * credscore.valor)                                 / 100).                                     
              end.
              
     else if credscore.operacao = yes /* Diminui */                        
          then if credscore.consnumparc = yes /* Considera parcelas pagas */    
               then if vcontapar > vnumparcpg                                   
                    then vcalclimite = vcalclimite - credscore.valor.           
                    else .                                                      
               else 
                    vcalclimite = vcalclimite - credscore.valor.
               /* Soma */                                                       
          else if credscore.consnumparc = yes /* Considera parcelas pagas */    
               then if vcontapar > vnumparcpg                                                       then vcalclimite = vcalclimite + credscore.valor.
                    else .                                                                    else vcalclimite = vcalclimite + credscore.valor.
***/

/*
message credscore.campo jacli view-as alert-box.
*/


    if credscore.tipo-vl = yes /* Percentual */                                     then if credscore.operacao = yes /* Diminui */                                      then if jacli = 0 or (jacli = 1 and credscore.consnumparc = yes)
                                  /* Considera parcelas pagas */                                then do:
                assign vperc = credscore.valor
                       vcalclimite = vcalclimite                                                                   - ((vcalclimite * credscore.valor)                                              / 100).                                        end.
              else do:
              /***
                  vperc = credscore.valor.
                  vcalclimite = vcalclimite - ((vcalclimite * credscore.valor)                               / 100).                                     
              ***/
              end.             
         /***
        else do:                                                                          vcalclimite = vcalclimite                                                                  - ((vcalclimite * credscore.valor)                   
                           / 100).                                             
         end.                                                              
         ***/
          /* Soma */                                                        
          else if jacli = 0 or (jacli = 1 and credscore.consnumparc = yes)
               then do:
                   assign vperc = credscore.valor
                           vcalclimite = vcalclimite                                                               + ((vcalclimite * credscore.valor)                                              / 100).  
               end.                   
               else do:                                                        
                 /***
                  vperc = credscore.valor.
                  vcalclimite = vcalclimite + ((vcalclimite * credscore.valor)                                 / 100).                                     
                  ***/                                
              end.
              
     else if credscore.operacao = yes /* Diminui */                        
          then if jacli = 0 or (jacli = 1 and credscore.consnumparc = yes)                     then vcalclimite = vcalclimite - credscore.valor.           
               else .                                                      
          /* Soma */                                                       
          else if jacli = 0 or (jacli = 1 and credscore.consnumparc = yes)                      then vcalclimite = vcalclimite + credscore.valor.
               else .
  
/*if vcalclimite <> vguardaval
then message credscore.campo vcalclimite vguardaval view-as alert-box.*/
if vcalclimite <> vguardaval
then do:
find first tt-dados where tt-dados.parametro = credscore.campo no-lock no-error.
if not avail tt-dados
then do:
    create tt-dados.
    if credscore.campo = "cartoes" or credscore.campo = "seguros"
    then
    tt-dados.parametro = credscore.vl-char.
    else
    tt-dados.parametro = credscore.desc-campo.
end.

tt-dados.valoralt  = vguardaval.
tt-dados.percent = vperc.
tt-dados.valor = if credscore.tipo-vl = yes then ((vguardaval * credscore.valor) / 100) else credscore.valor.
tt-dados.vcalclim = vcalclimite.
tt-dados.operacao = if credscore.operacao = yes then "-" else "+".
find last btt-dados no-lock no-error.
if not avail btt-dados
then tt-dados.numseq = 1.
else tt-dados.numseq = btt-dados.numseq + 1.
end.

end procedure.

