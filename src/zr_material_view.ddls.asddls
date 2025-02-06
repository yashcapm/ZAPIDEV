@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Master View'
@Metadata.allowExtensions: true
define root view entity zr_material_view
as select from ztt_material

{
    key material as Material,
    @EndUserText.label: 'API Text'
    key apitxt as Apitxt,
    @EndUserText.label: 'Material2'
    material2 as Material2,
    @EndUserText.label: 'GL Account'
    glacc as Glacc
    
}
