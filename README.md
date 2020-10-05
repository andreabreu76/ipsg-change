# AWS IP Change

Práticas de segurança no EC2 nos obriga a controlar e restringir os grupos de segurança para acessos externos provenientes de IP's autorizados. Em ambiente de desenvolvimento, onde a maioria dos usuarios tem conexão doméstica, se faz necessário a mudança do IP de tempos em tempos e normalmente isso é feito logando no console AWS e efetuando a mudança manualmente, e quando há muitos grupos a serem alterados isso toma muito tempo. Este script tem a proposta de ajudar nesta tarefa.  Espero que seja útil.    

## Aviso

É nescessários ter as devidas credenciais de acesso e o AWS Cli instalado. Mostro como instalar a seguir.

## Funcionamento

A primeira execução o pequeno script cria arquivos de armazenamento para controle do IP. Feito isto na proxima execução ele compara o seu IP obtido do proprio recurso oferecido pela [AMAZON AWS](http://checkip.amazonaws.com/). e compara o registrado, se o IP registrado anteriormente for diferente do novo IP obtido o script revoga da regra a menção do IP anterior e cria nova regra com o IP mais recente. 

## Requerimento

Para utiliza-lo corretamente você precisa ter o AWS Cli instalado em seu computador. Veja como instalar:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```

```bash
unzip awscliv2.zip
```

```bash
sudo ./aws/install -i /usr/local/aws-cli -b /usr/local/bin
```

Após a instalação execute o comando a seguir para configurar sua instancia AWS. Tenha suas credenciais em mãos.

```bash
aws configure
```

Agora baixe o script

```bash
git clone https://github.com/andreabreu76/awsipchange.git
```

## Uso

Acesse a pasta

```bash
cd awsipchange/
```

Crie um arquivo ""run.sh"" e preencha os campos obrigatorios para seu correto funcionamento.

```bash
vim run.sh
```

Copie o proximo bloco para dentro do script run.sh editando as partes que vao definir o grupo de segurança e a porta que pretende liberar:

```shell
## NÃO ALTERE ESTE LINHA, ELA FAZ COM QUE A FUNCAO SEJA CARREGADA
source $(pwd)/awsipchange.sh

## EDITE AS LINHAS A SEGUIR ALTERANDO COMO PRECISAR
# efetuaMudancaIp <grupo_de_seguranca_aws> <porta> <comentario/identificação>
efetuaMudancaIp sg-1234567891011121314abc 22 "SSH / MEU NOME - HOME"
efetuaMudancaIp sg-1234567891011121314abc 80 "HTTP / MEU NOME - HOME"
efetuaMudancaIp sg-1234567891011121314abc 3306 "MYSQL MY HOME" 
```

Agora toda vez que seu IP publico mudar é só executar o script.

```bash
./run.sh
```

Ou pode adiciona-lo ao seu CRON

```shell
* */1 * * * /home/meuusuario/pastadoscrip/run.sh  >/dev/null 2>&1
```

Com esta linha o script irá ser executado a cada uma hora e manterar seu IP atualizado sempre que precisar. 

### EXTRA

No Ubuntu 20.04 eu utilizo a extensão ShowIP ([Public IP - GNOME Shell Extensions](https://extensions.gnome.org/extension/1677/public-ip/)) ela me mostra o meu IP publico e assim que ele muda e eu percebo eu vou até o diretorio e executo o run.sh
