create or alter procedure AddAsset(
    @p_asset_id int,
    @p_name varchar(100),
    @p_asset_type_id int,
    @p_main_author_id int,
    @p_license_id int,
    @p_file_format varchar(10),
    @p_size_mb decimal(10, 2),
    @p_created_at date,
    @p_is_active bit,
    @p_description varchar(500),
    @p_ret bit out
)
as
begin
    set xact_abort on;
    set @p_ret = 0;

    begin try
        begin transaction;

        if not exists (select 1 from AssetType where asset_type_id = @p_asset_type_id)
           or not exists (select 1 from [Author] where author_id = @p_main_author_id)
           or not exists (select 1 from [License] where license_id = @p_license_id)
        begin
            rollback;
            return;
        end;

        insert into Asset(asset_id, name, asset_type_id, main_author_id, license_id, file_format, size_mb, created_at, is_active, description)
        values(@p_asset_id, @p_name, @p_asset_type_id, @p_main_author_id, @p_license_id, @p_file_format, @p_size_mb, @p_created_at, @p_is_active, @p_description);

        set @p_ret = 1;
        commit;
    end try
    begin catch
        if @@trancount > 0 rollback;
        set @p_ret = 0;
    end catch;
end;
go
