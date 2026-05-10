create or alter procedure GetAssetTypes
as
begin
    set nocount on;

    select asset_type_id, name, description
    from AssetType
    order by name;
end;
go

create or alter procedure GetAsset(
    @asset_id int = null,
    @name varchar(100) = null,
    @asset_type_id int = null
)
as
begin
    set nocount on;

    select top 1 a.asset_id, a.name, aty.name as asset_type, au.name as author_name,
           l.name as license_name, a.file_format, a.size_mb, a.created_at, a.is_active, a.description,
           (select max(av.version_number)
            from AssetVersion av
            where av.asset_id = a.asset_id and av.is_approved = 1) as approved_version_number
    from Asset a
    join AssetType aty on aty.asset_type_id = a.asset_type_id
    join [Author] au on au.author_id = a.main_author_id
    join [License] l on l.license_id = a.license_id
    where (@asset_id is null or a.asset_id = @asset_id)
      and (@name is null or lower(a.name) like lower(@name))
      and (@asset_type_id is null or a.asset_type_id = @asset_type_id)
    order by a.asset_id;
end;
go

create or alter procedure GetAssetVersions(
    @asset_id int
)
as
begin
    set nocount on;

    select asset_version_id, asset_id, version_number, file_path, created_at, changelog, is_approved
    from AssetVersion
    where asset_id = @asset_id
    order by version_number desc;
end;
go

create or alter procedure GetAssetProjects(
    @asset_id int
)
as
begin
    set nocount on;

    select apu.asset_id, apu.project_id, apu.usage_role, apu.added_at, apu.is_active,
           p.name as project_name, p.status as project_status
    from AssetProjectUsage apu
    join Project p on p.project_id = apu.project_id
    where apu.asset_id = @asset_id
    order by p.name;
end;
go

create or alter procedure FindAssets(
    @asset_type_id int = null,
    @only_commercial bit,
    @only_active bit,
    @only_approved bit
)
as
begin
    set nocount on;

    select a.asset_id, a.name, a.asset_type_id, a.main_author_id, a.license_id,
           a.file_format, a.size_mb, a.created_at, a.is_active, a.description
    from Asset a
    join [License] l on l.license_id = a.license_id
    where (@asset_type_id is null or a.asset_type_id = @asset_type_id)
      and (@only_commercial = 0 or l.is_commercial = 1)
      and (@only_active = 0 or a.is_active = 1)
      and (@only_approved = 0 or exists (
          select 1
          from AssetVersion av
          where av.asset_id = a.asset_id and av.is_approved = 1
      ))
    order by a.name;
end;
go

create or alter procedure GetStats
as
begin
    set nocount on;

    select top 10 a.asset_id, a.name, count(*) as usage_count
    from AssetProjectUsage apu
    join Asset a on a.asset_id = apu.asset_id
    where apu.is_active = 1
    group by a.asset_id, a.name
    order by usage_count desc, a.name;
end;
go

create or alter procedure GetAssets
as
begin
    set nocount on;

    select asset_id, name
    from Asset
    order by name;
end;
go
