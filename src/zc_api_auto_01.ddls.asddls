@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'api auto view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zc_api_auto_01 as select distinct from I_SalesOrderItem
association [0..1] to I_SalesOrder as _SalesOrder on $projection.SalesOrder = _SalesOrder.SalesOrder


////                                                               and $projection.SalesOrderItem  = _ScheduleLine.SalesOrderItem
{
    @ObjectModel.foreignKey.association: '_SalesOrder'
    key SalesOrder,
//    key SalesOrderItem,
    CreationDate,
     Product as Material,
    Plant,
    BaseUnit,
     @Semantics.quantity.unitOfMeasure: 'BaseUnit'
    RequestedQuantity,
//   _ScheduleLine.PurchaseRequisition,
//   _ScheduleLine.PurchaseRequisitionItem,
   MaterialByCustomer,
   YY1_MfgBatchID_SDI,
   
   _SalesOrder.HeaderBillingBlockReason,
   _SalesOrder.CustomerPriceGroup,
   _SalesOrder.DeliveryBlockReason,
   
   
//   _ScheduleLine,
   _SalesOrder
}
