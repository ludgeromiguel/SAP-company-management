*&---------------------------------------------------------------------*
*&  Include           ZBG16_PP_TOP
*&---------------------------------------------------------------------*

"As tabelas com que vou trabalhar
TABLES: zbg16_produto_t,
        zbg16_vendas_t,
        zbg16_empresas_t.

"Variáveis globais
DATA: go_container                  TYPE REF TO cl_gui_custom_container,
      go_alv                        TYPE REF TO cl_gui_alv_grid,
      go_container_carrinho         TYPE REF TO cl_gui_custom_container,
      go_alv_carrinho               TYPE REF TO cl_gui_alv_grid,
      go_container_vendas_filtradas TYPE REF TO cl_gui_custom_container,
      go_alv_vendas_filtradas       TYPE REF TO cl_gui_alv_grid,
      go_container_dados_empresas   TYPE REF TO cl_gui_custom_container,
      go_alv_dados_empresas         TYPE REF TO cl_gui_alv_grid,
      go_container_produtos_empresa TYPE REF TO cl_gui_custom_container,
      go_alv_produtos_empresa       TYPE REF TO cl_gui_alv_grid,
      gt_fieldcat                   TYPE lvc_t_fcat,
      gt_fieldcat_dados_empresas    TYPE lvc_t_fcat,
      gt_fieldcat_produtos          TYPE lvc_t_fcat,
      gt_data_produtos_empresa      TYPE STANDARD TABLE OF zbg16_produto_t,
      gt_data_carrinho              TYPE STANDARD TABLE OF zbg16_vendas_t,
      gt_data                       TYPE STANDARD TABLE OF zbg16_vendas_t,
      gt_carrinho                   TYPE STANDARD TABLE OF zbg16_vendas_t, "carrinho de compras
      gt_data_filtrada              TYPE STANDARD TABLE OF zbg16_vendas_t,
      gt_data_filtrada_produto      TYPE STANDARD TABLE OF zbg16_vendas_t,
      gt_data_filtrada_empresa      TYPE STANDARD TABLE OF zbg16_vendas_t,
      gt_data_filtrada_ambos        TYPE STANDARD TABLE OF zbg16_vendas_t,
      gt_data_dados_empresas        TYPE STANDARD TABLE OF zbg16_empresas_t,
      gs_data_about_empresa         TYPE zbg16_empresas_t,
      gv_venda_id_carrinho          TYPE zbg16_vendas_t-venda_id VALUE 1,
      gv_total                      TYPE zbg16_vendas_t-valor, "armazena o total ao longo das adições
      "gv_total TYPE P DECIMALS 2,
      gv_contador_carrinho          TYPE int1,      "Armazena quantos produtos já foram registados no msm cliente
      gv_registo_carrinho           TYPE int1,
      gv_contador_message           TYPE int1,
      gv_erro_revisao               TYPE int1.         "variavel caso dê erro a finalizar na parte dos stocks
