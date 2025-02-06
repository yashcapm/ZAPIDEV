CLASS zbp_r_n3_api_view DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zr_n3_api_view.
CLASS-DATA mapped_purchase_requisition TYPE RESPONSE FOR MAPPED i_purchaserequisitiontp.
CLASS-DATA mapped_purchase_order TYPE RESPONSE FOR MAPPED i_purchaseordertp_2.
CLASS-DATA mapped_material_document TYPE RESPONSE FOR MAPPED i_materialdocumenttp.
CLASS-DATA mapped_invoice   TYPE RESPONSE FOR MAPPED           i_billingdocumenttp.

CLASS-DATA : it_api type table of ztt_api_master03,
             it_kunnr TYPE TABLE of ztt_api_master03,
             it_final TYPE TABLE of ztt_api_master03.


ENDCLASS.



CLASS ZBP_R_N3_API_VIEW IMPLEMENTATION.
ENDCLASS.
