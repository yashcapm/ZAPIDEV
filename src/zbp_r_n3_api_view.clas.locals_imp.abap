CLASS lhc_zr_n3_api_view DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.

    TYPES:
      BEGIN OF post_s,
        user_id TYPE i,
        id      TYPE i,
        title   TYPE string,
        body    TYPE string,
      END OF post_s,

      post_tt TYPE TABLE OF post_s WITH EMPTY KEY,

      BEGIN OF post_without_id_s,
        user_id TYPE i,
        title   TYPE string,
        body    TYPE string,
      END OF post_without_id_s,

      BEGIN OF api_item,
        matnr TYPE matnr,
        posnr TYPE posnr,
        value TYPE zr_api_auto_02-requestedquantity,
      END OF api_item.

    TYPES: tt_str_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY
           ,
           BEGIN OF ts_data,
             data TYPE string,
             tab  TYPE tt_str_tab,
           END OF ts_data.

    DATA: ls_receive  TYPE ts_data,
          lt_response TYPE ts_data.
    DATA: url      TYPE string.
    DATA:it_apiitm TYPE STANDARD TABLE OF  api_item,
         wa_apitem TYPE api_item.


    DATA : ls_api   LIKE LINE OF zbp_r_n3_api_view=>it_api,
           ls_kunnr LIKE LINE OF zbp_r_n3_api_view=>it_kunnr,
           ls_final LIKE LINE OF zbp_r_n3_api_view=>it_final.

    METHODS:
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_web_http_client
        RAISING   cx_static_check.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zr_n3_api_view RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_n3_api_view RESULT result.

    METHODS autopost FOR MODIFY
      IMPORTING keys FOR ACTION zr_n3_api_view~autopost RESULT result.

    METHODS getdata FOR MODIFY
      IMPORTING keys FOR ACTION zr_n3_api_view~getdata RESULT result.

    METHODS grncreate FOR MODIFY
      IMPORTING keys FOR ACTION zr_n3_api_view~grncreate RESULT result.

    METHODS pocreate FOR MODIFY
      IMPORTING keys FOR ACTION zr_n3_api_view~pocreate RESULT result.
    CONSTANTS:
      base_url     TYPE string VALUE 'https://hub-lmi-westeurope-uat.azurewebsites.net/api/SAP_Integration/LMISapPurchaseOrder?Order_Id='

      ,
      content_type TYPE string VALUE 'Content-type',
      json_content TYPE string VALUE 'application/json; charset=UTF-8'.
ENDCLASS.

CLASS lhc_zr_n3_api_view IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD autopost.
    READ ENTITIES OF zr_n3_api_view IN LOCAL MODE
         ENTITY zr_n3_api_view
          ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(data_read)
         FAILED failed.

    DATA(url) = |{ base_url }|.
    TRY.
        DATA(client) = create_client( url ) .
      CATCH  cx_static_check INTO DATA(lv_static_chk).
        DATA(lv_cx_msg) = lv_static_chk->get_text(  ).
    ENDTRY.

    TRY.
        DATA(response) = client->execute( if_web_http_client=>get )->get_text(  ).
*      CATCH cx_web_http_client_error cx_web_message_error.
        "handle exception
      CATCH cx_web_http_client_error cx_web_message_error INTO DATA(lv_static_chk2).
        DATA(lv_cx_msg2) = lv_static_chk2->get_text(  ).
        "handle exception
    ENDTRY.

    DATA : lv_str1  TYPE string,
           lv_str2  TYPE string,
           lv_str3  TYPE string,
           lv_str4  TYPE string,
           lv_str5  TYPE string,
           lv_str6  TYPE string,
           lv_str7  TYPE string,
           lv_str8  TYPE string,
           lv_str9  TYPE string,
           lv_str10 TYPE string.
    SPLIT  response AT '},' INTO  lv_str1  lv_str2 lv_str3 lv_str4 lv_str5
                                           lv_str6  lv_str7 lv_str8 lv_str9 lv_str10.
    CLEAR:lv_str1,lv_str2,lv_str3.
    SPLIT lv_str4 AT ':"' INTO lv_str1 lv_str2.
    IF lv_str2 IS NOT INITIAL.
      DATA(zkunnr) = lv_str2+0(10).
    ELSE.
      zkunnr = '0020000000'.
    ENDIF.
    CLEAR:lv_str1 ,lv_str2 ,lv_str3, lv_str4, lv_str6,  lv_str7, lv_str8, lv_str9, lv_str10.
    SPLIT lv_str5 AT '":' INTO lv_str1 lv_str2 lv_str3 lv_str4 lv_str6  lv_str7 lv_str8 lv_str9 lv_str10.
    CLEAR:lv_str1 ,lv_str2 ,lv_str3, lv_str4.
    SPLIT lv_str6 AT ',' INTO  DATA(dose_id) lv_str1.
    CLEAR:lv_str1.
    SPLIT lv_str7 AT ',' INTO  DATA(unit_price) lv_str1.
    CLEAR:lv_str1.
    SPLIT lv_str8 AT ',' INTO  DATA(dose_transport_cost) lv_str1.
    CLEAR:lv_str1.
    SPLIT lv_str9 AT ',' INTO  DATA(pass_through_cost) lv_str1.

*      IF unit_price IS NOT INITIAL.
    wa_apitem-matnr = '5M'.
    wa_apitem-posnr = '10'.
*      IF unit_price = '0.000'.
    wa_apitem-value = '1'.
*      ELSE.
*        wa_apitem-value = unit_price.
*      ENDIF.
*Unit_Price
    APPEND wa_apitem TO it_apiitm.
    CLEAR:wa_apitem.
*      ENDIF.

    READ TABLE data_read INTO DATA(d_val) INDEX 1.
*    IF d_val-customerpricegroup = '02' OR d_val-customerpricegroup = '05'.
    IF dose_transport_cost IS NOT INITIAL.
      wa_apitem-matnr = '5T'.
      wa_apitem-posnr = '20'.
      wa_apitem-value = '2'.  "dose_transport_cost
      APPEND wa_apitem TO it_apiitm.
      CLEAR:wa_apitem.
*      ENDIF.
    ENDIF.

*        <<<<<<<<<<<<<<<<<<<<Create PR >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    DATA: purchase_requisitions      TYPE TABLE FOR CREATE i_purchaserequisitiontp,
          purchase_requisition       TYPE STRUCTURE FOR CREATE i_purchaserequisitiontp,
          purchase_requisition_items TYPE TABLE FOR CREATE i_purchaserequisitiontp\_purchaserequisitionitem,
          purchase_requisition_item  TYPE STRUCTURE FOR CREATE i_purchaserequisitiontp\\purchaserequisition\_purchaserequisitionitem,
          purchase_reqn_acct_assgmts TYPE TABLE FOR CREATE i_purchasereqnitemtp\_purchasereqnacctassgmt,
          purchase_reqn_acct_assgmt  TYPE STRUCTURE FOR CREATE i_purchasereqnitemtp\_purchasereqnacctassgmt,
          purchase_reqn_delivadds    TYPE TABLE FOR CREATE i_purchasereqnitemtp\_purchasereqndelivaddress,
          purchase_reqn_delivadd     TYPE STRUCTURE FOR CREATE i_purchasereqnitemtp\_purchasereqndelivaddress,
          delivery_date              TYPE i_purchasereqnitemtp-deliverydate,
          n                          TYPE i,
          i                          TYPE i,
          lt_temp                    TYPE TABLE OF zr_n3_api_view,
          wa_temp                    TYPE zr_n3_api_view.
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>


*    LOOP AT data_read ASSIGNING FIELD-SYMBOL(<fs_read>).
    n += 1.
    "purchase requisition
    DATA(cid) = 'My%CID_' && '_' && n.
    purchase_requisition = VALUE #(   %cid                      = cid
                                      purchaserequisitiontype   = 'NB'
                             %control = VALUE #( purchaserequisitiontype = cl_abap_behv=>flag_changed )
                                      ) .
    APPEND purchase_requisition TO purchase_requisitions.

    LOOP AT data_read INTO DATA(w_read).
      wa_temp-yy1_mfgbatchid_sdi  = w_read-yy1_mfgbatchid_sdi.
      wa_temp-plant               = w_read-plant.
      IF w_read-unit_price IS NOT INITIAL.
        wa_temp-unit_price   = w_read-unit_price.
      ELSE.
        wa_temp-unit_price   = '1'.
      ENDIF.

      wa_temp-requestedquantity = w_read-requestedquantity.
      wa_temp-material          = w_read-material.
      COLLECT wa_temp INTO lt_temp.
      CLEAR:wa_temp.
    ENDLOOP.

    LOOP AT lt_temp ASSIGNING FIELD-SYMBOL(<fs_read>).
    select SINGLE * from ztt_lmimapping WHERE plant = @<fs_read>-Plant into @data(wa_lmi).

      i += 1.
      purchase_requisition_item = VALUE #(
                                           %cid_ref = cid
                                           %target  = VALUE #(  (
                                                         %cid                         = |My%ItemCID_{ i }|
                                                         plant                        =  <fs_read>-plant "Plant 01 (DE)
                                                         accountassignmentcategory    = 'K'  "unknown
*                                                        PurchaseRequisitionItem       = wa_apitem-posnr
*                                                       purchasingdocumentitemcategory = '5'
*                                                       PurchaseRequisitionItemText =  . "retrieved automatically from maintained MaterialInfo
                                                         requestedquantity            = <fs_read>-requestedquantity
                                                         purchaserequisitionprice     = <fs_read>-unit_price
                                                         purreqnitemcurrency          = 'GBP'
                                                         material                     = <fs_read>-material"wa_apitem-matnr
                                                         materialgroup               = '10001'
*                                                        Material                  = 'laptop'
*                                                       materialgroup              = 'system'
                                                         purchasinggroup             = '30'
                                                         purchasingorganization     = wa_lmi-pur_org  " ping
                                                         deliverydate                = cl_abap_context_info=>get_system_date( )   "delivery_date  "yyyy-mm-dd (at least 10 days)
                                                         createdbyuser               = cl_abap_context_info=>get_user_alias( )
*                                                           SupplierMaterialNumber         = 'Test'"<fs_read>-MaterialByCustomer
                                                          %control = VALUE #(
                                                          plant                     = cl_abap_behv=>flag_changed
                                                          accountassignmentcategory = cl_abap_behv=>flag_changed
*                                                          PurchaseRequisitionItem   = cl_abap_behv=>flag_changed
                                                          requestedquantity         = cl_abap_behv=>flag_changed
                                                          purchaserequisitionprice  = cl_abap_behv=>flag_changed
                                                          purreqnitemcurrency       = cl_abap_behv=>flag_changed
                                                          material                  = cl_abap_behv=>flag_changed
                                                          materialgroup             = cl_abap_behv=>flag_changed
                                                          purchasinggroup           = cl_abap_behv=>flag_changed
                                                          purchasingorganization    = cl_abap_behv=>flag_changed
                                                          deliverydate              = cl_abap_behv=>flag_changed
                                                          createdbyuser             = cl_abap_behv=>flag_changed
*                                                            SupplierMaterialNumber    = cl_abap_behv=>flag_changed
                                                          )


                                                         ) ) ).
      APPEND purchase_requisition_item TO purchase_requisition_items.

      "purchase requisition account assignment  'My%ItemCID_1'
SELECT SINGLE * FROM ztt_material WHERE material2  = @<fs_read>-material INTO @data(wa_mat).



      purchase_reqn_acct_assgmt = VALUE #(
                                           %cid_ref =  |My%ItemCID_{ i }|
                                           %target  = VALUE #( (
                                                        %cid       = |MyTargetCID_{ i }|
                                                        costcenter = wa_lmi-costcenter " ping
*                                                        profitcenter = wa_mapping-profitcenter
                                                        glaccount  = wa_mat-glacc
                            %control = VALUE #(
                                          costcenter = cl_abap_behv=>flag_changed
                                          glaccount  = cl_abap_behv=>flag_changed
                                           )
                                                         ) ) ) .
      APPEND purchase_reqn_acct_assgmt TO purchase_reqn_acct_assgmts .

*      purchase_reqn_delivadd = VALUE #( %cid_ref = |My%delCID_{ i }|    "200125
*                                        %target = VALUE #( (
*                                                  %cid  = |MydelitCID_{ i }|
*                                                  addressid = '0000000317'
*                                                  manualdeliveryaddressid = '0000000317'
*                                                  careofname = 'CareofNameUpdatedq'
*                                                  plant     = '9401'
*                                                  purchasingdeliveryaddresstype = 'C'
*                                                  correspondencelanguage = 'E'
*                                        ) ) ).
*      APPEND  purchase_reqn_delivadd TO purchase_reqn_delivadds.
*        CLEAR:wa_apitem.
*      ENDLOOP.
    ENDLOOP.
    "purchase requisition
    MODIFY ENTITIES OF i_purchaserequisitiontp
      ENTITY purchaserequisition
        CREATE FIELDS ( purchaserequisitiontype )
        WITH purchase_requisitions
      "purchase requisition item
      CREATE BY \_purchaserequisitionitem
        FIELDS ( plant
*                  purchaserequisitionitemtext
                accountassignmentcategory
*                purchasingdocumentitemcategory
                requestedquantity
                baseunit
                purchaserequisitionprice
                purreqnitemcurrency
                material
                materialgroup
                purchasinggroup
                purchasingorganization
                deliverydate

              )
      WITH purchase_requisition_items
*        <<<<<<<<<<<<<<<<<<<<<<<<             >>>>>>>>>>>>>>>>>>>>>>>
ENTITY purchaserequisitionitem
CREATE BY \_purchasereqnacctassgmt
        FIELDS ( costcenter
                 glaccount
                 quantity
*                   BaseUnit
                 )
        WITH purchase_reqn_acct_assgmts
*        <<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>
    REPORTED DATA(reported_create_pr)
    MAPPED DATA(mapped_create_pr)
    FAILED DATA(failed_create_pr).
    READ ENTITIES OF i_purchaserequisitiontp
    ENTITY purchaserequisition
    ALL FIELDS WITH CORRESPONDING #( mapped_create_pr-purchaserequisition )
    RESULT DATA(pr_result)
    FAILED DATA(pr_failed)
    REPORTED DATA(pr_reported).

    DATA : update_lines TYPE TABLE FOR UPDATE zr_n3_api_view,
           update_line  TYPE STRUCTURE FOR UPDATE zr_n3_api_view.


    zbp_r_n3_api_view=>mapped_purchase_requisition-purchaserequisition = mapped_create_pr-purchaserequisition.
    LOOP AT keys INTO DATA(key).
      update_line-%tky                   = key-%tky.
*        update_line-purchaserequisitio    = 'X'.
      update_line-creationdate   = cl_abap_context_info=>get_system_date(  ).
      APPEND update_line TO update_lines.
    ENDLOOP.

    MODIFY ENTITIES OF zr_n3_api_view IN LOCAL MODE
           ENTITY zr_n3_api_view
             UPDATE
             FIELDS ( creationdate )
             WITH update_lines
             REPORTED reported
             FAILED failed
             MAPPED mapped.

    IF failed IS INITIAL.

      "Read the changed data for action result
      READ ENTITIES OF zr_n3_api_view IN LOCAL MODE
        ENTITY zr_n3_api_view
          ALL FIELDS WITH
          CORRESPONDING #( keys )
        RESULT DATA(result_read).
      "return result entities
      result = VALUE #( FOR result_order IN result_read ( %tky   = result_order-%tky
                                                          %param = result_order ) ).
    ENDIF.
*      ENDLOOP.
*    ELSE.
*      APPEND VALUE #( %tky = keys[ 1 ]-%tky
*                          %msg = new_message_with_text(
*                                   severity = if_abap_behv_message=>severity-error
*                                   text     = msg
*                                 )  )  TO reported-zr_api_auto.
*    ENDIF.


  ENDMETHOD.

  METHOD getdata.
    SELECT *
    FROM zc_api_auto_002
*    LEFT OUTER JOIN ztt_api_master AS B ON A~SalesOrder = B~salesorder
*                                   AND a~MaterialByCustomer = B~materialbycustomer
      WHERE ebeln IS NULL
     INTO TABLE @DATA(it_api).

    IF it_api IS NOT INITIAL.
      SELECT  a~* FROM ztt_api_master AS a
      INNER JOIN @it_api AS b ON a~salesorder = b~salesorder
                            AND a~materialbycustomer = b~materialbycustomer
      INTO TABLE @DATA(it_exe).
    ENDIF.

    LOOP AT it_api ASSIGNING FIELD-SYMBOL(<ws_api>).
      READ TABLE it_exe ASSIGNING FIELD-SYMBOL(<ws_exe>) WITH KEY salesorder = <ws_api>-salesorder
                                                                  materialbycustomer = <ws_api>-materialbycustomer.
      IF sy-subrc EQ 0.
        CLEAR: <ws_api>.
      ENDIF.
    ENDLOOP.

    DELETE it_api WHERE salesorder IS INITIAL.

    LOOP AT it_api INTO DATA(wa_api).
      MOVE-CORRESPONDING wa_api TO ls_api.
      APPEND ls_api TO zbp_r_n3_api_view=>it_api.
    ENDLOOP..


    DATA:it_tab TYPE STANDARD TABLE OF ztt_api_master03,
         wa_tab TYPE ztt_api_master03.

         DATA: lv_url TYPE string,
lo_http_client TYPE REF TO if_web_http_client.
TYPES:
BEGIN OF ty_metadata,
id TYPE string,
uri TYPE string,
type TYPE string,
END OF ty_metadata,

BEGIN OF ty_address_email,
__metadata TYPE ty_metadata,
addressid TYPE string,
person TYPE string,
ordinalnumber TYPE string,
isdefaultemailaddress TYPE string,
emailaddress TYPE string,
searchemailaddress TYPE string,
addresscommunicationremarktext TYPE string,
END OF ty_address_email,
BEGIN OF ty_root,
__count TYPE string,
results TYPE STANDARD TABLE OF ty_address_email WITH EMPTY KEY,
END OF ty_root,
BEGIN OF ty_root1,
d TYPE ty_root,
END OF ty_root1.
DATA : lv_root TYPE ty_root1.

*   <<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>
    LOOP AT it_api INTO wa_api.
      lv_url = |{ base_url }{ wa_api-materialbycustomer }|.
*      DATA(url) = base_url.
*      TRY.
*          DATA(client) = create_client( url ).
**        CATCH cx_static_check.
**          "handle exception
*        CATCH cx_static_check INTO DATA(lv_static_chk).
*          DATA(lv_msg1) = lv_static_chk->get_text(  ).
*          "handle exception
*      ENDTRY.
*      TRY.
*          TRY.
*              DATA(response) = client->execute( if_web_http_client=>get )->get_text(  ).
*            CATCH cx_web_http_client_error cx_web_message_error INTO DATA(lv_static_chk2).
*              DATA(lv_msg2) = lv_static_chk2->get_text(  ).
*              "handle exception
*          ENDTRY.
*        CATCH cx_web_http_client_error cx_web_message_error INTO DATA(lv_static_chk3).
*          DATA(lv_msg3) = lv_static_chk3->get_text(  ).
*          "handle exception
*
*      ENDTRY.
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<new Logic>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
TRY.
lo_http_client = cl_web_http_client_manager=>create_by_http_destination(
i_destination = cl_http_destination_provider=>create_by_url( i_url = lv_url ) ).
CATCH cx_web_http_client_error cx_http_dest_provider_error.
"handle exception
ENDTRY.

DATA(lo_request) = lo_http_client->get_http_request( ).
lo_request->set_header_fields( VALUE #(
( name = 'Accept' value = 'application/json')
( name = 'DataServiceVersion' value = '2.0' )
)
).

lo_request->set_authorization_basic(

EXPORTING i_username = 'admin'

i_password = 'fZXyZJiB9LktTNa'

RECEIVING r_value = DATA(l_value) ).

TRY. DATA(response) = lo_http_client->execute(

i_method = if_web_http_client=>get )->get_text( ).

CATCH cx_web_http_client_error cx_web_message_error.
"handle exception ENDTRY.
ENDTRY.


*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<new Logic end>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      TYPES:BEGIN OF ty_kunnr,
              kunnr TYPE kunnr,
            END OF ty_kunnr.
      DATA : lv_str1  TYPE string,
             lv_str2  TYPE string,
             lv_str3  TYPE string,
             lv_str4  TYPE string,
             lv_str5  TYPE string,
             lv_str6  TYPE string,
             lv_str7  TYPE string,
             lv_str8  TYPE string,
             lv_str9  TYPE string,
             lv_str10 TYPE string,
             it_kunnr TYPE STANDARD TABLE OF ty_kunnr,
             wa_kunnr TYPE ty_kunnr.

      CLEAR:it_kunnr,wa_kunnr,it_tab,wa_tab.
      SPLIT  response AT '},' INTO  lv_str1  lv_str2 lv_str3 lv_str4 lv_str5
                                             lv_str6  lv_str7 lv_str8 lv_str9 lv_str10.
*   **************Transpoter Id***************
      SPLIT: lv_str6 AT '":' INTO DATA(tra1) DATA(tra2) DATA(tra3) DATA(tra4),
             tra3    AT ',"' INTO DATA(trns_id) DATA(tra).
******************Distributor*****************
      SPLIT: lv_str6 AT '":' INTO DATA(dra1) DATA(dra2) DATA(dra3) DATA(dra4),
             dra3    AT ',"' INTO DATA(dis_id) DATA(dra).


**********************************************
      DATA(dose) =  lv_str7.
      SPLIT dose AT '":' INTO DATA(t1) DATA(t2) DATA(t3) DATA(t4) DATA(t5) DATA(t6) DATA(t7)
                              DATA(t8) DATA(t9) DATA(t10)  DATA(t11) DATA(t12) DATA(t13) DATA(t14)
                              DATA(t15) DATA(t16) DATA(t17).
      SPLIT: t6  AT ',"'  INTO DATA(unit_price) DATA(uv1),  "Unit_Price
             t13 AT ',"'  INTO DATA(unit_price_cur) uv1,
             unit_price_cur AT '"' INTO DATA(x) unit_price_cur uv1,
             t10 AT ',"'  INTO DATA(dis_trans) uv1,
             t11 AT ',"'  INTO DATA(fess_cost) uv1,
             t12 AT ',"'  INTO DATA(dis_curr) uv1,
             dis_curr AT '"' INTO  DATA(t) dis_curr uv1,
             t7  AT ',"'  INTO DATA(tra_cost) uv1,  "Dose_Transport_Cost
             t8  AT ',"'  INTO DATA(tra_curr) uv1,
             tra_curr AT '"' INTO x tra_curr uv1.
      DATA(dis) =  dis_trans .  "Dose_distributer_transport_Cost
      DATA(dis2) =   fess_cost. " Dose_distributer_fee_Cost
      DATA(upt)  = t15.   " Unit_Price_Transport



      data:cnt type i.
      CLEAR:lv_str5,lv_str6,lv_str7,cnt.
      SPLIT lv_str4 AT ':"' INTO lv_str5 lv_str6.
      IF unit_price IS NOT INITIAL.
        IF lv_str6 IS NOT INITIAL.
          DATA(zkunnr) = lv_str6+0(10).
        ENDIF.
        SELECT SINGLE * FROM ztt_material WHERE material = @wa_api-material
                                          AND   apitxt   = 'UNIT_PRICE' INTO @DATA(wa_unit_price).

        cnt = cnt + 10.
        ls_kunnr-kunnr = zkunnr.
        ls_kunnr-materialbycustomer = wa_api-materialbycustomer.
        ls_kunnr-meins_api = unit_price_cur.
        ls_kunnr-unit_price = unit_price.
        ls_kunnr-material = wa_unit_price-material2.
        ls_kunnr-posnr = cnt.
        APPEND ls_kunnr TO zbp_r_n3_api_view=>it_kunnr.
        CLEAR:ls_kunnr.
      ENDIF.
*      <<<<<<<<<<<<<<<>>>>>>>>>>>>
      IF tra_cost NE '0'.
       SELECT SINGLE * FROM ztt_material WHERE material = @wa_api-material
                                          AND   apitxt   = 'DOSE_TRANSPORT_COST' INTO @DATA(wa_DOSE_TRANSPORT_COST).
        ls_kunnr-kunnr = trns_id.
        ls_kunnr-materialbycustomer = wa_api-materialbycustomer.
        ls_kunnr-meins_api = tra_curr.
        ls_kunnr-unit_price = tra_cost .
        ls_kunnr-material = wa_DOSE_TRANSPORT_COST-material2.
        cnt = cnt + 10.
        ls_kunnr-posnr = cnt.
        APPEND ls_kunnr TO zbp_r_n3_api_view=>it_kunnr.
        CLEAR:ls_kunnr.
      ENDIF.

      IF wa_api-customerpricegroup = '02' OR wa_api-customerpricegroup = '05'.
        IF dis NE '0'.
         SELECT SINGLE * FROM ztt_material WHERE material = @wa_api-material
                                          AND   apitxt   = 'DOSE_DISTRIBUTER_TRANSPORT_COS' INTO @DATA(wa_DOSE_DISTRIBUTER_TRANSPORT).

          ls_kunnr-kunnr = DIS_id.
          ls_kunnr-materialbycustomer = wa_api-materialbycustomer.
          ls_kunnr-meins_api = dis_curr.
          ls_kunnr-unit_price = dis.
          ls_kunnr-material = wa_DOSE_DISTRIBUTER_TRANSPORT-material2.
          cnt = cnt + 10.
          ls_kunnr-posnr = cnt.
          APPEND ls_kunnr TO zbp_r_n3_api_view=>it_kunnr.
          CLEAR:ls_kunnr.
*        ***********************Fees Cost*********************
        SELECT SINGLE * FROM ztt_material WHERE material = @wa_api-material
                                          AND   apitxt   = 'DOSE_DISTRIBUTER_FEE_COST' INTO @DATA(wa_DOSE_DISTRIBUTER_FEE).

          ls_kunnr-kunnr = DIS_id.
          ls_kunnr-materialbycustomer = wa_api-materialbycustomer.
          ls_kunnr-meins_api = dis_curr.
          ls_kunnr-unit_price = dis2.
          ls_kunnr-material = wa_DOSE_DISTRIBUTER_FEE-material2.
          cnt = cnt + 10.
          ls_kunnr-posnr = cnt.
          APPEND ls_kunnr TO zbp_r_n3_api_view=>it_kunnr.
          CLEAR:ls_kunnr.
        ENDIF.
      ENDIF.
*      <<<<<<<<<<<<<<<Unit_Price_Transport>>>>>>>>>>>>>>>
      IF upt NE '0'.
      SELECT SINGLE * FROM ztt_material WHERE material = @wa_api-material
                                          AND   apitxt   = 'UNIT_PRICE_TRANSPORT' INTO @DATA(wa_UNIT_PRICE_t).
        ls_kunnr-kunnr = zkunnr.
        ls_kunnr-materialbycustomer = wa_api-materialbycustomer.
        ls_kunnr-meins_api = unit_price_cur.
        ls_kunnr-unit_price = upt.
        ls_kunnr-material = wa_UNIT_PRICE_t-material2.
        cnt = cnt + 10.
        ls_kunnr-posnr = cnt.
        APPEND ls_kunnr TO zbp_r_n3_api_view=>it_kunnr.
        CLEAR:ls_kunnr.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD grncreate.
  ENDMETHOD.

  METHOD pocreate.
    READ ENTITIES OF zr_n3_api_view IN LOCAL MODE
             ENTITY zr_n3_api_view ALL FIELDS WITH CORRESPONDING #( keys ) RESULT FINAL(data_read).

    DATA(variable) = lines( data_read ).
    IF variable > 1.
      DATA(msg) = 'You did not pass multiple Lines'.
      DATA(val) = 'X'.
    ENDIF.
    CLEAR val.
    IF val NE 'X'.
      DATA: purchase_orders      TYPE TABLE FOR CREATE i_purchaseordertp_2,
            purchase_order       LIKE LINE OF purchase_orders,
            purchase_order_items TYPE TABLE FOR CREATE i_purchaseordertp_2\_purchaseorderitem,
            purchase_order_item  LIKE LINE OF purchase_order_items,
            lv_matnr             TYPE matnr.
*            update_lines         TYPE TABLE FOR UPDATE zr_api_auto,
*            update_line          TYPE STRUCTURE FOR UPDATE zr_api_auto.
      DATA:it_po TYPE TABLE OF i_purchaseordertp_2,
           wa_po TYPE i_purchaseordertp_2.


      DATA :purchase_order_description TYPE c LENGTH 40.
      DATA(n1) = 0.
      DATA(n2) = 0.
      DATA(count) = 0.
*    <<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*      DATA: lt_temp_key TYPE zgje_transaction_handler02=>tt_temp_key,
*            ls_temp_key LIKE LINE OF lt_temp_key.

*    <<<<<<<<<<<<<<<<<< API Consume >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

      DATA(url) = |{ base_url }|.

      TRY.
          DATA(client) = create_client( url ).
*        CATCH cx_static_check.
          "handle exception
        CATCH cx_static_check INTO DATA(lv_static_chk3).
          DATA(lv_msg3) = lv_static_chk3->get_text(  )..
          "handle exception
      ENDTRY.
      TRY.
          DATA(response) = client->execute( if_web_http_client=>get )->get_text(  ).
*        CATCH cx_web_http_client_error cx_web_message_error.
          "handle exception
        CATCH cx_web_http_client_error cx_web_message_error INTO DATA(lv_static_chk4).
          DATA(lv_msg4) = lv_static_chk4->get_text(  )...
          "handle exception
      ENDTRY.

      DATA : lv_str1  TYPE string,
             lv_str2  TYPE string,
             lv_str3  TYPE string,
             lv_str4  TYPE string,
             lv_str5  TYPE string,
             lv_str6  TYPE string,
             lv_str7  TYPE string,
             lv_str8  TYPE string,
             lv_str9  TYPE string,
             lv_str10 TYPE string.
      SPLIT  response AT '},' INTO  lv_str1  lv_str2 lv_str3 lv_str4 lv_str5
                                             lv_str6  lv_str7 lv_str8 lv_str9 lv_str10.
      CLEAR:lv_str1,lv_str2,lv_str3.
      SPLIT lv_str4 AT ':"' INTO lv_str1 lv_str2.
      IF lv_str2 IS NOT INITIAL.
        DATA(zkunnr) = lv_str2+0(10).
      ELSE.
        zkunnr = '0020000000'.
      ENDIF.
      CLEAR:lv_str1 ,lv_str2 ,lv_str3, lv_str4, lv_str6,  lv_str7, lv_str8, lv_str9, lv_str10.
      SPLIT lv_str5 AT '":' INTO lv_str1 lv_str2 lv_str3 lv_str4 lv_str6  lv_str7 lv_str8 lv_str9 lv_str10.
      CLEAR:lv_str1 ,lv_str2 ,lv_str3, lv_str4.
      SPLIT lv_str6 AT ',' INTO  DATA(dose_id) lv_str1.
      CLEAR:lv_str1.
      SPLIT lv_str7 AT ',' INTO  DATA(unit_price) lv_str1.
      CLEAR:lv_str1.
      SPLIT lv_str8 AT ',' INTO  DATA(dose_transport_cost) lv_str1.
      CLEAR:lv_str1.
      SPLIT lv_str9 AT ',' INTO  DATA(pass_through_cost) lv_str1.

*      IF unit_price IS NOT INITIAL.
      wa_apitem-matnr = '5M'.
      wa_apitem-posnr = '10'.
*      IF unit_price = '0.000'.
      wa_apitem-value = '1'.
*      ELSE.
*        wa_apitem-value = unit_price.
*      ENDIF.
*Unit_Price
      APPEND wa_apitem TO it_apiitm.
      CLEAR:wa_apitem.
*      ENDIF.


*      READ TABLE data_read INTO DATA(d_val) INDEX 1.
*    IF d_val-customerpricegroup = '02' OR d_val-customerpricegroup = '05'.
*      IF dose_transport_cost IS NOT INITIAL.
      wa_apitem-matnr = '5T'.
      wa_apitem-posnr = '20'.
      wa_apitem-value = '1'."dose_transport_cost.
      APPEND wa_apitem TO it_apiitm.
      CLEAR:wa_apitem.
*      ENDIF.
*    ENDIF.
*<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      DATA:lt_temp TYPE STANDARD TABLE OF zr_n3_api_view,
           wa_temp TYPE zr_n3_api_view.
      CLEAR:purchase_orders,purchase_order,
           purchase_order_items,purchase_order_item,
           lv_matnr,n1,n2,lt_temp,wa_temp.

*IF VAL NE 'X'.

      READ TABLE data_read INTO DATA(head) INDEX 1.
      CLEAR:purchase_orders,purchase_order,
       purchase_order_items,purchase_order_item,
       lv_matnr.

      DATA: lv_ebeln TYPE ebeln.

      select SINGLE * from ztt_lmimapping WHERE plant = @head-Plant into @data(wa_lmi).



      n1 += 1.
      purchase_order =  VALUE #( %cid = |My%CID_{ n1 }|
      purchaseordertype      = 'NB'
      companycode            = wa_lmi-companycode
      purchasingorganization = wa_lmi-pur_org
      purchasinggroup        = '30'
      supplier               = head-kunnr
      purchaseorderdate      = cl_abap_context_info=>get_system_date( )
                   %control = VALUE #(
                                   purchaseordertype      = cl_abap_behv=>flag_changed
                                   companycode            = cl_abap_behv=>flag_changed
                                   purchasingorganization = cl_abap_behv=>flag_changed
                                   purchasinggroup        = cl_abap_behv=>flag_changed
                                   supplier               = cl_abap_behv=>flag_changed
                                   purchaseorderdate      = cl_abap_behv=>flag_changed
                                                            ) ).
      APPEND purchase_order TO purchase_orders.




      LOOP AT data_read INTO DATA(w_read).
        wa_temp-yy1_mfgbatchid_sdi = w_read-yy1_mfgbatchid_sdi.
        wa_temp-customerpricegroup = w_read-customerpricegroup.
        wa_temp-plant              = w_read-plant.
        IF w_read-unit_price IS NOT INITIAL.
          wa_temp-unit_price         = w_read-unit_price.
        ELSE.
          wa_temp-unit_price = '1'.
        ENDIF.
        wa_temp-material           = w_read-material.

        SELECT SINGLE banfn
          FROM ztt_api_master03
          WHERE  salesorder = @w_read-salesorder
          AND    materialbycustomer = @w_read-materialbycustomer
          AND    kunnr = @w_read-kunnr
          AND    posnr = @w_read-posnr
          INTO @DATA(banfn).
*      <<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>
        ls_final-salesorder              = w_read-salesorder.
        ls_final-materialbycustomer      = w_read-materialbycustomer.
        ls_final-kunnr =                   w_read-kunnr.
        ls_final-posnr =                   w_read-posnr.
        APPEND ls_final TO zbp_r_n3_api_view=>it_final.



        COLLECT wa_temp INTO lt_temp.
        CLEAR:wa_temp,ls_final.
      ENDLOOP.



      LOOP AT lt_temp ASSIGNING FIELD-SYMBOL(<fs_final>).
        READ TABLE data_read INTO w_read WITH KEY yy1_mfgbatchid_sdi = <fs_final>-yy1_mfgbatchid_sdi.
        IF sy-subrc EQ 0.
          DATA(vso) = w_read-salesorder.
        ENDIF.
*        LOOP AT it_apiitm INTO wa_apitem.



        n2 += 1.
        count +=  10.

        purchase_order_item = VALUE #(  %cid_ref = |My%CID_{ n1 }|
        %target = VALUE #( ( %cid = |My%CID_ITEM{ n2 }|
        material          = <fs_final>-material
        plant             = <fs_final>-plant
        invoiceisgoodsreceiptbased = 'X'
        orderquantity     = <fs_final>-requestedquantity
        purchaseorderitem = count"<fs_final>-posnr
        netpriceamount    = <fs_final>-unit_price
*      PurchasingItemIsFreeOfCharge = 'X'
*      goodsreceiptisnonvaluated = 'X'
        documentcurrency  = 'EUR'
        purchaserequisition = banfn
*       <fs_final>-purchaserequisition
        purchaserequisitionitem = count"<fs_final>-posnr
        suppliermaterialnumber =  w_read-materialbycustomer
        yy1_salesorder_pdi     = vso
        yy1_lmiordertypegroup_pdi = w_read-customerpricegroup
        yy1_mfgbatchid_pdi   = w_read-yy1_mfgbatchid_sdi

*      Batch             = 'TEST999111'
                          %control = VALUE #( material          = cl_abap_behv=>flag_changed
                                              plant             = cl_abap_behv=>flag_changed
                                              orderquantity     = cl_abap_behv=>flag_changed
                                              purchaseorderitem = cl_abap_behv=>flag_changed
                                              invoiceisgoodsreceiptbased = cl_abap_behv=>flag_changed
                                              netpriceamount    = cl_abap_behv=>flag_changed
*                                            PurchasingItemIsFreeOfCharge = cl_abap_behv=>flag_changed
*                                            goodsreceiptisnonvaluated = cl_abap_behv=>flag_changed
                                              documentcurrency  = cl_abap_behv=>flag_changed
                                              purchaserequisition = cl_abap_behv=>flag_changed
                                              purchaserequisitionitem = cl_abap_behv=>flag_changed
                                              suppliermaterialnumber  = cl_abap_behv=>flag_changed
                                              yy1_salesorder_pdi      = cl_abap_behv=>flag_changed
                                              yy1_lmiordertypegroup_pdi = cl_abap_behv=>flag_changed
                                              yy1_mfgbatchid_pdi    = cl_abap_behv=>flag_changed
                                                              ) ) )  ).
        APPEND purchase_order_item TO purchase_order_items.
        CLEAR:purchase_order_item,wa_apitem.
*        ENDLOOP..
      ENDLOOP.
      "Purchase Order Header Data
      MODIFY ENTITIES OF i_purchaseordertp_2
      ENTITY purchaseorder
      CREATE FROM purchase_orders
      CREATE BY \_purchaseorderitem
      FROM purchase_order_items
      MAPPED DATA(mapped_po_headers)
      REPORTED DATA(reported_po_headers)
      FAILED DATA(failed_po_headers).

      WAIT UP TO 2 SECONDS.

      zbp_r_n3_api_view=>mapped_purchase_order-purchaseorder = mapped_po_headers-purchaseorder.
*      LOOP AT keys INTO DATA(key).
*
*        update_line-%tky                   = key-%tky.
*        update_line-ebeln                  = 'X'.
*        APPEND update_line TO update_lines.
*      ENDLOOP.
*      SORT update_lines BY %tky.
*      DELETE ADJACENT DUPLICATES FROM update_lines COMPARING %tky.

*      MODIFY ENTITIES OF zr_n3_api_view IN LOCAL MODE
*            ENTITY zr_n3_api_view
*              UPDATE
*                FIELDS ( ebeln )
*                WITH update_lines
*                REPORTED reported
*                FAILED failed
*                MAPPED mapped.

      IF failed IS INITIAL.
        "Read the changed data for action result
        READ ENTITIES OF zr_n3_api_view IN LOCAL MODE
          ENTITY zr_n3_api_view
            ALL FIELDS WITH
            CORRESPONDING #( keys )
          RESULT DATA(result_read).
        "return result entities
        result = VALUE #( FOR result_order IN result_read ( %tky   = result_order-%tky
                                                            %param = result_order ) ).
      ENDIF.
    ELSE.
      APPEND VALUE #( %tky = keys[ 1 ]-%tky
                               %msg = new_message_with_text(
                                        severity = if_abap_behv_message=>severity-error
                                        text     = msg
                                      )  )  TO reported-zr_n3_api_view.

    ENDIF.

  ENDMETHOD.

  METHOD create_client.
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_n3_api_view DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zr_n3_api_view IMPLEMENTATION.

  METHOD save_modified.
    IF zbp_r_n3_api_view=>it_api IS NOT INITIAL.
      DELETE FROM ztt_api_master03 WHERE salesorder IS NOT INITIAL   .
      DATA:wa_final TYPE ztt_api_master03,
           vposnr   TYPE posnr.
      LOOP AT zbp_r_n3_api_view=>it_api INTO DATA(wa_api).
        CLEAR:vposnr.
        LOOP AT zbp_r_n3_api_view=>it_kunnr INTO DATA(wa_kunnr) WHERE materialbycustomer = wa_api-materialbycustomer.
          MOVE-CORRESPONDING wa_api TO wa_final.
          wa_final-kunnr = wa_kunnr-kunnr.
*          vposnr = vposnr + 10.
          wa_final-posnr = wa_kunnr-posnr.
          wa_final-meins_api = wa_kunnr-meins_api.
          wa_final-unit_price = wa_kunnr-unit_price.
          wa_final-material   = wa_kunnr-material.
          MODIFY ztt_api_master03 FROM @wa_final.
        ENDLOOP.
        CLEAR:wa_final,wa_api.
      ENDLOOP.
    ENDIF.

    DATA : lt_pr TYPE STANDARD TABLE OF ztt_api_master03,
           ls_pr TYPE                   ztt_api_master03,
           keys  TYPE TABLE OF zr_n3_api_view.



    IF zbp_r_n3_api_view=>mapped_purchase_requisition-purchaserequisition IS NOT INITIAL.
      LOOP AT zbp_r_n3_api_view=>mapped_purchase_requisition-purchaserequisition ASSIGNING FIELD-SYMBOL(<fs_pr_mapped>).
        CONVERT KEY OF i_purchaserequisitiontp FROM <fs_pr_mapped>-%pid TO DATA(ls_pr_key).
        <fs_pr_mapped>-purchaserequisition = ls_pr_key-purchaserequisition.
      ENDLOOP.
*
      LOOP AT update-zr_n3_api_view INTO  DATA(ls_poadd). " WHERE %control-OverallStatus = if_abap_behv=>mk-on.
        " Creates internal table with instance data
        DATA(creation_date) = cl_abap_context_info=>get_system_date(  ).
        UPDATE ztt_so_api_01 SET banfn = @ls_pr_key-purchaserequisition
         WHERE salesorder = @ls_poadd-salesorder.

        UPDATE ztt_api_master03  SET banfn = @ls_pr_key-purchaserequisition
         WHERE salesorder = @ls_poadd-salesorder
         AND   materialbycustomer = @ls_poadd-materialbycustomer
         AND   kunnr = @ls_poadd-kunnr
         AND   posnr = @ls_poadd-posnr.

      ENDLOOP.

    ENDIF.

    IF zbp_r_n3_api_view=>mapped_purchase_order IS NOT INITIAL.
      LOOP AT zbp_r_n3_api_view=>mapped_purchase_order-purchaseorder ASSIGNING FIELD-SYMBOL(<fs_po_mapped>).
        CONVERT KEY OF i_purchaseordertp_2 FROM <fs_po_mapped>-%pid TO DATA(ls_po_key).
        <fs_po_mapped>-purchaseorder = ls_po_key-purchaseorder.
      ENDLOOP.
      LOOP AT  zbp_r_n3_api_view=>it_final INTO  DATA(w_read).
        DATA(zuname) = cl_abap_context_info=>get_system_date( ).
        DATA(utime)  = cl_abap_context_info=>get_system_time( ).
        UPDATE ztt_so_api_01
        SET ebeln = @ls_po_key-purchaseorder,
            uname = @zuname,
            utime = @utime

        WHERE salesorder = @w_read-salesorder.
*        AND   salesorderitem = @w_read-salesorderitem.
        UPDATE ztt_api_master03  SET ebeln = @ls_po_key-purchaseorder
                 WHERE salesorder = @w_read-salesorder
                 AND   materialbycustomer = @w_read-materialbycustomer
                 AND   kunnr = @w_read-kunnr
                 AND   posnr = @w_read-posnr.


      ENDLOOP.

    ENDIF.

    IF zbp_r_n3_api_view=>mapped_material_document IS NOT INITIAL.
      LOOP AT zbp_r_n3_api_view=>mapped_material_document-materialdocument ASSIGNING FIELD-SYMBOL(<fs_mat_mapped>).
        CONVERT KEY OF i_materialdocumenttp FROM <fs_mat_mapped>-%pid TO DATA(ls_mat_key).
        <fs_mat_mapped>-materialdocument = ls_mat_key-materialdocument.
      ENDLOOP.
      CLEAR:ls_poadd.

      LOOP AT zbp_r_n3_api_view=>it_final INTO  w_read.
        UPDATE ztt_so_api_01 SET mblnr = @ls_mat_key-materialdocument
        WHERE salesorder = @w_read-salesorder.
*        AND   salesorderitem = @w_read-salesorderitem.
        UPDATE ztt_api_master03  SET mblnr = @ls_mat_key-materialdocument
                  WHERE salesorder = @w_read-salesorder
                  AND   materialbycustomer = @w_read-materialbycustomer
                  AND   kunnr = @w_read-kunnr
                  AND   posnr = @w_read-posnr.


      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
