@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projetion view'
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity zi_n3_api_view 
provider contract transactional_query
  as projection on zr_n3_api_view

{
  key Salesorder,
  key Materialbycustomer,
  @ObjectModel.text.element: [ 'CustomerName' ]
  key kunnr,
  key posnr as posnr,
      Status,
      Creationdate,
      Material,
      @ObjectModel.text.element: [ 'PlantName' ]
      Plant,
      Meins,
      @Semantics.quantity.unitOfMeasure : 'meins'
      Requestedquantity,
      customerpricegroup,
      @EndUserText.label: 'Manufacturing BatchID'
      yy1_mfgbatchid_sdi,
      meins_api,
      @Semantics.quantity.unitOfMeasure : 'meins_api'
       @EndUserText.label: 'Rate'
      unit_price,
      @Semantics.text: true
      CustomerName,
      @Semantics.text: true
      PlantName,
      @EndUserText.label: 'Purchase Requisition'
      banfn,
      @EndUserText.label: 'Purchase order'
      ebeln,
      @EndUserText.label: 'GRN No'
      mblnr
}
