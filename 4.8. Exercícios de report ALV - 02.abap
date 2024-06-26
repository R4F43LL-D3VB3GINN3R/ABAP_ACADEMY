*&---------------------------------------------------------------------*
*& Report ZREPORT_ALV_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zreport_alv_2.

*Criar um relatório do tipo ALV com o título (Relatório de Ordens de Venda em
*Moeda EURO), conforme descrito abaixo:

TABLES: vbak,  "Tabela Transparente - Documento de Vendas: Dados de Cabeçalho
        vbap,  "Tabela Transparente - Documento de Vendas: Dados de Item
        lips,  "Tabela Transparente - Documento SD: Fornecimento: Dados de Item
        kna1,  "Tabela Transparente - Mestre de Clientes (Parte Geral)
        makt,  "Tabela Transparente - Textos Breves de Material
        tgsbt. "Tabela Transparente - Denominação das Divisões da Empresa

"---------------
"TELA DE SELEÇÃO
"---------------

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_vbeln FOR vbak-vbeln, "Documento de Vendas
                  s_erdat FOR vbak-erdat, "Data de Criação do Registro
                  s_kunnr FOR vbak-kunnr. "Emissor da Ordem
SELECTION-SCREEN END OF BLOCK a1.
SELECTION-SCREEN SKIP 1.

"-------------------------------------------------------------------------------------------------------------------"
"-------------------------------------------------------------------------------------------------------------------"
"-------------------------------------------------------------------------------------------------------------------"
"Variáveis - Estruturas - Tabelas

  "-----------------------

  TYPES: BEGIN OF ty_vbak, "Estrutura - Documento de Vendas: Dados de Cabeçalho
    vbeln TYPE vbak-vbeln, "Documento de Vendas
    erdat TYPE vbak-erdat, "Data de Criação do Registro
    netwr TYPE vbak-netwr, "Valor Líquido da Ordem na Moeda do Documento
    kunnr TYPE vbak-kunnr, "Emissor da Ordem
  END OF ty_vbak.

  DATA: t_vbak  TYPE TABLE OF ty_vbak WITH HEADER LINE , "Tabela Interna - Estrutura - Documento de Vendas: Dados de Cabeçalho
        ls_vbak TYPE ty_vbak.                            "Estrutura - Estrutura - Documento de Vendas: Dados de Cabeçalho

  "-----------------------

  TYPES: BEGIN OF ty_vbap, "Estrutura - Documento de Vendas: Dados de Item
    vbeln TYPE vbap-vbeln, "Documento de Vendas
    posnr TYPE vbap-posnr, "Item do Documento de Vendas
    matnr TYPE vbap-matnr, "Número do Material
    gsber TYPE vbap-gsber, "Divisão.
  END OF ty_vbap.

  DATA: t_vbap  TYPE TABLE OF ty_vbap, "Tabela Interna - Estrutura - Documento de Vendas: Dados de Item
        ls_vbap TYPE ty_vbap.          "Estrutura - Estrutura - Documento de Vendas: Dados de Item

   "-----------------------

  TYPES: BEGIN OF ty_lips, "Estrutura - Documento SD: Fornecimento: Dados de Item
    vbeln TYPE lips-vbeln, "Documento de Vendas
    posnr TYPE lips-posnr, "Item do Documento de Vendas
    vgbel TYPE lips-vgbel, "Nº Documento do Documento de Referência
    vgpos TYPE lips-vgpos, "Nº Item do Item Comercial Modelo
  END OF ty_lips.

  DATA: t_lips  TYPE TABLE OF ty_lips, "Tabela Interna - Estrutura - Documento SD: Fornecimento: Dados de Item
        ls_lips TYPE ty_lips.          "Estrutura - Estrutura - Documento SD: Fornecimento: Dados de Item

  "-----------------------

  TYPES: BEGIN OF ty_kna1, "Estrutura - Mestre de Clientes (Parte Geral)
    kunnr TYPE kna1-kunnr, "Nº do Cliente
    name1 TYPE kna1-name1, "Nome do Cliente
  END OF ty_kna1.

  DATA: t_kna1  TYPE TABLE OF ty_kna1, "Tabela Interna - Estrutura - Mestre de Clientes (Parte Geral)
        ls_kna1 TYPE ty_kna1.          "Estrutura - Estrutura - Mestre de Clientes (Parte Geral)

  "-----------------------

  TYPES: BEGIN OF ty_makt, "Estrutura - Textos Breves de Material
    matnr TYPE makt-matnr, "Número do Material
    maktx TYPE makt-maktx, "Texto Breve de Material
  END OF ty_makt.

  DATA: t_makt  TYPE TABLE OF ty_makt, "Tabela Interna- Estrutura - Textos Breves de Material
        ls_makt TYPE ty_makt.          "Estrutura - Estrutura - Textos Breves de Material

  "-----------------------

  TYPES: BEGIN OF ty_tgsbt, "Estrutura - Denominação das Divisões da Empresa
    gsber TYPE tgsbt-gsber, "Divisão
    gtext TYPE tgsbt-gtext, "Denominação da Divisão
  END OF ty_tgsbt.

  DATA: t_tgsbt  TYPE TABLE OF ty_tgsbt, "Tabela Interna - Estrutura - Denominação das Divisões da Empresa
        ls_tgsbt TYPE ty_tgsbt.          "Estrutura - Estrutura - Denominação das Divisões da Empresa

  "-----------------------

  TYPES: BEGIN OF ty_output, "Estrutura - Tabela de Saída
    vbeln TYPE vbak-vbeln,   "Documento de Vendas -                          [Documento de Vendas: Dados de Cabeçalho]
    erdat TYPE vbak-erdat,   "Data de Criação do Registro -                  [Documento de Vendas: Dados de Cabeçalho]
    netwr TYPE vbak-netwr,   "Valor Líquido da Ordem na Moeda do Documento - [Documento de Vendas: Dados de Cabeçalho]
    kunnr TYPE vbak-kunnr,   "Emissor da Ordem -                             [Documento de Vendas: Dados de Cabeçalho]
    posnr TYPE vbap-posnr,   "Item do Documento de Vendas -                  [Documento de Vendas: Dados de Item]
    matnr TYPE vbap-matnr,   "Número do Material -                           [Documento de Vendas: Dados de Item]
    gsber TYPE vbap-gsber,   "Divisão -                                      [Documento de Vendas: Dados de Item]
    vgbel TYPE lips-vgbel,   "Nº Documento do Documento de Referência -      [Documento SD: Fornecimento: Dados de Item]
    vgpos TYPE lips-vgpos,   "Nº Item do Item Comercial Modelo -             [Documento SD: Fornecimento: Dados de Item]
    name1 TYPE kna1-name1,   "Nome do Cliente -                              [Mestre de Clientes (Parte Geral)]
    maktx TYPE makt-maktx,   "Texto Breve de Material -                      [Textos Breves de Material]
    gtext TYPE tgsbt-gtext,  "Denominação da Divisão -                       [Denominação das Divisões da Empresa]
    kunnr_name1 TYPE string, "Emissor da Ordem + Nome do Cliente
    gsber_gtext TYPE string, "Divisão + Denominação da Divisão
    matnr_maktx TYPE string, "Número do Material + Texto Breve de Material
    status TYPE icon_d,  "Status do Semáforo
  END OF ty_output.

  DATA: t_output  TYPE TABLE OF ty_output WITH HEADER LINE, "Tabela Interna - Estrutura - Tabela de Saída
        ls_output TYPE ty_output.                           "Estrutura - Estrutura - Tabela de Saída

  "-----------------------

  "------------------------------------------------

  "Escopo do ALV - Estrutura - Tabela Interna
  DATA: it_fieldcat      TYPE slis_t_fieldcat_alv,
        wa_fieldcat      TYPE slis_fieldcat_alv.

  "------------------------------------------------

  "Título do ALV
  DATA: lv_datenow    TYPE char10,   "Data Atual
        lv_hour       TYPE sy-uzeit, "Hora Atual
        lv_hour_str   TYPE string,   "Hora
        lv_minute_str TYPE string,   "Minuto
        lv_second_str TYPE string,   "Segundo
        lv_title      TYPE string,   "Título
        lv_supertitle TYPE char70.   "Título Concatenado

  DATA: lv_time_str TYPE string. "String para receber strings de tempo concatenadas

  lv_title = 'Relatório de Ordens de Venda em Moeda EURO'.
  lv_hour = sy-uzeit. "Variável recebe hora atual no sistema.

  " Separação da hora, minuto e segundo
  lv_hour_str   = lv_hour+0(2).
  lv_minute_str = lv_hour+2(2).
  lv_second_str = lv_hour+4(2).

  "Concatenando-os com ":" para formar o horário completo
  CONCATENATE lv_hour_str ':' lv_minute_str ':' lv_second_str INTO lv_time_str.

  "Função para formatar a data
  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal = sy-datum
    IMPORTING
      date_external = lv_datenow.

  "Juntando o título, a data e a hora
  CONCATENATE lv_title lv_datenow lv_time_str INTO lv_supertitle SEPARATED BY ' / '.

"------------------------------------------------

"-------------------------------------------------------------------------------------------------------------------"
"-------------------------------------------------------------------------------------------------------------------"
"-------------------------------------------------------------------------------------------------------------------"

"Subrotinas
START-OF-SELECTION.
  PERFORM get_sales_doc.
  PERFORM get_data_item.
  PERFORM get_data_delivery.
  PERFORM get_client.
  PERFORM get_text_item.
  PERFORM get_division_text.
  PERFORM data_processing.
  PERFORM display_data.
END-OF-SELECTION.

*&---------------------------------------------------------------------*
*& Form get_sales_doc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_sales_doc.

*Selecionar na tabela VBAK os campos VBELN, ERDAT, NETWR e KUNNR, onde
*VBAK-VBELN IN S_VBELN e VBAK-ERDAT IN S_ERDAT e VBAK-KUNNR IN
*S_KUNNR e VBAK-AUART = ‘TA’ e VBAK-WAERK = ‘EUR’. Para testes preencher o
*parâmetro S_ERDAT o período de 01.01.2008 a 31.12.2008. Armazenar registros na
*tabela interna T_VBAK.

  SELECT vbeln, "Selecione o Documento de Vendas
         erdat, "Data de Criação do Registro
         netwr, "Valor Líquido da Ordem na Moeda do Documento
         kunnr  "Emissor da Ordem
         FROM vbak "Da Tabela Transparente - Documento de Vendas: Dados de Cabeçalho
         INTO CORRESPONDING FIELDS OF TABLE @t_vbak "Nos campos correspondentes da Tabela Interna - Documento de Vendas: Dados de Cabeçalho
         WHERE vbeln IN @s_vbeln "Onde o Documento de Vendas está no range do campo de múltipla escolha
         AND erdat IN @s_erdat "E a Data de Criação do Registro está no range do campo de múltipla escolha
         AND kunnr IN @s_kunnr "E o Emissor da Ordem está no range do campo de múltipla escolha
         AND auart = 'TA' "E o Tipo de Documento de Vendas  é 'TA'
         AND waerk = 'EUR'. "E a Moeda do Documento for Euro.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data_item .

*Selecionar na tabela VBAP os campos VBELN, POSNR, MATNR e GSBER,
*relacionados com T_VBAK, onde VBAP-VBELN = T_VBAK-VBELN. Armazenar registros
*na tabela interna T_VBAP.

*+-------------+     +--------------+
*|   VBAK      |     |   VBAP       |
*+-------------+     +--------------+
*| VBELN (PK)  |<--->| VBELN (FK,PK)|
*| ...         |     | POSNR (PK)   |
*+-------------+     | ...          |
*                    +--------------+

  SELECT vbeln, "Selecione o Documento de Vendas
         posnr, "Item do Documento de Vendas
         matnr, "Número do Material
         gsber  "Divisão
         FROM vbap "Da Tabela Transparente - Documento de Vendas: Dados de Item
         INTO CORRESPONDING FIELDS OF TABLE @t_vbap "Nos campos correspondentes da Tabela Interna - Documento de Vendas: Dados de Item
         FOR ALL ENTRIES IN @t_vbak "Relacionada com a Tabela Interna - Documento de Vendas: Dados de Cabeçalho
         WHERE vbeln = @t_vbak-vbeln. "Onde o Documento de Vendas é o mesmo.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_delivery
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data_delivery .

*Selecionar na tabela LIPS os campos VBELN, POSNR, VGBEL e VGPOS,
*relacionados com T_VBAP, onde LIPS-VGBEL = T_VBAP-VBELN e LIPS-VGPOS =
*T_VBAP-POSNR e LIPS-PSTYV = ‘TAN’. Armazenar registros na tabela interna T_LIPS.

*+-------------+     +-------------+      +-------------+
*|   VBAK      |     |   VBAP      |      |   LIPS      |
*+-------------+     +-------------+      +-------------+
*| VBELN (PK)  |<--->| VBELN (FK,PK)|<--->| VBELN (PK)  |
*| ...         |     | POSNR (PK)  |      | ...         |
*+-------------+     | ...         |      | VGBEL (FK)  |
*                    +-------------+      | VGPOS (FK)  |
*                                         +-------------+

  SELECT vbeln, "Selecione o Documento de Vendas
         posnr, "Item do Documento de Vendas
         vgbel, "Nº Documento do Documento de Referência
         vgpos  "Nº Item do Item Comercial Modelo
         FROM lips "Da Tabela Transparente - Documento SD: Fornecimento: Dados de Item
         INTO CORRESPONDING FIELDS OF TABLE @t_lips "Nos Campos correspondentes da Tabela Interna - Documento SD: Fornecimento: Dados de Item
         FOR ALL ENTRIES IN @t_vbap "Relacionado à Tabela Interna - Documento de Vendas: Dados de Item
         WHERE vgbel = @t_vbap-vbeln "Onde fazem parte do mesmo Documento de Vendas
         AND vgpos = @t_vbap-posnr "E são igualmente os mesmos Itens do Documento de Vendas
         AND pstyv = 'TAN'. "E o Tipo de Item de Remessa for padrão."

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_client
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_client .

*Selecionar na tabela KNA1 os campos KUNNR e NAME1, relacionados com
*T_VBAK, onde KNA1-KUNNR = T_VBAK-KUNNR.

*+-------------+     +-------------+
*|   VBAK      |     |   KNA1      |
*+-------------+     +-------------+
*| VBELN (PK)  |     | KUNNR (PK)  |
*| KUNNR (FK)  |<--->| ...         |
*| ...         |     +-------------+
*+-------------+

  SELECT kunnr, "Nº do Cliente
         name1  "Nome do Cliente
         FROM kna1 "Da Tabela Transparente - Mestre de Clientes (Parte Geral)
         INTO CORRESPONDING FIELDS OF TABLE @t_kna1 "Nos campos correspondentes da Tabela Interna - Mestre de Clientes (Parte Geral)
         FOR ALL ENTRIES IN @t_vbak   "Relacionado à Tabela Interna - Documento de Vendas: Dados de Cabeçalho
         WHERE kunnr = @t_vbak-kunnr. "Onde os Números do Cliente são os mesmos.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_text_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_text_item .

*Selecionar na tabela MAKT os campos MATNR e MAKTX, relacionados com
*T_VBAP, onde MAKT-MATNR = T_VBAP-MATNR e SPRAS = SY-LANGU. Armazenar
*registros na tabela interna T_MAKT.

*+-------------+     +-------------+
*|   MAKT      |     |   VBAP      |
*+-------------+     +-------------+
*| MATNR (PK)  |<--->| MATNR (FK)  |
*| MAKTX       |     | VBELN (PK)  |
*| ...         |     | POSNR (PK)  |
*+-------------+     | ...         |
*                    +-------------+

  SELECT matnr, "Selecione o Número do Material
         maktx  "Texto Breve de Material
         FROM makt "Da Tabela Transparente - Textos Breves de Material
         INTO CORRESPONDING FIELDS OF TABLE @t_makt "Nos campos correspondentes da Tabela Interna - Textos Breves de Material
         FOR ALL ENTRIES IN @t_vbap "Relacionado à Tabela Interna - Documento de Vendas: Dados de Item
         WHERE matnr = @t_vbap-matnr "Onde os Números de Materiais são os mesmos
         AND spras = @sy-langu. "E onde o idioma for o mesmo do user logado no sistema.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_division_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_division_text .

*Selecionar na tabela TGSBT os campos GSBER e GTEXT, relacionados com
*T_VBAP, onde TGSBT-GSBER = T_VBAP-GSBER e SPRAS = SY-LANGU.

*+-------------+        +--------------+
*|    TGSBT    |        |     VBAP     |
*+-------------+        +--------------+
*|   GSBER (PK)| 1    N |   GSBER (FK) |
*|   GSBEZ     |--------|   VBELN (PK) |
*|   ...       |        |   POSNR (PK) |
*+-------------+        |   SPRAS      |
*                       +--------------+

  SELECT gsber, "Selecione Divisão
         gtext  "Denominação da Divisão
         FROM tgsbt "Da Tabela Transparente - Denominação das Divisões da Empresa
         INTO CORRESPONDING FIELDS OF TABLE @t_tgsbt "Nos campos correspondentes da Tabela Interna - Denominação das Divisões da Empresa
         FOR ALL ENTRIES IN @t_vbap "Relacionado à Tabela Interna - Documento de Vendas: Dados de Item
         WHERE gsber = @t_vbap-gsber. "Onde o material pertence à unidade da empresa.
         "AND spras = @sy-langu. "E onde o idioma for o mesmo do user logado no sistema.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_processing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM data_processing .

*Processamento:

*Dar um loop na tabela interna T_VBAP.

  LOOP AT t_vbap INTO ls_vbap.

*  Ler a tabela interna T_VBAK, onde T_VBAP-VBELN = T_VBAK-VBELN.
*  Se não encontrar o registro, ler o próximo da tabela interna T_VBAP.

   READ TABLE t_vbak INTO ls_vbak WITH KEY vbeln = ls_vbap-vbeln.
    IF sy-subrc = 0.
*     [Documento de Vendas: Dados de Cabeçalho]
      ls_output-vbeln = ls_vbak-vbeln. "Documento de Vendas
      ls_output-erdat = ls_vbak-erdat. "Data de Criação do Registro
      ls_output-netwr = ls_vbak-netwr. "Valor Líquido da Ordem na Moeda do Documento
      
*     *O campo STATUS deverá ser preenchido com semáforo vermelho se NETWR <=
*     *20000, amarelo se NETWR > 20000 e NETWR <= 40000 e verde se NETWR > 40000.

      IF ls_output-netwr <= 20000.
        ls_output-status = icon_led_red.
      ELSEIF ls_output-netwr <= 40000.
        ls_output-status = icon_led_yellow.
      ELSE.
        ls_output-status = icon_led_green.
      ENDIF.

      ls_output-kunnr = ls_vbak-kunnr. "Emissor da Ordem
*     [Documento de Vendas: Dados de Item]
      ls_output-posnr = ls_vbap-posnr. "Item do Documento de Vendas
      ls_output-matnr = ls_vbap-matnr. "Número do Material
      ls_output-gsber = ls_vbap-gsber. "Divisão
    ENDIF.

*   *Ler a tabela interna T_KNA1, onde T_KNA1-KUNNR = T_VBAK-KUNNR.
*   *Se não encontrar o registro, ler o próximo da tabela interna T_VBAP.

   READ TABLE t_kna1 INTO ls_kna1 WITH KEY kunnr = ls_vbak-kunnr.
    IF sy-subrc = 0.
*      [Mestre de Clientes (Parte Geral)]
       ls_output-name1 = ls_kna1-name1.
    ENDIF.

*  *Ler a tabela interna T_LIPS, onde T_LIPS-VGBEL = T_VBAP-VBELN e T_LIPSVGPOS = T_VBAP-POSNR.
   "Se não encontrar o registro, ler o próximo da tabela interna T_VBAP.

   READ TABLE t_lips INTO ls_lips WITH KEY vgbel = ls_vbap-vbeln
                                           vgpos = ls_vbap-posnr.
     IF sy-subrc = 0.
*      [Documento SD: Fornecimento: Dados de Item]
       ls_output-vgbel = ls_lips-vgbel.
       ls_output-vgpos = ls_lips-vgpos.
     ENDIF.

*   *Ler a tabela interna T_MAKT, onde T_VBAP-MATNR = T_MAKT-MATNR. Se não
*   *encontrar o registro, ler o próximo da tabela interna T_VBAP.

   READ TABLE t_makt INTO ls_makt WITH KEY matnr = ls_vbap-matnr.
     IF sy-subrc = 0.
*      [Textos Breves de Material]
       ls_output-maktx = ls_makt-maktx.
     ENDIF.

*   Ler a tabela interna T_TGSBT, onde T_TGSBT-GSBER = T_VBAP-GSBER. Se
*   não encontrar o registro, ler o próximo da tabela interna T_VBAP.

   READ TABLE t_tgsbt INTO ls_tgsbt WITH KEY gsber = ls_vbap-gsber.
     IF sy-subrc = 0.
*      [Denominação das Divisões da Empresa]
       ls_output-gtext = ls_tgsbt-gtext.
     ENDIF.

    CONCATENATE ls_output-kunnr ls_output-name1 INTO ls_output-kunnr_name1 SEPARATED BY ' - '.
    CONCATENATE ls_output-gsber ls_output-gtext INTO ls_output-gsber_gtext SEPARATED BY ' - '.
    CONCATENATE ls_output-matnr ls_output-maktx INTO ls_output-matnr_maktx SEPARATED BY ' - '.

    APPEND ls_output TO t_output.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_field_catalog USING pt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
  
*Layout do Relatório:
*O relatório deverá imprimir os campos conforme regras abaixo:
  
* *O campo VBELN(VBAK) deverá possui HOTSPOT conforme parâmetros abaixo:

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 1.
  wa_fieldcat-fieldname = 'vbeln'.
  wa_fieldcat-key = 'X'.
  wa_fieldcat-hotspot = 'X'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Número do Documento'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 19.
  wa_fieldcat-ref_tabname = 'VBAK'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 2.
  wa_fieldcat-fieldname = 'erdat'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Data'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 12.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 3.
  wa_fieldcat-fieldname = 'posnr'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Doc. Vendas'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 12.
  APPEND wa_fieldcat TO it_fieldcat.

*  *Efetuar quebra pelos campos da tabela de saída ERDAT KUNNR/NAME1 
  
  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 4.
  wa_fieldcat-fieldname = 'kunnr_name1'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Cliente'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 24.
  APPEND wa_fieldcat TO it_fieldcat.
  
* *O campo NETWR deverá possuir somatória.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 5.
  wa_fieldcat-fieldname = 'netwr'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Valor Líquido'.
  wa_fieldcat-do_sum = 'X'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 6.
  wa_fieldcat-fieldname = 'matnr_maktx'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Material'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 34.
  APPEND wa_fieldcat TO it_fieldcat.

* *O campo VBELN(LIPS) deverá possui HOTSPOT conforme parâmetros abaixo:

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 7.
  wa_fieldcat-fieldname = 'vgbel'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Número Documento (LIPS)'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-hotspot = 'X'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  
* *GSBER/GTEXT. (resultado da concatenação)

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 8.
  wa_fieldcat-fieldname = 'gsber_gtext'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Divisão'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 9.
  wa_fieldcat-fieldname = 'status'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Status'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 15.
  wa_fieldcat-icon = 'X'.
  APPEND wa_fieldcat TO it_fieldcat.

ENDFORM.
FORM display_data .

  PERFORM build_field_catalog USING it_fieldcat.

*Criar 2 botões, um para geração do arquivo TXT e outro do arquivo CSV das
*linhas selecionadas no relatório.

*O cabeçalho do relatório, além do título, deverá ter a data (sy-datum) e a hora (syuzeit) de execução do mesmo

* Configuração do layout

* Definir coloração

*  * Layout do ALV
  DATA: wa_layout TYPE slis_layout_alv.
  wa_layout-colwidth_optimize = 'X'.
  wa_layout-zebra = 'X'.

*   Botões do ALV
  DATA: it_excluding TYPE slis_t_extab.
  APPEND 'PRINT' TO it_excluding.
  APPEND 'SAVE' TO it_excluding.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    i_callback_program      = sy-repid
    i_callback_user_command = 'USER_COMMAND'
    is_layout               = wa_layout
    it_fieldcat             = it_fieldcat
    it_excluding            = it_excluding
    i_grid_title            = lv_supertitle
  TABLES
    t_outtab                = t_output.

ENDFORM.
FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

*  CASE r_ucomm.
*    WHEN '&IC1'.
*      READ TABLE t_output INDEX rs_selfield-tabindex INTO ls_output.
*      IF sy-subrc = 0.
*        CASE rs_selfield-fieldname.
*          WHEN 'VBELN'.
*            SET PARAMETER ID 'AUN' FIELD ls_output-vbeln.
*            CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
*          WHEN 'VGBEL'.
*            SET PARAMETER ID 'VL' FIELD ls_output-vgbel.
*            CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
*        ENDCASE.
*      ENDIF.
*    WHEN 'EXPORT_TXT'.
*      PERFORM export_to_txt.
*    WHEN 'EXPORT_CSV'.
*      PERFORM export_to_csv.
*  ENDCASE.

*SET PARAMETER ID ‘AUN’ FIELD SELFIELD-VALUE.
*CALL TRANSACTION ‘VA03’ AND SKIP FIRST SCREEN.

*SET PARAMETER ID ‘VL’ FIELD SELFIELD-VALUE.
*CALL TRANSACTION ‘VL03N’ AND SKIP FIRST SCREEN.

CASE r_ucomm.
    WHEN '&IC1'. " Este é o comando padrão para hotspots
      READ TABLE t_output INDEX rs_selfield-tabindex INTO ls_output.
      IF sy-subrc = 0.
        PERFORM call_transaction USING ls_output-vbeln.
      ENDIF.
  ENDCASE.

ENDFORM.

FORM call_transaction USING p_vbeln TYPE vbak-vbeln.

  DATA: lv_command TYPE string.

  " Monta o comando para a transação SE16N com o número do documento
  CONCATENATE '/nSE16N' 'VBAK' INTO lv_command SEPARATED BY space.

  " Adiciona o valor do número do documento ao comando
  SET PARAMETER ID 'AUN' FIELD p_vbeln.

  " Chama a transação SE16N com o comando montado
  CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

ENDFORM.
