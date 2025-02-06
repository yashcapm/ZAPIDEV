@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'API Root View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_API_AUTO_02 
as select from zc_api_auto_02

{
  key SalesOrder,
//  key SalesOrderItem,
  min(CreationDate) as CreationDate,
//  min(PurchaseRequisition) as PurchaseRequisition,
//  min(PurchaseRequisitionItem) as PurchaseRequisitionItem,
//  min(Supplier) as Supplier,
  min(Material) as Material,
  min(Plant) as Plant,
  BaseUnit,
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  min(RequestedQuantity) as RequestedQuantity,
  min(banfn) as banfn,
  min(ebeln) as ebeln,
  min(mblnr) as mblnr,
  MaterialByCustomer,
  min(CustomerPriceGroup) as CustomerPriceGroup,
  min(YY1_MfgBatchID_SDI) as YY1_MfgBatchID_SDI
  /* Associations */
  //_RequisitionItem,
  //_SalesOrder
//  _ScheduleLine


} where BaseUnit = 'ZDO' group by SalesOrder,MaterialByCustomer,BaseUnit
