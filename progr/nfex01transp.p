

def input parameter par-rec as recid.
def input parameter par-modfrete as int.

def var vnome as char format "x(30)".
def var vqtd  as dec.
def var vesp  as char.
def var vfre  as int format "9" initial 1.
def var vuf   as char format "x(02)" initial "RS".
def var vufplaca as char format "x(2)".
def var vplaca  as char label "Placa".
def var vforcgc like forne.forcgc.
def var vforinest  like forne.forinest.
def var vendereco  as char format "x(50)".
def var vmunicipio as char format "x(30)".
def var vcpf as char format "x(11)".

def var vnvol  as int.
def var vpesol as dec decimals 3.
def var vpesob as dec decimals 3.
def var vespecie  as char.
def var vmarca    as char.
def var vpbruto   as dec.
def var vpliqui   as dec.
find a01_infnfe where recid(a01_infnfe) = par-rec no-lock.

find x01_transp of a01_infnfe no-error.

find plani where plani.etbcod = a01_infnfe.etbcod and
a01_infnfe.placod = a01_infnfe.placod no-lock no-error.
if avail plani then do:
    hide message no-pause.
    message plani.numero.
end.    

    form 
        vplaca colon 16 label "Placa"
        vufplaca label "Uf Veiculo" colon 56
        skip(1)
        frete.frecod label "Transportadora" colon 16
        frete.frenom   no-label
        vnome label "Razao Social"  colon 16
        vforcgc label "CNPJ"            colon 16
        vforinest label "IE"            colon 56
        vendereco label "Endereco" colon 16
        vmunicipio label "Municipio" format "x(35)"   colon 16
        vuf label "UF"                  colon 56
        skip(1)
    
        vqtd  label "Volumes"           colon 16
        vesp  label "Especie"           colon 16
        vmarca label "Marca"            colon 56
        vpesob label "Peso Bruto"       colon 16
        vpesol label "Peso Liquido"    colon 56
        vfre  label "Frete por Conta"   colon 16
        " ( 0-Emitente 1-Destinatario )"
        
        with frame f-placa centered side-label color blue/cyan
        row 7 overlay title " dados do transportador ".
 


if par-modfrete <> 9 /** 9-Sem Frete **/
then do:             /*  Bloco com Frete **/

    if avail X01_transp
    then do: 
        assign
            vfre   = X01_transp.modfrete 
            vnome  = X01_transp.xnome
            vuf    = X01_transp.uf 
            vplaca = X01_transp.placa 
            vforinest = X01_transp.ie 
            vendereco = X01_transp.xender 
            vmunicipio = X01_transp.xmun
            vforcgc = X01_transp.cnpj
            vcpf   = X01_transp.cpf.
    
        find veiculo where veiculo.placa = vplaca no-lock no-error.
        if avail veiculo
        then do:
            vufplaca = veiculo.ufplaca.
            find frete of veiculo no-lock.
            disp vufplaca 
                frete.frecod frete.frenom
                with frame f-placa. 
        end.        
        find first X26_vol where
                X26_vol.chave = A01_infnfe.chave
                no-error.
        if avail X26_vol
        then assign vqtd   = X26_vol.qvol
                    vesp   = X26_vol.esp
                    vmarca = X26_vol.marca
                    vnvol  = X26_vol.nvol
                    vpesol = X26_vol.pesol
                    vpesob = X26_vol.pesob.
    end.                

    if vforcgc = "00000000000000"
    then vforcgc = "".
    
    do on endkey undo:

    disp  
        vplaca
        vnome 
        vforcgc
        vforinest 
        vendereco 
        vuf 
        vmunicipio 
        vqtd 
        vesp 
        vmarca 
        vpesob 
        vpesol 
        vfre  
       with frame f-placa.
    update 
       vplaca 
        with frame f-placa.
    if vplaca <> ""
    then do:
        find veiculo where veiculo.placa = vplaca no-lock no-error.
        if not avail veiculo
        then do:
            message "Veiculo nao Cadastrado " vplaca.
            undo.
        end.
        else do:
            vufplaca = veiculo.ufplaca.
            find frete of veiculo no-lock.
            disp vufplaca
                 frete.frecod
                 frete.frenom
                 with frame f-placa.
            find forne of frete no-lock.
            vnome   = forne.fornom.
            vforcgc = forne.forcgc.
            vforinest = forne.forinest.
            vendereco = forne.forrua.
            vuf       = forne.ufecod.
            vmunicipio = forne.formunic.
            
            disp
                vnome
                vforcgc
                vforinest
                vendereco
                vuf
                vmunicipio
                with frame f-placa.

        end.
    end.
    
    if keyfunction(lastkey) <> "GO"
    then
      update        
        vqtd 
        vesp 
        vmarca
        vpesob
        vpesol
        vfre 
        
        with frame f-placa.
       
/**    update  
        vnome label "Razao Social"  colon 16
        vforcgc label "CNPJ"            colon 16
        vforinest label "IE"            colon 16
        vendereco label "Endereco"      colon 16
        vuf   label "UF"                colon 16
        vplaca    label "Placa"         colon 16
        vmunicipio label "Municipio"    colon 16
        vqtd  label "Volumes"           colon 16
        vesp  label "Especie"           colon 16
        vmarca label "Marca"            colon 16
        vpesob label "Peso Bruto"       colon 16
        vpesol label "Peso Liquido"     colon 16 
        vfre  label "Frete por Conta"   colon 16
        " ( 0-Emitente 1-Destinatario )"
        with frame f-placa centered side-label color blue/cyan
        row 7 overlay title " dados do transportador ".
    **/
            
    end.
    
    if vforcgc = "00000000000000"
    then vforcgc = "".

    find first X01_transp where X01_transp.chave = A01_infnfe.chave no-error.
    if not avail X01_transp
    then create X01_transp.

    assign
        X01_transp.chave = A01_infnfe.chave
        X01_transp.modfrete = vfre
        X01_transp.xnome = vnome
        X01_transp.uf = vuf
        X01_transp.placa = caps(vplaca)
        X01_transp.ie = vforinest
        X01_transp.xender = vendereco
        X01_transp.xmun = vmunicipio
        X01_transp.cnpj = vforcgc
        X01_transp.cpf = vcpf.
    X01_transp.xnome = replace(X01_transp.xnome,"&","E").
    
    find first X26_vol where
               X26_vol.chave = A01_infnfe.chave
               no-error.
    if not avail X26_vol                
    then do:
        create X26_vol.
        X26_vol.chave = A01_infnfe.chave.
    end.     
    assign
        X26_vol.cnpj  = X01_transp.cnpj
        X26_vol.cpf   = X01_transp.cpf
        X26_vol.marca = vmarca
        X26_vol.nvol = vnvol
        X26_vol.qvol = vqtd
        X26_vol.esp  = vesp
        X26_vol.pesol = vpesol
        X26_vol.pesob = vpesob
        .

end.
else do:
    find first X01_transp where X01_transp.chave = A01_infnfe.chave no-error.
    if not avail X01_transp
    then do:
        vfre = 9. /*** Sem frete 07/06/2016 ***/
        create X01_transp.
        assign
            X01_transp.chave = A01_infnfe.chave
            X01_transp.modfrete = vfre .
    end.
end.

hide frame f-placa no-pause.
clear frame f-placa all.

