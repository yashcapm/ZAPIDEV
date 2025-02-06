@EndUserText.label: 'Projection view for'
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZC_API_AUTO_002 
provider contract transactional_query
as projection on ZR_API_AUTO_02
{
 key SalesOrder,
 CreationDate,
// PurchaseRequisition,
// PurchaseRequisitionItem,
// Supplier,
 Material,
 Plant,
 BaseUnit,
 @Semantics.quantity.unitOfMeasure: 'BaseUnit'
 RequestedQuantity,
 @EndUserText.label: 'Purchase Requisition' 
 banfn,
 @EndUserText.label: 'Purchase Order' 
 ebeln,
 mblnr,
 MaterialByCustomer,
 CustomerPriceGroup,
 @EndUserText.label: 'Manufacturing ID'
 YY1_MfgBatchID_SDI
 
 /* Associations */
// _RequisitionItem,
// _SalesOrder
}
