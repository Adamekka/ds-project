create or alter trigger TR_AssetVersion_OneApproved
on AssetVersion
after insert, update
as
begin
    set nocount on;

    update av
    set is_approved = 0
    from AssetVersion av
    join inserted i on i.asset_id = av.asset_id
    where i.is_approved = 1
      and av.is_approved = 1
      and av.asset_version_id <> i.asset_version_id;
end;
go

create or alter trigger TR_AssetProjectUsage_CommercialLicense
on AssetProjectUsage
after insert, update
as
begin
    set nocount on;

    if exists (
        select 1
        from inserted i
        join Asset a on a.asset_id = i.asset_id
        join [License] l on l.license_id = a.license_id
        join Project p on p.project_id = i.project_id
        where p.status = 'released'
          and l.is_commercial = 0
    )
    begin
        rollback transaction;
        throw 50001, 'Asset license does not allow usage in a released project.', 1;
    end;
end;
go
