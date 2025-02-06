@EndUserText.label: 'Material Master'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZI_MaterialMaster
  as select from ZTT_MATERIAL
  association to parent ZI_MaterialMaster_S as _MaterialMasterAll on $projection.SingletonID = _MaterialMasterAll.SingletonID
{
  key MATERIAL as Material,
  key APITXT as Apitxt,
  MATERIAL2 as Material2,
  GLACC as Glacc,
  @Consumption.hidden: true
  1 as SingletonID,
  _MaterialMasterAll
  
}
