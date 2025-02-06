@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Master Projection View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zi_material_view
 provider contract transactional_query
 as projection on zr_material_view
{
    key Material,
    key Apitxt,
    Material2,
    Glacc
}
