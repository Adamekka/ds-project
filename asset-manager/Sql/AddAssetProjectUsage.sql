create or alter procedure AddAssetProjectUsage(
    @p_asset_id int,
    @p_project_id int,
    @p_usage_role varchar(100),
    @p_added_at date,
    @p_is_active bit,
    @p_ret bit out
)
as
begin
    set xact_abort on;
    set @p_ret = 0;

    begin try
        begin transaction;

        if not exists (
            select 1
            from Asset a
            join [License] l on l.license_id = a.license_id
            join Project p on p.project_id = @p_project_id
            where a.asset_id = @p_asset_id
              and not (p.status = 'released' and l.is_commercial = 0)
        )
        begin
            rollback;
            return;
        end;

        insert into AssetProjectUsage(asset_id, project_id, usage_role, added_at, is_active)
        values(@p_asset_id, @p_project_id, @p_usage_role, @p_added_at, @p_is_active);

        set @p_ret = 1;
        commit;
    end try
    begin catch
        if @@trancount > 0 rollback;
        set @p_ret = 0;
    end catch;
end;
go
