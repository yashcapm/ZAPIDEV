@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'API Projection View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zc_n3_api_new  
as select from ztt_api_master03

{
  key salesorder as Salesorder,
  key materialbycustomer as Materialbycustomer,
  key kunnr as kunnr,
  key posnr as posnr,
  status as Status,
  creationdate as Creationdate,
  material as Material,
  plant as Plant,
  meins as Meins,
   @Semantics.quantity.unitOfMeasure : 'meins'
  requestedquantity as Requestedquantity,
  customerpricegroup,
  yy1_mfgbatchid_sdi,
  meins_api,
  @Semantics.quantity.unitOfMeasure : 'meins_api'
  unit_price,
  banfn,
  ebeln,
  mblnr
   
} where mblnr is initial
