@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'root view'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zr_n3_api_view 
as select from zc_n3_api_new
  association [0..1] to I_Supplier as _Customer on $projection.kunnr = _Customer.Supplier
  association [0..1] to I_Plant  as _Plant on $projection.Plant = _Plant.Plant
{
  key Salesorder,
  key Materialbycustomer,
  key kunnr,
  key posnr as posnr,
      Status,
      Creationdate,
      Material,
      Plant,
      Meins,
      @Semantics.quantity.unitOfMeasure : 'meins'
      Requestedquantity,
      customerpricegroup,
      yy1_mfgbatchid_sdi,
      meins_api,
      @Semantics.quantity.unitOfMeasure : 'meins_api'
      unit_price,
      _Customer.SupplierName as CustomerName,
      _Plant.PlantName,
      banfn ,
      ebeln,
      mblnr
}
