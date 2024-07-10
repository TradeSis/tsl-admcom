/* Higienizacao de Cadastros   - telas
   Tela de Log  de Higienizacao de Cadastro
*/

{cabec.i}


def var vcpf like neuclien.cpf.
def var vdtini as date format "99/99/9999" Label "De".
def var vdtfim as date format "99/99/9999" Label "Ate".

def var vchave   as char label "Chave".
def var valterou as char label "Alterou Para".


form 
        vCPF   
        vdtini 
        vdtfim
        with frame fcab
        row 3 side-labels centered.
form 
        neuclienhigie.CpfCnpj  
        neuclienhigie.Data  format "999999"
        neuclienhigie.Hora format ">>>>>>>>" column-label "Hora" 
        vchave format "x(50)"
        skip
        space(30)
        valterou format "x(45)"
        with frame frame-a
            width 80 no-box
            6 down row 6.

repeat.

    vcpf = 0.
    update vcpf
        with frame fcab.
    if vcpf = 0
    then do:
        update vdtini vdtfim 
            with frame fcab.
        for each neuclienhigie where 
            neuclienhigie.data >= vdtini and
            neuclienhigie.data <= vdtfim
            no-lock
            break by neuclienhigie.cpf 
                  by neuclienhigie.data desc
                  by neuclienhigie.hora desc.
            run frame-a.
        end.    
    end.
    else do:
        find neuclien where neuclien.cpf = vcpf no-lock no-error.
        if not avail neuclien
        then find neuclien where neuclien.clicod = int(vcpf) no-lock no-error.
        if avail neuclien
        then for each neuclienhigie where 
                neuclienhigie.cpf = neuclien.cpf
             no-lock 
                    break by neuclienhigie.cpf 
                  by neuclienhigie.data desc
                  by neuclienhigie.hora desc.

            run frame-a.
        end.
    end.
end.


procedure frame-a.
    vchave = neuclienhigie.tabelaalt   + "." +
             neuclienhigie.camposchave + "=" +
             neuclienhigie.dadoschave  . 
    valterou = neuclienhigie.campoalt    + " de " +
               (if neuclienhigie.dadoori = ?
                then "?"
                else neuclienhigie.dadoori)     + " p/ " +
               (if neuclienhigie.dadonovo = ?
                then "?"
                else neuclienhigie.dadonovo).
    
    disp 
        neuclienhigie.CpfCnpj  
        neuclienhigie.Data 
        string(neuclienhigie.Hora,"HH:MM:SS") @ neuclienhigie.Hora 
        vchave 
        valterou 
        with frame frame-a.
    down with frame frame-a.         
         
end procedure.         
