@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'api auto view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zc_api_auto_02 
as select from zc_api_auto_01
//  association [0..1] to I_PurchaseRequisitionItemAPI01 as _RequisitionItem on  $projection.PurchaseRequisition     = _RequisitionItem.PurchaseRequisition
//                                                                           and $projection.PurchaseRequisitionItem = _RequisitionItem.PurchaseRequisitionItem
 association [0..1] to ztt_so_api_01 as _Api on $projection.SalesOrder = _Api.salesorder
{
  key SalesOrder,
//  key SalesOrderItem,
      CreationDate,
//      PurchaseRequisition,
//      PurchaseRequisitionItem,
//      _RequisitionItem.Supplier,
      Material,
      Plant,
//      @Semantics.unitOfMeasure: true
      BaseUnit,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      RequestedQuantity,
      _Api.banfn,
      _Api.ebeln,
      _Api.mblnr,
      MaterialByCustomer,
      HeaderBillingBlockReason,
      CustomerPriceGroup,
      YY1_MfgBatchID_SDI,
      /* Associations */
      _SalesOrder,
//      _ScheduleLine,
//      _RequisitionItem,
      _Api
} where HeaderBillingBlockReason = ' '
  and   DeliveryBlockReason  = ''
