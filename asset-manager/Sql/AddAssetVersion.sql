create or alter procedure AddAssetVersion(
    @p_asset_version_id int,
    @p_asset_id int,
    @p_version_number int,
    @p_file_path varchar(255),
    @p_created_at date,
    @p_changelog varchar(500),
    @p_is_approved bit,
    @p_ret bit out
)
as
begin
    set xact_abort on;
    set @p_ret = 0;

    begin try
        set transaction isolation level serializable;
        begin transaction;

        if not exists (select 1 from Asset with (updlock, holdlock) where asset_id = @p_asset_id)
           or @p_version_number <= 0
           or @p_file_path is null
           or ltrim(rtrim(@p_file_path)) = ''
        begin
            rollback;
            return;
        end;

        if exists (select 1 from AssetVersion where asset_id = @p_asset_id and version_number = @p_version_number)
        begin
            rollback;
            return;
        end;

        if @p_is_approved = 1
        begin
            update AssetVersion
            set is_approved = 0
            where asset_id = @p_asset_id and is_approved = 1;
        end;

        insert into AssetVersion(asset_version_id, asset_id, version_number, file_path, created_at, changelog, is_approved)
        values(@p_asset_version_id, @p_asset_id, @p_version_number, @p_file_path, @p_created_at, @p_changelog, @p_is_approved);

        set @p_ret = 1;
        commit;
    end try
    begin catch
        if @@trancount > 0 rollback;
        set @p_ret = 0;
    end catch;
end;
go
