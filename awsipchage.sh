#! /bin/bash

#   PARA DEBUG DESCOMENTE A PROXIMA LINHA
#set -x

function efetuaMudancaIp () {

    if [ -z "$1" ]; then 
        printf "Você precisa definir o Grupo de Seguirança! Obrigado.\n" 
        printf "Ex. ./awsipchage.sh <NOME_DA_REGRA_DE_SEGURANCA> <PORTA_SERVICO> \"<DESCRICAO_DA_REGRA>\"\n"
    else 
        grupoDeSegurancaAws=$1 
    fi

    if [ -z "$2" ]; then 
        printf "Você precisa definir a porta de Serviço! Obrigado.\n" 
        printf "Ex. ./awsipchage.sh <NOME_DA_REGRA_DE_SEGURANCA> <PORTA_SERVICO> \"<DESCRICAO_DA_REGRA>\"\n"
    else 
        portaServicoAws=$2 
    fi

    if [ -z "$3" ]; then 
        printf "Por favor descreva a regra que esta acrescentando, sem catacteres especiais com o maxiomo de 250 caracteres! Obrigado.\n" 
        printf "Ex. ./awsipchage.sh <NOME_DA_REGRA_DE_SEGURANCA> <PORTA_SERVICO> \"<DESCRICAO_DA_REGRA>\"\n"
    else 
        descricaoRegra=$3 
    fi

    # Mude para seu diretorio com o comando $pwd sem a ultima barra (/).
    
    WORK_DIR="$(pwd)"
    
    # Quando executo em um computador novo o IP anterior cadastrado nos grupos 
    # precisa ser eliminado. Assim eu preencho essa variavel com o IP que quero
    # remover dos grupos de segurança. 

    vOldIp=""

    dataComando=$(/bin/date '+%d/%m/%Y %k:%M:%S')
    dataComandoArquivo=$(/bin/date '+%d%m%Y')
    dataAnterior=$(/bin/date --date="1 day ago" '+%d%m%Y')
    dataWAnterior=$(/bin/date --date="5 day ago" '+%d%m%Y')
    arquivoIP="$WORK_DIR/temp/ip_$grupoDeSegurancaAws-$portaServicoAws.old"
    arquivoLog="$WORK_DIR/temp/mudancasLog_$dataComandoArquivo.log"
    arquivoLogAnterior="$WORK_DIR/temp/mudancasLog_$dataAnterior.log"
    arquivoWLogAnterior="$WORK_DIR/temp/mudancasLog_$dataWAnterior.log"

    servicoIP="http://checkip.amazonaws.com/"

    if [ ! -d "$WORK_DIR/temp" ]; then 
        eval "mkdir -p \"$WORK_DIR/temp\""
    fi

    if [ -s "$arquivoLogAnterior" ]; then
        eval "tar -czvf $arquivoLogAnterior.tgz $arquivoLogAnterior > /dev/null 2>&1"
        eval "rm $arquivoLogAnterior"
    fi

    if [ -s "$arquivoWLogAnterior" ]; then
        eval "rm $arquivoWLogAnterior"
    fi

    if [ ! -s "$arquivoLog" ]; then
        eval "touch $arquivoLog"
    fi

    if [ -s "$arquivoIP" ]; then
        correnteIP=$(cat $arquivoIP)
    else 
        if [ -z "$vOldIp" ]
            then
                eval "echo \"0.0.0.0\" > $arquivoIP"
            else
                eval "echo \"$vOldIp\" > $arquivoIP"
        fi
        correnteIP=$(cat $arquivoIP)
    fi

    novoIP=$(curl -s $servicoIP)

    if [ $correnteIP != $novoIP ]; then

        REVOKE_CMD="aws ec2 revoke-security-group-ingress --group-id $grupoDeSegurancaAws --protocol tcp --port $portaServicoAws --cidr $correnteIP/32"
        
        if [ "$arquivoIP" == "0.0.0.0" ]; then
            printf "Primeira execução! Nada a revogar do $grupoDeSegurancaAws"
        else
            eval $REVOKE_CMD 

            printf "[\033[0;31mDEL\033[0m]" 
            printf "%s\t%s"
            printf "Regra de acesso IP $correnteIP removido do grupo $grupoDeSegurancaAws \n"
        fi

        INGRESS_CMD="aws ec2 authorize-security-group-ingress --group-id $grupoDeSegurancaAws --ip-permissions IpProtocol=tcp,FromPort=$portaServicoAws,ToPort=$portaServicoAws,IpRanges='[{CidrIp=$novoIP/32,Description=\"$descricaoRegra\"}]'"
        eval $INGRESS_CMD
            
        printf "[\033[0;32mADD\033[0m]" 
        printf "%s\t%s"
        printf "Regra de acesso a porta $portaServicoAws do IP $novoIP adicionado com sucesso no grupo $grupoDeSegurancaAws \n"
        printf "\n"

        eval "curl -s $servicoIP > $arquivoIP"
        echo "> [$dataComando] - IP TROCADO DE $correnteIP PARA $novoIP EM $grupoDeSegurancaAws ($portaServicoAws)" >> $arquivoLog
        
    else
        echo "[$dataComando] - IP MANTIDO DE $correnteIP PARA $novoIP EM $grupoDeSegurancaAws ($portaServicoAws)" >> $arquivoLog
        
        printf "[\033[0;34mOK\033[0m]" 
        printf "%s\t%s"
        printf "Sem mudanças de IP($correnteIP) no grupo $grupoDeSegurancaAws para a porta $portaServicoAws \n"
        

    fi

}