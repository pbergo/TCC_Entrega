# TCC Análise de Despesas de Combustíveis de Veículos dos Municípios do Estado de Minas Gerais

Trabalho de Conclusão de Curso apresentado ao Curso de Especialização em Ciência de Dados e Big Data como requisito parcial à obtenção do título de especialista.

## Pós-graduação Lato Sensu em Ciência de Dados e Big Data

## Table of Contents

-[Introdução](#introdução)
-[Diretórios](#diretórios)
-[Fontes de Dados](#fontes-de-dados)
-[Programas Utilizados](#programas-utilizados)
-[Arquitetura](#arquitetura)
-[Configurações realizadas](#configurações-realizadas)

## Introdução

Contém os arquivos e instruções para configuração e     execução dos programas para geração e análises realizadas para o trabalho de conclusão do Curso de Especialização em Ciência de Dados e Big Data.
O diagrama a seguir apresenta o fluxo da informação e como foram obtidos os resultados apresentados no trabalho.
(Diagramas/DIAGRAM DE ELT v03.jpg)

## Diretórios

Diagramas: Contém os desenhos da arqitetura utilizada.
FontesDados: Contém os arquivos fonte originais e extraídos para ingestão.
HQL: Contém uma série de programas HiveQL para tratamento de dados e criaçãod as bases Hive.
IQL: Contém uma série de programas Impala QL para tratamento de dados e criação das bases Impala.
Knime: Contém o Workspace do Knime, que faz a ingestão dos dados fontes para dentro do Cloudera Hive.
Qlik: Contém os programas de análises dos resultados após tratamento.
R: Contém os scripts utilizados para exploração, tratamento e análises dos dados.

## Fontes de Dados
As fontes de dados são:

1. Dados de Despesas com Frotas: https://dadosabertos.tce.mg.gov.br/view/xhtml/paginas/downloadArquivos.xhtml
2. Dados de Veículos: http://www.inmetro.gov.br/consumidor/tabelas_pbe_veicular.asp
3. Dados de Combustíveis: http://www.anp.gov.br/images/Precos/Mensal2013/MENSAL_MUNICIPIOS-DESDE_Jan2013.xlsx
4. Dados dos Municípios: ftp://ftp.ibge.gov.br/Pib_Municipios/2017/base/base_de_dados_2010_2017_xls.zip

## Programas Utilizados
Os programas utilizados para esse trabalho são:

1. VirtualBox for Windows: https://download.virtualbox.org/virtualbox/6.1.4/VirtualBox-6.1.4-136177-Win.exe
2. Cloudera QuickStart VM 5.13: https://docs.cloudera.com/documentation/enterprise/release-notes/topics/cdh_vd_cdh_download_513.html#download_5121
3. Driver ODBC para acesso ao ClouderaHive e Impala: https://www.cloudera.com/downloads/connectors/impala/odbc/2-6-0.html
4. Draw.io para desenho do fluxo da informação: https://www.draw.io/
5. R 3.6: https://cran.r-project.org/bin/windows/base/R-3.6.2-win.exe
6. R Studio: https://download1.rstudio.org/desktop/windows/RStudio-1.2.5033.exe

## Arquitetura:
A arquitetura para realização dos trabalho é:

1. Windows 10 Home Single Language: Contém a estrutura base para instalação e configuração dos programas. Processador i7, 16Gb Memória
2. Linux CentOs: Contém o Cloudera Quickstart executada num VM, com 2 CPU e 8Gb de memória.  
3. Armazenamento de dados: Os programas, scripts, dados fonte e a máquina VM Cloudera utilizaram HD Externo de 500Gb com NTFS.
4. Bases de Dados: Hive para ingestão dos dados e Impala para armazenagem dos dados tratados.

## Configurações realizadas:
1. Aumentar espaço em disco da Cloudera Quickstart VM: 
    https://mikaelsitruk.wordpress.com/2012/12/17/increasing-disk-size-on-hadoop-clouderas-vm/
    https://community.cloudera.com/t5/Support-Questions/cloudera-VM-enlarge-the-HDFS-FS-capacity/td-p/629

2. Aumentar Memória da Cloudera Quickstart VM:
    De 2Gb para 8Gb

