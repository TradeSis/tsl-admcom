def buffer xneuclien for neuclien.

def var vconta as int format ">>>>>>9"  label "Contagem".
def shared temp-table tt-clien no-undo
    field cpf like neuclien.cpf
    field NOVOCPF as char format "x(14)"  
    field CLICOD  like neuclien.clicod    init ?
    field DATEXP like clien.datexp format "99/99/9999"
    field reg as int    format ">>9"
    field regabe as int format ">>9"
    field regtit as int format ">>9"
    field zerar as log column-label "ZERAR"
    field duplo as log column-label "DUP"
    field caracter as log column-label "CARAC"
    field tamanho  as log column-label "TAM"
    field marca    as log column-label "*" format "*/ " init yes
    index cpf is unique primary cpf asc clicod asc
    index regabe regabe asc.

def shared temp-table tt-clicods no-undo
    field cpf like neuclien.cpf
    field clicod as int format ">>>>>>>>>>9" 
    field datexp like clien.datexp format "99/99/9999"
    field NOVOCPF as char format "x(14)"  
    field zerar as log column-label "ZERAR"
    field duplo as log column-label "DUP"
    field caracter as log column-label "CARAC"
    field tamanho  as log column-label "TAM"
    field sittit   as char format "x(03)" label "Tit"
    index cpf is unique primary cpf asc clicod asc.


def buffer bclien for clien.
def buffer btitulo for titulo.
def var vi as int.
def var vchar as char.
def var vint as int.
def var vnovocpf as char format "x(18)".
def var vtrimcpf as char format "x(18)".
def var vformato    as log format "Err/" label "FMT".
def var v2formato   as char format "x(05)" label "FMT".

def shared var par-cadastramento as log format "Sim/Nao" label "Filtra Cadastramento".
def shared var par-dtcadini as date format "99/99/99" label "de".
def shared var par-dtcadfim as date format "99/99/99" label "ate".
def shared var par-estab as log format "Sim/Nao" label "Filtra Estabel".
def shared var par-etbcad as int format ">>>9" label "Estab".

/*      
def var vchoose as char format "x(40)"  extent 5
            init [" TODOS",
                  " Somente Erro Formato ",
                  " Somente Duplos Com UMA Conta Aberta",
                  " Somente Duplos Sem     Conta Aberta",
                  " Somente Duplos Com VARIAS contas Abertas"].
                  
f    
def var vchoose as char format "x(40)"  extent 5
            init [" TODOS",
                  " Somente Erro Formato ",
                  " Somente Duplos Com UMA Conta Aberta",
                  " Somente Duplos Sem     Conta Aberta",
                  " Somente Duplos Com VARIAS contas Abertas"].
                  
def var tchoose as char format "x(15)"  extent 5
            init ["GERAL",
                  "FOR", 
                  "UMA",
                  "SEM",
                  "VAR"].
def var vindex as int.
def var ptitle as char.
*/

def shared var pchoose as char label "Situacao".

    if par-cadastramento
    then do:
        if par-estab
        then do:
            for each clien use-index etbdtcad  where
                    clien.etbcad = par-etbcad and
                    clien.dtcad >= par-dtcadini
                and clien.dtcad <= par-dtcadfim
                        and clien.tippes = yes
                        no-lock.
                run processa.                
            end. 

        end.
        else do:
            for each clien use-index dtcad  where
                    clien.dtcad >= par-dtcadini
                and clien.dtcad <= par-dtcadfim
                        and clien.tippes = yes
                        no-lock.
                run processa.                
            end. 
        end.       
    end.
    else do:
        if par-estab
        then do: 
            for each clien use-index etbdtcad  where
                    clien.etbcad = par-etbcad and
                         clien.tippes = yes
                        no-lock.
                run processa.                
            end.
        end.
        else do:
            for each clien use-index dtcad  where
                         clien.tippes = yes
                        no-lock.
                run processa.                
            end.
        end. 
    end.

procedure processa.
    
        
        if clien.ciccgc = ? or clien.ciccgc = ""
        then return. 
        if par-estab
        then if par-etbcad <> clien.etbcad
             then next.
 
    vconta = vconta + 1.
    
    if  vconta < 10 or vconta mod 100 = 0 then    
    disp vconta 
         clien.dtcad format "99/99/9999"
         clien.etbcad  
         with centered side-labels 1 down.


    run ajustacpf (input clien.ciccgc,
                   input clien.clicod,
                   no, 
                   output vnovocpf,
                   output vtrimcpf).

    /**
    if vnovocpf = "" 
    then do:
        next.
    end.    
    **/
    if vnovocpf <> "" and vnovocpf <> ?
    then do:
        for each bclien where bclien.ciccgc = vnovocpf 
                           and bclien.clicod <> clien.clicod
                           no-lock.
            run ajustacpf (input bclien.ciccgc,
                           input bclien.clicod,
                           yes,
                           output vnovocpf,
                           output vtrimcpf).
        end.

        if clien.ciccgc <> vnovocpf
        then for each bclien where bclien.ciccgc  = clien.ciccgc 
                           and     bclien.clicod <> clien.clicod
                           no-lock.
            run     ajustacpf (input bclien.ciccgc,
                           input bclien.clicod,
                           yes,
                           output vnovocpf,
                           output vtrimcpf).
        end.

        if vtrimcpf <> vnovocpf
        then for each bclien where bclien.ciccgc  = vtrimcpf
                           and     bclien.clicod <> clien.clicod
                           no-lock.
        
            run ajustacpf (input bclien.ciccgc,
                           input bclien.clicod,
                           yes,
                           output vnovocpf,
                           output vtrimcpf).
        end.
    end.
    
    find first tt-clien where
        tt-clien.cpf = dec(vnovocpf) 
        and
        ((tt-clien.zerar = yes and
          tt-clien.clicod = clien.clicod
         ) 
        or
         tt-clien.zerar = no
        ) 
            no-error.
    if avail tt-clien
    then do:
        find first tt-clicods where
            tt-clicods.cpf = tt-clien.cpf and
            tt-clicods.clicod = clien.clicod
                no-error.
        if not avail tt-clicods
        then do:
            create tt-clicods.
            tt-clicods.cpf = tt-clien.cpf.
            tt-clicods.clicod = clien.clicod.
            tt-clicods.novocpf = vnovocpf . 
            tt-clicods.duplo  = yes.
            tt-clien.reg = tt-clien.reg + 1.
        end.    
    end.    
end procedure.


def var vduplos     as int.
def var vcaracter   as int.
def var vtamanho    as int.
def var vzerar      as int.
def var vescopo     as int.
hide message no-pause.
message "Aguarde, Fazendo Estatisticas...".
for each tt-clien.

   find xneuclien where xneuclien.cpf = tt-clien.cpf no-lock no-error.
   if avail xneuclien
   then if tt-clien.clicod = ?
        then tt-clien.clicod = xneuclien.clicod.
        
   for each tt-clicods where tt-clicods.cpf =  tt-clien.cpf
           and
        ((tt-clicods.zerar = yes and
          tt-clicods.clicod = tt-clien.clicod
         ) 
        or
         tt-clicods.zerar = no
        )          :

           find clien where clien.clicod = tt-clicods.clicod no-lock.
            tt-clicods.datexp = if clien.datexp = ?
                            then 01/01/1901
                            else clien.datexp.
        if tt-clien.datexp = ? then tt-clien.datexp = tt-clicods.datexp.
        tt-clien.datexp = max(tt-clien.datexp,tt-clicods.datexp).
        
    end.             

    for each tt-clicods where tt-clicods.cpf =  tt-clien.cpf
           and
        ((tt-clicods.zerar = yes and
          tt-clicods.clicod = tt-clien.clicod
         ) 
        or
         tt-clicods.zerar = no
        )         
    
        break by tt-clicods.datexp.
        find clien where clien.clicod = tt-clicods.clicod no-lock.
        /*
        find first contrato use-index iconcli where
                contrato.clicod = tt-clicods.clicod
                no-lock no-error.
        */        
        find first titulo use-index iclicod where
            titulo.clifor = tt-clicods.clicod and
            titulo.modcod begins "C" and
            titulo.titnat = no and
            titulo.titsit <> "EXC"
                no-lock no-error.
        if avail titulo
        then do:
            tt-clien.regtit = tt-clien.regtit + 1.
            tt-clicods.sittit = "TIT".
        end.    
                        
        find first btitulo use-index iclicod where
            btitulo.clifor = tt-clicods.clicod and
            btitulo.modcod begins "C" and
            btitulo.titnat = no and
            btitulo.titdtpag = ?
                no-lock no-error.
        

       
        if avail btitulo
        then do:
            tt-clien.regabe = tt-clien.regabe + 1.
            if tt-clien.regabe > 1
            then tt-clien.marca = no.
            tt-clien.clicod = btitulo.clifor.
            tt-clicods.sittit = "ABE".
    
        end.
        else do:
            if avail titulo
            then do:
                if tt-clien.clicod = ?
                then tt-clien.clicod = titulo.clifor.
            end.
            else do:
                /*if avail contrato
                then do:
                    if tt-clien.clicod = ?
                    then tt-clien.clicod = contrato.clicod.
                end.
                else*/ do:
                        if tt-clien.datexp = tt-clicods.datexp
                        then do:
                            if tt-clien.clicod = ?
                            then tt-clien.clicod = tt-clicods.clicod.
                        end.
                end.
            end.            
        end.
                     
    end.
    if pchoose = "GER"
    then.
    else do:
        if pchoose = "FOR"
        then do:
            if tt-clien.reg > 1  
            then do:
                for each tt-clicods where tt-clicods.cpf = tt-clien.cpf.
                    delete tt-clicods.
                end.
                delete      tt-clien.
                next.
            end.
        end.
        if pchoose = "UMA"
        then do:
            if (tt-clien.regabe > 1 or tt-clien.regabe < 1) or
               tt-clien.zera = yes
            then do:
                for each tt-clicods where tt-clicods.cpf = tt-clien.cpf.
                    delete tt-clicods.
                end.
                delete      tt-clien.
                next.
            end.
        end.
        if pchoose = "SEM"
        then do:
            if tt-clien.regabe <> 0  or
            tt-clien.zera = yes
                or 
               tt-clien.reg <= 1
            then do:
                for each tt-clicods where tt-clicods.cpf = tt-clien.cpf.
                    delete tt-clicods.
                end.
                delete      tt-clien.
                next.
            end.
        end.
        if pchoose = "VAR"
        then do:
            if tt-clien.regabe < 2 or
               tt-clien.zera = yes
            then do:
                for each tt-clicods where tt-clicods.cpf = tt-clien.cpf.
                    delete tt-clicods.
                end.
                delete      tt-clien.
                next.
            end.
        end.
        
    end.

    vescopo = vescopo + 1.
    if tt-clien.duplo then vduplos = vduplos +  1.
    if tt-clien.zerar then vzerar  = vzerar  +  1.
    if tt-clien.caracter then vcaracter  = vcaracter  +  1.
    if tt-clien.tamanho then vtamanho  = vtamanho  +  1.



end.


hide message no-pause. 


message "Cpfs" vescopo "Duplos" vduplos "Zerar" vzerar "Caracter" vcaracter "Ta~manho" vtamanho.



/**
for each tt-clien 
    where tt-clien.regabe < 2
    with 
    width 80
    title 
    "Cpfs: " + string(vescopo) +
    " Duplos: " + string(vduplos) + 
    " Zerar: " + string(vzerar) +
    " Caracter: " + string(vcaracter) +
    " Tamanho: " + string(vtamanho).
    vformato = tt-clien.zerar or
               tt-clien.caracter or
               tt-clien.tamanho. 
    find clien where clien.clicod = tt-clien.clicod no-lock no-error.

    disp 
        tt-clien.NOVOCPF column-label "CPF"
        tt-clien.CLICOD  column-label "CODIGO"
        clien.clinom     format "x(32)" when avail clien
        tt-clien.REG     column-label "Regs"
        tt-clien.regtit column-label "Parc"
        tt-clien.REGABE  column-label "Parc!Abe"
        vformato.
            
    for each tt-clicods where tt-clicods.cpf =  tt-clien.cpf
            break by tt-clicods.datexp.
 
        find clien where clien.clicod = tt-clicods.clicod no-lock.
        
        disp clien.ciccgc format "x(14)"
             clien.clicod column-label "CODIGO"
             clien.clinom format  "x(15)"
             clien.etbcad format ">>9" column-label "Etb"
             clien.dtcad format "99/99/9999".
        
        disp tt-clicods.datexp column-label "Alter"
                                                        .
        v2formato = if tt-clicods.zerar
                    then "ZERAR"
                    else if tt-clicods.caracter
                         then "CARACTER"
                         else if tt-clicods.tamanho
                              then "TAMANHO"
                              else "".
        disp v2formato
             tt-clicods.sittit.
        /*                       
        
        find first titulo use-index iclicod where
            titulo.clifor = tt-clicods.clicod and
            titulo.modcod begins "C" and
            titulo.titnat = no
                no-lock no-error.
        find first btitulo use-index iclicod where
            btitulo.clifor = tt-clicods.clicod and
            btitulo.modcod begins "C" and
            btitulo.titnat = no and
            btitulo.titdtpag = ?
                no-lock no-error.
        disp avail titulo label "Tit"
             avail btitulo label "Abe".                
          */   
    end.
end.        
**/
    


procedure ajustacpf.
def  input parameter par-cpf    like clien.ciccgc.
def  input parameter par-clicod like clien.clicod.    
def  input parameter par-duplo  as log.
def output parameter par-novocpf as char.
def output parameter par-trimcpf as char.

def var par-carac  as log.
def var par-taman  as log.
def var par-zerar  as log.


    par-carac = no.
    par-taman = no.
    par-zerar = no.
    par-novocpf = "".
    if par-cpf = ?
    then par-cpf = "".
    
    do vi = 1 to length(par-cpf):
        vchar = substring(par-cpf,vi,1).

        if lookup(substring(par-cpf,vi,1),"0,1,2,3,4,5,6,7,8,9") > 0 
        then vint = int(substring(par-cpf,vi,1)). 
        else vint = ?.
        if vint >= 0 and vint <= 9
        then par-novocpf = par-novocpf + string(vint).
    end.
    par-novocpf = trim(par-novocpf).
    if par-novocpf <> par-cpf
    then  par-carac = yes.
    if length(par-novocpf) < 11
    then do:
        par-taman = yes.
        par-novocpf = fill("0",11 - length(par-novocpf)) + par-novocpf.
    end.
    if dec(par-novocpf) = 0 
    then  do:
        par-novocpf = "".
        par-zerar = yes.
        /**
        next.
        **/
    end.    
    par-trimcpf = trim(string(dec(par-novocpf))).


    find first tt-clien where tt-clien.cpf = dec(par-novocpf) 
            and (if par-zerar
                 then (tt-clien.clicod = par-clicod)
                 else true)
        no-error.
    if avail tt-clien
    then do:
        /*
        tt-clien.reg = tt-clien.reg + 1.
        */
    end.
    else do:
        if par-duplo or
           par-taman or
           par-carac or
           par-zerar 
        then do:
            create tt-clien.
            tt-clien.cpf = dec(par-novocpf).
            tt-clien.novocpf = par-novocpf.
            tt-clien.reg = 0.
            if par-zerar
            then tt-clien.clicod = par-clicod.
            tt-clien.zerar = par-zerar.
        end.
    end.
    
    if avail tt-clien
    then do:    
        tt-clien.caracter = if tt-clien.caracter = no
                            then par-carac
                            else tt-clien.caracter.
        tt-clien.duplo    = if tt-clien.duplo = no
                            then par-duplo
                            else tt-clien.duplo.
        tt-clien.tamanho  = if tt-clien.tamanho = no
                            then par-taman
                            else tt-clien.tamanho.
        tt-clien.zerar    = if tt-clien.zerar = no
                            then par-zerar
                            else tt-clien.zerar.

        find first tt-clicods where 
                tt-clicods.cpf = tt-clien.cpf and
                tt-clicods.clicod = par-clicod
                no-error.
        if not avail tt-clicods
        then do:        
            create tt-clicods.
            tt-clicods.cpf      = tt-clien.cpf.
            tt-clicods.clicod   = par-clicod.
            tt-clien.reg = tt-clien.reg + 1.
            
        end.            
        tt-clicods.novocpf  = par-novocpf.
        tt-clicods.caracter = par-carac.
        tt-clicods.duplo    = par-duplo.
        tt-clicods.tamanho  = par-taman.
        tt-clicods.zerar    = par-zerar.
    end.    



end procedure.

